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
      @plugins_methods ||= @@plugins.inject({}) do |hash, plugin_class|
        plugin_class.instance_methods(false).each do |method_name|
          raise "plugin method name clash ... \"#{method_name}\" is defined in \"#{plugin_class.name}\" and \"#{hash[method_name.to_sym].owner.name}\"!" if hash[method_name.to_sym]
          hash[method_name.to_sym] = plugin_class.instance.method( method_name )
        end
        hash
      end
    end

    def method_missing( method_name, *args )
      if plugins_methods[method_name.to_sym]
        plugins_methods[method_name.to_sym].call( *args )
      else
        raise "no method called #{method_name}"
      end
    end

    def sweeper_class_name(model)
      "Sweeper#{model}"
    end
        
    [:after, :before].each do |hook|
      define_method hook do |observed_method, &block|
        model, method_name = observed_method.split('#')

        raise "there is not observer callback called \"#{hook}_#{method_name}\"" unless VALID_HOOK_METHODS.include?(method_name.to_sym) 

        # define sweeper class if it is not defined yet
        Object.const_set(sweeper_class_name(model), Class.new) unless Object::const_defined?( sweeper_class_name(model) )

        # add the observer method to our class
        Object.send :define_method, "after_#{method_name}", lambda{|param| block.call(param) }
      end
    end
  end

  def self.observe(&block)
    SurveillanceAuthority::Sanction.instance.instance_eval(&block)
  end
end



class Bar < SurveillanceAuthority::Sanction
  def hallo(text)
    puts "hallo called with text: #{text}"
  end
end

class Foo < SurveillanceAuthority::Sanction
  def sweep(url, options)
    puts "sweep(#{url}, #{options.inspect}) called ... and #{iamprivate} as well"
  end

  private

  def iamprivate
    "XXXXXXXXXXXXXXXXXXXX"
  end
end

SurveillanceAuthority.observe do
  after "Movie#create" do |movie|
    hallo movie
    sweep "http://www.heise.de", :method => :delete, :foo => :bar
  end
  puts "... calling generated stuff"
  f = SweeperMovie.new
  f.after_create("Jupiiiii")
end
