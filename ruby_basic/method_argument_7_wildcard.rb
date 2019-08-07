#encoding: utf-8

require_relative '../ruby_tool/ruby_tools'

class Food
  def nutrition(vitamins, minerals)
    puts vitamins
    puts minerals
  end
end

class Bacon < Food
  def nutrition(*)
    super
  end
end

bacon = Bacon.new
bacon.nutrition("B6", "Iron")

# Error: `nutrition': wrong number of arguments (given 3, expected 2) (ArgumentError)
# bacon.nutrition("B6", "Iron", "B7")
