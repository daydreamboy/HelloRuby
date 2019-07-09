#encoding: utf-8

require 'json'
require_relative '../ruby_tool/ruby_tools'

def json_string_to_object
  $json_string = '
  {
      "podspecs": {
          "WXOpenIMSDK": {
              "path": "../WXOpenIMSDK_Dynamic.podspec",
              "use_framework": true,
              "run_script_paths": "${PROJECT_DIR}/../../Scripts/create_universal_framework.sh",
              "product_name": "WXOpenIMSDKFMWK",
              "build_settings": {
                  "ENABLE_STRICT_OBJC_MSGSEND": "NO"
              }
          },
          "WangXinKit": {
              "path": "../WangXinKit.podspec",
              "use_framework": true,
              "is_dynamic": false,
              "run_script_paths": [
                  "${PROJECT_DIR}/../../Scripts/copy_resource_bundle_to_WangXinKit_framework.sh",
                  "${PROJECT_DIR}/../../Scripts/create_universal_framework.sh"
              ]
          },
          "WXOpenIMUIKit": {
              "path": "../WXOpenIMUIKit_Dynamic.podspec",
              "use_framework": true,
              "product_name": "WXOUIModule",
              "run_script_paths": [
                  "${PROJECT_DIR}/../../Scripts/copy_resource_bundle_to_WXOUIModule_framework.sh",
                  "${PROJECT_DIR}/../../Scripts/create_universal_framework.sh"
              ],
              "dependencies": [ "WXOpenIMSDK" ]
          }
      }
  }
  '

  json_object = JSON.parse($json_string)
  dump_object(json_object)

end


def json_object_to_compact_json_string
  $json_string = '
  {
      "git": "git@gitlab.alibaba-inc.com:wxlib/ywimbridge.git",
      "branch": "develop",
      "podspecs": {
          "YWIMBridge": {
              "use_framework": true,
              "is_dynamic": false
          }
      }
  }
  '

  json_object = JSON.parse($json_string)
  json_string = JSON.dump(json_object)

  dump_object(json_string)
end

def json_object_to_pretty_json_string
  $json_string = '
  {
      "podspecs": {
          "YWIMBridge": {
              "use_framework": true,
              "is_dynamic": false,
              "path": "../ywimbridge.podspec",
              "subspecs": ["Core", "Weex", "WebView", "Windvane"]
          }
      }
  }
  '

  json_object = JSON.parse($json_string)
  json_string = JSON.pretty_generate(json_object)

  dump_object(json_string)
  puts json_string
end


def json_object_to_custom_indentation_json_string
  $json_string = '
  {
      "podspecs": {
          "YWIMBridge": {
              "use_framework": true,
              "is_dynamic": false,
              "path": "../ywimbridge.podspec",
              "subspecs": ["Core", "Weex", "WebView", "Windvane"]
          }
      }
  }
  '

  options = {
      :indent => '    '
  }

  json_object = JSON.parse($json_string)
  json_string = JSON.pretty_generate json_object, options

  dump_object(json_string)
  puts json_string
end


json_string_to_object
puts '================================='
json_object_to_compact_json_string
puts '================================='
json_object_to_pretty_json_string
puts '================================='
json_object_to_custom_indentation_json_string
