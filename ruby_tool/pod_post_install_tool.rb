#encoding: utf-8

require 'colored2'
require 'pathname'
require 'fileutils'
require 'optparse'
require 'json'
require 'xcodeproj'
require 'benchmark'
require 'optparse'
require 'cocoapods'
require_relative './log_tool'
require_relative './require_tool'
# For debug
require_relative './dump_tool'

class PodPostInstallTool
  attr_accessor :globalParser
  attr_accessor :subcommands
  attr_accessor :debugging
  attr_accessor :force_command

  def initialize

    self.subcommands = {
      # Note: configure more subcommand here...
      'addSourceFile' => {
        :optParser => OptionParser.new do |parser|
          parser.banner = "Usage: #{__FILE__} addSourceFile [-options] argument"

          parser.on("-p", "--path=path/to/Podfile", String, "[Required] The path of Podfile") do |path|
            self.subcommands['addSourceFile'][:options][:path] = path
          end
          parser.on("-t", "--target=name", String, "[Required] The target which add source files to") do |target|
            self.subcommands['addSourceFile'][:options][:target] = target
          end
          parser.on("-g", "--group=path/to/folder", String, "[Required] The group folder which add to Xcode project") do |group|
            self.subcommands['addSourceFile'][:options][:group] = group
          end
        end,
        :action => Proc.new do |subcommand, subcommandline, subcommandSetting|
          self.validate_options(subcommandSetting[:optParser], [:path, :target, :group], subcommandSetting[:options])
          self.handleSubcommandAddSourceFile(subcommandSetting[:options][:path], subcommandSetting[:options][:target])
        end,
        :options => {}
      }
    }

    self.globalParser = OptionParser.new do |parser|
      parser.banner = "Usage: #{__FILE__} <subcommand> [-options] argument"
      parser.separator  ""
      parser.separator  "在pod install之后执行本脚本，用于修改Xcode工程等"
      parser.separator  ""
      parser.separator  "示例："
      parser.separator  "$ pod install"
      parser.separator  "$ ruby /path/to/#{__FILE__} addSourceFile -path path/to/Podfile"
      parser.separator  ""
      parser.separator  "内置子命令: #{self.subcommands.keys}"
      parser.separator  ""
      parser.separator  "查看帮助：ruby /path/to/07_git-batch.rb --help"

      # Boolean switch.
      parser.on("-d", "--[no-]debug", "Run with debug info") do |enabled|
        self.debugging = enabled
      end
    end
  end

  def run
    if ARGV.empty?
      puts globalParser.help
      return
    end

    # Note: parse first level command
    self.globalParser.order!

    subcommandline = ARGV.join(' ')
    subcommand = ARGV.shift

    if self.subcommands[subcommand].nil?
      Log.e("#{subcommand} command not available. #{ self.subcommands.keys } are available.")
      puts ""
      puts globalParser.help
      return
    else
      if not self.subcommands[subcommand][:optParser].nil?
        # Note: parse second level command if needed
        begin
          self.subcommands[subcommand][:optParser].order!
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument
          Log.e($!.to_s)
          puts globalParser.help
          exit
        end
      end

      self.subcommands[subcommand][:action].call(subcommand, subcommandline, self.subcommands[subcommand])
    end
  end

  ##
  # Validate options for parser
  #
  # @param [OptionParser] parser
  #                       The parser
  # @param [Array] mandatory
  #                The list for mandatory option name
  # @param [Hash] options
  #               The options
  #
  # @see https://stackoverflow.com/questions/1541294/how-do-you-specify-a-required-switch-not-argument-with-ruby-optionparser/1542658#1542658
  #
  def validate_options(parser, mandatory, options)
    begin
      missing = mandatory.select{ |param| options[param].nil? }
      unless missing.empty?
        raise OptionParser::MissingArgument.new(missing.join(', '))
      end
    rescue OptionParser::MissingArgument
      Log.e($!.to_s)
      puts parser.help
      exit
    end
  end

  def handleSubcommandAddSourceFile(podfile_path, target_name)
    if not File.exist?(File.expand_path(podfile_path))
      Log.e "Podfile not exists at #{podfile_path}"
      return
    end
    podfile_dir = File.expand_path File.dirname(podfile_path)
    xcodeproj_files = Dir.glob("#{podfile_dir}/*.xcodeproj")
    if xcodeproj_files.length != 1
      Log.e "expect only a .xcodeproj, but multiple .xcodeproj files at #{podfile_dir}"
      return
    end

    project_path = xcodeproj_files[0]

    project = Xcodeproj::Project.open(project_path)
    project.targets.each do |target|
      # # Note: skip the target not match target_name
      if target.name != target_name
        next
      end

    end

    project.save(project_path)
  end
end

time = Benchmark.measure {
  puts "CocoaPods version: #{Pod::VERSION}"
  PodPostInstallTool.new.run
}

puts "Completed with #{time.real} s.".magenta

