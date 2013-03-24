$:.unshift File.expand_path('../lib/', __FILE__)

require 'snooper/version'

desc "Default task"
task :default => [:build]

desc "Build the gem"
task :build => [:docs] do
  puts "Building gem"
  `gem build snooper.gemspec`
end

desc "Build the manpages"
task :docs do
  puts "Compiling manpages"
  `ronn --style=dark,toc man/*.ronn`
end