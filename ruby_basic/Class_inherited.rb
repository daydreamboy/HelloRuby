class Foo
  def self.inherited(subclass)
    puts "New subclass: #{subclass}"
  end
end

class Bar < Foo
end

class Baz < Bar
end

# Console print
# New subclass: Bar
# New subclass: Baz

