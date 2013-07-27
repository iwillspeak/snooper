#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/config'

MokHook = Struct.new :pattern, :command

class TestConfig < Test::Unit::TestCase

  require 'utils'
  include TestUtils::TempConfig

  def test_create_compulsory
    r = Snooper::Config.new '.', 'echo "foo_bar"'
    assert r.base_path == Dir.pwd
    assert r.command == 'echo "foo_bar"'

    c = Snooper::Config.new '~', 'true'
    assert r != c
    assert c.base_path == Dir.home
    assert c.command == 'true'

    c = Snooper::Config.new nil, 'false'
    assert c.base_path == Dir.pwd
    assert c.command == 'false'
    
    c = Snooper::Config.new '/usr/local/bin/', 'ls -al'
    assert c.base_path == '/usr/local/bin'
    assert c.command == 'ls -al'
  end
  
  def test_create_options
    
    c = Snooper::Config.new nil, 'cd', :paths => ['test/']
    assert c.paths == [File.expand_path('test/')]
    
    c = Snooper::Config.new '/tmp', 'cd', :paths => ['a', 'b/', 'c']
    assert c.paths == [
                       File.expand_path('a', '/tmp'),
                       File.expand_path('b', '/tmp'),
                       File.expand_path('c', '/tmp')
                       ]

    c = Snooper::Config.new nil, 'cd', filters: [/hello/, 'world']
    assert c.filters == [/hello/, /world/]

    c = Snooper::Config.new nil, 'cd', ignored: ['.*.c', /[^a-g].rb$/]
    assert c.ignored == [/.*.c/, /[^a-g].rb$/]
    
    hooks = [MokHook.new(/a/, 'true'),
             MokHook.new(/b/, 'false')]
    c = Snooper::Config.new nil, 'cd', :hooks => hooks
    assert c.hooks.is_a? Array
    assert c.hooks == hooks

    c = Snooper::Config.new nil, 'cd', hooks: [ { "pattern" => "\.h",
                                                  "command" => "make clean"} ]
    assert c.hooks.is_a? Array
    c.hooks.each { |h| assert h.is_a? Snooper::Hook }

    # test the default values
    c = Snooper::Config.new nil, 'cd'
    assert c.paths == [c.base_path]
    assert c.hooks == []
    assert c.filters == []
    assert c.ignored == []
  end

  def test_create_snoop_migrations

    options = {
      :command => 'echo "hello world"',
      :filters => 'foo',
      :ignored => 'bar'
    }
    c = Snooper::Config.new WATCH_PATH, options[:command], options

    assert_equal(c.command, options[:command])
    assert_equal(c.filters, [/foo/])
    assert_equal(c.ignored, [/bar/])

    options = {
      :command => 'echo "foo bar && true',
      :filters => ['foo', 'bar'],
      :ignored => ['bar', 'foo']
    }
    c = Snooper::Config.new WATCH_PATH, options[:command], options

    assert_equal(c.command, options[:command])
    assert_equal(c.filters, [/foo/, /bar/])
    assert_equal(c.ignored, [/bar/, /foo/])

    options = {
      :command => 'echo "foo bar && true',
      :filters => Regexp.new('this[0-9]isaregex'),
      :ignored => Regexp.new('this[a-z]istoo')
    }
    c = Snooper::Config.new WATCH_PATH, options[:command], options

    assert_equal(c.command, options[:command])
    assert_equal(c.filters, [/this[0-9]isaregex/])
    assert_equal(c.ignored, [/this[a-z]istoo/])
  end

  def test_hooks_migrated
    options = {
      :hooks => [ { "pattern" => "\.h", "command" => "make clean"} ],
      :command => 'true'
    }
    
    c = Snooper::Config.new WATCH_PATH, options[:command], options

    assert c != nil
    h = c.hooks
    assert h
    assert h.length == 1
    h.each do |hook|
      assert hook.is_a? Snooper::Hook
    end
  end

  def test_create_errors
    
    assert_raise ArgumentError do
      Snooper::Config.new nil, nil
    end

    assert_raise ArgumentError do
      Snooper::Config.new
    end

    assert_raise ArgumentError do
      Snooper::Config.new Dir.pwd, nil
    end
  end

  def test_load
    write_config "base_path" => '.', "command" => 'true',
                 "paths" => ['bin', 'lib'],
                 "filters" => ".*\.c$ \.h$", "ignored" => ['tmp/.*', 'tst/.*']

    a =  Snooper::Config.load @config_file
    b =  Snooper::Config.load @config_file.path
    [a, b].each do |c|
      assert c.is_a? Snooper::Config
      assert c.base_path == Dir.pwd
      assert c.command == 'true'
      assert c.paths == [File.expand_path('bin'), File.expand_path('lib')]
    end

    write_config "paths" => "place_one place_two", "command" => 'cd'

    c = Snooper::Config.load @config_file
    assert c.is_a? Snooper::Config
    assert c.paths == [File.expand_path('place_one'),
                       File.expand_path('place_two')]

    write_config 'command' => 'cd',
                 'hooks' => [
                             {'pattern' => ".*", 'command' => 'true'},
                             {'pattern' => ".*", 'command' => 'false'}
                            ]
    
    c = Snooper::Config.load @config_file
    assert c.hooks.length == 2
    c.hooks.each do |h|
      assert h.is_a? Snooper::Hook
      assert h.run("anythign") != nil
      assert h.run("at all") != nil
    end

    assert c.hooks[0].fire
    assert !c.hooks[1].fire

    write_config 'command' => 'true', 'filters' => '\.c$', 'ignored' => '\.h$'
    c = Snooper::Config.load @config_file
    assert c.filters.length == 1
    assert c.ignored.length == 1
  end

  def test_load_empty
    write_config "command" => "true"
    
    c = Snooper::Config.load @config_file
    assert c.is_a? Snooper::Config
    assert c.base_path == Dir.pwd
    assert c.paths == [c.base_path]
    assert c.filters == []
    assert c.ignored == []
    assert c.hooks == []
  end

  def test_remembers_load_path
    write_config "command" => 'cd'
    
    c = Snooper::Config.load @config_file
    assert_equal c.file_path, File.expand_path(@config_file.path)

    c = Snooper::Config.load @config_file.path
    assert_equal c.file_path, File.expand_path(@config_file.path)

    c = Snooper::Config.load File.open(@config_file.path)
    assert_equal c.file_path, File.expand_path(@config_file.path)

    c = Snooper::Config.new ".", "cd"
    assert_equal c.file_path, nil
  end

  def test_reload_config
    write_config 'command' => 'cd'
    
    c = Snooper::Config.load @config_file
    assert_equal 'cd', c.command
    assert_equal true, c.reload
    assert_equal 'cd', c.command

    write_config 'command' => 'false', 'filters' => '\.x$'
    assert_equal true, c.reload
    assert_equal [/\.x$/], c.filters
    
    write_config 'command' => 'true'
    assert_equal true, c.reload
    assert_equal 'true', c.command
    assert_equal [], c.filters
  end

  def test_reload_raw_fails
    c = Snooper::Config.new Dir.pwd, 'cd'
    
    assert c.reload == nil
  end

  def test_reload_when_removed_fails
    write_config 'command' => 'echo "Hello world"'
    
    c = Snooper::Config.load @config_file.path
    assert_equal true, c.reload
    assert_equal 'echo "Hello world"', c.command
    
    File.delete @config_file.path

    assert_equal false, c.reload
    assert_equal 'echo "Hello world"', c.command
  end

end
