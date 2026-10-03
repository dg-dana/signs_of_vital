#!/bin/sh
# Static safety guard for the M1 single-battery-query app (docs/protocol/M1_BATTERY_EXPERIMENT.md,
# reused unchanged on the send path for M1.1: docs/protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md).
# Fails if the project could transmit anywhere other than the one gated write, connect without a
# tap, retry, touch other services/channels, use descriptors, or persist BLE output.
# Usage: sh ios/scripts/check_m1_gate.sh   (from the repository root)

set -u
dir="ios/SignsOfVital-M1.swiftpm"
model="$dir/BatteryProbeModel.swift"
fail=0
bad() { echo "FAIL: $1"; fail=1; }

# 1. APIs that are never allowed in M1.
forbidden='openL2CAPChannel|discoverDescriptors|retrievePeripherals|retrieveConnectedPeripherals|RestoreIdentifierKey|registerForConnectionEvents|setNotifyValue\(false|readValue|FileManager|UserDefaults|\.write\(to:|FileHandle|discoverServices\(nil|discoverCharacteristics\(nil|Timer\.|scheduledTimer|CADisplayLink'
if grep -rnE "$forbidden" "$dir" --include='*.swift'; then bad "forbidden API found"; fi

# 2. Untouchable channels must not appear in Swift code at all (FEE7 service, DE5BF72x channel).
if grep -rniE 'FEE7|FEA1|FEA2|FEC9|DE5BF72|DE5BF7' "$dir" --include='*.swift'; then bad "reference to a prohibited service/characteristic"; fi

# 3. Exactly one writeValue, in BatteryProbeModel.confirmAndSendBatteryQuery, using the fixed request.
total=$(grep -rn 'writeValue' "$dir" --include='*.swift' | wc -l)
[ "$total" -eq 1 ] || bad "expected exactly one writeValue, found $total"
grep -n 'writeValue' "$model" | grep -q 'BatteryRequest.bytes' || bad "writeValue must send BatteryRequest.bytes"
grep -n 'writeValue' "$model" | grep -q 'for: writeChar,' || bad "writeValue must target the discovered write characteristic"
line=$(grep -n 'writeValue' "$model" | head -1 | cut -d: -f1)
fn=$(head -n "$line" "$model" | grep -n 'func ' | tail -1)
echo "$fn" | grep -q 'confirmAndSendBatteryQuery' || bad "writeValue is not inside confirmAndSendBatteryQuery ($fn)"

# 4. confirmAndSendBatteryQuery is called only from the confirmation button in ContentView.
callers=$(grep -rn 'confirmAndSendBatteryQuery()' "$dir" --include='*.swift' | grep -v 'func confirmAndSendBatteryQuery')
[ "$(echo "$callers" | grep -c .)" -eq 1 ] || bad "confirmAndSendBatteryQuery must have exactly one caller"
echo "$callers" | grep -q 'ContentView.swift' || bad "confirmAndSendBatteryQuery caller must be ContentView (confirmation button)"

# 5. Gate + one-shot latch are wired before the write.
grep -q 'BatteryQueryGate.evaluate(preconditions)' "$model" || bad "send path must call BatteryQueryGate.evaluate"
grep -q 'queryAlreadySent = true' "$model" || bad "one-shot latch missing"

# 6. Exactly one user-initiated connect; no reconnect.
count=$(grep -rn 'central\.connect(' "$dir" --include='*.swift' | wc -l)
[ "$count" -eq 1 ] || bad "expected exactly one central.connect( call, found $count"

# 7. No writes to disk / logging frameworks that could persist raw data.
if grep -rnE '\b(print|NSLog|os_log|Logger)\(' "$dir" --include='*.swift'; then bad "logging call found (raw BLE data must stay on screen only)"; fi

# --- M1.1 additions (docs/protocol/M1_1_BATTERY_SEMANTICS_EXPERIMENT.md) ---

# 8. The only frame ever built is the fixed 0x03 request: one build call, one command-byte constant.
builds=$(grep -rn 'Frame16\.build(' "$dir" --include='*.swift')
[ "$(echo "$builds" | grep -c .)" -eq 1 ] || bad "expected exactly one Frame16.build( call in the app"
echo "$builds" | grep -q 'Frame16\.build(command: commandByte)' || bad "the only frame must be Frame16.build(command: commandByte) with no payload"
grep -q 'static let commandByte: UInt8 = 0x03$' "$dir/BatteryFrame.swift" || bad "commandByte must be the constant 0x03"
cmds=$(grep -rnE 'command: *0x|commandByte *= ' "$dir" --include='*.swift' | grep -v 'static let commandByte: UInt8 = 0x03$')
[ -z "$cmds" ] || bad "alternative command byte found: $cmds"

# 9. Single deferred block (the 10 s 'no response' log message); no other scheduling that could resend.
[ "$(grep -rn 'asyncAfter' "$dir" --include='*.swift' | wc -l)" -le 1 ] || bad "more than one asyncAfter"
if grep -rnE 'DispatchSourceTimer|OperationQueue|Task\.sleep|while |repeat \{' "$dir" --include='*.swift'; then bad "scheduling/loop construct found"; fi

# 10. No battery decoder and no user-facing battery value.
if grep -rniE 'percent|batteryLevel|decodeBattery|Battery: ' "$dir" --include='*.swift'; then bad "battery decoding / Battery % UI is not authorized"; fi

# 11. Raw notification bytes are never logged, rendered as hex, copied or shared.
if grep -rn 'record(' "$dir" --include='*.swift' | grep -E '\.hex|observation\.payload|\.value\b'; then bad "notification bytes must not reach the event log"; fi
if grep -n '\.hex' "$dir/ContentView.swift"; then bad "ContentView must not render notification hex"; fi
if grep -rnE 'UIPasteboard|ShareLink|UIActivityViewController|fileExporter' "$dir" --include='*.swift'; then bad "copy/share/export API found"; fi

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "OK: single gated writeValue of the fixed 0x03 request; no alternative command, resend, battery decoder, raw logging, export or prohibited-channel reference"
