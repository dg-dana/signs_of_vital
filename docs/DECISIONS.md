# Decisions

This file records important technical and architectural decisions that future agents may otherwise reconsider without knowing the original reasoning.

Keep entries concise.

Do not record routine implementation details.

## Entry format

Use this structure:

```md
## YYYY-MM-DD — Short decision title

**Decision:** What was chosen.

**Reason:** Why it was chosen.

**Alternatives considered:** Optional. Mention meaningful alternatives only.

**Consequences:** Important trade-offs or constraints created by the decision.
```

## Initial decision — Repository-managed agent memory

**Decision:** Project state is stored in repository Markdown files rather than depending on agent conversation history.

**Reason:** Coding agents may work in separate sessions, tools, or context windows. Repository files survive context resets and can be shared by Claude Code, Codex, ChatGPT, and other agents.

**Consequences:** Agents must keep `TODO.md` and the relevant project-state documentation current after meaningful changes.

## ADR-001 — Swift + CoreBluetooth for the BLE implementation

**Decision:** The BLE layer is written in Swift using CoreBluetooth. No Python/bleak probe or production stack.

**Reason:** The target is an iPhone app. The first BLE code should become the foundation of the real app, not a disposable prototype on another platform.

**Alternatives considered:** Python + bleak (as used by OpenH59) — faster to prototype on a desktop, but throwaway for an iOS product.

**Consequences:** Every BLE experiment, including M0, needs a working Apple build/install path (resolved by ADR-005).

## ADR-002 — M0 is passive GATT discovery before any protocol command

**Decision:** Milestone M0 only scans, connects, discovers services/characteristics, reads READ-capable characteristics, and subscribes to notifications. M1+ is not authorized until the architect approves.

**Reason:** UUIDs and protocol compatibility with OpenH59 are unproven for H59B. Observe first; command later; avoid modifying the wearable.

**Consequences:** Design in `docs/protocol/M0_PROBE.md`. No H59 packet encoding exists until M1 is authorized.

## ADR-003 — OpenH59 is reference only; no source copying

**Decision:** OpenH59 may be read for research. Its source must not be copied, translated, or ported.

**Reason:** The upstream repository has no license file, so no reuse rights are granted.

**Consequences:** We implement framing/commands independently from our own understanding and device observations. Findings are summarized in `docs/research/openh59.md`.

## ADR-004 — Notification subscription allowed in M0; application writes prohibited

**Decision:** `setNotifyValue(true, for:)` is permitted in M0. Application-level `writeValue` calls and manual CCCD descriptor writes are prohibited.

**Reason:** Subscribing is standard BLE client behavior (CoreBluetooth writes the CCCD internally) and does not send application data or change device settings.

**Consequences:** M0 can observe spontaneous notifications. Any code path calling `writeValue` is out of M0 scope.

## ADR-005 — M0 build path: Swift Playgrounds on iPad, synced via Working Copy

**Decision:** The M0 probe is a Swift Playgrounds app project (`ios/SignsOfVital-M0.swiftpm/`) built and run on Dana's iPad. The repository reaches the iPad through Working Copy (HTTPS clone). GitHub is the single source of truth; Swift code is never hand-copied.

**Reason:** No Mac/Xcode is available. Swift Playgrounds supports SwiftUI app projects with the Bluetooth capability, so CoreBluetooth code (ADR-001) can run on real Apple hardware without Xcode.

**Alternatives considered:** Mac + Xcode (no Mac available); cloud macOS + TestFlight (more setup, slower loop).

**Consequences:** The probe runs on the iPad, not the iPhone. Agents cannot compile the project; the first compile is on the iPad. Swift Playgrounds may rewrite `Package.swift` when App Settings change. Moving to a full Xcode project remains possible later.
