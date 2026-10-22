# M1.1 — Battery Payload Semantics Experiment

Status: **DESIGN APPROVED — PARTIALLY EXECUTED: 3 of 8 transmissions used (O1, O2, O3); 5
remaining. M1.1 PAUSED AFTER O3 — awaiting architect review of O3 validity. O3r NOT AUTHORIZED.**
No verdict yet (sufficiency in §8 not met). The O2 anomaly and the resulting protocol review
remain documented as historical evidence (§12 note, §16, handoff). Sanitized progress and handoff:
[`M1_1_PROGRESS_HANDOFF.md`](M1_1_PROGRESS_HANDOFF.md).

**Revision 1** (§16) is **APPROVED and IN FORCE**. The architect approved it on 2026-10-22, and
it was merged in PR #9 (merge commit `c69c024`). It follows the architect's rulings on
[`M1_1_PROTOCOL_REVIEW_PROPOSAL.md`](M1_1_PROTOCOL_REVIEW_PROPOSAL.md). Sections 1–15 are the
original approved text, kept as the historical record. Where Revision 1 changes or clarifies them,
a dated note points to §16. Approval of the protocol does **not** authorize any device
transmission. Any further `0x03` (or other) transmission needs a separate readiness check (the §7
and §16.4 preconditions verified) **and** a **new explicit written architect GO**.

The design, thresholds and criteria below are unchanged since approval (§15). The XCTest suite
has passed in CI (§13).

Experimental and **non-medical**. This is **not** M2: no protocol layer, no decoder, no
"Battery %" feature.

## 1. Question and hypothesis

**Question:** In valid `0x03` responses from our H59B, is there a payload field that can be
defensibly interpreted as battery level? If so, where is it and how is it encoded?

**Primary hypothesis (H1, pre-registered):** exactly one payload byte at a fixed index
`i` (1 ≤ `i` ≤ 14) is an unsigned 8-bit value equal to the battery percentage (0–100) shown
by the independent reference, within the tolerance in §9.

H1 is the **only** interpretation that can reach SUPPORTED in M1.1. Any other relationship
seen in the data (other scale, multi-byte field, coarse levels, offset) is recorded as a
**new hypothesis** for a later, separately authorized experiment. It is never adopted by
adjusting H1 after the results are in.

## 2. What M1 already established (2026-10-03, one observation)

On this H59B (`H59B_V1.0`, firmware `H59B_1.00.00_260402`), per
[`M1_BATTERY_EXPERIMENT.md`](M1_BATTERY_EXPERIMENT.md#results-2026-10-03):

- the UART channel accepts our independently built `0x03` request;
- the `.withResponse` ATT write was acknowledged;
- a 16-byte notification with byte 0 = `0x03` arrived;
- it passed our checksum rule (byte 15 = sum of bytes 0–14 mod 256).

## 3. What remains unknown

- Which payload byte (if any) is battery level; its encoding and scale.
- Which payload bytes are invariant structure and which vary.
- Whether the response layout is stable across observations.
- Whether the reference shown by the vendor app is itself derived from this same response.
  It may well be, so agreement shows "consistent with the vendor app's battery display", not
  "true cell charge" (§6).

## 4. Byte classification used in the results

Each position of a valid response is classified only from the observations:

| Class | Definition |
|---|---|
| **Framing (confirmed)** | Byte 0 (command echo `0x03`) and byte 15 (checksum). Confirmed by M1 and re-checked on every observation. |
| **Invariant – zero** | Payload byte that is `0` in every valid observation. |
| **Invariant – non-zero** | Payload byte with the same non-zero value in every valid observation (structural or unknown; not interpreted). |
| **Varying** | Payload byte whose value differs between valid observations. |
| **Candidate** | A varying byte that satisfies every H1 condition in §9. |
| **Unknown** | Everything else, including varying bytes that are not candidates. |

A byte is never labelled battery level because its value "looks like a percentage".

## 5. Exact scope

Allowed (after GO only):

- The existing, unchanged M1 send path: one fixed 16-byte request
  `03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03`, `.withResponse`, to
  `6E400002-B5A3-F393-E0A9-E50E24DCCA9E`, observing `6E400003-B5A3-F393-E0A9-E50E24DCCA9E`
  in service `6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E`.
- At most **one** request per app launch (existing one-shot latch), at most **8** requests in
  total for M1.1 (§8).

Not allowed: any other command or payload; HR/BP/SpO2/HRV/stress/sleep/steps/realtime;
decoding or acting on unsolicited notifications; `FEE7` writes; `DE5BF72x`
authentication or writes; pairing/bonding workarounds; fuzzing; automatic retry,
reconnect-and-send, polling or repeated sampling; a protocol layer; a production decoder;
a user-facing battery value; M2/M3/M4 work. The M0 project is untouched.

## 6. Independent reference (comparison evidence, not ground truth)

The reference is the battery indication in the existing Bionny/QWatch app on Dana's phone.
It is treated as comparison evidence only. It is not assumed to be accurate, and it may be
derived from the same device response, which limits what agreement can prove (§3).

For each observation, Dana records **only the number** (or the bar count, if no number is
shown) and how it is displayed (`%` or bars). Do not take screenshots of the vendor app: it
shows account and health data.

Bracketing procedure, all within **15 minutes**:

1. **Reference A:** open the vendor app, let it connect and refresh, and read the battery
   indication.
2. Make sure the vendor app is **no longer connected** to the band (e.g. turn Bluetooth off on
   that phone), so our app is not competing for the connection.
3. Take the M1.1 observation (§7).
4. Turn the phone's Bluetooth back on, **confirm the vendor app has reconnected** to the band
   and refreshed, then read **Reference B**. If it does not reconnect, abort (§12).

Reference for the observation = mean of A and B. If |A − B| > 5 points (or the bar count
differs), the observation is **invalid**: it is recorded and counted, but not used for H1.

## 7. Per-observation procedure (after GO only)

Preconditions: band **off the charger for at least 15 minutes** (avoids charge-state
transients); vendor app disconnected per §6 step 2; at least **30 minutes** since the previous
M1.1 request.

1. Swift Playgrounds → open `ios/SignsOfVital-M1.swiftpm` → **Run** (fresh launch; the latch
   allows one request per launch).
2. Start scan → tap the Bionny → wait for all eight preconditions to be green.
3. **Prepare battery query** → **Send once**, exactly once.
4. Confirm on screen: write acknowledged; exactly one framing-compatible `0x03` response after
   the query (the app shows an **ANOMALY** warning if more than one arrives).
5. Transcribe into the private worksheet (§10) the 14 values listed under
   "Payload by position". Transcribe nothing else from the screen.
6. Disconnect, stop the app, and do step 4 of §6.

The app shows **no hex** for any notification. Unsolicited or non-`0x03` notifications show
only length and framing checks. They are not transcribed, decoded or acted on.

## 8. Observation plan and the sufficiency threshold

Required valid observations (all off-charger):

| # | Battery state (by reference) | Purpose |
|---|---|---|
| O1 | High (≥ 80) | Upper anchor |
| O2 | High, same state as O1: ≥ 30 min later, reference unchanged within ±2 | Repeatability: no-change check |
| O3 | Middle (roughly 45–70) | Discharge tracking |
| O4 | Low (≤ 40) | Lower anchor |
| O5 | After a partial recharge, ≥ 15 points above O4 | Direction reversal: separates battery from time-like counters |

Sufficiency (all of these, decided now): at least **5 valid** observations; reference spread
**≥ 40 points**; at least **3 distinct levels ≥ 15 points apart**; at least **one upward
change** (O5) and at least **one same-state repeat** (O2).

> *Revision 1 note (in force since 2026-10-22, PR #9):* the thresholds above are unchanged. The plan table
> and the O1/O2-specific repeat are replaced for the remaining transmissions by §16.5–§16.6,
> which assume neither O1 nor O2 is valid.

**Hard cap: 8 transmissions in total** for M1.1, counting invalid and anomalous ones. Each is
numbered in the worksheet before pressing Send. If the cap is reached without sufficiency,
the result is INCONCLUSIVE. There is no extension without a new architect decision.

Do not deliberately run the battery down below ~20% or otherwise stress the device.

## 9. Evidence criteria (fixed before execution)

Tolerance: an observation **agrees** with H1 at index `i` if
|value[`i`] − reference| ≤ **5** points.

**SUPPORTED:** all of the following hold:

1. the sufficiency threshold in §8 is met;
2. every valid observation passed the framing checks with exactly one `0x03` response;
3. exactly **one** index `i` agrees with the reference in **every** valid observation;
4. at index `i`, every value is within 0–100;
5. at index `i`, the direction of change matches the reference for every pair of valid
   observations whose reference differs by ≥ 10 points, including the upward change (O5);
6. at index `i`, the same-state repeat (O2) differs from O1 by ≤ 2;
   *(Revision 1, in force since 2026-10-22: wording replaced by §16.5. This is an explicit change, not a
   clarification.)*
7. no other varying byte also satisfies 3–6.

Result wording if supported: "byte `i` of the `0x03` response, unsigned 8-bit, is consistent
with the vendor app's battery percentage on this device/firmware." It is still not a production
decoder; using it needs a separate architect decision.

**REJECTED** (H1 is contradicted). With the sufficiency threshold met, **every** varying
payload index fails H1 in at least one of these ways:

- a value > 100 in any valid observation; or
- a direction contradiction: for a pair with a reference change ≥ 15 points, the byte moves
  ≥ 5 in the opposite direction.

If no payload byte varies at all, the result is INCONCLUSIVE (see below), not REJECTED.

**INCONCLUSIVE:** everything else, including:

- the reference changed but no candidate field changed (or no payload byte varies);
- several fields change and cannot be distinguished (more than one index meets criteria 3–6);
- a field varies consistently with the reference but outside the ±5 tolerance (e.g. a
  different scale or coarse levels). This is recorded as a **new hypothesis**, not adopted;
- too little battery-state variation, or fewer than 5 valid observations by the cap;
- reference and response disagree without a direct contradiction;
- an inconsistent response layout (framing failure, wrong length, or more than one `0x03`
  response for a query);
- any abort (§12) before sufficiency.

The criteria, tolerance and plan above may not be changed after the first M1.1 transmission.
Any change needs a new document revision approved before further observations.

## 10. Privacy rules

- **Nothing raw is committed.** No hex, no full frames, no screenshots or screen recordings
  of the app or the vendor app, no peripheral identifiers, account data, serial/System ID or
  health data.
- The app is unchanged in this respect: nothing is persisted, there is no logging framework,
  no copy/share/export. Notification bytes never enter the event log, and observation rows
  are not text-selectable.
- **Private worksheet (off-repository).** Comparing observations taken hours or days apart
  needs the payload values per observation. Dana keeps them in a private worksheet
  (paper or a local note) that is **never committed, pasted into GitHub, or attached to a
  PR/issue**. Contents per row: observation number, date and hour only, reference A/B and
  display form, minutes off charger, framing checks OK yes/no, and the 14 payload values. No
  byte 0/15, no hex, no screenshots. It is deleted once the architect accepts the M1.1 result.
  *(Architect decision 1: approved as specified.)*
- **Committed results (sanitized):** per observation, **only** the candidate byte's value and
  the vendor reference, plus validity flags, counts, the per-position class labels (§4, labels
  only) and the verdict. All 14 payload values are **never** committed; no byte value other
  than the candidate's appears in the repository. *(Architect decision 2.)*

## 11. Manual gating (unchanged from M1, guarded)

- Nothing is sent on launch, scan, connect, discovery, subscription, notification, write
  callback, timer or reconnect. The only transmit call is reached solely from the **Send once**
  confirmation button after **Prepare battery query**, and it re-checks the pure
  `BatteryQueryGate` against live state.
- One-shot latch per app launch: a second request needs a full relaunch and a fresh two-step
  action. There is no auto-connect and no auto-reconnect.
- Rapid repeats are hard to do by accident: two taps plus a relaunch per request, a 30-minute
  procedural minimum spacing, a numbered worksheet row before each Send, and the hard cap of 8.
- A cross-launch counter or cooldown would need on-device persistence, which the guard
  forbids. It is not added; counting and spacing stay procedural (architect decision 3).

## 12. Abort conditions

The experiment is stopped (no retry, no workaround) and reported to the architect on:

- any iOS pairing prompt (tap **Cancel**, then **Log pairing prompt**), or any
  `insufficientAuthentication` / `insufficientEncryption` / `insufficientEncryptionKeySize`
  ATT error. This is the existing abort behavior, unchanged;
- a write error, no response within 10 s, a framing failure, or more than one `0x03` response
  to a query (the ANOMALY banner);
- unexpected device behavior (reset, vibration pattern, settings change, the vendor app
  showing errors or losing data);
- the vendor app being unable to reconnect afterwards;
- reaching the 8-transmission cap.

> *Historical note (2026-10-22):* the text above was approved as written. It does not say which
> notification "a framing failure" refers to; that was **not** unambiguously settled before O1.
> After the O2 anomaly the architect ruled (Q1, reading **R2**) that it refers to the expected
> `0x03` response to our query. This is a **post-hoc clarification**, recorded in §16.1. The
> list of abort triggers is unchanged.

## 13. Device-free verification

| Check | What it covers |
|---|---|
| `sh ios/scripts/check_m1_gate.sh` | Exactly one `writeValue` (fixed request, write characteristic, inside `confirmAndSendBatteryQuery`, single caller = confirmation button); gate + latch wired; single user-initiated `connect`; no prohibited APIs/channels (`FEE7`, `DE5BF72x`, reads, descriptors, persistence, timers). **M1.1 additions:** exactly one frame build, `Frame16.build(command: commandByte)` with no payload, and `commandByte` = `0x03`; no alternative command byte; at most one `asyncAfter` and no loops/other schedulers; no battery decoder or "Battery:"/percent UI; notification bytes never in the event log; no hex rendered in the UI; no copy/share/export APIs. |
| `python3 ios/scripts/check_m1_vectors.py` | Request/checksum vectors, plus the payload-position rule (bytes 1–14 only). |
| `swift test --package-path ios/SignsOfVital-M1Tests` | Existing frame/gate tests plus `PayloadPositionTests`: positions 1–14 only for compatible frames; never bytes 0/15; nothing for short, long, bad-checksum or non-`0x03` frames; command byte is `0x03`. **PASSED: 20 tests, 0 failures** (CI run [37152212233](https://github.com/dg-dana/signs_of_vital/actions/runs/37152212233), PR head `156b44f`, macos-15, Apple Swift 6.1.2; workflow `M1 Swift Tests`). |
| `sh ios/scripts/check_m0_passive.sh` | M0 remains passive and unchanged. |

The guard was mutation-tested in the agent environment: 13 injected violations (alternative
command, non-zero payload, `Battery:` UI, percent helper, hex in UI/log, pasteboard, extra
`asyncAfter`, send from a write callback, `FEE7` reference, loop, `UserDefaults`) were all
rejected.

## 14. Results

**PARTIALLY EXECUTED (as of 2026-10-22, after O3).** Sanitized format per §10; context, validity
checklist and UNVERIFIED items are in [`M1_1_PROGRESS_HANDOFF.md`](M1_1_PROGRESS_HANDOFF.md).
Observations are **provisional** until the architect accepts them as valid.

| Obs | Date | Vendor reference | Candidate index 1 | Flags |
|---|---|---|---|---|
| O1 | 2026-10-04 | 100% | 100 | **HISTORICAL — not valid for H1** (architect Q5). One write ack'd, one framing-compatible `0x03` response, checksum OK; unsolicited non-`0x03` notification seen (not interpreted); Reference B and other conditions undocumented. Transmission counted. |
| O2 | 2026-10-05 | A = 100%, B = 100% (difference 0) | 100 | **PROVISIONAL — not counted** (architect Q6). One write ack'd, one framing-compatible `0x03` response, checksum OK; additional framing-incompatible, checksum-OK notification ~12 s later (not a second transmission; not decoded; under R2 not itself a duplicate valid response); other validity conditions UNVERIFIED. Transmission counted. |
| O3 | 2026-10-22 | A = 60%, B = 60% (difference 0) | 60 | **PROVISIONALLY SUCCESSFUL — not yet formally VALID** (architect). Transmission 3. One write ack'd; exactly one framing-compatible `0x03` response, checksum OK, within the window (displayed ≤ 9 s); no additional notifications in the log as provided; no retry. V9 MET (written architect GO issued in ChatGPT before O3; not previously recorded in GitHub). V1 (fresh launch, worksheet row), V3 (log completeness, N8), V4, V6 and V7 are UNVERIFIED. |

Reference-only checkpoints: 2026-10-09 vendor app shows 93%; later, before O3, 60% (date not recorded).
**Not observations; no query sent.**

Validity status (architect rulings, 2026-10-22): O1 is **historical, not valid for H1**. O2 is
**provisional and not counted** until its conditions are verified; unknown conditions are not
assumed to have passed. O3 (2026-10-22) is **provisionally successful, not yet formally VALID**;
see the V1–V9 check in [`M1_1_PROGRESS_HANDOFF.md`](M1_1_PROGRESS_HANDOFF.md). All three
transmissions count toward the cap.

| Item | Value |
|---|---|
| Transmissions (of max 8) | **3** (O1, O2, O3); 5 remaining |
| Valid observations counted | **0** (O1 historical; O2 provisional; O3 provisional, not yet VALID; need ≥ 5) |
| Reference spread / distinct levels / upward change / repeat | among counted observations: none. Among all three (not counted): references 100 / 100 / 60; no upward change; no qualifying repeat (§16.5) |
| Per-position classification | not yet recorded |
| Candidate index | index 1 observed = 100 (O1, O2) and 60 (O3); equal to the reference each time. **Not a finding**: no observation is VALID yet and sufficiency is not met |
| Verdict (SUPPORTED / INCONCLUSIVE / REJECTED) | **none yet** — sufficiency not met |

Next: **paused.** The architect rules on O3's open V1–V9 items. **O3r is NOT AUTHORIZED**; it needs
its own readiness check and a new explicit written GO (handoff, "Gate for O3r").

## 15. Architect decisions (design review, approved)

The architect reviewed this design and approved it with these decisions. They are binding for
M1.1; changing any of them needs a new architect decision before further observations.

1. **Private worksheet:** APPROVED exactly as specified in §10 (off-repository; payload bytes
   1–14 only; deleted once the architect accepts the result).
2. **Committed evidence:** APPROVED for the candidate byte's value + the vendor reference per
   observation **only**. All 14 payload values are not committed.
3. **Cross-launch counter / cooldown:** stays **PROCEDURAL** (numbered worksheet rows, 30-minute
   spacing, cap of 8). No persistence is added to the app.
4. **Thresholds:** APPROVED unchanged: ±5 points; reference spread ≥ 40 points; ≥ 5 valid
   observations; ≥ 3 distinct levels; same-state repeat; upward/recharge observation; at most
   8 transmissions.
5. **Vendor-app disconnect:** APPROVED. Turning Bluetooth off on the phone is acceptable, and
   Dana must confirm the vendor app reconnects afterwards (§6 step 4).

XCTest pre-GO condition: **met** (20 tests, 0 failures in CI, §13). Remaining before any
physical execution: the architect's final review and an explicit GO.

## 16. Revision 1 — APPROVED, IN FORCE (2026-10-22, PR #9)

Origin: the protocol review after the O2 anomaly
([`M1_1_PROTOCOL_REVIEW_PROPOSAL.md`](M1_1_PROTOCOL_REVIEW_PROPOSAL.md)) and the architect's
rulings Q1–Q10 of 2026-10-22 (recorded there and in `docs/DECISIONS.md`).

**Approval:** the architect approved Revision 1 as written on 2026-10-22. It was merged in PR #9
(merge commit `c69c024`) and has been in force since then. Approval of the protocol does **not**
authorize any device transmission. O3 still needs a separate readiness check and a new explicit
written GO, and any later observation is taken only under the GO terms the architect sets.

**Unchanged by Revision 1:** H1 (§1). The request, channel, send path and app (§5, §11). The ±5
tolerance (§9). The sufficiency thresholds (§8): ≥ 5 valid observations, reference spread
≥ 40, ≥ 3 distinct levels ≥ 15 apart, ≥ 1 upward change, ≥ 1 same-state repeat. The
**8-transmission lifetime cap** (2 used, **6 remaining, no reset**). The §9 verdict rules, except
the wording of §9.6 (§16.5). The §10 privacy rules, except the added worksheet fields (§16.2 N8).
The §12 abort triggers (clarified in §16.1). No Swift, BLE, persistence, logging, decoder or UI
change.

### 16.1 Clarification of §12 "framing failure" (post-hoc; architect Q1 = R2)

The approved §12 text does not say which notification "a framing failure" refers to. After the
O2 anomaly, the architect ruled:

- the **expected battery response** to our query must satisfy the existing `0x03` framing and
  checksum rules (16 bytes, byte 0 = `0x03`, byte 15 = checksum). If it does not, that is a
  framing failure;
- an **unrelated non-`0x03` notification is not automatically a framing failure**;
- this applies **equally to O1 and O2**: neither observation's extra non-`0x03` notification
  triggers §12;
- **no unknown notification is decoded or assigned meaning.**

This clarification was adopted **after** O1 and O2. It is not presented as having been settled
before O1.

### 16.2 Notification rules (replaces the draft N1–N7 of the review proposal)

Each notification is classified **only** from labels the app already shows, nothing else:

| Class | App labels (summary text) |
|---|---|
| **R** — valid response | length 16, `byte0 = 0x03`, `checksum OK` → "framing COMPATIBLE" |
| **M** — malformed `0x03` | `byte0 = 0x03` **and** (length ≠ 16 **or** `checksum MISMATCH`) |
| **U** — unrelated non-`0x03` | `byte0 ≠ 0x03` (any length, any checksum result) |
| **Z** — unclassifiable | no byte-0 label (length 0), **or** any notification whose labels were not read and recorded before the app was closed |

**Response window:** from the `SENDING` log line to 10 s after it. The app's event log records
**whole seconds only**, so the displayed difference between two log lines is **not** the precise
elapsed time. A displayed difference *d* means a real elapsed time somewhere between *d* − 1 and
*d* + 1 seconds (exclusive). The rule is therefore deliberately **conservative**:

- displayed **≤ 9 s** → the R is accepted as within the window, because the real elapsed time
  must be under 10 s;
- displayed **10 s or more** → **not** shown to be within the window, and treated as late (N2),
  even though the real time may have been under 10 s.

This rule does not measure or prove the exact latency. It only avoids accepting a response that
might have been late. A timely response could be rejected at the boundary; that cost is accepted.

- **N1 — Required:** exactly one R, within the window.
- **N2 — Missing or late:** no R within the window, even if an R arrives later, or U/M/Z arrive →
  the observation **fails** (INVALID, counted) and the §12 trigger "no response within 10 s"
  applies.
- **N3 — Malformed:** any M after the query → §12 abort (framing failure); INVALID.
- **N4 — Duplicate:** more than one R after the query, at any time, whether or not the ANOMALY
  banner shows → §12 abort; INVALID.
- **N5 — Unclassifiable (conservative):** any Z after the query is treated as a framing failure →
  §12 abort; INVALID. If a Z appears **before** the query, do not press Send in that launch: close
  the app (no transmission is spent) and report to the architect. A Z is never assumed harmless.
- **N6 — Unrelated:** a U at any time is not decoded, interpreted, transcribed (beyond the N8
  counts) or acted on. It does not by itself invalidate the observation, and it never stands in
  for the R (N2 still applies).
- **N7 — Other abort triggers, unchanged (§12):** write error or no ATT acknowledgement; any
  pairing prompt; `insufficientAuthentication` / `insufficientEncryption` /
  `insufficientEncryptionKeySize`; unexpected device behavior; vendor app unable to reconnect;
  reaching the cap.
- **N8 — Recording before the app is closed** (added private-worksheet fields; no bytes, no hex,
  no screenshots):
  - the displayed seconds from `SENDING` to the R;
  - the number of R;
  - whether any M or Z occurred;
  - the number of U before the query, within the window and after the window;
  - whether any N7 condition occurred.
  
  The repository receives only yes/no flags and these counts (§10 "validity flags, counts").

Consequence of an abort: unchanged from §12 and §9. Stop, no retry, report to the architect. Under
§9, "any abort (§12) before sufficiency" makes M1.1 INCONCLUSIVE.

### 16.3 Manual 10-second check (app limitation; no code change)

The app's 10-s timer (`BatteryProbeModel.confirmAndSendBatteryQuery`) logs "No notification
received within 10 s" only if **no** notification at all arrived after the query. A U, M or Z
suppresses that line, and the timer never checks the R's timing. **The absence of that line is
not evidence of a timely response.** So after Send, the operator, without closing the app:

1. Finds the `SENDING single battery query …` line in the event log (newest first) and its time.
2. Finds the `NOTIFICATION after query: …` line whose summary says "framing COMPATIBLE", and its
   time.
3. Computes the displayed difference: ≤ 9 s is within the window; anything else is late (N2). This
   is a conservative whole-second check, not a precise latency measurement (§16.2).
4. Classifies every other `NOTIFICATION` line as M, U or Z from its labels (N3, N5, N6).
5. Checks the ANOMALY banner and the count of R (N4).
6. Writes the N8 fields into the private worksheet, then disconnects and closes the app.

### 16.4 Observation validity (architect Q4)

| # | Condition |
|---|---|
| V1 | Exactly one transmission, fresh launch, numbered worksheet row written before Send (§5, §7, §8) |
| V2 | ATT write acknowledged (§7) |
| V3 | N1 met; no N2–N5 condition (§16.2–§16.3) |
| V4 | No N7 condition: no pairing prompt, security error or unexpected device behavior (§12) |
| V5 | Reference A and B within 15 min, \|A − B\| ≤ 5 (§6) |
| V6 | Band off the charger ≥ 15 min (§7) |
| V7 | Vendor app disconnected during the query and reconnected afterwards (§6 steps 2 and 4) |
| V8 | ≥ 30 min since the previous M1.1 query (§7) |
| V9 | Written architect GO existed before the run (§7) |

Outcome per observation: **VALID** (every item verified as passed at the time), **INVALID** (any
item failed), or **UNVERIFIABLE** (any item unknown). **Only VALID observations count toward
sufficiency and H1.** Every transmission counts toward the cap. Unknown or unverifiable conditions
are never assumed to have passed. At verdict time, every observation that is not VALID is
excluded.

Status of the earlier observations (architect Q5, Q6):

- **O1 — HISTORICAL.** Not valid for H1: Reference B and other required conditions are
  undocumented. Kept as historical evidence; its transmission counts.
- **O2 — PROVISIONAL, not counted.** Under R2 its extra notification is not itself a duplicate
  valid response, but V1 and V5–V9 (and the extra notification's exact labels) remain unverified.
  It counts only if those are verified from existing records and the architect accepts it. Dana is
  not asked to reconstruct old events from memory. The plan in §16.6 does not rely on O2.

The N5 rule for Z applies only to observations taken after Revision 1 is approved. The O1/O2
extra notifications are governed by the Q1/Q6 rulings above.

### 16.5 Same-state repeat (explicit change to §8/§9.6; architect Q7)

**Original wording (approved, kept above):** §8 plans O2 as "High, same state as O1", and §9.6
requires "the same-state repeat (O2) differs from O1 by ≤ 2". With O1 not valid, that criterion
cannot be met as worded.

**Revision 1 wording:** the required same-state repeat is any **pair of VALID observations** that:

- are in the same discharge cycle (no charging between them);
- are ≥ 30 min apart;
- have references (A/B means) within ±2 of each other.

§9.6 then reads: "at index `i`, the two values of the same-state pair differ by ≤ 2". If more than
one qualifying pair exists, **every** such pair must satisfy it, so a favorable pair cannot be
picked after the fact. This is a change to a pre-registered criterion, made before any further
observation.

### 16.6 Remaining observation plan (conservative: neither O1 nor O2 counted)

Six transmissions remain (T3–T8). Five must yield VALID observations. One is spare.

| Planned | State (by reference, A/B mean) | Provides |
|---|---|---|
| **O3** | Middle: 45–70 | Level 1 |
| **O3r** | Same discharge cycle as O3, ≥ 30 min later, reference within ±2 of O3 | Same-state repeat (§16.5) |
| **O4** | Low: ≤ 40 **and** ≥ 15 below O3. Not deliberately run below ~20 | Level 2; lower anchor |
| **O5** | After a partial recharge: **≥ O4 + 40 and ≥ O3 + 15** (e.g. O3 = 60, O4 = 30 → O5 ≥ 75). Revised-plan requirement; see the note below | Upward change; spread ≥ 40; level 3 |
| **O6** | Any state, ≥ 30 min after O5 (preferably after some discharge, to add a direction pair) | Fifth valid observation |
| spare | — | Replaces one observation that is INVALID without a §12 abort (for example, a V5 bracket mismatch) |

How this meets each original requirement (§8):

- ≥ 5 valid observations: O3, O3r, O4, O5, O6.
- Spread ≥ 40: from O5 − O4.
- 3 distinct levels pairwise ≥ 15 apart: O4 < O3 < O5.
- Upward change: O4 → O5.
- Same-state repeat: O3/O3r.
- H1, the ±5 tolerance and the 8-transmission cap: unchanged.

**O5 requirement (explicit Revision 1 change, stronger than the original target).**
- The original §8 target for O5 was only "after a partial recharge, ≥ 15 points above O4".
- Revision 1 requires **O5 ≥ O4 + 40 and O5 ≥ O3 + 15**. These are requirements of the **revised
  observation plan**, not new sufficiency thresholds. They follow from the unchanged §8 thresholds
  once O1 and O2 cannot supply the high end:
  - O5 − O4 ≥ 40 gives the reference spread;
  - O5 ≥ O3 + 15 gives a third level ≥ 15 from the others.
- The original O5 condition (≥ 15 above O4) is implied by the stricter one.
- If O5's reference does not meet both requirements, the observation still counts toward the cap.
  Whether sufficiency remains reachable is then decided by the early-stop rule (§16.7).

**Opportunistic, not forced.**
- Every state is reached through the band's **normal use and normal charging** with its own
  charger.
- No forced or accelerated discharge.
- No running the battery below about 20%.
- No unusual, repeated or unsafe charging to hit a number.
- Observations are taken only when the vendor app's reference happens to be in the required range.
- If a state is not reached in normal use (for example, the mid range passes during review, or a
  recharge does not reach O5's level), wait for a later normal cycle.
- If a required state cannot be reached safely, apply §16.7: stop and record INCONCLUSIVE.

Default order only. If the reference is outside 45–70 when a GO is given, wait for the next
discharge through the middle range (recharging normally). Any reordering needs an architect
decision.

### 16.7 Early stop (architect Q8)

Before every transmission and after every observation, count the VALID observations still
required by §16.6 to meet **all** sufficiency conditions. If that number exceeds the remaining
transmissions, or a required state cannot be reached without stressing the band or going below
~20%, **stop and record INCONCLUSIVE**. Do not send further queries. With one spare, a second
non-VALID observation among T3–T8 triggers this. Any §12 abort also stops the experiment
(§16.2).

### 16.8 If the evidence remains insufficient

The verdict is **INCONCLUSIVE** (§8, §9). There is no extension and no budget reset. Sanitized
results are recorded (§10). Battery semantics stay **NOT proven**. Any pattern seen is recorded
only as a new hypothesis. Any further attempt is a new, separately pre-registered experiment with
its own architect GO. M2 is not authorized by any M1.1 outcome.

### 16.9 Implementation (architect Q9)

No Swift app changes. The known limitations are handled procedurally:

| Limitation | Procedure |
|---|---|
| Nothing is persisted | N8 |
| The 10-s timer is not response-specific | §16.3 |
| The ANOMALY banner does not flag M or Z | §16.3 step 4 |
| "After query" is not window-based | §16.3 step 3 |

The verification guards and tests (§13) are retained unchanged.
