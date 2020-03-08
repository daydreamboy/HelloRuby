require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--verbose[=XXX]')
  opts.on('-a[YYY]')
end.parse!(into: options)

p options
p ARGV
