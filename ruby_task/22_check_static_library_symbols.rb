#!/usr/bin/env ruby
#encoding: utf-8

<<-DOC
A tool for check symbols in binary file which MachO type is static library
This tool produce the following analysis data:
- Conflicted symbols 
- Symbol dependency
Above results also display related libraries
For example:
TODO

DOC

require 'optparse'
require 'open3'
require 'colored2'
require 'benchmark'
require 'fileutils'

require_relative '../ruby_tool/ruby_tools'
require_relative '../ruby_tool/ext_numeric'

$static_library_list = []

class WCStaticLibrary
  attr_accessor :path
  attr_accessor :object_files
end

class WCObjectFile
  # The path for object file
  attr_accessor :path
  # The name for object file
  attr_accessor :name
  # The symbol list in object file
  attr_accessor :symbols
end

class WCSymbol
  # raw line for single symbol
  attr_accessor :line

  # The four parts: address<space>segment_info<space>attribute<space>symbol_name
  attr_accessor :address
  attr_accessor :segment
  attr_accessor :attribute
  attr_accessor :name

  ##
  # Check symbol if undefined
  #
  def is_undefined?
    if @segment.nil?
      return false
    end

    return @segment == "undefined"
  end
end

class CheckSymbolForStaticLibraryUtility
  attr_accessor :cmd_parser

  attr_accessor :debug
  attr_accessor :verbose
  attr_accessor :conflict
  attr_accessor :dependency

  # initialize for new
  def initialize
    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER [options]"
      opts.separator ""
      opts.separator "在指定目录nm搜索特定的符号"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -v"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -d"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |toggle|
        self.verbose = toggle
      end

      opts.on("-d", "--[no-]debug", "Run in debug mode") do |toggle|
        self.debug = toggle
      end

      opts.on("-c", "--[no-]conflict", "Check symbol conflict") do |toggle|
        self.conflict = toggle
      end

      opts.on("-D", "--dependency", "Check symbol dependency") do |toggle|
        self.dependency = toggle
      end
    end
  end

  def check_if_static_library(file_path)
    command = "lipo -info \"#{file_path}\" 2>/dev/null"
    # puts command.cyan if self.debug
    puts command.cyan if self.verbose

    stdout, stderr, status = Open3.capture3(command)

    if not status.success?
      if self.verbose and !stderr.empty?
        puts "#{stderr}".red
      end

      return false
    end

    if stdout.empty?
      return false
    end

    # puts stdout.cyan if self.debug
    puts stdout.cyan if self.verbose

    if stdout.include?("fat file") or stdout.include?("Non-fat file")
      return true
    else
      return false
    end
  end

  ##
  # Find static library binary files in framework
  #
  # @param [String] framework_path
  #       The path of framework
  #
  # @return [Array] The path list for
  #
  def find_static_library_in_framework(framework_path)
    file_ext = File.extname(framework_path).delete('.')
    if file_ext != 'framework'
      return []
    end

    path_list = []
    Dir.glob(framework_path + '/*') do |item|
      next if item == '.' or item == '..'
      if check_if_static_library(item)
        path_list.append(item)
      end
    end

    return path_list
  end

  def check_symbol_conflict
    $static_library_list.each do |static_library|
      Log.v("[Conflict] checking #{static_library.path}") if self.verbose
    end
  end

  def process_symbol(line)
    if line.strip.length == 0
      return nil
    end

    # symbol line format:
    # - defined symbol
    # address<space>(segment)<space>attribute<space>name
    # - undefined symbol
    # <space><space>(undefined)<space>attribute<space>name
    symbol = WCSymbol.new
    symbol.line = line

    symbol.address = line.index(' ').nil? ? "" : line[0..line.index(' ')].strip
    symbol.segment = (line.index('(').nil? || line.rindex(')').nil?) ? "" : line[line.index('(')+1..line.rindex(')')-1]

    Log.d("line: #{line}") if self.debug
    if line.include?("_block_invoke")
      separator = '___'
    elsif line.include?("+[") or line.include?("-[")
      separator = line.include?("+[") ? '+[' : '-['
    else
      separator = ' '
    end
    symbol.attribute = (line.rindex(')').nil? || line.rindex(separator).nil?) ? "" : line[line.rindex(')')+1..line.rindex(separator)].strip
    symbol.name = line.rindex(separator).nil? ? "" : line[line.rindex(separator)..-1].strip

    return symbol
  end

  def process_object_file(path)
    command = "nm -m #{path}"
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      output = "#{stdout}"
      object_file_list = []
      current_object = nil
      output.each_line do |line|
        # Note: remove \n of each line
        line = line.chomp

        if line.strip.length == 0
          next
        end

        # This is header line
        if line.include?(".o:") or line.include?(".o):")
          # Log.v("Process new object file: #{line}") if self.verbose
          current_object = WCObjectFile.new
          current_object.name = line.include?("(") ? line.split('(')[1].gsub(/\A[():]+|[():]+\z/, '') : line.strip
          current_object.path = line.include?("(") ? line.split('(').first.strip : '.'
          current_object.symbols = []
          object_file_list.append(current_object)
        else
          if not current_object.nil?
            symbol = process_symbol(line)
            current_object.symbols.append(symbol) if not symbol.nil?
            Log.v("add symbol: #{symbol.name}|#{symbol.segment}|#{symbol.attribute}|#{symbol.address}|#{symbol.is_undefined?}|") if self.debug
          else
            Log.e("Should never hit this line")
            exit(1)
          end
        end
      end
      # Log.d("#{stdout}")  if self.debug
      return object_file_list
    else
      puts "#{stderr}".red if !stderr.empty?
      return nil
    end
  end

  def process_static_library(path)
    static_library = WCStaticLibrary.new
    static_library.path = path
    static_library.object_files = process_object_file(path)
    $static_library_list.append(static_library)
  end

  def traverse_all_files(dir_path, &block)
    raise ArgumentError, "Block is required" unless block_given?

    Dir.glob(dir_path + '/**/*') do |item|
      # Log.d("item: #{item}")

      next if item == '.' or item == '..'
      next if File.directory?(item)

      if File.symlink?(item)
        linked_item = File.readlink(item)
        if File.directory?(linked_item)
          traverse_all_files(linked_item, &block)
        end
      end

      if File.file?(item)
        Log.d("item: #{item}")
        block.call(item) if block_given?
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

    dir_path = ARGV[0]

    if !File.directory?(dir_path)
      puts "[Error] #{dir_path} is not a directory!"
      return
    end

    traverse_all_files(dir_path + '/**/*') do |item|
      file_ext = File.extname(item).delete('.')

      if file_ext == 'a'
        process_static_library(item)
      elsif file_ext == '' and check_if_static_library(item)
        process_static_library(item)
      end
    end

    # Dir.glob(dir_path + '/**/*') do |item|
    #   Log.d("item: #{item}")
    #
    #   next if item == '.' or item == '..'
    #   next if File.directory?(item)
    #
    #   Log.v("item: #{item}")
    #
    #   file_ext = File.extname(item).delete('.')
    #
    #   if file_ext == 'a'
    #     process_static_library(item)
    #   elsif file_ext == '' and check_if_static_library(item)
    #     process_static_library(item)
    #   end
    # end

    dump_object($static_library_list.length)

    if self.conflict
      check_symbol_conflict()
    end

  end
end

# @see https://stackoverflow.com/a/29166478
time = Benchmark.measure {
  CheckSymbolForStaticLibraryUtility.new.run
}

puts "Completed with #{time.real.duration}.".magenta