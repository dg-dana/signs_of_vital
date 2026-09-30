// swift-tools-version: 5.9

// Swift Playgrounds app project for the M1 single-battery-query experiment.
// PREPARED FOR ARCHITECT REVIEW — the physical experiment is NOT authorized yet.
// Swift Playgrounds may rewrite this file when App Settings are changed on the iPad.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "SignsOfVital M1",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "SoV M1 Battery Query",
            targets: ["AppModule"],
            bundleIdentifier: "com.dgdana.SignsOfVitalM1",
            teamIdentifier: "",
            displayVersion: "0.1",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .heart),
            accentColor: .presetColor(.orange),
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
                .bluetoothAlways(purposeString: "Signs of Vital M1 is an experiment. It connects to the device you select and, only after you explicitly confirm, sends a single battery query.")
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
