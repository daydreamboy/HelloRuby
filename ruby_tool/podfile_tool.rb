require 'colored2'
require 'pathname'
require 'fileutils'
require 'optparse'
require 'json'
require_relative './log_tool'

##
# A tool used in Podfile
#
class PodfileTool
  ##
  # change xcconfig files of the .xcodeproj which located in Podfile's folder
  #
  # @param [String]  podfile_path
  #        Pass __FILE__ usually
  # @param [String]  config_map
  #        The key which in xcconfig file. The supported keys are 'HEADER_SEARCH_PATHS', 'LIBRARY_SEARCH_PATHS', 'FRAMEWORK_SEARCH_PATHS',
  #        'OTHER_LDFLAGS', 'OTHER_CFLAGS'
  #        The value which is hash, and the keys are symbols:
  #        HEADER_SEARCH_PATHS/LIBRARY_SEARCH_PATHS/FRAMEWORK_SEARCH_PATHS -> :path_to_add/:path_to_remove
  #        OTHER_LDFLAGS -> :library_to_add/:library_to_remove/:framework_to_remove/:framework_to_add
  #        OTHER_CFLAGS -> :flag_to_add/:flag_to_remove
  # @param [Array]  target_list
  #        The xcconfig belong which target. If nil, will change xcconfig for all targets
  # @param [Bool]  debug
  #        If true, to print debug log
  # @return [None]
  #
  # @example
  #
  # post_install do |installer|
  #   PodfileTool.modify_xcconfig_attrs!(__FILE__, {
  #       'HEADER_SEARCH_PATHS' => {
  #           :path_to_add => [
  #               "${PODS_ROOT}/Headers/Public/DTIMAPI-DG/DTIMAPI",
  #               "${PODS_ROOT}/Headers/Public/DTIMBasicModule-DG/DTIMBasicModule"
  #           ],
  #           :path_to_remove => [
  #               "${PODS_CONFIGURATION_BUILD_DIR}/PodfileScript/PodfileScript.framework/Headers"
  #           ]
  #       },
  #       'OTHER_LDFLAGS' => {
  #           :library_to_add => [
  #               "MyLibrary1",
  #               "MyLibrary2",
  #           ],
  #           :framework_to_add => [
  #               "MyFramework1",
  #               "MyFramework2",
  #           ],
  #           :framework_to_remove => [
  #               "PodfileScript"
  #           ]
  #       }
  #   }, ["PodfileScript_Example"], true)
  # end
  #
  def self.modify_xcconfig_attrs!(podfile_path, config_map, target_list = nil, debug = false)

    if config_map.length == 0
      return
    end

    podfile_dir = File.expand_path File.dirname(podfile_path)
    xcodeproj_files = Dir.glob("#{podfile_dir}/*.xcodeproj")
    if xcodeproj_files.length != 1
      Log.e "expect only a .xcodeproj, but multiple .xcodeproj files at #{podfile_dir}"
      return
    end

    project_path = xcodeproj_files[0]

    project = Xcodeproj::Project.open(project_path)
    project.targets.each do |target|
      # Note: skip the target in the target_list
      if Array(target_list).length > 0 && !target_list.include?(target.name)
        next
      end

      target.build_configurations.each do |xcconfig|
        if xcconfig.base_configuration_reference.nil?
          next
        end

        xcconfig_pathname = xcconfig.base_configuration_reference.real_path
        xcconfig_name = xcconfig.base_configuration_reference.name
        if File.exists?(xcconfig_pathname)
          Log.v("<<<Start modify xcconfig for `#{xcconfig_name}`")
          config = Xcodeproj::Config.new(File.new(xcconfig_pathname.to_path))
          change_xcconfig_attrs!(config, config_map, debug)
          config.save_as(xcconfig_pathname)
          Log.v(">>>End modify xcconfig for `#{xcconfig_name}`")
        end
      end
    end
    project.save(project_path)
  end

  def self.change_other_ldflags!(config, key, change_map, debug = false)
    library_to_remove = change_map[:library_to_remove]
    library_to_add = change_map[:library_to_add]

    framework_to_remove = change_map[:framework_to_remove]
    framework_to_add = change_map[:framework_to_add]

    # @see https://stackoverflow.com/a/18894072
    # @see https://stackoverflow.com/a/15649423
    config.libraries.subtract(Array(library_to_remove).to_set)
    config.libraries.merge(Array(library_to_add).to_set)

    config.frameworks.subtract(Array(framework_to_remove).to_set)
    config.frameworks.merge(Array(framework_to_add).to_set)
  end

  def self.change_header_search_path!(config, key, change_map, debug = false)
    path_to_remove = change_map[:path_to_remove]
    path_to_add = change_map[:path_to_add]

    value = config.attributes[key]
    Log.v("Change before #{key}: #{value}", debug)

    if not value.nil?
      paths = value.split(' ').
          map {|item| item.strip}.
          reject {|item| item.empty?}.
          map {|item|
            item.gsub!(/\A"|"\z/, '')
            item.gsub!(/\A'|'\z/, '')
            item
          }
    else
      paths = []
    end

    Array(path_to_remove).each do |path|
      paths.delete(path)
    end

    Array(path_to_add).each do |path|
      paths.push(path)
    end

    paths.delete('$(inherited)')
    paths.map! {|item| '"' + item + '"'}

    config.attributes[key] = paths.insert(0, '$(inherited)').uniq.join(' ')

    Log.v("Change after #{key}: #{config.attributes[key]}", debug)
  end

  def self.change_framework_or_library_search_path!(config, key, change_map, debug = false)
    path_to_remove = change_map[:path_to_remove]
    path_to_add = change_map[:path_to_add]

    value = config.attributes[key]
    if value.nil?
      if not path_to_add.nil?
        path_to_add.map! do |item|
          '"' + item + '"'
        end

        config.attributes[key] = path_to_add.insert(0, '$(inherited)').uniq.join(' ')
      end
    else
      parts = value.split

      # @see https://stackoverflow.com/questions/30276873/ruby-wrap-each-element-of-an-array-in-additional-quotes
      parts.map! do |item|
        item.gsub!(/\A"|"\z/, '')
        item.gsub!(/\A'|'\z/, '')
        item
      end.reject! do |item|
        if path_to_remove.nil?
          false
        else
          path_to_remove.include? item
        end
      end

      if not path_to_add.nil?
        parts = parts + path_to_add
      end

      parts.map! do |item|
        if item != '$(inherited)'
          '"' + item + '"'
        else
          item
        end
      end

      config.attributes[key] = parts.uniq.join(' ')
    end
  end

  def self.change_other_cflags!(config, key, change_map, debug = false)
    flag_to_remove = change_map[:flag_to_remove]
    flag_to_add = change_map[:flag_to_add]

    value = config.attributes[key]
    Log.v("Change before #{key}: #{value}", debug)

    if not value.nil?
      paths = value.split(' ').
          map {|item| item.strip}.
          reject {|item| item.empty?}.
          map {|item|
            item.gsub!(/\A"|"\z/, '')
            item.gsub!(/\A'|'\z/, '')
            item
          }
    else
      paths = []
    end

    Array(flag_to_remove).each do |path|
      paths.delete(path)
    end

    Array(flag_to_add).each do |path|
      paths.push(path)
    end

    paths.delete('$(inherited)')

    config.attributes[key] = paths.insert(0, '$(inherited)').uniq.join(' ')

    Log.v("Change after #{key}: #{config.attributes[key]}", debug)
  end

  def self.change_xcconfig_attrs!(config, config_map, debug = false)
    config_map.each {|key, change_map|
      if key == 'FRAMEWORK_SEARCH_PATHS' || key == 'LIBRARY_SEARCH_PATHS'
        self.change_framework_or_library_search_path!(config, key, change_map, debug)
      elsif key == 'OTHER_LDFLAGS'
        self.change_other_ldflags!(config, key, change_map, debug)
      elsif key == 'HEADER_SEARCH_PATHS'
        self.change_header_search_path!(config, key, change_map, debug)
      elsif key == 'OTHER_CFLAGS'
        self.change_other_cflags!(config, key, change_map, debug)
      end
    }
  end

  ##
  # Copy custom resource file or folder to Pods
  #
  # @param [Object]  podfile_path
  #        The path of Podfile
  # @param [Object]  copy_config_map
  #        The copy mapping. key is source path, value is destination path.
  #        The source/destination path is relative to the Podfile
  # @param [Object]  config_json_path
  #        The json for copy_config_map. The `config_json_path` is prior to the `copy_config_map`
  # @param [Object]  debug
  #        The flag for debugging
  # @return [Void]
  #
  # @example
  #
  # post_install do |installer|
  #   PodfileTool.resource_copy(__FILE__, {
  #     'Headers' => 'Pods/Headers'
  #   }, './copy_map.json', true)
  # end
  #
  def self.resource_copy(podfile_path, copy_config_map, config_json_path = nil, debug = false)
    if config_json_path.nil? and (copy_config_map.nil? or copy_config_map.length == 0)
      Log.e("parameter is wrong: #{config_json_path}, #{copy_config_map}", debug)
      return
    end

    podfile_dir = File.expand_path File.dirname(podfile_path)

    if not config_json_path.nil? and File.exist? config_json_path
      begin
        copy_config_map = JSON.parse IO.read config_json_path
      rescue Exception => e
        Log.e("an exception occurred: #{e}", debug)
      end
    end

    copy_config_map.each do |src_path, dest_path|
      src_absolute_path = Pathname.new(podfile_dir).join(src_path).to_s
      dest_absolute_path = Pathname.new(podfile_dir).join(dest_path).to_s

      if not File.exist? src_absolute_path
        Log.v("source path not exists #{src_absolute_path}", debug)
        next
      end

      # Note: src -> dest
      #       file  file, dest file replace by src file
      #       file  folder, copy file to the underneath of folder
      #       folder file, delete file, copy folder to the underneath of new created folder
      #       folder folder, copy folder to the underneath of folder
      if File.directory? src_absolute_path
        Log.v("copy dir from `#{src_absolute_path}` to #{dest_absolute_path}", debug)

        if Dir.exist? dest_absolute_path
          # Note:
        elsif File.exist? dest_absolute_path
          FileUtils.remove_file dest_absolute_path
        else
          FileUtils.mkdir_p dest_absolute_path
        end

        FileUtils.mkdir_p dest_absolute_path
        FileUtils.cp_r src_absolute_path, dest_absolute_path
      elsif File.file? src_absolute_path
        Log.v("copy file from `#{src_absolute_path}` to #{dest_absolute_path}", debug)

        if Dir.exist? dest_absolute_path
          FileUtils.cp src_absolute_path, dest_absolute_path
        elsif File.exist? dest_absolute_path
          if File.file? dest_absolute_path
            FileUtils.remove_file dest_absolute_path
          else
            FileUtils.remove_dir dest_absolute_path
          end

          # Note: make a copied file
          src_path_copied = src_absolute_path + '.copy'

          # Note: make folders for the dest_path
          FileUtils.mkdir_p File.dirname dest_path

          # Note: make a copied file and reserve the original file
          FileUtils.cp src_absolute_path, src_path_copied

          # Note: move the copied file to the dest file
          FileUtils.mv src_path_copied, dest_absolute_path
        end
      end
    end
  end
end

PODFILE_CONFIG_FILE_PATH = './podfile_config.json'

options = {}
parser = OptionParser.new do |opts|
  opts.on('--podfile=PODFILE_PATH', '[Required] The path of Podfile')
  opts.on('--method=METHOD_NAME', '[Required] The method to run')
  opts.on('--json[=PATH]', '[Optional] The config json file path. Default is `./podfile_config.json`')
  opts.on('--debug', '[Optional] The flag for debug')
end
parser.parse!(into: options)

if not options[:method].nil? and not options[:podfile].nil? and File.exist? File.expand_path options[:podfile]

  json_path = File.expand_path PODFILE_CONFIG_FILE_PATH
  if not options[:json].nil?
    json_path = File.expand_path options[:json]
  end

  if not File.exist? json_path
    Log.e("json file not exists at `#{json_path}`", true)
    return
  end

  begin
    config_map = JSON.parse(IO.read json_path)
  rescue JSON::ParserError
    Log.e('json file\'s format is not correct', true)
    return
  end

  if options[:method].eql? 'resource_copy'
    PodfileTool.resource_copy options[:podfile], config_map, nil, options[:debug].nil? ? false : true
  else
    Log.e("unknown method: #{options[:method]}", true)
  end

else
  puts parser.help
end

