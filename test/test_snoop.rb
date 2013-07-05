#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/snoop'

WATCH_PATH = ENV["TMP"]

# Allow ourselves access to the attributes we want to
# peak at
class Snooper::Snoop
  attr_reader :command, :paths, :filters, :ignored
end

class TestSnoop < Test::Unit::TestCase
  
  ##
  # We need an instance of the class to mess with
  
  def setup
    @snoop = Snooper::Snoop.new WATCH_PATH
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

  def test_settings

    options = {
      :command => 'echo "hello world"',
      :filters => 'foo',
      :ignored => 'bar'
    }
    s = Snooper::Snoop.new WATCH_PATH, options

    assert_equal(s.command, options[:command])
    assert_equal(s.filters, [/foo/])
    assert_equal(s.ignored, [/bar/])

    options = {
      :command => 'echo "foo bar && true',
      :filters => ['foo', 'bar'],
      :ignored => ['bar', 'foo']
    }
    s = Snooper::Snoop.new WATCH_PATH, options

    assert_equal(s.command, options[:command])
    assert_equal(s.filters, [/foo/, /bar/])
    assert_equal(s.ignored, [/bar/, /foo/])

    options = {
      :command => 'echo "foo bar && true',
      :filters => Regexp.new('this[0-9]isaregex'),
      :ignored => Regexp.new('this[a-z]istoo')
    }
    s = Snooper::Snoop.new WATCH_PATH, options

    assert_equal(s.command, options[:command])
    assert_equal(s.filters, [/this[0-9]isaregex/])
    assert_equal(s.ignored, [/this[a-z]istoo/])
  end

end
