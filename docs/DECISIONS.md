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

## ADR-006 — M1 is a separate app with one gated write; M0 stays passive

**Decision:** The single battery-query experiment lives in its own Swift Playgrounds project (`ios/SignsOfVital-M1.swiftpm/`). Exactly one `writeValue` exists, sending a fixed 16-byte frame to `6E400002` from an explicit two-step operator confirmation, behind a pure send gate and a one-shot latch that lasts for the app run. It discovers only the UART service; no retries; security/pairing errors abort.

**Reason:** ADR-004 forbids writes in M0, and the M0 static guard enforces it. A separate project keeps M0 provably passive and makes the M1 write surface small enough to audit with `ios/scripts/check_m1_gate.sh`.

**Alternatives considered:** Adding the write to the M0 project (weakens the passive guarantee); write-without-response (no ATT feedback on errors).

**Consequences:** Implementation is prepared only; the physical run needs explicit architect GO. Any additional command, channel or retry needs a new architect decision.

## 2026-10-22 — M1.1 paused after the O2 anomaly (architect assessment)

**Decision:** M1.1 is paused and O3 is NOT AUTHORIZED. The O2 extra notification (framing-incompatible,
checksum-OK, ~12 s after the response) does not establish a second framing-compatible `0x03` response,
and the ANOMALY banner counts only those. It does raise an unresolved §12 framing-failure question, so
O2 is not accepted as fully valid. O1 also has unverified validity requirements. Its payload is not to
be decoded.

**Reason:** The pre-registered abort rule (§12) does not say whether a non-response notification is a
"framing failure"; that must be settled explicitly before any further transmission.

**Consequences:** No transmission until the architect rules on
`docs/protocol/M1_1_PROTOCOL_REVIEW_PROPOSAL.md` and gives a new written GO. H1, tolerance,
thresholds and the 8-transmission cap are unchanged.

## 2026-10-22 — Architect rulings Q1–Q10 on the M1.1 protocol review (PR #9, round 1)

**Decision:**
- §12 "framing failure" concerns the expected `0x03` response, not unrelated non-`0x03`
  notifications (R2). This is a post-hoc clarification, applied equally to O1 and O2.
- Continue M1.1 via a documented Revision 1 (option A, in principle), subject to final review.
- Notification rules must cover malformed, missing, duplicate and late responses.
- Validity checklist V1–V9 adopted; UNVERIFIABLE observations do not count.
- O1 is historical, not valid for H1. O2 is provisional and not counted until verified.
- A later same-state repeat may replace the O1/O2-specific one, approved before further
  observations.
- An early-stop rule is added.
- No Swift changes.
- The cap stays 8 (2 used, 6 remaining, no reset).

**Reason:** The pre-registered §12 wording was ambiguous. Resolving it explicitly, and not counting
weakly documented observations, protects the experiment's integrity.

**Consequences:** Documentation revisions only; O3 is still NOT AUTHORIZED. The remaining plan
must reach sufficiency without O1/O2 (5 valid observations from 6 transmissions).

## ADR-007 (PROPOSED — PENDING FINAL ARCHITECT REVIEW) — M1.1 Revision 1

**Decision (proposed, not in force):** Adopt Revision 1 (`M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`
§16), which contains:
- the R2 clarification;
- classes R/M/U/Z and rules N1–N8 (exactly one valid `0x03` response within a displayed ≤ 9 s;
  missing/late, malformed, duplicate or unclassifiable → fail/abort; unrelated non-`0x03` → ignored);
- a manual 10-second check;
- V1–V9, where only VALID counts;
- a replacement same-state repeat (an explicit change to §9.6);
- a conservative plan O3, O3r, O4, O5, O6 with 1 spare transmission;
- early stop.

H1, the tolerance, the thresholds and the cap are unchanged.

**Reason:** Implements the Q1–Q10 rulings without app changes and without counting O1/O2.

**Alternatives considered:** Close M1.1 as INCONCLUSIVE and pre-register a new experiment (B);
treat O2 as an observation-level invalid (C); stop (D). See
`docs/protocol/M1_1_PROTOCOL_REVIEW_PROPOSAL.md`.

**Consequences:** One spare transmission. Any §12 abort (including a late response) ends M1.1 as
INCONCLUSIVE under the unchanged §9, pending confirmation (proposal §11). O3 needs final approval
plus a separate written GO.
