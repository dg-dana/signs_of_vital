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
- Protocol compatibility with H59B: strongly suggested (matching UUIDs), **not proven**.
- The Bionny measurement protocol is **not decoded**. We know the GATT topology and some
  observed behavior only; characteristic semantics are unknown.
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
- **M1 preparation (not yet run, not authorized):** `ios/SignsOfVital-M1.swiftpm/` is a
  separate app that can send exactly one gated battery query (`03 00…00 03`) on the UART
  channel. Pure framing/gate logic has device-free tests (`ios/SignsOfVital-M1Tests/`,
  `ios/scripts/check_m1_vectors.py`, static guard `ios/scripts/check_m1_gate.sh`).
- Not compiled in CI or by agents (no macOS/iOS/Swift toolchain in the agent environment).

## Current milestone

```text
M0   = COMPLETE / SUCCESSFUL (2026-09-30)
M0.5 = M1 DESIGN / IMPLEMENTATION PREPARATION
M1 physical experiment = NOT YET AUTHORIZED
```

M0 design/result: [`docs/protocol/M0_PROBE.md`](protocol/M0_PROBE.md). M1 design:
[`docs/protocol/M1_BATTERY_EXPERIMENT.md`](protocol/M1_BATTERY_EXPERIMENT.md).

## Build path (resolved — ADR-005)

Swift Playgrounds on Dana's iPad; repository synced via Working Copy (HTTPS clone).
GitHub is the single source of truth; no manual copy/paste of Swift code.

## Handoff

Last completed:
- PR #4 merged: M0 results recorded (M0 successful).
- M1 preparation implemented for architect review (branch `claude/m0-5-m1-battery-prep`,
  PR opened, not merged by the implementer).

Current working branch / PR:
- `claude/m0-5-m1-battery-prep` — M1 preparation PR, awaiting architect review.

Current blocker:
- Architect final review of the M1 preparation, then an explicit GO for the physical run.

Next action:
- Architect reviews design + implementation. Only after an explicit GO may Dana run the
  M1 battery query. Also run `swift test` for `ios/SignsOfVital-M1Tests` on a Mac if available.

Do NOT:
- run the M1 physical battery query or instruct Dana to, before explicit architect GO
- send any command other than the single M1 battery `0x03`, or more than one per deliberate action
- retry automatically, fuzz, or brute-force packets
- write to `FEE7` (`FEA1`/`FEC9`/`FEA2`) or authenticate/write on `DE5BF72x`
- add any write call to the M0 project
- implement pairing/bonding workarounds (tap Cancel on any iOS pairing prompt)
- commit peripheral identifiers, manufacturer data, serial/System ID, raw values or health data
- treat any response byte as a trusted battery value or claim the protocol is decoded
- ask Dana to repeat BLE screenshots/findings already documented

## Important files

- `AGENTS.md`, `CLAUDE.md` — agent instructions
- `TODO.md` — roadmap / unfinished work
- `docs/DECISIONS.md` — ADR-001..006
- `ios/` — M0 passive probe, M1 battery-query app (unrun), tests and guard scripts
- `docs/protocol/`, `docs/research/` — protocol evidence and research
