# TODO

## Next — architect review (current)

- [ ] Architect: review the M0 results PR and decide whether/how to scope M1. No BLE protocol work until then.
- [ ] Open question for review: `FEE7` service (`FEA1`/`FEC9`/`FEA2`) is not covered by OpenH59 notes; decide whether it needs research before any M1 design. Do not write to it.

## M1 — Battery command proof (NOT YET AUTHORIZED)

- [ ] Send battery `0x03` only; verify response framing against our own understanding.
  Requires explicit architect authorization; M0 shows the GATT topology only.

## M2 — Minimal protocol layer (NOT YET AUTHORIZED)

- [ ] Independent Swift frame encode/decode + checksum, with unit tests.

## M3 — Selected sensor/history decoding (NOT YET AUTHORIZED)

- [ ] Pick 1–2 metrics (e.g. HR history) and decode on H59B.

## M4 — Minimal usable iOS interface (NOT YET AUTHORIZED)

- [ ] Simple screen showing decoded values, labeled non-medical.

## Later (NOT YET AUTHORIZED)

- [ ] Local storage, Apple Health integration, broader product work.
