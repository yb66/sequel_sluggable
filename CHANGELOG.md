# Changes #

## 2nd of December 2017 ##

* Updated layout of library to conform to Sequel v5 plugin standard.
* Removed subclassing feature, not sure what it was for.
* Changed spec to use given/when syntax and generally update and sandbox tests from each other.
* Added yard doc and updated files to be markdown or txt to cut down on yard complaints.
* Added simplecov, 100% nice!
* Simplified some the logic a bit, I don't mind a few extra lines.
* A bit of freezing (of the hash) and defaulting for the getter.

----


## 0.0.6, 2010-05-02
* Make Rakefile and gemspec sane
* Fix the strucutre of the gem
* Update RSpecHleper to work with the latest code.
  You now need to use require 'sequel_sluggable/rspec_helper' and the name of
	the helper module changed to Sequel::Plugins::Sluggable::RSpecHelper.

== 0.0.5, 2010-03-04
* Allow to generate slug before the before_save + doc update
* Slug is generated only before_create and when it's not set manually
* Slug is not by default regenerated before_update
* New :frozen option (true by default). When true slug is not regenerated
  during update. When :frozen => false slug is regenerated during update.
