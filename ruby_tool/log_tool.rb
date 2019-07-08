#encoding: utf-8

# This file provide convenient methods
#
# Usage:
#   require_relative '../02 - Ruby Helper/rubyscript_helper'
#
# References:
#   https://stackoverflow.com/questions/16856243/how-to-require-a-ruby-file-from-another-directory

require 'logger'
require 'colored2'

# 2. A class for logging message on diferrent level
#
# Usage:
#   Log.i, Log.d, Log.e, Log.w
#
# Demo:
#   Log.w('This is a warning')
#
# Reference:
#   @see none
class Log
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def self.i(msg)
    # @@logger.info(msg)
    puts msg
  end

  def self.d(msg)
    # @@logger.debug(msg)
    puts msg.blue
  end

  def self.w(msg)
    # @@logger.warn(msg)
    puts msg.yellow
  end

  def self.e(msg)
    # @@logger.error(msg)
    puts msg.red
  end
end
