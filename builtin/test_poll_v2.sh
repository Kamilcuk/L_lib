#!/usr/bin/env bash

# test_poll_v2.sh - Unit tests for new positional poll/ppoll interface

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
enable -f "$DIR/build/L_builtin.so" L_builtin || { echo "Failed to load L_builtin"; exit 1; }

echo "Builtin loaded (v2 interface)."

# Test 1: Basic poll timeout
echo "Test 1: poll timeout"
L_builtin poll -t 0.1 -v results
if [[ ${#results[@]} -eq 0 ]]; then echo "PASS"; else echo "FAIL (count=${#results[@]})"; fi

# Test 2: Basic poll with pipe
echo "Test 2: poll with pipe"
L_builtin pipe p
echo "hello" >&"${p[1]}"
# Watch read end (p[0])
L_builtin poll -t 1 -v results "${p[0]}:r"
if [[ ${#results[@]} -eq 1 ]] && [[ "${results[0]}" == "${p[0]}:r" ]]; then
    echo "PASS"
else
    echo "FAIL (results=${results[*]})"
fi
exec {p[0]}<&-
exec {p[1]}>&-

# Test 3: ppoll atomic signal
echo "Test 3: ppoll atomic signal"
trap 'CAUGHT=1' USR1
CAUGHT=0
L_builtin sigmask -s USR1
kill -USR1 $$
# Should return immediately, results should be empty but CAUGHT=1
L_builtin ppoll -u USR1 -t 2 -v results
if [[ $CAUGHT -eq 1 ]] && [[ ${#results[@]} -eq 0 ]]; then
    echo "PASS"
else
    echo "FAIL (CAUGHT=$CAUGHT, count=${#results[@]})"
fi
L_builtin sigmask -u USR1

echo "Tests completed."
