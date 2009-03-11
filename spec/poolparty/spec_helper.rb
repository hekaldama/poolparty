$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'poolparty'

%w(spec).each do |library|
  begin
    require library
  rescue
    STDERR.puts "== Cannot run test without #{library}"
  end
end

# Dir["#{File.dirname(__FILE__)}/helpers/**"].each {|a| require a}

ENV["POOL_SPEC"] = nil

include PoolParty
extend PoolParty

def debugging
  false
end
def are_too_many_instances_running?  
end
def are_any_nodes_exceeding_minimum_runtime?  
end
def are_too_few_instances_running?
end

class TestClass < PoolParty::Cloud::Cloud
  include CloudResourcer
  attr_accessor :parent
  def initialize(&block)
    super :test_cloud, nil, &block
  end
  def keypair
    "fake_keypair"
  end
end

def setup
  PoolParty::Messenger.stub!(:messenger_send!).and_return false
end

def setup_cl
  require 'poolpartycl'
end

def stub_option_load
    @str=<<-EOS
:access_key:    
  3.14159
:secret_access_key:
  "pi"
    EOS
    @sio = StringIO.new
    StringIO.stub!(:new).and_return @sio
    Base.stub!(:open).with("http://169.254.169.254/latest/user-data").and_return @sio
    @sio.stub!(:read).and_return @str
    Base.reset!
end

def wait_launch(time=5)
  pid = fork {yield}
  wait time
  Process.kill("INT", pid)
  Process.wait(pid, 0)
end
def reset_all!
  $cloud = nil
end
def read_file(path)
  require "open-uri"
  open(path).read
end
def sample_instances_list
  @sample_instances_lister ||= [
    {:ip => "127.0.0.1", :name => "master", :launching_time => 2.days.ago}, 
    {:ip => "127.0.0.2", :name => "node1", :launching_time => 2.days.ago}
  ]
end

def sample_instances
  sample_instances_list.map {|h| PoolParty::Remote::RemoteInstance.new(h) }
end
def stub_list_from_local_for(o)
  @list =<<-EOS
  master 192.168.0.1
  node1 192.168.0.2
  EOS
  @file = "filename"
  @file.stub!(:read).and_return @list
  o.stub!(:open).and_return @file

  @ris = @list.split(/\n/).map {|line| PoolParty::Remote::RemoteInstance.new(line) }
end
def stub_remoter_for(o)
  o.stub!(:ec2).and_return EC2::Base.new( :access_key_id => "not a key",  :secret_access_key => "even more not a key")
  o.stub!(:list_of_running_instances).and_return sample_instances
end
def stub_list_from_remote_for(o, launch_stub=true)
  stub_remoter_for(o)
  o.stub!(:access_key).and_return "NOT A KEY"
  o.stub!(:secret_access_key).and_return "NOT A SECRET"
  # o.stub!(:list_from_remote).and_return ris
  # o.stub!(:remote_instances_list).once.and_return ris
  # o.stub!(:master).and_return @ris[0]
  o.stub!(:launch_new_instance!).and_return sample_instances.first if launch_stub  
  stub_list_of_instances_for(o)
  stub_remoting_methods_for(o)
end
def stub_remoting_methods_for(o)
  @key = Key.new
  o.stub!(:keypair).and_return @key
  o.stub!(:keypair_path).and_return "~/.ec2/fake_keypair"
  o.stub!(:other_clouds).and_return []
  o.stub!(:expand_when).and_return "cpu > 10"
  o.stub!(:copy_file_to_storage_directory).and_return true
  o.stub!(:rsync_storage_files_to).and_return true
  o.stub!(:minimum_runnable_options).and_return []
  o.stub!(:build_and_store_new_config_file).and_return true
  o.stub!(:process_clean_reconfigure_for!).and_return true
  o.stub!(:before_install).and_return true
  o.stub!(:process_install).and_return true
  o.stub!(:after_install).and_return true
  o.stub!(:can_contract_cloud?).and_return false
  o.stub!(:can_expand_cloud?).and_return false
end
def stub_list_of_instances_for(o)  
  # o.stub!(:list_of_running_instances).once.and_return running_remote_instances
  o.stub!(:keypair).and_return "fake_keypair"
  o.stub!(:describe_instances).and_return response_list_of_instances
end

def response_list_of_instances(arr=[])
  unless @response_list_of_instances
    @a1 = stub_instance(1); 
    @a1[:name] = "master"
    @a2 = stub_instance(1); @a3 = stub_instance(2, "terminated"); @a4 = stub_instance(3, "pending")
    @b1 = stub_instance(4, "shutting down", "blist"); @c1 = stub_instance(5, "pending", "clist")
    @response_list_of_instances = [@a1, @a2, @a3, @a4, @b1, @c1]
  end
  @response_list_of_instances
end

def running_remote_instances
  response_list_of_instances.select {|a| a[:status] =~ /running/ }
end

def reset_response!
  setup
  @ris = nil
end

def add_stub_instance_to(o, num, status="running")  
  reset_response!  
  response_list_of_instances << stub_instance(num, status)
  sample_instances_list << stub_instance(num, status)
  stub_list_of_instances_for o
  stub_remoter_for(o)
end
def ris
  @ris ||= response_list_of_instances.collect {|h| PoolParty::Remote::RemoteInstance.new(h) }
end
def remove_stub_instance_from(o, num)
  reset_response!
  response_list_of_instances.reject! {|r| r if r[:name] == "node#{num}" }  
  # o.stub!(:remote_instances_list).once.and_return ris
end
def stub_instance(num=1, status="running", keypair="fake_keypair")
  {:name => "node#{num}", :ip => "192.168.0.#{num}", :status => "#{status}", :launching_time => num.minutes.ago.to_s, :keypair => "#{keypair}"}
end
def drop_pending_instances_for(o)
  puts "hi"
  o.list_of_pending_instances.stub!(:size).and_return 0
  1
end

# Stub for messenger_send!
class Object
  def messenger_send!(*args)
    true
  end
end

class Object
  def to_html_list
    str = ''
    str << "<ul>"
    str << self.collect {|k,v| 
      "<li>#{k} => #{(v.instance_of?(Hash) || v.instance_of?(Array)) ? v.to_html_list : v.inspect}</li> "
      }.join(" ")
    str << "</ul>"
  end
end

class Array 
    def to_html_list
         str =''
        str<< "<ul class='array'>"
        str<< self.collect {|v| 
          "<li>#{(v.is_a?(Array) || v.is_a?(Hash)) ? v.to_html_list : v.inspect}</li>"
          }.join(' ')
        str<<"</ul>"
    end
end