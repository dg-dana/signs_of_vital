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
  `ios/SignsOfVital-M0.swiftpm/` (SwiftUI + CoreBluetooth). Passive-only boundary
  approved by the architect; merged via PR #2. **Not yet compiled on the iPad,
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
- M0 probe implemented and merged (PR #2, architect-approved passive-only boundary).
- Docs corrected: GATT_MAP section B transcription status, pairing-prompt rule in
  M0_PROBE.md, this file's branch reference.

Current working branch / PR:
- None open for M0 code. PR #2 (`claude/m0-swift-playground-probe`) merged into `main`.

Current blocker:
- None known. First compile in Swift Playgrounds on the iPad is still unverified.

Next action:
1. Dana pulls `main` in Working Copy, opens `ios/SignsOfVital-M0.swiftpm` in
   Swift Playgrounds, confirms it compiles and runs (report any compile errors).
2. Run the probe against the Bionny per M0_PROBE.md (cancel + log any pairing prompt).
3. Paste "Copy GATT map" output into `GATT_MAP.md` section A; re-confirm HW/FW strings.

Do NOT:
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
