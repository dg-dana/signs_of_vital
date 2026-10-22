# M1.1 — Progress and Handoff (sanitized)

Checkpoint as of **2026-10-22, after O3** (M1.1 **PAUSED**; O3r NOT AUTHORIZED). Experimental and **non-medical**. The design, thresholds and
verdict rules live in [`M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`](M1_1_BATTERY_SEMANTICS_EXPERIMENT.md)
and are **unchanged**; this file only records what has physically happened and what is next.

Source of the evidence below: Dana's report to the agent. No screenshots, raw frames or the
private worksheet were seen by any agent. Items the repository cannot confirm are marked
**UNVERIFIED**.

## For a new session (read this first)

1. Read this file, then `docs/CURRENT_STATE.md`, `TODO.md` and the experiment document.
2. **Do not ask Dana to repeat the O1/O2 evidence or to reconstruct old events from memory.** It is
   recorded here. Items marked UNVERIFIED stay unverified and are never assumed to have passed.
3. Revision 1 (experiment §16) is **approved and in force** (2026-10-22, PR #9). O3 was performed on
   2026-10-22 and is **provisionally successful, not yet formally VALID** (architect). The next step
   is the architect's decision on O3's open V1–V9 items, not sending. **O3r is NOT AUTHORIZED**;
   no query is authorized now.
4. Do not decode, interpret or study the extra notifications seen in O1/O2.

## Status

| Item | Value |
|---|---|
| Transmissions used | **3 of 8** (O1, O2, O3); **5 remaining** |
| Valid observations counted toward sufficiency (§8: ≥ 5) | **0**: O1 historical; O2 provisional; O3 provisionally successful, **not yet formally VALID** |
| O3 | **Performed 2026-10-22** (transmission 3). Provisionally successful; V1–V9 not all verified (below) |
| O3r | **NOT authorized** |
| Verdict | **None.** Sufficiency not met → not yet SUPPORTED / REJECTED / INCONCLUSIVE |
| Battery semantics | **NOT proven** |

## Historical evidence (sanitized, as reported)

| Obs | Date | Vendor reference | Result |
|---|---|---|---|
| O1 | 2026-10-04 | 100% (single reading) | One explicitly confirmed `0x03` query sent; ATT write acknowledged; one framing-compatible 16-byte response, checksum OK. **Candidate index 1 = 100.** An unsolicited non-`0x03` notification was also observed (not interpreted). |
| O2 | 2026-10-05 | A = 100%, B = 100% | One query sent at approx. 18:35 (time zone not recorded); acknowledged; one framing-compatible 16-byte response, checksum OK. **Candidate index 1 = 100.** See "O2 extra notification". |
| — | 2026-10-09 | 93% | **Reference-only checkpoint. Not O3. No query was sent.** |
| — | not recorded | 60% | **Reference-only (reported before O3). Not an observation. No query was sent.** |
| O3 | 2026-10-22 | A = 60%, B = 60% | Transmission 3 of 8. One query; ATT write acknowledged; exactly one framing-compatible 16-byte `0x03` response, checksum OK; response within the window (displayed difference ≤ 9 s, §16.2); no additional notifications in the event log as provided; no retry. **Candidate index 1 = 60.** See "O3 validity". |

- O2 reference bracket difference: **0 points**.
- O1 vs O2 at index 1: identical (difference 0, within the ≤ 2 same-state-repeat criterion).
  This is **consistent** with a same-state repeat. It proves nothing about battery semantics:
  both observations are at the same reference level (100%), so a constant byte would look the same.
  Because O1 is not valid (Q5), this pair **cannot** serve as the sufficiency repeat (experiment §16.5).
- O3 at index 1: 60 vs reference 60, i.e. within the ±5 tolerance at index 1. This is **not a
  finding**: no verdict is possible before sufficiency (§8, §9), and O3 is not yet VALID.
- No other payload value is recorded in the repository (experiment §10, architect decision 2).
  Per-position classification (experiment §4) is therefore **not yet recorded**.

### O2 extra notification (distinct, preserved)

About 12 seconds after the O2 response, an additional notification arrived that was
**framing-incompatible but checksum-OK**. It was **not a second transmission** by us. It is
recorded as an anomaly and **was not decoded**. The following are **UNVERIFIED**:

- the exact on-screen labels. If they were "checksum OK" and "framing NOT compatible" verbatim,
  the app's code implies byte 0 ≠ `0x03` (proposal §3.2). This is not a decoding;
- whether the app's ANOMALY banner appeared (by code, it should not have).

Whether it falls under §12 is **resolved by the architect** (below): it does not.

The O1 unsolicited non-`0x03` notification is likewise recorded only as having occurred
(before or after the O1 query: **UNVERIFIED**).

The app was closed after O2 and nothing is persisted, so the screen cannot be re-checked.

**Architect decisions (2026-10-22):**
- The extra notification does not establish a second framing-compatible `0x03` response.
- §12 "framing failure" is read as concerning the expected `0x03` response only (R2). This is a
  **post-hoc clarification**, applied equally to O1 and O2, so neither extra non-`0x03`
  notification is a framing failure.
- No unknown notification is decoded or given meaning.
- Analysis: [`M1_1_PROTOCOL_REVIEW_PROPOSAL.md`](M1_1_PROTOCOL_REVIEW_PROPOSAL.md) §3–§4.

## Validity of O1 and O2 (architect decisions Q5/Q6)

- **O1 — HISTORICAL, not valid for H1.** Reference B and other required conditions are
  undocumented. Its transmission counts.
- **O2 — PROVISIONAL, not counted.** The items below are UNVERIFIED. It counts only if they are
  verified from existing records and the architect accepts it. Dana is not asked to reconstruct
  them from memory, and the remaining plan does not rely on O2.

UNVERIFIED items are never assumed to have passed. The table below is the historical checklist.

| Condition (experiment §) | O1 | O2 |
|---|---|---|
| Exactly one request, ATT write acknowledged (§5, §7) | Reported yes | Reported yes |
| Exactly one framing-compatible `0x03` response, checksum OK (§7, §9.2) | Reported yes | Reported yes |
| Candidate value within 0–100 and within ±5 of reference (§9) | 100 vs 100: yes | 100 vs 100: yes |
| Reference bracket A and B within 15 min, \|A−B\| ≤ 5 (§6) | **UNVERIFIED** (single reference reported, no bracket) | A/B reported, difference 0; 15-minute window **UNVERIFIED** |
| Same-state repeat: ≥ 30 min after previous, reference within ±2 (§8) | n/a | Different day; reference 100 vs 100: yes |
| Band off charger ≥ 15 min (§7) | **UNVERIFIED** | **UNVERIFIED** |
| Vendor app disconnected during the query (§6 step 2) | **UNVERIFIED** | **UNVERIFIED** |
| Vendor app reconnected afterwards (§6 step 4) | **UNVERIFIED** | Implied by Reference B; not explicitly confirmed |
| Fresh launch, one request per launch (§5, §7) | Reported (exactly one query) | Reported (exactly one query) |
| Numbered worksheet row before Send (§8) | **UNVERIFIED** | **UNVERIFIED** |
| Response within 10 s (§12) | **UNVERIFIED** (response reported, latency not) | **UNVERIFIED** |
| No pairing prompt / security error / unexpected device behavior (§12) | **UNVERIFIED** (not reported either way) | **UNVERIFIED** |
| Explicit architect GO before the run (§7) | **UNVERIFIED** in the repository | **UNVERIFIED** in the repository |

## O3 validity (V1–V9, experiment §16.4) — PROVISIONALLY SUCCESSFUL, not yet formally VALID

Evidence source: Dana's sanitized report to the agent (2026-10-22). Only what that report states is
marked met; nothing is inferred. Per §16.4, any item that is not verified makes the observation
UNVERIFIABLE (not counted) until the architect decides.

| # | Condition | O3 status | Basis |
|---|---|---|---|
| V1 | Exactly one transmission | Reported **yes** (transmission 3; no retry) | Report |
| V1 | Fresh app launch | **UNVERIFIED** | Not stated |
| V1 | Numbered worksheet row written before Send | **UNVERIFIED** | Not stated |
| V2 | ATT write acknowledged | Reported **yes** | Report |
| V3 | Exactly one R within the window (N1) | Reported **yes**: one framing-compatible 16-byte `0x03`, checksum OK; displayed difference ≤ 9 s | Report |
| V3 | No M, Z, duplicate R or U (N2–N6) | **Partly verified**: no additional notification in the event log *as provided*. Whether that log was complete, and the observations panel / ANOMALY banner state, are **UNVERIFIED** | Report |
| V3 | N8 fields written to the worksheet before the app was closed | **UNVERIFIED** | Not stated |
| V4 | No pairing prompt, security error or unexpected device behavior | **UNVERIFIED** | Not stated either way |
| V5 | A and B within 15 min, \|A − B\| ≤ 5 | **Met**: A = 60, B = 60 (difference 0); bracket within 15 min reported | Report |
| V6 | Band off the charger ≥ 15 min | **UNVERIFIED** | Not stated |
| V7 | Vendor app disconnected during the query | **UNVERIFIED** | Not stated |
| V7 | Vendor app reconnected afterwards | **UNVERIFIED** (Reference B was read, but reconnection is not explicitly confirmed) | Not stated |
| V8 | ≥ 30 min since the previous M1.1 query | **Met** | The repository records the previous query (O2) on 2026-10-05 |
| V9 | Written architect GO before the run | **UNVERIFIED in the repository** (no written O3 GO is recorded here) | Repository |

Also within plan: the reference 60 is inside the O3 range (45–70, §16.6).

O3 counts toward the cap. It counts toward sufficiency only once the architect formally accepts
it as VALID. A one-time, records-based confirmation of the UNVERIFIED items above is possible only
if the architect asks for it. Missing confirmations are not inferred.

**Budget after O3 (§16.7):** 5 transmissions remain.

| If O3 is ruled… | Valid observations still needed | Spare transmissions |
|---|---|---|
| VALID | 4 (O3r, O4, O5, O6) | 1 |
| not VALID | 5 | 0: every remaining observation would need to be VALID; any non-VALID one triggers early stop |

## Remaining plan (Revision 1 — APPROVED, in force since 2026-10-22, PR #9)

**5 transmissions remain** of the 8-transmission lifetime cap (no reset). The plan assumes
**neither O1 nor O2 counts** (experiment §16.6). O3 has been performed (provisional):

| Planned | State |
|---|---|
| O3 | Middle, 45–70 (**performed 2026-10-22**, reference 60; provisional) |
| O3r | Same-state repeat of O3: same discharge cycle, ≥ 30 min after O3, reference within ±2 of 60 (§16.5–§16.6). **NOT AUTHORIZED** |
| O4 | Low: ≤ 40, ≥ 15 below O3 (so ≤ 40 given O3 = 60), not below ~20 |
| O5 | After a partial recharge: ≥ O4 + 40 and ≥ O3 + 15, i.e. ≥ 75 given O3 = 60 (revised-plan requirement, stronger than the original "≥ 15 above O4") |
| O6 | Any state |
| — | 1 spare |

H1, the ±5 tolerance and the thresholds are unchanged. The replacement same-state repeat (§16.5) is
an explicit Revision 1 change, as is the stronger O5 requirement. All states are reached
opportunistically through normal use and charging: no forced discharge, no unsafe charging. Early stop (§16.7): if the remaining transmissions cannot reach
sufficiency, stop and record INCONCLUSIVE.

## Gate for O3 (historical — O3 performed 2026-10-22)

- [x] Revision 1 approved and merged (PR #9, `c69c024`).
- [x] Middle-state reference: A = B = 60%.
- [ ] Every §6–§7 / V1–V9 precondition verified and written down before Send. Partly; see "O3 validity".
- [ ] Written architect GO for O3 recorded in the repository. **UNVERIFIED in the repository.**

## Gate for O3r — all must be true before any query

- [ ] The architect has ruled on O3's validity (the UNVERIFIED V1–V9 items above).
- [ ] O3r conditions hold: same discharge cycle as O3 (no charging since O3), ≥ 30 min after O3, and
  a Reference A within ±2 of 60.
- [ ] Every §6–§7 / V1–V9 precondition is verified and written down before Send.
- [ ] A **new explicit written architect GO** for O3r exists.

Timing risk (not a decision): if the band is charged, or the level leaves 58–62 before an O3r GO,
the planned O3r can no longer be taken in this cycle. Any change to the plan or its order needs an
architect decision (§16.6).

During and after any run: the manual 10-second check and N8 recording (§16.2–§16.3) are done before
the app is closed. Abort conditions are §12 and §16.2. On any abort: stop, no retry, no workaround,
report to the architect.

## Not authorized

Any query or other device command now; O3r before its gate above; decoding unsolicited or extra
notifications; any battery decoder/UI; M2+; Swift changes; `FEE7` writes; `DE5BF72x`
authentication or writes; automatic retry, polling or fuzzing.

## Privacy

No raw frames, payload values other than index 1 (100 for O1/O2, 60 for O3), O3 latency values, screenshots, peripheral
identifiers, account data or health measurements are recorded here. The private worksheet stays
off-repository (experiment §10).
