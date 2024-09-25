# app.rb

require 'bundler/setup'

require 'faker'
require 'colorize'

puts "Welcome to the Fake Name Generator!".colorize(:green)

10.times do
  name = Faker::Name.name
  puts "- #{name}".colorize(:blue)
end
