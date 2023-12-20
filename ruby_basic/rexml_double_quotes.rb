
require 'rexml/document'
include REXML

# Example from https://stackoverflow.com/a/3943662
doc = REXML::Document.new
doc.context[:attribute_quote] = :quote  # <-- Set double-quote as the attribute value delimiter

root = doc.add_element('root')
root.add_attribute('attr', '123')

new_node = Element.new("EnvironmentVariable")
new_node.add_attributes({
                          "key" => "DYLD_PRINT_ENV",
                          "value" => "1",
                          "isEnabled" => "YES"
                        })
doc.elements['root'].add_element(new_node)

doc.write(STDOUT)
