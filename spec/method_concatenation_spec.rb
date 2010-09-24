require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Plugin1 < SurveillanceAuthority::Sanction
  def plugin1_method(object)
  end
end

class Plugin2 < SurveillanceAuthority::Sanction
  def plugin2_method(object)
  end
end

class Plugin3 < SurveillanceAuthority::Sanction
  def plugin3_method(object)
  end
end

describe "Concatenate blocks into one method" do
  it "should make plugin methods in available in the observer blocks" do
    SurveillanceAuthority.observe do 
      after "ConcatenateTest1#create" do |object|
        plugin1_method object
      end
      after "ConcatenateTest1#create" do |object|
        plugin2_method object
      end
      after "ConcatenateTest1#create" do |object|
        plugin3_method object
      end
    end

    Plugin1.instance.should_receive(:plugin1_method).with("They set us up the bomb!")
    Plugin2.instance.should_receive(:plugin2_method).with("They set us up the bomb!")
    Plugin3.instance.should_receive(:plugin3_method).with("They set us up the bomb!")
    SurveillanceObserverForConcatenateTest1.new.after_create("They set us up the bomb!")
  end

end
