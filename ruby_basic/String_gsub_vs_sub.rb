require_relative '../ruby_tool/ruby_tools'

# @see https://stackoverflow.com/questions/6124548/what-does-the-g-stand-for-in-rubys-gsub-and-in-vims-substitution-command
string = "One potato, two potato, three potato, four."
string.sub('potato','banana') # => "One banana, two potato, three potato, four."
string.gsub('potato','banana') # => "One banana, two banana, three banana, four."

dump_object(string.sub('potato','banana'))
dump_object(string.gsub('potato','banana'))

