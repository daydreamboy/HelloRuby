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
  def self.v(msg, debug = true, colored = true)
    if debug
      if colored
        puts "[Verbose] #{msg}".blue
      else
        puts "[Verbose] #{msg}"
      end
    end
  end

  ##
  # Debug
  def self.d(arg, dump_mode = true, debug = true, colored = true)
    # @@logger.debug(msg)
    if debug
      loc = caller_locations.first
      line = File.read(loc.path).lines[loc.lineno - 1]

      # get string started by `dump_object`
      callerString = line[/#{__method__}\(.+\)/].to_s

      # get the part of (xxx)
      parenthesis_part = callerString[/\(.+\)/]

      # check if match the format (xx, yy, zz)
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

      if dump_mode
        if colored
          puts "[Debug] #{filename}:#{lineNo}: #{arg_name_str} = (#{arg.class}) #{arg.inspect}".cyan
        else
          puts "[Debug] #{filename}:#{lineNo}: #{arg_name_str} = (#{arg.class}) #{arg.inspect}"
        end
      else
        if colored
          puts "[Debug] #{filename}:#{lineNo}: #{arg}".cyan
        else
          puts "[Debug] #{filename}:#{lineNo}: #{arg}"
        end
      end
    end
  end

  ##
  # Warning
  def self.w(msg, debug = true, colored = true)
    # @@logger.warn(msg)
    if debug
      if colored
        puts "[Warning] #{msg}".yellow
      else
        puts "[Warning] #{msg}"
      end
    end
  end

  ##
  # Error
  def self.e(msg, debug = true, colored = true)
    # @@logger.error(msg)
    if debug
      if colored
        puts "[Error] #{msg}".red
      else
        puts "[Error] #{msg}"
      end
    end
  end

  ##
  # Timing
  def self.t(msg, debug = true, colored = true)
    if debug
      if colored
        puts "[Measure] #{msg}".magenta
      else
        puts "[Measure] #{msg}"
      end
    end
  end
end
