#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

def write(file, data, mode = "w")
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  puts "==========================="
end

=begin
def write2(file, data, mode = "w", size)
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  dump_object(size)
  puts "==========================="
end
=end

def write2(file = 'default', data, mode, size)
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  dump_object(size)
  puts "==========================="
end

# Error: the optional argument `name` should not after normal argument `size` again
=begin
def write3(file, data, mode = "w", size, name = "default")
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  dump_object(size)
  dump_object(name)
  puts "==========================="
end
=end

def write3_fixed(file, data, size, mode = "w", name = "default")
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  dump_object(size)
  dump_object(name)
  puts "==========================="
end

# Ok: the last parameter is omitted optionally
# write("cats.txt", "cats are cool!")

write2("cats are cool!", "w", 10)
write2("cats.txt", "cats are cool!", "r", 10)

# write3("cats.txt", "cats are cool!", 10)
# write3("cats.txt", "cats are cool!", "r", 10)
# write3("cats.txt", "cats are cool!", "r", 10, "a.txt")

