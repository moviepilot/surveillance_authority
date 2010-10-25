surveillance_authority
======================

Introduction
------------

This gem provides a dsl to easily write observers in one or more centralized files.

Installation
------------

Install _surveillance_authority_ by adding 

  `gem 'surveillance_authority'` 

to your Gemfile or install it using 

  `gem install surveillance_authority`

Integration into your project
-----------------------------

In 

  `config/initializers`

create one or more ruby files in which you can define your surveillance rules. For example:

<code>
     SurveillanceAuthority.observe do
       # Do something after a new movie was created
       after "Movie#create" do |movie|
          # ... do stuff
       end
     
       
       # Do something before a User gets updated
       before "User#update" do |user|
         # ... do stuff
       end
     end
</code>

Uhm ...so what?
---------------

_surveillance_authority_ is meant to be used together with some plugins. One of those is varnish_sweeper, which invalidates certain routes.

Writing plugins for _surveillance_authority_
------------------------------------------

### Making methods available to _surveillance_authority_

In order to write a plugin for _surveillance_authority_, simply create a class that inherits from

  `SurveillanceAuthority::Sanctions`

all public methods of that class will be available in the blocks. E.g.

<code>

     class VarnishSweeper < SurveillanceAuthority::Sanctions
       def sweep(url, options = {})
         options.reverse_merge(
           :method => :invalidate
         }
         
         options[:method] == :purge ? purge_url(url) : invalidate(url)
       end
     
       private
       def purge_url(url)
         ...
       end
     
       def invalidate(url)
         ...
       end
     end

</code>

will make the sweep method available:

<code>

     SurveillanceAuthority.observe do
       # Do something after a new movie was updated
       after "Movie#update" do |movie|
          sweep movie_path(movie), :method => :invalidate
       end
     end

</code>

### Configuration for plugins

Configuring plugins should be made with the central config method provided by _surveillance_authority_. If we again use a plugin called `VarnishSweeper`, configuring this plugin should happen like this:

`SurveillanceAuthority.config(VarnishSweeper, <hash with options>)`

Withing your plugin, you will be able to access your options simply by calling `config`.

#### Example: `VarnishSweep` needs to be configured with a base url to varnish


     class VarnishSweeper < SurveillanceAuthority::Sanctions
       default_config  {:method => :purge}

       def sweep(url, options = {})
         options.reverse_merge(
           :method => :invalidate
         }
         
         options[:method] == :purge ? purge_url(url) : invalidate(url)
       end
     
       private
       def varnish_base_url
         config[:base_url]
       end

       def purge_url(url)
         ...
       end
     
       def invalidate(url)
         ...
       end
     end


In the project using this plugin:


      SurveillanceAuthority.config(VarnishSweeper, :base_url => "http://varnish.example.com")
      ...

If you want to access the config of other plugins, use:

      `SurveillanceAuthority.config_for(<plugin>)`

Note that you can easily provide default options for your plugin by calling `default_config` in your plugin file:

     default_config {:method => :purge}

which comes in handy if some config options of your plugin do not need to be set by the users.


Copyright
---------

Copyright (c) 2010 Daniel Bornkessel. See LICENSE for details.
