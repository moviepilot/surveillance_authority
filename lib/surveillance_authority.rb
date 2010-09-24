require 'singleton'


class SurveillanceAuthority

  class Sanction
    VALID_HOOK_METHODS = [:validation, :validation_on_create, :save, :create]
    include Singleton
    @@plugins = []

    # register plugins (== SurveillanceAuthority::Sanction Sub-Classes) automatically when they get defined
    def self.inherited(c)
      c.class_eval do
        include Singleton
      end

      @@plugins << c
    end

    # build a hash containing all available plugin methods
    def plugins_methods
      # caching wiht @plugins_methods ||= ... makes problems :/
      @plugins_methods = @@plugins.inject({}) do |hash, plugin_class|
        plugin_class.instance_methods(false).each do |method_name|
          raise "plugin method name clash ... \"#{method_name}\" is defined in \"#{plugin_class.name}\" and \"#{hash[method_name.to_sym].owner.name}\"!" if hash[method_name.to_sym]
          hash[method_name.to_sym] = plugin_class.instance.method( method_name )
        end
        hash
      end
    end

    def method_missing( method_name, *args )
      @plugins_methods ||= {}

      # this is a weird caching optimization ... if you change this, make sure all tests run when called with rake
      if @plugins_methods[method_name.to_sym] || plugins_methods[method_name.to_sym]
        plugins_methods[method_name.to_sym].call( *args )
      else
        raise "no method called #{method_name}"
      end
    end



    [:after, :before].each do |hook|
      define_method hook do |*observed_methods, &block|
        observed_methods.each do |observed_method|
          model, method_name = observed_method.split('#')
          observer_name = :"SurveillanceObserverFor#{model}"
          observer_method_name = :"#{hook}_#{method_name}"


          raise "there is no observer callback called \"#{hook}_#{method_name}\"" unless VALID_HOOK_METHODS.include?(method_name.to_sym) 

          # define sweeper class if it is not defined yet
          unless Object.const_defined?( observer_name )
            c = Object.const_set( observer_name, Class.new(ActionController::Caching::Sweeper) )
            c.class_exec do
              observe model.downcase.to_sym
            end
          end  
         
          observer_class = Object.const_get( observer_name )

          # concat current method implementation with the current block if the method is already defined
          if observer_class.instance_methods(false).include?( observer_method_name )

            # current method implementation
            current_method_implementation = observer_class.instance_method( observer_method_name )

            # concatenate the new block and the old implementation
            observer_class.send :define_method, observer_method_name, lambda{ |param| 
              block.call(param)
              old_implementation = current_method_implementation.bind(self)
              old_implementation.call(param)
            }
          else

            # otherwise simply define method
            observer_class.send :define_method, observer_method_name, lambda{|param| block.call(param) }
          end

        end
      end
    end
  end

  def self.observe(&block)
    SurveillanceAuthority::Sanction.instance.instance_eval(&block)
  end
end
