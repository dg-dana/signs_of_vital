# M0 — Passive CoreBluetooth GATT Probe

Status: **design approved by architect; not implemented** (no verified Apple build path yet).

## Purpose

Independently capture the Bionny H59B's real GATT map with CoreBluetooth,
so that [`GATT_MAP.md`](GATT_MAP.md) can move entries into **CONFIRMED** —
without sending any application-level data to the band.

## Permitted operations

- Create `CBCentralManager`; wait for `.poweredOn`.
- `scanForPeripherals(withServices: nil)` — intentionally unfiltered.
- Show per discovered peripheral: advertised/local name, iOS peripheral identifier,
  RSSI, advertised service UUIDs, manufacturer data as hex.
- Let Dana select the Bionny → `stopScan()` → `connect`.
- `discoverServices(nil)`; `discoverCharacteristics(nil, for:)` for every service.
- Record per characteristic: exact `uuid.uuidString`, flags `read`, `write`,
  `writeWithoutResponse`, `notify`, `indicate`, and the raw property bitmask.
- `readValue(for:)` **only** when the characteristic has the READ property.
- `setNotifyValue(true, for:)` when it has NOTIFY or INDICATE (ADR-004).
- Read standard Device Information (0x180A) values.

## Prohibited operations

- Any `writeValue(_:for:type:)` of application data (characteristic or descriptor).
- Manual CCCD descriptor manipulation.
- Any H59 command (including battery `0x03`, set time `0x01`, realtime, HR logging).
- Authenticating to or sending anything on the "bc" (`DE5BF72x`) channel.
- Changing any device setting; sending arbitrary packets.

## Expected output (displayed on screen)

One line per event:

```text
<timestamp>  <characteristic UUID>  READ|NOTIFY  hex=<bytes>  utf8=<text if printable>
```

Plus a structured service → characteristic → properties tree.
UTF-8 is shown only when the bytes decode to printable text.

## Privacy handling

- Output is **displayed only**; raw BLE output is not written to disk in M0.
- Serial Number (0x2A25) may appear on screen but is never saved, documented,
  committed, or intentionally kept in screenshots.
- The iOS peripheral identifier and manufacturer data are per-device values:
  do not commit them.
- If any capture is ever saved later, it goes under `captures/` or `logs/` (gitignored).
- Notifications may contain health data; treat all payloads as private.

## Success criteria

1. Bionny found by unfiltered scan and connected.
2. Complete service + characteristic list captured with exact UUIDs and properties.
3. Hardware `H59B_V1.0` and firmware `H59B_1.00.00_260402` re-confirmed via CoreBluetooth reads.
4. Notify/indicate subscriptions succeed (or failures recorded).
5. Any spontaneous notifications recorded (hex only).
6. `GATT_MAP.md` updated: probe-captured UUIDs promoted to CONFIRMED; no serial or identifiers committed.
7. Confirmed zero application-level writes were issued.

## Blocker

No verified way yet to build and install a Swift app on Dana's iPhone
(no confirmed Mac/Xcode or cloud macOS path). Architect decision pending.
