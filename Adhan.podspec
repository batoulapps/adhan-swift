Pod::Spec.new do |s|
  s.name             = 'Adhan'
  s.version          = '1.4.0'
  s.summary          = 'High precision Islamic prayer time library.'

  s.description      = <<-DESC
                      Calculate Islamic prayer times for any location
                      using high precision astronomical equations from
                      cited authoritative sources. Written in Swift
                      and also compatible with Objective-C.
                     DESC

  s.homepage         = "https://github.com/batoulapps/adhan-swift"
  s.license          = 'MIT'
  s.author           = { 'Ameir Al-Zoubi' => 'ameir@ameir.com' }
  s.source           = { :git => "https://github.com/batoulapps/adhan-swift.git", :tag => s.version.to_s }

  s.social_media_url = 'https://twitter.com/batoulapps'

  s.swift_versions = ['4.0', '4.1', '4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5']

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'

  s.source_files =  'Sources/**/*.{swift,h}'
  
end
