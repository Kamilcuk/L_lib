#!/bin/bash
set -euo pipefail
. "${BASH_SOURCE[0]%/*}/../bin/L_lib.sh"

p() {
  L_exit_to v L_not "$@"
  echo -n "$1=$v "
}

ERRORS=0
SCRIPT='
echo

case "${SCOPE[0]}" in
main) is_sourced=1 has_sourced_arguments=? ;;
args*) is_sourced=0 has_sourced_arguments=0 ;;
noargs*) is_sourced=0 has_sourced_arguments=1 ;;
*) echo "ERROROOR: ${SCOPE[*]}"; exit 123 ;;
esac

L_is_sourced && L_is_sourced=$? || L_is_sourced=$?
L_has_sourced_arguments && L_has_sourced_arguments=$? || L_has_sourced_arguments=$?

msg=""
if [[ "$L_is_sourced" != "$is_sourced" ]]; then ERRORS=$((ERRORS+1)); msg="${L_RED}ERR${L_RESET}"; else msg=${L_GREEN}OK${L_RESET}; fi
msg="L_is_sourced=$L_is_sourced =? $is_sourced $msg"
printf "%-40s | %s\n" "${SCOPE[*]}" "$msg"

if [[ "$L_has_sourced_arguments" != $has_sourced_arguments ]]; then ERRORS=$((ERRORS+1)); msg="${L_RED}ERR${L_RESET}"; else msg="${L_GREEN}OK${L_RESET}"; fi
msg="L_has_sourced_arguments=$L_has_sourced_arguments =? $has_sourced_arguments $msg"
printf "%-40s | %s\n" "${SCOPE[*]}" "$msg"

'

SCOPE=("main")
eval "$SCRIPT"
SCOPE=("noargs")
ARGS=()
. ${BASH_SOURCE[0]%/*}/source_test_1.sh ${ARGS[@]:+"${ARGS[@]}"}
SCOPE=("args")
ARGS=(a b c)
. ${BASH_SOURCE[0]%/*}/source_test_1.sh ${ARGS[@]:+"${ARGS[@]}"}


shopt -s extdebug
SCOPE=("noargs_extdebug")
ARGS=()
. ${BASH_SOURCE[0]%/*}/source_test_1.sh ${ARGS[@]:+"${ARGS[@]}"}
SCOPE=("args_extdebug")
ARGS=(a b c)
. ${BASH_SOURCE[0]%/*}/source_test_1.sh ${ARGS[@]:+"${ARGS[@]}"}

shopt -u extdebug

set -- d e f
SCOPE=("noargs")
ARGS=()
. ${BASH_SOURCE[0]%/*}/source_test_1.sh ${ARGS[@]:+"${ARGS[@]}"}
SCOPE=("args")
ARGS=(a b c)
. ${BASH_SOURCE[0]%/*}/source_test_1.sh ${ARGS[@]:+"${ARGS[@]}"}

exit "$ERRORS"
