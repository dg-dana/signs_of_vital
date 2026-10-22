# TODO

## Next — M1.1 PAUSED (Revision 1 approved and in force; O3 NOT AUTHORIZED)

- [ ] Architect: review the docs-only status follow-up PR (`claude/m1-1-rev1-status`). Do not merge
  without approval.
- [ ] O3 readiness check, then a **new explicit written GO** from the architect. Revision 1 approval
  (PR #9) is not a GO. Readiness means a middle-state reference (45–70%; last reported 60%, date not
  recorded) and every §6–§7 / V1–V9 precondition verified. 2 of 8 transmissions used; 0 valid
  counted. Context: `docs/protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md` §16.
- [ ] After O3 only, and only under the GO terms the architect sets: O3r, O4, O5, O6 per experiment §16.6 (1 spare; early stop
  §16.7). Record sanitized results in §14.
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
