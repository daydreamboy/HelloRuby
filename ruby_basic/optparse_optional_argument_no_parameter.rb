require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--verbose')
  opts.on('--abort')
end.parse!(into: options)

p options
p ARGV
