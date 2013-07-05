# -*- coding: utf-8 -*-
# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snoop is open source! See LICENCE.md for more details.

module Snooper
  
  ##
  # File Change Hook
  #
  # Hooks represent a command that is fired when a given file changes. 
  class Hook

    ##
    # Public : Create a new Hook
    #
    # pattern - The String or Regex to match
    # command - The String containig the command to be run
    #
    # Returns a new Hook
    def initialize(pattern, command)
      raise ArgumentError, "invalid pattern" if pattern == nil
      raise ArgumentError, "invalid command" if command == nil
      @command = command
      @pattern = to_regex pattern
    end

    ##
    # Public : Fire the hook
    #
    # Returns the exit code of the command
    def fire
      system @command
    end

    ##
    # Public : Run the Hook
    #
    # path - The String to match agains the hook
    #
    # Returns the exit code of the command or nil if the path doesn't match
    def run(path)
      path = Array(path)
      path.each do |p|
        return fire if @pattern.match p
      end
      nil
    end

    ##
    # Private : Convert a string, regex, or regex-linke to Regexp
    #
    # regex - The String or Regexp to convert
    #
    # Returns a Regexp
    def to_regex(regex)
      Regexp.try_convert(regex) || Regexp.new(regex)
    end

    private :to_regex
  end
end
