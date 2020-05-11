#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'json'
require 'open3'
require 'colored2'
require 'benchmark'
# require_relative '../ruby_tool/dump_tool'

class GitBatch
  attr_accessor :globalParser
  attr_accessor :subcommands
  attr_accessor :configuration
  attr_accessor :debugging

  def initialize

    self.subcommands = {
        # Note: configure more subcommand here...
        'log' => {
            :optParser => OptionParser.new do |parser|
              parser.banner = "Usage: #{__FILE__} log [-options] argument"

              parser.on("-d", "--days N", Integer, "The number of recent days") do |days|
                self.subcommands['log'][:options][:days] = days
              end
            end,
            :action => Proc.new do |subcommandline|
            end,
            :options => {}
        },
        'pull' => {
            :optParser => nil,
            :action => Proc.new do |subcommandline|

            end
        },
    }

    self.globalParser = OptionParser.new do |parser|
      parser.banner = "Usage: #{__FILE__} <git subcommand> [-options] argument"
      parser.separator  ""
      parser.separator  "git批量工具"
      parser.separator  ""
      parser.separator  "示例：ruby /path/to/07_git-batch.rb log -d 10"
      parser.separator  ""
      parser.separator  "内置子命令如下#{self.subcommands.keys}"
      parser.separator  ""
      parser.separator  "查看帮助：ruby /path/to/07_git-batch.rb --help"

      # Boolean switch.
      parser.on("-d", "--[no-]debug", "Run with debug info") do |enabled|
        self.debugging = enabled
      end
    end
  end

  def run
    if ARGV.empty?
      puts globalParser.help
      return
    end

    # Note: parse first level command
    self.globalParser.order!

    subcommandline = ARGV.join(' ')
    subcommand = ARGV.shift

    if self.subcommands[subcommand].nil?
      puts "\033[31m[Error] #{subcommand} command not available. #{ self.subcommands.keys.join(', ') } are available.\033[0m"
      puts
      puts globalParser.help
      return
    else
      if not self.subcommands[subcommand][:optParser].nil?

        # Note: parse second level command if needed
        self.subcommands[subcommand][:optParser].order!
      end

      self.subcommands[subcommand][:action].call(subcommandline)
    end
  end
end

time = Benchmark.measure {
  GitBatch.new.run
}

puts "Completed with #{time.real} s.".magenta
