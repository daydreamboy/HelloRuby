#encoding: utf-8

require_relative 'dump_tool'

class PodfileHook
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
  class Podfile
    module DSL
      # hook pod
      alias original_pod pod

      def pod(*args)
        dump_object(args)
        pod_name = args[0]
        pod_arg_hash = {}

        if args[1] and args[1].is_a?(Hash)
          pod_arg_hash.merge(args[1])
        elsif args[1] and args[1].is_a?(String)
          pod_arg_hash[:version] = args[1]
        end

        should_ignore_pod = false
        target_name = current_target_definition.name if current_target_definition
        PodfileHook.pod_hook_plugins.each do |plugin|
          should_ignore_pod = plugin.call(target_name, pod_name, pod_arg_hash)
        end

        if not should_ignore_pod
          # Note: check :path first and remove :version
          # Case 1: :path and :version both exist, only :path is used, pass hash
          # Case 2: :path not exists and :version exists, use :version, pass string
          # Case 2: :path and :version both not exists, pass hash
          if pod_arg_hash[:path]
            pod_arg_hash[:version] = nil
            pod_rest_args = pod_arg_hash
          elsif pod_arg_hash[:version]
            pod_rest_args = pod_arg_hash[:version]
          else
            pod_arg_hash[:version] = nil
            pod_rest_args = pod_arg_hash
          end

          if pod_rest_args.is_a? String or pod_rest_args.is_a? Hash
            Log.d("[pod_hook] install #{pod_name} for target #{target_name}, with #{pod_rest_args}", PodfileHook.debug_flag)
            original_pod pod_name, pod_rest_args
          else
            Log.e("[pod_hook] unknown pod args type: #{pod_rest_args} in #{pod_name} #{target_name}", PodfileHook.debug_flag)
          end
        else
          Log.d("Skip pod #{pod_name}", PodfileHook.debug_flag)
        end
      end
    end
  end
end
