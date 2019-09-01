#encoding: utf-8

require 'optparse'
require_relative '../ruby_tool/dump_tool'

<<-DOC
The example for parsing multiple subcommands
@see https://stackoverflow.com/a/2737822
DOC

global = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} subcommand [-options] argument"
end

subcommands = {
    'foo' => OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} foo [-options] argument"
    end,
    # ...
    'baz' => OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} baz [-options] argument"
    end
}

if ARGV.empty?
puts global.help
return
end

global.order!
subcommands[ARGV.shift].order!

dump_object(ARGV)

