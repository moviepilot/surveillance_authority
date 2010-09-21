require 'singleton'

class SurveillanceAuthority
  class SurveillanceAuthority::Sanction
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

    def after( observed_method ) 
      puts "after called with #{observed_method}"
      yield("hust")
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
    puts "sweep(#{url}, #{options.inspect}) called"
  end
end

SurveillanceAuthority.observe do
  hallo "du"
  after "hihiih" do |movie|
    hallo movie
    sweep "http://www.heise.de", :method => :delete, :foo => :bar
  end
end
