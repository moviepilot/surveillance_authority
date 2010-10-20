require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Notify < SurveillanceAuthority::Sanction
  def my_config
    config
  end

  def notify2(message1, message2, message3)
    puts message1
    puts message2
    puts message3
  end
end

describe "plugin configuration" do
  it "should be possible to configure plugins with the SurveillanceAuthority.config method" do
    SurveillanceAuthority.config(Notify, :option1 => true)

    Notify.instance.config.should == {:option1 => true}
  end

  it "configuration should be accessible within the plugin" do
    SurveillanceAuthority.config(Notify, :option2 => true)

    Notify.instance.my_config.should == {:option2 => true}
  end

  it "should be possible to configure plugins with the SurveillanceAuthority.config method and retrieve this config with SurveillanceAuthority::config_for" do
    SurveillanceAuthority.config(Notify, :option3 => true)

    SurveillanceAuthority.config_for(Notify).should == {:option3 => true}
  end
end
