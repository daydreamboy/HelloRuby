#encoding: utf-8
#
# The tool for generate key/values in .xcconfig

require 'pathname'

class FrameworkSearchPaths

  ##
  # Get a list of the folder paths which the framework located in
  #
  # @param [String]  dir_path the path contains frameworks, e.g. `Pods` folder path
  # @param [Array]  black_list_of_folder_name the black list for ignore the folder name
  # @param [Bool]  relative_to_dir_path true if get relative path which base on the `dir_path`, false if get
  # absolute path. Default is false
  #
  # @return [Array] the path contains frameworks
  #
  # @discussion This method generates value For FRAMEWORK_SEARCH_PATHS
  #
  def self.list_framework_search_paths(dir_path = '.', black_list_of_folder_name = [], relative_to_dir_path = false)
    search_path_list = []
    Dir.glob(File.expand_path(dir_path) + '/*') do |path|
      next if path == '.' or path == '..'

      if File.directory?(path) && File.exist?(path)
        folder_name = File.basename path

        if not black_list_of_folder_name.include? folder_name
          Dir.glob("#{path}/**/*.framework") do |framework_path|
            if File.directory?(framework_path) && File.exist?(framework_path)
              search_path = File.dirname framework_path
              if relative_to_dir_path
                search_path_list.push Pathname.new(search_path).relative_path_from(Pathname.new(dir_path)).to_s
              else
                search_path_list.push search_path
              end
            end
          end
        end
      end
    end
    search_path_list.uniq!.sort!
  end
end