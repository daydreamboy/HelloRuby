require_relative '../../ruby_tool/dump_tool'

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

  def foo; end
  alias bar foo
end

dump_method :hello
dump_method :description, Person, true

dump_method :hello, Person
dump_method :hello, Person, false

dump_method :bar, Person
