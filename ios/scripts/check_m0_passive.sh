#!/bin/sh
# Static guard for the M0 passive-only rule (ADR-002, ADR-004, docs/protocol/M0_PROBE.md).
# Fails if any Swift file in the M0 project uses an API that could send data to the
# peripheral, connect without a user tap, or persist BLE output.
# Usage: sh ios/scripts/check_m0_passive.sh   (from the repository root)

set -u
dir="ios/SignsOfVital-M0.swiftpm"
forbidden='writeValue|openL2CAPChannel|discoverDescriptors|retrievePeripherals|retrieveConnectedPeripherals|RestoreIdentifierKey|registerForConnectionEvents|setNotifyValue\(false|FileManager|UserDefaults|\.write\(to:|FileHandle'

if grep -rnE "$forbidden" "$dir" --include='*.swift'; then
    echo "FAIL: forbidden API found in $dir (see lines above)"
    exit 1
fi

# The only connect call must be the user-initiated one in ProbeModel.connect(_:).
count=$(grep -rn 'central\.connect(' "$dir" --include='*.swift' | wc -l)
if [ "$count" -ne 1 ]; then
    echo "FAIL: expected exactly one central.connect( call, found $count"
    exit 1
fi

echo "OK: no forbidden APIs in $dir; single user-initiated connect call"
