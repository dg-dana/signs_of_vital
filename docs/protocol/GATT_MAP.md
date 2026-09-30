# GATT Map — Bionny 4.0 (H59B)

Status of every known BLE service/characteristic for our device, separated by
**evidence level**. Only section A may be treated as fact about our hardware.

Rules for editing this file:

- Promote a **UUID** to **A. CONFIRMED** only when it was captured directly by our
  own CoreBluetooth probe (`uuid.uuidString` copied from probe output, not typed
  from memory or a screenshot).
- Never "fix" a section B entry to match OpenH59. If they differ, record both.
- Never record the device serial number (2A25), System ID (2A23) value, iOS peripheral
  identifier, manufacturer data, or any other per-device identifier here.

---

## A. CONFIRMED ON BIONNY H59B

Directly observed on our device by the M0 passive CoreBluetooth probe, physical
run on iPad, **2026-09-30** (details: [`M0_PROBE.md`](M0_PROBE.md)). The probe
confirmed **4 services**. UUIDs and properties were copied from the probe's
"Copy GATT map" output (UUIDs + properties only; no values, identifiers or
manufacturer data).

### A.1 Product facts and revision strings

| Item | Value | Source |
|---|---|---|
| Physical product | Bionny 4.0 | Device in hand |
| Connectable over BLE | Yes | nRF Connect (iPhone); M0 probe connected successfully |
| Hardware Revision String (0x2A27) | `H59B_V1.0` | nRF Connect, then independently re-confirmed by M0 CoreBluetooth read |
| Firmware Revision String (0x2A26) | `H59B_1.00.00_260402` | nRF Connect, then independently re-confirmed by M0 CoreBluetooth read |

### A.2 GATT topology (UUIDs + properties only)

```text
M0 probe GATT capture (UUIDs + properties only)

SERVICE 6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E
  CHAR 6E400002-B5A3-F393-E0A9-E50E24DCCA9E  writeWithoutResponse write (0x0C)
  CHAR 6E400003-B5A3-F393-E0A9-E50E24DCCA9E  notify (0x10)

SERVICE DE5BF728-D711-4E47-AF26-65E3012A5DC7
  CHAR DE5BF72A-D711-4E47-AF26-65E3012A5DC7  writeWithoutResponse write (0x0C)
  CHAR DE5BF729-D711-4E47-AF26-65E3012A5DC7  notify (0x10)

SERVICE 180A
  CHAR 2A25  read (0x02)
  CHAR 2A27  read (0x02)
  CHAR 2A26  read (0x02)
  CHAR 2A23  read (0x02)

SERVICE FEE7
  CHAR FEA1  read notify (0x12)
  CHAR FEC9  read (0x02)
  CHAR FEA2  read write indicate (0x2A)
```

Directly observed facts derived from the capture:

- UART-style service is `6E40FFF0-…` (not the Nordic default `…0001`), with
  `6E400002-…` (writeWithoutResponse + write) and `6E400003-…` (notify).
- The previously unknown parent service of the `DE5BF72x` characteristics is
  **`DE5BF728-D711-4E47-AF26-65E3012A5DC7`**, containing `DE5BF72A-…`
  (writeWithoutResponse + write) and `DE5BF729-…` (notify). No other `DE5BF72x`
  characteristics were listed.
- Device Information (`180A`) exposes `2A25`, `2A27`, `2A26`, `2A23`, all read-only.
  (Only the hardware/firmware strings are recorded; `2A25` and `2A23` values are
  per-device identifiers and are deliberately not recorded.)
- Service `FEE7` is present with `FEA1`, `FEC9`, `FEA2`. It is **not** described in
  the OpenH59 notes reviewed ([section C](#c-reference-from-openh59)).

Other observed behavior (this device/firmware, 2026-09-30):

- `FEA1` notification subscription succeeded.
- `FEA2` indication subscription succeeded.
- Reading `FEC9` returned `The attribute could not be found.` This is an
  observation from this device/firmware only; it is **not** proof that `FEC9` is
  universally unreadable.

**A characteristic being writable does NOT authorize writing to it.** Properties
tell us what the GATT table permits, not what any characteristic means or what is
safe to send. The UUID/property map alone does not establish protocol semantics.

## B. MANUALLY OBSERVED / TRANSCRIPTION NOT YET VERIFIED

**Resolved (2026-09-30).** These nRF Connect observations were superseded by the
M0 probe capture in section A:

| Earlier observation | Resolution |
|---|---|
| Standard Device Information service (0x180A) present | Confirmed (A.2) |
| A UART-style service with a write and a notify characteristic | Confirmed: `6E40FFF0-…` / `6E400002-…` / `6E400003-…` (A.2) |
| A proprietary service resembling the OpenH59 `DE5BF72x` channel | Confirmed: parent `DE5BF728-…`, chars `DE5BF72A-…` / `DE5BF729-…` (A.2) |

The hand-transcribed UUIDs were never committed and are no longer relevant. Nothing
is currently pending in this section.

## C. REFERENCE FROM OPENH59

From [OpenH59](https://github.com/LudovicoPiccolo/OpenH59) (reference device
`H59_V2.0`, firmware `H59_2.00.14_…`). Reference only — **not evidence about our device**. The UUIDs below match what the M0
probe observed on our device (section A); that matches structure only, not protocol behavior.

| Role (per OpenH59) | UUID as written upstream | Notes |
|---|---|---|
| UART service | `6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E` | Stated in upstream technical notes; note it is `…FFF0`, not the Nordic default `6E400001` |
| UART RX (write) | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | 16-byte command frames |
| UART TX (notify) | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | Responses |
| "bc" channel write | `DE5BF72A-D711-4E47-AF26-65E3012A5DC7` | Requires login (see research doc) |
| "bc" channel notify | `DE5BF729-D711-4E47-AF26-65E3012A5DC7` | Multi-frame responses |
| "bc" parent service | Not identified in upstream sources reviewed | Unknown upstream; our device shows `DE5BF728-D711-4E47-AF26-65E3012A5DC7` (section A.2) |

Details: [`docs/research/openh59.md`](../research/openh59.md).

## D. NOT YET VERIFIED / UNKNOWN

Answered by the M0 probe (see section A): full service list (4 services), full
characteristic list with properties, UART service UUID, RX/TX UUIDs, parent
service of `DE5BF72x`, and which Device Information characteristics are present.

Still unknown (hypotheses, not facts):

- Semantics of every characteristic, including all of `FEE7` (`FEA1`, `FEC9`,
  `FEA2`). Nothing is inferred from UUID/properties.
- Whether H59B speaks the OpenH59 (H59_V2.0) command protocol: strongly suggested by
  matching UUIDs, **not proven**. The measurement protocol is **not decoded**.
- Whether the `DE5BF72x` channel requires login/authentication on H59B.
- Whether any characteristic requires pairing/encryption (no pairing prompt was
  reported with the M0 results; not otherwise verified).
- Why `FEC9` read returned `The attribute could not be found.` despite advertising READ.
- Whether any characteristic emits spontaneous notifications after subscription
  (no payloads recorded; raw values are not committed).
- Advertised name, advertised service UUIDs, manufacturer data format (manufacturer
  data is never committed).
