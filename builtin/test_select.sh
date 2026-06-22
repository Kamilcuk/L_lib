#!/usr/bin/env bash

# test_select.sh - Unit tests for L_builtin select subcommand

# Load the builtin
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
enable -f "$DIR/build/L_builtin.so" L_builtin || { echo "Failed to load builtin from $DIR/build/L_builtin.so"; exit 1; }

echo "Builtin loaded."

# Test 1: Timeout
readfds=(0)
timeout=0.1
ret=-1
echo "Test 1: Timeout (polling stdin with 0.1s timeout, no input expected)"
L_builtin select -r readfds -t $timeout -v ret
echo "Return: $ret (expected 0)"
echo "Readfds: ${readfds[@]} (expected empty)"

# Test 2: Ready FD (using a pipe)
echo "Test 2: Ready FD (polling read end of a pipe)"
exec 3< <(echo "data")
sleep 0.1 # Ensure data is in pipe
readfds=(3)
L_builtin select -r readfds -t $timeout -v ret
echo "Return: $ret (expected 1)"
echo "Readfds: ${readfds[@]} (expected 3)"
read line <&3
echo "Read: $line"
exec 3<&-

# Test 3: Multiple FDs
echo "Test 3: Multiple FDs"
exec 3< <(echo "data3")
exec 4< <(echo "data4")
sleep 0.1
readfds=(3 4)
L_builtin select -r readfds -t $timeout -v ret
echo "Return: $ret (expected 2)"
echo "Readfds: ${readfds[@]} (expected 3 4)"
exec 3<&-
exec 4<&-

echo "Tests completed."
