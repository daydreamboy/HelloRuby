require_relative '../ruby_tool/ruby_tools'

def create_with_forward_slashes
  return /hay/
end

match_data = create_with_forward_slashes.match('haystack')

dump_object(match_data)
dump_object("original string: #{match_data.string}")
dump_object("matched string: #{match_data.to_s}")
