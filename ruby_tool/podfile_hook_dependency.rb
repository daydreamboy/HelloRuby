#encoding: utf-8

require_relative 'dump_tool'

class PodfileDependencyHook
  @@pod_hook_plugins = []
  @@debug_flag = false

  ##
  # [Public] Register a hook plugin for the dependency method
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

  def self.do_dependency_hook(dependency_config_file = nil, debug = false)
    PodfileDependencyHook.debug_flag = debug
    PodfileDependencyHook.register_pod_hook do |pod_name, dependency_pod_name, pod_arg_hash|
      false
    end
  end
end



module Pod
  class Specification
    module DSL
      # hook dependency
      alias original_dependency dependency

      def dependency(*args)
        dependency_pod_name = args[0]

        dependency_arg_hash = {}
        dependency_arg_hash[:name_of_pod] = self.name
        dependency_arg_hash[:name_of_dependency] = dependency_pod_name
        dependency_arg_hash[:version] = self.version

        should_ignore_dependency = false
        PodfileDependencyHook.pod_hook_plugins.each do |plugin|
          should_ignore_dependency = plugin.call(self.name, dependency_pod_name, dependency_arg_hash)
        end

        if not should_ignore_dependency
          Log.i("[pod_dependency] install #{dependency_pod_name} for pod #{self.name} with #{args}", PodfileDependencyHook.debug_flag)
          original_dependency *args
        else
          Log.i("Skip dependency #{dependency_pod_name}", PodfileDependencyHook.debug_flag)
        end
      end
    end
  end

end


