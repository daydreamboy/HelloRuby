#encoding: utf-8

##
# An example of class method definition
#
# @see https://railsware.com/blog/better-ruby-choosing-convention-for-class-methods-definition/
#
class MyObject

  # Note: style 1
  def self.description
    return 'This is a MyObject class'
  end

  # Note: style 2
  class << self
    def debug_description
      return "This is a MyObject class: #{self}"
    end
  end
end

puts MyObject.description
puts MyObject.debug_description
