# GATT Map — Bionny 4.0 (H59B)

Status of every known BLE service/characteristic for our device, separated by
**evidence level**. Only section A may be treated as fact about our hardware.

Rules for editing this file:

- Promote a **UUID** to **A. CONFIRMED** only when it was captured directly by our
  own CoreBluetooth probe (`uuid.uuidString` copied from probe output, not typed
  from memory or a screenshot).
- Never "fix" a section B entry to match OpenH59. If they differ, record both.
- Never record the device serial number (2A25) or any per-device identifier here.

---

## A. CONFIRMED ON BIONNY H59B

Directly observed on our device. Currently only product facts and the two
revision strings Dana read from the standard Device Information service in
nRF Connect (accepted as confirmed by the architect; no UUIDs):

| Item | Value | Source |
|---|---|---|
| Physical product | Bionny 4.0 | Device in hand |
| Connectable over BLE | Yes | nRF Connect (iPhone) |
| Hardware Revision String (0x2A27) | `H59B_V1.0` | nRF Connect, Device Information (0x180A) |
| Firmware Revision String (0x2A26) | `H59B_1.00.00_260402` | nRF Connect, Device Information (0x180A) |

No proprietary service or characteristic UUID is confirmed yet. The M0
CoreBluetooth probe must independently re-confirm the two revision strings above.

## B. MANUALLY OBSERVED / TRANSCRIPTION NOT YET VERIFIED

Dana observed these in nRF Connect; exact UUIDs were transcribed by hand and are
**provisional**.

| Observation | Status |
|---|---|
| Standard Device Information service (0x180A) present | Observed |
| A UART-style service with a write and a notify characteristic | Observed; exact UUIDs provisional |
| A proprietary service resembling the OpenH59 `DE5BF72x` channel | Observed; exact UUIDs provisional |

> TODO(M0): paste the exact provisional UUID transcriptions here if still
> available, labeled as transcriptions, then replace with probe output.

## C. REFERENCE FROM OPENH59

From [OpenH59](https://github.com/LudovicoPiccolo/OpenH59) (reference device
`H59_V2.0`, firmware `H59_2.00.14_…`). Reference only — **not evidence about our device**.

| Role (per OpenH59) | UUID as written upstream | Notes |
|---|---|---|
| UART service | `6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E` | Stated in upstream technical notes; note it is `…FFF0`, not the Nordic default `6E400001` |
| UART RX (write) | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` | 16-byte command frames |
| UART TX (notify) | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` | Responses |
| "bc" channel write | `DE5BF72A-D711-4E47-AF26-65E3012A5DC7` | Requires login (see research doc) |
| "bc" channel notify | `DE5BF729-D711-4E47-AF26-65E3012A5DC7` | Multi-frame responses |
| "bc" parent service | Not identified in upstream sources reviewed | Unknown |

Details: [`docs/research/openh59.md`](../research/openh59.md).

## D. NOT YET VERIFIED

Open questions that the M0 probe should answer:

- Full list of services on H59B (`discoverServices(nil)`).
- Full list of characteristics per service, with properties
  (read / write / writeWithoutResponse / notify / indicate, raw bitmask).
- Whether the UART service UUID is `6E40FFF0-…`, `6E400001-…`, or something else.
- Whether RX/TX are `6E400002-…` / `6E400003-…` on H59B.
- Parent service UUID of the `DE5BF72x` characteristics, and whether additional
  `DE5BF72x` characteristics exist.
- Which Device Information characteristics are present (manufacturer, model,
  hardware, firmware, software revision, serial — serial is displayed only, never recorded).
- Advertised name, advertised service UUIDs, manufacturer data format.
- Whether any characteristic emits notifications spontaneously after subscription
  (without any command being sent).
