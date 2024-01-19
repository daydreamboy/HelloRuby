#!/usr/bin/env ruby
#encoding: utf-8

require 'set'

file_path1 = '/Users/wesley_chen/Downloads/duplicate symbol.txt'
file_path2 = '/Users/wesley_chen/Downloads/symbol_conflict7.txt'

# 初始化一个空数组以存储重复符号
# duplicate_symbols_from_ld = []
# duplicate_symbols_from_script = []

def extract_symbols(file_path)
  duplicate_symbols = []
  # 逐行读取文件
  File.foreach(file_path) do |line|
    # 匹配每一行中的重复符号名称
    match = line.match(/^duplicate symbol '([^']+)'/)
    duplicate_symbols << match[1] if match
  end

  return duplicate_symbols
end

duplicate_symbols_from_ld = extract_symbols(file_path1)
duplicate_symbols_from_script = extract_symbols(file_path2)
# duplicate_symbols_from_ld.sort!

# puts duplicate_symbols_from_ld
puts duplicate_symbols_from_ld.length


# 转换为集合进行比较
symbols_set1 = duplicate_symbols_from_ld.to_set
symbols_set2 = duplicate_symbols_from_script.to_set

# 检查 file1 中的所有符号是否都在 file2 中
missing_symbols = symbols_set1 - symbols_set2

if missing_symbols.empty?
  puts "All symbols from '#{file_path1}' are present in '#{file_path2}'."
else
  puts "The following symbols from '#{file_path1}' are missing in '#{file_path2}':"
  puts missing_symbols.inspect
end
