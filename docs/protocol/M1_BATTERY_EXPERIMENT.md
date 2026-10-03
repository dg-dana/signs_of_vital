# M1 — Single Battery-Query Experiment

Status: **EXECUTED ONCE ON 2026-10-03 — transport/framing proof SUCCEEDED** (see
[Results](#results-2026-10-03)). Battery payload semantics are **NOT proven**. No further
runs, commands or decoding are authorized without a new architect decision.

Implementation: [`ios/SignsOfVital-M1.swiftpm/`](../../ios/SignsOfVital-M1.swiftpm/) (separate
Swift Playgrounds app; the M0 project stays passive and untouched — ADR-006).
Experimental and **non-medical**.

## Hypothesis (framing supported by M1; payload meaning unproven)

The H59B answers a single 16-byte battery request written to the UART-style channel with a
notification on the paired notify characteristic. The framing rules below come from our
documented understanding of the OpenH59 reference ([`openh59.md`](../research/openh59.md)),
implemented independently (ADR-003). Matching UUIDs do **not** prove the protocol matches.

## Exact channel

```text
SERVICE 6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E   (confirmed by M0)
  WRITE   6E400002-B5A3-F393-E0A9-E50E24DCCA9E  → the single request
  NOTIFY  6E400003-B5A3-F393-E0A9-E50E24DCCA9E  ← response observation
```

Only these two characteristics are used. The app discovers only the UART service (no
`discoverServices(nil)`), performs no reads and no descriptor access, and never references
the `FEE7` service or the `DE5BF72x` channel.

## Frame construction

| Index | Value |
|---|---|
| 0 | `0x03` (command byte, battery hypothesis) |
| 1–14 | `0x00` (default/zero payload) |
| 15 | checksum = (sum of bytes 0–14) mod 256 |

Resulting request (16 bytes): `03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03`

Written once with `.withResponse` (requires the characteristic to advertise `write`; there is
no fallback to another write type) so an ATT error, including a security error, is visible.
Logic: `BatteryFrame.swift`; tested without a device (see Verification).

## One-shot boundary

Nothing is ever sent on connect, discovery, subscription or any callback. Sending requires:

1. Operator connects by tapping a device (no auto-connect, no auto-reconnect).
2. UART service, write characteristic and notify characteristic discovered.
3. Notification subscription confirmed by the peripheral.
4. Connection still active (checked live at send time).
5. Operator step 1: **Prepare battery query** (sends nothing).
6. Operator step 2: **Send once** in a confirmation dialog.
7. Not aborted, and not already sent.

`BatteryQueryGate` (pure, unit-tested) evaluates all of this against live state immediately
before the single `writeValue`. The one-shot latch is set *before* the write and lasts for the
whole app run: a second request needs an app relaunch plus a fresh deliberate action. There
are no retries, no timers that resend, and no other commands.

## Response observation strategy

Every notification on `6E400003` is shown on screen (never saved), tagged
**after query** or **unsolicited (before query)**, with:

- length in bytes and hex;
- byte 0 == `0x03`?
- if length is 16: checksum by *our* rule (sum of bytes 0–14 mod 256) valid or not, and the
  expected value;
- verdict "framing compatible / not compatible with hypothesis".

The UI deliberately shows **no "Battery: X%"**. Interpreting any byte as a percentage needs
independent evidence first (M1 follow-up decision by the architect).

## Abort conditions

Abort = disconnect, block the query for that connection, never work around:

- any `insufficientAuthentication` / `insufficientEncryption` / `insufficientEncryptionKeySize`
  ATT error (discovery, subscription, write or notification);
- an iOS pairing prompt (operator taps **Cancel**, then **Log pairing prompt**);
- service/characteristic missing, or subscription failed (query stays blocked);
- peripheral reports services changed (reconnect required).

Also: no notification within 10 s only logs a message; it never retries.

## Success / failure criteria

- **Success (transport):** the write is acknowledged and a notification arrives after the query.
- **Success (framing hypothesis):** that notification is 16 bytes, byte 0 is `0x03`, and the
  checksum passes under our rule. This supports, but does not prove, the frame model; it is
  not a decoded battery value.
- **Partial:** notification arrives but fails length/command/checksum checks → hypothesis
  wrong or incomplete for H59B; record the *shape* (length, which checks failed), not raw bytes.
- **Failure:** write error, no notification, disconnect, or security abort. No retry; report
  to the architect.

Raw response bytes are private device data and are **not committed**; only the summarized
outcome is recorded in the repository.

## Verification (no device required)

- `python3 ios/scripts/check_m1_vectors.py` — independent re-computation of the vectors, and
  confirmation the same vectors appear in the Swift tests. Runs anywhere.
- `swift test --package-path ios/SignsOfVital-M1Tests` — XCTest for frame construction,
  command-byte placement, zero payload, checksum and 8-bit truncation, malformed
  length/checksum/command-byte flags, and every send-gate condition. Needs a Swift toolchain
  (the sources are symlinks to the app files, so there is one copy of the logic). **Not run
  in the agent environment (no Swift toolchain); run on a Mac before GO.**
- `sh ios/scripts/check_m1_gate.sh` — static guard: exactly one `writeValue`, inside the
  confirm-and-send method with the fixed request, one caller (the confirmation button),
  single `connect`, no prohibited channels/APIs, no logging calls.
- The app has not been compiled by an agent (no Apple toolchain). It **compiled and ran on
  Dana's iPad on 2026-10-03.**

## Results (2026-10-03)

Run by Dana on the iPad (Swift Playgrounds), app compiled from branch
`claude/m0-5-m1-battery-prep` (PR #5). Summarized outcome only — **raw response bytes are
private and deliberately not recorded anywhere in the repository.**

Procedure: Bluetooth permission granted, Bluetooth powered on; Dana manually scanned,
selected the Bionny 4.0, connected, saw **all eight send preconditions green** (UART service,
write characteristic, write property, notify characteristic, subscription confirmed,
connection active, not previously sent, not aborted), tapped **Prepare battery query**, then
**Send once** exactly once. No automatic send.

| Check | Outcome |
|---|---|
| Requests transmitted | Exactly **one** (`0x03` battery request, 16 bytes) |
| ATT write (`.withResponse`) | **Acknowledged** by the peripheral |
| Notification after query | Arrived immediately |
| Length = 16 | **Pass** |
| Byte 0 = `0x03` | **Pass** |
| Checksum: sum(bytes 0–14) mod 256 | **Pass** (our independent rule) |
| Framing vs. hypothesis | **Compatible** |
| Pairing / authentication prompt | None |
| Security (ATT) errors | None |
| Retries | None |
| `FEE7` / `DE5BF72x` interaction | None |

**Conclusion (architect-authorized):** the M1 transport/framing proof succeeded on this
H59B (`H59B_V1.0`, firmware `H59B_1.00.00_260402`). The confirmed UART channel accepts our
independently constructed `0x03` request, the device acknowledges the write, and it returns a
corresponding 16-byte `0x03` notification that satisfies our checksum rule. This is stronger
evidence of H59 protocol compatibility than M0 provided — for this one command and frame shape.

**Not established:**

- **Battery value.** The response payload contains a non-zero byte that *could* be a battery
  level. Its position, meaning and scale are **UNKNOWN**; the value is intentionally not
  recorded. No decoder or "Battery %" UI exists or is authorized. A separate
  architect-approved experiment is required before any battery decoding is accepted.
- **Unsolicited notifications.** Notifications with a *different* command/type byte arrived on
  `6E400003` both before and after the query without any request from us. Their meaning is
  **UNKNOWN**; they are not decoded, acted on or recorded.
- Generalization to any other command, the payload layout of other commands, or other firmware.

## Remaining unknowns

Resolved by M1 (this device/firmware): H59B honours `0x03` without pairing/authentication;
16-byte framing and checksum hold for the `0x03` response; `.withResponse` writes are accepted
on `6E400002`; spontaneous notifications do occur on `6E400003`. Still unknown:

- Response layout: which byte, if any, is the battery level, and its scale.
- Meaning of the unsolicited notifications (different command/type byte) on `6E400003`.
- Whether framing/checksum hold for any other command (none authorized).
- Whether the XCTest suite passes (`swift test` not yet run on a Swift toolchain).
