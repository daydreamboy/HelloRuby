require_relative '../ruby_tool/ruby_tools'

def gsub_with_string_pattern(string)
  string.gsub('potato', 'banana')
end

def gsub_with_Regexp_pattern(string)
  string.gsub(/p[a-zA-Z]+o/, 'banana')
end

def gsub_with_Regexp_pattern_anchored(string)
  string.gsub(/^p[a-zA-Z]+o$/, 'banana')
end

dump_object(gsub_with_string_pattern("One potato, two potato, three potato, four."))
dump_object(gsub_with_Regexp_pattern("One potato, two potato, three potato, four."))
dump_object(gsub_with_Regexp_pattern_anchored("One potato, two potato, three potato, four."))

def gsub_with_string_pattern_literal(string)
  string.gsub('\d+', "[number]")
end

dump_object(gsub_with_string_pattern_literal("ff001.png"))
dump_object(gsub_with_string_pattern_literal('pattern is \d+')) # output: "pattern is [number]"
