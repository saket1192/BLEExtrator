import Foundation
import CoreBluetooth
import os.log
import Combine

/// A class responsible for scanning Bluetooth Low Energy devices
@available(iOS 14.0, macOS 11.0, *)
public final class BLEScanner: NSObject {
    // MARK: - Properties
    
    private let centralManager: CBCentralManager
    private let logger = Logger(subsystem: "com.bleextractor", category: "BLEScanner")
    private var scanningTask: Task<[BLEDevice], Error>?
    private var discoveredDevices: [UUID: BLEDevice] = [:]
    
    /// Publisher for real-time device discovery
    public let deviceDiscoveryPublisher = PassthroughSubject<BLEDevice, Never>()
    
    /// Publisher for Bluetooth state changes
    public let bluetoothStatePublisher = PassthroughSubject<CBManagerState, Never>()
    
    /// Whether the scanner is currently scanning for devices
    public private(set) var isScanning = false
    
    // MARK: - Public Interface
    
    /// Initialize BLEScanner with optional configuration
    /// - Parameter shouldRestoreState: Whether to restore state between app launches. Default is true.
    /// - Parameter showPowerAlert: Whether to show power alert when Bluetooth is off. Default is true.
    public init(shouldRestoreState: Bool = true, showPowerAlert: Bool = true) {
        var options: [String: Any] = [:]
        
        if showPowerAlert {
            options[CBCentralManagerOptionShowPowerAlertKey] = true
        }
        
        if shouldRestoreState {
            options[CBCentralManagerOptionRestoreIdentifierKey] = "com.bleextractor.centralManager"
        }
        
        self.centralManager = CBCentralManager(delegate: nil, queue: .main, options: options)
        super.init()
        self.centralManager.delegate = self
        
        // Send initial state
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.bluetoothStatePublisher.send(self.centralManager.state)
        }
    }
    
    /// Starts scanning for BLE devices with real-time updates
    /// - Parameter duration: Optional duration in seconds. If nil, scanning continues until stopScan is called
    /// - Throws: BLEError if scanning cannot be started
    public func startScanningWithPublisher(duration: TimeInterval? = nil) {
        logger.info("Attempting to start scanning with publisher...")
        
        guard !isScanning else {
            logger.warning("Scanner is already running")
            return
        }
        
        // Check Bluetooth authorization status on iOS
        #if os(iOS)
        let authStatus = CBCentralManager.authorization
        switch authStatus {
        case .notDetermined:
            logger.error("Bluetooth authorization not determined")
            return
        case .restricted:
            logger.error("Bluetooth access is restricted")
            return
        case .denied:
            logger.error("Bluetooth access is denied")
            return
        case .allowedAlways:
            break
        @unknown default:
            logger.warning("Unknown authorization status")
            break
        }
        #endif
        
        // Check Bluetooth state
        guard centralManager.state == .poweredOn else {
            logger.error("Cannot start scanning: Bluetooth is not powered on. Current state: \(self.centralManager.state.rawValue)")
            bluetoothStatePublisher.send(self.centralManager.state)
            
            switch self.centralManager.state {
            case .poweredOff:
                logger.error("Please turn on Bluetooth in your device settings")
            case .unauthorized:
                logger.error("Please authorize Bluetooth access in settings")
            case .unsupported:
                logger.error("This device does not support Bluetooth LE")
            case .resetting:
                logger.error("Bluetooth is resetting, please wait and try again")
            case .unknown:
                logger.error("Bluetooth state is unknown, please wait and try again")
            default:
                logger.error("Bluetooth is not ready. Please check your device settings")
            }
            return
        }
        
        isScanning = true
        discoveredDevices.removeAll()
        
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true,
            CBCentralManagerScanOptionSolicitedServiceUUIDsKey: []
        ]
        
        centralManager.scanForPeripherals(withServices: nil, options: options)
        logger.info("Started scanning for BLE devices")
        
        if let duration = duration {
            logger.info("Scan will automatically stop after \(duration) seconds")
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.stopScan()
            }
        }
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
        guard isScanning else {
            logger.warning("Scanner is not running")
            return
        }
        
        centralManager.stopScan()
        isScanning = false
        logger.info("Stopped scanning for BLE devices")
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
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    private func stopScanning() {
        centralManager.stopScan()
        centralManager.delegate = nil
    }
}

// MARK: - CBCentralManagerDelegate

@available(iOS 14.0, macOS 11.0, *)
extension BLEScanner: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let stateString = {
            switch central.state {
            case .unknown: return "unknown"
            case .resetting: return "resetting"
            case .unsupported: return "unsupported"
            case .unauthorized: return "unauthorized"
            case .poweredOff: return "powered off"
            case .poweredOn: return "powered on"
            @unknown default: return "unknown state (\(central.state.rawValue))"
            }
        }()
        
        logger.info("Bluetooth state updated to: \(stateString)")
        
        // Always stop scanning if state is not powered on
        if central.state != .poweredOn && isScanning {
            stopScan()
        }
        
        // Send state update on main queue
        DispatchQueue.main.async { [weak self] in
            self?.bluetoothStatePublisher.send(central.state)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // Create device instance
        let device = BLEDevice(peripheral: peripheral, rssi: RSSI.intValue, advertisementData: advertisementData)
        
        // Update device in dictionary
        discoveredDevices[peripheral.identifier] = device
        
        // Log discovery
        logger.info("""
            Discovered device:
            Name: \(peripheral.name ?? "Unknown")
            ID: \(peripheral.identifier)
            RSSI: \(RSSI)
            Advertisement Data: \(advertisementData)
        """)
        
        // Send device update on main queue
        DispatchQueue.main.async { [weak self] in
            self?.deviceDiscoveryPublisher.send(device)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        logger.info("Restoring central manager state: \(dict)")
        
        // Handle restored peripherals if needed
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                logger.info("Restored peripheral: \(peripheral.name ?? "Unknown") (\(peripheral.identifier))")
            }
        }
        
        // Handle restored scan services if needed
        if let services = dict[CBCentralManagerRestoredStateScanServicesKey] as? [CBUUID] {
            logger.info("Restored scan services: \(services)")
        }
        
        // Handle restored scan options if needed
        if let scanOptions = dict[CBCentralManagerRestoredStateScanOptionsKey] as? [String: Any] {
            logger.info("Restored scan options: \(scanOptions)")
        }
    }
} 