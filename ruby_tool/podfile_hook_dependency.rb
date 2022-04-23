#encoding: utf-8

require_relative 'dump_tool'

class PodfileDependencyHook
  @@pod_hook_plugins = []
  @@debug_flag = false

  ##
  # [Public] Register a hook plugin for the pod method
  #
  # @param [Block]  &block
  #        - target_name [String] the target name when pod method inside
  #        - pod_name [String] the pod name for pod method's first parameter
  #        - pod_arg_hash [Hash] the rest for pod method's second parameter.
  #          Change pod_arg_hash to modify pod method's second parameter and use
  #          :version to set a new version
  #
  # @return [Void]
  #
  # @note This method will change pod 'A', ... to  pod 'A', :path => 'path/to/A.podspec'
  #
  def self.register_pod_hook(&block)
    @@pod_hook_plugins.push(block) if block
  end

  def self.pod_hook_plugins
    @@pod_hook_plugins
  end

  def self.debug_flag=(flag)
    @@debug_flag = flag
  end

  def self.debug_flag
    @@debug_flag
  end
end



module Pod
  class Specification
    module DSL
      # hook dependency
      alias original_dependency dependency

      def dependency(*args)
        dump_object(args)
        dump_object(self)
        dump_object(self.name)
        dump_object(self.version)

        dump_method(:original_dependency)
        dump_call_stack

        dependency_arg_hash = {}
        dependency_arg_hash[:name] = self.name
        dependency_arg_hash[:version] = self.version

        should_ignore_dependency = false
        PodfileDependencyHook.pod_hook_plugins.each do |plugin|
          should_ignore_dependency = plugin.call(self.name, pod_name, dependency_arg_hash)
        end

        if not should_ignore_dependency
          original_dependency *args
        else

        end
      end
    end
  end

end


