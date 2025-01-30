import XCTest
import CoreBluetooth
import Combine
@testable import BLEExtractor

final class BLEScannerTests: XCTestCase {
    var scanner: BLEScanner!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        scanner = BLEScanner()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        scanner = nil
        super.tearDown()
    }
    
    func testScannerInitialization() {
        XCTAssertNotNil(scanner, "Scanner should be initialized")
    }
    
    func testStopScan() {
        // Given
        let scanner = BLEScanner()
        
        // When
        scanner.stopScan()
        
        // Then
        // No crash means success
        XCTAssert(true, "stopScan should complete without crashing")
    }
    
    func testPublishersExist() {
        // Test that publishers are properly initialized
        XCTAssertNotNil(scanner.deviceDiscoveryPublisher, "Device discovery publisher should exist")
        XCTAssertNotNil(scanner.bluetoothStatePublisher, "Bluetooth state publisher should exist")
    }
    
    func testDeviceDiscoveryPublisherSubscription() {
        // Given
        let scanner = BLEScanner()
        var receivedDevice: BLEDevice?
        
        // When
        let subscription = scanner.deviceDiscoveryPublisher
            .sink { device in
                receivedDevice = device
            }
        
        // Then
        XCTAssertNotNil(subscription, "Should be able to subscribe to device discovery publisher")
        subscription.cancel()
    }
    
    // Add more tests as needed
} 