#encoding: utf-8

require 'open3'
require_relative './log_tool'

class PathTool
  def self.check_alias?(path, debug=false)
    stdout, stderr, status = Open3.capture3("file #{path} 2>/dev/null | grep -q ': MacOS Alias file$'")
    if status.success?
      return true
    else
      return false
    end
  end

  def self.check_symlink?(path)
    return File.symlink?(path)
  end

  def self.get_real_path(path, debug=false)
    if check_alias?(path, debug) && File.exist?(File.join(File.dirname(__FILE__), 'alias_tool'))
      command_tool = File.join(File.dirname(__FILE__), 'alias_tool')
      if debug
        Log.d(command_tool)
      end
      stdout, stderr, status = Open3.capture3("#{command_tool} #{path}")
      if status.success?
        return stdout
      else
        return path
      end
    elsif check_symlink?(path)
      return File.realpath(path)
    else
      return File.expand_path(path)
    end
  end
end

