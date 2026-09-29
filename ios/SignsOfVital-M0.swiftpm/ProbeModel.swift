import Foundation
import CoreBluetooth

// Passive-only CoreBluetooth probe (M0, ADR-002 / ADR-004).
//
// The only GATT operations this file performs are:
//   discoverServices(nil), discoverCharacteristics(nil, for:),
//   readValue(for:) on characteristics with the .read property,
//   setNotifyValue(true, for:) on characteristics with .notify or .indicate.
// It never sends application data to the peripheral, never touches descriptors,
// never reconnects on its own and never connects without a tap from the user.
// Nothing is written to disk: all output lives in memory and is shown on screen.

struct DiscoveredPeripheral: Identifiable {
    let id: UUID                      // iOS peripheral identifier (per-device; do not commit)
    let peripheral: CBPeripheral
    var name: String?
    var localName: String?
    var rssi: Int
    var serviceUUIDs: [String]
    var manufacturerDataHex: String?

    var displayName: String { localName ?? name ?? "(no name)" }
}

struct CharacteristicInfo: Identifiable {
    var id: String { uuid }
    let uuid: String
    let properties: String
    var lastValueHex: String?
    var lastValueUTF8: String?
    var status: String?
}

struct ServiceInfo: Identifiable {
    var id: String { uuid }
    let uuid: String
    let isPrimary: Bool
    var characteristics: [CharacteristicInfo] = []
}

struct LogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
}

final class ProbeModel: NSObject, ObservableObject {
    @Published private(set) var bluetoothState: String = "unknown"
    @Published private(set) var isScanning = false
    @Published private(set) var peripherals: [UUID: DiscoveredPeripheral] = [:]
    @Published private(set) var connected: DiscoveredPeripheral?
    @Published private(set) var connectionState: String = "not connected"
    @Published private(set) var services: [ServiceInfo] = []
    @Published private(set) var log: [LogEntry] = []

    private var central: CBCentralManager!
    private var pendingReads: Set<String> = []   // "service/characteristic" keys awaiting a read response

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    var sortedPeripherals: [DiscoveredPeripheral] {
        peripherals.values.sorted { lhs, rhs in
            let lNamed = lhs.localName != nil || lhs.name != nil
            let rNamed = rhs.localName != nil || rhs.name != nil
            if lNamed != rNamed { return lNamed }
            return lhs.rssi > rhs.rssi
        }
    }

    // MARK: - User actions

    func startScan() {
        guard central.state == .poweredOn else {
            record("SCAN not started: Bluetooth state is \(bluetoothState)")
            return
        }
        peripherals.removeAll()
        // Intentionally unfiltered (withServices: nil) — see M0_PROBE.md.
        central.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
        record("SCAN started (unfiltered)")
    }

    func stopScan() {
        guard isScanning else { return }
        central.stopScan()
        isScanning = false
        record("SCAN stopped")
    }

    /// Only ever called from an explicit tap on a row in the scan list.
    func connect(_ item: DiscoveredPeripheral) {
        stopScan()
        services.removeAll()
        pendingReads.removeAll()
        connected = item
        connectionState = "connecting…"
        record("CONNECT requested by user: \(item.displayName)")
        central.connect(item.peripheral, options: nil)
    }

    func disconnect() {
        guard let item = connected else { return }
        record("DISCONNECT requested by user")
        central.cancelPeripheralConnection(item.peripheral)
    }

    /// The app cannot see the iOS system pairing dialog, so the user records it by hand.
    func recordPairingPromptCancelled() {
        record("PAIRING PROMPT shown by iOS — user tapped Cancel (no pairing/bonding accepted)")
    }

    /// Leaves the (disconnected) device view and returns to the scan list. Does not scan by itself.
    func closeDevice() {
        guard connectionState != "connected" && connectionState != "connecting…" else { return }
        connected = nil
        services.removeAll()
        connectionState = "not connected"
    }

    func clearLog() {
        log.removeAll()
    }

    /// UUIDs and properties only — no values, names or identifiers — for pasting into GATT_MAP.md.
    var gattMapText: String {
        var lines = ["M0 probe GATT capture (UUIDs + properties only)"]
        for service in services {
            lines.append("SERVICE \(service.uuid)\(service.isPrimary ? "" : " (secondary)")")
            for c in service.characteristics {
                lines.append("  CHAR \(c.uuid)  \(c.properties)")
            }
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private func record(_ text: String) {
        log.append(LogEntry(date: Date(), text: text))
    }

    private func key(_ c: CBCharacteristic) -> String {
        "\(c.service?.uuid.uuidString ?? "?")/\(c.uuid.uuidString)"
    }

    private func updateCharacteristic(_ c: CBCharacteristic, _ change: (inout CharacteristicInfo) -> Void) {
        guard let serviceUUID = c.service?.uuid.uuidString,
              let s = services.firstIndex(where: { $0.uuid == serviceUUID }),
              let i = services[s].characteristics.firstIndex(where: { $0.uuid == c.uuid.uuidString })
        else { return }
        change(&services[s].characteristics[i])
    }

    /// Flags ATT errors that usually mean iOS wanted to pair/encrypt. The probe never retries.
    private func describe(_ error: Error) -> String {
        let securityCodes: [CBATTError.Code] = [
            .insufficientAuthentication, .insufficientEncryption, .insufficientEncryptionKeySize
        ]
        if let att = error as? CBATTError, securityCodes.contains(att.code) {
            return "\(error.localizedDescription) — SECURITY REQUIRED (pairing was not accepted; not retried)"
        }
        return error.localizedDescription
    }
}

// MARK: - CBCentralManagerDelegate

extension ProbeModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let names: [CBManagerState: String] = [
            .unknown: "unknown", .resetting: "resetting", .unsupported: "unsupported",
            .unauthorized: "unauthorized", .poweredOff: "powered off", .poweredOn: "powered on"
        ]
        bluetoothState = names[central.state] ?? "state \(central.state.rawValue)"
        if central.state != .poweredOn { isScanning = false }
        record("BLUETOOTH \(bluetoothState)")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let uuids = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
        let mfg = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        peripherals[peripheral.identifier] = DiscoveredPeripheral(
            id: peripheral.identifier,
            peripheral: peripheral,
            name: peripheral.name,
            localName: advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            rssi: RSSI.intValue,
            serviceUUIDs: uuids.map(\.uuidString),
            manufacturerDataHex: mfg.map { Hex.string($0) }
        )
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = "connected"
        record("CONNECTED — discovering all services")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionState = "connection failed"
        record("CONNECT FAILED: \(error.map(describe) ?? "no error given")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = "disconnected"
        pendingReads.removeAll()
        // No automatic reconnect: the user must tap a device again.
        record("DISCONNECTED\(error.map { ": \(describe($0))" } ?? "")")
    }
}

// MARK: - CBPeripheralDelegate

extension ProbeModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            record("SERVICE DISCOVERY FAILED: \(describe(error))")
            return
        }
        let found = peripheral.services ?? []
        services = found.map { ServiceInfo(uuid: $0.uuid.uuidString, isPrimary: $0.isPrimary) }
        record("SERVICES discovered: \(found.count)")
        for service in found {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let serviceUUID = service.uuid.uuidString
        if let error {
            record("CHARACTERISTIC DISCOVERY FAILED for \(serviceUUID): \(describe(error))")
            return
        }
        let found = service.characteristics ?? []
        if let s = services.firstIndex(where: { $0.uuid == serviceUUID }) {
            services[s].characteristics = found.map {
                CharacteristicInfo(uuid: $0.uuid.uuidString, properties: Props.describe($0.properties))
            }
        }
        record("CHARACTERISTICS for \(serviceUUID): \(found.count)")

        for c in found {
            if c.properties.contains(.read) {
                pendingReads.insert(key(c))
                peripheral.readValue(for: c)
            }
            if c.properties.contains(.notify) || c.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: c)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let k = key(characteristic)
        let kind = pendingReads.remove(k) != nil ? "READ" : "NOTIFY"
        let uuid = characteristic.uuid.uuidString
        if let error {
            let message = describe(error)
            updateCharacteristic(characteristic) { $0.status = "\(kind) error: \(message)" }
            record("\(uuid)  \(kind)  ERROR \(message)")
            return
        }
        let hex = Hex.string(characteristic.value)
        let text = Hex.printableUTF8(characteristic.value)
        updateCharacteristic(characteristic) {
            $0.lastValueHex = hex
            $0.lastValueUTF8 = text
        }
        record("\(uuid)  \(kind)  hex=\(hex)\(text.map { "  utf8=\($0)" } ?? "")")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let uuid = characteristic.uuid.uuidString
        if let error {
            let message = describe(error)
            updateCharacteristic(characteristic) { $0.status = "subscribe error: \(message)" }
            record("\(uuid)  SUBSCRIBE FAILED: \(message)")
            return
        }
        let state = characteristic.isNotifying ? "subscribed" : "not subscribed"
        updateCharacteristic(characteristic) { $0.status = state }
        record("\(uuid)  \(state.uppercased())")
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // Logged only; the probe does not re-run discovery by itself.
        record("SERVICES CHANGED by peripheral: \(invalidatedServices.map(\.uuid.uuidString).joined(separator: ", "))")
    }
}
