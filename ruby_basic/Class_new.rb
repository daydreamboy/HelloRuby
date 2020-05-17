##
# An example of using Class
#
fred = Class.new do
  def meth1
    "hello"
  end
  def meth2
    "bye"
  end
end

a = fred.new
puts fred.superclass #=> Object
puts a.inspect   #=> #<#<Class:0x100381890>:0x100376b98>
puts a.meth1     #=> "hello"
puts a.meth2     #=> "bye"
