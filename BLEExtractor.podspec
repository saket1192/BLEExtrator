Pod::Spec.new do |spec|
  spec.name         = "BLEExtractor"
  spec.version      = "1.0.2"
  spec.summary      = "A Swift framework for easy Bluetooth Low Energy (BLE) device scanning and discovery"
  spec.description  = <<-DESC
                     BLEExtractor is a modern Swift framework that simplifies BLE device scanning in iOS applications.
                     It provides async/await support, proper error handling, and comprehensive logging.
                     
                     Key features:
                     * Asynchronous BLE device scanning
                     * Modern Swift concurrency (async/await)
                     * Proper error handling
                     * Automatic cleanup and resource management
                     * Comprehensive logging
                     * Thread-safe implementation
                     DESC
                     
  spec.homepage     = "https://github.com/saket1192/BLEExtrator"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "saket kumar" => "saket1192@gmail.com" }
  
  spec.ios.deployment_target = "14.0"
  spec.osx.deployment_target = "11.0"
  spec.swift_version = "5.5"
  
  spec.source       = { :git => "https://github.com/saket1192/BLEExtrator.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/BLEExtractor/**/*.swift"
  
  spec.framework    = "CoreBluetooth"
  spec.requires_arc = true
end 