
##
# Store utility methods in this module, which used in Podfile
module PodfileToolUtility
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def xcode_version
      # @see https://groups.google.com/g/cocoapods/c/GFMujJUdVrY?pli=1
      `xcrun xcodebuild -version | head -1 | awk '{print $2}'`
    end
  end
end