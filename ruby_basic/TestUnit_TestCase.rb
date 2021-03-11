require 'test/unit'

class Hello
  def self.world
    'world2'
  end
end

class HelloTest < Test::Unit::TestCase
  def setup
  end

  def test_world
    assert_equal 'world', Hello.world, "Hello.world should return a string called 'world'"
  end

  def test_flunk
    flunk "You shall not pass"
  end
end
