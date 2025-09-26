#!/usr/bin/env bash

. bin/L_lib.sh


L_finally_handle() {
  local L_SIGNAL="${1:-EXIT}" _L_pid
  trap - "$L_SIGNAL" RETURN EXIT
  if [[ "$L_SIGNAL" == "SIGQUIT" ]]; then
  	exit 131
  fi
  L_bashpid_to _L_pid
  kill -"$L_SIGNAL" "$_L_pid"
}

L_finally() {
  register_signals="HUP"
  for i in EXIT $register_signals; do
  	# shellcheck disable=SC2064
    trap "L_finally_handle $i" "$i" || return 1
  done
}

###############################################################################

f() {
  . bin/L_lib.sh
  L_finally eval 'echo $L_SIGNAL received'
  set -x
  L_raise -HUP
}

check() {
  echo "TEST [ $1 ]"
  eval "$1"
  echo
}

check '( f; echo IN=$? ); echo OUT=$?'
check '( ( f; ); echo RET=$? );'

check '( trap "trap - EXIT; trap - HUP; L_raise -HUP" HUP; L_raise -HUP; ); echo OUT=$?'
check '( ( trap "trap - EXIT HUP; L_raise -HUP" HUP; L_raise -HUP; ); echo RET=$? )'
check '( trap "trap - EXIT; trap - HUP; L_raise -HUP" EXIT HUP; L_raise -HUP; ); echo OUT=$?'
check '( ( trap "trap - EXIT HUP; L_raise -HUP" EXIT HUP; L_raise -HUP; ); echo RET=$? )'
exit

g() { trap - HUP EXIT RETURN; L_raise -HUP; }
check '                   ( ( set -x; g; ); echo RET=$? )'
check '( set -x; L_finally echo hi; ( ( set -x; g; ); echo RET=$? ) )'
check '( set -o functrace; trap : HUP EXIT RETURN; ( set -x; g; ); echo RET=$? )'


