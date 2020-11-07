
##
# Get Xcode version on MacOS
# @see https://webdevjourney.wordpress.com/2015/10/15/find-your-xcode-version-using-terminal/
def get_xcode_version
  result = `xcodebuild -version`
  first_line = result.split("\n")[0]
  version = first_line.split(' ')[1]
  version
end

get_xcode_version
