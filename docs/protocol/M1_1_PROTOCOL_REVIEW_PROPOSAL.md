# M1.1 — Protocol Review and Continuation Proposal (after the O2 anomaly)

Status: **PENDING FINAL ARCHITECT REVIEW.** Documentation only. M1.1 is **PAUSED**. O3 is **NOT
AUTHORIZED**. No query or other device command is authorized, and nothing here instructs one.

Round 1 (2026-10-22): first draft; architect review = **CHANGES REQUESTED**, with rulings Q1–Q10 (§2).
Round 2 (this revision): the rulings are incorporated. The normative Revision 1 text now lives in
the experiment document, [`M1_1_BATTERY_SEMANTICS_EXPERIMENT.md` §16](M1_1_BATTERY_SEMANTICS_EXPERIMENT.md#16-revision-1--proposed-pending-final-architect-review-not-in-force).
This file holds the analysis and the decision record.

How to read the labels used in this file:

| Label | Meaning |
|---|---|
| **HISTORICAL** | Evidence from O1/O2 as reported; not rewritten |
| **DECIDED** | Architect ruling already made (2026-10-22) |
| **PROPOSED (Rev 1)** | Rule drafted for Revision 1; in force only after final architect approval |
| **UNVERIFIED** | Not documented; never assumed to have passed |
| **NOT AUTHORIZED** | O3 or any query, any Swift/BLE change, decoding of unknown notifications, M2+ |

H1 (experiment §1), the ±5 tolerance (§9), the sufficiency thresholds (§8) and the 8-transmission
cap (§8) are **unchanged**. The one change to a pre-registered criterion, the same-state repeat
(§16.5), is identified explicitly as a change.

Prepared by Claude Code (developer). Inputs: the repository (docs and the M1 app source). No raw
frames, screenshots, payload values beyond those already committed, or private-worksheet contents
were seen. The unsolicited notifications were **not** decoded or investigated.

## 1. Architect assessment (DECIDED, as given, 2026-10-22)

- The O2 extra notification does **not** establish a second framing-compatible `0x03` response.
- The app's ANOMALY banner counts only framing-compatible `0x03` responses.
- The extra notification nevertheless raises an **unresolved framing-failure question under §12**.
- **O2 cannot currently be accepted as fully valid.**
- **O1 also has outstanding unverified validity requirements.**
- M1.1 is on hold; O3 is not authorized; the payload of the extra notification is not to be decoded.

## 2. Architect rulings on the first draft (DECIDED, 2026-10-22)

| Q | Ruling | Where incorporated |
|---|---|---|
| Q1 | **R2 approved.** §12 "framing failure" concerns the expected `0x03` response, not unrelated non-`0x03` notifications | Experiment §12 note, §16.1 |
| Q2 | **Option A approved in principle.** Continue through a documented Revision 1, subject to final review | Experiment §16 |
| Q3 | **Conditional.** Revise N1–N7 to handle malformed, missing, duplicate and late responses explicitly | Experiment §16.2–§16.3 |
| Q4 | **Approved.** V1–V9; UNVERIFIABLE observations do not count toward sufficiency | Experiment §16.4 |
| Q5 | **O1 not accepted as valid.** Retained as historical evidence; its transmission counts | Experiment §14, §16.4 |
| Q6 | **O2 not yet accepted.** Its extra notification is not itself a duplicate valid response under R2, but other conditions are unverified | Experiment §14, §16.4 |
| Q7 | **Approved for Revision 1.** A later same-state repeat may replace the O1/O2-specific repeat, if approved before further observations | Experiment §16.5 |
| Q8 | **Approved.** Early stop when the remaining transmissions cannot meet sufficiency | Experiment §16.7 |
| Q9 | **Approved.** No Swift changes; limitations handled procedurally | Experiment §16.3, §16.9 |
| Q10 | **Confirmed.** 8 transmissions in total, 2 used, 6 remaining, no reset | Experiment §16 (unchanged list) |

These rulings authorize documentation revisions only, not O3.

## 3. The O2 anomaly and what is still uncertain

### 3.1 What is recorded (HISTORICAL)

O2 (2026-10-05): one explicitly confirmed `0x03` query; ATT write acknowledged; one
framing-compatible 16-byte response, checksum OK; candidate index 1 = 100; vendor reference
A = B = 100%. About **12 s after that response**, one further notification arrived. It was
reported as **framing-incompatible, checksum-OK**. It was not a second transmission by us. The
app was then closed; nothing is persisted, so the screen cannot be re-checked.

### 3.2 What the app's own checks imply (code reading only; no payload examined)

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

### 3.3 Still unresolved

UNVERIFIED, and not to be reconstructed from memory:

- Whether the report used the app's labels verbatim (and so whether 3.2 applies).
- Whether the ANOMALY banner appeared (3.2.4 says it should not have).
- Whether the O1 unsolicited non-`0x03` notification arrived before or after the O1 query.
- The O1/O2 precondition items marked UNVERIFIED in [`M1_1_PROGRESS_HANDOFF.md`](M1_1_PROGRESS_HANDOFF.md).

Resolved by the architect: neither event is a §12 framing failure under R2 (Q1).

## 4. Does §12 require terminating M1.1? (resolved: Q1 = R2)

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

**Answer:** §12 requires termination **only under R1**. Under R2, it does not.

**Ruling (Q1):** R2. It is recorded in experiment §16.1 as a **post-hoc clarification** adopted
after the O2 anomaly. The original §12 wording is preserved, with a dated note.

## 5. Is a separately approved continuation permissible?

Yes. The document provides for it. §9: "Any change needs a new document revision approved before
further observations." §8: "no extension without a new architect decision." §15: changes need a
new architect decision before further observations. A continuation is legitimate if it is written
down, approved **before** the next transmission, and does not quietly alter H1, the tolerance,
the thresholds or the cap.

## 6. Continuation alternatives (resolved: Q2 = A in principle)

| Option | What it means | For | Against |
|---|---|---|---|
| **A. Continue M1.1 under R2 + Rev 1 clarification** | Architect rules R2, adopts the notification rules in §6 and the validity rules in §7 as **Revision 1**, decides O1/O2 validity, then (separately) gives O3 GO. | Keeps all 6 remaining transmissions and possibly O1/O2; no code change; criteria untouched. | The clarification is written *after* seeing the anomaly (post-hoc). Mitigated by applying it to O1 and O2 alike and by it not touching H1, the tolerance, or which byte is the candidate. |
| **B. Close M1.1 INCONCLUSIVE (R1); pre-register a continuation "M1.1-R"** | M1.1 ends as INCONCLUSIVE (abort before sufficiency). A new document with the **same** H1, tolerance and thresholds, the §6/§7 rules, and a cap equal to the **6 remaining** transmissions (total budget stays 8). O1/O2 are **not** used for H1. | Cleanest pre-registration story; the strict rule is honored. | Needs 5 valid observations from 6 transmissions (1 spare); needs a high-state observation again (recharge) or a different same-state repeat. |
| **B′. As B, but carry O1/O2 forward as provisional** | Like B, with O1/O2 imported subject to §7 validity. | More margin. | Close to A in substance while claiming R1. Mixing an aborted experiment's data into a new one is the weakest option methodologically. Not recommended. |
| **C. Keep M1.1 open; treat O2 as an observation-level invalid** | §12 is read as "stop this observation" rather than "stop the experiment". O2 counted, not used. | Simple. | This is itself a reinterpretation of §12 (an experiment-level stop becomes observation-level). Needs the same explicit ruling as A, without A's clarity. |
| **D. Stop; no continuation** | M1.1 INCONCLUSIVE; battery semantics parked. | No further device interaction. | Leaves the M1.1 question open; the 6-transmission budget goes unused. |

The developer recommended **A**. **Ruling (Q2): A approved in principle.** O1/O2 are nonetheless
treated conservatively: neither is counted, so the plan matches option B's requirements (5 valid
observations from the 6 remaining transmissions) while staying within M1.1.

## 7. Revision 1 summary (PROPOSED; normative text in experiment §16)

### 7.1 Notification rules: first draft → Revision 1

Notifications are classified only by the app's existing labels: **R** (valid `0x03` response),
**M** (malformed `0x03`), **U** (unrelated non-`0x03`), **Z** (unclassifiable: no byte-0 label, or
labels not recorded before the app closed).

| Case | First draft | Revision 1 (§16.2) |
|---|---|---|
| Valid response | One framing-compatible `0x03` within 10 s | **N1** Exactly one R within the window; "within" = displayed log difference **≤ 9 s**. Conservative: the log shows whole seconds, so this does not prove the precise elapsed time |
| Missing / late | Folded into N5 | **N2** Explicit: no R within the window (including an R that arrives late) → observation fails; §12 "no response within 10 s" applies |
| Malformed `0x03` | N3 | **N3** Any M after the query → §12 abort |
| Duplicate | N5 (banner) | **N4** More than one R at any time, banner or not → §12 abort |
| Empty / unclassifiable | Empty after the query → framing failure | **N5** Any Z after the query → §12 abort. A Z before the query → do not send in that launch. Never assumed harmless |
| Unrelated non-`0x03` | N4 | **N6** Not decoded, interpreted or acted on; never substitutes for the R |
| Security / pairing / unexpected behavior | Implicit (§12) | **N7** Listed explicitly, unchanged |
| Recording | N6 | **N8** Fixed field list, written before closing the app; flags and counts only are committed |
| Retroactivity | N7 "applies to O1 and O2" | R2 applies to O1/O2 (Q1). N5 applies only to observations taken after approval; O1/O2 are governed by Q5/Q6 |

### 7.2 Manual 10-second check

The app's 10-s timer only checks whether *any* notification arrived after the query, so a
U/M/Z suppresses its warning. Experiment §16.3 defines the manual check: compare the `SENDING`
and "framing COMPATIBLE" log times, classify every other notification, and record N8 before
closing the app. No app change.

### 7.3 Validity policy

V1–V9 (§16.4). Only VALID counts; unknown is never assumed to have passed.

- **O1:** HISTORICAL, not valid for H1.
- **O2:** PROVISIONAL, not counted. It can count only if verified from existing records and
  accepted by the architect; Dana is not asked to reconstruct events from memory.

### 7.4 Same-state repeat (explicit change)

§16.5 replaces the O1/O2-specific repeat. The replacement is any VALID pair in the same discharge
cycle, ≥ 30 min apart, with references within ±2. Every qualifying pair must agree within 2 at
index `i`.

## 8. Feasibility of the remaining 6 transmissions

Planned conservatively for **neither O1 nor O2 counting** (§16.6):

| | O3 | O3r | O4 | O5 | O6 | spare |
|---|---|---|---|---|---|---|
| State | 45–70 | O3 ±2, same cycle, ≥ 30 min later | ≤ 40 and ≥ 15 below O3 (not below ~20) | after partial recharge, ≥ O4 + 40 and ≥ O3 + 15 | any, ≥ 30 min after O5 | — |

Original requirement → how the plan meets it:

| Requirement | Met by |
|---|---|
| ≥ 5 valid | O3, O3r, O4, O5, O6 |
| Spread ≥ 40 | O5 − O4 |
| 3 levels pairwise ≥ 15 apart | O4 < O3 < O5 |
| Upward change | O4 → O5 |
| Same-state repeat | O3/O3r |
| H1, ±5, cap | Unchanged |

**O5 is stronger than the original target.** The original O5 target was "≥ 15 above O4". The
revised plan requires **O5 ≥ O4 + 40 and O5 ≥ O3 + 15** (§16.6), so that the unchanged spread and
level thresholds can be met without O1/O2. These are revised-plan requirements, not new thresholds.

**All states are opportunistic.** They are reached through normal use and normal charging. There
is no forced discharge, no going below about 20%, and no unsafe charging. If a state is not reached
safely, the early-stop rule applies.

**Margin: 1 spare.** Two non-VALID observations, or any §12 abort, end M1.1 as INCONCLUSIVE
(§16.7, §9). The plan is feasible but fragile; that is the honest consequence of not counting
O1/O2.

Timing: the latest reported vendor reference is 60% (date not recorded; reference only). If the
level is outside 45–70 when a GO is given, wait for the next discharge cycle. Do not stress the
band.

## 9. If the evidence remains insufficient

INCONCLUSIVE, with no extension and no budget reset (§16.8). Battery semantics stay NOT proven.
Any further attempt is a new pre-registered experiment. M2 is not authorized.

## 10. Implementation implications

No Swift changes (Q9). The app already shows every label the rules need: after-query flag,
length, byte 0 = / ≠ `0x03`, checksum, framing compatibility, and log times to the second.

Limitations and how they are handled (§16.9):

| Limitation | Handled by |
|---|---|
| No persistence | N8 |
| Timer not response-specific | §16.3 |
| Banner ignores M/Z | §16.3 |
| "After query" not window-based | §16.3 |

Guards and tests are unchanged.

## 11. Points for final architect review

The Q1–Q10 rulings are incorporated. These Revision 1 details were drafted by the developer and
need explicit confirmation:

1. **Abort consequence.** §9 (unchanged) makes *any* §12 abort before sufficiency INCONCLUSIVE.
   Revision 1 keeps that, so N2 (missing/late), N3, N4 and N5 each **end M1.1**. The ruling's
   wording "a missing or late valid response *fails the observation*" could be read as
   observation-level only. Making it observation-level would be a change to §12/§9, not a
   clarification. The developer recommends keeping the original, stricter consequence. Confirm.
2. **≤ 9 s displayed threshold** (§16.2). It is conservative because the log records whole
   seconds. It does not prove the precise elapsed time. A real 9.5 s response displayed as "10 s"
   would be treated as late and would end M1.1. *(Clarified per the final architect corrections.)*
3. **Z before the query → do not send in that launch** (N5). Confirm.
4. **"Every qualifying pair"** in the same-state repeat (§16.5). Confirm.
5. **O2 path.** The developer proposes no request to Dana. O2 stays provisional and unused unless
   records-based verification is offered. Confirm.
6. **Fixed default order** (O3 → O3r → O4 → O5 → O6); any reordering needs an architect decision.
   Confirm.
   *(The O5 ≥ O4 + 40 and ≥ O3 + 15 requirement, and the opportunistic, no-forced-discharge
   approach, are documented per the final architect corrections, §16.6.)*
7. **Final approval of Revision 1 as a whole** (experiment §16). After that, O3 still needs a
   separate written GO.
