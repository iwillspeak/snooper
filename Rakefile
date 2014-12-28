$:.unshift File.expand_path('../lib/', __FILE__)

require 'rake/testtask'
require 'rake/clean'
require 'snooper/version'

# tests : rake test
desc "Run unit tests"
Rake::TestTask.new do |t|
  t.libs << "test"
end

desc "Default task"
task :default => [:build]

# Build the docs : rake docs
DOC_SRCS = FileList['man/*.ronn']
DOCS = DOC_SRCS.ext("") + DOC_SRCS.ext("html")

DOCS.each { |f| CLEAN << f }
# Rule to convert ronn formatted manpages to compiled ones
rule '.html' => ['.ronn'] do |t|
  `ronn --style=dark,toc --html #{t.source}`
end

# Rule to convert ronn formatted manpages to compiled ones
rule /\.[0-9]$/ => [ proc { |t| t + '.ronn' } ] do |t|
  `ronn --roff #{t.source}`
end

desc "Build the manpages"
task :docs => DOCS

# build gem : rake build
gemfile = "snooper-#{Snooper::VERSION}.gem"
gem_srcs = FileList['lib/**.rb','data/**','bin/**']

desc "Build everything"
task :build => DOCS + [ gemfile ]

desc "Build #{gemfile}"
file gemfile => gem_srcs + [ 'snooper.gemspec' ] do
  sh %{gem build snooper.gemspec}
end

# Clean up : rake clean
Dir.glob("*.gem").each do |f|
  CLOBBER << f
end
