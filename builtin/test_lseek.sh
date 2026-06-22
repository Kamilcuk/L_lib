#!/bin/bash

# test_lseek.sh - Unit tests for L_builtin lseek subcommand

# Ensure the builtin is built
if [[ ! -f "./build/L_builtin.so" ]]; then
    echo "Error: ./build/L_builtin.so not found. Run make first." >&2
    exit 1
fi

enable -f ./build/L_builtin.so L_builtin

_L_test_lseek_basic() {
    local tmpfile=$(mktemp)
    echo -n "abcdefghij" > "$tmpfile"
    exec 3<"$tmpfile"

    local pos char
    
    # SEEK_SET
    L_builtin lseek -v pos 3 2 SET
    [[ "$pos" == "2" ]] || return 1
    read -n 1 -u 3 char
    [[ "$char" == "c" ]] || return 1

    # SEEK_CUR
    L_builtin lseek -v pos 3 2 CUR
    [[ "$pos" == "5" ]] || return 1
    read -n 1 -u 3 char
    [[ "$char" == "f" ]] || return 1

    # SEEK_END
    L_builtin lseek -v pos 3 -1 END
    [[ "$pos" == "9" ]] || return 1
    read -n 1 -u 3 char
    [[ "$char" == "j" ]] || return 1

    exec 3<&-
    rm "$tmpfile"
    return 0
}

_L_test_lseek_numeric_whence() {
    local tmpfile=$(mktemp)
    echo -n "0123456789" > "$tmpfile"
    exec 3<"$tmpfile"

    local pos
    
    L_builtin lseek -v pos 3 5 0 # SET
    [[ "$pos" == "5" ]] || return 1

    L_builtin lseek -v pos 3 2 1 # CUR
    [[ "$pos" == "7" ]] || return 1

    L_builtin lseek -v pos 3 0 2 # END
    [[ "$pos" == "10" ]] || return 1

    exec 3<&-
    rm "$tmpfile"
    return 0
}

_L_test_lseek_errors() {
    # Invalid FD
    if L_builtin lseek 999 0 SET 2>/dev/null; then
        return 1
    fi

    # Invalid whence
    if L_builtin lseek 0 0 INVALID 2>/dev/null; then
        return 1
    fi

    return 0
}

# Simple runner if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    errors=0
    for test_func in $(declare -F | awk '{print $3}' | grep '^_L_test_lseek_'); do
        echo -n "Running $test_func... "
        if $test_func; then
            echo "PASS"
        else
            echo "FAIL"
            errors=$((errors + 1))
        fi
    done
    exit $errors
fi
