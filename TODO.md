# TODO

## M0 — Passive BLE/GATT discovery (current)

- [ ] Architect: review M0 probe PR #2 (branch `claude/m0-swift-playground-probe`) for passive-only BLE behavior.
  Do not run against the Bionny before approval.
- [ ] Dana: pull `main` in Working Copy, open `ios/SignsOfVital-M0.swiftpm` in Swift Playgrounds, confirm it compiles/runs.
- [ ] Run probe on the iPad against the Bionny (cancel + log any pairing prompt); paste "Copy GATT map" output into `GATT_MAP.md` section A; re-confirm HW/FW strings.

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
