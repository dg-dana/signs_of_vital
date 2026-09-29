# Current State

Concise technical checkpoint. Experimental research project — wearable readings are
**not** medically validated.

## Device

- Product: Bionny 4.0 health armband.
- Hardware revision: `H59B_V1.0` (Device Information, nRF Connect).
- Firmware revision: `H59B_1.00.00_260402` (Device Information, nRF Connect).
- Connectable over BLE; exposes UART-style and proprietary services (exact UUIDs provisional).

## Research state

- OpenH59 (H59_V2.0 reference) reviewed: [`docs/research/openh59.md`](research/openh59.md).
- Protocol compatibility with H59B: strongly suggested, **not proven**.
- GATT evidence levels: [`docs/protocol/GATT_MAP.md`](protocol/GATT_MAP.md).

## Implementation

- M0 passive probe implemented as a Swift Playgrounds app project:
  `ios/SignsOfVital-M0.swiftpm/` (SwiftUI + CoreBluetooth). **Not yet reviewed,
  not yet run against the Bionny.**
- Passive-only static guard: `sh ios/scripts/check_m0_passive.sh`.
- Not compiled in CI (no macOS/iOS toolchain in the agent environment); first
  compile happens in Swift Playgrounds on the iPad.

## Current milestone

**M0 — passive BLE/GATT discovery.** Design: [`docs/protocol/M0_PROBE.md`](protocol/M0_PROBE.md).
M1+ not authorized.

## Build path (resolved — ADR-005)

Swift Playgrounds on Dana's iPad; repository synced via Working Copy (HTTPS clone).
GitHub is the single source of truth; no manual copy/paste of Swift code.

## Handoff

Last completed:
- M0 probe implemented (`ios/SignsOfVital-M0.swiftpm/`).
- Docs corrected: GATT_MAP section B transcription status, pairing-prompt rule in
  M0_PROBE.md, this file's branch reference.

Current working branch / PR:
- `claude/m0-swift-playground-probe` — PR open for architect review, **not merged**.

Current blocker:
- Architect review of the PR for passive-only BLE behavior.

Next action:
1. Architect reviews/merges the PR.
2. Dana pulls `main` in Working Copy, opens the project in Swift Playgrounds,
   confirms it compiles and runs.
3. Only after approval: run the probe against the Bionny per M0_PROBE.md.

Do NOT:
- run the probe against the Bionny before the architect approves the PR
- accept an iOS pairing/bonding prompt (tap Cancel, log it)
- start M1 or send proprietary H59 commands
- add any write call to the M0 project
- ask Dana to repeat BLE screenshots/findings already documented
- treat provisional UUID transcriptions as confirmed

## Important files

- `AGENTS.md`, `CLAUDE.md` — agent instructions
- `TODO.md` — roadmap / unfinished work
- `docs/DECISIONS.md` — ADR-001..005
- `ios/` — M0 Swift Playgrounds project and passive guard script
- `docs/protocol/`, `docs/research/` — protocol evidence and research
