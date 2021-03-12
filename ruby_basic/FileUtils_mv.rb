require 'fileutils'

src_path = './test/1.txt'
dest_path = './test/test2/2.txt'
src_path_copied = File.dirname(src_path) + File.basename(src_path) + '.copy'

# Note: make folders for the dest_path
FileUtils.mkdir_p File.dirname dest_path

# Note: make a copied file to save the original file
FileUtils.cp src_path, src_path_copied
# Note: move the copied file to the dest file
FileUtils.mv src_path_copied, dest_path
