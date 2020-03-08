require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--verbose=FLAG')
  opts.on('-aflag')
end.parse!(into: options)

p options
p ARGV
