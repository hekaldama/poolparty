require File.dirname(__FILE__) + '/../spec_helper'

describe "String" do
  before(:each) do
    @string = "string"
    @string.stub!(:bucket_objects).and_return([])
  end
  # Dumb test
  it "should be able to call bucket_objects on itself" do
    @string.should_receive(:bucket_objects)
    @string.bucket_objects
  end
  describe "with config replacements" do
    it "should replace those syms in the string" do
      ("new :port" ^ {:port => 100}).should == "new 100"
    end
    it "should be able to detect vars" do
      @string=<<-EOC
listen web_proxy 127.0.0.1::client_port
\tserver web1 127.0.0.1::port weight 1 minconn 3 maxconn 6 check inter 30000
      EOC
      (@string ^ {:client_port => 3000, :port => 3001}).should ==<<-EOO
listen web_proxy 127.0.0.1:3000
\tserver web1 127.0.0.1:3001 weight 1 minconn 3 maxconn 6 check inter 30000
      EOO
    end
  end
  describe "collect_each_line_with_index" do
    before(:each) do
      @longer_string = "hot\npotato\nthrough\nthe\nwindow"
    end
    it "should run the same code on the entire string" do
      @longer_string.collect_each_line_with_index do |str, index|
        "#{index}_#{str}"
      end.should == ["0_hot", "1_potato", "2_through", "3_the", "4_window"]
    end
  end
  describe "String" do
    before(:each) do
      @str =<<-EOS
        echo 'hi'
        puts 'hi'
      EOS
    end
    it "should be able to convert a big string with \n to a runnable string" do
      @str.runnable.should == "echo 'hi' &&         puts 'hi'"
    end
  end
  describe "Constantize" do
    before(:each) do
      @str = "prok"
    end
    it "should be able to turn itself into constant" do
      @str.class_constant.should == ProkClas
    end
    it "should turn itself into a class constant" do
      @str.class_constant.class.should == Class
    end
    it "should not recreate the constant if it exists" do
      Class.should_receive(:new).once.and_return Class.new
      @str.class_constant
      @str.class_constant
    end
    it "should set the parent class when sent with the superclass" do
      "stirer".class_constant(String).ancestors[1].should == String
    end
    it "should be able to create a module into a constant" do
      @str.module_constant.should == ProkModule
    end
    it "should turn itself into a class constant" do
      @str.module_constant.class.should == Module
    end
    describe "with a block" do
      before(:each) do
        @str = "nack"
      end
      it "should be able to yield a block on the module and set methods" do
        "tippy".module_constant do
          def tippy
            puts "etc"
          end
        end
        Class.new.extend("tippy".module_constant).methods.include?("tippy").should == true
      end
    end
  end
end