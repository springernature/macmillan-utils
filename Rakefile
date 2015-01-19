require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
task test: :spec

YARD::Rake::YardocTask.new do |task|
  task.files = ['lib/**/*.rb']
end
