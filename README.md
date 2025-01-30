# BLEExtractor

A Swift framework for easy Bluetooth Low Energy (BLE) device scanning and discovery.

## Features

- Asynchronous BLE device scanning
- Modern Swift concurrency (async/await)
- Proper error handling
- Automatic cleanup and resource management
- Comprehensive logging
- Thread-safe implementation

## Requirements

- iOS 14.0+ / macOS 11.0+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

1. In Xcode, select File > Add Packages...
2. Enter the package repository URL:
   ```
   https://github.com/YourUsername/BLEExtractor.git
   ```
3. Select the version or branch you want to use

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'BLEExtractor'
```

## Usage

1. Import the framework:
```swift
import BLEExtractor
```

2. Create a scanner instance:
```swift
let scanner = BLEScanner()
```

3. Start scanning for devices:
```swift
do {
    // Scan for 5 seconds
    let devices = try await scanner.startScan(duration: 5)
    
    // Process discovered devices
    for device in devices {
        print("Found device: \(device.name ?? "Unnamed")")
        print("RSSI: \(device.rssi)")
    }
} catch let error as BLEError {
    // Handle specific BLE errors
    print("BLE Error: \(error.localizedDescription)")
} catch {
    // Handle other errors
    print("Error: \(error.localizedDescription)")
}
```

4. Stop scanning when needed:
```swift
scanner.stopScan()
```

## Required Permissions

Add the following keys to your app's Info.plist:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to scan for nearby devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to scan for nearby devices</string>
```

## License

This project is available under the MIT license. See the LICENSE file for more info. 