##
# A example of class_eval
# @see https://www.jimmycuadra.com/posts/metaprogramming-ruby-class-eval-and-instance-eval/

class Person
end

Person.class_eval do
  def say_hello
    "Hello!"
  end

  def self.say_hello2
    "Hello2!"
  end
end

Person.class_eval('def say_hello3() "Hello3" end')

jimmy = Person.new
puts jimmy.say_hello # "Hello!"
puts Person.say_hello2 # "Hello2!"
puts jimmy.say_hello3 # "Hello3!"
