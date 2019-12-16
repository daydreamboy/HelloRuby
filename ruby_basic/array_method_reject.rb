#!/usr/bin/env ruby

list = ['1', '2', '3', '4', '5']
list_to_remove = ['5', '4']

list.reject! do |item|
  list_to_remove.include? item
end

puts list

total_items = (list + list_to_remove).map { |item| 'number: ' + item }
puts total_items
