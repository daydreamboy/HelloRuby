##
# An example of checking ancestors
#
def check_ancestors(var)
  puts "#{var} --> #{var.ancestors.inspect}"
end

class MyBaseClass
end

class MyDerivedClass < MyBaseClass
end

check_ancestors(BasicObject)
check_ancestors(Object)
check_ancestors(Module)
check_ancestors(Class)
check_ancestors(String)
check_ancestors(Array)
check_ancestors(Hash)
check_ancestors(Range)
check_ancestors(Numeric)
check_ancestors(Float)
check_ancestors(Complex)
check_ancestors(MyBaseClass)
check_ancestors(MyDerivedClass)


