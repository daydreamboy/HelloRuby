#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'benchmark'
require_relative '../ruby_tool/ruby_tools'

class FileRenameBatchUtility
  attr_accessor :cmd_parser
  attr_accessor :cmd_options

  def initialize
    self.cmd_options = {}

    self.cmd_parser = OptionParser.new do |parser|
      parser.banner = "Usage: #{__FILE__} PATH/TO/FOLDER"
      parser.version = "1.0"
      parser.separator ""
      parser.separator "在指定目录下批量重命名文件名"
      parser.separator "Examples:"
      parser.separator "ruby 10_file-batch.rb ./emoticon -p '[a-zA-Z]+([0-9]+).*' -o '\1.png'"
      parser.separator "ruby 10_file-batch.rb ./emoticon -p '[a-zA-Z]+([0-9]+).*' -o '\1.png'"
      parser.separator "ruby 10_file-batch.rb ./emoticon -p '[a-zA-Z]*([0-9]+).*' -o '\1@2x.png' -d"

      parser.on("-v", "--[no-]verbose", "Run verbosely") do |value|
        self.cmd_options[:verbose] = value
      end

      parser.on("-d", "--[no-]debug", "Run in debug mode") do |value|
        self.cmd_options[:debug] = value
      end

      parser.on("-p", "--pattern [regexp]", String, "The regular expression, e.g. [a-zA-Z]+([0-9]+).*") do |value|
        self.cmd_options[:pattern] = value
      end

      parser.on("-o", "--output [new_filename]", String, "The new file name, e.g. '\\1.png', which '\\1' ",
                "for the first captured group") do |value|
        self.cmd_options[:output] = value
      end
    end
  end

  def run
    self.cmd_parser.parse!

    if ARGV.length != 1
      Log.e "Please type a folder path as input, but the current input: #{ARGV}"
      puts self.cmd_parser.help
      return
    end

    dir_path = ARGV[0]

    if self.cmd_options[:debug]
      Log.d "the current input: #{ARGV}"
      dump_object(self.cmd_options)
    end

    if !File.directory?(dir_path)
      Log.e "#{dir_path} is not a directory!"
      return
    end

    Dir.glob(dir_path + '**{,/*/**}/*') do |item|
      next if item == '.' or item == '..'

      if !File.directory?(item) && File.exist?(item)
        filename = File.basename(item)
        pattern = "^#{self.cmd_options[:pattern]}$"
        regexp = Regexp.new(pattern)
        if regexp.match?(filename)
          modified_filename = filename.gsub(regexp, self.cmd_options[:output])
        else
          Log.w "The pattern #{regexp} not match the #{filename}. Skip it."
          next
        end

        if self.cmd_options[:debug]
          dump_object(pattern)
          dump_object(filename)
          dump_object(regexp)
          dump_object(modified_filename)
        else
          File.rename(item, dir_path + "/" + modified_filename)
          if self.cmd_options[:verbose]
            Log.v "Renaming #{item} to #{dir_path + "/" + modified_filename}"
          end
        end

      end
    end

  end
end

time = Benchmark.measure {
  FileRenameBatchUtility.new.run
}

Log.t "Completed with #{time.real} s."
