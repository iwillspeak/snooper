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
  require 'snooper/options'
  require 'snooper/config'

  ##
  # Public: Watch for changes in a directory
  #
  # config - The String containing the path to a config or a Config-like object
  #
  # Returns the reseult of the run.
  def self.watch(config)
    Snoop.new(config).run
  end
end
