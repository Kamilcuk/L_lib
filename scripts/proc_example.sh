#!/usr/bin/env bash
. L_lib.sh
L_finally wait
L_finally L_kill_all_childs
pids=()
for script in 'sleep 1 && exit 1' 'sleep 2; exit 2' 'sleep 3; exit 3'; do
  L_proc_popen pid bash -c "$script"
  pids+=("$pid")
done
for pid in "${pids[@]}"; do
  L_proc_wait "$pid"
  echo "Process [$(L_proc_get_cmd "$pid")] pid $(L_proc_get_pid "$pid") exited with $(L_proc_get_exitcode "$pid")"
done
