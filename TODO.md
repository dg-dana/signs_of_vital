# TODO

## M0 — Passive BLE/GATT discovery (current)

- [ ] Architect: choose Apple build/deploy path (Mac + Xcode / other Apple env / cloud macOS + TestFlight).
  Blocks everything below. See `docs/CURRENT_STATE.md`.
- [ ] Record Dana's provisional UUID transcriptions in `docs/protocol/GATT_MAP.md` section B (labeled provisional).
- [ ] Implement minimal passive probe per `docs/protocol/M0_PROBE.md` (only once a build path is verified).
- [ ] Run probe on Dana's iPhone; promote captured UUIDs to CONFIRMED in `GATT_MAP.md`; re-confirm HW/FW strings.

## M1 — Battery command proof (NOT YET AUTHORIZED)

- [ ] Send battery `0x03` only; verify response framing against our own understanding.

## M2 — Minimal protocol layer (NOT YET AUTHORIZED)

- [ ] Independent Swift frame encode/decode + checksum, with unit tests.

## M3 — Selected sensor/history decoding (NOT YET AUTHORIZED)

- [ ] Pick 1–2 metrics (e.g. HR history) and decode on H59B.

## M4 — Minimal usable iOS interface (NOT YET AUTHORIZED)

- [ ] Simple screen showing decoded values, labeled non-medical.

## Later (NOT YET AUTHORIZED)

- [ ] Local storage, Apple Health integration, broader product work.
