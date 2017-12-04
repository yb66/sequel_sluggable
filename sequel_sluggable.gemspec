$:.push File.expand_path("../lib", __FILE__)
require "sequel/plugins/sluggable/version"

Gem::Specification.new do |s|
  s.name     = 'sequel_sluggable'
  s.version  = Sequel::Plugins::Sluggable::VERSION
  s.authors  = ['Pavel Kunc']
  s.email = 'pavel.kunc@gmail.com'
  s.homepage = 'http://github.com/pk/sequel_sluggable'
  s.summary = 'Sequel plugin which provides Slug functionality for model.'
  s.description = s.summary
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency 'sequel', "~>5.0"

  s.require_paths = ["lib"]
end
