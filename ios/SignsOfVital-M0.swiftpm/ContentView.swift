import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var probe: ProbeModel

    var body: some View {
        NavigationStack {
            List {
                statusSection
                if probe.connected == nil {
                    scanSection
                } else {
                    deviceSection
                    gattSection
                }
                logSection
            }
            .navigationTitle("M0 Passive Probe")
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        Section {
            LabeledContent("Bluetooth", value: probe.bluetoothState)
            LabeledContent("Connection", value: probe.connectionState)
            Text("Passive only: no commands are sent. If iOS shows a pairing request, tap Cancel, then tap “Log pairing prompt”.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Log pairing prompt (I tapped Cancel)", role: .destructive) {
                probe.recordPairingPromptCancelled()
            }
        } header: {
            Text("Status")
        } footer: {
            Text("Experimental research tool — not medically validated.")
        }
    }

    private var scanSection: some View {
        Section {
            if probe.isScanning {
                Button("Stop scan") { probe.stopScan() }
            } else {
                Button("Start unfiltered scan") { probe.startScan() }
            }
            ForEach(probe.sortedPeripherals) { item in
                Button {
                    probe.connect(item)
                } label: {
                    PeripheralRow(item: item)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Nearby devices (\(probe.peripherals.count)) — tap one to connect")
        }
    }

    private var deviceSection: some View {
        Section("Selected device") {
            if let item = probe.connected {
                PeripheralRow(item: item)
            }
            if probe.connectionState == "connected" || probe.connectionState == "connecting…" {
                Button("Disconnect", role: .destructive) { probe.disconnect() }
            } else {
                Button("Back to scan list") { probe.closeDevice() }
            }
        }
    }

    private var gattSection: some View {
        Section {
            if probe.services.isEmpty {
                Text("No services discovered yet.").foregroundStyle(.secondary)
            } else {
                Button("Copy GATT map (UUIDs + properties only)") {
                    UIPasteboard.general.string = probe.gattMapText
                }
            }
            ForEach(probe.services) { service in
                VStack(alignment: .leading, spacing: 6) {
                    Text("SERVICE \(service.uuid)\(service.isPrimary ? "" : " (secondary)")")
                        .font(.system(.subheadline, design: .monospaced).bold())
                    ForEach(service.characteristics) { c in
                        CharacteristicRow(info: c)
                    }
                }
                .textSelection(.enabled)
                .padding(.vertical, 4)
            }
        } header: {
            Text("GATT (\(probe.services.count) services)")
        }
    }

    private var logSection: some View {
        Section {
            if probe.log.isEmpty {
                Text("No events yet.").foregroundStyle(.secondary)
            }
            ForEach(probe.log.reversed()) { entry in
                Text("\(entry.date.formatted(date: .omitted, time: .standard))  \(entry.text)")
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
            }
        } header: {
            HStack {
                Text("Event log (\(probe.log.count), newest first)")
                Spacer()
                Button("Clear") { probe.clearLog() }
                    .font(.caption)
            }
        } footer: {
            Text("Shown on screen only; never saved. Values may include the serial number or health data — do not commit or share screenshots of them.")
        }
    }
}

struct PeripheralRow: View {
    let item: DiscoveredPeripheral

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(item.displayName).font(.headline)
                Spacer()
                Text("RSSI \(item.rssi)").font(.caption).foregroundStyle(.secondary)
            }
            Text("id \(item.id.uuidString)")
            if !item.serviceUUIDs.isEmpty {
                Text("adv services \(item.serviceUUIDs.joined(separator: ", "))")
            }
            if let mfg = item.manufacturerDataHex {
                Text("mfg \(mfg)")
            }
        }
        .font(.system(.caption2, design: .monospaced))
        .contentShape(Rectangle())
    }
}

struct CharacteristicRow: View {
    let info: CharacteristicInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("  CHAR \(info.uuid)")
            Text("    \(info.properties)").foregroundStyle(.secondary)
            if let status = info.status {
                Text("    \(status)").foregroundStyle(.orange)
            }
            if let hex = info.lastValueHex {
                Text("    hex=\(hex)")
            }
            if let text = info.lastValueUTF8 {
                Text("    utf8=\(text)")
            }
        }
        .font(.system(.caption, design: .monospaced))
    }
}
