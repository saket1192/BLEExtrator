Pod::Spec.new do |s|
  s.name             = 'BLEExtractor'
  s.version          = '1.1.2'
  s.summary          = 'A powerful Swift framework for Bluetooth Low Energy (BLE) device scanning with Combine support'
  
  s.description      = <<-DESC
  BLEExtractor is a powerful Swift framework that simplifies Bluetooth Low Energy (BLE) device scanning and data extraction.
  It provides a clean, type-safe API for discovering BLE devices, managing connections, and handling real-time updates.
  
  Key Features:
  * Asynchronous BLE device scanning with async/await support
  * Real-time device discovery using Combine framework
  * Bluetooth state monitoring and automatic state management
  * Comprehensive error handling with custom BLEError types
  * Thread-safe implementation with proper resource management
  * Detailed logging using os.log framework
  * Support for both iOS 14.0+ and macOS 11.0+
  * Clean and modern Swift API with protocol-oriented design
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