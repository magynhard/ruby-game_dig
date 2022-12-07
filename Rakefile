require "bundler/gem_tasks"
require "rspec/core/rake_task"

require "json"
require "colorize"

#
# run default task to see tasks to build and publish gem
#
task :default do
  system 'rake --tasks'
end

desc "start cli to play with the environment"
task :cli do |t|
  puts
  puts %{ Starting CLI ... }.red
  puts
  require_relative 'cli/pry'
end

RSpec::Core::RakeTask.new(:spec)