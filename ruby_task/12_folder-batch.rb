#!/usr/bin/env ruby -w
## Using ruby's standard OptionParser to get subcommand's in command line arguments
## Note you cannot do: opt.rb help command
## other options are commander, main, GLI, trollop...

# run it as
# ruby opt.rb --help
# ruby opt.rb foo --help
# ruby opt.rb foo -q
# etc
#
# @see https://gist.github.com/rkumar/445735

require 'optparse'
require 'benchmark'
require 'colored2'
require_relative './12_folder-batch-rename'

options = {}

subtext = <<HELP
Commonly used subcommand are:
   rename : rename directories by batch
   baz    : does something fantastic
See 'opt.rb SUBCOMMAND --help' for more information on a specific subcommand.
HELP

parser = OptionParser.new do |opts|
  opts.banner = "Usage: opt.rb [options] [subcommand [options]] arguments"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.separator ""
  opts.separator subtext
end
#end.parse!

subcommands = {
    'rename' => Subcommand_rename,
}

parser.order!
subcommand = ARGV.shift
if ARGV.length <= 0
  puts parser.help()
  return
end

time = Benchmark.measure {
  subcommands[subcommand].create_subcommand.order!
  subcommands[subcommand].execute_subcommand(ARGV)
}

puts "Completed with #{time.real} s.".magenta
