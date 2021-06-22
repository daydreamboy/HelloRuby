#!/usr/bin/env ruby -w


require 'optparse'
require 'benchmark'
require 'colored2'
require 'open3'
require_relative '../ruby_tool/log_tool'

class Subcommand_remove_local_other_branch

  @@options = {}

  def self.real_command
    'git branch -d `git branch | grep -v \\* | xargs`'
  end

  def self.create_subcommand
    return OptionParser.new do |opts|
      opts.banner = "Usage: remove_local_other_branch [options] [path/to/git_repo]"
      opts.separator ""
      opts.separator "Examples:"
      opts.separator "ruby 13_git-alias.rb remove_local_other_branch [options] [path/to/git_repo]"
      opts.separator ""

      opts.on("-v", "--verbose", "Run verbosely") do |v|
        @@options[:verbose] = v
      end

      opts.on('-d', '--debug', 'Execute in debug mode and print debug info') do |v|
        @@options[:debug] = v
      end
    end
  end

  def self.execute_subcommand(argv_list)

    git_repo_path = argv_list.empty? ? '.' : argv_list[0]

    command = "cd #{git_repo_path}; git branch -d `git branch | grep -v \\* | xargs`"
    #command = "cd #{git_repo_path}; git branch | grep -v \\* | xargs"
    if @@options[:debug]
      Log.d "argv_list: #{argv_list}"
      Log.d "command: #{command}"
    else
      stdout, stderr, status = Open3.capture3(command)

      if status.success?
        if !stdout.empty?
          Log.v "#{command}" if @@options[:verbose]
          puts "#{stdout}"
        else
          puts "No stdout from `#{command}`"
        end
      else
        if !stderr.empty?
          Log.e "#{stderr}"
        else
          puts "No stderr from `#{command}`"
        end
      end
    end
  end
end


options = {}

subtext = <<HELP
Commonly used subcommand are:
   remove_local_other_branch : remove all local other branches except the current branch
   baz    : does something fantastic
See 'opt.rb SUBCOMMAND --help' for more information on a specific subcommand.
HELP

parser = OptionParser.new do |opts|
  opts.program_name = 'git-alias'
  opts.banner = "Usage: opt.rb [options] [subcommand [options]] arguments"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on('-l', '--list', 'Show real git command for shortcuts') do |v|
    options[:list] = v
  end

  opts.separator ""
  opts.separator subtext
end
#end.parse!

subcommands = {
    'remove_local_other_branch' => Subcommand_remove_local_other_branch,
}

parser.order!
subcommand = ARGV.shift

if options[:list]
  puts 'The available shortcuts are:'
  subcommands.each {|key, value|
    puts "#{key} -> `#{value.real_command}`"
  }
  return
end

if subcommand.nil?
  puts parser.help
  return
end

time = Benchmark.measure {
  subcommands[subcommand].create_subcommand.order!
  subcommands[subcommand].execute_subcommand(ARGV)
}

puts "Completed with #{time.real} s.".magenta
