#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/version'

class TestVersion < Test::Unit::TestCase
  
  def test_version_string
    version_string = Snooper::VERSION

    # Version should be a sting containing three numbers
    assert(version_string.is_a? String)
    assert_equal(version_string.split(".").length, 3)

    # Version numbers should be number-like
    version_string.split(".").each do |s|
      assert /^[0-9]+/.match s
    end
  end
  
end
