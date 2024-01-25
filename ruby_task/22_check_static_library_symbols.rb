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
  attr_accessor :pod_name

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
  attr_accessor :black_list_file
  attr_accessor :dependency_html

  # initialize for new
  def initialize
    self.colored = true
    self.dependency_html = true

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

      opts.on("-b", "--black-list-file=path", "Black list file", String) do |value|
        self.black_list_file = value
      end

      opts.on("-D", "--dependency", "Check symbol dependency") do |toggle|
        self.dependency = toggle
      end

      opts.on("-H", "--[no-]html", "Output as html") do |toggle|
        self.dependency_html = toggle
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

    library_black_list = self.black_list_file ?  File.readlines(self.black_list_file).map(&:chomp) : []

    count = 0
    symbol_dict.each do |symbol_name, symbol_list|
      next if symbol_list.length < 2

      conflict_symbol_list = []
      symbol_list.each do |symbol|
        static_library_name = symbol.object_file.static_library.file_name
        # Note: not in black list, just skip
        next if library_black_list.length > 0 and not library_black_list.include?(static_library_name)
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
    library_black_list = self.black_list_file ?  File.readlines(self.black_list_file).map(&:chomp) : []

    $static_library_list.each do |static_library|
      # Note: not in black list, just skip
      next if library_black_list.length > 0 and not library_black_list.include?(static_library.file_name)

      Log.v("[Dependency] checking #{static_library.path}") if self.verbose
      static_library.object_files.each do |object_file|
        Log.v("[Dependency] checking object #{object_file.name}") if self.verbose

        object_file.undefined_symbols.each do |symbol|
          undefined_symbols[symbol.name] ||= []
          unless undefined_symbols[symbol.name].any? { |s| s.object_file.static_library.pod_name == symbol.object_file.static_library.pod_name }
            undefined_symbols[symbol.name] << symbol
          end
        end

        object_file.defined_symbols.each do |symbol|
          defined_symbols[symbol.name] ||= []
          unless defined_symbols[symbol.name].any? { |s| s.object_file.static_library.pod_name == symbol.object_file.static_library.pod_name }
            defined_symbols[symbol.name] << symbol
          end
        end
      end
    end

    undefined_symbols.each_value do |symbols_list|
      symbols_list.sort_by! { |s| s.object_file.static_library.pod_name }
    end

    defined_symbols.each_value do |symbols_list|
      symbols_list.sort_by! { |s| s.object_file.static_library.pod_name }
    end

    undefined_symbols.each do |name, undefined_symbol_list|
      defined_symbol_list = defined_symbols[name]
      next if defined_symbol_list.nil?
      next if undefined_symbol_list.length == 0

      undefined_symbol_library_list = undefined_symbol_list.map { |s| s.object_file.static_library.pod_name }
      defined_symbol_library_list = defined_symbol_list.map { |s| s.object_file.static_library.pod_name }

      # Note: remove same pod name which both in undefined_symbol_library_list and defined_symbol_library_list
      intersection = undefined_symbol_library_list & defined_symbol_library_list
      undefined_symbol_library_list -= intersection

      # Note: if undefined symbols and defined_symbols are both in the same library, just skip
      next if undefined_symbol_library_list.length == 0

      part1 = undefined_symbol_library_list.join(',')
      part2 = defined_symbol_library_list.join(',')

      pair = "#{part1}~>#{part2}"
      dependencies[pair] ||= []
      dependencies[pair].append(name)
      dependencies[pair].uniq!
    end

    dependencies.each_value do |symbols_list|
      symbols_list.sort_by!
    end

    if self.dependency_html
      lines = []
      dependencies.sort_by { |key, value| key }.each do |key, symbol_list|
        pair = key.split("~>")
        first_part_list = pair[0].split(',')
        second_part_list = pair[1].split(',')

        combinations = first_part_list.product(second_part_list)
        lines += combinations.map { |x, y| "#{x} --> #{y}\n" }
      end

      mermaid = "graph LR\n"
      lines.uniq.sort.each do |item|
        mermaid += item
      end

      html = <<-HEREDOC
<!DOCTYPE html>
<html>
<head>
  <title>Symbol Dependency</title>
</head>
<body>
  <div class="mermaid">
    #{mermaid}
  </div>
  <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
  <script>
    mermaid.initialize({
      startOnLoad: true,
      maxEdges: 1200
    });
  </script>
</body>
</html>
HEREDOC
      puts html
    else
      puts "Found #{dependencies.length} dependencies:"
      dependencies.sort_by { |key, value| key }.each do |key, symbol_list|
        puts "- #{key}"
        symbol_list.each do |symbol_name|
          puts "  #{symbol_name}"
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
    static_library.pod_name = path.match(/Pods\/Release\/([^\/]+)\/[^\/]+/)[1]
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
