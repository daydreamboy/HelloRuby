require_relative '../ruby_tool/dump_tool'

def test___method__
  __method__
end

dump_object(test___method__) # :test___method__
dump_object(__method__) # nil
