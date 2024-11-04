#!/usr/bin/env ruby
#encoding: utf-8

<<-DOC
The nm batch tool for searching symbols in a directory recursively
DOC

require 'optparse'
require 'open3'
require 'colored2'
require 'benchmark'

# require_relative '../ruby_tool/ruby_tools'
require_relative '../ruby_tool/ext_numeric'

$default_exclude_list = %w(
am
amr
bin
c
caf
car
cer
cpp
data
gif
gypi
h
hpp
html
in
ipp
js
json
jpg
keys
markdown
pch
pdf
plist
png
py
race
rb
sh
strings
swiftdoc
swiftinterface
swiftmodule
swiftsourceinfo
ttf
txt
m4a
m
md
modulemap
mm
mnn
mp3
nib
wav
webp
wvc
xcodeproj
xib
xml
zip
)

$default_ignore_folder_list = %w(
Pods.xcodeproj
_CodeSignature
Target Support Files
)

class NmUtility

  attr_accessor :cmd_parser
  attr_accessor :cmd_options
  attr_accessor :symbol_list

  # initialize for new
  def initialize
    self.cmd_options = {}

    self.cmd_parser = OptionParser.new do |opts|
      self.symbol_list = [
        "___swift_reflection_version",
        # Note: only static library have this symbol, so not use it
        #"l_llvm.swift_module_hash",
        # "__swift_FORCE_LOAD_$_swiftCoreFoundation",
        # "__swift_FORCE_LOAD_$_swiftDarwin",
        # "__swift_FORCE_LOAD_$_swiftDispatch",
        # "__swift_FORCE_LOAD_$_swiftFoundation",
        # "__swift_FORCE_LOAD_$_swiftObjectiveC",
      ]

      opts.banner = "Usage: #{__FILE__} PATH/TO/FOLDER -s symbol1,symbol2,... [options]"
      opts.separator ""
      opts.separator "在指定目录nm搜索特定的符号"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -v"
      opts.separator "ruby #{__FILE__ } PATH/TO/FOLDER -d"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |toggle|
        self.cmd_options[:verbose] = toggle
      end

      opts.on("-d", "--[no-]debug", "Run in debug mode") do |toggle|
        self.cmd_options[:debug] = toggle
      end

      opts.on("-r", "--[no-]color", "Run in color mode") do |toggle|
        self.cmd_options[:colored] = toggle
      end

      opts.on("-s", "--[no-]sort", "Sort result") do |toggle|
        self.cmd_options[:sorted] = toggle
      end

      opts.on("-i", "--include_exts suffix1,suffix2,...", Array, "included files with ext") do |include_list|
        self.cmd_options[:include_list] = include_list
      end

      opts.on("-e", "--exclude_exts suffix1,suffix2,...", Array, "excluded files with ext") do |exclude_list|
        self.cmd_options[:exclude_list] = exclude_list
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
    symbol_list = Array(self.symbol_list)

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
    colored = self.cmd_options[:colored].nil? ? true : self.cmd_options[:colored]
    sorted = self.cmd_options[:sorted]
    sorted_result = []

    if !File.directory?(dir_path)
      puts "[Error] #{dir_path} is not a directory!"
      return
    end

    #puts self.cmd_options

    # Note: not use `/**/*` instead of `**{,/*/**}/*`, so Dir.glob can search following the linking folders
    # @see https://stackoverflow.com/a/2724048
    all_paths = Dir.glob(dir_path + '/**{,/*/**}/*').uniq
    all_paths.each do |item|
      next if item == '.' or item == '..'

      if !File.directory?(item) && File.exist?(item)
        # @see https://stackoverflow.com/questions/16902083/exclude-the-from-a-file-extension-in-rails
        file_ext = File.extname(item).delete('.')
        if !exclude_list.empty? and exclude_list.include?(file_ext)
          next
        end

        # Note: check dir_path/XXX or dir_path/.../XXX
        if $default_ignore_folder_list.any? { |ignore_folder| item.include?("#{ignore_folder}") }
          next
        end

        #puts "#{item}" if debug

        if include_list.empty? or include_list.include?(file_ext) or file_ext == ''
          # Note: lookup symbols for every file
          symbol_list.each do |symbol|
            command = "nm -m \"#{item}\" 2>/dev/null | grep '#{symbol}'"
            if debug
              puts colored ? command.cyan : command
              next
            end

            stdout, stderr, status = Open3.capture3(command)

            if status.success?
              message = "Find symbol #{symbol} in #{item}"
              if sorted
                sorted_result.append(message)
              else
                puts colored ? message.green : message
              end

              if verbose and !stdout.empty?
                puts colored ? "#{stdout}".blue : "#{stdout}"
              end
              # Note: detect one Swift symbol just stop, and to check next binary file
              break
            else
              if verbose and !stderr.empty?
                puts colored ? "#{stderr}".red : "#{stderr}"
              end
            end
          end

        end
      end
    end

    if sorted and !sorted_result.empty?
      sorted_result.sort!.each do |message|
        puts colored ? message.green : message
      end
    end
  end
end

parser = NmUtility.new
# @see https://stackoverflow.com/a/29166478
time = Benchmark.measure {
  parser.run
}

message = "Completed with #{time.real.duration}."
puts parser.cmd_options[:colored] ? message.magenta : message
