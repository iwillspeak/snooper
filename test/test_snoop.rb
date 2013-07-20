#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/snoop'

WATCH_PATH = ENV["TMP"]

# Allow ourselves access to the attributes we want to
# peak at
class Snooper::Snoop
  attr_reader :config
end

class TestSnoop < Test::Unit::TestCase
  
  require 'utils'
  include TestUtils::TempConfig
  
  ##
  # We need an instance of the class to mess with
  
  def setup
    config = TestUtils::MockConfig.new base_path: WATCH_PATH, command: 'true'
    @snoop = Snooper::Snoop.new config
    super
  end
  
  def test_statusbar
    p = Proc.new {|b| "foo"}
    assert_equal "foo", @snoop.statusbar("baz", &p)
    
    p = Proc.new {|b| "fizzle_snaps"}
    assert_equal "fizzle_snaps", @snoop.statusbar("basfdasdfa", &p)
  end

  def test_statusbar_timings
    
    r =  @snoop.statusbar("foobar", 13.37)
    assert r.include? "foobar"
    assert r.include? "13.37"

    r = @snoop.statusbar "hello world", 123456.789112
    assert r.include? "hello world"
    assert r.include? "123456.789"
    assert !(r.include? "112") # make sure that it is rounded

    r = @snoop.statusbar "foobar", 0.123312
    assert r.include? "0.123"
    assert !(r.include? "321")
    
    r = @snoop.statusbar "fsda", 3.3335
    assert r.include? "3.334" # check rounding direction

    r = @snoop.statusbar "h", 12.123
    assert r.include? "12.123s"
  end

  def test_create_with_config
    config = {
      :command => 'echo "Hello World"',
      :base_path => Dir.pwd,
      :paths => [ File.expand_path('test', Dir.pwd) ],
      :filters => [ /\.c$/, /\.h$/ ],
      :ignored => [ /test_.*\.c$/ ]
    }
    config = TestUtils::MockConfig.new config
    
    s = Snooper::Snoop.new config
    assert s
    assert_equal config, s.config
    assert_equal 'echo "Hello World"', s.config.command
  end
  
  def test_cteate_with_config_path
    write_config 'base_path' => Dir.pwd, 'command' => 'true'
    
    s = Snooper::Snoop.new @config_file.path
    assert s.config.is_a? Snooper::Config
    TestUtils.silent { assert s.run_command }
  end
end
