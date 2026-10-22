# M1.1 — Progress and Handoff (sanitized)

Checkpoint as of **2026-10-22, after the O3 validity ruling**. **O3 VALID — architect accepted.
M1.1 PAUSED — awaiting O3r readiness assessment. O3r NOT AUTHORIZED. M2+ NOT AUTHORIZED.** Experimental and **non-medical**. The design, thresholds and
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
   2026-10-22 and is **VALID — architect accepted** (2026-10-22, records-based confirmation of
   V1–V9; no further transmission). It is the first observation counted toward sufficiency. The
   next step is the O3r readiness assessment (below), not sending. **O3r is NOT AUTHORIZED**;
   no query is authorized now.
4. Do not decode, interpret or study the extra notifications seen in O1/O2.

## Status

| Item | Value |
|---|---|
| Transmissions used | **3 of 8** (O1, O2, O3); **5 remaining** |
| Valid observations counted toward sufficiency (§8: ≥ 5) | **1 of 5**: O3 VALID. O1 historical, not counted; O2 provisional, not counted |
| O3 | **VALID — architect accepted** (2026-10-22). Performed 2026-10-22 (transmission 3) under a written architect GO; V1–V9 all MET (below) |
| O3r | **NOT authorized** — awaiting readiness assessment and a new written GO |
| H1 | **NOT YET PROVEN** |
| Verdict | **None.** Sufficiency not met → not yet SUPPORTED / REJECTED / INCONCLUSIVE |
| M2+ | **NOT authorized** |
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
- O3 at index 1: 60 vs reference 60, i.e. within the ±5 tolerance at index 1. O3 is VALID and
  counts, but this is **not a finding** on its own: no verdict is possible before sufficiency
  (§8, §9), and one observation at one level cannot distinguish battery % from a constant byte.
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

## O3 validity (V1–V9, experiment §16.4) — VALID, architect accepted (2026-10-22)

**Architect ruling (2026-10-22, after PR #11):** O3 is **formally VALID** and counts toward H1
sufficiency. All V1–V9 conditions are **MET**. This is a **records-based confirmation**: the
operator confirmed the outstanding items to the architect in ChatGPT from existing records. **No
additional BLE transmission occurred.**

| # | Condition | Final status | Evidence (sanitized) |
|---|---|---|---|
| V1 | Exactly one transmission, fresh launch, worksheet row before Send | **MET** | Fresh app launch; numbered O3 worksheet row prepared before Send; one query, no retry |
| V2 | ATT write acknowledged | **MET** | ATT write acknowledged |
| V3 | Exactly one timely compatible R; no M, Z, duplicate R or U; N8 recorded | **MET** | Exactly one timely framing-compatible response; no additional notifications or ANOMALY warning; N8 recorded before the app was closed |
| V4 | No pairing prompt, security error or unexpected device behavior | **MET** | None occurred |
| V5 | A and B within 15 min, \|A − B\| ≤ 5 | **MET** | Reference A = 60%, B = 60%, within 15 minutes |
| V6 | Band off the charger ≥ 15 min | **MET** | Off the charger at least 15 minutes |
| V7 | Vendor app disconnected during the query, reconnected afterwards | **MET** | Disconnected during O3; successfully reconnected afterwards |
| V8 | ≥ 30 min since the previous M1.1 query | **MET** | More than 30 minutes since O2 (2026-10-05) |
| V9 | Written architect GO before the run | **MET** | Written architect GO issued in ChatGPT before O3 |

V1–V9 are the protocol validity conditions of experiment §16.4. They are **distinct from the app's
eight on-screen send-gate checks** (BLE readiness preconditions), which do not establish any V
item. Sanitized result: Reference A/B 60% / 60%; candidate index 1 = 60; exactly one timely
framing-compatible response; no protocol abort condition reported.

### Historical record — O3 check as first reported (before the ruling, PR #11)

Kept unchanged as evidence of what the first report did and did not establish. Superseded by the
ruling above for the items marked UNVERIFIED here.

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
| V9 | Written architect GO before the run | **MET.** Written architect GO: **EXISTS**, issued in ChatGPT before O3 (conditional). The architect reaffirmed authorization after the operator reported the app's eight on-screen send preconditions (BLE readiness), which are not the V1–V8 items. GitHub record: **not previously recorded**; recorded here on 2026-10-22 | Architect confirmation (2026-10-22, PR #11 review) |

Also within plan: the reference 60 is inside the O3 range (45–70, §16.6).

V9 being met does **not** establish any of V1–V8. They stand as listed above. Per §16.4, the
written authorization must exist before transmission. It does not need to have been committed to
GitHub first (architect clarification, 2026-10-22).

(End of the historical record. The architect then requested and accepted the records-based
confirmation above.)

O3 counts toward the cap **and** toward sufficiency.

**Budget after the O3 ruling (§16.7):** 5 transmissions remain. O3 is VALID, so **4 valid
observations are still needed** (O3r, O4, O5, O6) with **1 spare** transmission. One non-VALID
observation can be absorbed; a second triggers the early-stop check (§16.7).

## Remaining plan (Revision 1 — APPROVED, in force since 2026-10-22, PR #9)

**5 transmissions remain** of the 8-transmission lifetime cap (no reset). The plan assumes
**neither O1 nor O2 counts** (experiment §16.6). O3 has been performed and is VALID:

| Planned | State |
|---|---|
| O3 | Middle, 45–70 (**performed 2026-10-22**, reference 60; **VALID — counted**) |
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
- [x] Every §6–§7 / V1–V9 precondition verified. Partly recorded in the first report; the rest
  confirmed from records and accepted by the architect (2026-10-22); see "O3 validity".
- [x] Written architect GO for O3: issued in ChatGPT before O3 (conditional), reaffirmed after the
  app's send preconditions were reported green. Recorded in GitHub afterwards (PR #11).

## Gate for O3r — NOT AUTHORIZED; all must be true before any query

- [x] The architect has ruled on O3's validity: **VALID** (2026-10-22).
- [ ] No charging since O3 (same discharge cycle).
- [ ] At least 30 minutes since O3.
- [ ] A fresh vendor Reference A within **58–62%** (±2 of O3's 60).
- [ ] All required §6–§7 / V1–V9 readiness and validity conditions verified and written down
  before Send.
- [ ] A **new written architect GO issued specifically for O3r**.

The operator verifies the first four items, then requests the O3r GO. If the band has been charged
since O3, or Reference A is outside 58–62%, **do not proceed automatically**: escalate to the
architect for a planning decision (§16.6). Any change to the plan or its order needs an architect
decision. No BLE command is sent before the GO.

During and after any run: the manual 10-second check and N8 recording (§16.2–§16.3) are done before
the app is closed. Abort conditions are §12 and §16.2. On any abort: stop, no retry, no workaround,
report to the architect.

## Not authorized

Any query or other device command now; O3r before its gate above (including its own written GO); decoding unsolicited or extra
notifications; any battery decoder/UI; M2+; Swift changes; `FEE7` writes; `DE5BF72x`
authentication or writes; automatic retry, polling or fuzzing.

## Privacy

No raw frames, payload values other than index 1 (100 for O1/O2, 60 for O3), O3 latency values, screenshots, peripheral
identifiers, account data or health measurements are recorded here. The private worksheet stays
off-repository (experiment §10).
