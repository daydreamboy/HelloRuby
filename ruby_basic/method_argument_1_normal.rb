#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

def write(file, data, mode)
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  puts "==========================="
end

# Note: must specify two arguments
# Error: wrong number of arguments (given 0, expected 3) (ArgumentError)
# write

# Note: must specify two arguments, the 2, 3, 4 not treat as Array
# Error: wrong number of arguments (given 4, expected 3) (ArgumentError)
# write(1, 2, 3, 4)

# Ok: arguments are correct
write("cats.txt", "cats are cool!", "w")
