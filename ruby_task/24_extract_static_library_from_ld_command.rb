#!/usr/bin/env ruby
#encoding: utf-8

require 'optparse'

class LdCommandParser
  attr_accessor :cmd_parser

  def initialize
    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER [options]"
      opts.separator ""
      opts.separator "在指定文件夹下递归地检查所有静态库的符号"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -c (检查符号冲突)"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -d"
    end
  end

  def run
    self.cmd_parser.parse!

    if ARGV.length != 1
      puts self.cmd_parser.help
      return
    end

    file_path = ARGV[0]

    if !File.file?(file_path)
      puts "[Error] #{file_path} is not a file!"
      return
    end

    content = IO.read(file_path)
    libraries = content.scan(/ -l([^ ]+)/).flatten
    # puts libraries

    frameworks = content.scan(/ -framework ([^ ]+)/).flatten
    # puts frameworks

    file_name_list = libraries + frameworks
    file_name_list.sort!
    # puts file_name_list.length
    puts file_name_list
  end
end

LdCommandParser.new.run

