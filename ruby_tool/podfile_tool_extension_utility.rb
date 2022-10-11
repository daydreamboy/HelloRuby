
##
# Store utility methods in this module, which used in Podfile
module PodfileToolUtility
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    ##
    # Get current xcode version
    #
    # @return [String] current xcode version
    # 
    def xcode_version
      # @see https://groups.google.com/g/cocoapods/c/GFMujJUdVrY?pli=1
      `xcrun xcodebuild -version | head -1 | awk '{print $2}'`
    end

    ##
    # check current xcode version > x.y.z
    #
    # @param [String] version_string, e.g. "14.0"
    #
    # @return [Boolean] true if xcode version > x.y.z, false if not
    #
    def xcode_version_greater_than(version_string)
      Gem::Version.new(self.xcode_version) > Gem::Version.new(version_string)
    end

    ##
    # check current xcode version >= x.y.z
    #
    # @param [String] version_string, e.g. "14.0"
    #
    # @return [Boolean] true if xcode version >= x.y.z, false if not
    #
    def xcode_version_greater_than_or_equal(version_string)
      Gem::Version.new(self.xcode_version) >= Gem::Version.new(version_string)
    end
  end
end