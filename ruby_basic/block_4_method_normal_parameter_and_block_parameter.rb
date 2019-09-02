#!/usr/bin/env ruby

#encoding:utf-8

def my_map(array)
  new_array = []

  for element in array
    new_array.push yield element if block_given?
  end

  new_array
end

result = my_map([1, 2, 3]) do |number|
  number * 2
end

puts result

result = my_map([1, 2, 3])

puts result
