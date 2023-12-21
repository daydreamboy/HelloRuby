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

  def content_after_last_tag(file_path)
    buffer_size = 1024
    buffer = ""
    found = false

    puts File.read(file_path)

    File.open(file_path, 'rb') do |file|
      dump_object(file)
      file.seek(0, IO::SEEK_END)
      dump_object(file.pos)
      while file.pos > 0 && !found
        to_read = [file.pos, buffer_size].min
        file.seek(-to_read, IO::SEEK_CUR)
        buffer = file.read(to_read) + buffer
        dump_object(buffer)
        file.seek(-to_read, IO::SEEK_CUR)
        found = buffer.include?('>')
      end
    end

    dump_object(buffer)
    dump_object(found)
    if found
      return buffer[buffer.rindex('>')..-1]
    else
      return ""
    end
  end

  # def write_document(node, output)
  #   super(node, output)
  #   temp_content = self.content_after_last_tag(output.path)
  #   dump_object(temp_content)
  #
  #   output << temp_content
  # end

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
      if @current_level == 1
        output << "\n"
      end
    end

    # Note: decrease level after this node processed
    @current_level -= 1
  end
end

def test_create_node
  begin
    xml_file = File.new("./test/dummy_rexml_CRUD.xml")
    doc = Document.new(xml_file)
    # Note: not works with custom formatter
    #doc.context[:attribute_quote] = :quote
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

    #formatter = EmptyBodyTagFormatter.new(enableSelfClosingTag: true)
    formatter = EmptyBodyTagFormatter.new
    File.open("./test/dummy_rexml_CRUD.xml", "w") do |xml_file|
      formatter.write(doc, xml_file)
    end
  rescue => e
    puts "An error occurred:"
    puts e.full_message(highlight: true, order: :top)
  end
end

test_create_node