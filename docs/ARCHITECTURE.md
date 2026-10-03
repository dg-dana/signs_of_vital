# Architecture

## Overview

Signs of Vital is an experimental iOS research project to read data from a
Bionny 4.0 (H59B) health armband over Bluetooth LE. Readings are not medically
validated. Current stage: M0 and M1 complete; M1.1 (battery payload semantics) designed, not executed (see `docs/CURRENT_STATE.md`).

## Main components

```text
Bionny H59B (BLE peripheral)
  ↑ scan / connect / discover / read / notify  (no writes in M0)
M0 probe app — SwiftUI + CoreBluetooth, Swift Playgrounds, runs on iPad
  ├─ ProbeModel.swift    CBCentralManager/CBPeripheral delegate, in-memory state + log
  ├─ ContentView.swift   scan list, GATT tree, event log
  └─ Hex.swift           hex / printable-UTF-8 / property formatting
```

M1 (run once on 2026-10-03; further runs not authorized) is a separate app, `ios/SignsOfVital-M1.swiftpm/`:
`BatteryFrame.swift` + `BatteryQueryGate.swift` (pure, Foundation-only, unit-tested),
`BatteryProbeModel.swift` (CoreBluetooth; the only transmit call, behind the gate and a
two-step operator confirmation), `ContentView.swift`. See `docs/protocol/M1_BATTERY_EXPERIMENT.md`.
M1.1 reuses this app unchanged on the send path; it only shows `0x03` payload bytes by position
(no hex). See `docs/protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`.

## Repository structure

```text
ios/SignsOfVital-M0.swiftpm/   M0 Swift Playgrounds app project
ios/SignsOfVital-M1.swiftpm/   M1 single-battery-query app (run once, 2026-10-03)
ios/SignsOfVital-M1Tests/      device-free SwiftPM tests (symlinked pure sources)
ios/scripts/                   check_m0_passive.sh, check_m1_gate.sh, check_m1_vectors.py
.github/workflows/             m1-swift-tests.yml: device-free M1 XCTest package on PRs (macOS runner)
docs/protocol/                 M0 probe design, GATT map by evidence level
docs/research/                 OpenH59 reference notes (reference only, ADR-003)
docs/                          CURRENT_STATE, DECISIONS, ARCHITECTURE, AGENT_WORKFLOW
.claude/skills/                TODO skills
```

## Data flow

BLE values → CoreBluetooth delegate callbacks → in-memory `@Published` state →
on-screen display as raw hex. Nothing is persisted. Only UUIDs/properties
(via "Copy GATT map") are meant to reach the repository.

## Architectural constraints

- CoreBluetooth only (ADR-001); built with Swift Playgrounds on iPad (ADR-005).
- M0 is passive: no application writes, no descriptor writes, no commands (ADR-002/004).
- M1 app: at most one gated battery write, nothing automatic, no other channels (ADR-006).
- No OpenH59 source reuse (ADR-003).
- Never commit serial numbers, per-device identifiers, health data or credentials.
