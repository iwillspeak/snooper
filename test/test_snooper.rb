#! /usr/bin/env ruby

require 'test/unit'

# Just a dummy module to ensure that things are imported correctly at the moment
class TestSnooper < Test::Unit::TestCase

  def test_require
    require 'snooper'
  end
end
