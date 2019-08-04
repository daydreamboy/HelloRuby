#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

def method_with_2_arguments(x, y)
  dump_object(x)
  dump_object(y)
end

def print_all(**args)
  # Note: args is a hash
  dump_object(args)

  # Note: expand *args as [:x, 1], [:y, 2]
  method_with_2_arguments *args

  # Note: **args also a hash
  dump_object(**args)
end

print_all(x: 1, y: 2)
