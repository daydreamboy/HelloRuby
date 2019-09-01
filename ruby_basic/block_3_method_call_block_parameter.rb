#encoding: utf-8

def my_method
  puts "reached the top"
  # Note: call the block parameter by using `yield`
  yield
  puts "reached the bottom"
end

my_method do
  puts "reached yield"
end

# Note: do ... end is not a literal block, so can't call it directly by `yield`
=begin
do
    puts 'block called'
end.yield
=end
