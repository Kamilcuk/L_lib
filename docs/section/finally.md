When discovering Bash one of the missing features is _not_ try catch block, but try finally block.

The issues with raw `trap`:
  - not easy to append actions to trap
    - (this is something I initialialy lightly wanted to solve with `L_trap_push` and `L_trap_pop`)
  - On which signals you want to execute? EXIT? INT? TERM?
  - EXIT trap signal is not executed always and is not executed in command substitutions. Or is it? It depends.
  - If you register action on EXIT and INT trap, it will execute twice.
    - Trapped SIGINT does not exit. Calling `exit` inside SIGINT trap changes exit status.
    - The proper way is to `trap - SIGINT; kill -SIGINT $BASHPID` to have the Bash process properly exit with the signal cause.
    - The trap and kill is different between signals.
  - There is one RETURN trap shared across all functions. Inner functions overwrite outer functions RETURN trap.

Requirements:
  - Execute something when Bash exits. Always.
    - `L_finally something`
  - Execute something when a function returns or Bash exits, whichever comes first.
    - `L_finally -r something`
  - Execute something on signal and continue execution after it.
    - `L_finally; trap 'something' USR1`
  - If signal is received in trap handler, terminate execution.
  - Registered actions execute in reverse order.
  - Remove the last registered action without execution.
    - `L_finally_pop -n`
  - Remove and execute the last registered action.
    - `L_finally_pop`

How `L_finally` works?
  - Registers trap on all signals that result in process termination.
  - Keeps a list of actions to execute on what signal. Each action executes once (by default).
  - Unless the signal has been added to the list of signals that continue the execution.
    - Explicitly executes EXIT actions on all signals that result in process termination.
    - The trap handler properly preserves exit code of terminating signals.
  - The RETURN trap handler checks the registration location of the trap and executes appriopriate action only.

Example:

```

tmpf=$(mktemp)
L_finally rm -rf "$tmpf"
: do something to tmpf >"$tmpf"

if [[ -n "$option" ]]; then
  tmpf2=$(mktemp)
  L_finally rm -rf "$tmpf2"
  : we need another tmpf2 >"$tmpf2"
  : it is ok, we can remove it now
  L_finally_pop
if

# tmp will be removed on the end of the script.
```

Function return example:

```
some_function() {
  local tmpf=$(mktemp)
  L_finally -r rm -rf "$tmpf"
  echo Do something with temporary file >"$tmpf"

  # exit 1         # this will remove the tempfile
  # return 1       # this will also remove the tempfile
  # kill $BASHPID  # this will also remove the tempfile
  # the tempfile is automatically removed on the end of function
}
```

Custom action on signal:

```
increase_volume() { : your function to increase volume; }

# kill -USR1 $BASHPID   # will terminate the process, default action
L_finally -n USR1 increase_volume
# kill -USR1 $BASHPID   # will increase volume and continue execution
```

# Generated documentation from source:

::: bin/L_lib.sh finally
