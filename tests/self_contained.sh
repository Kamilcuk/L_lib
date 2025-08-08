#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh -s
functions="$(compgen -A function -- _L_)
$(compgen -A function -- L_)
"
all_functions="$functions
L_cb_parse_args
L_cb_usage
"
work() {
  func="$1"
  def=$(declare -f "$func") || L_panic "Function does not exists: $func"
  calls=$(sed -n 's/^[ \t\n]*\(_\?L_[^ \t\n;]*\).*/\1/p' <<<"$def" | grep -v '[=+[]' | sort -u)
  for call in $calls; do
    L_assert "Function $func calls $call but this function does not exists in L_lib.sh: $def" \
      grep -q "$call" <<<"$all_functions"
  done
}
export -f $functions work
xargs -P$(nproc) -i bash -c "work {}" <<<"$functions"
echo "SUCCESS"
