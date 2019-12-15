require 'xcodeproj'
require_relative '../ruby_tool/ruby_tools'

project_path = './Sample/Sample.xcodeproj'
dest_target = 'Framework'

# start code
source_files = []
header_files = []
project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
  # dump_object(target)

  if target.name == dest_target
    source_files = target.source_build_phase.files.to_a.map do |pbx_build_file|
      pbx_build_file.file_ref.real_path.to_s
    end.select do |path|
      path.end_with?(".m", ".mm", ".swift", ".c", ".cpp")
    end.select do |path|
      File.exists?(path)
    end

    header_files = target.headers_build_phase.files.to_a.map do |pbx_build_file|
      pbx_build_file.file_ref.real_path.to_s
    end.select do |path|
      path.end_with?(".h")
    end.select do |path|
      File.exists?(path)
    end
  end
end

puts source_files
puts '------'
puts header_files
