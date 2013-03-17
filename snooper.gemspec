Gem::Specification.new do |s|
  s.name        = 'snooper'
  s.version     = '0.0.1'
  s.date        = '2013-03-17'
  s.summary     = "Spying on Tests"
  s.description =
    "A simple language and test system agnostic continuous test runner."
  s.license     =
    "Snooper is Open Source! See the LICENCE.md for more information."
  s.homepage    =
    'http://github.com/iwillspeak/snooper'
  s.authors     = ["Will Speak"]
  s.email       = 'lithiumflame@gmail.com'
  s.files       = ["lib/snooper.rb", "lib/snooper/snoop.rb",
                   "bin/snooper", "LICENCE.md"]
  s.executables << 'snooper'
end
