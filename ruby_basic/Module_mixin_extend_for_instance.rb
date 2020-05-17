require 'logger'

module Logging
  def logger
    @logger ||= Logger.new(STDOUT)
  end
end

class Person; end

p = Person.new
# p.logger -- this would throw a NoMethodError
p.extend Logging
p.logger.debug "just a test"

