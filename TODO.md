# TODO

## Next — architect review (current)

- [ ] Architect: review/merge PR #5 (M1 app, design and 2026-10-03 results) and decide the next
  milestone. No further device commands until then.
- [ ] Architect decision: whether to design a separate experiment to establish battery payload
  semantics (meaning/scale currently UNKNOWN; no decoder or "Battery %" UI).
- [ ] Run `swift test --package-path ios/SignsOfVital-M1Tests` on a Mac/Linux Swift toolchain
  (not runnable in the agent environment).
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
