#!/bin/bash
. L_lib.sh
childs=()
for script in 'sleep 1 && exit 1' 'sleep 2; exit 2' 'sleep 3; exit 3'; do
  L_proc_popen tmp bash -c "$script"
  childs+=("$(L_array_to_string tmp)")
done
for i in "${childs[@]}"; do
  L_array_from_string child "$i"
  declare -p child
  L_proc_wait child
  echo "Child [$(L_proc_get_cmd child)] pid $(L_proc_get_pid child) exited with $(L_proc_get_exitcode child)"
done
