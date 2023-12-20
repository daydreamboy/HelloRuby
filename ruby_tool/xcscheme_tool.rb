require 'optparse'
require_relative 'log_tool'
require 'rexml/document'
include REXML

class XcschemeTool

end

if File.basename($0) == File.basename(__FILE__)
  options = {}
  parser = OptionParser.new do |opts|
    opts.on('--xcodeproj=PATH', '[Required] The path of Xcode xcodeproj')
    opts.on('--scheme=NAME', '[Required] The name of scheme')
    opts.on('--debug', '[Optional] The flag for debug')
    opts.on("--envVar KEY=VALUE", "Description of env variables") do |pair|
      key, value = pair.split('=')
      options[:envVar] ||= {}
      options[:envVar][key.to_sym] = value
    end
  end
  parser.parse!(into: options)

  Log.d("options: #{options}", options[:debug])

  if not options[:xcodeproj].nil? and not options[:scheme].nil? and File.directory? File.expand_path options[:xcodeproj]
    xcodeproj_path = File.expand_path options[:xcodeproj]
    scheme_name = options[:scheme]

    Log.i("xcodeproj path: #{xcodeproj_path}", options[:debug])
    xml_path = File.join(xcodeproj_path, 'xcshareddata', 'xcschemes', "#{scheme_name}.xcscheme")
    Log.i("scheme path: #{xml_path}", options[:debug])

    if not File.exists? xml_path
      Log.e("not found #{xml_path}. Please turn on `Shared` checkbox for scheme #{scheme_name} in Xcode project.")
      return
    end

    # Note: check parameters for modifying xml file
    need_modify = true
    if not options[:envVar].is_a?(Hash) or options[:envVar].size == 0
      need_modify = false
    end

    if not need_modify
      return
    end

    File.open(xml_path, "w") do |file|
      # Step1: set env vars
      if options[:envVar]
        # doc.elements.each("root/someElement") do |element|
        #   puts element.text
        # end
        #
        # # 获取特定的元素
        # element = doc.elements["root/someElement"]
      end

      # Step2: other changes
      # ...

      doc.write(file)
    end

  else
    puts parser.help
  end
end