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
- Not compiled in CI (no macOS/iOS toolchain in the agent environment).

## Current milestone

```text
M0 = SUCCESSFUL (2026-09-30)
M1 = NOT STARTED / NOT AUTHORIZED
```

M0 design/result: [`docs/protocol/M0_PROBE.md`](protocol/M0_PROBE.md). The next milestone
remains subject to architect review.

## Build path (resolved — ADR-005)

Swift Playgrounds on Dana's iPad; repository synced via Working Copy (HTTPS clone).
GitHub is the single source of truth; no manual copy/paste of Swift code.

## Handoff

Last completed:
- M0 passive probe run on physical hardware (2026-09-30); results recorded in
  `GATT_MAP.md` section A and `M0_PROBE.md` (docs-only PR from
  `claude/m0-probe-documentation-ayh4z0`).

Current working branch / PR:
- `claude/m0-probe-documentation-ayh4z0` — M0 results documentation PR, awaiting
  architect review (not merged by the implementer).

Current blocker:
- Architect review of the M0 results and decision on the next milestone.

Next action:
- Architect reviews/merges the docs PR and decides whether and how M1 is scoped.
  No implementation work until then.

Do NOT:
- start M1 or send any proprietary H59 command (including battery `0x03`)
- write to any characteristic merely because it is writable
- add any write call to the M0 project, or guess/fuzz/brute-force packets
- implement pairing/bonding (tap Cancel on any iOS pairing prompt)
- commit peripheral identifiers, manufacturer data, serial/System ID, raw values or health data
- claim the measurement protocol is decoded
- ask Dana to repeat BLE screenshots/findings already documented

## Important files

- `AGENTS.md`, `CLAUDE.md` — agent instructions
- `TODO.md` — roadmap / unfinished work
- `docs/DECISIONS.md` — ADR-001..005
- `ios/` — M0 Swift Playgrounds project and passive guard script
- `docs/protocol/`, `docs/research/` — protocol evidence and research
