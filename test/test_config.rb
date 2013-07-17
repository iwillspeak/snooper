#! /usr/bin/env ruby

require 'test/unit'
require 'snooper/config'

MokHook = Struct.new :pattern, :command

class TestConfig < Test::Unit::TestCase

=begin
  require 'tempfile'
  require 'yaml'

  def setup
    @config_file = Tempfile.new 'snooper_config'
  end

  def teardown
    @config_file.unlink
  end

  def setup_config(config)
     YAML.dump config, @config_file
    @config_file.rewind
  end
=end

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
  
end
