##
# An example of using IO.readlines from Ruby Doc
#


# @see https://stackoverflow.com/a/11974989
def test_read_lines
  IO.readlines(__FILE__).each do |line|
    print line
  end
end

def test_read_lines_without_line_wrapper
  IO.readlines(__FILE__, chomp: true).each do |line|
    print line
  end
end


test_read_lines
puts '------------------------------'
test_read_lines_without_line_wrapper
