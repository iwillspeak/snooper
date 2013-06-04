#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/version'

class TestVersion < Test::Unit::TestCase
  
  def test_version_string
    assert_equal("0.1.1", Snooper::VERSION, "Version number mismatch")
  end
  
end