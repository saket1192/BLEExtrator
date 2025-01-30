Pod::Spec.new do |s|
  s.name             = 'BLEExtractor'
  s.version          = '1.1.1'
  s.summary          = 'A Swift framework for Bluetooth Low Energy (BLE) device scanning and data extraction'
  
  s.description      = <<-DESC
  BLEExtractor is a powerful Swift framework that simplifies Bluetooth Low Energy (BLE) device scanning and data extraction.
  It provides a clean API for discovering BLE devices, managing connections, and handling real-time updates using Combine framework.
  Features include:
  * Real-time device discovery
  * Bluetooth state monitoring
  * Clean and modern Swift API
  * Combine integration for reactive programming
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