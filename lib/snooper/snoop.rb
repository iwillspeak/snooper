# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snoop is open source! See LICENCE.md for more details.

module Snooper
  
  ##
  # Watches over a directory, executing a comand when files change
  #
  # The fine-grained behaviour of this class is controlled by the parameters
  # passed to the +new+ method.
  class Snoop
  
    require 'listen'
    require 'colored'
    require 'terminfo'
    
    ##
    # Create a new source code spy
    #
    # @param [String, Array] path - the path (or paths) to begin watching
    # @param [Hash] args - the options hash
    # [+:filters+] [Array,String,Regexp] Files to include, empty for all
    # [+:ignored+] [Array,String,Regexp] Paths to ignore
    # [+:command+] [String] The command to run when changes are detected
    
    def initialize(path, args = {})
      to_regex = Proc.new { |r| Regexp.new r if not r.is_a?(Regexp) }
      
      @paths = Array(path)
      @filters = args[:filters]
      @filters = Array(@filters).map(&to_regex) if @filters
      @ignored = args[:ignored]
      @ignored = Array(@ignored).map(&to_regex) if @ignored
      @command = args[:command]
    end
    
    ##
    # Time Command
    #
    # Run a command and time how long it takes. The exit status of the command
    # and the time taken to run the command are both returned.
    
    def time_command(command)
      before = Time.new
      result = system command
      after = Time.new
      return result, after - before
    end
    
    ##
    # Change callback
    #
    # Called when a filesystem change is detected by +listen+. Runs the command
    # passed to t he constructor and prints a summary of the output.
    
    def on_change(modified, added, removed)
      begin
        # Puase the listener to make sure any build output doesn't mess with things
        @listener.pause if @listener
      
        # summarise the changes made
        changes = modified + added + removed
        
        statusline = ('-' * removed.length).red
        statusline << ('.' * modified.length).blue
        statusline << ('+' * added.length).green
        puts "#{statusline} #{changes.length.to_s.magenta.bold} changes"
        
        # run the test suite and check the result
        res, time = time_command @command
        if res then
          puts statusbar "✓ All tests passed (#{time}s)", &:white_on_green
        else
          puts statusbar "✗ Tests failed (#{time}s)", &:white_on_red
        end
        
        # return to listening
        @listener.unpause if @listener
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
  
    ##
    # Prettify a status line
    #
    # Prints the message at the center of the line, automatically detected 
    # from the terminal info. If a block is supplied then the resulting message
    # is post-filtered by it before being returned.
    #
    # @param message - the message to print
    
    def statusbar(message)
      message = message.to_s.center TermInfo.screen_width
      block_given? ? yield(message) : message
    end
    
    ##
    # Main run loop
    #
    # Registers for filesystem notifications and dispatches them to the
    # +on_change+ handler. This method also forces a dummy update to ensure that
    # tests are run when watching begins.
    
    def run
      
      # Force a change to start with
      on_change [], [], []
      
      callback_helper = Proc.new {|*args| self.on_change *args }
      
      @listener = Listen.to(*@paths, :latency => 0.5, :filter => @filters, \
        :ignore => @ignored)
      @listener.change &callback_helper

      @listener.start
    end
  end
end