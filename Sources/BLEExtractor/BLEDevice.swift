import Foundation
import CoreBluetooth

/// Represents a discovered Bluetooth Low Energy device
public struct BLEDevice: Identifiable, Hashable {
    /// The CoreBluetooth peripheral object
    public let peripheral: CBPeripheral
    
    /// Unique identifier for the device
    public var id: UUID { peripheral.identifier }
    
    /// Name of the device (if available)
    public var name: String? { peripheral.name }
    
    /// Received Signal Strength Indicator
    public let rssi: Int
    
    /// Last time the device was seen
    public let lastSeen: Date
    
    /// Advertisement data from the device
    public let advertisementData: [String: Any]
    
    /// Local name from advertisement data
    public var localName: String? {
        advertisementData[CBAdvertisementDataLocalNameKey] as? String
    }
    
    /// Service UUIDs from advertisement data
    public var serviceUUIDs: [CBUUID]? {
        advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
    }
    
    /// Manufacturer data from advertisement data
    public var manufacturerData: Data? {
        advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
    }
    
    /// TX Power Level from advertisement data
    public var txPowerLevel: Int? {
        advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int
    }
    
    /// Is device connectable
    public var isConnectable: Bool {
        if let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber {
            return isConnectable.boolValue
        }
        return false
    }
    
    /// Display name (uses local name or peripheral name)
    public var displayName: String {
        localName ?? name ?? "Unknown Device"
    }
    
    /// Signal strength description
    public var signalStrengthDescription: String {
        if rssi >= -50 { return "Excellent" }
        if rssi >= -65 { return "Good" }
        if rssi >= -80 { return "Fair" }
        return "Poor"
    }
    
    /// Creates a BLE device instance
    /// - Parameters:
    ///   - peripheral: The CoreBluetooth peripheral
    ///   - rssi: The signal strength
    ///   - advertisementData: Additional advertisement data
    public init(peripheral: CBPeripheral, rssi: Int, advertisementData: [String: Any]) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
        self.lastSeen = Date()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        lhs.id == rhs.id
    }
} 