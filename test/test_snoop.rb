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
