import Foundation

// Pure protocol logic for the M1 battery-query experiment. Foundation only — no
// CoreBluetooth — so it is unit-testable without a device.
//
// Everything here is an UNPROVEN HYPOTHESIS about the H59B (docs/protocol/M1_BATTERY_EXPERIMENT.md):
//   * frames are 16 bytes;
//   * byte 0 is a command byte (0x03 = battery query);
//   * byte 15 is the sum of bytes 0...14, truncated to 8 bits.
// Implemented independently from the documented understanding (ADR-003).

enum Frame16 {
    static let length = 16
    static let checksumIndex = 15

    /// Sum of the given bytes truncated to 8 bits. The hypothesis applies it to bytes 0...14.
    static func checksum(of bytes: [UInt8]) -> UInt8 {
        bytes.reduce(0) { $0 &+ $1 }
    }

    /// Command byte, payload zero-padded to 14 bytes, then checksum. Nil if the payload is too long.
    static func build(command: UInt8, payload: [UInt8] = []) -> [UInt8]? {
        guard payload.count <= length - 2 else { return nil }
        var frame = [UInt8](repeating: 0, count: length)
        frame[0] = command
        for (i, b) in payload.enumerated() { frame[1 + i] = b }
        frame[checksumIndex] = checksum(of: Array(frame[0..<checksumIndex]))
        return frame
    }
}

/// The one and only request the M1 app can transmit.
enum BatteryRequest {
    static let commandByte: UInt8 = 0x03
    /// 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03
    static let bytes: [UInt8] = Frame16.build(command: commandByte) ?? []
}

enum Hex {
    /// Uppercase hex pairs, e.g. "0A 1B FF". Empty → "(empty)".
    static func string(_ bytes: [UInt8]) -> String {
        bytes.isEmpty ? "(empty)" : bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

/// What we can honestly say about a received notification. It is NOT decoded data.
struct ResponseObservation: Equatable {
    let length: Int
    let hex: String
    let lengthIs16: Bool
    let commandByteIs03: Bool?      // nil when the notification is empty
    let checksumValid: Bool?        // nil unless the length is 16
    let expectedChecksum: UInt8?    // computed by our rule; nil unless the length is 16

    /// True only if all three hypothesis checks pass. Says nothing about the payload's meaning.
    var framingCompatibleWithHypothesis: Bool {
        lengthIs16 && commandByteIs03 == true && checksumValid == true
    }

    var summary: String {
        var parts = ["length \(length)\(lengthIs16 ? " (= 16)" : " (≠ 16, hypothesis not met)")"]
        if let c = commandByteIs03 { parts.append(c ? "byte0 = 0x03" : "byte0 ≠ 0x03") }
        if let v = checksumValid { parts.append(v ? "checksum OK" : "checksum MISMATCH") }
        parts.append(framingCompatibleWithHypothesis
                     ? "framing COMPATIBLE with hypothesis (not a decoded battery value)"
                     : "framing NOT compatible with hypothesis")
        return parts.joined(separator: "; ")
    }

    static func observe(_ bytes: [UInt8]) -> ResponseObservation {
        let is16 = bytes.count == Frame16.length
        var checksumValid: Bool?
        var expected: UInt8?
        if is16 {
            let e = Frame16.checksum(of: Array(bytes[0..<Frame16.checksumIndex]))
            expected = e
            checksumValid = (bytes[Frame16.checksumIndex] == e)
        }
        return ResponseObservation(
            length: bytes.count,
            hex: Hex.string(bytes),
            lengthIs16: is16,
            commandByteIs03: bytes.first.map { $0 == BatteryRequest.commandByte },
            checksumValid: checksumValid,
            expectedChecksum: expected
        )
    }
}
