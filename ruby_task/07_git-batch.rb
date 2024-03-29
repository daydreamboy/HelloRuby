#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'json'
require 'open3'
require 'colored2'
require 'benchmark'
require_relative '../ruby_tool/path_tool'
# require_relative '../ruby_tool/dump_tool'

$CONFIG_FILE_PATH = './git-batch_config.json'
$CONFIG_KEY_GIT_REPO_LIST = 'git_repo_list'

class GitBatch
  attr_accessor :globalParser
  attr_accessor :subcommands
  attr_accessor :configuration
  attr_accessor :debugging
  attr_accessor :force_command

  def initialize

    self.subcommands = {
        # Note: configure more subcommand here...
        'log' => {
            :optParser => OptionParser.new do |parser|
              parser.banner = "Usage: #{__FILE__} log [-options] argument"

              parser.on("-d", "--days N", Integer, "The number of recent days") do |days|
                self.subcommands['log'][:options][:days] = days
              end
            end,
            :action => Proc.new do |subcommandline|

              search_current_git_repos do |entry|
                gitDirPath = File.join('./', entry, '.git')
                if File.directory? File.join('./', entry) and File.directory? gitDirPath
                  options = self.subcommands['log'][:options]

                  days = options[:days].nil? ? "7.days" : "#{options[:days]}.days"
                  author = `git config --file #{File.join(gitDirPath, 'config')} user.name`
                  #dump_object(author)
                  if author.empty?
                    author = `git config --global user.name`
                  end

                  author.strip!

                  command = "git --git-dir=#{gitDirPath} log --branches --remotes --since=#{days} --format='%ai %s' --author=#{author} --no-merges"

                  content = nil
                  if self.debugging then
                    puts "[Debug] #{command}"
                  else
                    content = %x{#{command}}
                  end

                  if not content.nil? and content.length > 0
                    content = content.gsub(" +0800", '')
                    puts "\033[32m[#{entry}]\033[0m"
                    puts content
                    puts
                  end

                end
              end
            end,
            :options => {}
        },
        'pull' => {
            # Note: subcommandline, the rest of command line
            :optParser => nil,
            :action => Proc.new do |subcommandline|
              run_git_command subcommandline
            end
        },
        'remove_local_other_branch' => {
            :optParser => nil,
            :action => Proc.new do |subcommandline|
              # Note: subcommand without git
              subcommand = "branch -d `git branch | grep -v \\* | xargs`"
              run_git_command subcommand
            end
        }
    }

    self.globalParser = OptionParser.new do |parser|
      parser.banner = "Usage: #{__FILE__} <git subcommand> [-options] argument"
      parser.separator  ""
      parser.separator  "git批量工具"
      parser.separator  ""
      parser.separator  "示例：ruby /path/to/07_git-batch.rb log -d 10"
      parser.separator  ""
      parser.separator  "内置子命令如下#{self.subcommands.keys}"
      parser.separator  ""
      parser.separator  "查看帮助：ruby /path/to/07_git-batch.rb --help"

      # Boolean switch.
      parser.on("-d", "--[no-]debug", "Run with debug info") do |enabled|
        self.debugging = enabled
      end

      parser.on("-c", "--configuration <path/to/config.json>", String,
                "The configuration json file decides those git repos should apply batch command which placed beside ",
                "the git repos.",
                "The default file path is #{$CONFIG_FILE_PATH} if not use -c option.") do |file_path|
        $CONFIG_FILE_PATH = file_path
      end

      parser.on("-f", "--force [subcommand]", String, "The git subcommand to force execute, e.g. git-batch.rb -f checkout -- -b new_branch") do |command|
        self.force_command = command
      end
    end
  end

  def run_git_command(subcommandline)
    search_current_git_repos do |entry|
      path = PathTool.get_real_path(File.join('./', entry)).strip
      # Note: check folder or a soft link for folder
      if File.directory?(path) and File.directory?(File.join(path, '.git'))
        cmd = "cd #{path} && git #{subcommandline}"
        # dump_object(cmd)
        puts "\033[32m[#{entry}]\033[0m"

        if self.debugging then
          puts "[Debug] #{cmd}"
        else
          stdout, stderr, status = Open3.capture3("#{cmd}")
          if status.success?
            puts stdout
          else
            puts "\033[31m#{stdout}\033[0m"
            puts "\033[31m#{stderr}\033[0m"
          end
        end

        puts ""
      end
    end
  end

  def search_current_git_repos
    Dir.entries('./').select do |entry|
      next if %w{. .. ,,}.include? entry

      if not self.configuration.nil? and not self.configuration[$CONFIG_KEY_GIT_REPO_LIST].nil?
        next if not self.configuration[$CONFIG_KEY_GIT_REPO_LIST].include? entry
      end

      yield entry if block_given?
    end
  end

  def run
    if ARGV.empty?
      puts globalParser.help
      return
    end

    # Note: parse first level command
    self.globalParser.order!

    config_file_path = File.join '.', $CONFIG_FILE_PATH
    if File.exist? config_file_path
      self.configuration = JSON.parse File.read config_file_path
      if self.debugging
        puts "[Debug] #{self.configuration}"
        puts ""
      end
    end

    subcommandline = ARGV.join(' ')
    subcommand = ARGV.shift

    if not self.force_command.nil?
      run_git_command [self.force_command, subcommandline].join(' ')
      return
    end

    if self.subcommands[subcommand].nil?
      puts "\033[31m[Error] #{subcommand} command not available. #{ self.subcommands.keys.join(', ') } are available.\033[0m"
      puts
      puts globalParser.help
      return
    else
      if not self.subcommands[subcommand][:optParser].nil?

        # Note: parse second level command if needed
        self.subcommands[subcommand][:optParser].order!
      end

      self.subcommands[subcommand][:action].call(subcommandline)
    end
  end
end

time = Benchmark.measure {
  GitBatch.new.run
}

puts "Completed with #{time.real} s.".magenta
