require 'colored2'
require_relative '../ruby_tool/log_tool'

class PodfileTool
  ##
  # change xcconfig files of the .xcodeproj which located in Podfile's folder
  #
  # @param [String]  podfile_path Pass __FILE__ usually
  # @param [String]  key the key which in xcconfig file, e.g. 'OTHER_LDFLAGS'
  # @param [Array]  list_to_remove the values to remove for the key
  # @param [Array]  list_to_add the values to remove for the key
  # @param [Array]  target_list the xcconfig belong which target. If nil, will change xcconfig for all targets
  # @param [Bool]  debug If true, to print debug log
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
          Log.v("Start modify xcconfig for `#{xcconfig_name}`")
          config = Xcodeproj::Config.new(File.new(xcconfig_pathname.to_path))
          change_xcconfig_attrs!(config, config_map, debug)
          config.save_as(xcconfig_pathname)
          Log.v("End modify xcconfig for `#{xcconfig_name}`")
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

    paths = value.split(' ').
        map {|item| item.strip}.
        reject {|item| item.empty?}.
        map {|item|
          item.gsub!(/\A"|"\z/, '')
          item.gsub!(/\A'|'\z/, '')
          item
        }

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

  def self.change_framework_or_library_search_path!(config, key, change_map, degbug = false)
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

  # TODO test
  def self.change_other_cflags!(config, key, change_map, debug = false)
    flag_to_remove = change_map[:flag_to_remove]
    flag_to_add = change_map[:flag_to_add]

    value = config.attributes[key]
    Log.d(value, debug)

    paths = value.split(' ').
        map {|item| item.strip}.
        reject {|item| item.empty?}.
        map {|item|
          item.gsub!(/\A"|"\z/, '')
          item.gsub!(/\A'|'\z/, '')
          item
        }

    paths.delete('$(inherited)')

    unless paths.length % 2 == 0
      Log.e "`#{key}` should have paired key-values, but now is #{value}"
      raise "`#{key}` should have paired key-values, but now is #{value}"
    end

    paired_list = []
    (0..paths.length - 1).step(2).each {|index|
      if not Array(flag_to_remove).include?(paths[index + 1])
        paired_list.push([paths[index], paths[index + 1]])
      end
    }

    Array(flag_to_add).each {|item|
      paired_list.push(['-iquote', item])
    }

    flat_list = paired_list.map {|item|
      item[0] + ' ' + '"' + item[1] + '"'
    }

    config.attributes[key] = flat_list.insert(0, '$(inherited)').uniq.join(' ')
  end

  def self.change_xcconfig_attrs!(config, config_map, debug = false)
    config_map.each { |key, change_map|
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
end
