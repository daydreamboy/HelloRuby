##
# A example of `send` method
# @see ruby doc

class Klass
  def hello(*args)
    puts "Hello " + args.join(' ')
  end

  def self.Hello(*args)
    puts "Hello2 " + args.join(' ')
  end
end

k = Klass.new
k.send :hello, "gentle", "readers"   #=> "Hello gentle readers"
# use send method by runtime, is same as the following line
k.hello "gentle", "readers"

Klass.send :Hello, 'gentle2', 'readers2'

puts Klass.ancestors.inspect