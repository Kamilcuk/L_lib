#!/bin/bash
set -euo pipefail

###############################################################################
###############################################################################

if L_is_main; then
  set -euo pipefail
  if (( $# )); then
    "$@"
  else
    count=0
    mycallback() {
      count=$((count + 1))
      L_notice "mycallback called! count=$count"
      if ((count == 5)); then
        L_notice "ENDING! removing mytimer=$mytimer"
        L_uv_remove "$mytimer"
      fi
    }

    myreader() {
      L_notice "The pipe has written: $*"
    }

    L_finally -f set +e
    L_log_configure -L
    L_uv_init
    L_pipe fd
    L_with_process_into _ L_eval 'for i in 1 2 3; do sleep 0.6; L_log "writing $i"; echo $i; done >&"${fd[1]}"'
    exec {fd[1]}>&-
    L_uv_add_reader "${fd[0]}" myreader
    L_uv_add_timer -d 0.5 -r 0.35 -v mytimer mycallback
    L_notice "process start"
    L_uv_run "$@"
    L_notice "process end"
  fi
fi

# Example usage (commented out):
# count=0
# mycallback() {
#   count=$((counecho WHERE MA I?
#   echo "$(date +%s) mycallback called! count=$count"
#   if ((count == 5)); then
#     echo "ENDING!"
#     L_uv_current_remove
#   fi
# }
# loop1=
# L_uv_init loop1
# L_uv_add_timer -d 100 -r 200 loop1 mycallback
# sleep 0.123 &
# L_uv_add_waiter loop1 "$!" L_eval 'echo "$1 died with $2"' $!
# L_uv_add_waiter loop1 "$!" L_eval 'echo "$1 died with $2"' $!

