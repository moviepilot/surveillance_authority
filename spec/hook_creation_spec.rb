require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BasicHookTests: hook creation" do
  it "should create sweeper class" do
    SurveillanceAuthority.observe do
      after "BasicHookTests1#create" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end
    end

    Object.const_defined?(:SurveillanceObserverForBasicHookTests1).should be_true
  end


  it "should add the observe method with the respective class" do
    Object.should_receive(:const_defined?).with(:SurveillanceObserverForBasicHookTests2)
    ActionController::Caching::Sweeper.should_receive(:observe)

    SurveillanceAuthority.observe do
      after "BasicHookTests2#create" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end
    end

  end

  it "should create an after create hook" do
    SurveillanceAuthority.observe do
      after "BasicHookTests3#create" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end
    end

    SurveillanceObserverForBasicHookTests3.instance_methods(false).include?(:after_create).should be_true
  end

  it "should be able to create create multiple hooks on one class" do 
    SurveillanceAuthority.observe do
      after "BasicHookTests4#create" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end

      before "BasicHookTests4#save" do
        # ... me neither
      end

    end


    SurveillanceObserverForBasicHookTests4.instance_methods(false).include?(:after_create).should be_true
    SurveillanceObserverForBasicHookTests4.instance_methods(false).include?(:before_save).should be_true

  end

  it "should throw an exception when invalid hoods are getting defined" do
    lambda {
      SurveillanceAuthority.observe do
      after "BasicHookTests5#nonexistanthook" do
        # ...
      end
      end
    }.should raise_exception

  end
end

describe "MultipleHooksSameModelTests: multiple hooks with one specification" do
  it "should create sweeper class" do
    SurveillanceAuthority.observe do
      after "MultipleHooksSameModelTests1#create", "MultipleHooksSameModelTests1#save" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end
    end

    Object.const_defined?(:SurveillanceObserverForMultipleHooksSameModelTests1).should be_true
  end


  it "should add the observe method with the respective class" do
    ActionController::Caching::Sweeper.should_receive(:observe).once

    SurveillanceAuthority.observe do
      after "MultipleHooksSameModelTests2#create", "MultipleHooksSameModelTests2#save" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end
    end

  end

  it "should create an after create hook" do
    SurveillanceAuthority.observe do
      after "MultipleHooksSameModelTests3#create", "MultipleHooksSameModelTests3#save" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end
    end

    SurveillanceObserverForMultipleHooksSameModelTests3.instance_methods(false).include?(:after_create).should be_true
    SurveillanceObserverForMultipleHooksSameModelTests3.instance_methods(false).include?(:after_save).should be_true
  end

  it "should be able to create create multiple hooks on one class" do 
    SurveillanceAuthority.observe do
      after "MultipleHooksSameModelTests4#create", "MultipleHooksSameModelTests4#save" do
        # hahaha ... I don't do nothing -- YOU FOOL
      end

      before "MultipleHooksSameModelTests4#create", "MultipleHooksSameModelTests4#save" do
        # ... me neither
      end

    end


    SurveillanceObserverForMultipleHooksSameModelTests4.instance_methods(false).include?(:after_create).should be_true
    SurveillanceObserverForMultipleHooksSameModelTests4.instance_methods(false).include?(:after_save).should be_true
    SurveillanceObserverForMultipleHooksSameModelTests4.instance_methods(false).include?(:before_create).should be_true
    SurveillanceObserverForMultipleHooksSameModelTests4.instance_methods(false).include?(:before_save).should be_true

  end
end



class Notify < SurveillanceAuthority::Sanction
  def notify(message)
    puts message
  end
end

class CachingSweeper < SurveillanceAuthority::Sanction
  def sweep(url, options)
    # do nothing
  end
end

