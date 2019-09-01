#!/usr/bin/env ruby

# 1. =begin...=end

=begin
Every body mentioned this way
to have multiline comments.

The =begin and =end must be at the beginning of the line or
it will be a syntax error.
=end

puts "Hello world!"

# 2. Here doc style

<<-DOC
Also, you could create a docstring.
which...
DOC

puts "Hello world!"

# 3. literal string

"..is kinda ugly and creates
a String instance, but I know one guy
with a Smalltalk background, who
does this."

puts "Hello world!"

# 4. sharp sign

##
# most
# people
# do
# this

# 5. __END__ sign

__END__

But all forgot there is another option.
Only at the end of a file, of course.