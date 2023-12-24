require 'optparse'
require_relative 'log_tool'
require_relative 'dump_tool'

class XcschemeTool
  require 'rexml/document'
  include REXML

  class XcschemeFormatter < REXML::Formatters::Default
    def initialize(indentation: 3, enableSelfClosingTag: true)
      super()
      @indentation = indentation
      @current_level = 0
      @enableSelfClosingTag = enableSelfClosingTag
    end

    def write(node, output)
      case node
      when REXML::XMLDecl
        output << node.to_s.gsub("'", '"')
      else
        super(node, output)
      end
    end

    def write_text(node, output)
      output << ""
    end

    def write_element(node, output)
      current_node_indent = "\n#{" " * @indentation * @current_level}"
      output << current_node_indent
      output << "<#{node.expanded_name}"

      # Note: increase level before this node's attributes processed
      @current_level += 1
      attrs = node.attributes.to_a

      unless attrs.empty?
        attrs.each_with_index do |attr, index|
          output << "\n" << (" " * @indentation * @current_level)
          # output << attr.to_string.sub(/=/, '="') << '"'
          output << "#{attr.name} = \"#{attr.value}\""
        end
      end

      if node.children.empty?
        if @enableSelfClosingTag
          output << " />"
        else
          output << ">"
          output << current_node_indent
          output << "</#{node.expanded_name}"
        end
      else
        output << ">"
        node.children.each { |child| write(child, output) }

        output << current_node_indent
        output << "</#{node.expanded_name}>"
        if @current_level == 1
          output << "\n"
        end
      end

      # Note: decrease level after this node processed
      @current_level -= 1
    end
  end

  ##
  # Open a xml file to parse
  #
  # @param [String] xml_path
  #       The path for xml file
  #
  def self.open_xml(xml_path)
    @@xml_file = File.new(xml_path)
    @@doc = Document.new(@@xml_file)
  end

  ##
  # Write modified document object to xml
  #
  # @param [String] xml_path
  #       Pass nil, will the path which passed by open_xml method
  #
  def self.write_xml(xml_path = nil)
    formatter = XcschemeFormatter.new
    path = xml_path != nil ? xml_path : @@xml_file.path
    File.open(path, "w") do |xml_file|
      formatter.write(@@doc, xml_file)
    end
  end

  ##
  # Insert an environment variable
  #
  # @param [Array] env_var_list
  #       the list for EnvironmentVariables, each element is a single entry dict
  #
  def self.insert_env_vars(env_var_list)
    if not env_var_list.is_a?(Array) or env_var_list.size == 0
      return
    end

    if @@doc.nil?
      return
    end

    parent_node = @@doc.elements['Scheme/LaunchAction/EnvironmentVariables']

    if parent_node.nil?
      parent_node = @@doc.elements['Scheme/LaunchAction']
      if parent_node.nil?
        return
      end

      parent_node = parent_node.add_element(Element.new("EnvironmentVariables"))
    end

    env_var_list.each do |pair_dict|
      name = pair_dict[:name]
      value = pair_dict[:value]
      enabled = pair_dict[:enabled] ? pair_dict[:enabled] : "YES"

      new_node = Element.new("EnvironmentVariable")
      new_node.add_attributes({
                                "key" => name,
                                "value" => value,
                                "isEnabled" => enabled
                              })
      parent_node.add_element(new_node)
    end
  end
end

if File.basename($0) == File.basename(__FILE__)
  options = {}
  parser = OptionParser.new do |opts|
    opts.on('--xcodeproj=PATH', '[Required] The path of Xcode xcodeproj')
    opts.on('--scheme=NAME', '[Required] The name of scheme')
    opts.on('--debug', '[Optional] The flag for debug')
    opts.on('--verbose', '[Optional] The flag for debug')
    opts.on('--envVars="KEY1=VALUE1,KEY2=VALUE2,..."', Array, "Description of env variables")
  end
  parser.parse!(into: options)

  # Log.d("options: #{options}", options[:debug])

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
    env_var_list = []
    need_modify = false
    dump_object(options[:envVars])
    if options[:envVars].is_a?(Array) and options[:envVars].size > 0
      options[:envVars].each do |pair|
        dump_object(pair)
        key, value = pair.split('=')
        dump_object(key)
        dump_object(value)
        if key.strip.length > 0 and value.strip.length > 0
          env_var_list.append({
                                :name => key.strip,
                                :value => value.strip,
                                :enabled => "YES"
                              })
          need_modify = true
        end
      end
    end

    dump_object(need_modify)

    if not need_modify
      return
    end

    dump_object(env_var_list)

    XcschemeTool.open_xml(xml_path)
    Log.v("insert env vars: #{env_var_list}") if options[:verbose]
    XcschemeTool.insert_env_vars(env_var_list)
    XcschemeTool.write_xml(nil)
  else
    puts parser.help
  end
end