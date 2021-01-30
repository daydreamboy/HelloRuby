

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
            search_path_list.push File.dirname(framework_path)
          end
        end
      end
    end
  end
  search_path_list
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
