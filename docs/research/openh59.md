# Research: OpenH59

Upstream: <https://github.com/LudovicoPiccolo/OpenH59>
Last reviewed: 2026-09-28 (README, `band.py`, `docs/APPUNTI-TECNICI.md` read on GitHub).

Labels used below:

- **FACT** — directly stated in the upstream repository.
- **INFERENCE** — our reasoning; plausible but unproven.
- **UNKNOWN** — not established.

## License and usage rule

- **FACT:** No LICENSE file and no license in the repository sidebar (as of last review).
- **INFERENCE:** Without a license, default copyright applies; we have no right to reuse its code.
- **RULE (ADR-003):** OpenH59 is research/reference only. Do **not** copy, translate,
  or port its source into Signs of Vital. We implement the protocol independently
  from our own understanding and our own device observations.

## Upstream project

- **FACT:** Python project using `bleak` for BLE (`band.py`, `collect.py`, `store.py`, etc.)
  plus a PHP web dashboard (`index.php`).
- **FACT:** README describes the band as compatible with the Colmi / QWatch Pro protocol.
- **FACT:** Reference hardware `H59_V2.0`, firmware `H59_2.00.14_…` (from `docs/APPUNTI-TECNICI.md`).

## BLE architecture (per upstream)

- **FACT:** UART-style channel: service `6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E`,
  RX/write `6E400002-…`, TX/notify `6E400003-…`.
- **FACT:** Second proprietary "bc" / "rich" channel: write `DE5BF72A-D711-4E47-AF26-65E3012A5DC7`,
  notify `DE5BF729-D711-4E47-AF26-65E3012A5DC7`.
- **UNKNOWN:** Parent service UUID of the `DE5BF72x` characteristics.

See [`docs/protocol/GATT_MAP.md`](../protocol/GATT_MAP.md) section C.

## Command framing (UART channel)

- **FACT:** Fixed 16-byte frames: command byte, payload, final checksum byte.
- **FACT:** Checksum = sum of the preceding 15 bytes, truncated to 8 bits.
- **FACT:** Commands referenced upstream:

| Byte | Purpose (per upstream) |
|---|---|
| `0x01` | Set device time |
| `0x03` | Battery level |
| `0x0D` | Sleep history |
| `0x15` | Heart-rate history |
| `0x16` | 24/7 HR logging on/off (settings) |
| `0x37` | Stress history |
| `0x39` | HRV history |
| `0x43` | Steps / calories / distance |
| `0x69` / `0x6A` | Start / stop realtime measurement |

> None of these are authorized to be sent. M0 sends no commands. M1 (battery `0x03`) is not yet authorized.

## Second "bc" channel

- **FACT:** Variable-length frames: magic `0xBC`, type byte, 2-byte little-endian
  length, 2-byte CRC-16 (Modbus), body. Responses can span multiple notifications.
- **FACT:** Requires authentication: a login frame containing the user's QWatch
  account credentials, then an init frame, before data requests.
- **FACT:** Carries SpO2 hourly history and staged sleep data.
- **RULE:** We do not authenticate to this channel. Never commit QWatch/Bionny credentials.

## Known feature support (per upstream, on H59_V2.0)

HR (interval + realtime), HRV, stress, steps/calories/distance, SpO2 history,
staged sleep, on-demand blood pressure. **UNKNOWN** which of these H59B supports.

## Compatibility evidence for our H59B

- **FACT:** Our hardware string `H59B_V1.0` and firmware `H59B_1.00.00_260402` share the `H59` family prefix.
- **FACT (manual observation, unverified UUIDs):** Our device exposes a UART-style
  service and a proprietary service resembling `DE5BF72x`.
- **INFERENCE:** Protocol compatibility is strongly suggested.
- **UNKNOWN:** Whether UUIDs, framing, checksum, and command set actually match.
  Not proven until M0 (GATT) and M1 (one command) evidence exists.

## Differences from our device

| | OpenH59 reference | Ours |
|---|---|---|
| Hardware | `H59_V2.0` | `H59B_V1.0` |
| Firmware | `H59_2.00.14_…` | `H59B_1.00.00_260402` |
| Variant | H59 | H59**B** (meaning of suffix UNKNOWN) |
| Platform | Python + bleak (desktop) | Swift + CoreBluetooth (iPhone) |
