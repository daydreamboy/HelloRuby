#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'json'
require 'open3'
require 'colored2'
require 'benchmark'
require 'fileutils'
require_relative '../ruby_tool/ruby_tools'

class FileBatchUtility
  attr_accessor :cmd_parser
  attr_accessor :cmd_options

  def initialize
    self.cmd_options = {}

    self.cmd_parser = OptionParser.new do |parser|
      parser.banner = "Usage: #{__FILE__} PATH/TO/FOLDER"
      parser.separator ""
      parser.separator "在指定目录下批量操作文件名"
      parser.separator "Examples:"
      parser.separator "ruby 10_file-batch.rb ./emoticon -p '[a-zA-Z]+([0-9]+).*' -o '\1.png'"
      parser.separator "ruby 10_file-batch.rb ./emoticon -p '[a-zA-Z]+([0-9]+).*' -o '\1.png'"
      parser.separator "ruby 10_file-batch.rb ./emoticon  -p '[a-zA-Z]*([0-9]+).*' -o '\1@2x.png' -d"

      parser.on("-v", "--[no-]verbose", "Run verbosely") do |value|
        self.cmd_options[:verbose] = value
      end

      parser.on("-d", "--[no-]debug", "Run in debug mode") do |value|
        dump_object(value)
        self.cmd_options[:debug] = value
      end

      parser.on("-o", "--output [new_filename]", String, "The new file name, e.g. '\1.png'") do |value|
        self.cmd_options[:output] = value
      end
    end
  end

  def run
    self.cmd_parser.parse!

    if ARGV.length != 1
      dump_object(ARGV)
      puts self.cmd_parser.help
      return
    end

    dir_path = ARGV[0]

    dump_object(dir_path)

    if self.cmd_options[:debug]
      dump_object(self.cmd_options)
    end

    if !File.directory?(dir_path)
      puts "[Error] #{dir_path} is not a directory!"
      return
    end

    Dir.glob(dir_path + '**{,/*/**}/*') do |item|
      next if item == '.' or item == '..'

      if !File.directory?(item) && File.exist?(item)
        filename = File.basename(item)

        regexp = /[a-zA-Z]*([0-9]+).*/
        modified_filename = filename.gsub(regexp, '\1')
        dump_object(modified_filename)

        dest = File.join(self.cmd_options[:output], "#{modified_filename}.imageset", filename)
        dump_object(item)
        dump_object(dest)
        FileUtils.cp(item, dest)
      end

    end

  end
end

time = Benchmark.measure {
  FileBatchUtility.new.run
}

puts "Completed with #{time.real} s.".magenta
