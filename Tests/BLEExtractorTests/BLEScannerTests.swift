import XCTest
import CoreBluetooth
import Combine
@testable import BLEExtractor

@available(iOS 14.0, macOS 11.0, *)
final class BLEScannerTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func testScannerInitialization() {
        let scanner = BLEScanner(shouldRestoreState: false)
        XCTAssertNotNil(scanner)
    }
    
    func testPublishersExist() {
        let scanner = BLEScanner(shouldRestoreState: false)
        XCTAssertNotNil(scanner.deviceDiscoveryPublisher)
        XCTAssertNotNil(scanner.bluetoothStatePublisher)
    }
    
    func testDeviceDiscoveryPublisherSubscription() {
        let expectation = XCTestExpectation(description: "Bluetooth state update received")
        let scanner = BLEScanner(shouldRestoreState: false)
        
        scanner.bluetoothStatePublisher
            .sink { state in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStopScan() {
        let scanner = BLEScanner(shouldRestoreState: false)
        scanner.startScanningWithPublisher()
        scanner.stopScan()
        XCTAssertFalse(scanner.isScanning)
    }
    
    func testScanningStateManagement() {
        let scanner = BLEScanner(shouldRestoreState: false)
        XCTAssertFalse(scanner.isScanning)
        
        scanner.startScanningWithPublisher()
        // Note: In a real device, we'd need to wait for .poweredOn state
        // For tests, we just verify the state management logic
        scanner.stopScan()
        XCTAssertFalse(scanner.isScanning)
    }
    
    // Add more tests as needed
} 