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
  def self.i(msg, disabled = false)
    # @@logger.info(msg)

    if !disabled
      puts msg
    end
  end

  ##
  # Verbose
  def self.v(msg, disabled = false)
    if !disabled
      puts "[Verbose] #{msg}".blue
    end
  end

  ##
  # Debug
  def self.d(arg, disabled = false)
    # @@logger.debug(msg)
    if !disabled
      loc = caller_locations.first
      line = File.read(loc.path).lines[loc.lineno - 1]

      # get string started by `dump_object`
      callerString = line[/#{__method__}\(.+\)/].to_s

      # get parameter name of `dump_object`
      argName = callerString[/\(.+\)/]

      # get content of parenthesis
      argNameStr = (argName && argName.gsub!(/^\(|\)?$/, '')) || 'empty'

      filename = loc.path
      lineNo = loc.lineno

      puts "[Debug] #{filename}:#{lineNo}: #{argNameStr} = (#{arg.class}) #{arg.inspect}".cyan
    end
  end

  ##
  # Warning
  def self.w(msg, disabled = false)
    # @@logger.warn(msg)

    if !disabled
      puts "[Warning] #{msg}".yellow
    end

  end

  ##
  # Error
  def self.e(msg, disabled = false)
    # @@logger.error(msg)

    if !disabled
      puts "[Error] #{msg}".red
    end
  end

  ##
  # Timing
  def self.t(msg, disabled = false)
    if !disabled
      puts "[Measure] #{msg}".magenta
    end
  end
end
