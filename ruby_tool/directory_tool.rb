#encoding: utf-8
#
# The tool for operate directory

class DirectoryTool

  def self.list_all_folders(dir_path = '.', black_list_of_folder_name = [], list_folder_name = true, need_sort = false)
    folder_name_list = []
    Dir.glob(File.expand_path(dir_path) + '/*') do |path|
      next if path == '.' or path == '..'

      # @see https://stackoverflow.com/questions/10115591/check-if-a-filename-is-a-folder-or-a-file
      if File.directory?(path) && File.exist?(path)
        folder_name = File.basename path

        if not black_list_of_folder_name.include? folder_name
          if list_folder_name
            folder_name_list.push folder_name
          else
            folder_name_list.push path
          end
        end
      end
    end
    need_sort ? folder_name_list.sort! : folder_name_list
  end

end