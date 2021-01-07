require 'colored2'
require_relative '../ruby_tool/log_tool'

class PodfileTool
  def self.modify_xcconfig_attrs!(podfile_path, key, list_to_remove = nil, list_to_add = nil, target_list = nil, debug = false)

    if Array(list_to_remove).length == 0 && Array(list_to_add).length == 0
      return
    end

    podfile_dir = File.expand_path File.dirname(podfile_path)
    xcodeproj_files = Dir.glob("#{podfile_dir}/*.xcodeproj")
    if xcodeproj_files.length != 1
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
        if File.exists?(xcconfig_pathname)
          config = Xcodeproj::Config.new(File.new(xcconfig_pathname.to_path))
          change_xcconfig_attrs!(config, key, list_to_remove, list_to_add)
          config.save_as(xcconfig_pathname)
        end
      end
    end
    project.save(project_path)
  end

  def self.change_xcconfig_attrs!(config, key, list_to_remove, list_to_add, debug = false)
    if key == 'FRAMEWORK_SEARCH_PATHS' || key == 'LIBRARY_SEARCH_PATHS'

      value = config.attributes[key]
      if value.nil?
        if !list_to_add.nil?
          list_to_add.map! do |item|
            '"' + item + '"'
          end

          config.attributes[key] = list_to_add.insert(0, '$(inherited)').uniq.join(' ')
        end
      else
        parts = value.split

        # @see https://stackoverflow.com/questions/30276873/ruby-wrap-each-element-of-an-array-in-additional-quotes
        parts.map! do |item|
          item.gsub!(/\A"|"\z/,'')
          item.gsub!(/\A'|'\z/,'')
          item
        end.reject! do |item|
          if list_to_remove.nil?
            false
          else
            list_to_remove.include? item
          end
        end

        if !list_to_add.nil?
          parts = parts + list_to_add
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
    elsif key == 'OTHER_LDFLAGS'
      # @see https://stackoverflow.com/a/18894072
      Array(list_to_remove).each do |flag|
        # Log.w "Removing #{key} for #{flag} (" + File.basename(xcconfig_pathname.to_path) + " `#{xcconfig.name}`)"
        config.libraries.delete(flag)
      end

      Array(list_to_add).each do |flag|
        # Log.w "Adding flag for #{pod_name} (" + File.basename(xcconfig_pathname.to_path) + " `#{xcconfig.name}`)"
        config.frameworks.add(flag)
      end
    elsif key == 'HEADER_SEARCH_PATHS'
      value = config.attributes[key]
      Log.d(value)

      paths = value.split(' ').
          map {|item| item.strip }.
          reject {|item| item.empty? }.
          map {|item|
            item.gsub!(/\A"|"\z/,'')
            item.gsub!(/\A'|'\z/,'')
            item
          }

      Array(list_to_remove).each do |path|
        paths.delete(path)
      end

      Array(list_to_add).each do |path|
        paths.push(path)
      end

      # dump_object(paths)
      paths.delete('$(inherited)')
      paths.map! {|item| '"' + item + '"' }

      config.attributes[key] = paths.insert(0, '$(inherited)').uniq.join(' ')
    elsif key == 'OTHER_CFLAGS'
      value = config.attributes[key]
      paths = value.split(' ').
          map {|item| item.strip }.
          reject {|item| item.empty? }.
          map {|item|
            item.gsub!(/\A"|"\z/,'')
            item.gsub!(/\A'|'\z/,'')
            item
          }

      paths.delete('$(inherited)')

      unless paths.length % 2 == 0
        Log.e "`#{key}` should have paired key-values, but now is #{value}"
        raise "`#{key}` should have paired key-values, but now is #{value}"
      end

      paired_list = []
      (0..paths.length - 1).step(2).each { |index|
        if !Array(list_to_remove).include?(paths[index + 1])
          paired_list.push([paths[index], paths[index + 1]])
        end
      }

      Array(list_to_add).each { |item|
        paired_list.push(['-iquote', item])
      }

      flat_list = paired_list.map { |item|
        item[0] + ' ' + '"' + item[1] + '"'
      }

      config.attributes[key] = flat_list.insert(0, '$(inherited)').uniq.join(' ')
    end
  end
end
