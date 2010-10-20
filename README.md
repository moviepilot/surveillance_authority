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


Copyright
---------

Copyright (c) 2010 Daniel Bornkessel. See LICENSE for details.
