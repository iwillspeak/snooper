#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/config'

MokHook = Struct.new :pattern, :command

class TestConfig < Test::Unit::TestCase

  require 'tempfile'
  require 'yaml'

  def setup
    @config_file = Tempfile.new 'snooper_config'
  end

  def teardown
    @config_file.unlink
  end

  def write_config(config)
    @config_file.open
    @config_file.truncate 0
    YAML.dump config, @config_file
    @config_file.close
  end

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

    # test the default values
    c = Snooper::Config.new nil, 'cd'
    assert c.paths == [c.base_path]
    assert c.hooks == []
    assert c.filters == []
    assert c.ignored == []
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
end
