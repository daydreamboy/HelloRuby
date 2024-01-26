#!/usr/bin/env ruby
#encoding: utf-8

require 'optparse'

class LdOutputParser
  attr_accessor :cmd_parser

  def initialize
    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FILE [options]"
      opts.separator ""
      opts.separator "在指定文件夹下递归地检查所有静态库的符号"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/FILE"
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

    conflict_symbols = []

    content = IO.read(file_path)
    content.scan(/duplicate symbol '([^']+)' in:\n((?:.|\n)+?)(?=\nduplicate symbol '|\z)/m) do |match|
      library_list = []
      match[1].scan(/Pods\/Release\/([^\/]+)\/[^\/]+/m) do |inner_match|
        # puts "- #{inner_match[0]}"
        library_list.append(inner_match[0])
      end

      match[1].scan(/^.*Developer\/Xcode\/DerivedData.*$/) do |inner_match|
        library_list.append(File.basename(inner_match))
      end

      conflict_symbols.append(
        {
          :symbol_name => match[0],
          :library_list => library_list.uniq.sort
        }
      )
    end

    category_dict = {}
    conflict_symbols.each do |dict|
      # puts dict
      key = dict[:library_list]
      category_dict[key] ||= []
      category_dict[key].append(dict[:symbol_name])
      category_dict[key].uniq!
    end
    category_dict.each_value do |value|
      value.sort!
    end

    # puts category_dict
    output_dict = {}
    category_dict.each do |library_list, conflict_symbol_list|
      output_dict[library_list.join(',')] = conflict_symbol_list
    end

    puts "Found #{output_dict.length} conflicts:"
    output_dict.sort_by { |key, value| key }.each do |key, conflict_symbol_list|
      puts "- #{key}"
      conflict_symbol_list.each do |conflict_symbol|
        puts "  #{conflict_symbol}"
      end
    end
  end
end

LdOutputParser.new.run

