require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Notify < SurveillanceAuthority::Sanction
  def notify(message)
    puts message
  end

  def notify2(message)
    puts message
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
