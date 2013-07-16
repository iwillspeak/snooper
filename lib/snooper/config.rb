# -*- coding: utf-8 -*-
# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snooper is open source! See LICENCE.md for more details.

module Snooper

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

      # use normalised base_path, or CWD if none is given
      @base_path = (base_path && File.expand_path(base_path)) || Dir.pwd

      # comand is used verbotem
      @command = command

      # paths are expanded relative to tbe base, otherwise the base is returned
      base_expand = Proc.new { |p| File.expand_path(@base_path, p) }
      @paths = (options[:paths] && options[:paths].map(&base_expand))
      @paths ||= [@base_path]
      
      # filters all need to be converted to regexes
      to_regex = Proc.new { |r| Regexp.try_convert(r) || Regexp.new(r) }
      rgx_key = Proc.new { |k| (options[k] && options[k].map(&to_regex)) || [] }
      @filters = rgx_key.call :filters
      @ignored = rgx_key.call :ignored

      @hooks = options[:hooks] || []
    end
  end
end
