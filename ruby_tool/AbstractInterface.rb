##
# Provide an abstract module to define an interface
#
# @see https://metabates.com/2011/02/07/building-interfaces-and-abstract-classes-in-ruby/
module AbstractInterface
  class InterfaceNotImplementedError < NoMethodError
  end

  def self.included(clz)
    clz.send(:include, AbstractInterface::Methods)
    clz.send(:extend, AbstractInterface::Methods)
  end

  module Methods
    def api_not_implemented(instance)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise AbstractInterface::InterfaceNotImplementedError.new("#{instance.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end
  end
end