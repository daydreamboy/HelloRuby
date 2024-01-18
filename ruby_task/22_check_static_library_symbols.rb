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

  def defined_symbols
    symbol_list = []
    @symbols.each do |symbol|
      if not symbol.is_undefined?
        symbol_list.append(symbol)
      end
    end
    symbol_list
  end

  def defined_external_symbols
    symbol_list = []
    @symbols.each do |symbol|
      if not symbol.is_undefined? and symbol.is_external?
        symbol_list.append(symbol)
      end
    end
    symbol_list
  end

  def undefined_symbols
    symbol_list = []
    @symbols.each do |symbol|
      if symbol.is_undefined?
        symbol_list.append(symbol)
      end
    end
    symbol_list
  end

  ##
  # Lookup symbol by name in defined external symbol set
  #
  def contains_defined_external_symbol_name?(name)
    defined_external_symbols = self.defined_external_symbols
    defined_external_symbols.each do |symbol|
      if symbol.name == name
        return true
      end
    end
    return false
  end
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

  def is_external?
    if @attribute.nil?
      return false
    end

    return !(@attribute.include?("non-external") or @attribute.include?("private"))
  end
end

class CheckSymbolForStaticLibraryUtility
  attr_accessor :cmd_parser

  attr_accessor :debug
  attr_accessor :verbose
  attr_accessor :conflict
  attr_accessor :dependency
  attr_accessor :arch

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

      opts.on("-aArchFlag", "--arch=ArchFlag", "Arch type. Default is arm64") do |value|
        self.arch = value
      end
    end
  end

  def check_if_static_library(file_path)
    command = "file \"#{file_path}\" 2>/dev/null"
    puts command.cyan if self.debug

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

    puts stdout.cyan if self.debug

    if stdout.include?("current ar archive")
      return true
    else
      return false
    end
  end

  def parse_arch_of_static_library(file_path)
    command = "lipo -info \"#{file_path}\""
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success? && !stdout.empty?
      puts stdout.cyan if self.debug

      index = stdout.rindex(":")
      if index.nil?
        return []
      end

      str = stdout.slice(index+1...).strip!
      archs = str.split(" ")

      Log.d(archs.to_s()) if self.debug

      return archs
    else
      puts "#{stderr}".red !stderr.empty?

      return []
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
    $static_library_list.each_with_index do |static_library1, index1|
      Log.v("[Conflict] checking #{static_library1.path}") if self.verbose

      static_library1.object_files.each do |object_file1|
        Log.v("[Conflict] checking object #{object_file1.name}") if self.verbose
        defined_external_symbols = object_file1.defined_external_symbols
        defined_external_symbols.each do |symbol|
          $static_library_list.each_with_index do |static_library2, index2|
            next if index2 <= index1

            static_library2.object_files.each do |object_file2|
              if object_file2.contains_defined_external_symbol_name?(symbol.name)
                puts "duplicated symbol #{symbol.name} both in:".red
                puts "- #{static_library1.path} (#{object_file1.name})".red
                puts "- #{static_library2.path} (#{object_file2.name})".red
              end
            end
          end
        end
      end
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

  def process_object_file(static_library_path)
    arch = self.arch.nil? ? "arm64" : self.arch
    arch_list = parse_arch_of_static_library(static_library_path)
    if not arch_list.include?(arch)
      Log.w("#{static_library_path} not contains #{arch}")
      return []
    end
    command = "nm -arch #{arch} -m #{static_library_path}"
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      output = "#{stdout}"
      current_object = nil
      object_file_list = []
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
            Log.e("current line: #{line}")
            Log.e("current command: #{command}")
            Log.e("current output: #{output[0..500]}")
            exit(1)
          end
        end
      end
      # Log.d("#{stdout}")  if self.debug
      return object_file_list
    else
      puts "#{stderr}".red if !stderr.empty?
      return []
    end
  end

  def process_static_library(path)
    static_library = WCStaticLibrary.new
    static_library.path = path
    static_library.object_files = process_object_file(path)
    $static_library_list.append(static_library)
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

    PathTool.traverse_all_files(dir_path) do |item|
      file_ext = File.extname(item).delete('.')

      if file_ext == 'a'
        process_static_library(item)
      elsif file_ext == '' and check_if_static_library(item)
        process_static_library(item)
      end
    end

    # dump_object($static_library_list.length)

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