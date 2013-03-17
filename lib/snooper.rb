module Snooper
  
  require 'snooper/snoop'
  
  def self.watch(*args)
    george = Snoop.new *args
    george.run
  end
end
