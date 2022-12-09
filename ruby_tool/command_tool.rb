class Command
  ##
  # Get the path of shell command
  #
  # @param [String] cmd the command string
  #
  # @return [String] the path of the command. If not found, return nil
  #
  # @see https://stackoverflow.com/a/5471032
  #
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  ##
  # Check shell command if available
  #
  # @param [String] cmd the command string
  #
  # @return [String] the path of the command. If not found, return nil
  #
  def self.exists?(cmd)
    self.which(cmd) != nil
  end
end