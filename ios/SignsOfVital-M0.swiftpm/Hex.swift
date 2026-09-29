import Foundation
import CoreBluetooth

enum Hex {
    /// Raw bytes as uppercase hex pairs, e.g. "0A 1B FF". Empty data → "(empty)".
    static func string(_ data: Data?) -> String {
        guard let data, !data.isEmpty else { return "(empty)" }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    /// UTF-8 text only when every scalar is printable; otherwise nil.
    static func printableUTF8(_ data: Data?) -> String? {
        guard let data, !data.isEmpty,
              let text = String(data: data, encoding: .utf8) else { return nil }
        let printable = !text.unicodeScalars.contains { CharacterSet.controlCharacters.contains($0) }
        return printable ? text : nil
    }
}

enum Props {
    /// Human-readable flags plus the raw bitmask, e.g. "read notify (0x12)".
    static func describe(_ p: CBCharacteristicProperties) -> String {
        var names: [String] = []
        if p.contains(.broadcast) { names.append("broadcast") }
        if p.contains(.read) { names.append("read") }
        if p.contains(.writeWithoutResponse) { names.append("writeWithoutResponse") }
        if p.contains(.write) { names.append("write") }
        if p.contains(.notify) { names.append("notify") }
        if p.contains(.indicate) { names.append("indicate") }
        if p.contains(.authenticatedSignedWrites) { names.append("signedWrite") }
        if p.contains(.extendedProperties) { names.append("extended") }
        let flags = names.isEmpty ? "none" : names.joined(separator: " ")
        return "\(flags) (0x\(String(format: "%02X", p.rawValue)))"
    }
}
