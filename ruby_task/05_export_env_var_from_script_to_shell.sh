#!/usr/bin/env bash

# @see https://stackoverflow.com/questions/24671014/exporting-ruby-variables-to-parent-process
# Note: 执行简单的ruby代码，导出环境变量
eval `ruby -e "puts 'export foo=bar'"`
echo $foo

# Note: 执行的ruby脚本，导出环境变量
eval `ruby './05_export_env_var_from_script_to_shell.rb'`

echo "ruby_secret1 = $ruby_secret1"
echo "ruby_secret2 = $ruby_secret2"
echo "ruby_secret3 = $ruby_secret3"


