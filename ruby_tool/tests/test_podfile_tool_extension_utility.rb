#encoding: utf-8

require_relative '../podfile_tool'

puts PodfileTool.xcode_version

puts PodfileTool.xcode_version_greater_than '14.0'
puts PodfileTool.xcode_version_greater_than '13.0'
puts PodfileTool.xcode_version_greater_than '13.1'
puts PodfileTool.xcode_version_greater_than_or_equal '14.0'

