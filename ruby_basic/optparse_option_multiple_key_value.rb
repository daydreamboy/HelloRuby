require 'optparse'
require_relative '../ruby_tool/ruby_tools'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-n", "--name NAME", "The name of the person") do |value|
    options[:name] = value
  end

  opts.on("-a", "--age AGE", Integer, "The age of the person") do |value|
    options[:age] = value
  end

  opts.on("-s", "--student", "Is the person a student?") do |value|
    options[:student] = value
  end

  # Note: use multiple option arguments, e.g. --item key1=value1 --item key2=value2
  opts.on("--item KEY=VALUE", "Description of item option") do |pair|
    key, value = pair.split('=')
    # Note: make options[:items] must be a hash container
    options[:items] ||= {}
    options[:items][key.to_sym] = value
  end
end.parse!

puts "Name: #{options[:name]}" if options[:name]
puts "Age: #{options[:age]}" if options[:age]
puts "Student: #{options[:student]}" if options[:student]
puts "Items: #{options[:items]}" if options[:items]

dump_object(options)

# Usage example
# $ ruby optparse_option_multiple_key_value.rb --name Alice --age 30 --student --item key1=value1 --item key2=value2
#
# Bug example
# $ ruby optparse_option_multiple_key_value.rb --item key1=value1 --item key2=value2 -name Alice


