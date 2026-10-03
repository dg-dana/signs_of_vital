# Current State

Concise technical checkpoint. Experimental research project — wearable readings are
**not** medically validated.

## Device

- Product: Bionny 4.0 health armband.
- Hardware revision: `H59B_V1.0` (Device Information; nRF Connect, re-confirmed by M0 CoreBluetooth probe).
- Firmware revision: `H59B_1.00.00_260402` (Device Information; nRF Connect, re-confirmed by M0 CoreBluetooth probe).
- Connectable over BLE. M0 probe confirmed 4 GATT services: UART-style `6E40FFF0-…`,
  proprietary `DE5BF728-…` (holds `DE5BF72A`/`DE5BF729`), Device Information `180A`,
  and `FEE7`. Full map: [`GATT_MAP.md`](protocol/GATT_MAP.md) section A.

## Research state

- OpenH59 (H59_V2.0 reference) reviewed: [`docs/research/openh59.md`](research/openh59.md).
- Protocol compatibility with H59B: **supported for the `0x03` request/response** by M1
  (16-byte framing, command byte echo, checksum rule all held). Not proven for any other command.
- Battery payload semantics: **NOT proven** (no byte is accepted as battery %). M1.1 is designed
  to test this: [`M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`](protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md)
  (**NOT EXECUTED**).
- The Bionny measurement protocol is **not decoded**. Unsolicited UART notifications with a
  different command/type byte were seen; their meaning is unknown.
- GATT evidence levels: [`docs/protocol/GATT_MAP.md`](protocol/GATT_MAP.md).

## Implementation

- **M0 passive probe successfully executed on physical hardware on 2026-09-30**
  (iPad, Swift Playgrounds; `ios/SignsOfVital-M0.swiftpm/`, merged via PR #2). Compiled,
  Bluetooth powered on, Bionny 4.0 discovered and connected, GATT discovered, passive
  reads/subscriptions done, sanitized capture recorded. No application-level writes.
- Observed: `FEA1` notify and `FEA2` indicate subscriptions succeeded; reading `FEC9`
  returned `The attribute could not be found.` (this device/firmware only, not proof it is
  universally unreadable).
- Passive-only static guard: `sh ios/scripts/check_m0_passive.sh`.
- **M1 executed successfully on physical hardware on 2026-10-03** (iPad, Swift Playgrounds;
  `ios/SignsOfVital-M1.swiftpm/`, PR #5). Exactly one gated `0x03` battery query sent by
  explicit operator action; ATT write acknowledged; a 16-byte `0x03` notification arrived and
  passed our checksum rule. No pairing prompt, security error, retry, `FEE7` or `DE5BF72x`
  interaction. Raw response bytes are not recorded. Details:
  [`M1_BATTERY_EXPERIMENT.md`](protocol/M1_BATTERY_EXPERIMENT.md#results-2026-10-03).
- M1.1 preparation (display-only, send path unchanged): the M1 app shows `0x03` payload bytes 1–14
  by position, with no hex. The guard was strengthened (fixed `0x03` only, no decoder/percent UI, no
  raw bytes in the log/UI/clipboard). The code as run in M1 is at merge commit `63de169`.
- Device-free checks: `ios/SignsOfVital-M1Tests/` (XCTest, not yet run on a Swift toolchain),
  `ios/scripts/check_m1_vectors.py`, static guard `ios/scripts/check_m1_gate.sh`.
- Not compiled in CI or by agents (no macOS/iOS/Swift toolchain in the agent environment).

## Current milestone

```text
M0   = COMPLETE / SUCCESSFUL (2026-09-30)
M0.5 = COMPLETE
M1 physical experiment = COMPLETE / SUCCESSFUL (2026-10-03)
  Transport + framing hypothesis supported on H59B (0x03 only)
  Battery payload semantics = NOT YET PROVEN
M1.1 battery payload semantics = DESIGNED / READY FOR ARCHITECT REVIEW
  NOT physically executed; no device command authorized
M2+  = NOT AUTHORIZED
```

M0 design/result: [`docs/protocol/M0_PROBE.md`](protocol/M0_PROBE.md). M1 design/result:
[`docs/protocol/M1_BATTERY_EXPERIMENT.md`](protocol/M1_BATTERY_EXPERIMENT.md).

## Build path (resolved — ADR-005)

Swift Playgrounds on Dana's iPad; repository synced via Working Copy (HTTPS clone).
GitHub is the single source of truth; no manual copy/paste of Swift code.

## Handoff

Last completed:
- M1 physical run (2026-10-03), merged via PR #5 (handoff PR #6).
- M1.1 design + preparation on branch `claude/m1-1-battery-semantics` (PR #7, open for architect
  review): experiment doc, display-only app change, stronger guards, tests.

Current working branch / PR:
- `claude/m1-1-battery-semantics`, PR #7 (open, not merged).

Current blocker:
- Architect review of the M1.1 design, including its open questions (§15: private worksheet,
  committed evidence format, counter/cooldown, thresholds, vendor-app disconnect).
- `swift test` has not been run (no Swift toolchain for agents); it must pass before any GO.

Next action:
- Architect reviews PR #7 (M1.1). Physical execution needs a **separate explicit GO** after review.

Do NOT:
- run M1.1, send another battery query, or any other H59 command, without that explicit GO
- claim any response byte is battery % or add a battery decoder/UI
- decode, act on or record the unsolicited UART notifications
- start M2+ (protocol layer, HR/BP/SpO2/HRV/stress/sleep/steps)
- retry automatically, fuzz, or brute-force packets
- write to `FEE7` (`FEA1`/`FEC9`/`FEA2`) or authenticate/write on `DE5BF72x`
- add any write call to the M0 project
- implement pairing/bonding workarounds (tap Cancel on any iOS pairing prompt)
- commit raw BLE bytes, peripheral identifiers, manufacturer data, serial/System ID or health data
- ask Dana to repeat BLE screenshots/findings already documented

## Important files

- `AGENTS.md`, `CLAUDE.md` — agent instructions
- `TODO.md` — roadmap / unfinished work
- `docs/DECISIONS.md` — ADR-001..006
- `ios/` — M0 passive probe, M1 battery-query app (run once; M1.1-prepared), tests and guard scripts
- `docs/protocol/`, `docs/research/` — protocol evidence and research
