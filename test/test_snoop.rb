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
  
  require 'tempconfig'
  include TempConfig
  
  ##
  # We need an instance of the class to mess with
  
  def setup
    @snoop = Snooper::Snoop.new WATCH_PATH
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

end
