#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'json'
require 'open3'
require 'colored2'
require 'benchmark'
require 'fileutils'
require_relative '../ruby_tool/../ruby_tool/log_tool'

class Subcommand_copy

  @@options = {}

  def self.create_subcommand
    return OptionParser.new do |opts|
      opts.program_name = 'file-batch-copy'
      opts.version = "1.0"
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER"
      opts.separator ""
      opts.separator "在指定目录下批量操作文件名"
      opts.separator "Examples:"
      opts.separator "ruby 11_file-batch.rb copy -p '([0-9]+)@2x.png' -o '~/Downloads/Resource.bundle/\\1_new.imageset/\\1@2x.png' ~/Downloads/3.30"
      opts.separator "ruby 11_file-batch.rb copy -p '([0-9]+)@2x.png' -o '~/Downloads/Resource.bundle/\\1_new.imageset/\\1@2x.png' -d ~/Downloads/3.30"

      opts.on("-d", "--[no-]debug", "Run in debug mode") do |v|
        @@options[:debug] = v
      end

      opts.on("-o", "--output [new_filename]", String, "The new file name, e.g. '\1.png'") do |v|
        @@options[:output] = v
      end

      opts.on("-p", "--pattern=regexp", "The regular expression, e.g. [a-zA-Z]+([0-9]+).*") do |v|
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

    Log.d "folder search: #{dir_path}" if @@options[:debug]
    Log.d "pattern: #{pattern}, regexp: #{regexp}" if @@options[:debug]

    Dir.glob(dir_path + '/**{,/*/**}/*') do |item_path|
      next if item_path == '.' or item_path == '..'

      if !File.directory?(item_path) && File.exist?(item_path)
        filename = File.basename(item_path)

        if regexp.match?(filename)
          dest_path = filename.gsub(regexp, File.expand_path(@@options[:output]))
        else
          Log.w "The pattern #{regexp} not match the #{filename}. Skip it."
          next
        end

        if @@options[:debug]
          Log.d "Copying #{item_path} to #{dest_path}"
        else
          FileUtils.cp(item_path, dest_path)
          if @@options[:verbose]
            Log.v "Copying #{item_path} to #{dest_path}"
          end
        end
      end

    end
  end

  def self.options
    @@options
  end
end
