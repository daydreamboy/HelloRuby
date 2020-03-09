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

# 2. A class for logging message on different level
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

  ##
  # Info
  def self.i(msg)
    # @@logger.info(msg)
    puts msg
  end

  ##
  # Verbose
  def self.v(msg)
    puts "[Verbose] #{msg}".blue
  end

  ##
  # Debug
  def self.d(msg)
    # @@logger.debug(msg)
    puts "[Debug] #{msg}".cyan
  end

  ##
  # Warning
  def self.w(msg)
    # @@logger.warn(msg)
    puts "[Warning] #{msg}".yellow
  end

  ##
  # Error
  def self.e(msg)
    # @@logger.error(msg)
    puts "[Error] #{msg}".red
  end

  ##
  # Timing
  def self.t(msg)
    puts "[Measure] #{msg}".magenta
  end
end
