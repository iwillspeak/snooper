# -*- coding: utf-8 -*-
# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snoop is open source! See LICENCE.md for more details.

require 'snooper/config'

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
    # config - The String containing the path to the config or a Snooper::Config
    #          like object. If the path is a directory and not a file then
    #          default config names are searched for in the direcory.
    def initialize(config)
      case config
      when String
        @config = Snooper::Config.load config
      else
        @config = config
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
    # Internal: Run a block in a dir
    #
    # direcotry - The String containing the path to change to
    # block     - The block to run
    #
    # Returns the result of the block's execution.
    def in_dir(directory, &block)
      old_dir = File.expand_path '.'
      Dir.chdir directory if directory
      r = yield block
      Dir.chdir old_dir
      r
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
      # Puase the listener to avoid spurious triggers from build output
      @listener.pause if @listener
      
      # summarise the changes made
      changes = modified + added + removed
      
      statusline = ('-' * removed.length).red
      statusline << ('.' * modified.length).blue
      statusline << ('+' * added.length).green
      puts "#{statusline} #{changes.length.to_s.magenta.bold} changes"
      
      @config.hooks.each do |hook|
        hook.run changes
      end

      run_command
      
      # return to listening
      @listener.unpause if @listener
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end

    ##
    # Internal: Run command and print the result
    #
    # Return result of the command
    def run_command
      # run the test suite and check the result
      res, time = time_command @config.command
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
      if @config.file_path
        dir = File.dirname @config.file_path
        filter = %r{#{File.basename @config.file_path}$}
        @cfg_listener = Listen.to dir do |*args|
          next unless args.reduce(&:+).include? @config.file_path
          if @listener
            puts statusbar "Re-loading Config File...", &:yellow
            @listener.stop
            @listener = nil
          end
        end
        @cfg_listener.start
      end

      # on C-c tell all listeners to stop
      Signal.trap "INT", "DEFAULT"

      # loop forever listening, each time the above block causes the listener
      # to stop it will re-start listening with the new config.
      while true
        do_listening
        while @listener != nil
          sleep(1.0)
        end
        @config.reload
      end
    end

    ##
    # Internal : Do the Filesystem Listening
    #
    # This function blocks while it listens to the filsystem for changes. When
    # the lisetner terminates it returns the listener's status
    #
    # Returns the result of the listener
    def do_listening
      in_dir @config.base_path do

        # Notify people if we are using fallback mode
        if @config.force_poll
          puts statusbar "Using polling fallback listener", &:yellow
        end

        # Force a change to start with
        run_command

        params = {
          latency: 0.5,
        }

        params[:only] = Regexp.new @config.filters.join "|" unless @config.filters.empty?
        params[:ignore] = Regexp.new @config.ignored "|" unless @config.ignored.empty?

        if @config.force_poll
          params[:latency] = @config.force_poll
          params[:force_poll] = true
        end

        @listener = Listen.to(*@config.paths, params) do |*args|
          self.on_change *args
        end
        
        @listener.start
      end
    end

  end
end
