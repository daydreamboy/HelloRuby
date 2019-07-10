#encoding: utf-8

exported_string1 = 'exported_string1'
exported_string2 = 'exported_string2'

# Note: add ; to separate next shell command
puts 'echo running the ruby script...;'

# Note: system() not works
system("export ruby_secret1=\"#{exported_string1}\"")

puts "export ruby_secret2=\"#{exported_string2}\""
puts 'export ruby_secret3=bar2'

