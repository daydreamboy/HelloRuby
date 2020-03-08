require 'json'

$json_string = '
"key": {
  "some": "thing",
}
'

def test_without_exception_catch
  JSON.parse($json_string)
end

def test_with_exception_catch
  # @see https://stackoverflow.com/questions/27944050/how-to-handle-json-parser-errors-in-ruby
  begin
    JSON.parse($json_string)
  rescue JSON::ParserError
    puts "json is not valid"
  end
end

test_with_exception_catch
test_without_exception_catch
