#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh -s
functions="\
$(compgen -A function -- _L_)
$(compgen -A function -- L_)
"
all_functions="\
$functions
L_cb_parse_args
L_cb_usage
L_asa_set
"
work() {
  func="$1"
  if [[ "$func" == _L_lib_usage ]]; then
    # Ignore
    return
  fi
  def=$(declare -f "$func") || L_panic "Function does not exists: $func"
  calls=$(sed -n 's/^[ \t\n]*\(_\?L_[^ \t\n;]*\).*/\1/p' <<<"$def" | grep -v '[=+[]' | sort -u)
  for call in $calls; do
    L_assert "-255 Function $func calls $call but this function does not exists in L_lib.sh: $def" \
      grep -q "$call" <<<"$all_functions"
  done
}
if L_hash L_xargs; then
  L_xargs -t -P "$(nproc)" -i work {} <<<"$functions"
else
  export -f $functions work
  export all_functions functions
  xargs -t -P "$(nproc)" -n1 bash -c 'work $1' bash <<<"$functions"
fi
echo "SUCCESS"
