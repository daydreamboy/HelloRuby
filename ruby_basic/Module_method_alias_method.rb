class User
  def fullname
    'John Joe'
  end

  alias_method :username, :fullname
  alias_method 'name',:username
end

def test_alias_method
  u = User.new
  p u.fullname
  p u.username
  p u.name
end

test_alias_method
