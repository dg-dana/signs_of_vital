# M1.1 — Battery Payload Semantics Experiment

Status: **DESIGN / PREPARATION ONLY — NOT EXECUTED.** Physical execution requires a
**separate explicit architect GO** after this design has been reviewed. Until then, no `0x03`
(or any other) transmission is authorized.

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
4. Turn the phone's Bluetooth back on, let the vendor app reconnect and refresh, then read
   **Reference B**.

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
  *(Requires architect confirmation: §15 Q1.)*
- **Committed results (sanitized):** the per-position classification (§4); for the
  candidate index only, the per-observation reference vs candidate value; validity flags;
  counts; and the verdict. No other byte values. *(Requires architect confirmation: §15 Q2.)*

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
  forbids. It is not added (§15 Q3).

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

## 13. Device-free verification

| Check | What it covers |
|---|---|
| `sh ios/scripts/check_m1_gate.sh` | Exactly one `writeValue` (fixed request, write characteristic, inside `confirmAndSendBatteryQuery`, single caller = confirmation button); gate + latch wired; single user-initiated `connect`; no prohibited APIs/channels (`FEE7`, `DE5BF72x`, reads, descriptors, persistence, timers). **M1.1 additions:** exactly one frame build, `Frame16.build(command: commandByte)` with no payload, and `commandByte` = `0x03`; no alternative command byte; at most one `asyncAfter` and no loops/other schedulers; no battery decoder or "Battery:"/percent UI; notification bytes never in the event log; no hex rendered in the UI; no copy/share/export APIs. |
| `python3 ios/scripts/check_m1_vectors.py` | Request/checksum vectors, plus the payload-position rule (bytes 1–14 only). |
| `swift test --package-path ios/SignsOfVital-M1Tests` | Existing frame/gate tests plus `PayloadPositionTests`: positions 1–14 only for compatible frames; never bytes 0/15; nothing for short, long, bad-checksum or non-`0x03` frames; command byte is `0x03`. **Not run by agents (no Swift toolchain); must be run before GO.** |
| `sh ios/scripts/check_m0_passive.sh` | M0 remains passive and unchanged. |

The guard was mutation-tested in the agent environment: 13 injected violations (alternative
command, non-zero payload, `Battery:` UI, percent helper, hex in UI/log, pasteboard, extra
`asyncAfter`, send from a write callback, `FEE7` reference, loop, `UserDefaults`) were all
rejected.

## 14. Results

**NOT EXECUTED.** No M1.1 transmission has taken place. This section is filled in only after
an architect GO and execution, using the sanitized format in §10.

| Item | Value |
|---|---|
| Transmissions (of max 8) | — |
| Valid observations | — |
| Reference spread / distinct levels / upward change / repeat | — |
| Per-position classification | — |
| Candidate index | — |
| Verdict (SUPPORTED / INCONCLUSIVE / REJECTED) | — |

## 15. Open questions for the architect (before GO)

1. **Private worksheet:** approve keeping per-observation payload values (bytes 1–14) in an
   off-repository private worksheet until the result is accepted? Without it, multi-session
   comparison is impossible.
2. **Committed evidence:** may the candidate byte's per-observation values (next to the
   reference) be committed as sanitized results? A battery value is not an identifier or
   health data. The alternative is committing only the verdict and aggregate deviations,
   which is weaker evidence for later reviewers.
3. **Cross-launch counter/cooldown:** keep the cap and spacing procedural (current design),
   or authorize a persisted, non-BLE send counter? That would relax the "no persistence"
   guard.
4. **Thresholds:** confirm ±5 tolerance, ≥ 40-point spread, 5 valid observations and the cap
   of 8 transmissions.
5. **Vendor app disconnect:** is turning off Bluetooth on the phone acceptable, given the
   vendor app's own behavior on reconnect is outside our control?
