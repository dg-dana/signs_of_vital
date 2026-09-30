# TODO

## Next — architect review (current)

- [ ] Architect: final review of the M1 preparation PR (`docs/protocol/M1_BATTERY_EXPERIMENT.md`,
  `ios/SignsOfVital-M1.swiftpm/`) and explicit GO/NO-GO for the physical run. Dana must not run it before GO.
- [ ] Run `swift test --package-path ios/SignsOfVital-M1Tests` on a Mac/Linux Swift toolchain
  (not runnable in the agent environment) and confirm the M1 app compiles on the iPad.
- [ ] Open question: `FEE7` service (`FEA1`/`FEC9`/`FEA2`) is not covered by OpenH59 notes; decide
  whether it needs research. Do not write to it.

## M1 — Battery command proof (PREPARED, NOT YET AUTHORIZED)

- [ ] Physical run: one gated battery `0x03` query on `6E400002`/`6E400003`; record only the
  summarized outcome (never raw bytes). Blocked on architect GO.

## M2 — Minimal protocol layer (NOT YET AUTHORIZED)

- [ ] Extend the independent Swift frame encode/decode + checksum with tests beyond the M1 battery frame.

## M3 — Selected sensor/history decoding (NOT YET AUTHORIZED)

- [ ] Pick 1–2 metrics (e.g. HR history) and decode on H59B.

## M4 — Minimal usable iOS interface (NOT YET AUTHORIZED)

- [ ] Simple screen showing decoded values, labeled non-medical.

## Later (NOT YET AUTHORIZED)

- [ ] Local storage, Apple Health integration, broader product work.
