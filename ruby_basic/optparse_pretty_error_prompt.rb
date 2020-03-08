require 'optparse'

options = {}

begin
  OptionParser.new do |opts|
    opts.on('--require LIB', '-r', 'Specify your library', String)
  end.parse!(into: options)

  p options
  p ARGV
rescue OptionParser::ParseError => e
  puts "#{e.message}"
end


