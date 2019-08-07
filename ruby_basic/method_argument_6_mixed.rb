#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

# Note: required -> optional -> variable -> keyword
def testing(a, b = 1, *c, d: 1, **x)
  # p a,b,c,d,x
  dump_object(a)
  dump_object(b)
  dump_object(c)
  dump_object(d)
  dump_object(x)
end

testing('a', 'b', 'c', 'd', 'e', d: 2, x: 1)
