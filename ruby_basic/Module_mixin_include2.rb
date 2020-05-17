require 'logger'

module Logging
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end

class Person
  include Logging

  def relocate
    logger.debug "Relocating person..."
    # or
    # self.logger.debug "Relocating person..."
  end
end

p = Person.new()
p.relocate()

puts Person.ancestors.inspect # [Person, Logging, Object, Kernel, BasicObject]
