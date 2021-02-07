// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UDPToTCPSwift",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Kitura/BlueSocket.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UDPToTCPSwift",
            dependencies: [
                "Socket",
                "ArgumentParser",
                "Logging"
            ]),
        .testTarget(
            name: "UDPToTCPSwiftTests",
            dependencies: ["UDPToTCPSwift"]),
    ]
)
