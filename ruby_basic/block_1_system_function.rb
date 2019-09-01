#encoding: utf-8

# Note: pass block (do ... end) as parameters
[1, 2, 3].each do |n|
  # Prints out a number
  puts "Number #{n}"
end

# Note: pass block ({ ... }) as parameters
[1, 2, 3].each {|n| puts "Number #{n}"}

