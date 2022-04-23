##
# A example of `then` method
# @see ruby doc

# Case 1
output = 3.next.then do |x|
  x ** x
end.to_s
puts output

# Case 2
output = "my string".yield_self { |s| s.upcase }
puts output

# Case 3
output = "my string".then { |s| s.upcase }.then { |s| s.capitalize }
puts output
