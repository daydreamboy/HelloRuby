#encoding: utf-8


class RequireTool
  ##
  # use require if needed
  #
  # @param [String]  file_path
  #
  # @@return [Boolean] Return false, if the file path not exists, or not a file path
  #
  def self.require_relative_if_needed(file_path)
    if File.file? file_path
      require_relative file_path
      true
    else
      false
    end
  end
end



