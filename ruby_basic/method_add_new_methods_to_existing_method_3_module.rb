
module ExtraMethods
  # @see http://rubyblog.pro/2017/04/class-methods-and-instance-methods-by-including-one-module
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def bar
      "bar class method in Foo's extra module"
    end
  end
end
