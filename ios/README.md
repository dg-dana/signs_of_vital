# iOS — M0 passive probe

`SignsOfVital-M0.swiftpm/` is a Swift Playgrounds app project (SwiftUI + CoreBluetooth)
implementing [`docs/protocol/M0_PROBE.md`](../docs/protocol/M0_PROBE.md). Passive only.

Architect-approved passive-only boundary (PR #2). Any change that adds BLE behavior
needs a new architect review before it runs against the Bionny.

## Open on the iPad

1. Working Copy → `signs_of_vital` → Pull (so `main` has the latest version).
2. Swift Playgrounds → Locations / Browse → Working Copy →
   `signs_of_vital/ios/SignsOfVital-M0.swiftpm` → open.
3. Run (▶). Allow Bluetooth when iOS asks.

If Swift Playgrounds cannot open the project in place from Working Copy, report it
rather than copying code by hand; GitHub stays the single source of truth.

## Using it

1. **Start unfiltered scan**, find the Bionny, tap its row (nothing connects automatically).
2. The app discovers all services/characteristics, reads `read` characteristics once,
   and subscribes to `notify`/`indicate` characteristics. Values are shown as hex.
3. **Pairing prompt from iOS → tap Cancel**, then tap **Log pairing prompt**.
4. **Copy GATT map** copies UUIDs + properties only (no values) for `GATT_MAP.md`.

Nothing is saved to disk. Values may include the serial number or health data —
never commit them or keep screenshots of them.

## Passive-only check

```sh
sh ios/scripts/check_m0_passive.sh
```

Fails on any write/descriptor/L2CAP/identifier-retrieval/state-restoration/file API,
or if there is not exactly one (user-initiated) `connect` call.

## M1 battery query (prepared — NOT AUTHORIZED TO RUN)

`SignsOfVital-M1.swiftpm/` can send one gated battery query; see
[`docs/protocol/M1_BATTERY_EXPERIMENT.md`](../docs/protocol/M1_BATTERY_EXPERIMENT.md).
**Do not run it against the Bionny until the architect gives an explicit GO.**

```sh
sh ios/scripts/check_m1_gate.sh        # static guard: one gated write, nothing else
python3 ios/scripts/check_m1_vectors.py  # device-free vector cross-check
swift test --package-path ios/SignsOfVital-M1Tests  # needs a Swift toolchain
```
