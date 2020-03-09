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
require_relative './09_foo_subcommand'
require_relative './09_baz_subcommand'
require_relative '../ruby_tool/ruby_tools'

options = {}

subtext = <<HELP
Commonly used command are:
   foo :     does something awesome
   baz :     does something fantastic
See 'opt.rb COMMAND --help' for more information on a specific command.
HELP

parser = OptionParser.new do |opts|
  opts.banner = "Usage: opt.rb [options] [subcommand [options]]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.separator ""
  opts.separator subtext
end
#end.parse!

subcommands = {
    'foo' => Subcommand_foo.create_subcommand,
    'baz' => Subcommand_baz.create_subcommand
}

parser.order!
command = ARGV.shift
if ARGV.length <= 0

end
dump_object(command)

subcommands[command].order!

puts "Command: #{command} "
p options
puts "ARGV:"
p ARGV