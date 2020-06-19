class Device1
  def description
    'I\'m a device'
  end

  def self.alias_description
    alias_method :describe, :description
  end
end

class Microwave1 < Device1
  def description
    'I\'m a microwave'
  end

  alias_description
end

class Device2
  def description
    'I\'m a device'
  end

  def self.alias_description
    alias :describe :description
  end
end

class Microwave2 < Device2
  def description
    'I\'m a microwave'
  end

  alias_description
end


def test_alias_method
  puts "-- #{__method__} --"

  m = Microwave1.new

  p m.description
  p m.describe
end

def test_alias
  puts "-- #{__method__} --"

  m = Microwave2.new

  p m.description
  p m.describe
end

test_alias_method
test_alias
