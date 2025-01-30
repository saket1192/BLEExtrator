import XCTest
import CoreBluetooth
@testable import BLEExtractor

final class BLEScannerTests: XCTestCase {
    var scanner: BLEScanner!
    
    override func setUp() {
        super.setUp()
        scanner = BLEScanner()
    }
    
    override func tearDown() {
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
    
    // Add more tests as needed
} 