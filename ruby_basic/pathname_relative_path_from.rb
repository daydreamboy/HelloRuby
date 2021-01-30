require 'pathname'

# @see https://stackoverflow.com/questions/9416578/relative-path-to-your-project-directory
puts Pathname.new('/').relative_path_from(Pathname.new('/some/child/dir/')).to_s
puts Pathname.new('/Users/wesley_chen/6/iOS/Pods/FDFullscreenPopGesture').relative_path_from(Pathname.new('/Users/wesley_chen/6/iOS/Pods/')).to_s
