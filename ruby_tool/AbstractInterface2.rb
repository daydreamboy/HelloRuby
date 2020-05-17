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
    def api_not_implemented(clz)
      caller.first.match(/in \`(.+)\'/)
      method_name = $1
      raise AbstractInterface::InterfaceNotImplementedError.new("#{clz.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end
  end

  module ClassMethods
    def needs_implementation(name, *args)

    end
  end
end