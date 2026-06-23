#!/usr/bin/env bash
set -euo pipefail

ulimit -c 0
export TIMEFORMAT='real=%6lR user=%6lU system=%6lS'
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir"/../bin/L_lib.sh

# Load L_builtin
build_dir="${B:-build}"
module="$dir/$build_dir/L_builtin.so"
L_info "BASH_VERSION=$BASH_VERSION module=$module"

if [[ ! -f $module ]]; then
    L_panic "Error: $module not found. Run make first."
fi
enable -f "$module" L_builtin

# Source all modular test files
for f in "$dir"/tests/test_*.sh; do
    . "$f"
done

L_trap_err_enable
L_unittest_main -p _L_test_ "$@"
