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
  def self.i(msg, debug = true)
    # @@logger.info(msg)
    if debug
      puts msg
    end
  end

  ##
  # Verbose
  def self.v(msg, debug = true)
    if debug
      puts "[Verbose] #{msg}".blue
    end
  end

  ##
  # Debug
  def self.d(arg, debug = true)
    # @@logger.debug(msg)
    if debug
      loc = caller_locations.first
      line = File.read(loc.path).lines[loc.lineno - 1]

      # get string started by `dump_object`
      callerString = line[/#{__method__}\(.+\)/].to_s

      # get the part of (xxx)
      parenthesis_part = callerString[/\(.+\)/]

      # check if match the format (xx, yy)
      match_data = /^\((.+),(.+)\)$/.match(parenthesis_part)
      if not match_data.nil?
        captures = match_data.captures
        if not captures.nil?
          arg_name_str = captures[0]
        end
      else
        # get content of parenthesis
        arg_name_str = (parenthesis_part && parenthesis_part.gsub!(/^\(|\)?$/, '')) || 'empty'
      end

      filename = loc.path
      lineNo = loc.lineno

      puts "[Debug] #{filename}:#{lineNo}: #{arg_name_str} = (#{arg.class}) #{arg.inspect}".cyan
    end
  end

  ##
  # Warning
  def self.w(msg, debug = true)
    # @@logger.warn(msg)
    if debug
      puts "[Warning] #{msg}".yellow
    end

  end

  ##
  # Error
  def self.e(msg, debug = true)
    # @@logger.error(msg)
    if debug
      puts "[Error] #{msg}".red
    end
  end

  ##
  # Timing
  def self.t(msg, debug = true)
    if debug
      puts "[Measure] #{msg}".magenta
    end
  end
end
