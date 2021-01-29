

def list_all_folders(dir_path = '.', black_list_of_folder_name = [], list_folder_name = true)
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
  folder_name_list
end

def list_framework_search_paths(dir_path = '.', black_list_of_folder_name = [])
  search_path_list = []
  Dir.glob(File.expand_path(dir_path) + '/*') do |path|
    next if path == '.' or path == '..'

    if File.directory?(path) && File.exist?(path)
      folder_name = File.basename path

      if not black_list_of_folder_name.include? folder_name
        Dir.glob("#{path}/**/*.framework") do |framework_path|
          if File.directory?(framework_path) && File.exist?(framework_path)
            #search_path = File.basename framework_path
            search_path_list.push framework_path
          end
        end
      end
    end
  end
  search_path_list
end

def test_list_folder
  dir_path = '/Users/wesley_chen/6/DingGov-iOS/Pods'
  black_list_of_folder_name = ['Headers', 'Local Podspecs', 'Target Support Files', 'Pods.xcodeproj']
  folder_name_list = list_all_folders(dir_path, black_list_of_folder_name)

  framework_search_path = ''
  folder_name_list.each do |name|
    framework_search_path += "\"${PODS_ROOT}/#{name}\" "
  end

  puts framework_search_path
end

def test_framework_search_paths
  dir_path = '/Users/wesley_chen/6/DingGov-iOS/Pods'
  black_list_of_folder_name = ['Headers', 'Local Podspecs', 'Target Support Files', 'Pods.xcodeproj']
  search_path_list = list_framework_search_paths(dir_path, black_list_of_folder_name)

  puts search_path_list

  # framework_search_path = ''
  # search_path_list.each do |name|
  #   framework_search_path += "\"${PODS_ROOT}/#{name}\" "
  # end

  # puts framework_search_path
end

test_framework_search_paths
