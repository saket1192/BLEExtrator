Pod::Spec.new do |s|
  s.name             = 'BLEExtractor'
  s.version          = '1.2.0'
  s.summary          = '🔵 Modern Bluetooth LE Scanner with SwiftUI & Combine | iOS & macOS'
  s.social_media_url = 'https://twitter.com/saket1192'
  s.homepage         = 'https://github.com/saket1192/BLEExtrator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'saket kumar' => 'saket1192@gmail.com' }
  s.source           = { :git => 'https://github.com/saket1192/BLEExtrator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*'
  s.frameworks = 'CoreBluetooth', 'Combine'
  
  s.documentation_url = 'https://github.com/saket1192/BLEExtrator/blob/main/README.md'
end 