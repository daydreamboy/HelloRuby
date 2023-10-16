
def test1
  # @see https://stackoverflow.com/questions/2051229/how-to-compare-versions-in-ruby
  # false
  puts Gem::Version.new('0.4.1') > Gem::Version.new('0.10.1')
end

VERSION = "1.2.0"
def test2
  def CompareVersion(version)
    Gem::Dependency.new('', version).match?('', VERSION)
  end

  if CompareVersion('>=1.2.0')
    puts ">=1.2.0"
  else
    puts "<1.2.0"
  end

  if CompareVersion('>3.0')
    puts ">3.0"
  else
    puts "<=3.0"
  end
end

test1
test2
