# -*- coding: utf-8 -*-
# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snoop is open source! See LICENCE.md for more details.

require 'snooper/hook'

module Snooper
  
  ##
  # Public: Watches over a directory, executing a comand when files change
  #
  # The fine-grained behaviour of this class is controlled by the parameters
  # passed to the +new+ method.
  class Snoop
  
    require 'listen'
    require 'colored'
    require 'terminfo'
    
    ##
    # Public: Create a new source code spy
    #
    # path - the String or  Array path (or paths) to begin watching
    # args - the Hash of options
    #        :filters - The Array, String or Regexp files to include, empty or
    #                   to signify no filter.
    #        :ignored - The Array, String or Regexp paths to ignore. As above.
    #        :command - The String containing the command to run when changes
    #                   are detected
    #        :hooks   - The Array of hashes to be converted into Hook objects
    def initialize(path, args = {})
      to_regex = Proc.new { |r| Regexp.try_convert(r) || Regexp.new(r) }
      
      @paths = Array(path)
      @filters = args[:filters]
      @filters = Array(@filters).map(&to_regex) if @filters
      @ignored = args[:ignored]
      @ignored = Array(@ignored).map(&to_regex) if @ignored
      @command = args[:command]
      @hooks = create_hooks(args[:hooks])
    end

    ##
    # Public: Create Hook Objects
    #
    # raw_hooks - The Array of maps. Each map should contain the pattern to
    #             match and the command to run.
    #
    # Returns an Array of Hooks
    def create_hooks(raw_hooks)
      raw_hooks.to_a.map do |hook|
        Hook.new hook["pattern"], hook["command"]
      end
    end
    
    ##
    # Internal: Time Command
    #
    # Run a command and time how long it takes. The exit status of the command
    # and the time taken to run the command are both returned.
    #
    # command - The command to run
    #
    # Returns the result of the command and the time taken to run it, in seconds
    def time_command(command)
      before = Time.new
      result = system command
      after = Time.new
      return result, after - before
    end
    
    ##
    # Internal: Change callback
    #
    # Called when a filesystem change is detected by +listen+. Runs the command
    # passed to t he constructor and prints a summary of the output.
    #
    # modified - The Array of paths that were modified since the last change
    # added    - The Array of paths that were added since the last change
    # removed  - The Array of paths that were removed since the last change
    #
    # Raises nothing.
    #
    # Returns nothing.
    def on_change(modified, added, removed)
      begin
        # Puase the listener to avoid spurious triggers from build output
        @listener.pause if @listener
      
        # summarise the changes made
        changes = modified + added + removed
        
        statusline = ('-' * removed.length).red
        statusline << ('.' * modified.length).blue
        statusline << ('+' * added.length).green
        puts "#{statusline} #{changes.length.to_s.magenta.bold} changes"
        
        @hooks.each do |hook|
          hook.run changes
        end

        run_command
        
        # return to listening
        @listener.unpause if @listener
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end

    ##
    # Internal: Run command and print the result
    #
    # Return result of the command
    def run_command
      # run the test suite and check the result
      res, time = time_command @command
      if res then
        puts statusbar "✓ All tests passed", time, &:white_on_green
      else
        puts statusbar "✗ Tests failed", time, &:white_on_red
      end
      res
    end

    ##
    # Internal: Prettify a status line
    #
    # Prints the message at the center of the line, automatically detected
    # from the terminal info. If a block is supplied then the resulting message
    # is post-filtered by it before being returned.
    #
    # message - the message to print
    #
    # Yields the String that has been aligned to the terminal width.
    #
    # Returns the prettified String.
    def statusbar(message, time=nil)
      message << " (#{time.round(3)}s)" if time
      message = message.to_s.center TermInfo.screen_width - 1
      block_given? ? yield(message) : message
    end
    
    ##
    # Public: Main run loop
    #
    # Registers for filesystem notifications and dispatches them to the
    # #on_change handler. This method also forces a dummy update to ensure that
    # tests are run when watching begins.
    #
    # Returns the result of the listener
    def run
      
      # Force a change to start with
      run_command
      
      callback_helper = Proc.new {|*args| self.on_change *args }
      
      @listener = Listen.to(*@paths, :latency => 0.5, :filter => @filters, \
        :ignore => @ignored)
      @listener.change &callback_helper

      @listener.start!
    end
  end
end
