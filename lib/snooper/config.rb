# -*- coding: utf-8 -*-
# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snooper is open source! See LICENCE.md for more details.

module Snooper

  require 'snooper/hook'
  require 'yaml'

  ##
  # Public: Snooper Configuration
  #
  # This object contains the configuration information that is
  class Config

    # base_path - The directory from which all path resolution is based
    attr_accessor :base_path

    # command - The shell command to run when changes are detected
    attr_accessor :command

    # paths - The Array of paths to watch for changes
    attr_accessor :paths

    # filters - The Array of Regex containing the inclusion finters
    attr_accessor :filters

    # ignored = The Array of Regex containing the exclusion filters
    attr_accessor :ignored

    # hooks - The Array of Hook objects
    attr_accessor :hooks

    ##
    # Public: create a new config object
    #
    # base_path - The String representing the path from which all the other
    #             paths should be resolved. Nil to use the current directory.
    # command   - The command to execute when a change satisfies all the
    #             predicates. 
    # options   - The hash containing all of the optinal parameters.
    #             :paths   - The Array of the paths to watch, relative to the
    #                        base. Nil or empty to watch the whole directory.
    #             :filters - THe Array of Regex-like inclusion filters. Nil or
    #                        empty to trigger on all changes.
    #             :ignored - The Array of Regex-like ignore filters. Nil or
    #                        empty to ignore no changes.
    #             :hooks   - The Array of Hook objects to call when a change
    #                        satisifies all the predicates and before the
    #                        command is run. Nil or empty for no hooks.
    def initialize(base_path, command, options={})

      raise ArgumentError, "No command supplied in config" if command == nil

      # use normalised base_path, or CWD if none is given
      @base_path = (base_path && File.expand_path(base_path)) || Dir.pwd

      # comand is used verbotem
      @command = command

      # paths are expanded relative to tbe base, otherwise the base is returned
      base_expand = Proc.new { |p| File.expand_path(p, @base_path) }
      @paths = (options[:paths] && options[:paths].map(&base_expand))
      @paths ||= [@base_path]
      
      # filters all need to be converted to regexes
      rgx_key = Proc.new do |k|
        to_regex = Proc.new { |r| Regexp.try_convert(r) || Regexp.new(r) }
        (options[k] && Array(options[k]).map(&to_regex)) || []
      end

      @filters = rgx_key.call :filters
      @ignored = rgx_key.call :ignored

      @hooks = (options[:hooks] && create_hooks(options[:hooks])) || []
    end

    ##
    # Public: Create Hook Objects
    #
    # raw_hooks - The Array of unprocessed hooks. Each item shoudl either be
    #             a map containing the pattern to match and the command to run
    #             or a Hook or Hook-like object.
    #
    # Returns an Array of Hooks
    def create_hooks(raw_hooks)
      raw_hooks.to_a.map do |hook|
        case hook
        when Hash
          Hook.new hook["pattern"], hook["command"]
        else
          hook
        end
      end
    end

    ##
    # Public: create a new config from a YAML file
    #
    # Retuns a new instace of the Config class
    def self.load(*args)
      instance = allocate
      instance.initialize_from_yaml *args
      instance
    end

    ##
    # Implementaiton: load and initialise a config from a YAML file
    #
    # file_path - The String containing the path to the YAML file.
    def initialize_from_yaml(file_path)
      # Load the options file
      raw_options = YAML.load_file file_path

      base_path = raw_options.delete 'base_path'
      command = raw_options.delete 'command'

      options = raw_options.each_with_object(Hash.new) do |(key, value), opts|
        
        case key
        when 'paths', 'filters', 'ignored'
          value = value.split if value.is_a? String
         
        when 'hooks'
          value.map! do |hook_hash|
            Hook.new hook_hash["pattern"], hook_hash["command"]
          end

        else
          $stderr.puts "warning: ignoring unknown option #{key}"
        end

        opts[key.to_sym] = value
      end
      
      initialize base_path, command, options
    end
  end
end
