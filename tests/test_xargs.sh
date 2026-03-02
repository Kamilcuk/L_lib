#!/usr/bin/env bash
set -euo pipefail

_L_test_L_xargs_basic_functionality() {
    local output
    # Test simple command execution
    output=$(printf "1
2
3" | L_xargs echo)
    L_unittest_eq "$output" "1 2 3"

    # Test -n option
    output=$(printf "1
2
3
4
5" | L_xargs -n 2 echo)
    L_unittest_eq "$output" "1 2
3 4
5"

    # Test -I option
    output=$(printf "file1
file2" | L_xargs -I {} echo "Processing {}")
    L_unittest_eq "$output" "Processing file1
Processing file2"

    # Test with no input. L_xargs should not run the command.
    output=$(printf "" | L_xargs echo "this should not be printed")
    L_unittest_eq "$output" ""

    # Test -0 option with null-separated input
    output=$(printf "item1\0item2\0item3\0" | L_xargs -0 echo)
    L_unittest_eq "$output" "item1 item2 item3"

    # Test -P option (basic parallel execution, difficult to assert order)
    # This test just ensures it runs without error, exact output order may vary
    output=$(printf "1
2
3" | L_xargs -P 3 -n 1 bash -c 'echo "proc:$BASHPID val:$1"' --)
    L_unittest_match "$output" "proc:[0-9]+ val:1
proc:[0-9]+ val:2
proc:[0-9]+ val:3" "L_xargs -P should run in parallel"
}

_L_test_L_xargs_extended_options() {
    local output
    # Test -t option (verbose)
    output=$(printf "1
2" | L_xargs -t -n 1 echo 2>&1)
    L_unittest_eq "$output" "+ echo 1
1
+ echo 2
2"

    # Test -d option (delimiter)
    output=$(printf "1:2:3" | L_xargs -d : echo)
    L_unittest_eq "$output" "1 2 3"

    # Test -a option (read from array)
    local my_array=("a b" "c" "d")
    output=$(L_xargs -a my_array echo)
    L_unittest_eq "$output" "a b c d"

    # Test -s option (shell-like parsing)
    output=$(printf "'a b'
c
'd e'" | L_xargs -s echo)
    L_unittest_eq "$output" "a b c d e"

    # Test -O option (separate output buffering)
    output=$(printf "1
2" | L_xargs -P 2 -n 1 -O bash -c 'echo $1')
    L_unittest_eq "$output" "1
2"

    # Test -^ option (prefix)
    output=$(printf "1
2" | L_xargs -n 1 -^ echo)
    L_unittest_eq "$output" "1: 1
2: 2"
}

L_unittest_match() {
    L_unittest_cmd L_regex_match "$1" "$2"
}

_L_test_L_xargs_return_codes() {
    # Command exiting with 0
    L_unittest_cmd -e 0 -I L_xargs bash -c 'exit 0' <<<'1'
    # Command exiting with 1-125 -> L_xargs should return 123
    L_unittest_cmd -e 123 -I L_xargs bash -c 'exit 5' <<<'1'
    # Command exiting with 255 -> L_xargs should return 124
    L_unittest_cmd -e 124 -I L_xargs bash -c 'exit 255' <<<'1'
    # Command not found -> L_xargs should return 127
    L_unittest_cmd -e 127 -I L_xargs non_existent_command <<<'1'
}
