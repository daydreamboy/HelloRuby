require_relative 'method_add_new_methods_to_existing_method_2_module'

class Foo

end

Foo.class_eval { include ExtraMethods }