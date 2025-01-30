import Foundation
import CoreBluetooth
import os.log

/// A class responsible for scanning Bluetooth Low Energy devices
public final class BLEScanner: NSObject {
    // MARK: - Properties
    
    private var centralManager: CBCentralManager!
    private let logger = Logger(subsystem: "com.bleextractor", category: "BLEScanner")
    private var scanningTask: Task<[BLEDevice], Error>?
    private var discoveredDevices: [UUID: BLEDevice] = [:]
    
    // MARK: - Public Interface
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: nil, queue: .main)
    }
    
    /// Starts scanning for BLE devices
    /// - Parameter duration: How long to scan for in seconds (default: 10)
    /// - Returns: An array of discovered BLE devices
    /// - Throws: BLEError if scanning cannot be started
    public func startScan(duration: TimeInterval = 10) async throws -> [BLEDevice] {
        // Cancel any existing scanning task
        scanningTask?.cancel()
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                continuation.resume(throwing: BLEError.scanningFailed("Scanner was deallocated"))
                return
            }
            
            self.scanningTask = Task {
                do {
                    let devices = try await withThrowingTaskGroup(of: Void.self) { group in
                        // Start scanning
                        try await self.startScanning()
                        
                        // Add timeout task
                        group.addTask { [weak self] in
                            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                            self?.stopScanning()
                            try Task.checkCancellation()
                        }
                        
                        // Wait for timeout or cancellation
                        try await group.next()
                        
                        // If we get here, scanning completed successfully
                        return Array(self.discoveredDevices.values)
                    }
                    return devices
                } catch is CancellationError {
                    self.stopScanning()
                    throw BLEError.scanningFailed("Scanning was cancelled")
                } catch {
                    self.stopScanning()
                    throw error
                }
            }
            
            Task {
                do {
                    let devices = try await self.scanningTask!.value
                    continuation.resume(returning: devices)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Stops the current scanning operation
    public func stopScan() {
        logger.info("Stopping BLE scan")
        scanningTask?.cancel()
        stopScanning()
    }
    
    // MARK: - Private Methods
    
    private func startScanning() async throws {
        logger.info("Starting BLE scan")
        
        // Check Bluetooth state
        switch centralManager.state {
        case .poweredOn:
            break
        case .poweredOff:
            throw BLEError.bluetoothPoweredOff
        case .unauthorized:
            throw BLEError.bluetoothUnauthorized
        case .unsupported:
            throw BLEError.bluetoothUnsupported
        default:
            throw BLEError.bluetoothUnknown
        }
        
        // Clear previous results
        discoveredDevices.removeAll()
        
        // Set delegate and start scanning
        centralManager.delegate = self
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    private func stopScanning() {
        centralManager.stopScan()
        centralManager.delegate = nil
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEScanner: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.info("Bluetooth state updated: \(central.state.rawValue)")
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = BLEDevice(peripheral: peripheral, rssi: RSSI.intValue, advertisementData: advertisementData)
        discoveredDevices[device.id] = device
        logger.debug("Discovered device: \(device.name ?? "Unnamed") (RSSI: \(device.rssi))")
    }
} 