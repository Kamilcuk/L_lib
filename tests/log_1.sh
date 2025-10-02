#!/bin/bash
set -euo pipefail
. "$L_LIB_SCRIPT"
L_log_configure -L
case "$1" in
  1)
    log_function() {
      L_log 'hello world from function'
    }
    log_function
    ;;
  2)
    L_log 'hello world from main'
    ;;
  *)
    exit 200
esac
