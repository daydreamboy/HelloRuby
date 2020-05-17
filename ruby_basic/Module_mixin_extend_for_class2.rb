require 'logger'

module Logging
  def logger
    @@logger ||= Logger.new(STDOUT)
  end
end

class Person
  extend Logging

  def relocate
    Person.logger.debug "Relocating1 person..."

    # could also access it with this
    self.class.logger.debug "Relocating2 person..."
  end
end

p = Person.new()
p.relocate()

puts Person.ancestors.inspect # [Person, Object, Kernel, BasicObject]
