This section contains functions related to handling co-processes. The Bash builtin coproc is missing features, in particular there may be only one coproc open at any time.

This library comes with `L_proc_popen` which allows to open any number of child processes for writing and reading.

```
--8<-- "scripts/proc_example.sh"
```

::: bin/L_lib.sh proc
