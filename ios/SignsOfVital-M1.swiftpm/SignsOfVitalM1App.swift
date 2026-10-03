import SwiftUI

// M1 — single battery-query experiment. See docs/protocol/M1_BATTERY_EXPERIMENT.md.
// EXPERIMENTAL research tool. Nothing shown here is medically validated.

@main
struct SignsOfVitalM1App: App {
    @StateObject private var model = BatteryProbeModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
