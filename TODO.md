# TODO

## Next — M1.1 PAUSED after O3 (O3r NOT AUTHORIZED)

- [ ] Architect: review the docs-only O3 record PR (`claude/m1-1-o3-results`) and rule on O3's
  validity. UNVERIFIED V1–V9 items are listed in `docs/protocol/M1_1_PROGRESS_HANDOFF.md` ("O3
  validity"). Do not merge without approval.
- [ ] O3r: readiness check (same discharge cycle as O3, ≥ 30 min after it, reference within ±2 of
  60, all §6–§7 / V1–V9 preconditions), then a **new explicit written GO**. Not authorized now. If
  the band is charged or leaves 58–62 first, the architect decides how the repeat is replanned
  (§16.6). 3 of 8 transmissions used; 0 valid counted.
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
