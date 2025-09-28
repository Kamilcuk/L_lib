#!/bin/bash
. ../bin/L_lib.sh

L_critical_section() {
  local _L_traps=$(trap -p) _L_i
  local -a _L_arr="($_L_traps)"
  for ((_L_i = 3; _L_i < ${#_L_arr[@]}; _L_i += 4)); do
    if [[ "${_L_arr[$_L_i]}" == SIG* ]]; then
      trap - "${_L_arr[$_L_i]}"
    fi
  done
  "$@"
  eval "$_L_traps; return $?"
}
