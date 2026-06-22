#!/usr/bin/env bash

# test_pselect.sh - Unit tests for pselect subcommand

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
enable -f "$DIR/build/L_builtin.so" L_builtin || { echo "Failed to load L_builtin"; exit 1; }

echo "Builtin loaded."

# Test 1: Atomic signal unblocking
trap 'CAUGHT=1' USR1
CAUGHT=0

echo "Test 1: Atomic signal unblocking"
# Block USR1
L_builtin sigmask -s USR1
echo "Signal blocked."

# Send USR1 to self - it should be pending
kill -USR1 $$
echo "Signal sent."

# Now call pselect and unblock USR1. It should return immediately.
ret=0
L_builtin pselect -u USR1 -t 2 -v ret_val || ret=$?

if [[ ${CAUGHT:-0} -eq 1 ]]; then
    echo "PASS: USR1 caught during pselect"
else
    echo "FAIL: USR1 NOT caught during pselect"
fi

# Check return value
if [[ $ret_val -eq -1 ]]; then
    echo "PASS: pselect returned -1 (interrupted)"
else
    echo "FAIL: pselect returned $ret_val, expected -1"
fi

# Test 2: Timeout works
echo "Test 2: Timeout works"
L_builtin pselect -t 0.5 -v ret_val
if [[ $ret_val -eq 0 ]]; then
    echo "PASS: pselect timeout works"
else
    echo "FAIL: pselect timeout returned $ret_val"
fi

# Cleanup mask
L_builtin sigmask -u USR1

echo "Tests completed."
