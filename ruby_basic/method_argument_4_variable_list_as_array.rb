#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

def method_with_5_args(arg1, arg2, arg3, arg4, arg5)
  dump_object(arg1)
  dump_object(arg2)
  dump_object(arg3)
  dump_object(arg4)
  dump_object(arg5)
end

def print_all(*args)
  # Note: args is an array
  dump_object(args)

  # Note: expand *args as 1, 2, 3, 4, 5
  method_with_5_args(*args)
end

print_all(1, 2, 3, 4, 5)

# Note: splat operator (*) example
list = [ 6, 7, 8, 9, 0 ]
print_all(*list) # Note: expand *list as 6, 7, 8, 9, 0

