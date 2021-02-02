#encoding: utf-8
#
# The tool for generate key/values in .xcconfig

require_relative 'xcconfig_tool/FRAMEWORK_SEARCH_PATHS'

class XcconfigTool
  def self.list_framework_search_paths(dir_path = '.', black_list_of_folder_name = [], relative_to_dir_path = false)
    FrameworkSearchPaths.list_framework_search_paths(dir_path, black_list_of_folder_name, relative_to_dir_path)
  end
end