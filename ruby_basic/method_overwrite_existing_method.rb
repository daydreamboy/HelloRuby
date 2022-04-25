
def dummy_method
  puts "This is a dummy method"
end

def test_hook_dummy_method
  # Note: before call the dummy_method, use eval to hook it
  ruby_code = IO.read('./method_overwrite_existing_method_to_hook.rb')
  eval(ruby_code)

  dummy_method
end

test_hook_dummy_method
