require_relative '../ruby_tool/ruby_tools'

# @see https://stackoverflow.com/a/8652833
def string_to_regexp1(rg_string)
  return Regexp.new(rg_string)
end

# Note: not work, https://stackoverflow.com/a/11647572
def string_to_regexp2(rg_string)
  return /#{Regexp.quote(rg_string)}/
end

def test1
  input = 'aaa074.png'
  pattern = '[a-zA-Z]*([0-9]+).*'
  pattern = '(\d+)'
  pattern = '^[a-zA-Z]*(\d+)\.png$'
  regexp = string_to_regexp1(pattern)
  dump_object(regexp)

  if regexp.match?(input)
    # Note: find the match and replace the match with the second parameter
    # the second parameter is '\1' or fixed string value
    output = input.gsub(regexp, '\1')
    # output = input[regexp, 1]

    dump_object(output)
  else
    puts "The pattern #{regexp} not match the #{input}"
  end
end

def test2
  input = 'f001.png'
  regexp = string_to_regexp2('[a-zA-Z]+([0-9]+).*')
  dump_object(regexp)

  output = input.gsub(regexp, '\1')
  dump_object(output)
end

test1
# test2

