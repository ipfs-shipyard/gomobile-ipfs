#
# Be sure to run `pod lib lint GomobileIPFS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GomobileIPFS'
  s.version          = '0.1.0'
  s.summary          = 'GomobileIPFS is an ready to use ipfs node for mobile'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       IPFS mobile
                       DESC

  s.homepage         = 'https://github.com/gfanton/GomobileIPFS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gfanton' => 'guilhem@berty.tech' }
  s.source           = { :git => 'https://github.com/gfanton/GomobileIPFS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.ios.vendored_frameworks = 'Frameworks/Ipfs.framework'
  s.source_files = 'GomobileIPFS/Classes/**/*'
  # s.xcconfig = { 'OTHER_LDFLAGS' => '-framework Mobile' }

  # s.resource_bundles = {
  #   'GomobileIPFS' => ['GomobileIPFS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
