Pod::Spec.new do |s|
  s.name             = "Adhan"
  s.version          = "1.0.2"
  s.summary          = "High precision prayer time library."

  s.description      = <<-DESC
                      Adhan is a high precision prayer time
                      library with all astronomical equations
                      from cited authoritative sources. Adhan
                      is well tested and available in multiple
                      languages. For iOS and OS X apps Adhan
                      is available in Swift and with an Objective-C
                      compatible Swift interface.
                     DESC

  s.homepage         = "https://github.com/batoulapps/adhan-swift"
  s.license          = 'MIT'
  s.author           = { 'Batoul Apps' => 'support@batoulapps.com' }
  s.source           = { :git => "https://github.com/batoulapps/adhan-swift.git", :tag => s.version.to_s }

  s.social_media_url = 'https://twitter.com/batoulapps'

  s.swift_version = "4.2"
  s.swift_versions = ['4.0', '4.2', '5.0']

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'

  s.source_files =  'Sources/**/*.{swift,h}'
  
end
