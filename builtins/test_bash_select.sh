#!/usr/bin/env bash

# Load the builtin
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
enable -f "$DIR/build/bash_select.so" bash_select || { echo "Failed to load builtin from $DIR/build/bash_select.so"; exit 1; }

echo "Builtin loaded."

# Test 1: Timeout
readfds=(0)
timeout=0.1
ret=-1
echo "Test 1: Timeout (polling stdin with 0.1s timeout, no input expected)"
bash_select -r readfds -t $timeout -v ret
echo "Return: $ret (expected 0)"
echo "Readfds: ${readfds[@]} (expected empty)"

# Test 2: Ready FD (using a pipe)
echo "Test 2: Ready FD (polling read end of a pipe)"
exec 3< <(echo "data")
sleep 0.1 # Ensure data is in pipe
readfds=(3)
bash_select -r readfds -t $timeout -v ret
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
bash_select -r readfds -t $timeout -v ret
echo "Return: $ret (expected 2)"
echo "Readfds: ${readfds[@]} (expected 3 4)"
exec 3<&-
exec 4<&-

echo "Tests completed."
