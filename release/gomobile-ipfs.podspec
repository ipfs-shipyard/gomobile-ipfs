Pod::Spec.new do |spec|
  spec.name         = "gomobile-ipfs"
  spec.version      = "<version>"
  spec.summary      = "A peer-to-peer hypermedia protocol designed to make the web faster, safer, and more open."
  spec.description  = <<-DESC
                      Objective C framework for gomobile-ipfs. You should not usually use this pod directly, but instead use the ipfs pod.
                    DESC
  spec.homepage     = "https://github.com/textileio/gomobile-ipfs"
  spec.license      = "MIT"
  spec.author       = { "textile.io" => "contact@textile.io" }
  spec.platform     = :ios, "7.0"
  spec.source       = spec.source = { :http => 'https://github.com/textileio/gomobile-ipfs/releases/download/v<version>/gomobile-ipfs_v<version>_ios-framework.tar.gz' }
  spec.vendored_frameworks = 'Mobile.framework'
  spec.requires_arc = false
  spec.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1', 'OTHER_LDFLAGS[arch=i386]' => '-Wl,-read_only_relocs,suppress' }
end
