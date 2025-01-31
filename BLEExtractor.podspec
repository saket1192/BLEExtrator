Pod::Spec.new do |s|
  s.name             = 'BLEExtractor'
  s.version          = '1.1.7'
  s.summary          = 'Modern Bluetooth LE framework with SwiftUI, Combine, and async/await support for iOS and macOS'
  
  s.description      = <<-DESC
BLEExtractor: Modern Bluetooth Low Energy Framework

A powerful, protocol-oriented Swift framework for BLE device scanning and management, featuring:

✨ Modern Swift Features:
• Full SwiftUI integration with ready-to-use views
• Combine publishers for reactive programming
• Async/await support for modern concurrency
• Protocol-oriented design with value types

🔍 Core Features:
• Real-time BLE device discovery and monitoring
• Comprehensive state management
• Built-in diagnostic tools and debugging views
• Automatic resource cleanup
• Thread-safe implementation

📱 Platform Support:
• iOS 14.0+ and macOS 11.0+
• Native SwiftUI views and modifiers
• Extensive documentation and examples
• Memory-efficient implementation

🛠 Developer Experience:
• Clean, type-safe API
• Detailed logging with os.log
• Custom error handling
• Automatic state restoration
• Example projects and guides
                       DESC

  s.homepage         = 'https://github.com/saket1192/BLEExtrator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'saket kumar' => 'saket1192@gmail.com' }
  s.source           = { :git => 'https://github.com/saket1192/BLEExtrator.git', :tag => s.version.to_s }

  s.platform = :ios, :osx
  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*'
  
  s.frameworks = 'CoreBluetooth', 'Combine'
end 