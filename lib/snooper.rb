##
# Public: This module provides the snooping abilities.
# 
# This program runs in the background watching for file changes. When a file
# change is dtected a command is run. It is intended to watch repos for changes
# and run unit tests automatically when source files are changed.
#
# Author::    Will Speak  (@willspeak)
# Copyright:: Copyright (c) 2013 Will Speak
# License::   Snoop is open source! See LICENCE.md for more details.
#
#
# For most applications calling the Snooper#watch method should be sufficient
# if not Snooper::Snoop objects can be created directly.
module Snooper
  
  require 'snooper/snoop'
  require 'snooper/version'
  require 'snooper/options'

  ##
  # Public: Watch for changes in a directory
  #
  # args - The Hash containing the options. See Snooper::Snoop.new for more
  #        information
  #
  # Returns the reseult of the run.
  def self.watch(*args)
    george = Snoop.new *args
    george.run
  end
end
