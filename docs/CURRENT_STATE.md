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
  (design **APPROVED**; **PARTIALLY EXECUTED**: O1, O2 done, O3 not authorized;
  progress: [`M1_1_PROGRESS_HANDOFF.md`](protocol/M1_1_PROGRESS_HANDOFF.md)).
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
- **M1.1 physical observations O1 (2026-10-04) and O2 (2026-10-05) done** (same M1 app, send path
  unchanged): each had one `0x03` query, ATT write acknowledged, one framing-compatible 16-byte
  response, checksum OK; candidate payload index 1 = 100 in both, vendor reference 100% (O2 bracket
  A = B = 100). Extra notifications (O1 non-`0x03`; O2 framing-incompatible, checksum-OK, ~12 s after
  the response) were recorded as anomalies and **not decoded**. **2 of 8 transmissions used.**
  Both are only *provisionally* valid: several protocol conditions are UNVERIFIED (see handoff doc).
  Battery semantics remain **NOT proven**. 2026-10-09: vendor app shows 93% (reference only, no query).
- M1.1 preparation (display-only, send path unchanged): the M1 app shows `0x03` payload bytes 1–14
  by position, with no hex. The guard was strengthened (fixed `0x03` only, no decoder/percent UI, no
  raw bytes in the log/UI/clipboard). The code as run in M1 is at merge commit `63de169`.
- Device-free checks: `ios/SignsOfVital-M1Tests/` (XCTest: **20 tests, 0 failures** in GitHub Actions
  workflow "M1 Swift Tests", `.github/workflows/m1-swift-tests.yml`; CI run [37152212233](https://github.com/dg-dana/signs_of_vital/actions/runs/37152212233), PR head `156b44f`, macos-15, Apple Swift 6.1.2),
  `ios/scripts/check_m1_vectors.py`, static guard `ios/scripts/check_m1_gate.sh`.
- The iOS apps are not compiled in CI or by agents (no Apple app toolchain); only the device-free
  SwiftPM package is built and tested in CI. Agents themselves have no Swift toolchain.

## Current milestone

```text
M0   = COMPLETE / SUCCESSFUL (2026-09-30)
M0.5 = COMPLETE
M1 physical experiment = COMPLETE / SUCCESSFUL (2026-10-03)
  Transport + framing hypothesis supported on H59B (0x03 only)
  Battery payload semantics = NOT YET PROVEN
M1.1 battery payload semantics = IN PROGRESS (design approved; PR #7 merged)
  O1 (2026-10-04) + O2 (2026-10-05) done; 2 of 8 transmissions; no verdict
  O3 = NOT performed, NOT authorized; no device command authorized now
M2+  = NOT AUTHORIZED
```

M0 design/result: [`docs/protocol/M0_PROBE.md`](protocol/M0_PROBE.md). M1 design/result:
[`docs/protocol/M1_BATTERY_EXPERIMENT.md`](protocol/M1_BATTERY_EXPERIMENT.md).

## Build path (resolved — ADR-005)

Swift Playgrounds on Dana's iPad; repository synced via Working Copy (HTTPS clone).
GitHub is the single source of truth; no manual copy/paste of Swift code.

## Handoff

Last completed:
- M1 physical run (2026-10-03), PR #5. M1.1 design + preparation, PR #7 (merged).
- M1.1 O1 and O2 physical observations (sanitized in `docs/protocol/M1_1_PROGRESS_HANDOFF.md`).

Current working branch / PR:
- `claude/m1-1-o1-o2-handoff` (docs-only handoff PR; not merged without approval).

Current blocker:
- Waiting for the vendor app to show a **middle-state battery level (roughly 45–70%)**; it showed
  93% on 2026-10-09. No technical blocker.

Next action:
- When the middle state is reached: verify every precondition in experiment §6–§7, and the architect
  rules on the open O2 extra-notification question, then give a **new explicit GO** for O3.
- New session: read the repository first; do **not** ask Dana to repeat O1/O2 evidence. Ask only
  for items the handoff doc marks UNVERIFIED, if the architect wants them resolved.
- M2+ remains NOT AUTHORIZED.

Do NOT:
- run O3 or any further M1.1 query (or send another battery query), or any other H59 command, without that explicit GO
- claim any response byte is battery % or add a battery decoder/UI
- decode, act on or record the unsolicited UART notifications (including the O1/O2 extra ones)
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
