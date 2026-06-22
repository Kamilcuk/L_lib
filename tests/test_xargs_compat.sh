#!/usr/bin/env bash
set -euo pipefail

_L_test_L_xargs_eof_flushing() {
    local output
    # Test: atoms less than -n limit should be flushed at EOF
    output=$(echo "a b" | L_xargs -n 3 echo)
    L_unittest_eq "$output" "a b"

    # Test: exact multiple of -n
    output=$(echo "a b c d" | L_xargs -n 2 echo)
    L_unittest_eq "$output" "a b
c d"

    # Test: partial chunk at the end
    output=$(echo "a b c d e" | L_xargs -n 2 echo)
    L_unittest_eq "$output" "a b
c d
e"
}

_L_test_L_xargs_run_once_behavior() {
    local output
    # Standard xargs runs the command once even if input is empty
    output=$(echo -n "" | L_xargs echo "HEAD")
    L_unittest_eq "$output" "HEAD"

    # With -r, it should NOT run
    output=$(echo -n "" | L_xargs -r echo "HEAD")
    L_unittest_eq "$output" ""
}

_L_test_L_xargs_strict_options() {
    local output tmpf
    L_with_tmpfile_into tmpf
    echo "file_content" > "$tmpf"

    # -a should read from file
    output=$(L_xargs -a "$tmpf" echo)
    L_unittest_eq "$output" "file_content"

    # -A should read from array name
    local my_arr=("array_content")
    output=$(L_xargs -A my_arr echo)
    L_unittest_eq "$output" "array_content"

    # Passing array to -a should FAIL (it looks for a file named "my_arr")
    L_unittest_cmd -e 1 L_xargs -a my_arr echo 2>/dev/null
}

_L_test_L_xargs_record_limits() {
    local output
    # -L 1: trigger every line
    # Even if -z splits line into atoms, -L 1 should trigger dispatch after the line is processed.
    output=$(printf "a b\nc d" | L_xargs -L 1 -z echo)
    L_unittest_eq "$output" "a b
c d"

    # -L 2: trigger every 2 lines
    output=$(printf "1\n2\n3\n4\n5" | L_xargs -L 2 echo)
    L_unittest_eq "$output" "1 2
3 4
5"
}
