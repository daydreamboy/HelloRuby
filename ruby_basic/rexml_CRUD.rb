require_relative '../ruby_tool/ruby_tools'
require 'rexml/document'
include REXML

class EmptyBodyTagFormatter < REXML::Formatters::Default
  def initialize(indentation: 3, enableSelfClosingTag: true)
    super()
    @indentation = indentation
    @current_level = 0
    @enableSelfClosingTag = enableSelfClosingTag
  end

  def write(node, output)
    case node
    when XMLDecl
      output << node.to_s.gsub("'", '"')
      # node.write( output )
    else
      super(node, output)
    end
  end

  def write_text(node, output)
    # Note: always make text body empty
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
    end

    # Note: decrease level after this node processed
    @current_level -= 1
  end
end

def traverse(element, indent = 0)
  # Note: each indent with two space
  print "#{'  ' * indent}#{element.name}"

  print "(" if element.attributes.length > 0
  index = 0
  element.attributes.each do |name, value|
    index = index + 1
    print "#{name} = #{value}#{index == element.attributes.length ? '' : ', '}"
  end
  print ")" if element.attributes.length > 0
  print "\n"

  indent = indent + 1
  element.each_element do |child|
    traverse(child, indent)
  end
end

def test_traverse_all_node
  xml_file = File.new("./test/dummy_rexml_CRUD.xml")
  doc = Document.new(xml_file)

  # Note: traverse from root
  traverse(doc.root)
end

def test_read_specific_node
  xml_file = File.new("./test/dummy_rexml_CRUD.xml")
  doc = Document.new(xml_file)

  puts doc.elements['Scheme/LaunchAction']
end

def test_create_node
  xml_file = File.new("./test/dummy_rexml_CRUD.xml")
  doc = Document.new(xml_file)
  # Note: not works with custom formatter
  #doc.context[:attribute_quote] = :quote
  # puts doc
  parent_node = doc.elements['Scheme/LaunchAction/EnvironmentVariables']

  if parent_node.nil?
    # dump_object(parent_node)
    # puts doc.elements['Scheme']

    parent_node = doc.elements['Scheme/LaunchAction']
    if parent_node.nil?
      return
    end

    parent_node = parent_node.add_element(Element.new("EnvironmentVariables"))
    # dump_object(parent_node)
  end

  new_node = Element.new("EnvironmentVariable")
  new_node.add_attributes({
                            "key" => "DYLD_PRINT_ENV",
                            "value" => "1",
                            "isEnabled" => "YES"
                          })
  parent_node.add_element(new_node)

  #formatter = EmptyBodyTagFormatter.new(enableSelfClosingTag: true)
  formatter = EmptyBodyTagFormatter.new
  File.open("./test/dummy_rexml_CRUD.xml", "w") do |xml_file|
    # doc.write(xml_file, 3)
    formatter.write(doc, xml_file)
  end
end

def test_update_node

end

def test_delete_node

end

#test_traverse_all_node
#test_read_specific_node
test_create_node
