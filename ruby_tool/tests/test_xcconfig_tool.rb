require_relative '../xcconfig_tool'

def test_framework_search_paths
  dir_path = '/Users/wesley_chen/6/DingGov-iOS/Pods'
  black_list_of_folder_name = ['Headers', 'Local Podspecs', 'Target Support Files', 'Pods.xcodeproj']
  search_path_list = XcconfigTool.list_framework_search_paths(dir_path, black_list_of_folder_name, true)

  #puts search_path_list

  framework_search_path = ''
  search_path_list.each do |name|
    framework_search_path += "\"${PODS_ROOT}/#{name}\" "
  end

  puts framework_search_path
end

test_framework_search_paths