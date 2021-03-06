module PoolParty  
  class Cloud < DslBase
    
    # Options we want on the output of the compiled script
    # but want to take the options from the parent if they
    # are nil on the cloud
    default_options(
      :minimum_instances        => 2,     # minimum_instances default
      :maximum_instances        => 5,     # maximum_instances default
      :minimum_runtime          => 3600,  # minimum_instances default: 1 hour
      :contract_when            => nil,
      :expand_when              => nil,
      :cloud_provider_name      => :ec2,
      :dependency_resolver_name => nil
    )
    
    # Define what gets run on the callbacks
    # This is where we can specify what gets called
    # on callbacks
    #   parameters: cld, time
    #   cld - the cloud the callback came from
    #   callback - the callback called (i.e. :after_provision)
    callback_block do |cld, callback|
    end
    
    # Freeze the cloud_name so we can't modify it at all, set the plugin_directory
    # call and run instance_eval on the block and then call the after_create callback
    def initialize(n, o={}, &block)
      @cloud_name = n
      @cloud_name.freeze
      
      # @init_block = block
      @init_opts = compile_opts(o)
      
      @init_block = Proc.new do
        super(n,o,&block)
      end
      
    end
    
    # returns an instance of Keypair
    # You can pass either a filename which will be searched for in ~/.ec2/ and ~/.ssh/
    # Or you can pass a full filepath
    def keypair(n=nil)
      @keypair ||= Keypair.new(n)
    end
    
    # Declare the CloudProvider for a cloud
    #  Create an instance of the cloud provider this cloud is using
    def using(provider_symbol, o={}, &block)
      return @cloud_provider if @cloud_provider
      self.cloud_provider_name = provider_symbol
      cloud_provider(o, &block)
    end
    
    # Cloud provider methods
    def nodes(o={}); delayed_action {cloud_provider.nodes(o)}; end
    def run_instance(o={}); cloud_provider.run_instance(o);end
    def terminate_instance!(o={}); cloud_provider.terminate_instance!(o);end
    def describe_instances(o={}); cloud_provider.describe_instances(o);end
    def describe_instance(o={}); cloud_provider.describe_instance(o);end
    
    # Terminate all instances in the cloud
    def terminate!
      nodes.collect{|n| n.terminate! }
    end
    
    # The actual cloud_provider instance
    def cloud_provider(opts={}, &block)
      return @cloud_provider if @cloud_provider
      klass_name = "CloudProviders::#{cloud_provider_name}".classify
      if provider_klass = CloudProviders.all.detect {|k| k.to_s == klass_name }
        opts.merge!(:cloud => self, :keypair_name => self.keypair.basename)
        @cloud_provider = provider_klass.new(dsl_options.merge(opts), &block)
      else
        raise PoolParty::PoolPartyError.create("UnknownCloudProviderError", "Unknown cloud_provider: #{cloud_provider_name}")
      end
      @cloud_provider
    end
    
    # 1.) Launches a new instance,
    # 2.) Waits for the instance to get an ip address
    # 3.) Waits for port 22 to be open
    # 4.) Calls call_after_launch_instance callbacks
    # 5.) Executes passed &block, if any
    # 6.) Returns the new instance object
    def expand(opts={}, &block)
      timeout = opts.delete(:timeout) || 300

      instance = cloud_provider.run_instance(opts)
      instance.cloud = self
      @instance = instance
      callback :before_launch_instance
      #wait for an ip and then wait for ssh port, then configure instance
      if instance.wait_for_public_ip(timeout) && instance.wait_for_port(22, :timeout=>timeout)
        callback :after_launch_instance
        instance.callback :before_bootstrap
        instance.bootstrap!
        instance.callback :after_bootstrap
        instance.callback :before_configure
        instance.configure!
        instance.callback :after_configure
        block.call(instance) if block
        instance
      else
         raise StandardError.new("Instance port 22 not available")
      end
      instance.refresh!
      instance
    end
    
    # Contract the cloud
    def contract!(hsh={})
      inst=nodes(hsh).last
      inst.callback :before_terminate
      inst.terminate!
      inst.callback :after_terminate
      inst
    end
    
    # convenience method to loop thru all the nodes and configure them
    def configure!(opts={}, threaded=true)
      nodes.collect{|n| n.configure!}
    end
    
    # Run command/s on all nodes in the cloud.
    # Returns a hash of instance_id=>result pairs
    def run(commands, opts={})
      results = {}
      threads = nodes.collect do |n|
         Thread.new{ results[n.instance_id] = n.run(commands, opts)  }
      end
      threads.each{ |aThread|  aThread.join }
      results
      # Serial implementation #
      # nodes.inject({})do |results, n|
      #   results[n.instance_id] = n.run(commands, opts)
      #   results
      # end
    end
    
    # Temporary path
    # Starts at the global default tmp path and appends the pool name
    # and the cloud name
    def tmp_path
      Default.tmp_path / pool.name / name
    end
    
    # The pool this cloud belongs to
    def pool
      parent
    end
    
    # compile
    
    # Resolve with the dependency resolver
    def resolve_with(a)
      if DependencyResolvers.const_defined?(a.classify)        
        dependency_resolver DependencyResolvers.module_eval("#{a.classify}")
      else
        raise PoolParty::PoolPartyError.create("DependencyResolverError", "Undefined dependency resolver: #{a}. Please specify one of the following: #{DependencyResolvers.all.join(", ")}")
      end
    end
    
    # Set the dependency resolver
    def dependency_resolver(sym=nil)
      @dependency_resolver ||= case sym
      when :chef, nil
        dsl_options[:dependency_resolver_name] = :chef
        DependencyResolvers::Chef
      end
    end
    
    # Take the cloud's resources and compile them down using 
    # the defined (or the default dependency_resolver, chef)
    def compile(caller=nil)
      FileUtils.mkdir_p tmp_path unless File.directory?(tmp_path)
      ddputs("Compiling cloud #{self.name} to #{tmp_path/"etc"/"#{dependency_resolver_name}"}")
      dependency_resolver.compile_to(ordered_resources, tmp_path/"etc"/"#{dependency_resolver_name}", caller)
    end
    
    # Get the os of the first node, we'll assume they are
    # all homogenous
    def os
      nodes.size > 0 ? nodes.first.os : dsl_options[:os]
    end
    alias :platform :os
    
    def public_ip
      nodes.first.public_ip
    end
    
    ##### Internal methods #####
    # Methods that only the cloud itself will use
    # and thus are private
    
    # Form the cloud
    # Run the init block with the init_opts
    # on the cloud
    # This is run after the cloud.rb file has been consumed
    def form_clouds
      run_with_callbacks(@init_opts, &@init_block)
      loaded!
    end
    
    def after_all_loaded
      run_after_loaded do |b|
        run_in_context(&b)
      end
    end
    
  end
end