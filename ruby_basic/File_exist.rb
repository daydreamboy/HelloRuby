require 'test/unit/assertions'
include Test::Unit::Assertions

output = File.exist?(File.expand_path '~')
expected = true
assert_equal expected, output, 'Failed'

output = Dir.exist?(File.expand_path '~')
expected = true
assert_equal expected, output, 'Failed'
