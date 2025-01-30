import Foundation
import CoreBluetooth

/// Represents a discovered Bluetooth Low Energy device
public struct BLEDevice: Identifiable, Hashable {
    /// Unique identifier for the device
    public let id: UUID
    /// Name of the device (if available)
    public let name: String?
    /// Received Signal Strength Indicator
    public let rssi: Int
    /// Advertisement data from the device
    public let advertisementData: [String: Any]
    
    /// Creates a BLE device instance
    /// - Parameters:
    ///   - peripheral: The CoreBluetooth peripheral
    ///   - rssi: The signal strength
    ///   - advertisementData: Additional advertisement data
    public init(peripheral: CBPeripheral, rssi: Int, advertisementData: [String: Any]) {
        self.id = peripheral.identifier
        self.name = peripheral.name
        self.rssi = rssi
        self.advertisementData = advertisementData
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        lhs.id == rhs.id
    }
} 