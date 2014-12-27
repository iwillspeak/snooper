$:.unshift File.expand_path('../lib/', __FILE__)

require 'snooper/version'
require 'rbconfig'
HOST_OS ||= RbConfig::CONFIG['target_os']

Gem::Specification.new do |s|
  s.name        = 'snooper'
  s.version     = Snooper::VERSION
  s.date        = Date.today
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Spying on Tests"
  s.description = <<ENDESC
Snooper is a lightweight test automation tool, it monitors files and folders
while you work and re-runs your tests when you change something. Snooper doesn't
care what language you're using or what framework you are testing with, it's all
configureable.
ENDESC
  s.license     = 'MIT'
  s.homepage    = 'http://github.com/iwillspeak/snooper'
  s.authors     = ["Will Speak"]
  s.email       = 'will@willspeak.me'
  # Gem contents
  s.files       = Dir.glob("{lib,bin,man,data}/**/*") + %w[LICENCE.md README.md]
  s.executables << 'snooper'
  # Gem dependencies
  s.add_runtime_dependency "colored", [">= 1.2"]
  s.add_runtime_dependency "listen", ["~> 2.7"]
  if HOST_OS =~ /mswin|mingw|cygwin/i
    s.add_runtime_dependency "wdm", ">= 0.1.0"
  else
    s.add_runtime_dependency "ruby-terminfo", [">= 0.1"]
  end
  s.add_development_dependency "ronn", [">= 0.7.3"]
end
