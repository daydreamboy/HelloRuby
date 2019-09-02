#encoding: utf-8

def my_method
  puts "reached the top"
  # Note: call the block parameter by using `yield`
  status = yield("John", 2) if block_given?
  puts "reached the bottom"
  puts "status code: #{status}"
end

my_method do |name, age|
  puts "Hello, #{name} in #{age} years old"
  puts "reached yield"
  1
end

puts '-------------'
# Note: no block parameter
my_method

# Note: do ... end is not a literal block, so can't call it directly by `yield`
=begin
do
    puts 'block called'
end.yield
=end
