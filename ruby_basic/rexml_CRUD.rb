require_relative '../ruby_tool/ruby_tools'
require 'rexml/document'
include REXML

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
  begin
    xml_file = File.new("./test/dummy_rexml_CRUD.xml")
    doc = Document.new(xml_file)
    parent_node = doc.elements['Scheme/LaunchAction/EnvironmentVariables']

    if parent_node.nil?
      parent_node = doc.elements['Scheme/LaunchAction']
      if parent_node.nil?
        return
      end

      parent_node = parent_node.add_element(Element.new("EnvironmentVariables"))
    end

    new_node = Element.new("EnvironmentVariable")
    new_node.add_attributes({
                              "key" => "DYLD_PRINT_ENV",
                              "value" => "1",
                              "isEnabled" => "YES"
                            })
    parent_node.add_element(new_node)

    formatter = REXML::Formatters::Pretty.new
    File.open("./test/dummy_rexml_CRUD.xml", "w") do |xml_file|
      formatter.write(doc, xml_file)
    end
  rescue => e
    puts "An error occurred:"
    puts e.full_message(highlight: true, order: :top)
  end
end

def test_update_node
  xml_file = File.new("./test/dummy_rexml_CRUD.xml")
  doc = Document.new(xml_file)
  target_node = doc.elements['Scheme/ArchiveAction']

  if target_node.nil?
    Log.e("not found Scheme/ArchiveAction")
    return
  end

  new_node = REXML::Element.new("ArchiveActionChanged")
  target_node.attributes.each do |key, value|
    new_node.attributes[key] = value
  end
  new_node.attributes["buildConfiguration"] = "Debug"

  target_node.parent.replace_child(target_node, new_node)

  formatter = REXML::Formatters::Pretty.new
  File.open("./test/dummy_rexml_CRUD.xml", "w") do |file|
    formatter.write(doc, file)
  end
end

def test_delete_node
  xml_file = File.new("./test/dummy_rexml_CRUD.xml")
  doc = Document.new(xml_file)
  target_node = REXML::XPath.first(doc, "//Scheme/BuildAction")
  if target_node
    target_node.parent.delete_element(target_node)
  end
  formatter = REXML::Formatters::Pretty.new
  File.open("./test/dummy_rexml_CRUD.xml", "w") do |file|
    formatter.write(doc, file)
  end
end

# Note: test following each method with ./test/dummy_rexml_CRUD.xml
#test_traverse_all_node
#test_read_specific_node
#test_create_node
#test_update_node
test_delete_node
