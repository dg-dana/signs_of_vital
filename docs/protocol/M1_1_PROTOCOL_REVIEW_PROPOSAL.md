# M1.1 — Protocol Review and Continuation Proposal (after the O2 anomaly)

Status: **PENDING ARCHITECT REVIEW.** Documentation only; nothing in this file is in force.
M1.1 is **PAUSED**. O3 is **NOT AUTHORIZED**. No query or other device command is authorized.

The pre-registered hypothesis (experiment §1), tolerance (§9), sufficiency thresholds (§8) and
transmission cap (§8) in [`M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`](M1_1_BATTERY_SEMANTICS_EXPERIMENT.md)
are **unchanged** by this document. Every item below that would change how the experiment runs,
or how its rules are read, is marked **[DECISION]**. It takes effect only after an explicit,
written architect decision.

Prepared 2026-10-22 by Claude Code (developer) at the architect's request. Inputs: the repository
at `main` `dc7e1d4` (docs and the M1 app source). No raw frames, screenshots, payload values beyond
those already committed, or private-worksheet contents were seen. The unsolicited notification's
payload was **not** decoded or investigated.

## 1. Architect assessment (as given, 2026-10-22)

- The O2 extra notification does **not** establish a second framing-compatible `0x03` response.
- The app's ANOMALY banner counts only framing-compatible `0x03` responses.
- The extra notification nevertheless raises an **unresolved framing-failure question under §12**.
- **O2 cannot currently be accepted as fully valid.**
- **O1 also has outstanding unverified validity requirements.**
- M1.1 is on hold; O3 is not authorized; the payload of the extra notification is not to be decoded.

## 2. The O2 anomaly and what is still uncertain

### 2.1 What is recorded (unchanged evidence)

O2 (2026-10-05): one explicitly confirmed `0x03` query; ATT write acknowledged; one
framing-compatible 16-byte response, checksum OK; candidate index 1 = 100; vendor reference
A = B = 100%. About **12 s after that response**, one further notification arrived. It was
reported as **framing-incompatible, checksum-OK**. It was not a second transmission by us. The
app was then closed; nothing is persisted, so the screen cannot be re-checked.

### 2.2 What the app's own checks imply (code reading only; no payload examined)

These follow from `ios/SignsOfVital-M1.swiftpm/BatteryFrame.swift` (`ResponseObservation`) and
`BatteryProbeModel.swift`. They hold **only if** the report used the app's on-screen labels
("checksum OK", "framing NOT compatible with hypothesis") exactly. That is **UNVERIFIED**.

1. The app computes a checksum only for a 16-byte notification. "Checksum OK" therefore implies
   length 16 with a valid checksum.
2. "Framing compatible" means length 16 **and** byte 0 = `0x03` **and** checksum OK. A 16-byte,
   checksum-OK notification that is *not* compatible must therefore have had **byte 0 ≠ `0x03`**
   (a framing byte, not payload).
3. Because the query latch was already set, the app would have labelled it "After query".
4. `queryResponseCount` counts only framing-compatible `0x03` notifications, so the ANOMALY
   banner would **not** have appeared for it. This matches the architect's assessment.
5. Since the response arrives after the write, a notification ~12 s after the response arrived
   **more than 10 s after the write**, i.e. outside the §12 response window (timing approximate).

Nothing here says what the notification means. It is not interpreted.

### 2.3 Still unresolved

- Whether the report used the app's labels verbatim (and so whether 2.2 applies).
- Whether the ANOMALY banner appeared (2.2.4 says it should not have).
- Whether the O1 unsolicited non-`0x03` notification arrived before or after the O1 query.
- Whether either event falls under §12 "framing failure". **Architect's call** (§3).
- The O1/O2 precondition items marked UNVERIFIED in [`M1_1_PROGRESS_HANDOFF.md`](M1_1_PROGRESS_HANDOFF.md).

## 3. Does §12 require terminating M1.1?

§12 lists, without scoping, "a write error, no response within 10 s, **a framing failure**, or
more than one `0x03` response to a query". §9 makes "any abort (§12) before sufficiency"
INCONCLUSIVE. Two readings are possible:

| | **R1 — strict** | **R2 — scoped to the response** |
|---|---|---|
| Meaning of "framing failure" | Any framing-incompatible notification during an observation | The response to our `0x03` query fails length/checksum/command-echo checks |
| O2 extra notification | Triggers §12 → M1.1 stopped → INCONCLUSIVE | Not a framing failure; handled by §7 ("not transcribed, decoded or acted on") |
| Textual support | §12 wording is unqualified | §7 explicitly anticipates non-`0x03` notifications and says not to act on them; §9 files framing failure under "inconsistent **response** layout"; every other §12 item concerns the query's response; O1's non-`0x03` notification was not treated as an abort |

**Developer view (for challenge, not a ruling):** R2 is the better-supported reading of the
document as written, but the text does not say so explicitly, and the rule was pre-registered.
So it must be settled by an explicit, recorded architect ruling, not by the developer. Note:

- The reporting duty in §12 is already met under either reading (the observation ended, no retry,
  and it was reported).
- The ruling must apply **equally to O1**, which also had a non-`0x03` notification.
- The stakes are bounded. O2's index-1 value equals O1's at the same reference level, so O2 carries
  little evidential weight for H1. Its role is the same-state repeat and the valid-observation count (§8).

**Answer:** §12 requires termination **only under R1**. Under R2, it does not. **[DECISION Q1]**

## 4. Is a separately approved continuation permissible?

Yes. The document provides for it. §9: "Any change needs a new document revision approved before
further observations." §8: "no extension without a new architect decision." §15: changes need a
new architect decision before further observations. A continuation is legitimate if it is written
down, approved **before** the next transmission, and does not quietly alter H1, the tolerance,
the thresholds or the cap.

## 5. Continuation alternatives

| Option | What it means | For | Against |
|---|---|---|---|
| **A. Continue M1.1 under R2 + Rev 1 clarification** | Architect rules R2, adopts the notification rules in §6 and the validity rules in §7 as **Revision 1**, decides O1/O2 validity, then (separately) gives O3 GO. | Keeps all 6 remaining transmissions and possibly O1/O2; no code change; criteria untouched. | The clarification is written *after* seeing the anomaly (post-hoc). Mitigated by applying it to O1 and O2 alike and by it not touching H1, the tolerance, or which byte is the candidate. |
| **B. Close M1.1 INCONCLUSIVE (R1); pre-register a continuation "M1.1-R"** | M1.1 ends as INCONCLUSIVE (abort before sufficiency). A new document with the **same** H1, tolerance and thresholds, the §6/§7 rules, and a cap equal to the **6 remaining** transmissions (total budget stays 8). O1/O2 are **not** used for H1. | Cleanest pre-registration story; the strict rule is honored. | Needs 5 valid observations from 6 transmissions (1 spare); needs a high-state observation again (recharge) or a different same-state repeat. |
| **B′. As B, but carry O1/O2 forward as provisional** | Like B, with O1/O2 imported subject to §7 validity. | More margin. | Close to A in substance while claiming R1. Mixing an aborted experiment's data into a new one is the weakest option methodologically. Not recommended. |
| **C. Keep M1.1 open; treat O2 as an observation-level invalid** | §12 is read as "stop this observation" rather than "stop the experiment". O2 counted, not used. | Simple. | This is itself a reinterpretation of §12 (an experiment-level stop becomes observation-level). Needs the same explicit ruling as A, without A's clarity. |
| **D. Stop; no continuation** | M1.1 INCONCLUSIVE; battery semantics parked. | No further device interaction. | Leaves the M1.1 question open; the 6-transmission budget goes unused. |

**Recommendation:** **A**. If the architect prefers R1, use **B** (shared cap of 8, O1/O2 not
used for H1), not B′. **[DECISION Q2]**

## 6. Proposed handling of notifications during an observation [DECISION Q3]

These rules use only labels the existing app already shows: "After query" / "Unsolicited (before
query)", length, "byte0 = 0x03" / "byte0 ≠ 0x03", "checksum OK/MISMATCH", "framing COMPATIBLE/NOT
compatible", log timestamps. Nothing is decoded.

- **N1 — Response window:** from the write (log `SENDING`) to 10 s after it. Unchanged from §12.
- **N2 — The response:** exactly one framing-compatible `0x03` notification after the query, within
  the window. Unchanged.
- **N3 — Framing failure (§12 abort):** any notification after the query with byte 0 = `0x03` but
  length ≠ 16 or a checksum mismatch, **or** an empty notification after the query (byte 0
  unknown; treated conservatively).
- **N4 — Non-`0x03` notification:** any notification with byte 0 ≠ `0x03`, at any time. **Not** a
  framing failure. Not decoded, not transcribed beyond N6, not acted on. It does not by itself
  invalidate the observation.
- **N5 — Existing anomalies, unchanged:** more than one framing-compatible `0x03` (ANOMALY banner),
  or no framing-compatible `0x03` within the window (even if a non-`0x03` one arrived), → §12 abort.
- **N6 — Recording, before closing the app:** the operator writes into the private worksheet only
  the count of non-`0x03` notifications per timing class (before query / within window / after
  window) and whether any N3/N5 condition occurred. No bytes. This adds fields to the §10
  worksheet and so needs approval. The committed record gets the same counts as validity flags.
- **N7 — Applies retroactively to O1 and O2 alike.**

Under N4, the O2 extra notification would be a non-`0x03` notification after the window, **if**
2.2 holds. That depends on Dana confirming the labels.

## 7. How observation validity should be assessed [DECISION Q4–Q6]

Each observation is checked against:

| # | Condition | Source in experiment |
|---|---|---|
| V1 | Exactly one transmission, fresh launch, numbered worksheet row first | §5, §7, §8 |
| V2 | ATT write acknowledged | §7 |
| V3 | Exactly one framing-compatible `0x03` response within 10 s; no N3/N5 condition | §7, §9.2, §12, N1–N5 |
| V4 | No pairing prompt, security error or unexpected device behavior | §12 |
| V5 | Reference A and B within 15 min, \|A−B\| ≤ 5 | §6 |
| V6 | Band off charger ≥ 15 min | §7 |
| V7 | Vendor app disconnected during the query, reconnected afterwards | §6 steps 2 and 4 |
| V8 | ≥ 30 min since the previous M1.1 query | §7 |
| V9 | Written architect GO existed before the run | §7 |

Outcomes: **VALID** (all verified), **INVALID** (any failed; counted toward the cap, not used for
H1), **UNVERIFIABLE**. Proposed: **UNVERIFIABLE is treated as INVALID** for H1 (conservative).

Verification without exposing private data: Dana gives a written **yes / no / don't know** per
item, from memory or the private worksheet (which records date/hour, references A/B, minutes off
charger and framing-check yes/no). No worksheet contents are committed.

Specific notes:

- **O1:** the handoff records a *single* reference reading. §6 requires both A and B. Unless Dana
  confirms a B reading existed, O1 fails V5 and is **INVALID as the rule is written**, not merely
  unverified. **[DECISION Q5]**
- **O2:** V5 (15-minute window), V6, V7, V9 and V3 (as governed by the §3 ruling) are open.
  **[DECISION Q6]**

## 8. Can the remaining 6 transmissions meet the original sufficiency requirement?

Requirement (§8, unchanged): ≥ 5 valid; reference spread ≥ 40; ≥ 3 distinct levels ≥ 15 apart;
≥ 1 upward change; ≥ 1 same-state repeat. §9.6 names the repeat specifically as "O2 vs O1".

| Scenario | Valid observations still needed | Spare transmissions | Feasible? |
|---|---|---|---|
| S1: O1 and O2 valid | 3 (O3 mid, O4 low, O5 recharge) | 3 | Yes. Spread from 100 to ≤ 40 is ≥ 60. |
| S2: O1 invalid, O2 valid | 4 (O3, a new same-state repeat, O4, O5) | 2 | Yes, **but** §9.6 cannot be met as worded without a substitute repeat **[DECISION Q7]** |
| S3: O1 valid, O2 invalid | 4 (as S2; or repeat O1's state after recharge) | 2 | Yes, with the same §9.6 decision |
| S4: both invalid (or option B) | 5 (incl. a new repeat; e.g. mid ~60, low ~20–25, recharge to ≥ 75 for spread ≥ 40 and 3 levels ≥ 15 apart) | 1 | Marginal: one more invalid observation ends in INCONCLUSIVE |

Timing: the latest vendor-app reference reported to the architect is **60%** (date not recorded in
the repository; UNVERIFIED). That is inside the O3 range today, but it may leave the range during
review. If it does, the plan is unchanged: recharge and wait for the next discharge through the
middle range. Do not run the band down deliberately (§8).

**Proposed early-stop rule [DECISION Q8]:** if, at any point, the remaining transmissions are fewer
than the valid observations still needed, stop and declare INCONCLUSIVE rather than spend more
transmissions. This only reduces device interaction.

## 9. If the evidence remains insufficient

Unchanged from §8/§9: when the cap is reached (or the early-stop rule fires) without sufficiency,
the verdict is **INCONCLUSIVE**. There is no extension. Sanitized results are recorded (§10).
Battery semantics stay **NOT proven**. Any pattern seen (other scale, coarse levels, etc.) is
recorded only as a new hypothesis. Any further attempt is a **new, separately pre-registered
experiment** with its own cap and a new architect GO. An INCONCLUSIVE M1.1 does not authorize M2.

## 10. Implementation implications

**The existing M1 app is sufficient for options A, B and C without code changes.** It already
shows, per notification, the after-query flag, length, byte 0 = / ≠ `0x03`, checksum result and
framing compatibility. The event log timestamps (to the second) `SENDING`, the write ack and each
notification. The ANOMALY banner covers N5.

Limitations, handled procedurally:

| # | Limitation (code) | Procedural mitigation |
|---|---|---|
| L1 | Nothing is persisted; closing the app loses the screen (this is how O2's details were lost) | N6: write the counts/flags into the worksheet **before** closing the app |
| L2 | The 10-s "no notification" log line is suppressed by *any* after-query notification, including a non-`0x03` one | Operator checks that the framing-compatible `0x03` response is timestamped ≤ 10 s after `SENDING` |
| L3 | The ANOMALY banner does not flag N3 (a malformed `0x03`) | Operator checks the labels of every after-query notification |
| L4 | "After query" is not window-based | Operator classifies timing from log timestamps (N6) |

Possible code changes (**not recommended now**; would need separate authorization): a display-only
window classification and an N3 warning. No new BLE behavior. Trade-off: O3+ would run on a
different build than O1/O2, and the static guard, tests and CI would need updating. Procedural
handling is enough. **[DECISION Q9]**

No new Bluetooth behavior, persistence, logging, decoders or transmission paths are proposed.

## 11. Questions requiring architect decision

1. **Q1** — §12 reading: R1 (strict, M1.1 terminates as INCONCLUSIVE) or R2 (scoped to the response)?
2. **Q2** — Continuation option: A, B, B′, C or D?
3. **Q3** — Adopt notification rules N1–N7 as Revision 1, including N3's conservative handling of
   empty notifications and N6's added worksheet fields?
4. **Q4** — Adopt the V1–V9 validity checklist, with UNVERIFIABLE treated as INVALID, verified by
   Dana's yes/no/don't-know statements?
5. **Q5** — O1: VALID or INVALID, given a single reference reading (§6 requires A and B)?
6. **Q6** — O2: VALID or INVALID, after Q1 and Dana's answers on V3/V5/V6/V7/V9?
7. **Q7** — If O1 or O2 is invalid: may a later same-state repeat substitute for §9.6's "O2 vs O1"
   (same ±2 reference band, ≥ 30 min apart, same discharge cycle)? This changes the wording of a
   pre-registered criterion.
8. **Q8** — Adopt the early-stop rule (§8 above)?
9. **Q9** — Confirm that no app changes are made and that L1–L4 are handled procedurally?
10. **Q10** — If option B: confirm the shared cap (6 remaining, 8 in total) and that O1/O2 are not
    used for H1.

Unchanged regardless of the answers: H1, the ±5 tolerance, the §8 sufficiency thresholds and the
8-transmission cap. O3 still needs the §6–§7 preconditions **and** a new, explicit, written GO
after these decisions.
