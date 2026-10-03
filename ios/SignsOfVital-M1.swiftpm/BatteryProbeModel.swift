import Foundation
import CoreBluetooth

// M1 — one deliberately gated battery query on the UART-style channel.
//
// Boundary (docs/protocol/M1_BATTERY_EXPERIMENT.md):
//   * Only the UART service is discovered; only its write and notify characteristics are used.
//   * The peripheral is never written to on connect, on discovery, on subscription or on any
//     callback. The single transmit call lives in the confirm-and-send method below, which is
//     reachable only from the confirmation button in the UI and re-checks `BatteryQueryGate`
//     against live state first.
//   * No retries, no reconnects, no other commands, no descriptor access, no reads.
//   * Security/pairing/authentication errors abort; they are never worked around.
//   * Nothing is written to disk; all output is in memory and on screen only.

struct ScanItem: Identifiable {
    let id: UUID                     // iOS identifier: used only for list identity, never displayed or logged
    let peripheral: CBPeripheral
    var name: String
    var rssi: Int
}

struct LogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let text: String
}

struct ObservedNotification: Identifiable {
    let id = UUID()
    let date: Date
    let afterQuery: Bool             // false = arrived before our query was sent (unsolicited)
    let observation: ResponseObservation
}

final class BatteryProbeModel: NSObject, ObservableObject {
    static let uartService = CBUUID(string: "6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E")
    static let writeUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    static let notifyUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    @Published private(set) var bluetoothState = "unknown"
    @Published private(set) var isScanning = false
    @Published private(set) var scanItems: [UUID: ScanItem] = [:]
    @Published private(set) var selectedName: String?
    @Published private(set) var connectionState = "not connected"
    @Published private(set) var preconditions = BatteryQueryPreconditions()
    @Published private(set) var awaitingConfirmation = false
    @Published private(set) var observations: [ObservedNotification] = []
    @Published private(set) var log: [LogEntry] = []

    private var central: CBCentralManager!
    private var activePeripheral: CBPeripheral?
    private var uartServiceRef: CBService?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    private var queryAlreadySent = false     // one-shot latch for the whole app run
    private var aborted = false

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    var sortedScanItems: [ScanItem] {
        scanItems.values.sorted { $0.rssi > $1.rssi }
    }

    var gateDecision: GateDecision { BatteryQueryGate.evaluate(preconditions) }

    // MARK: - Operator actions

    func startScan() {
        guard central.state == .poweredOn else {
            record("SCAN not started: Bluetooth state is \(bluetoothState)")
            return
        }
        scanItems.removeAll()
        // Unfiltered, as in M0; the device may not advertise the UART service.
        central.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
        record("SCAN started")
    }

    func stopScan() {
        guard isScanning else { return }
        central.stopScan()
        isScanning = false
        record("SCAN stopped")
    }

    /// Only ever called from an explicit tap on a row in the scan list.
    func connect(_ item: ScanItem) {
        stopScan()
        resetConnectionState()
        activePeripheral = item.peripheral
        selectedName = item.name
        connectionState = "connecting…"
        record("CONNECT requested by operator: \(item.name)")
        central.connect(item.peripheral, options: nil)
    }

    func disconnect() {
        guard let p = activePeripheral else { return }
        record("DISCONNECT requested by operator")
        central.cancelPeripheralConnection(p)
    }

    func closeDevice() {
        guard connectionState != "connected" && connectionState != "connecting…" else { return }
        resetConnectionState()
        activePeripheral = nil
        selectedName = nil
        connectionState = "not connected"
    }

    /// The app cannot see the iOS pairing dialog; the operator records it by hand. This ABORTS the experiment.
    func recordPairingPromptCancelled() {
        record("PAIRING PROMPT shown by iOS — operator tapped Cancel. Experiment ABORTED for this connection.")
        abort()
    }

    func clearLog() { log.removeAll() }

    /// Step 1 of 2. Does not transmit anything; it only asks the UI to show the confirmation.
    func requestBatteryQuery() {
        refreshPreconditions()
        if case .blocked(let reasons) = BatteryQueryGate.evaluate(preconditions.with(confirmed: true)) {
            record("BATTERY QUERY not available: \(reasons.map(\.rawValue).joined(separator: "; "))")
            return
        }
        awaitingConfirmation = true
        refreshPreconditions()
    }

    /// The operator backed out of the confirmation.
    func cancelBatteryQuery() {
        awaitingConfirmation = false
        refreshPreconditions()
        record("Battery query cancelled by operator (nothing sent)")
    }

    /// Step 2 of 2 — the ONLY place in the app that transmits to the peripheral.
    /// Reachable only from the confirmation button. Sends at most once per app run; never retries.
    func confirmAndSendBatteryQuery() {
        refreshPreconditions()
        guard case .allowed = BatteryQueryGate.evaluate(preconditions),
              BatteryRequest.bytes.count == Frame16.length,
              let peripheral = activePeripheral,
              let writeChar = writeCharacteristic else {
            awaitingConfirmation = false
            refreshPreconditions()
            record("BATTERY QUERY BLOCKED at send time — nothing sent")
            return
        }
        awaitingConfirmation = false
        queryAlreadySent = true                     // latch BEFORE the write so nothing can send twice
        refreshPreconditions()
        record("SENDING single battery query (\(Hex.string(BatteryRequest.bytes))) to 6E400002")
        peripheral.writeValue(Data(BatteryRequest.bytes), for: writeChar, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self else { return }
            if !self.observations.contains(where: { $0.afterQuery }) {
                self.record("No notification received within 10 s of the query. NOT retrying.")
            }
        }
    }

    // MARK: - State

    private func resetConnectionState() {
        uartServiceRef = nil
        writeCharacteristic = nil
        notifyCharacteristic = nil
        awaitingConfirmation = false
        aborted = false
        refreshPreconditions()
    }

    private func abort() {
        aborted = true
        awaitingConfirmation = false
        refreshPreconditions()
        if let p = activePeripheral, p.state == .connected || p.state == .connecting {
            central.cancelPeripheralConnection(p)
        }
    }

    /// Rebuilds the preconditions from LIVE CoreBluetooth state.
    private func refreshPreconditions() {
        var p = BatteryQueryPreconditions()
        p.uartServiceDiscovered = uartServiceRef != nil
        p.writeCharacteristicDiscovered = writeCharacteristic != nil
        p.writeCharacteristicSupportsWrite = writeCharacteristic?.properties.contains(.write) == true
        p.notifyCharacteristicDiscovered = notifyCharacteristic != nil
        p.notifySubscribed = notifyCharacteristic?.isNotifying == true
        p.connectionActive = activePeripheral?.state == .connected
        p.operatorConfirmed = awaitingConfirmation
        p.alreadySentThisRun = queryAlreadySent
        p.aborted = aborted
        preconditions = p
    }

    private func record(_ text: String) {
        log.append(LogEntry(date: Date(), text: text))
    }

    /// Security-type ATT errors mean iOS/peripheral wanted pairing or auth: abort, never work around.
    private func isSecurityError(_ error: Error) -> Bool {
        let codes: [CBATTError.Code] = [
            .insufficientAuthentication, .insufficientEncryption, .insufficientEncryptionKeySize
        ]
        if let att = error as? CBATTError { return codes.contains(att.code) }
        return false
    }

    private func handleFailure(_ what: String, _ error: Error) {
        if isSecurityError(error) {
            record("\(what) FAILED: \(error.localizedDescription) — SECURITY REQUIRED. ABORTING (not retried, not worked around).")
            abort()
        } else {
            record("\(what) FAILED: \(error.localizedDescription)")
        }
    }
}

private extension BatteryQueryPreconditions {
    func with(confirmed: Bool) -> BatteryQueryPreconditions {
        var copy = self
        copy.operatorConfirmed = confirmed
        return copy
    }
}

// MARK: - CBCentralManagerDelegate

extension BatteryProbeModel: CBCentralManagerDelegate {
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
        let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "(no name)"
        scanItems[peripheral.identifier] = ScanItem(id: peripheral.identifier, peripheral: peripheral,
                                                    name: name, rssi: RSSI.intValue)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = "connected"
        record("CONNECTED — discovering ONLY the UART service. Nothing is sent.")
        peripheral.delegate = self
        peripheral.discoverServices([Self.uartService])
        refreshPreconditions()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionState = "connection failed"
        record("CONNECT FAILED: \(error?.localizedDescription ?? "no error given")")
        refreshPreconditions()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = "disconnected"
        awaitingConfirmation = false
        // No automatic reconnect: the operator must tap the device again.
        record("DISCONNECTED\(error.map { ": \($0.localizedDescription)" } ?? "")")
        refreshPreconditions()
    }
}

// MARK: - CBPeripheralDelegate

extension BatteryProbeModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            handleFailure("SERVICE DISCOVERY", error)
            return
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == Self.uartService }) else {
            record("UART service NOT found — battery query unavailable.")
            refreshPreconditions()
            return
        }
        uartServiceRef = service
        record("UART service found; discovering its write and notify characteristics only.")
        peripheral.discoverCharacteristics([Self.writeUUID, Self.notifyUUID], for: service)
        refreshPreconditions()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            handleFailure("CHARACTERISTIC DISCOVERY", error)
            return
        }
        let found = service.characteristics ?? []
        writeCharacteristic = found.first { $0.uuid == Self.writeUUID }
        notifyCharacteristic = found.first { $0.uuid == Self.notifyUUID }
        record("Characteristics: write \(writeCharacteristic != nil ? "found" : "MISSING"), notify \(notifyCharacteristic != nil ? "found" : "MISSING")")

        if let n = notifyCharacteristic, n.properties.contains(.notify) {
            peripheral.setNotifyValue(true, for: n)      // subscription only; no data is sent
        } else if notifyCharacteristic != nil {
            record("Notify characteristic does not advertise notify — not subscribing; query stays blocked.")
        }
        refreshPreconditions()
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            handleFailure("NOTIFY SUBSCRIPTION", error)
        } else {
            record("NOTIFY \(characteristic.isNotifying ? "SUBSCRIBED" : "not subscribed")")
        }
        refreshPreconditions()
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            handleFailure("BATTERY QUERY WRITE", error)
        } else {
            record("Write acknowledged by peripheral (ATT write response). Waiting for a notification.")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == Self.notifyUUID else { return }
        if let error {
            handleFailure("NOTIFICATION", error)
            return
        }
        let bytes = [UInt8](characteristic.value ?? Data())
        let observation = ResponseObservation.observe(bytes)
        observations.append(ObservedNotification(date: Date(), afterQuery: queryAlreadySent, observation: observation))
        record("NOTIFICATION \(queryAlreadySent ? "after query" : "UNSOLICITED, before query"): \(observation.summary)")
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // Logged only; discovery is not re-run automatically.
        record("SERVICES CHANGED by peripheral — reconnect required; query unavailable until then.")
        uartServiceRef = nil
        writeCharacteristic = nil
        notifyCharacteristic = nil
        awaitingConfirmation = false
        refreshPreconditions()
    }
}
