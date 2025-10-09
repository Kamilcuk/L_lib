#!/bin/bash
. $(dirname "$0")/../L_lib.sh
L_finally wait
L_finally L_kill_all_childs
childs=()
for script in 'sleep 1 && exit 1' 'sleep 2; exit 2' 'sleep 3; exit 3'; do
  L_proc_popen tmp bash -c "$script"
  childs+=("$tmp")
done
for i in "${childs[@]}"; do
  L_proc_wait i
  echo "Process [$(L_proc_get_cmd i)] pid $(L_proc_get_pid i) exited with $(L_proc_get_exitcode i)"
done
