# M1.1 — Progress and Handoff (sanitized)

Checkpoint as of **2026-10-09**. Experimental and **non-medical**. The design, thresholds and
verdict rules live in [`M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`](M1_1_BATTERY_SEMANTICS_EXPERIMENT.md)
and are **unchanged**; this file only records what has physically happened and what is next.

Source of the evidence below: Dana's report to the agent. No screenshots, raw frames or the
private worksheet were seen by any agent. Items the repository cannot confirm are marked
**UNVERIFIED**.

## For a new session (read this first)

1. Read this file, then `docs/CURRENT_STATE.md`, `TODO.md` and the experiment document.
2. **Do not ask Dana to repeat the O1/O2 evidence.** It is recorded here. Ask only for the items
   marked UNVERIFIED if the architect says they matter.
3. The next step is **waiting**, not sending: O3 needs a vendor-app battery level in the middle
   state (roughly 45–70%), all protocol preconditions verified, and a **new explicit architect
   GO**. No query is authorized now.
4. Do not decode, interpret or study the extra notifications seen in O1/O2.

## Status

| Item | Value |
|---|---|
| Transmissions used | **2 of 8** (O1, O2) |
| Valid observations toward sufficiency (§8: ≥ 5) | at most 2, **provisional** (see validity below) |
| O3 | **NOT performed, NOT authorized** |
| Verdict | **None.** Sufficiency not met → not yet SUPPORTED / REJECTED / INCONCLUSIVE |
| Battery semantics | **NOT proven** |

## Confirmed physical history (sanitized)

| Obs | Date | Vendor reference | Result |
|---|---|---|---|
| O1 | 2026-10-04 | 100% (single reading) | One explicitly confirmed `0x03` query sent; ATT write acknowledged; one framing-compatible 16-byte response, checksum OK. **Candidate index 1 = 100.** An unsolicited non-`0x03` notification was also observed (not interpreted). |
| O2 | 2026-10-05 | A = 100%, B = 100% | One query sent at approx. 18:35 (time zone not recorded); acknowledged; one framing-compatible 16-byte response, checksum OK. **Candidate index 1 = 100.** See "O2 extra notification". |
| — | 2026-10-09 | 93% | **Reference-only checkpoint. Not O3. No query was sent.** |

- O2 reference bracket difference: **0 points**.
- O1 vs O2 at index 1: identical (difference 0, within the ≤ 2 same-state-repeat criterion).
  This is **consistent** with a same-state repeat. It proves nothing about battery semantics:
  both observations are at the same reference level (100%), so a constant byte would look the same.
- No other payload value is recorded in the repository (experiment §10, architect decision 2).
  Per-position classification (experiment §4) is therefore **not yet recorded**.

### O2 extra notification (distinct, preserved)

About 12 seconds after the O2 response, an additional notification arrived that was
**framing-incompatible but checksum-OK**. It was **not a second transmission** by us. It is
recorded as an anomaly and **was not decoded**. The following are **UNVERIFIED**:

- whether its command byte was `0x03` (framing-incompatible may mean wrong length or wrong command);
- whether the app's ANOMALY banner appeared;
- whether it counts under the experiment's §12 abort condition "more than one `0x03` response
  to a query". It is not a framing-compatible `0x03` response as reported, so it was not
  treated as one, but **that call belongs to the architect**; the agent does not make it.

The O1 unsolicited non-`0x03` notification is likewise recorded only as having occurred.

## Validity check against the protocol (O1 and O2)

Status: **provisionally usable, not confirmed valid.** Neither observation is labelled valid
until the architect accepts it.

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

## Remaining plan (design unchanged)

Per experiment §8: **6 transmissions remain** under the cap. Still required for sufficiency:
O3 (middle, roughly 45–70), O4 (low, ≤ 40), O5 (after a partial recharge, ≥ 15 points above
O4) — which also supplies the ≥ 40-point reference spread and ≥ 3 distinct levels. All
thresholds and criteria are as pre-registered and may not change.

## Gate for O3 — all must be true before any query

- [ ] The vendor app shows a middle-state battery level, roughly 45–70%. (Currently 93%: not met.)
- [ ] Every precondition in experiment §6–§7 is verified and written down: off charger ≥ 15 min,
  vendor app disconnected, ≥ 30 min since the previous query, numbered worksheet row, Reference A taken.
- [ ] The open O2 anomaly question above has been ruled on by the architect.
- [ ] A **new explicit architect GO** for O3 exists in writing.

Abort conditions are experiment §12, unchanged. On any abort: stop, no retry, no workaround,
report to the architect.

## Not authorized

Any query or other device command now; O3 before the gate above; decoding unsolicited or extra
notifications; any battery decoder/UI; M2+; Swift changes; `FEE7` writes; `DE5BF72x`
authentication or writes; automatic retry, polling or fuzzing.

## Privacy

No raw frames, payload values other than index 1 = 100 for O1/O2, screenshots, peripheral
identifiers, account data or health measurements are recorded here. The private worksheet stays
off-repository (experiment §10).
