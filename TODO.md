# TODO

## Next — M1.1 PAUSED (pending architect review)

- [ ] Architect: review the protocol-review PR (`claude/m1-1-protocol-review`) and answer Q1–Q10 in
  `docs/protocol/M1_1_PROTOCOL_REVIEW_PROPOSAL.md` §11 (§12 reading, continuation option, notification
  and validity rules, O1/O2 validity). Do not merge without approval.
- [ ] Dana (only if the architect asks): give yes / no / don't know for the O1/O2 items marked
  UNVERIFIED in `docs/protocol/M1_1_PROGRESS_HANDOFF.md`, and whether the O2 extra notification's
  labels were exactly "checksum OK" / "framing NOT compatible". No worksheet contents, no screenshots.
- [ ] After the architect's rulings: update the experiment doc (Revision 1, or close as INCONCLUSIVE
  and pre-register a continuation, per the chosen option).
- [ ] O3 only after those rulings, the §6–§7 preconditions, a middle-state reference (45–70%; last
  reported 60%, date not recorded) and a **new explicit written GO**. 2 of 8 transmissions used.
- [ ] After O3 GO only: O4 (low), O5 (after partial recharge) per experiment §8; record sanitized
  results in its §14.
- [ ] Open question (unsolicited UART notifications with a different command/type byte): decide
  whether/when to study them. Do not decode or act on them until authorized.
- [ ] Open question: `FEE7` service (`FEA1`/`FEC9`/`FEA2`) is not covered by OpenH59 notes; decide
  whether it needs research. Do not write to it.

## M2 — Minimal protocol layer (NOT YET AUTHORIZED)

- [ ] Extend the independent Swift frame encode/decode + checksum with tests beyond the M1 battery frame.

## M3 — Selected sensor/history decoding (NOT YET AUTHORIZED)

- [ ] Pick 1–2 metrics (e.g. HR history) and decode on H59B.

## M4 — Minimal usable iOS interface (NOT YET AUTHORIZED)

- [ ] Simple screen showing decoded values, labeled non-medical.

## Later (NOT YET AUTHORIZED)

- [ ] Local storage, Apple Health integration, broader product work.
