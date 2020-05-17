#!/usr/bin/ruby

##
# Print all data types of Ruby
#
# @return [NilClass]
#
# @see http://zetcode.com/lang/rubytutorial/datatypes/
# @see https://docs.ruby-lang.org/en/2.0.0/syntax/literals_rdoc.html
def print_data_types
  h = {:name => "Jane", :age => 17}

  p true.class, false.class, nil.class
  # TrueClass
  # FalseClass
  # NilClass

  p "Ruby".class # String
  p 1.class # Integer
  p 4.5.class # Float
  p 3_463_456_457.class # Integer
  p :age.class # Symbol
  p [1, 2, 3].class # Array
  p h.class # Hash
  p (1..2).class # Range
  p /.*/.class # Regexp
  p -> { 1 + 1 }.class # Proc

  # Note: add `return` to explicitly return nil
  return
end

print_data_types