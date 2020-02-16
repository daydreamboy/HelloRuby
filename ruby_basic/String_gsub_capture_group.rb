require_relative '../ruby_tool/ruby_tools'

def regexp_capture_group(string)
  string.gsub(/(\d+)/, '\1')
end

def regexp_capture_group_anchored(string)
  string.gsub(/[a-zA-Z]*(\d+)/, '\1')
end

dump_object(regexp_capture_group('aaa074')) # output: "aaa074"
dump_object(regexp_capture_group_anchored('aaa074')) # output: "074"

