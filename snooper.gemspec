Gem::Specification.new do |s|
  s.name        = 'snooper'
  s.version     = '0.1.0'
  s.date        = Date.today
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Spying on Tests"
  s.description =
    "A simple language and test system agnostic continuous test runner."
  s.license     =
    "Snooper is Open Source! See the LICENCE.md for more information."
  s.homepage    =
    'http://github.com/iwillspeak/snooper'
  s.authors     = ["Will Speak"]
  s.email       = 'lithiumflame@gmail.com'
  # Gem contents
  s.files       = Dir.glob("{lib,bin,man}/**/*") + %w[LICENCE.md README.md]
  s.executables << 'snooper'
  # Gem dependencies
  s.add_runtime_dependency "colored", [">= 1.2"]
  s.add_runtime_dependency "listen", [">= 0.7"]
  s.add_runtime_dependency "ruby-terminfo", [">= 0.1"]
  s.add_development_dependency "ronn", [">= 0.7.3"]
  # Rdoc stuff
  s.extra_rdoc_files = Dir.glob("{man}/*.ronn") + %w[LICENCE.md README.md]
  s.rdoc_options     << '--main' << 'README.md'
end
