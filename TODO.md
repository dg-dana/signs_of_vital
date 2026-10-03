# TODO

## Next — M1.1 architect review (current)

- [ ] Architect: review the M1.1 design PR (`claude/m1-1-battery-semantics`,
  `docs/protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md`) and answer its §15 questions.
  M1.1 is NOT executed; no device command is authorized until a separate explicit GO.
- [ ] Run `swift test --package-path ios/SignsOfVital-M1Tests` on a Mac/Linux Swift toolchain
  before any M1.1 GO (not runnable in the agent environment).
- [ ] After GO only: execute M1.1 per its §7–§8, then record sanitized results in its §14.
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
