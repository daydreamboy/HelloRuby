# encoding: utf-8
require_relative '../ruby_tool/dump_tool'

##
# Examples from http://www.chrisrolle.com/blog/ruby-percentage-notations
#

def test_default_percentage
  puts %(Ruby is awesome) # => "Ruby is awesome"
  puts %[Ruby is awesome] # => "Ruby is awesome"
  puts %%Ruby is awesome% # => "Ruby is awesome"
  puts %.Ruby is awesome. # => "Ruby is awesome"

  puts '------------------'
end

def test_nested_delimiter
  puts %(Ruby (is) awesome) # => "Ruby (is) awesome"
  puts %[Ruby [is awesome]] # => "Ruby [is awesome]"
  puts %<Ruby <<is> awesome>> # => "Ruby <<is> awesome>"

  # Note: need escape by \
  puts %-Ruby \-is\- awesome- # => "Ruby -is- awesome"

  puts '------------------'
end

def test_percentage_notation
  language = 'Ruby'

  puts %q('Simple' "non-interpolated" String.) # => "'Simple' \"non-interpolated\" String."
  puts %Q(Interpolated "#{language}" String.) # => "Interpolated \"Ruby\" String."
  puts %(Interpolated "#{language}" String (default).) # => "Interpolated \"Ruby\" String (default)."

  # Simple non-interpolated String Array:
  puts %w[Ruby Javascript Coffeescript] # => ["Ruby", "Javascript", "Coffeescript"]

  # Interpolated String Array:
  puts %W[#{language} Javascript Coffeescript] # => ["Ruby", "Javascript", "Coffeescript"]

  #  Simple non-interpolated Symbol Array:
  array1 = %i[ruby javascript coffeescript] # => [:ruby, :javascript, :coffeescript]
  dump_object(array1)

  # Interpolated Symbol Array:
  array2 = %I[#{language.downcase} javascript coffeescript] # => [:ruby, :javascript, :coffeescript]
  dump_object(array2)

  puts %x(echo #{language} interpolated shell scripting command)

  # => "Ruby interpolated shell scripting command\n"
  reg = %r{/#{language} regexp/i} # => /\/Ruby regexp\/i/
  dump_object(reg)

  puts '------------------'
end

test_default_percentage
test_nested_delimiter
test_percentage_notation

