require '../../ruby_tool/command_tool'

def test_which
  puts Command.which('ruby')
  puts Command.which('python')
  puts Command.which('python3')
end

def test_exists
  puts "ruby = #{Command.exists?('ruby')}"
  puts "python = #{Command.exists?('python')}"
  puts "python3 = #{Command.exists?('python3')}"
end

test_which
test_exists

