// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BLEExtractor",
    platforms: [
        .iOS(.v14), // Minimum iOS version
        .macOS(.v11) // Minimum macOS version if needed
    ],
    products: [
        .library(
            name: "BLEExtractor",
            targets: ["BLEExtractor"]),
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .target(
            name: "BLEExtractor",
            dependencies: []),
        .testTarget(
            name: "BLEExtractorTests",
            dependencies: ["BLEExtractor"]),
    ]
) 