#encoding: utf-8


class RequireTool
  ##
  # use require if needed
  #
  # @param [String]  relative_file_path, which without file extension
  #
  # @@return [Boolean] Return false, if the file path not exists, or not a file path
  #
  def self.require_relative_if_needed(relative_file_path)
    # Note: require_relative implementation, see
    # https://github.com/steveklabnik/require_relative/blob/master/lib/require_relative.rb
    base_file_path = caller.first.split(/:\d/,2).first

    raise LoadError, "require_relative is called in #{$1}" if /\A\((.*)\)/ =~ base_file_path

    resolved_file_path = File.expand_path(relative_file_path, File.dirname(base_file_path))

    if not File.extname(resolved_file_path).equal?('.rb')
      dir_path = File.dirname(resolved_file_path)
      resolved_file_path = "#{File.join(dir_path, File.basename(resolved_file_path))}.rb"
    end

    if File.file? resolved_file_path
      require resolved_file_path
      true
    else
      false
    end
  end
end



