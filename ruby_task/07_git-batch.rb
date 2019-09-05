#!/usr/bin/env ruby

#encoding: utf-8

require 'optparse'
require 'json'
# require_relative '../ruby_tool/dump_tool'

$CONFIG_FILE_PATH = './git-batch_config.json'
$CONFIG_KEY_GIT_REPO_LIST = 'git_repo_list'

class GitBatch
  attr_accessor :global
  attr_accessor :subcommands
  attr_accessor :configuration
  attr_accessor :debugging

  def initialize
    self.configuration = {
        'git_repo_list' => [
            'MPDataSDKExtention'
        ]
    }
    self.global = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} <git subcommand> [-options] argument"
      opts.separator  ""
      opts.separator  "git批量工具"
      opts.separator  ""
      opts.separator  "示例：ruby /path/to/07_git-batch.rb log -d 10"
      opts.separator  ""
      opts.separator  "查看帮助：ruby /path/to/07_git-batch.rb --help"
    end

    # Boolean switch.
    self.global.on("-d", "--[no-]debug", "Run with debug info") do |enabled|
      self.debugging = enabled
    end

    self.subcommands = {
        # Note: configure more subcommand here...
        'log' => {
            :optParser => OptionParser.new do |opts|
              opts.banner = "Usage: #{__FILE__} log [-options] argument"

              opts.on("-d", "--days N", Integer, "The number of recent days") do |days|
                self.subcommands['log'][:options][:days] = days
              end
            end,
            :action => Proc.new do
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
        }
    }
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
      puts global.help
      return
    end

    config_file_path = File.join '.', $CONFIG_FILE_PATH
    if File.exist? config_file_path
      self.configuration = JSON.parse File.read config_file_path
    end

    self.global.order!
    subcommandline = ARGV.join(' ')
    subcommands = ARGV.shift

    if self.subcommands[subcommands].nil?
      search_current_git_repos do |entry|
        if File.directory? File.join('./', entry) and File.directory? File.join('./', entry, '.git')
          cmd = "cd #{entry} && git #{subcommandline}"
          # dump_object(cmd)
          puts "\033[32m[#{entry}]\033[0m"

          if self.debugging then
            puts "[Debug] #{cmd}"
          else
            content = `#{cmd}`
            puts content
          end

          puts
        end
      end
    else
      self.subcommands[subcommands][:optParser].order!

      self.subcommands[subcommands][:action].call()
    end
  end
end

GitBatch.new.run