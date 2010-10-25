require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Notify < SurveillanceAuthority::Sanction
  default_config(:default_config => "I am a default option")

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

    Notify.instance.config[:option1].should == true
  end

  it "configuration should be accessible within the plugin" do
    SurveillanceAuthority.config(Notify, :option2 => true)

    Notify.instance.my_config[:option2].should == true
  end

  it "should be possible to configure plugins with the SurveillanceAuthority.config method and retrieve this config with SurveillanceAuthority::config_for" do
    SurveillanceAuthority.config(Notify, :option3 => true)

    SurveillanceAuthority.config_for(Notify)[:option3].should == true
  end

  it "should be possible for plugins to have default options" do
    Notify.instance.config[:default_config].should == "I am a default option"
  end

  it "should not delete default config if user sets some config options" do
    SurveillanceAuthority.config(Notify, :what => "ever")
    Notify.instance.config[:default_config].should == "I am a default option"
  end

  # ALWAYS LAST:
  it "should be possible for plugins to overwrite default options" do
    SurveillanceAuthority.config(Notify, :default_config => "I am not a default option")
    Notify.instance.config[:default_config].should == "I am not a default option"
  end

end
