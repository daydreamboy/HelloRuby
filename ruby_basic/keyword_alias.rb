class User
  def fullname
    'John Doe'
  end

  alias username fullname
  alias name username
end

def test_alias
  u = User.new

  p u.fullname
  p u.username
  p u.name
end

test_alias