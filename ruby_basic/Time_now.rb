require_relative '../ruby_tool/ruby_tools'

now = Time.now
dump_object(now) # Time

t1 = Time.now.to_i
dump_object(t1) # Integer

t2 = Time.now.to_s
dump_object(t2) # String

RUN_SCRIPT_COMMENT = "#!/usr/bin/env bash\n# Auto-generated by pod_tweaker on %s\n\nblah..." % Time.now.to_s

puts RUN_SCRIPT_COMMENT