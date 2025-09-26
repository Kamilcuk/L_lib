#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh
L_log_configure -L

_L_ini_args() {
  local OPTIND OPTERR OPTARG _L_i
  while getopts _L_i; do
    case "$_L_i" in
      h) L_func_help 1; return 0 ;;
      *) L_func_error "" 1; return 2; ;;
    esac
  done
  shift "$((OPTIND-1))"
}

L_ini_set() {
  local _L_v
  _L_ini_args
}
