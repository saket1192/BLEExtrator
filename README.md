# BLEExtractor

A Swift framework for easy Bluetooth Low Energy (BLE) device scanning and discovery.

## Features

- Asynchronous BLE device scanning
- Modern Swift concurrency (async/await)
- Proper error handling
- Automatic cleanup and resource management
- Comprehensive logging
- Thread-safe implementation
- Real-time device discovery using Combine

## Requirements

- iOS 14.0+ / macOS 11.0+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

1. In Xcode, select File > Add Packages...
2. Enter the package repository URL:
   ```
   https://github.com/saket1192/BLEExtractor.git
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

3. For real-time device discovery:
```swift
// Set up Combine subscribers
private var cancellables = Set<AnyCancellable>()

// Subscribe to device discoveries
scanner.deviceDiscoveryPublisher
    .sink { device in
        print("Found device: \(device.name ?? "Unnamed")")
        print("RSSI: \(device.rssi)")
    }
    .store(in: &cancellables)

// Start scanning
Task {
    do {
        try await scanner.startScanningWithPublisher()
    } catch {
        print("Scanning error: \(error)")
    }
}
```

4. For batch scanning:
```swift
do {
    let devices = try await scanner.startScan(duration: 5)
    for device in devices {
        print("Found device: \(device.name ?? "Unnamed")")
    }
} catch {
    print("Error: \(error)")
}
```

5. Stop scanning when needed:
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

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

1. Clone the repository
2. Run tests: `xcodebuild test -scheme BLEExtractor`
3. Lint the pod: `pod lib lint`

### Releasing New Versions

1. Update version in BLEExtractor.podspec
2. Commit changes
3. Create and push a new tag:
   ```bash
   git tag 'X.Y.Z'
   git push origin 'X.Y.Z'
   ```
4. Create a new release on GitHub
5. CI/CD will automatically:
   - Run tests
   - Validate podspec
   - Deploy to CocoaPods

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment:

- On every push and pull request:
  - Runs unit tests
  - Validates podspec
- On new releases:
  - Automatically publishes to CocoaPods

## License

This project is available under the MIT license. See the LICENSE file for more info. 