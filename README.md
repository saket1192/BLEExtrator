# BLEExtractor

A powerful Swift framework for Bluetooth Low Energy (BLE) device scanning and discovery, featuring Combine integration and SwiftUI support.

## Features

- Asynchronous BLE device scanning with async/await
- Real-time device discovery using Combine framework
- Full SwiftUI integration with diagnostic views
- Bluetooth state monitoring and automatic management
- Comprehensive error handling with custom BLEError types
- Built-in diagnostic tools for debugging BLE issues
- Automatic cleanup and resource management
- Memory-efficient implementation
- Detailed logging with os.log
- Thread-safe implementation
- Support for both iOS and macOS
- Extensive documentation and examples

## Requirements

- iOS 14.0+ / macOS 11.0+
- Swift 5.0+
- Xcode 13.0+

## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'BLEExtractor', '~> 1.1.6'
```

Then run:
```bash
pod install
```

### Swift Package Manager

1. In Xcode, select File > Add Packages...
2. Enter the package repository URL:
   ```
   https://github.com/saket1192/BLEExtractor.git
   ```
3. Select the version or branch you want to use

## Usage

1. Import the framework:
```swift
import BLEExtractor
import Combine
```

2. Create a scanner instance and set up Combine subscribers:
```swift
class BLEViewModel: ObservableObject {
    private let scanner = BLEScanner()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var isScanning = false
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to device discoveries
        scanner.deviceDiscoveryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.handleDiscoveredDevice(device)
            }
            .store(in: &cancellables)
            
        // Subscribe to Bluetooth state changes
        scanner.bluetoothStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.bluetoothState, on: self)
            .store(in: &cancellables)
    }
    
    private func handleDiscoveredDevice(_ device: BLEDevice) {
        // Update device list, avoiding duplicates
        if let index = discoveredDevices.firstIndex(where: { $0.id == device.id }) {
            discoveredDevices[index] = device
        } else {
            discoveredDevices.append(device)
        }
    }
    
    func startScanning() {
        guard !isScanning else { return }
        isScanning = true
        // Start scanning with 30 seconds timeout
        scanner.startScanningWithPublisher(duration: 30)
    }
    
    func stopScanning() {
        isScanning = false
        scanner.stopScan()
    }
}
```

3. Use in SwiftUI:
```swift
struct BLEDeviceListView: View {
    @StateObject private var viewModel = BLEViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.discoveredDevices) { device in
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name ?? "Unknown Device")
                        .font(.headline)
                    Text("RSSI: \(device.rssi) dBm")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("ID: \(device.id.uuidString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("BLE Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                    }) {
                        Text(viewModel.isScanning ? "Stop" : "Scan")
                    }
                }
            }
            .overlay(
                Group {
                    if viewModel.bluetoothState != .poweredOn {
                        BluetoothStatusOverlay(state: viewModel.bluetoothState)
                    }
                }
            )
        }
    }
}

struct BluetoothStatusOverlay: View {
    let state: CBManagerState
    
    var body: some View {
        VStack {
            Image(systemName: "bluetooth.slash")
                .font(.largeTitle)
            Text(stateMessage)
                .multilineTextAlignment(.center)
                .padding()
        }
        .foregroundColor(.white)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .padding()
    }
    
    private var stateMessage: String {
        switch state {
        case .poweredOff:
            return "Bluetooth is turned off. Please enable it in Settings."
        case .unauthorized:
            return "Bluetooth access is not authorized. Please enable it in Settings."
        case .unsupported:
            return "Bluetooth is not supported on this device."
        default:
            return "Bluetooth is not available."
        }
    }
}
```

4. Advanced Usage with Filtering:
```swift
class AdvancedBLEViewModel: ObservableObject {
    private let scanner = BLEScanner()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var isScanning = false
    
    init() {
        setupDeviceDiscovery()
    }
    
    private func setupDeviceDiscovery() {
        // Filter and transform the device stream
        scanner.deviceDiscoveryPublisher
            .filter { device in
                // Only devices with names and RSSI stronger than -70
                device.name != nil && device.rssi > -70
            }
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates { device1, device2 in
                device1.id == device2.id
            }
            .sink { [weak self] device in
                self?.discoveredDevices.append(device)
            }
            .store(in: &cancellables)
    }
    
    func startScanningWithTimeout() {
        guard !isScanning else { return }
        isScanning = true
        // Auto-stop after 1 minute
        scanner.startScanningWithPublisher(duration: 60)
    }
    
    func startContinuousScanning() {
        guard !isScanning else { return }
        isScanning = true
        // Continuous scanning until stopScan is called
        scanner.startScanningWithPublisher()
    }
    
    func stopScanning() {
        isScanning = false
        scanner.stopScan()
    }
}
```

5. Error Handling:
```swift
extension BLEViewModel {
    func handleBluetoothState(_ state: CBManagerState) {
        switch state {
        case .poweredOn:
            // Safe to start scanning
            startScanning()
        case .poweredOff:
            stopScanning()
            // Show alert to enable Bluetooth
            break
        case .unauthorized:
            stopScanning()
            // Show alert to authorize Bluetooth access
            break
        case .unsupported:
            // Show device not supported message
            break
        default:
            stopScanning()
            break
        }
    }
}
```

## Required Permissions

Add the following keys to your app's Info.plist:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to scan for nearby devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to scan for nearby devices</string>
```

## Error Handling

The framework includes proper error handling through the `BLEError` enum:

```swift
public enum BLEError: LocalizedError {
    case bluetoothPoweredOff
    case bluetoothUnauthorized
    case bluetoothUnsupported
    case bluetoothUnknown
    case scanningFailed(String)
}
```

## Latest Changes (v1.1.2)

- Enhanced SwiftUI integration with improved UI components
- Added isScanning state management
- Improved error handling and state management
- Enhanced documentation with comprehensive examples
- Bug fixes and performance improvements

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available under the MIT license. See the LICENSE file for more info. 