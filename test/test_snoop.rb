#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/snoop'

WATCH_PATH = ENV["TMP"]

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

end