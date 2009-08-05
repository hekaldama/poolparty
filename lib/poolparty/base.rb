=begin rdoc
  Base class for all PoolParty objects
=end
module PoolParty
  
  # Global storage for the current context_stack
  def context_stack
    $context_stack ||= []
  end
  
  class Base
    attr_reader :init_opts, :base_name
    
    include Parenting, Dslify
    include SearchablePaths
    include Callbacks
    include Delayed
    
    default_options Default.default_options
    
    def initialize(opts={}, extra_opts={}, &block)
      @init_block = block
      @init_opts = compile_opts(opts, extra_opts)
      
      run_with_callbacks(init_opts, &block)
      @base_name = self.name
    end
    
    # Overloading the parent run_in_context
    # First, push ourself to the stack
    # then set all the variables given with the init
    # and then eval the block and pop ourselves off the stack
    # During runtime, the stack looks like
    # 
    # - self
    #   - instance_eval block
    # - stack
    def run_in_context(o={}, &block)
      proc = Proc.new do
        set_vars_from_options(o)
        instance_eval &block if block
      end
      super(&proc)
    end
    
    # Run the block in the context of self
    # and call the block after calling 
    #   before_load
    # and afterwards calling
    #   after_loaded
    def run_with_callbacks(o, &block)
      run_in_context(o) do
        callback :before_load, o, &block
        instance_eval &block if block
        callback :after_loaded, o, &block
      end
    end
    
    # Base callbacks for run_with_callbacks
    # before_load
    # This is called before the block is yielded
    def before_load(o={}, &block)      
    end
    
    # after_loaded
    # This is run immediately after the block given
    # on init is yielded
    def after_loaded(o={}, &block)
    end
    
    # Try to extract the name from the options
    # Either the first parameter is a string or it is a hash
    # if it is a hash, just merge the two hashes
    # If it is a string, then merge it in as the name of the
    # instance on the hash
    def compile_opts(o={}, extra={})
      case o
      when Symbol, String
        extra.merge(:name => o.to_s)
      when NilClass
        extra
      else
        extra.merge(o)
      end
    end
    
    # Validation checks
    # if all of the validations pass, the object is considered valid
    # the validations are responsible for raising a PoolPartyError (StandardError)
    def valid?
      validations.each {|validation| self.send(validation.to_sym) }
    end
    
    # The array of validations that the instances must pass
    # to be considered valid. These must be methods available on the instance
    def validations
      []
    end
    
    # Ordered resources
    # are the resources associated with this base
    
    # Resources are all the resources attached to this resource
    def resources
      @resources ||= []
    end
    
    # Order the resources_graph using a top-sort iterator
    def ordered_resources
      resources_graph.topsort_iterator.to_a
    end
    
    # Get a resource, based on it's type
    # Used for INTERNAL use
    def get_resource(ty, nm)
      o = self.send "#{ty}s".to_sym
      o.detect {|r| r.name == nm }
    end
    
    def to_s
      "#{self.respond_to?(:has_method_name) ? self.has_method_name : self.class.to_s.top_level_class}:#{name}"
    end
    
    # Create a directed adjacency graph of each of the dependencies
    def resources_graph(force=false)
      return @resources_graph if @resources_graph && !force
      result = RGL::DirectedAdjacencyGraph.new
      # res = resources.TODOODOODODOD
      
      resources.each do |res|
        result.add_vertex(res)
        add_resource_to_resources_graph(res, nil, result)
      end

      @resources_graph = result
    end
    
    # First, add this resource to the dependency tree
    def add_resource_to_resources_graph(resource, on, rgraph)
      
      # Add the dependencies if they are not already on the graph
      resource.dependencies.each do |dep_type, deps|
        deps.each do |dep_name|
          dep = get_resource(dep_type, dep_name)
          add_resource_to_resources_graph(dep, resource, rgraph)
        end
      end # end resource filtering
      
      # Add this resource to the graph
      rgraph.add_edge(resource, on) unless on.nil? || rgraph.has_edge?(resource, on)
      
      # Add all the resources this resource has to the graph
      resource.resources.each do |r|
         add_resource_to_resources_graph(r, resource, rgraph) if !resource.resources.empty?
      end
      
      resource
    end
    
    # All the dependencies that are required by this resource
    # This is a hash of the dependencies required by the resource
    def dependencies
      @dependencies ||= {}
    end
    
    def all_resources
      resources.map do |res|
        [res, res.all_resources ]
      end.flatten
    end    

    # Write the cloud dependency graph
    def output_resources_graph(fmt='png', dotfile="graph",params={})
      src = dotfile + ".dot"
      dot = dotfile + "." + fmt

      File.open(src, 'w') do |f|
        f << resources_graph.to_dot_graph({
          'bgcolor' => 'white',
          'pad'     => '0.5',
          'rankdir' => 'LR',
          'ordering' => 'out',
          'overlap' => 'false',
          'node_params' => {
            'color' => "#000000"
          }
        }.merge(params)).to_s << "\n"
      end

      system( "dot -T#{fmt} #{src} -o #{dot}" )
      dot
    end
    
    # The clouds.rb file
    def clouds_dot_rb_file; self.class.clouds_dot_rb_file; end
    def self.clouds_dot_rb_file
      Pool.clouds_dot_rb_file
    end
    
    # If the method is missing from ourself, check the Default
    # class for the corresponding method.
    # If the Default class has the method, inquire from the Default
    # class, otherwise, call super
    def method_missing(m,*a,&block)
      if Default.respond_to?(m)
        Default.send(m,*a,&block)
      else
        super
      end
    end
    
    def has_searchable_paths(opts={})
      default_searchable_paths = [
        Dir.pwd,
        PoolParty::Default.poolparty_home_path,
        PoolParty::Default.poolparty_src_path,
        PoolParty::Default.poolparty_src_path/:lib/:poolparty,
        PoolParty::Default.base_config_directory,
        PoolParty::Default.remote_storage_path
      ]      
      super(opts.merge(:paths => (opts.delete(:paths) || default_searchable_paths)))
    end
    
  end
end