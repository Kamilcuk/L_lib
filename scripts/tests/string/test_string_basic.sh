#!/bin/bash
# Test basic string operations from string.md

. "$(dirname "$0")/../../../bin/L_lib.sh"

echo "=== Testing L_strip ==="
str="  hello world  "
result=$(L_strip "$str")
echo "Result: '$result'"
[[ "$result" == "hello world" ]] || { echo "FAIL: Expected 'hello world'"; exit 1; }

L_strip -v result2 "$str"
echo "Result with -v: '$result2'"
[[ "$result2" == "hello world" ]] || { echo "FAIL: Expected 'hello world'"; exit 1; }

echo ""
echo "=== Testing L_strupper / L_strlower ==="
upper=$(L_strupper "hello")
echo "Upper: $upper"
[[ "$upper" == "HELLO" ]] || { echo "FAIL: Expected 'HELLO'"; exit 1; }

lower=$(L_strlower "WORLD")
echo "Lower: $lower"
[[ "$lower" == "world" ]] || { echo "FAIL: Expected 'world'"; exit 1; }

L_strupper -v upper2 "bash scripting"
echo "Upper with -v: $upper2"
[[ "$upper2" == "BASH SCRIPTING" ]] || { echo "FAIL"; exit 1; }

echo ""
echo "=== Testing L_strstr ==="
if L_strstr "hello world" "world"; then
	echo "Found 'world' in 'hello world' ✓"
else
	echo "FAIL: Should have found 'world'"
	exit 1
fi

if ! L_strstr "hello world" "xyz"; then
	echo "'xyz' not found in 'hello world' ✓"
else
	echo "FAIL: Should not have found 'xyz'"
	exit 1
fi

echo ""
echo "All basic string tests passed!"
