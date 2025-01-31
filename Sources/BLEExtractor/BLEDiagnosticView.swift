import SwiftUI
import CoreBluetooth
import Combine

@available(iOS 14.0, macOS 11.0, *)
public struct BLEDiagnosticView: View {
    @StateObject private var viewModel = BLEDiagnosticViewModel()
    
    public init() {}
    
    public var body: some View {
        List {
            Section(header: Text("Bluetooth Status")) {
                HStack {
                    Text("Current State:")
                    Spacer()
                    Text(viewModel.bluetoothStateString)
                        .foregroundColor(viewModel.stateColor)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                }
            }
            
            Section(header: Text("Discovered Devices")) {
                if viewModel.discoveredDevices.isEmpty {
                    Text(viewModel.isScanning ? "Searching for devices..." : "No devices found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.discoveredDevices) { device in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name ?? "Unknown Device")
                                .font(.headline)
                            Text("RSSI: \(device.rssi) dBm")
                                .font(.subheadline)
                            Text("ID: \(device.id.uuidString)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section(header: Text("Actions")) {
                Button(action: {
                    viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                }) {
                    HStack {
                        Text(viewModel.isScanning ? "Stop Scanning" : "Start Scanning")
                        Spacer()
                        if viewModel.isScanning {
                            ProgressView()
                        }
                    }
                }
                .disabled(!viewModel.canScan)
            }
            
            Section(header: Text("Debug Information")) {
                Text("SDK Version: \(UIDevice.current.systemVersion)")
                Text("Device Model: \(UIDevice.current.model)")
                if let bundleVersion = Bundle.main.object(forInfoKey: "CFBundleShortVersionString") as? String {
                    Text("App Version: \(bundleVersion)")
                }
            }
        }
        .navigationTitle("BLE Diagnostic")
    }
}

@available(iOS 14.0, macOS 11.0, *)
class BLEDiagnosticViewModel: ObservableObject {
    private let scanner = BLEScanner()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var isScanning = false
    @Published var errorMessage: String?
    
    var canScan: Bool {
        bluetoothState == .poweredOn
    }
    
    var bluetoothStateString: String {
        switch bluetoothState {
        case .unknown: return "Unknown"
        case .resetting: return "Resetting"
        case .unsupported: return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff: return "Powered Off"
        case .poweredOn: return "Powered On"
        @unknown default: return "Unknown State"
        }
    }
    
    var stateColor: Color {
        switch bluetoothState {
        case .poweredOn: return .green
        case .poweredOff: return .red
        case .unauthorized: return .orange
        case .unsupported: return .red
        case .resetting: return .orange
        case .unknown: return .gray
        @unknown default: return .gray
        }
    }
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        scanner.bluetoothStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.bluetoothState = state
                self?.handleBluetoothState(state)
            }
            .store(in: &cancellables)
        
        scanner.deviceDiscoveryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.handleDiscoveredDevice(device)
            }
            .store(in: &cancellables)
    }
    
    private func handleBluetoothState(_ state: CBManagerState) {
        switch state {
        case .poweredOn:
            errorMessage = nil
        case .poweredOff:
            errorMessage = "Please turn on Bluetooth in your device settings"
            stopScanning()
        case .unauthorized:
            errorMessage = "Please authorize Bluetooth access in Settings"
            stopScanning()
        case .unsupported:
            errorMessage = "This device does not support Bluetooth LE"
            stopScanning()
        case .resetting:
            errorMessage = "Bluetooth is resetting, please wait..."
            stopScanning()
        case .unknown:
            errorMessage = "Bluetooth state is unknown, please wait..."
            stopScanning()
        @unknown default:
            errorMessage = "Unknown Bluetooth state"
            stopScanning()
        }
    }
    
    private func handleDiscoveredDevice(_ device: BLEDevice) {
        if let index = discoveredDevices.firstIndex(where: { $0.id == device.id }) {
            discoveredDevices[index] = device
        } else {
            discoveredDevices.append(device)
        }
    }
    
    func startScanning() {
        isScanning = true
        scanner.startScanningWithPublisher(duration: 30)
    }
    
    func stopScanning() {
        isScanning = false
        scanner.stopScan()
    }
} 