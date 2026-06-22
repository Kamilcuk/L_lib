#!/usr/bin/env bash

# test_poll.sh - Unit tests for poll and ppoll subcommands

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
enable -f "$DIR/build/L_builtin.so" L_builtin || { echo "Failed to load L_builtin"; exit 1; }

echo "Builtin loaded."

# Test 1: Basic poll timeout
echo "Test 1: poll timeout"
L_builtin poll -t 0.1 -v ret
if [[ $ret -eq 0 ]]; then echo "PASS"; else echo "FAIL (ret=$ret)"; fi

# Test 2: Basic poll with pipe
echo "Test 2: poll with pipe"
L_builtin pipe p
echo "hello" >&"${p[1]}"
rfds=("${p[0]}")
L_builtin poll -r rfds -v ret
if [[ $ret -eq 1 ]] && [[ "${rfds[0]}" == "${p[0]}" ]]; then
    echo "PASS"
else
    echo "FAIL (ret=$ret, rfds=${rfds[*]})"
fi
exec {p[0]}<&-
exec {p[1]}>&-

# Test 3: ppoll atomic signal
echo "Test 3: ppoll atomic signal"
trap 'CAUGHT=1' USR1
CAUGHT=0
L_builtin sigmask -s USR1
kill -USR1 $$
# Should return immediately with -1
L_builtin ppoll -u USR1 -t 2 -v ret
if [[ $CAUGHT -eq 1 ]] && [[ $ret -eq -1 ]]; then
    echo "PASS"
else
    echo "FAIL (CAUGHT=$CAUGHT, ret=$ret)"
fi
L_builtin sigmask -u USR1

echo "Tests completed."
