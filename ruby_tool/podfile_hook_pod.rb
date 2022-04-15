#encoding: utf-8

require_relative 'dump_tool'

module Pod
  class Podfile
    module DSL
      # hook pod
      alias original_pod pod

      def pod(*args)
        dump_object(args)
        # dump_object(*args)

        pod_name = args[0]
        pod_arg_map = args.length > 2 ? args[1] : nil

        # dump_object(pod_name)
        # dump_object(pod_arg_map)

        dump_object(current_target_definition.name)

        original_pod *args
      end
    end
  end
end
