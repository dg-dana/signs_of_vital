import SwiftUI

// M0 — passive BLE/GATT discovery. See docs/protocol/M0_PROBE.md.
// Experimental research tool. Nothing shown here is medically validated.

@main
struct SignsOfVitalM0App: App {
    @StateObject private var probe = ProbeModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(probe)
        }
    }
}
