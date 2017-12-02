require 'rspec'
require 'rspec/its'
require 'rspec/given'

if ENV["DEBUG"]
  require 'pry-byebug'
  require 'pry-state'
  binding.pry
end

# code coverage
require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  # for OSX
  add_filter "/vendor.noindex/"
  add_filter "/bin/"
  add_filter "/spec/"
end


# RSpec.configure do |config|
# end
