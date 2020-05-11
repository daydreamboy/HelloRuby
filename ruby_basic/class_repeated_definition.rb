class ThisAClass
  def self.description
    'ThisAClass 1'
  end
end

# Note: class definition allow repeated, and follow the rule 'Last one is winner'
class ThisAClass
  def self.description
    'ThisAClass 2'
  end
end

# print 'The true description: ThisAClass 2'
puts "The true description: #{ThisAClass.description}"
