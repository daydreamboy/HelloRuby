require 'pathname'
require 'test/unit/assertions'
include Test::Unit::Assertions

# Output: /Users/wesley_chen/6/iOS/Pods/FDFullscreenPopGesture
output = Pathname.new('/Users/wesley_chen/6/iOS/Pods/').join('FDFullscreenPopGesture').to_s
expected = '/Users/wesley_chen/6/iOS/Pods/FDFullscreenPopGesture'

assert_equal expected, output, "Failed"
