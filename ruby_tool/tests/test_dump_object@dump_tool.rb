#encoding: utf-8

require_relative '../ruby_tools'

string = 'hello, world'
hash = {"key" => "value"}
array = []
number = 3
symbol = :test
nilValue = nil

def test(param)
  return param
end

dump_object(string)
dump_object(hash)
dump_object(array)
dump_object(number)

dump_object("string")
dump_object({"key" => "value"})
dump_object([1, 2, 3])
dump_object(3.14)
dump_object(nilValue)

dump_object(test('FrameworkPackager'))
dump_object(symbol)
