require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)



begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
