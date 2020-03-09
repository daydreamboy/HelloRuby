#!/usr/bin/env ruby

#encoding: utf-8
#
#
require 'optparse'

class Subcommand_foo
  def self.create_subcommand
    return OptionParser.new do |opts|
      opts.banner = "Usage: foo [options]"
      opts.on("-f", "--[no-]force", "force verbosely") do |v|
        options[:force] = v
      end
    end
  end
end

