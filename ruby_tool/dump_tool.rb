#encoding: utf-8

##
# Dump object as format 'var = (type) value'
#
# @param [Object]  arg
#
# @return [NilClass]
#
# @example
#
# Demo output:
# [Debug] test_dump_object.rb:8: string = (String) "hello, world"
# [Debug] test_dump_object.rb:9: dict = (Hash) {}
# [Debug] test_dump_object.rb:10: array = (Array) []
# [Debug] test_dump_object.rb:11: number = (Integer) 3
# [Debug] test_dump_object.rb:13: "string" = (String) "string"
# [Debug] test_dump_object.rb:14: {} = (Hash) {}
# [Debug] test_dump_object.rb:15: [1, 2, 3] = (Array) [1, 2, 3]
# [Debug] test_dump_object.rb:16: 3.14 = (Float) 3.14
#
# @see https://stackoverflow.com/questions/15769739/determining-type-of-an-object-in-ruby
# @see https://stackoverflow.com/questions/41032717/get-original-variable-name-from-function-in-ruby
# @see https://stackoverflow.com/questions/3453262/how-to-strip-leading-and-trailing-quote-from-string-in-ruby
# @see http://ruby-doc.org/core-2.1.0/Regexp.html
#
# @note
# /<.+>/.match("<a><b>")  #=> #<MatchData "<a><b>">
# /<.+?>/.match("<a><b>") #=> #<MatchData "<a>">
def dump_object(arg)
  loc = caller_locations.first
  line = File.read(loc.path).lines[loc.lineno - 1]

  # get string started by `dump_object`
  callerString = line[/#{__method__}\(.+\)/].to_s

  # get parameter name of `dump_object`
  argName = callerString[/\(.+\)/]

  # get content of parenthesis
  argNameStr = (argName && argName.gsub!(/^\(|\)?$/, '')) || 'empty'

  filename = loc.path
  lineNo = loc.lineno

  puts "[Debug] #{filename}:#{lineNo}: #{argNameStr} = (#{arg.class}) #{arg.inspect}"
end

##
# Dump info of method symbol
#
# Note: https://til-engineering.nulogy.com/Show-definition-of-a-method-at-runtime-in-Ruby/
# Note: https://stackoverflow.com/a/3393706
def dump_method(method_symbol, clz = nil, is_class_method = false)
  if clz.nil?
    method_variable = method(method_symbol)
  else
    if is_class_method
      method_variable = clz.method(method_symbol)
    else
      method_variable = clz.instance_method(method_symbol)
    end
  end

  if not method_variable.nil?
    puts "[Debug] `#{method_symbol}` at #{method_variable.source_location.join(':')} (original_name = `#{method_variable.original_name}`)"
  else
    puts "[Debug] not find `#{method_symbol}` method!"
  end
end