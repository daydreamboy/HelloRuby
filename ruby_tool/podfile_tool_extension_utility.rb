
##
# Store utility methods in this module, which used in Podfile
module PodfileToolUtility
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def xcode_version
      `xcrun xcodebuild -version | head -1 | awk '{print $2}'`
    end
  end
end