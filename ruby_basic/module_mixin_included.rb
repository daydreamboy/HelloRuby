##
# An example of using included
#
# @see Ruby doc

module A
  def A.included(mod)
    puts "module `#{self}` included in module `#{mod}`"
  end
end

module Enumerable
  include A
end

# => prints "A included in Enumerable"