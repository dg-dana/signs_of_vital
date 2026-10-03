# TODO

## Next — M1.1 final review / GO (current)

- [ ] Architect: final review of PR #7 (`claude/m1-1-battery-semantics`; design review already
  APPROVED, decisions in `docs/protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md` §15) and explicit
  GO. XCTest passes in CI (`.github/workflows/m1-swift-tests.yml`). Physical execution NOT
  AUTHORIZED until then; no device command is authorized.
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
