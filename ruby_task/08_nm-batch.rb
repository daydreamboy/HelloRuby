#!/usr/bin/env ruby
#encoding: utf-8

<<-DOC
The nm batch tool for searching symbols in a directory recursively
DOC

require 'optparse'
require 'open3'
require 'colored2'

#require_relative '../ruby_tool/ruby_tools'

$default_exclude_list = %w(
c
cpp
gif
h
hpp
js
json
jpg,
plist
png
py
rb
sh
strings
m
modulemap
mm
webp
wvc
xib
)

class NmUtility

  attr_accessor :cmd_parser
  attr_accessor :cmd_options

  # initialize for new
  def initialize
    self.cmd_options = {}

    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER -s symbol1,symbol2,... [options]"
      opts.separator ""
      opts.separator "在指定目录nm搜索特定的符号"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -s 'OBJC_CLASS_$_XXX' -v"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -s XXX -d"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |toggle|
        self.cmd_options[:verbose] = toggle
      end

      opts.on("-d", "--[no-]debug", "Run in debug mode") do |toggle|
        self.cmd_options[:debug] = toggle
      end

      opts.on("-i", "--include_exts suffix1,suffix2,...", Array, "included files with ext") do |include_list|
        self.cmd_options[:include_list] = include_list
      end

      opts.on("-e", "--exclude_exts suffix1,suffix2,...", Array, "excluded files with ext") do |exclude_list|
        self.cmd_options[:exclude_list] = exclude_list
      end

      opts.on("-s", "--symbol_list symbol1,symbol2,...", Array, "the symbols to search") do |symbol_list|
        self.cmd_options[:symbol_list] = symbol_list
      end
    end
  end

  # parse command line
  def run
    self.cmd_parser.parse!

    if ARGV.length != 1
      puts self.cmd_parser.help
      return
    end

    # @see https://stackoverflow.com/questions/1541294/how-do-you-specify-a-required-switch-not-argument-with-ruby-optionparser/1542658#1542658
    symbol_list = Array(self.cmd_options[:symbol_list])

    if symbol_list.empty?
      puts "[Error] use -s to specify at least one symbol."
      puts self.cmd_parser.help
      return
    end

    dir_path = ARGV[0]

    include_list = Array(self.cmd_options[:include_list])
    exclude_list = self.cmd_options[:exclude_list].nil? ? $default_exclude_list : Array(self.cmd_options[:exclude_list])
    debug = self.cmd_options[:debug]
    verbose = self.cmd_options[:verbose]

    if !File.directory?(dir_path)
      puts "[Error] #{dir_path} is not a directory!"
      return
    end

    # Note: not use `/**/*` instead of `**{,/*/**}/*`
    # @see https://stackoverflow.com/a/2724048
    Dir.glob(dir_path + '**{,/*/**}/*') do |item|
      next if item == '.' or item == '..'

      if !File.directory?(item) && File.exist?(item)
        # puts "stub1"

        # @see https://stackoverflow.com/questions/16902083/exclude-the-from-a-file-extension-in-rails
        file_ext = File.extname(item).delete('.')
        if !exclude_list.empty? and exclude_list.include?(file_ext)
          next
        end

        if include_list.empty? or include_list.include?(file_ext) or file_ext == ''
          # Note: lookup symbols for every file
          symbol_list.each do |symbol|
            command = "nm -m \"#{item}\" 2>/dev/null | grep '#{symbol}'"
            if debug
              puts command.cyan
            end

            stdout, stderr, status = Open3.capture3(command)

            if status.success?
              puts "Find symbol #{symbol} in #{item}".green
              if verbose and !stdout.empty?
                puts "#{stdout}".blue
              end
            else
              if verbose and !stderr.empty?
                puts "#{stderr}".red
              end
            end
          end

        end
      end
    end

  end
end

NmUtility.new.run
