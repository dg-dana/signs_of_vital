import Foundation

// Pure send gate for the single M1 battery query. The CoreBluetooth layer fills in
// `BatteryQueryPreconditions` from LIVE state immediately before the write and
// transmits only if `evaluate` returns `.allowed`.

struct BatteryQueryPreconditions: Equatable {
    var uartServiceDiscovered = false
    var writeCharacteristicDiscovered = false
    var writeCharacteristicSupportsWrite = false   // must advertise .write (no fallback to other write types)
    var notifyCharacteristicDiscovered = false
    var notifySubscribed = false                   // subscription confirmed by the peripheral
    var connectionActive = false
    var operatorConfirmed = false                  // explicit second step, single use
    var alreadySentThisRun = false                 // one-shot latch for the whole app run
    var aborted = false                            // security/pairing/auth condition seen
}

enum BlockReason: String, Equatable, CaseIterable {
    case uartServiceNotDiscovered = "UART service not discovered"
    case writeCharacteristicNotDiscovered = "write characteristic not discovered"
    case writeCharacteristicNotWritable = "write characteristic does not advertise write"
    case notifyCharacteristicNotDiscovered = "notify characteristic not discovered"
    case notifyNotSubscribed = "notification subscription not confirmed"
    case connectionNotActive = "connection not active"
    case notConfirmedByOperator = "operator has not confirmed"
    case alreadySent = "query already sent in this app run (relaunch app to repeat)"
    case aborted = "aborted after a security/pairing/authentication condition"
}

enum GateDecision: Equatable {
    case allowed
    case blocked([BlockReason])
}

enum BatteryQueryGate {
    static func evaluate(_ p: BatteryQueryPreconditions) -> GateDecision {
        var reasons: [BlockReason] = []
        if !p.uartServiceDiscovered { reasons.append(.uartServiceNotDiscovered) }
        if !p.writeCharacteristicDiscovered { reasons.append(.writeCharacteristicNotDiscovered) }
        if !p.writeCharacteristicSupportsWrite { reasons.append(.writeCharacteristicNotWritable) }
        if !p.notifyCharacteristicDiscovered { reasons.append(.notifyCharacteristicNotDiscovered) }
        if !p.notifySubscribed { reasons.append(.notifyNotSubscribed) }
        if !p.connectionActive { reasons.append(.connectionNotActive) }
        if !p.operatorConfirmed { reasons.append(.notConfirmedByOperator) }
        if p.alreadySentThisRun { reasons.append(.alreadySent) }
        if p.aborted { reasons.append(.aborted) }
        return reasons.isEmpty ? .allowed : .blocked(reasons)
    }
}
