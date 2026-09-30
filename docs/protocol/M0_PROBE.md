# M0 — Passive CoreBluetooth GATT Probe

Status: **EXECUTED SUCCESSFULLY on physical hardware, 2026-09-30.** Passive-only boundary
approved by architect (PR #2, merged) — Swift Playgrounds app project
[`ios/SignsOfVital-M0.swiftpm/`](../../ios/SignsOfVital-M0.swiftpm/).

## Execution result (2026-09-30)

Run on Dana's iPad against the Bionny 4.0:

- Package opened from Working Copy in Swift Playgrounds and **compiled successfully**.
- CoreBluetooth initialized; Bluetooth reported `powered on`.
- Bionny 4.0 was discovered by the unfiltered scan; connection succeeded.
- GATT discovery succeeded: 4 services, sanitized UUID/property map captured
  (recorded in [`GATT_MAP.md`](GATT_MAP.md) section A).
- Permitted passive operations performed: reads of read-only characteristics and
  notify/indicate subscriptions (`FEA1` notify and `FEA2` indicate succeeded; a read
  of `FEC9` returned `The attribute could not be found.` — observation for this
  device/firmware only).
- Hardware `H59B_V1.0` and firmware `H59B_1.00.00_260402` independently re-confirmed
  by CoreBluetooth.
- **No application-level BLE command write was issued.**
- M0 achieved its intended passive-discovery goal. **M0 = successful.**

This is GATT topology only. It does not decode the Bionny measurement protocol, and
writable characteristics in the map are not authorization to write. Nothing beyond M0
is authorized; M1 is subject to architect review.

## Purpose

Independently capture the Bionny H59B's real GATT map with CoreBluetooth,
so that [`GATT_MAP.md`](GATT_MAP.md) can move entries into **CONFIRMED** —
without sending any application-level data to the band.

## Permitted operations

- Create `CBCentralManager`; wait for `.poweredOn`.
- `scanForPeripherals(withServices: nil)` — intentionally unfiltered.
- Show per discovered peripheral: advertised/local name, iOS peripheral identifier,
  RSSI, advertised service UUIDs, manufacturer data as hex.
- Let Dana select the Bionny → `stopScan()` → `connect`. The app never connects
  on its own (no auto-connect by name/identifier, no auto-reconnect).
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

## Pairing / bonding prompt rule

The probe never asks for pairing, but iOS may show a system pairing dialog by itself
when a read or subscribe hits a characteristic that requires encryption.

- Dana **must tap Cancel**. Never accept pairing or bonding in M0.
- Dana then taps **"Log pairing prompt (I tapped Cancel)"** in the app, so the
  event appears in the on-screen log with a timestamp.
- The probe also flags ATT errors `insufficientAuthentication`,
  `insufficientEncryption` and `insufficientEncryptionKeySize` as
  "SECURITY REQUIRED" in the log. It does **not** retry the operation.
- Record in the M0 findings which characteristic(s) triggered the prompt.
- If the Bionny ever appears under iOS Settings → Bluetooth → My Devices as
  paired, choose "Forget This Device" and record that it happened.

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

Outcome of the 2026-09-30 run:

1. Bionny found by unfiltered scan and connected. — **Met**
2. Complete service + characteristic list captured with exact UUIDs and properties. — **Met** (4 services)
3. Hardware `H59B_V1.0` and firmware `H59B_1.00.00_260402` re-confirmed via CoreBluetooth reads. — **Met**
4. Notify/indicate subscriptions succeed (or failures recorded). — **Met** (`FEA1` notify, `FEA2` indicate succeeded)
5. Any spontaneous notifications recorded (hex only). — **Not recorded**: no payloads were supplied or committed; raw values stay out of the repo.
6. `GATT_MAP.md` updated: probe-captured UUIDs promoted to CONFIRMED; no serial or identifiers committed. — **Met** by this documentation update
7. Confirmed zero application-level writes were issued. — **Met** (none issued; static guard also enforces this)

Pairing prompt: none was reported in the M0 results supplied to this update; the
pairing-prompt rule above remains in force for any future run.

## Build path and passive check

- Built and run with Swift Playgrounds on Dana's iPad (ADR-005); repo synced via
  Working Copy. See [`ios/README.md`](../../ios/README.md).
- Static guard: `sh ios/scripts/check_m0_passive.sh` fails if the project uses any
  write, descriptor, L2CAP, identifier-based retrieval, state-restoration or
  file-persistence API, or has more than one `connect` call.
