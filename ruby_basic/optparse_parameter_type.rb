#encoding: utf-8

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on("-v", "--verbose")
  opts.on("-i", "--integer", Integer, '=integer')
  opts.on("-p", "--path", String, '=path')
  opts.on("-d", "--decimal", Float, '=decimal')

  # Note: take a list of opts (must have a opt at least)
  opts.on("-l", "--list x,y", Array,
          "This command flag takes a comma separated list (without",
          "spaces) of values and turns it into an array. This requires",
          "at least one argument.")
end.parse!(into: options)

p options
p ARGV

