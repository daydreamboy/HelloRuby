# app.rb

puts '1.-----------'
puts $LOAD_PATH

require 'bundler/setup'

puts '2.-----------'
puts $LOAD_PATH

Bundler.require(:default)

puts '3.-----------'
puts $LOAD_PATH

# Note: use Bundler.require(:default) to load all required gems
# require 'faker'
# require 'colorize'

puts "Welcome to the Fake Name Generator!".colorize(:green)

10.times do
  name = Faker::Name.name
  puts "- #{name}".colorize(:blue)
end
