// swift-tools-version: 5.9
// Device-free unit tests for the pure M1 protocol logic (framing, checksum, send gate).
// Sources are symlinks to ../SignsOfVital-M1.swiftpm so there is a single copy of the logic.
// Run on a Mac/Linux Swift toolchain:  swift test --package-path ios/SignsOfVital-M1Tests
// Not part of the iPad app build; requires no Bluetooth device.

import PackageDescription

let package = Package(
    name: "M1Protocol",
    targets: [
        .target(name: "M1Protocol", path: "Sources/M1Protocol"),
        .testTarget(name: "M1ProtocolTests", dependencies: ["M1Protocol"], path: "Tests/M1ProtocolTests")
    ]
)
