import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: BatteryProbeModel
    @State private var showConfirm = false

    var body: some View {
        NavigationStack {
            List {
                bannerSection
                statusSection
                if model.selectedName == nil {
                    scanSection
                } else {
                    deviceSection
                    gateSection
                    querySection
                    observationSection
                }
                logSection
            }
            .navigationTitle("M1 Battery Query")
        }
    }

    private var bannerSection: some View {
        Section {
            Text("EXPERIMENTAL — NON-MEDICAL. Sends at most ONE 16-byte battery query, only after two explicit taps. A response is shown as raw bytes and framing checks only; it is not decoded data.")
                .font(.footnote.bold())
                .foregroundStyle(.orange)
        }
    }

    private var statusSection: some View {
        Section("Status") {
            LabeledContent("Bluetooth", value: model.bluetoothState)
            LabeledContent("Connection", value: model.connectionState)
            Button("Log pairing prompt (I tapped Cancel) — aborts", role: .destructive) {
                model.recordPairingPromptCancelled()
            }
        }
    }

    private var scanSection: some View {
        Section {
            if model.isScanning {
                Button("Stop scan") { model.stopScan() }
            } else {
                Button("Start scan") { model.startScan() }
            }
            ForEach(model.sortedScanItems) { item in
                Button {
                    model.connect(item)
                } label: {
                    HStack {
                        Text(item.name).font(.headline)
                        Spacer()
                        Text("RSSI \(item.rssi)").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Nearby devices — tap one to connect (connecting sends nothing)")
        }
    }

    private var deviceSection: some View {
        Section("Selected device") {
            Text(model.selectedName ?? "").font(.headline)
            if model.connectionState == "connected" || model.connectionState == "connecting…" {
                Button("Disconnect", role: .destructive) { model.disconnect() }
            } else {
                Button("Back to scan list") { model.closeDevice() }
            }
        }
    }

    private var gateSection: some View {
        let p = model.preconditions
        return Section("Send preconditions") {
            check("UART service 6E40FFF0 discovered", p.uartServiceDiscovered)
            check("Write characteristic 6E400002 discovered", p.writeCharacteristicDiscovered)
            check("Write characteristic advertises write", p.writeCharacteristicSupportsWrite)
            check("Notify characteristic 6E400003 discovered", p.notifyCharacteristicDiscovered)
            check("Notification subscription confirmed", p.notifySubscribed)
            check("Connection active", p.connectionActive)
            check("Not already sent in this app run", !p.alreadySentThisRun)
            check("Not aborted (no security/pairing condition)", !p.aborted)
        }
    }

    private func check(_ label: String, _ ok: Bool) -> some View {
        Label(label, systemImage: ok ? "checkmark.circle.fill" : "xmark.circle")
            .foregroundStyle(ok ? .green : .secondary)
            .font(.footnote)
    }

    private var querySection: some View {
        Section {
            Button("Prepare battery query (sends nothing yet)") {
                model.requestBatteryQuery()
                showConfirm = model.awaitingConfirmation
            }
            .disabled(!readyForPrepare)
        } header: {
            Text("Battery query — EXPERIMENTAL")
        } footer: {
            Text("Requires architect GO. One request per app run; relaunch the app to repeat. No retries.")
        }
        .confirmationDialog("Send ONE battery query (03 00 … 03) to the band?",
                            isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Send once", role: .destructive) { model.confirmAndSendBatteryQuery() }
            Button("Cancel", role: .cancel) { model.cancelBatteryQuery() }
        } message: {
            Text("Experimental and non-medical. It will not be retried.")
        }
        .onChange(of: showConfirm) { _, isShown in
            // Dismissing the dialog any other way withdraws the confirmation.
            if !isShown && model.awaitingConfirmation { model.cancelBatteryQuery() }
        }
    }

    /// Every precondition except the operator confirmation.
    private var readyForPrepare: Bool {
        var p = model.preconditions
        p.operatorConfirmed = true
        return BatteryQueryGate.evaluate(p) == .allowed
    }

    private var observationSection: some View {
        Section {
            if model.observations.isEmpty {
                Text("No notification received yet.").foregroundStyle(.secondary)
            }
            ForEach(model.observations.reversed()) { o in
                VStack(alignment: .leading, spacing: 2) {
                    Text(o.afterQuery ? "After query" : "Unsolicited (before query)").font(.caption.bold())
                    Text("length: \(o.observation.length)")
                    Text("hex: \(o.observation.hex)")
                    Text(o.observation.summary)
                }
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
            }
        } header: {
            Text("Notifications observed (raw, on screen only)")
        } footer: {
            Text("Never saved. Do not commit or share screenshots of raw values.")
        }
    }

    private var logSection: some View {
        Section {
            if model.log.isEmpty {
                Text("No events yet.").foregroundStyle(.secondary)
            }
            ForEach(model.log.reversed()) { entry in
                Text("\(entry.date.formatted(date: .omitted, time: .standard))  \(entry.text)")
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
        } header: {
            HStack {
                Text("Event log (\(model.log.count), newest first)")
                Spacer()
                Button("Clear") { model.clearLog() }.font(.caption)
            }
        }
    }
}
