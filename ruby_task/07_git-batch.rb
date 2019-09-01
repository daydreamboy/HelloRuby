#encoding: utf-8

require 'optparse'
# require_relative '../ruby_tool/dump_tool'

class GitBatch
  attr_accessor :global
  attr_accessor :subcommands

  def initialize
    self.global = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} <git subcommand> [-options] argument"
      opts.separator  ""
      opts.separator  "git批量工具"
      opts.separator  ""
      opts.separator  "示例：ruby /path/to/07_git-batch.rb log -d 10"
      opts.separator  ""
      opts.separator  "查看帮助：ruby /path/to/07_git-batch.rb --help"
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
              Dir.entries('./').select do |entry|
                next if %w{. .. ,,}.include? entry
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
                  #dump_object(command)

                  content = %x{#{command}}

                  if content.length > 0
                    content = %x{#{command}}.gsub(" +0800", '')
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

  def run
    if ARGV.empty?
      puts global.help
      return
    end

    self.global.order!
    subcommandline = ARGV.join(' ')
    subcommands = ARGV.shift

    if self.subcommands[subcommands].nil?
      Dir.entries('./').select do |entry|
        next if %w{. .. ,,}.include? entry
        if File.directory? File.join('./', entry) and File.directory? File.join('./', entry, '.git')
          cmd = "cd #{entry} && git #{subcommandline}"
          # dump_object(cmd)
          puts "\033[32m[#{entry}]\033[0m"
          `#{cmd}`
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