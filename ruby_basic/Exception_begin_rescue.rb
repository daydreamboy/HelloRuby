require 'json'
require 'test/unit/assertions'
include Test::Unit::Assertions

config_json_path = __FILE__

begin
  output = JSON.parse IO.read config_json_path
rescue Exception => e
  puts "an exception occurred: #{e}"
end

assert_nil output, "output expected nil"