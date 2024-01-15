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

$default_ext_list = %w(
a
framework
)

class CheckSymbolForStaticLibraryUtility
  attr_accessor :cmd_parser
  attr_accessor :cmd_options

  attr_accessor :debug
  attr_accessor :verbose

  # initialize for new
  def initialize
    self.cmd_options = {}

    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER [options]"
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

      # opts.on("-i", "--include_exts suffix1,suffix2,...", Array, "included files with ext") do |include_list|
      #   self.cmd_options[:include_list] = include_list
      # end
      #
      # opts.on("-e", "--exclude_exts suffix1,suffix2,...", Array, "excluded files with ext") do |exclude_list|
      #   self.cmd_options[:exclude_list] = exclude_list
      # end
      #
      # opts.on("-s", "--symbol_list symbol1,symbol2,...", Array, "the symbols to search") do |symbol_list|
      #   self.cmd_options[:symbol_list] = symbol_list
      # end
    end
  end

  def check_if_static_library(file_path)
    command = "lipo -info \"#{file_path}\" 2>/dev/null"
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

    puts stdout.cyan if self.verbose

    if stdout.include?("fat file") or stdout.include?("Non-fat file")
      return true
    else
      return false
    end
  end

  def parse_arch_of_library(file_path)
    command = "lipo -info \"#{file_path}\""
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success? && !stdout.empty?
      puts stdout.cyan if self.verbose

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

  def create_single_arch_library(file_path, arch, output)
    #lipo XXXModule -thin arm64 -output XXXModule_arm64.a
    command = "lipo \"#{file_path}\" -thin #{arch} -output \"#{output}\""
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      return true
    else
      puts "#{stderr}".red if !stderr.empty?

      return false
    end
  end

  def extract_object_file(file_path)
    #ar x XXXModule_arm64.a
    command = "cd \"#{File.dirname(file_path)}\"; ar x \"#{File.basename(file_path)}\""
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      return true
    else
      puts "#{stderr}".red if !stderr.empty?

      return false
    end
  end

  def test_object_file(file_path)
    # nm YYY.o | grep -e "_objc_msgSend\\$"
    command = "nm \"#{file_path}\" | grep -e \"_objc_msgSend\\\\$\""
    puts command.cyan if self.debug

    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      puts "#{stdout}"
      return true
    else
      puts "#{stderr}".red if !stderr.empty?

      return false
    end
  end

  ##
  # Find static library binary files in framework
  #
  # @return [Void] Get path list for
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

  # parse command line
  def run
    self.cmd_parser.parse!

    if ARGV.length != 1
      puts self.cmd_parser.help
      return
    end

    dir_path = ARGV[0]

    ext_list = $default_ext_list
    self.debug = self.cmd_options[:debug]
    self.verbose = self.cmd_options[:verbose]

    if !File.directory?(dir_path)
      puts "[Error] #{dir_path} is not a directory!"
      return
    end

    # Note: only search target under the one level of the dir_path
    Dir.glob(dir_path + '/*') do |item|
      next if item == '.' or item == '..'

      # @see https://stackoverflow.com/questions/16902083/exclude-the-from-a-file-extension-in-rails
      file_ext = File.extname(item).delete('.')
      if ext_list.empty? or file_ext == ''
        next
      end

      if file_ext == 'a' or file_ext == 'framework'
        item = File.join(item, File.basename(item, File.extname(item))) if file_ext == 'framework'
        result = check_if_static_library(item)
        Log.d(result) if self.debug

        if result == false
          next
        end

        archs = parse_arch_of_library(item)
        if archs.empty?
          next
        end

        temp_dir = File.join(dir_path, "#{File.basename(item)}_" + Time.now.to_s.gsub!(/:/, '-'))
        FileUtils.mkdir_p temp_dir

        archs.each { |arch|
          suffix = File.extname(item)
          arch_dir = File.join(temp_dir, "#{arch}")
          FileUtils.mkdir_p arch_dir
          output = File.join(arch_dir, File.basename(item, suffix) + "_#{arch}" + suffix)
          result = create_single_arch_library(item, arch, output)
          if result == false
            next
          end

          result = extract_object_file(output)
          if result == false
            next
          end

          puts "#{File.basename(item)} (#{arch})"

          Dir.glob(arch_dir + '/*.o').sort().each do |object_file|
            next if object_file == '.' or object_file == '..'

            puts "#{File.basename(object_file)} (#{arch}):"
            test_object_file(object_file)
          end

          puts "------"
        }

      end

    end

  end
end

# @see https://stackoverflow.com/a/29166478
time = Benchmark.measure {
  CheckSymbolForStaticLibraryUtility.new.run
}

puts "Completed with #{time.real.duration}.".magenta