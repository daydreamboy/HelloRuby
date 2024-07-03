#!/usr/bin/env ruby
#encoding: utf-8

require 'optparse'

class LdOutputParser
  attr_accessor :cmd_parser

  def initialize
    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FILE [options]"
      opts.separator ""
      opts.separator "解析Xcode的ld命令执行输出结果，存在缺失符号的报错"
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

    undefined_symbols = []

    content = IO.read(file_path)
    content.scan(/  "([^"]+)", referenced from:\n((?:.|\n)+?)(?=\n  "|\z)/m) do |match|
      library_list = []

      # Note match `in XXX(yyy.o)`
      match[1].scan(/in ([^\(]*?)\(/m) do |inner_match|
        #puts "- #{inner_match[0]}"
        library_list.append(inner_match[0])
      end

      undefined_symbols.append(
        {
          :symbol_name => match[0],
          :library_list => library_list.uniq.sort
        }
      )
    end

    category_dict = {}
    undefined_symbols.each do |dict|
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
    category_dict.each do |library_list, undefined_symbol_list|
      output_dict[library_list.join(',')] = undefined_symbol_list
    end

    puts "Found #{output_dict.length} libraries missing symbols:"
    output_dict.sort_by { |key, value| key }.each do |key, undefined_symbol_list|
      puts "- #{key}"
      undefined_symbol_list.each do |undefined_symbol|
        puts "  #{undefined_symbol}"
      end
    end
  end
end

LdOutputParser.new.run

