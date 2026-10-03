#!/usr/bin/env python3
"""Device-free cross-check of the M1 framing hypothesis (docs/protocol/M1_BATTERY_EXPERIMENT.md).

Independent re-computation of the locally constructed test vectors, plus a check that the
same hex strings appear in the Swift unit tests. Vectors are NOT device captures.
Usage: python3 ios/scripts/check_m1_vectors.py   (from the repository root)
"""
import pathlib
import sys

TEST_FILE = pathlib.Path("ios/SignsOfVital-M1Tests/Tests/M1ProtocolTests/BatteryFrameTests.swift")


def build(command, payload=b""):
    assert len(payload) <= 14
    body = bytes([command]) + payload + bytes(14 - len(payload))
    return body + bytes([sum(body) & 0xFF])


def hexs(b):
    return " ".join(f"{x:02X}" for x in b)


vectors = {
    "battery request": (build(0x03), "03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03"),
    "payload 01 02": (build(0x03, bytes([1, 2])), "03 01 02 00 00 00 00 00 00 00 00 00 00 00 00 06"),
}
ok = True
swift = TEST_FILE.read_text()
for name, (frame, expected) in vectors.items():
    good = len(frame) == 16 and hexs(frame) == expected and expected in swift
    print(("OK   " if good else "FAIL ") + f"{name}: {hexs(frame)}")
    ok &= good

# Truncation: sum of fifteen 0xFF bytes = 3825 = 0xEF1 -> 0xF1 ; 0xFF + 0x02 -> 0x01
for data, want in ((bytes([0xFF] * 15), 0xF1), (bytes([0xFF, 0x02]), 0x01)):
    good = (sum(data) & 0xFF) == want
    print(("OK   " if good else "FAIL ") + f"checksum truncation -> {want:02X}")
    ok &= good

# M1.1: payload positions are bytes 1..14 only (never command byte 0 or checksum byte 15).
frame = build(0x03, bytes([1, 2]))
positions = {i: frame[i] for i in range(1, 15)}
good = (list(positions) == list(range(1, 15)) and positions[1] == 1 and positions[2] == 2
        and "PayloadPositionTests" in swift and "Array(1...14)" in swift)
print(("OK   " if good else "FAIL ") + "payload positions 1..14 (M1.1)")
ok &= good

sys.exit(0 if ok else 1)
