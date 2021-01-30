
require_relative '../directory_tool'

def test_list_folder
  dir_path = '/Users/wesley_chen/6/DingGov-iOS/Pods'
  black_list_of_folder_name = ['Headers', 'Local Podspecs', 'Target Support Files', 'Pods.xcodeproj']
  folder_name_list = DirectoryTool.list_all_folders(dir_path, black_list_of_folder_name, list_folder_name = true, need_sort = true)

  puts folder_name_list
end

test_list_folder