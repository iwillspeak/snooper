$:.unshift File.expand_path('../lib/', __FILE__)

require 'rake/testtask'

# tests : rake test
Rake::TestTask.new do |t|
  t.libs << "test"
end

desc "Default task"
task :default => [:build]

# build gem : rake build
desc "Build the gem"
task :build => [:docs] do
  puts "Building gem"
  `gem build snooper.gemspec`
end

# Build the docs : rake docs
desc "Build the manpages"
task :docs do
  puts "Compiling manpages"
  `ronn --style=dark,toc man/*.ronn`
end