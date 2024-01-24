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

def puts_red(msg, colored = true)
  if colored
    puts "#{msg}".red
  else
    puts"#{msg}"
  end
end

def puts_magenta(msg, colored = true)
  if colored
    puts "#{msg}".magenta
  else
    puts"#{msg}"
  end
end

class WCStaticLibrary
  attr_accessor :path
  # xxx.a or yyy
  attr_accessor :file_name
  attr_accessor :object_files

  def ==(other)
    return @path == other.path
  end
end

class WCObjectFile
  # The path for object file
  attr_accessor :path
  # The name for object file
  attr_accessor :name
  # The symbol list in object file
  attr_accessor :symbols

  # Object relation
  attr_accessor :static_library

  # Private ivars
  @defined_symbols
  @defined_external_symbols
  @undefined_symbols

  def initialize
    super
    @defined_symbols = nil
    @defined_external_symbols = nil
    @undefined_symbols = nil
  end

  def defined_symbols
    @defined_symbols ||= @symbols.select { |symbol| !symbol.is_undefined? }
  end

  def defined_external_symbols
    @defined_external_symbols ||= @symbols.select { |symbol| !symbol.is_undefined? and symbol.is_external? }
  end

  def undefined_symbols
    @undefined_symbols ||= @symbols.select { |symbol| symbol.is_undefined? }
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

  # Object relation
  attr_accessor :object_file

  def ==(other)
    return @name == other.name
  end

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

    return !(@attribute.include?("non-external") or
      @attribute.include?("weak private external") or
      @attribute.include?("weak external automatically hidden") or
      @attribute.include?("weak external"))
  end
end

class CheckSymbolForStaticLibraryUtility
  attr_accessor :cmd_parser

  attr_accessor :debug
  attr_accessor :verbose
  attr_accessor :conflict
  attr_accessor :dependency
  attr_accessor :arch
  attr_accessor :colored
  attr_accessor :conflict_white_list
  attr_accessor :conflict_black_list_file

  # initialize for new
  def initialize
    self.colored = true

    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER [options]"
      opts.separator ""
      opts.separator "在指定文件夹下递归地检查所有静态库的符号"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -c (检查符号冲突)"
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

      opts.on("-w", "--conflict-white-list x,y", Array, "The static libraries to ignore to check, e.g. libXXX.a or ") do |value|
        self.conflict_white_list = value
      end

      opts.on("-b", "--conflict-black-list-file=path", "Black list file", String) do |value|
        self.conflict_black_list_file = value
      end

      opts.on("-D", "--dependency", "Check symbol dependency") do |toggle|
        self.dependency = toggle
      end

      opts.on("-aArchFlag", "--arch=ArchFlag", "Arch type. Default is arm64") do |value|
        self.arch = value
      end

      opts.on("-C","--[no-]color", "Output with color") do |toggle|
        self.colored = toggle
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

      #Log.d(archs.to_s()) if self.debug

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
    # Version1: too slow when Pods folder has 500+ pods
=begin
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
=end

    symbol_dict = {}
    $static_library_list.each do |static_library|
      Log.v("[Conflict] checking #{static_library.path}") if self.verbose

      static_library.object_files.each do |object_file|
        Log.v("[Conflict] checking object #{object_file.name}") if self.verbose
        defined_external_symbols = object_file.defined_external_symbols
        defined_external_symbols.each do |symbol|
          if symbol_dict[symbol.name].nil?
            symbol_dict[symbol.name] = []
          end

          symbol_dict[symbol.name].append(symbol)
        end
      end
    end

    conflict_black_list = self.conflict_black_list_file ?  File.readlines(self.conflict_black_list_file).map(&:chomp) : []

    count = 0
    symbol_dict.each do |symbol_name, symbol_list|
      next if symbol_list.length < 2

      conflict_symbol_list = []
      symbol_list.each do |symbol|
        static_library_name = symbol.object_file.static_library.file_name
        # Note: not in black list, just skip
        next if conflict_black_list.length > 0 and not conflict_black_list.include?(static_library_name)
        # Note: in white list, just skip
        next if not self.conflict_white_list.nil? and self.conflict_white_list.include?(static_library_name)

        conflict_symbol_list.append(symbol)
      end

      # Note: if conflicted symbols are <= 1, just skip print duplicate symbol
      next if conflict_symbol_list.length <= 1

      count = count + 1
      puts_red "duplicate symbol '#{symbol_name}' in:", self.colored
      conflict_symbol_list.each do |symbol|
        puts_red "- #{symbol.object_file.static_library.path} (#{symbol.object_file.name})", self.colored
      end
      puts ""
    end

    puts "Found #{count} duplicate symbols"
  end

  def check_symbol_dependency
    dependencies = {}
    undefined_symbols = {}
    defined_symbols = {}
    $static_library_list.each do |static_library|
      Log.v("[Dependency] checking #{static_library.path}") if self.verbose
      static_library.object_files.each do |object_file|
        Log.v("[Dependency] checking object #{object_file.name}") if self.verbose

        object_file.undefined_symbols.each do |symbol|
          undefined_symbols[symbol.name] = symbol
        end

        object_file.defined_symbols.each do |symbol|
          defined_symbols[symbol.name] = symbol
        end
      end
    end

    undefined_symbols.each do |name, undefined_symbol|
      defined_symbol = defined_symbols[name]
      # Note: ignore defined and undefined symbols both in the same static library
      if not defined_symbol.nil? and undefined_symbol.object_file.static_library.file_name != defined_symbol.object_file.static_library.file_name
        pair = "#{undefined_symbol.object_file.static_library.file_name},#{defined_symbol.object_file.static_library.file_name}"
        dependencies[pair] ||= []
        dependencies[pair].append(name)
        dependencies[pair].uniq!
      end
    end

    # puts "Found #{dependencies.length} dependencies:"
    # dependencies.sort_by { |key, value| key }.each do |key, symbol_list|
    #   puts "- #{key}"
    #   symbol_list.each do |symbol_name|
    #     puts "  #{symbol_name}"
    #   end
    # end

    puts "```mermaid"
    puts "graph LR"
    dependencies.sort_by { |key, value| key }.each do |key, symbol_list|
      pair = key.split(",")
      puts "#{pair[0]} --> #{pair[1]}"
    end
    puts "```"
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
    # Note: block symbols
    if line.include?("_block_invoke") and line.include?("___")
      separator = '___'
    # Note: OC method symbols
    elsif line.include?(" +[") or line.include?(" -[")
      separator = line.include?("+[") ? '+[' : '-['
    # Note: "000000000000557e (__TEXT,__cstring) non-external l___PRETTY_FUNCTION__.__57-[NSItemProvider(XXXUtils) yy_loadOriginalFileURL]_block_invoke"
    elsif line.include?(" l___")
      separator = 'l___'
    # Note:
    # 0000000000005788 (__DATA,__bss) non-external __ZZ34+[WANMailService(Load) initialize]E9onceToken
    # 0000000000000120 (__TEXT,__text) weak private external ___clang_call_terminate
    elsif line.include?(" __")
      matchData = line.match(/\ __.+$/)
      separator = matchData ? matchData[0] : ' '
    else
      separator = ' '
    end
    symbol.attribute = (line.index(')').nil? || line.rindex(separator).nil?) ? "" : line[line.index(')')+1..line.rindex(separator)].strip
    symbol.name = line.rindex(separator).nil? ? "" : line[line.rindex(separator)..-1].strip

    # if symbol.name.include?("dt_loadOriginalFileURL")
    #   Log.d(line)
    #   Log.d(symbol.name)
    #   Log.d(symbol.attribute)
    #   Log.d(symbol.address)
    #   Log.d(symbol.segment)
    #   puts ""
    # end

    return symbol
  end

  def process_object_file(static_library_path, static_library_object)
    arch = self.arch.nil? ? "arm64" : self.arch
    arch_list = parse_arch_of_static_library(static_library_path)
    if not arch_list.include?(arch)
      Log.w("#{static_library_path} not contains #{arch}", true, self.colored)
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
          current_object.static_library = static_library_object
          object_file_list.append(current_object)
        else
          if not current_object.nil?
            symbol = process_symbol(line)
            if not symbol.nil?
              symbol.object_file = current_object
              current_object.symbols.append(symbol)
              Log.v("add symbol: #{symbol.name}|#{symbol.segment}|#{symbol.attribute}|#{symbol.address}|#{symbol.is_undefined?}|") if self.debug
            else
              Log.w("not create symbol for line: #{line}")
            end
          else
            Log.e("Should never hit this line")
            Log.e("current line: #{line}")
            Log.e("current command: #{command}")
            Log.e("current output: #{output[0..500]}")
            exit(1)
          end
        end
      end

      return object_file_list
    else
      puts "#{stderr}".red if !stderr.empty?
      return []
    end
  end

  def process_static_library(path)
    static_library = WCStaticLibrary.new
    static_library.path = path
    static_library.file_name = File.basename(path)
    static_library.object_files = process_object_file(path, static_library)
    $static_library_list.append(static_library)
  end

  # parse command line
  def run
    self.cmd_parser.parse!

    if ARGV.length != 1
      dump_object(ARGV)
      puts self.cmd_parser.help
      return
    end

    dir_path = ARGV[0]

    if !File.directory?(dir_path)
      puts "[Error] #{dir_path} is not a directory!"
      return
    end

    count = 0
    PathTool.traverse_all_files(dir_path) do |item|
      file_ext = File.extname(item).delete('.')

      if file_ext == 'a'
        count = count + 1
        process_static_library(item)
      elsif file_ext == '' and check_if_static_library(item)
        count = count + 1
        process_static_library(item)
      end
    end

    Log.i("Finish parsing all symbols for #{count} static libraries")

    if self.conflict
      check_symbol_conflict()
    end

    if self.dependency
      check_symbol_dependency()
    end

  end
end

utility = CheckSymbolForStaticLibraryUtility.new
time = Benchmark.measure {
  utility.run
}

puts_magenta "Completed with #{time.real.duration}.", utility.colored
