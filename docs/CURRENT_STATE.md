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

- No app code yet. Repository contains documentation and agent tooling only.

## Current milestone

**M0 — passive BLE/GATT discovery.** Design: [`docs/protocol/M0_PROBE.md`](protocol/M0_PROBE.md).
M1+ not authorized.

## Current blocker

No verified way to build and install a Swift/CoreBluetooth app on Dana's iPhone
(Dana works from iPhone + GitHub; no confirmed Mac/Xcode).

## Next architectural decision

Choose the Apple build/deploy path: Mac + Xcode, another Apple dev environment,
or cloud macOS + TestFlight.

## Important files

- `AGENTS.md`, `CLAUDE.md` — agent instructions
- `TODO.md` — roadmap / unfinished work
- `docs/DECISIONS.md` — ADR-001..004
- `docs/protocol/`, `docs/research/` — protocol evidence and research
