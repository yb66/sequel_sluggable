# Sequel Sluggable #

## Install ##

Install via rubygems:

    gem install sequel_sluggable

Via Bundler's Gemfile:

    gem "sequel_sluggable"

## Usage ##

This plug-in provide functionality to allow Sequel::Model to have a slug.
Slug is created in ether the *before_create* or *before_update* hooks.

Require the plugin:

    require "sequel/plugins/sluggable.rb"

Then add the plug-in to your model:

    class MyModel < Sequel::Model
      plugin :sluggable, :source => :name
    end

The following options are available:

- *frozen*: Should slug be frozen once it's generated? Default true.
- *sluggator*: Proc or Symbol to call to create slug.
- *source*: Column which value will be used to generate slug.
- *target*: Column where slug will be written, defaults to *:slug*.

Options *frozen*, *sluggator* and *target* are optional.

**Options are inherited when you use inheritance for your models**. However
you can only set options via plugin method.

You can access options for current model via reader `Model#sluggable_options`
which is readonly.

## When is slug generated? ##

By default slug is generated *ONLY* when model is created and you 
**didn't set it**. **When you update model slug 
is not updated by default** but if you set `:frozen => false`, 
slug will be regenerated on update. Some examples:

    class Item < Sequel::Model
      plugin :source => :name
      # ...
    end

    Item.create(:name => 'X')      # Generates slug
  
    i = Item.new(:name => 'X')
    i.slug = 'X Y'                 # Sets slug manualy
    i.save                         # Slug is not regenerated but the set slug is used
    i.slug                         # => x-y
    i.update(:name => 'Y')         # Won't regenerate slug, because slug is frozen by default
    i.slug                         # => x-y
  
But:
  
    class Item < Sequel::Model
      plugin :source => :name, :frozen => false
      ...
    end
  
    i = Item.create(:name => 'X')  # Generates slug
    i.update(:name => 'Y')         # Will regenerate slug, because slug is now not frozen
    i.slug                         # => y

## Access/Set slug ##

You can access slug via your normal Sequel reader. By default that will be `Model#slug` method. If you customize this via :target option than you have `Model#:target`.

Writer for the slug is generated depending on your :target option. Default will be `Model#slug=` otherwise `Model#:target=`. You can call setter to set the slug before the creating or updating model.

## Algorithm customization ##

You can customize algorithm of the slug creation in several places.
If you provide _:sluggator_ Proc or Symbol the sluggator will be called:

    class MyModel < Sequel::Model
      plugin :sluggable,
             :source    => :name,
             :sluggator => Proc.new {|value, model| do_something }
    end

OR

    class MyModel < Sequel::Model
      plugin :sluggable, :source => :name, :sluggator => :my_to_slug
    end

If you don't provide `:sluggator` then the library will try to use
`Model#to_slug(value)`. So if you have in your model this method
it will be used:

    class MyModel < Sequel::Model
      plugin :sluggable, :source => :name

      def to_slug(value)
        value.upcase
      end
    end

If you don't define `Model#to_slug` or `:sluggator` sequel_sluggable
will use it's own default implementation which does following:
 
    'value_of_the_source_column'.chomp.downcase.gsub(/[^a-z0-9]+/,'-')

## Note on Patches/Pull Requests ##
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Contributors ##

* Pavel Kunc
* Jakub "Botanicus" Stastny

## Copyright ##

Copyright (c) 2009 Pavel Kunc. See LICENSE for details.
