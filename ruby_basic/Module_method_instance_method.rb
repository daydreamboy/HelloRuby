class Interpreter
  def do_a() print 'there, ' end
  def do_d() print 'Hello ' end
  def do_e() print "!\n" end
  def do_v() print 'Dave' end

  Dispatcher = {
      'a' => instance_method(:do_a),
      'd' => instance_method(:do_d),
      'e' => instance_method(:do_e),
      'v' => instance_method(:do_v),
  }

  def interpret(string)
    string.each_char do |b|
      Dispatcher[b].bind(self).call
    end
  end

end

i = Interpreter.new
i.interpret('dave')
print Class.ancestors.inspect

