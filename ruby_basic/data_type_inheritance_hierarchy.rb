##
# An example of checking superclass
#
def check_superclass(var)
  puts "#{var} --> #{var.superclass}"
end

class MyBaseClass

end

class MyDerivedClass < MyBaseClass

end

check_superclass(BasicObject)
check_superclass(Object)
check_superclass(Module)
check_superclass(Class)
check_superclass(String)
check_superclass(Array)
check_superclass(Hash)
check_superclass(Range)
check_superclass(Numeric)
check_superclass(Float)
check_superclass(Complex)
check_superclass(MyBaseClass)
check_superclass(MyDerivedClass)


