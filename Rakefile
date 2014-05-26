$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'rspec/core/rake_task'

require 'easytag/version'

task :default => [:spec]
task :test => :spec

task :spec do
  RSpec::Core::RakeTask.new do |task|
    task.verbose = false
    task.rspec_opts = '--color'
  end
end

task :build do
  system 'gem build easytag.gemspec'
end

task :release => :build do
  system "gem push easytag-#{EasyTag::VERSION}.gem"
end

task :clean do
  system 'rm -f *.gem'
end
