module Snooper
  class Snoop
  
    require 'listen'
    require 'colored'
    require 'terminfo'
    
    def initialize(path, args = {})
      to_regex = Proc.new { |r| Regexp.new r if not r.is_a?(Regexp) }
      
      @paths = Array(path)
      @filters = args[:filters]
      @filters = Array(args[:filters]).map(&to_regex) if @filters
      @ignored = args[:ignored]
      @ignored = Array(args[:exclude]).map(&to_regex) if @ignored
      @command = args[:command]
    end
    
    def on_change(modified, added, removed)
      begin
        # Puase the listener to make sure any build output doesn't mess with things
        @listener.pause if @listener
      
        # summarise the changes made
        changes = modified + added + removed
      
        puts
        puts "#{changes.length.to_s.magenta.bold} changes, retesting..."
        
        # run the test suite and check the result
        if system @command then
          puts statusbar "All tests passed", &:white_on_green
        else
          puts statusbar "Tests failed", &:white_on_red
        end
        
        # return to listening
        @listener.unpause if @listener
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
  
    def statusbar(message)
      message = message.to_s.center TermInfo.screen_width
      block_given? ? yield(message) : message
    end
        
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