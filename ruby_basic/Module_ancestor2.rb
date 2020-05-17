##
# An example of `ancestors` method
#
# @see ruby doc

module Mod
  include Math
  include Comparable
  prepend Enumerable
end

puts Mod.ancestors.inspect        #=> [Enumerable, Mod, Comparable, Math]
puts Math.ancestors.inspect       #=> [Math]
puts Enumerable.ancestors.inspect #=> [Enumerable]
