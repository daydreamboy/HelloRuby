
# Partial examples from https://rollbar.com/guides/ruby/how-to-raise-exceptions-in-ruby/

def test_raise_with_ArgumentError
  raise ArgumentError, 'No parameters', caller
# 22_raise.rb: No parameters (ArgumentError)
end

def test_raise_with_Informative
  extname = 'txt'
  raise Informative, "Unsupported specification format `#{extname}`."
# 22_raise.rb:6:in `<main>': uninitialized constant Informative (NameError)
end

def test_raise_with_string
  # Note: raise a RuntimeError
  raise 'This is an exception'
end

def test_raise_with_StandardError
  raise StandardError.new "This is an exception"
end

def test_raise_with_Exception
  raise Exception.new "This is an exception"
end

class MyCustomException < StandardError
  def initialize(msg="This is a custom exception", exception_type="custom")
    @exception_type = exception_type
    super(msg)
  end

  def exception_type
    @exception_type
  end
end

def test_raise_with_custom_exception
  raise MyCustomException.new "Message, message, message", "Yup"
end

def test_raise_and_rescue_with_custom_exception
  begin
    raise MyCustomException.new "Message, message, message", "Yup"
  rescue MyCustomException => e
    puts e.message # Message, message, message
    puts e.exception_type # Yup
  end
end

# Note: reorder the following test methods to test
test_raise_with_custom_exception
# test_raise_with_ArgumentError
# test_raise_with_Informative
# test_raise_and_rescue_with_custom_exception
# test_raise_with_Exception
# test_raise_with_StandardError
# test_raise_with_string
