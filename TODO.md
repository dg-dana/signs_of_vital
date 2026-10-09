# TODO

## Next — M1.1 O3 (current)

- [ ] Wait for the vendor app to show a middle-state battery level (roughly 45–70%; 93% on
  2026-10-09). Then verify all preconditions (experiment §6–§7), get the architect's ruling on the O2
  extra-notification question, and obtain a **new explicit architect GO** before O3. Until then no
  query is authorized. 2 of 8 transmissions used; context: `docs/protocol/M1_1_PROGRESS_HANDOFF.md`.
- [ ] Architect: review the handoff PR and decide whether O1/O2 are accepted as valid (several
  conditions are UNVERIFIED in the handoff doc).
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
