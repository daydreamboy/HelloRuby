#encoding: utf-8

require_relative '../ruby_tool/log_tool'
require 'benchmark'
require 'optparse'

def symbolicate(crash_report_path, dSYM_path = nil, output_path = nil, verbose = false, debug = false)

  if not File.exist? crash_report_path or File.directory? crash_report_path
    Log.e("crash report file not found!")
    return
  end

  symbolicatecrash_search_paths = %w(
    /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/PrivateFrameworks/DVTFoundation.framework/symbolicatecrash
    /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/iOSSupport/Library/PrivateFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash
    /Applications/Xcode.app/Contents/Developer/Platforms/AppleTVSimulator.platform/Developer/Library/PrivateFrameworks/DVTFoundation.framework/symbolicatecrash
    /Applications/Xcode.app/Contents/Developer/Platforms/WatchSimulator.platform/Developer/Library/PrivateFrameworks/DVTFoundation.framework/symbolicatecrash
  )

  symbolicatecrash_path = nil
  symbolicatecrash_search_paths.each do |path|
    if File.exist? path
      symbolicatecrash_path = path
      break
    end
  end

  dir_path = File.dirname crash_report_path

  if dSYM_path.nil?
    Dir.glob(dir_path + '/*.dSYM') do |item|
      next if item == '.' or item == '..'

      if File.directory?(item) && File.exist?(item)
        dSYM_path = item
      end
    end
  end

  if dSYM_path.nil?
    Log.e('not found dSYM file', true)
    return
  end

  if symbolicatecrash_path.nil?
    find_paths = `find /Applications/Xcode.app -name symbolicatecrash -type f`
    symbolicatecrash_path = find_paths[0]
  end

  if symbolicatecrash_path.nil?
    Log.e('not found symbolicatecrash script', true)
    return
  end

  if output_path.nil?
    timestamp = Time.now.to_s.gsub!(':', '_').gsub!(' ', '#')
    output_path = File.join dir_path, timestamp
  end

  export_environment = 'export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"'

  command_line = "#{export_environment};#{symbolicatecrash_path} #{crash_report_path} -d #{dSYM_path} > #{output_path}.log"
  if debug or verbose
    Log.v("#{command_line}")
  end
  `#{command_line}`
end

class CmdParser

  attr_accessor :cmd_parser
  attr_accessor :cmd_options

  # initialize for new
  def initialize
    self.cmd_options = {}

    self.cmd_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} PATH/TO/CRASH_FILE [options]"
      opts.separator ""
      opts.separator "对指定文件进行符号化"
      opts.separator "Examples:"
      opts.separator "ruby #{__FILE__ } PATH/TO/CRASH_FILE -v"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |toggle|
        self.cmd_options[:verbose] = toggle
      end

      opts.on("-d", "--[no-]debug", "Run in debug mode") do |toggle|
        self.cmd_options[:debug] = toggle
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

    file_path = ARGV[0]

    if !File.exist?(file_path)
      puts "[Error] #{file_path} is not a file!"
      return
    end

    file_path
  end
end

time = Benchmark.measure {
  parser = CmdParser.new
  file_path = parser.run
  symbolicate(file_path, nil, nil, parser.cmd_options[:verbose], parser.cmd_options[:debug])
}

puts "Completed with #{time.real} s.".magenta