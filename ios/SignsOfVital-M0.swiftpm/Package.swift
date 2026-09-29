// swift-tools-version: 5.9

// Swift Playgrounds app project for the M0 passive GATT probe.
// Swift Playgrounds may rewrite this file when App Settings are changed on the iPad.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "SignsOfVital M0",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "SoV M0 Probe",
            targets: ["AppModule"],
            bundleIdentifier: "com.dgdana.SignsOfVitalM0",
            teamIdentifier: "",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .heart),
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .bluetoothAlways(purposeString: "Signs of Vital M0 scans for nearby Bluetooth devices and reads the services of the device you select. It sends no commands.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ],
    swiftLanguageVersions: [.version("5")]
)
