
s1 = '"some"'
s2 = "'some'"

# @see https://www.ruby-forum.com/topic/6878144

s1.gsub!(/\A'|'\z/, '')
s2.gsub!(/\A'|'\z/, '')

puts s1
puts s2
puts '-----'

puts s1.gsub(/\A"|"\z|\A'|'\z/, '')
puts s2.gsub(/\A"|"\z|\A'|'\z/, '')
