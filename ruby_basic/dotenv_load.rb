#!/usr/bin/ruby
#
# An example for usage of dotenv

require 'dotenv'
Dotenv.load

def test_env_load
  puts ENV['SECRET_KEY']
  puts ENV['SECRET_HASH']

  puts "---------"
  ENV.each_pair do |name, value|
    puts "#{name} = #{value}"
  end
end

test_env_load
