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
    clz.send(:extend, AbstractInterface::ClassMethods)
  end

  module Methods
    def api_not_implemented(instance, method_name = nil)
      if method_name.nil?
        caller.first.match(/in \`(.+)\'/)
        method_name = $1
      end
      raise AbstractInterface::InterfaceNotImplementedError.new("#{instance.class.name} needs to implement '#{method_name}' for interface #{self.name}!")
    end
  end

  module ClassMethods
    def needs_implementation(clz, name, *args)
      self.class_eval do
        define_method(name) do |*args|
          clz.api_not_implemented(self, name)
        end
      end
    end
  end
end