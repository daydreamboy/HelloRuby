#!/usr/bin/env ruby

# Style 1
str ='world'
puts "hello, #{str}"

# Style 2
# @see https://stackoverflow.com/questions/3554344/what-is-ruby-equivalent-of-pythons-s-hello-s-where-is-s-john-mar
puts "%s, %s" % [ 'hello', 'world' ]

