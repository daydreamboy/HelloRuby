require_relative '../../ruby_tool/command_tool'

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

def get_available_python_command
  require_relative '../../ruby_tool/command_tool'

  if Command.exists?("python3")
    command = "python3"
  elsif Command.exists?("python")
    command = "python"
  else
    raise "No available python on this system"
  end
  command
end

test_which
test_exists

command = get_available_python_command
puts "#{command} xxx.py"

