# require_relative '../ruby_tool/dump_tool'

def hello
  "Hello"
end

class Person
  def hello
    "Hello"
  end

  def self.description
    "Person class"
  end
end

# Note: https://til-engineering.nulogy.com/Show-definition-of-a-method-at-runtime-in-Ruby/
puts method(:hello).source_location
# Note: https://stackoverflow.com/a/3393706
puts Person.instance_method(:hello).source_location
puts Person.method(:description).source_location

# dump_method :hello
# dump_method :description, true, Person
# dump_method :hello, false, Person
