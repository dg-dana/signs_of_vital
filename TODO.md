# TODO

## Next — M1.1 PAUSED (O3 VALID; awaiting O3r readiness assessment; O3r NOT AUTHORIZED)

- [ ] O3r readiness assessment (operator): no charging since O3 (same discharge cycle), ≥ 30 min
  after O3, fresh vendor Reference A within 58–62%, all §6–§7 / V1–V9 conditions. Then request a
  **new written architect GO specifically for O3r**. Not authorized now; no BLE command. If the band
  was charged or Reference A is outside 58–62%, do not proceed: escalate to the architect for a
  planning decision (§16.6). 3 of 8 transmissions used; 1 of 5 valid counted (O3).
- [ ] After O3r only, and only under the GO terms the architect sets: O4, O5, O6 per experiment
  §16.6 (early stop §16.7). Record sanitized results in §14.
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
