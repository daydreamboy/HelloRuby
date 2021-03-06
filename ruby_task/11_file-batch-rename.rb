#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'benchmark'
require_relative '../ruby_tool/ruby_tools'

class Subcommand_rename
  @@options = {}

  def self.create_subcommand
    return OptionParser.new do |opts|
      opts.program_name = 'file-batch-rename'
      opts.version = "1.0"
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER"
      opts.separator ""
      opts.separator "在指定目录下批量重命名文件名"
      opts.separator "Examples:"
      opts.separator "ruby 11_file-batch.rb rename -p 'f([0-9]+).png' -o '\\1@2x.png' ~/Downloads/Resources"
      opts.separator "ruby 11_file-batch.rb rename -p 'f([0-9]+).png' -o '\\1@2x.png' -d ~/Downloads/Resources"

      opts.on("-d", "--[no-]debug", "Run in debug mode, and print command but not execute it.") do |v|
        @@options[:debug] = v
      end

      opts.on("-o", "--output [new_filename]", String, "The new file name, e.g. '\\1.png', which '\\1' for the first captured group") do |v|
        @@options[:output] = v
      end

      opts.on("-p", "--pattern [regexp]", String, "The regular expression, e.g. [a-zA-Z]+([0-9]+).*") do |v|
        @@options[:pattern] = v
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        @@options[:verbose] = v
      end
    end
  end

  def self.execute_subcommand(argv_list)
    if argv_list.nil? or argv_list.length == 0
      return;
    end

    if argv_list.length > 1
      Log.e "expected only one path, but get #{argv_list}"
      return
    end

    dir_path = argv_list[0]

    if dir_path.length <= 0
      Log.e "the folder path is empty: #{dir_path}"
      return
    end

    if !File.directory?(dir_path)
      Log.e "#{dir_path} is not a directory!"
      return
    end

    pattern = "^#{@@options[:pattern]}$"
    regexp = Regexp.new(pattern)

    if @@options[:debug]
      Log.d pattern
      Log.d regexp
    end

    Dir.glob(dir_path + '/**{,/*/**}/*') do |item|
      next if item == '.' or item == '..'

      if !File.directory?(item) && File.exist?(item)
        filename = File.basename(item)
        if regexp.match?(filename)
          modified_filename = filename.gsub(regexp, @@options[:output])
        else
          Log.w "The pattern #{regexp} not match the #{filename}. Skip it."
          next
        end

        if @@options[:debug]
          Log.d "Renaming #{item} to #{modified_filename}"
        else
          dest_path = dir_path + "/" + modified_filename
          File.rename(item, dest_path)
          if @@options[:verbose]
            Log.v "Renaming #{item} to #{dest_path}"
          end
        end

      end
    end
  end

  def self.options
    @@options
  end
end

