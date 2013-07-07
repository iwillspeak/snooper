$:.unshift File.expand_path('../lib/', __FILE__)

require 'snooper/version'

Gem::Specification.new do |s|
  s.name        = 'snooper'
  s.version     = Snooper::VERSION
  s.date        = Date.today
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Spying on Tests"
  s.description = "Snooper is a lightweight test automation tool, it monitors files and folders while you work and re-runs your tests when you change something. Snooper doesn't care what language you're using or what framework you are testing with, it's all configureable."
  s.license     = 'MIT'
  s.homepage    = 'http://github.com/iwillspeak/snooper'
  s.authors     = ["Will Speak"]
  s.email       = 'lithiumflame@gmail.com'
  # Gem contents
  s.files       = Dir.glob("{lib,bin,man}/**/*") + %w[LICENCE.md README.md]
  s.executables << 'snooper'
  # Gem dependencies
  s.add_runtime_dependency "colored", [">= 1.2"]
  s.add_runtime_dependency "listen", [">= 1.2"]
  s.add_runtime_dependency "ruby-terminfo", [">= 0.1"]
  s.add_development_dependency "ronn", [">= 0.7.3"]
  # Rdoc stuff
  s.extra_rdoc_files = Dir.glob("{man}/*.ronn") + %w[LICENCE.md README.md]
  s.rdoc_options     << '--main' << 'README.md'
end
