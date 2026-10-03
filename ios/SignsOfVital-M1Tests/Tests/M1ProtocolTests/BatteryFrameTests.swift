import XCTest
@testable import M1Protocol

// All vectors are locally constructed from the documented hypothesis
// (16 bytes; byte 0 = command; byte 15 = sum of bytes 0...14 mod 256).
// They are NOT device captures and prove nothing about the H59B.
// The same hex strings are cross-checked by ios/scripts/check_m1_vectors.py.

final class BatteryFrameTests: XCTestCase {
    func testBatteryRequestIsExactly16Bytes() {
        XCTAssertEqual(BatteryRequest.bytes.count, 16)
    }

    func testBatteryRequestVector() {
        XCTAssertEqual(Hex.string(BatteryRequest.bytes), "03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03")
    }

    func testCommandBytePlacementAndZeroPayload() {
        let f = BatteryRequest.bytes
        XCTAssertEqual(f[0], 0x03)
        XCTAssertTrue(f[1...14].allSatisfy { $0 == 0 })
    }

    func testChecksumIsSumOfFirst15Bytes() {
        XCTAssertEqual(BatteryRequest.bytes[15], Frame16.checksum(of: Array(BatteryRequest.bytes[0..<15])))
        XCTAssertEqual(Frame16.checksum(of: [0x03] + [UInt8](repeating: 0, count: 14)), 0x03)
    }

    func testChecksumTruncatesTo8Bits() {
        XCTAssertEqual(Frame16.checksum(of: [0xFF, 0x02]), 0x01)
        XCTAssertEqual(Frame16.checksum(of: [UInt8](repeating: 0xFF, count: 15)), 0xF1) // 15*255 = 3825 = 0xEF1
    }

    func testBuildRejectsOversizedPayload() {
        XCTAssertNil(Frame16.build(command: 0x03, payload: [UInt8](repeating: 0, count: 15)))
        XCTAssertNotNil(Frame16.build(command: 0x03, payload: [UInt8](repeating: 0, count: 14)))
    }

    func testBuildWithPayloadVector() {
        let f = Frame16.build(command: 0x03, payload: [0x01, 0x02])!
        XCTAssertEqual(Hex.string(f), "03 01 02 00 00 00 00 00 00 00 00 00 00 00 00 06")
    }
}

final class ResponseObservationTests: XCTestCase {
    func testWellFormedFrameIsCompatible() {
        let o = ResponseObservation.observe(BatteryRequest.bytes)
        XCTAssertTrue(o.lengthIs16)
        XCTAssertEqual(o.commandByteIs03, true)
        XCTAssertEqual(o.checksumValid, true)
        XCTAssertTrue(o.framingCompatibleWithHypothesis)
    }

    func testShortFrameFlagged() {
        let o = ResponseObservation.observe([0x03, 0x00, 0x03])
        XCTAssertFalse(o.lengthIs16)
        XCTAssertNil(o.checksumValid)
        XCTAssertFalse(o.framingCompatibleWithHypothesis)
    }

    func testLongFrameFlagged() {
        XCTAssertFalse(ResponseObservation.observe(BatteryRequest.bytes + [0x00]).framingCompatibleWithHypothesis)
    }

    func testEmptyNotificationFlagged() {
        let o = ResponseObservation.observe([])
        XCTAssertEqual(o.length, 0)
        XCTAssertNil(o.commandByteIs03)
        XCTAssertFalse(o.framingCompatibleWithHypothesis)
        XCTAssertEqual(o.hex, "(empty)")
    }

    func testBadChecksumFlagged() {
        var f = BatteryRequest.bytes
        f[15] = 0x04
        let o = ResponseObservation.observe(f)
        XCTAssertEqual(o.checksumValid, false)
        XCTAssertEqual(o.expectedChecksum, 0x03)
        XCTAssertFalse(o.framingCompatibleWithHypothesis)
    }

    func testWrongCommandByteFlaggedEvenWithValidChecksum() {
        let f = Frame16.build(command: 0x04)!
        let o = ResponseObservation.observe(f)
        XCTAssertEqual(o.checksumValid, true)
        XCTAssertEqual(o.commandByteIs03, false)
        XCTAssertFalse(o.framingCompatibleWithHypothesis)
    }
}

final class BatteryQueryGateTests: XCTestCase {
    private func ready() -> BatteryQueryPreconditions {
        BatteryQueryPreconditions(uartServiceDiscovered: true, writeCharacteristicDiscovered: true,
                                  writeCharacteristicSupportsWrite: true, notifyCharacteristicDiscovered: true,
                                  notifySubscribed: true, connectionActive: true, operatorConfirmed: true,
                                  alreadySentThisRun: false, aborted: false)
    }

    func testDefaultBlocksEverything() {
        guard case .blocked(let reasons) = BatteryQueryGate.evaluate(BatteryQueryPreconditions()) else {
            return XCTFail("default state must be blocked")
        }
        XCTAssertTrue(reasons.contains(.notConfirmedByOperator))
        XCTAssertFalse(reasons.contains(.alreadySent))
    }

    func testAllConditionsMetAllows() {
        XCTAssertEqual(BatteryQueryGate.evaluate(ready()), .allowed)
    }

    func testEachMissingConditionBlocks() {
        let mutations: [(WritableKeyPath<BatteryQueryPreconditions, Bool>, Bool, BlockReason)] = [
            (\.uartServiceDiscovered, false, .uartServiceNotDiscovered),
            (\.writeCharacteristicDiscovered, false, .writeCharacteristicNotDiscovered),
            (\.writeCharacteristicSupportsWrite, false, .writeCharacteristicNotWritable),
            (\.notifyCharacteristicDiscovered, false, .notifyCharacteristicNotDiscovered),
            (\.notifySubscribed, false, .notifyNotSubscribed),
            (\.connectionActive, false, .connectionNotActive),
            (\.operatorConfirmed, false, .notConfirmedByOperator),
            (\.alreadySentThisRun, true, .alreadySent),
            (\.aborted, true, .aborted),
        ]
        for (path, value, reason) in mutations {
            var p = ready()
            p[keyPath: path] = value
            XCTAssertEqual(BatteryQueryGate.evaluate(p), .blocked([reason]), "\(reason)")
        }
    }
}
