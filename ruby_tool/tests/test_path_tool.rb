#encoding: utf-8

require_relative '../ruby_tools'


path = './alias_file'
puts "#{path} = #{PathTool.get_real_path(path)}"

path = './alias_folder'
puts "#{path} = #{PathTool.get_real_path(path)}"

path = './symlink_file'
puts "#{path} = #{PathTool.get_real_path(path)}"

path = './symlink_folder'
puts "#{path} = #{PathTool.get_real_path(path)}"

path = './original_file.txt'
puts "#{path} = #{PathTool.get_real_path(path)}"

