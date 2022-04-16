#!/usr/bin/env ruby

#encoding:utf-8


require '../ruby_tool/dump_tool'

# example from https://mixandgo.com/learn/ruby/blocks
def a_method(&block)
  dump_object(block)
  block.call()
end

# Case 1:
a_method { puts "x" } # => #<Proc:...>

# Case 2:
a_proc = Proc.new { "x" }
a_method(&a_proc) # => #<Proc:...>
# a_method(a_proc) # Runtime: ArgumentError

# Case 3:
a_lambda = -> () { "x" } # => #<Proc:... (lambda)>
a_method(&a_lambda) # => #<Proc:... (lambda)>


# example from https://stackoverflow.com/a/3066747
def a_method_block_with_arguments(&block)
  dump_object(block)
  block.call('Hello', 'World') if block
end

# Case 4: pass a block
a_method_block_with_arguments do |arg1, arg2|
  puts "arg1 = #{arg1}"
  puts "arg2 = #{arg2}"
end

# Case 5: pass a nil as block
a_method_block_with_arguments