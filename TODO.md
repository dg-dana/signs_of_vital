# TODO

## Next — M1.1 PAUSED (O3 + O3r VALID; awaiting O4 readiness assessment; O4 NOT AUTHORIZED)

- [ ] Architect: review the docs-only O3r acceptance PR (`claude/o3r-acceptance-docs-jy0iq5`). Do
  not merge without approval.
- [ ] O4 readiness assessment (operator): vendor Reference A of 40% or lower (≥ 15 points below
  O3's 60), reached through normal use without discharging below ~20%; ≥ 30 min after O3r; all
  §6–§7 / V1–V9 conditions. Then request a **new written architect GO specifically for O4**. Not
  authorized now; no BLE command. If the range cannot be reached safely, escalate to the architect
  (§16.6–§16.7). 4 of 8 transmissions used (4 remaining); 2 of 5 valid counted (O3, O3r);
  same-state repeat satisfied. H1 NOT YET PROVEN.
- [ ] After O4 only, and only under the GO terms the architect sets: O5, O6 per experiment §16.6
  (early stop §16.7). Record sanitized results in §14.
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
