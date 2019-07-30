#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

# Note: the last is optional keyword argument
def write(file:, data:, mode: "rw")
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  puts "==========================="
end

# Note: keyword argument mixed with normal argument
def write2(file, data:, mode: "rw")
  dump_object(file)
  dump_object(data)
  dump_object(mode)
  puts "==========================="
end

write(data: 123, file: "test.txt")
write2("test.txt", data: 123, mode: 'r')

