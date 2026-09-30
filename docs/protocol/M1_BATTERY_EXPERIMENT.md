# M1 — Single Battery-Query Experiment

Status: **PREPARED FOR ARCHITECT REVIEW. The physical experiment is NOT AUTHORIZED.**
Nobody (including Dana) runs it until the architect reviews this design and the
implementation and gives an explicit GO.

Implementation: [`ios/SignsOfVital-M1.swiftpm/`](../../ios/SignsOfVital-M1.swiftpm/) (separate
Swift Playgrounds app; the M0 project stays passive and untouched — ADR-006).
Experimental and **non-medical**.

## Hypothesis (unproven on H59B)

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
- The app has not been compiled by an agent (no Apple toolchain); first compile is on the iPad.

## Remaining unknowns

- Whether H59B honours command `0x03` at all, or requires pairing/authentication first.
- Whether the checksum and 16-byte framing hold on H59B (H59B ≠ H59_V2.0).
- Response layout: which byte, if any, is the battery level, and its scale.
- Whether `.withResponse` is accepted by this characteristic on this firmware (advertises
  both write types per M0).
- Whether spontaneous notifications exist on `6E400003` before any query.
- Whether the operator's iPad build behaves as expected (never compiled by an agent).
