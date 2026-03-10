#!/usr/bin/env bash
./bash.sh 5.2 -c '( . bin/L_lib.sh ; a=($(seq 10)); f() { L_bashpid_to pid; echo $L_XARGS_INDEX:$pid; exec sleep 1; }; L_time L_setx L_xargs -a a -P5 f >/tmp/1 2>&1; cat /tmp/1 | grep -E "^[^\+]|^\++ (wait|kill) "; echo $? )'
