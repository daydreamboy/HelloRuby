##
# An example of checking class
#

class Name

end


def check_class(var)
  puts "#{var} ..> #{var.class}"
end

check_class(BasicObject)
check_class(Object)
check_class(Module)
check_class(Class)
check_class(String)
check_class(Array)
check_class(Hash)
check_class(Range)
check_class(Numeric)
check_class(Float)
check_class(Complex)
check_class(Name)
check_class(Name.new)


