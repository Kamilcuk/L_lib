#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh -s
functions="\
$(compgen -A function -- _L_)
$(compgen -A function -- L_)
"
all_functions="\
$functions
L_cb_parse_args
L_cb_usage
L_asa_set
L_lib
"
work() {
  local func="$1"
  local def=$(declare -f "$func") || L_panic "Function does not exists: $func"
  while IFS= read -r _L_line; do
    # 1. Match any identifier at the start of whitespace cleanly
    if [[ "$_L_line" =~ ^[[:space:]]*(_?L_[a-zA-Z0-9_]+) ]]; then
      _L_call="${BASH_REMATCH[1]}"
      # Additional safety check to drop common assignment artifacts
      if [[ "$_L_line" =~ ^[[:space:]]*_?L_[a-zA-Z0-9_]+[[:space:]]*[*+=[] ]]; then
        continue
      fi
      if [[ " $all_functions " != *[$' \n']"$_L_call"[$' \n']* ]]; then
        L_fatal "-255 Function $func calls $_L_call but this function does not exist in L_lib.sh:$L_NL$_L_line"
      fi
    fi
  done <<<"$def"
}
if L_is_main; then
  if L_hash L_xargs; then
    L_xargs -t -P n -i work {} <<<"$functions" || exit
  else
    export -f $functions work
    export all_functions functions
    xargs -t -P "$(nproc)" -n1 bash -c 'work $1' bash <<<"$functions" || exit
  fi
  echo "SUCCESS"
fi
