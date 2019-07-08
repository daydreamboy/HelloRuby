#!/usr/bin/env ruby
#
# Usage:
#   ruby 03_pass_shell_command_to_script.rb ruby 03_callee.rb
#   ./03_pass_shell_command_to_script.rb ruby 03_callee.rb
#
# Demo ouput:
#   execute `ruby 03_callee.rb` command
#
# Reference:
#   @see https://www.ruby-forum.com/topic/193088
#   @see https://stackoverflow.com/questions/9351539/is-it-possible-to-export-environment-property-from-ruby-script
#
# Note:
#   make this script executable with chmod +x

require_relative '../ruby_tool/ruby_tools'

def pass_shell_command_line_to_another_ruby_script
  ENV['develop_pod_mode']='YES'

  command = ARGV.join(' ')
  status = system(command)
  if (status == nil)
    Log.e "failed to execute #{command}"
  else
    Log.i "exit with status: #{status}"
  end
end

pass_shell_command_line_to_another_ruby_script
