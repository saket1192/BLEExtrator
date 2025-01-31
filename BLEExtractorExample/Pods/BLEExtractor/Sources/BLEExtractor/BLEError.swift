import Foundation

/// Represents possible errors that can occur during BLE operations
public enum BLEError: LocalizedError {
    /// Bluetooth is powered off
    case bluetoothPoweredOff
    /// Bluetooth is not authorized
    case bluetoothUnauthorized
    /// Bluetooth is unsupported on this device
    case bluetoothUnsupported
    /// Bluetooth state is unknown
    case bluetoothUnknown
    /// Scanning operation failed
    case scanningFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .bluetoothPoweredOff:
            return "Bluetooth is powered off"
        case .bluetoothUnauthorized:
            return "Bluetooth usage is not authorized"
        case .bluetoothUnsupported:
            return "Bluetooth is not supported on this device"
        case .bluetoothUnknown:
            return "Bluetooth state is unknown"
        case .scanningFailed(let message):
            return "Scanning failed: \(message)"
        }
    }
} 