#!/bin/bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh -s

###############################################################################

###############################################################################
# @section obj
# Implementation of a class that can hold arbitrary nested data of maps and arrays.

# .a -> .a
# .a. -> .a
# '' -> .
# a -> .a
_L_dotkey_normalize_vL_KEY() {
  case "${1//\\[.\\]/xx}" in
    *\\*) return 1 ;;
    .*[^.].) L_KEY=${1%.} ;;
    *[^.].) L_KEY=.${1%.} ;;
    .*) L_KEY=$1 ;;
    *) L_KEY=.$1 ;;
  esac
}

_L_dotkey_is_valid() { [[ "${1//\\[.\\]/}" != *\\* ]]; }
# a.b.c -> a
_L_dotkey_get_first_vL_RET() { L_RET=${1//\\[.\\]/XX} L_RET=${L_RET#.} L_RET=${L_RET%%.*} L_RET=${1::${#L_RET}}; }
_L_dotkey_remove_last_vL_RET() { L_RET=${1//\\[.\\]/XX} L_RET=${L_RET#.} L_RET=${L_RET%.*} L_RET=${1::${#L_RET}}; }

_L_dotkey_escape_vL_RET() { L_RET=("${@//\\/\\\\}") L_RET=("${L_RET[@]//./\\.}"); }
_L_dotkey_unescape_vL_RET() { L_RET=("${@/\\\\/\\}") L_RET=("${L_RET[@]//\\./.}"); }

L_dotkey_join() { L_handle_v_scalar "$@"; }
L_dotkey_join_vL_RET() { L_RET=("${@//\\/\\\\}"); local IFS=.; L_RET="${L_RET[*]//./\\.}"; }

L_dotkey_split() { L_handle_v_scalar "$@"; }
L_dotkey_split_vL_RET() {
  _L_dotkey_is_valid "$1" || return
  case "$1" in
    *\\*)
      L_RET=${1#.}
      L_RET=${L_RET//$'\2'/$'\2\3'}
      L_RET=${L_RET//\\\\/$'\2\5'}
      L_RET=${L_RET//\\./$'\2\4'}
      L_readarray -t -d . L_RET <<<"$L_RET."
      unset 'L_RET[-1]'
      L_RET=("${L_RET[@]//$'\2\4'/.}")
      L_RET=("${L_RET[@]//$'\2\5'/\\}")
      L_RET=("${L_RET[@]//$'\2\3'/$'\2'}")
      ;;
    *$'\n'*)
      L_readarray -t -d . L_RET <<<"${1#.}."
      unset 'L_RET[-1]'
      ;;
    *)
      IFS=. read -ra L_RET <<<"${1#.}"
      ;;
  esac
}
