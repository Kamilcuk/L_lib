#!/usr/bin/env bash
set -euo pipefail

ulimit -c 0
export TIMEFORMAT='real=%6lR user=%6lU system=%6lS'
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir"/../bin/L_lib.sh

# Load L_builtin
if [[ ! -f "$dir/build/L_builtin.so" ]]; then
    L_panic "Error: $dir/build/L_builtin.so not found. Run make first."
fi
enable -f "$dir/build/L_builtin.so" L_builtin

# Source all modular test files
for f in "$dir"/tests/test_*.sh; do
    . "$f"
done

L_trap_err_enable
L_unittest_main -p _L_test_ "$@"
