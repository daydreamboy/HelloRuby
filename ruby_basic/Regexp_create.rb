require_relative '../ruby_tool/ruby_tools'

def create_with_forward_slashes
  return /hay/
end

def create_with_r_percent_literal
  return %r{hay}
end

def create_with_new
  return Regexp.new('hay')
end

dump_object(create_with_forward_slashes)
dump_object(create_with_r_percent_literal)
dump_object(create_with_new)

