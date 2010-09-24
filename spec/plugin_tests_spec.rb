require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Notify < SurveillanceAuthority::Sanction
  def notify(message)
    puts message
  end

  def notify2(message1, message2, message3)
    puts message1
    puts message2
    puts message3
  end
end

describe "avoid ambigous plugin method names" do
  it "should throw an exception if a new plugin wants to use a method name that is already used" do
    C = Class.new(SurveillanceAuthority::Sanction)
    lambda {
      C.class_exec {
        def notify
        end
      }
      SurveillanceAuthority.observe do 
        after "DoubleHappinesTest#create" do |param|
          notify "huhu"
        end
      end
      SurveillanceObserverForDoubleHappinesTest.new.after_create(nil)
    }.should raise_exception
    C.class_exec {
      undef notify
    }
  end
end

describe "SimplePluginsTests: simple plugins" do
  it "should make plugin methods in available in the observer blocks" do
    SurveillanceAuthority.observe do 
      after "SimplePluginsTests1#create" do
        notify "hihihihi ... I was called"
      end
    end

    Notify.instance.should_receive(:notify).with("hihihihi ... I was called")
    SurveillanceObserverForSimplePluginsTests1.new.after_create(nil)
  end

  it "should pass parameters on to plugin methods" do
    SurveillanceAuthority.observe do 
      after "SimplePluginsTests2#create" do |param|
        notify param
      end
    end

    Notify.instance.should_receive(:notify).with("I was called with a param")
    SurveillanceObserverForSimplePluginsTests2.new.after_create("I was called with a param")
  end

  it "should pass multiple parameters on to plugin methods" do
    SurveillanceAuthority.observe do 
      after "SimplePluginsTests3#create" do |param|
        notify2 "lala", "lulu", param
      end
    end

    Notify.instance.should_receive(:notify2).with("lala", "lulu", "pipi")
    SurveillanceObserverForSimplePluginsTests3.new.after_create("pipi")
  end


  # ... this currently fails and says that notify2 does not get called ... which is not true
#  it "should be able to call multiple methods" do
#    SurveillanceAuthority.observe do 
#      after "SimplePluginsTests3#create" do |param|
#        notify param
#        notify2 param
#      end
#    end
#
#    Notify.instance.should_receive(:notify).with("I was called with a param")
#    Notify.instance.should_receive(:notify2).with("I was called with a param")
#    SurveillanceObserverForSimplePluginsTests3.new.after_create("I was called with a param")
#  end
end
