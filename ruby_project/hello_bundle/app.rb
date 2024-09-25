# app.rb

puts $LOAD_PATH
# require 'bundler/setup'
Bundler.require(:default)

puts '-----------'
puts $LOAD_PATH

# require 'faker'
# require 'colorize'

puts "Welcome to the Fake Name Generator!".colorize(:green)

10.times do
  name = Faker::Name.name
  puts "- #{name}".colorize(:blue)
end
