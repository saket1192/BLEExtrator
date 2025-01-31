//
//  ContentView.swift
//  BLEExtractorExample
//
//  Created by Saket Kumar - I77194 on 31/01/25.
//

import SwiftUI
import BLEExtractor
import CoreBluetooth
import Combine

struct ContentView: View {
    @StateObject private var viewModel = BLEScannerViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Status Card
                    BluetoothStatusCard(state: viewModel.bluetoothState)
                        .padding()
                    
                    // Device List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.discoveredDevices) { device in
                                DeviceCard(device: device, viewModel: viewModel)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("BLE Scanner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showSettings = true }) {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Button(action: viewModel.clearDevices) {
                            Label("Clear Devices", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.toggleScanning) {
                        Image(systemName: viewModel.isScanning ? "stop.circle.fill" : "play.circle.fill")
                            .foregroundColor(viewModel.isScanning ? .red : .green)
                            .imageScale(.large)
                    }
                    .disabled(viewModel.bluetoothState != .poweredOn)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

struct BluetoothStatusCard: View {
    let state: CBManagerState
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(stateColor)
                    .imageScale(.large)
                
                Text(stateText)
                    .font(.headline)
                
                Spacer()
                
                Text(stateDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if state != .poweredOn {
                Text(actionText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var iconName: String {
        switch state {
        case .poweredOn: return "checkmark.circle.fill"
        case .poweredOff: return "power.circle.fill"
        case .unauthorized: return "exclamationmark.triangle.fill"
        case .unsupported: return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private var stateColor: Color {
        switch state {
        case .poweredOn: return .green
        case .poweredOff: return .red
        case .unauthorized: return .orange
        case .unsupported: return .red
        default: return .gray
        }
    }
    
    private var stateText: String {
        switch state {
        case .poweredOn: return "Ready"
        case .poweredOff: return "Bluetooth Off"
        case .unauthorized: return "Unauthorized"
        case .unsupported: return "Unsupported"
        case .resetting: return "Resetting"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }
    
    private var stateDescription: String {
        switch state {
        case .poweredOn: return "Scanning available"
        case .poweredOff: return "Disabled"
        case .unauthorized: return "No permission"
        case .unsupported: return "Not supported"
        case .resetting: return "Restarting"
        case .unknown: return "Initializing"
        @unknown default: return "Unknown state"
        }
    }
    
    private var actionText: String {
        switch state {
        case .poweredOff: return "Please enable Bluetooth in Settings"
        case .unauthorized: return "Please allow Bluetooth access in Settings"
        case .unsupported: return "This device does not support Bluetooth LE"
        case .resetting: return "Bluetooth is restarting, please wait..."
        case .unknown: return "Initializing Bluetooth..."
        default: return ""
        }
    }
}

struct DeviceCard: View {
    let device: BLEDevice
    @ObservedObject var viewModel: BLEScannerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name ?? "Unknown Device")
                        .font(.headline)
                        .foregroundColor(device.name == nil ? .secondary : .primary)
                    
                    Text(device.id.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                SignalStrengthIndicator(rssi: device.rssi)
            }
            
            Divider()
            
            HStack {
                Label("\(device.rssi) dBm", systemImage: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(viewModel.getLastSeen(for: device), style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct SignalStrengthIndicator: View {
    let rssi: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { index in
                Rectangle()
                    .frame(width: 3, height: 8.0 + Double(index) * 4)
                    .cornerRadius(1.5)
                    .foregroundColor(barColor(for: index))
            }
        }
    }
    
    private func barColor(for index: Int) -> Color {
        let strength = signalStrength(rssi)
        return index <= strength ? .green : Color(.systemGray5)
    }
    
    private func signalStrength(_ rssi: Int) -> Int {
        if rssi >= -50 { return 3 }
        if rssi >= -65 { return 2 }
        if rssi >= -80 { return 1 }
        return 0
    }
}

class BLEScannerViewModel: ObservableObject {
    private let scanner = BLEScanner()
    private var cancellables = Set<AnyCancellable>()
    private var deviceTimestamps: [UUID: Date] = [:]
    
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var isScanning = false
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        scanner.deviceDiscoveryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                self?.handleDiscoveredDevice(device)
            }
            .store(in: &cancellables)
        
        scanner.bluetoothStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.bluetoothState = state
                if state != .poweredOn {
                    self?.isScanning = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleDiscoveredDevice(_ device: BLEDevice) {
        withAnimation {
            if let index = discoveredDevices.firstIndex(where: { $0.id == device.id }) {
                discoveredDevices[index] = device
            } else {
                discoveredDevices.append(device)
            }
            deviceTimestamps[device.id] = Date()
            
            // Sort devices by signal strength
            discoveredDevices.sort { $0.rssi > $1.rssi }
        }
    }
    
    func getLastSeen(for device: BLEDevice) -> Date {
        return deviceTimestamps[device.id] ?? Date()
    }
    
    func toggleScanning() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
        }
    }
    
    func startScanning() {
        isScanning = true
        scanner.startScanningWithPublisher()
    }
    
    func stopScanning() {
        isScanning = false
        scanner.stopScan()
    }
    
    func clearDevices() {
        withAnimation {
            discoveredDevices.removeAll()
            deviceTimestamps.removeAll()
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Scanning")) {
                    NavigationLink(destination: Text("Filter Settings")) {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    NavigationLink(destination: Text("Sort Settings")) {
                        Label("Sort Options", systemImage: "arrow.up.arrow.down.circle")
                    }
                }
                
                Section(header: Text("Display")) {
                    NavigationLink(destination: Text("Display Settings")) {
                        Label("Appearance", systemImage: "textformat.size")
                    }
                    
                    NavigationLink(destination: Text("Units Settings")) {
                        Label("Units", systemImage: "ruler")
                    }
                }
                
                Section(header: Text("Data")) {
                    NavigationLink(destination: Text("Export Settings")) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    NavigationLink(destination: Text("History Settings")) {
                        Label("History", systemImage: "clock")
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    ContentView()
}
