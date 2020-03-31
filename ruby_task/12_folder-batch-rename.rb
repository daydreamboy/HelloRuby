#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require_relative '../ruby_tool/log_tool'

class Subcommand_rename

  @@options = {}

  def self.create_subcommand
    return OptionParser.new do |opts|
      opts.banner = "Usage: rename [options] -p 'pattern' -o 'new_folder' path/to/folder"
      opts.separator ""
      opts.separator "Examples:"
      opts.separator "ruby 12_folder-batch.rb rename -v -p '([0-9]+).*' -o '\\1_new.imageset' ./xxx.bundle"
      opts.separator ""

      opts.on("-v", "--verbose", "Run verbosely") do |v|
        @@options[:verbose] = v
      end

      opts.on('-d', '--debug', 'Execute in debug mode and print debug info') do |v|
        @@options[:debug] = v
      end

      opts.on('-r', '--recursive', 'Recursively rename directories') do |v|
        @@options[:recursive] = v
      end

      opts.on("-p", "--pattern=regexp", "The regular expression, e.g. [a-zA-Z]+([0-9]+).*") do |v|
        @@options[:pattern] = v
      end

      opts.on("-o", "--output=new_folder", "The new folder name, e.g. '\\1.imageset' which '\\1' for the first captured group") do |v|
        @@options[:output] = v
      end
    end
  end

  def self.execute_subcommand(argv_list)

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

    sub_path = if @@options[:recursive] then '/**{,/*/**}/*' else '/*' end
    pattern = "^#{@@options[:pattern]}$"
    regexp = Regexp.new(pattern)

    Log.d "folder search: #{dir_path + sub_path}" if @@options[:debug]
    Log.d "pattern: #{pattern}, regexp: #{regexp}" if @@options[:debug]

    Dir.glob(dir_path + sub_path) do |item|
      next if item == '.' or item == '..'

      if File.directory?(item) && File.exist?(item)
        folder_name = File.basename(item)
        if regexp.match?(folder_name)
          modified_folder_name = folder_name.gsub(regexp, @@options[:output])
        else
          Log.w "The pattern #{regexp} not match the #{folder_name}. Skip it."
          next
        end

        if @@options[:debug]
          Log.d "`#{folder_name}` to `#{modified_folder_name}`"
        else
          dest_path = dir_path + "/" + modified_folder_name
          File.rename(item, dest_path)
          if @@options[:verbose]
            Log.v "Renaming #{item} to #{dest_path}"
          end
        end

      end
    end
  end
end

