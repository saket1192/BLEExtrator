Pod::Spec.new do |s|
  s.name             = 'BLEExtractor'
  s.version          = '1.1.9'
  s.summary          = '🔵 Modern Bluetooth LE Scanner with SwiftUI & Combine | iOS & macOS'
  s.social_media_url = 'https://twitter.com/saket1192'
  
  s.description      = <<-DESC
# BLEExtractor

🔵 The Modern Bluetooth Low Energy Framework for iOS & macOS

BLEExtractor is a powerful, SwiftUI-first framework that makes Bluetooth LE development a breeze.

## Why BLEExtractor?

### 🎯 Modern Swift Development
* SwiftUI-first approach with beautiful pre-built views
* Combine integration for reactive device updates
* async/await API for modern concurrency
* Protocol-oriented design for flexibility

### 💪 Powerful Features
* Real-time BLE device scanning and monitoring
* Built-in diagnostic and debugging tools
* Automatic state management
* Comprehensive error handling
* Thread-safe by design

### 🛡 Enterprise-Ready
* Production-tested reliability
* Memory-efficient implementation
* Automatic resource cleanup
* Detailed logging system
* Extensive documentation

### 🎨 Developer Experience
* Beautiful SwiftUI diagnostic views
* Clean, intuitive API design
* Type-safe operations
* Extensive code examples
* Comprehensive guides

### 📱 Platform Support
* iOS 14.0+
* macOS 11.0+
* Swift 5.0+
* SwiftUI & UIKit compatible

Perfect for both beginners and advanced developers building Bluetooth LE applications.
                       DESC

  s.homepage         = 'https://github.com/saket1192/BLEExtrator'
  s.screenshots      = 'https://raw.githubusercontent.com/saket1192/BLEExtrator/main/Resources/screenshot1.png'
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