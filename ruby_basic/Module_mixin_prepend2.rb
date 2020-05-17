module ServiceDebugger
  def run(args)
    puts "Service run start: #{args.inspect}"
    result = super
    puts "Service run finished: #{result}"
  end
end

class Service
  prepend ServiceDebugger

  # perform some real work
  def run(args)
    args.each do |arg|
      sleep 1
    end
    {result: "ok"}
  end
end

puts Service.ancestors.inspect

s = Service.new()
s.run([1, 2, 3])
