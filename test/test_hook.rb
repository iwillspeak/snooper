#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/hook'

class TestHook < Test::Unit::TestCase

  def setup
    @passing_hook = Snooper::Hook.new /\.[ch]$/, 'true'
    @failing_hook = Snooper::Hook.new /\.[ch]$/, 'false'
  end

  def test_create
    assert Snooper::Hook
    assert Snooper::Hook.new "pattern", 'echo "hello world"'
    assert Snooper::Hook.new /foo/, 'echo "bar"'
  end

  def test_fire #getit?
    assert @passing_hook.fire
    assert !@failing_hook.fire
  end

  def test_run_hook
    assert @passing_hook.run("hello.c") == true
    assert @passing_hook.run("hello.h") == true
    assert @failing_hook.run("hello.c") == false
    assert @failing_hook.run("hello.h") == false
    assert @passing_hook.run("not-a-match") == nil
    assert @failing_hook.run("not-a-match") == nil
    assert @failing_hook.run(["not me", "me.c"]) == false
    assert @passing_hook.run(["not me", "me_neither", "do.c"]) == true
    assert @passing_hook.run(["not me", "me_neither"]) == nil
  end

  def test_errors
    assert_raise ArgumentError do Snooper::Hook.new nil, "true" end
    assert_raise ArgumentError do Snooper::Hook.new "foobar", nil end
  end
end
