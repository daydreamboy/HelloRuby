

def get_available_python_command
  require_relative '../ruby_tool/command_tool'

  if Command.exists?("python3")
    command = "python3"
  elsif Command.exists?("python")
    command = "python"
  else
    raise "No available python on this system"
  end
  command
end

puts get_available_python_command