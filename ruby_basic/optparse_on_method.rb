require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on('--require LIB', '-r', 'Specify your library', String)
end.parse!(into: options)

p options
p ARGV
