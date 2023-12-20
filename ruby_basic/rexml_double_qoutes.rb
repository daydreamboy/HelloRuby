
require 'rexml/document'

# Example from https://stackoverflow.com/a/3943662
doc = REXML::Document.new
doc.context[:attribute_quote] = :quote  # <-- Set double-quote as the attribute value delimiter

root = doc.add_element('root')
root.add_attribute('val', '123')

doc.write(STDOUT)
