#encoding:utf-8

##
# work with 03_pass_shell_command_to_script.rb

if !ENV['develop_pod_mode'].nil?
  puts 'is develop_pod_mode'
else
  puts 'is not develop_pod_mode'
end
