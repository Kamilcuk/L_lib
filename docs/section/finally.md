When discovering Bash one of the missing features is _not_ try catch block, but try finally block.

See also [with](https://kamilcuk.github.io/L_lib/section/with/) section of documentation.
It has some function build on top of `L_finally`.

## The issues with raw `trap`:

  - Not easy to append actions to trap.
    - (This is something I crudely wanted to solve with `L_trap_push` and `L_trap_pop` with unmanageable results)
  - On which signals you want to execute? EXIT? INT? TERM? HUP?
  - EXIT trap signal is not executed always and is not executed in command substitutions. Or it is? It depends.
  - If you register action on EXIT and INT trap, it might execute twice, or not.
    - Trapped SIGINT does not exit. Calling `exit` inside SIGINT trap changes exit status.
  - The signal exit status is hard to preserve.
    - The proper way is to `trap - SIGINT; kill -SIGINT $BASHPID` to have the Bash process properly exit with the signal cause.
    - The trap and kill is different between signals.
  - There is one RETURN trap shared across all functions. Inner functions overwrite outer functions RETURN trap.

## Features:

  - Execute something when Bash exits. Always.
    - `L_finally something`
  - Execute something when a function returns or Bash exits, whichever comes first.
    - `func() { L_finally -r something; }`
  - Execute something on signal and continue execution after it.
    - `L_finally; trap 'something' USR1`
  - If 2 signals are received during trap handler execution, terminate execution with a friendly message.
  - Registered actions execute in reverse order.
  - Remove the last registered action without execution.
    - `L_finally_pop -n`
  - Remove and execute the last registered action.
    - `L_finally_pop`
  - Critical section delays the execution of signal handlers.
    - `L_finally_critical_section func`
  - The signal exit status as reported by `WIFSIGNALED` should be preserved.

## How `L_finally` works?

  - Registers trap on all signals that result in process termination.
  - Keeps a list of actions to execute on exit.
  - When receiving a signal, all exit actions are executed.
  - When receiving a RETURN trap:
     - Execute the RETURN traps for the function that is returning.
     - The traps are removed the exit traps.

## Usage notes:

  - Inside the `L_finally` handler:
     - Variable `L_SIGNAL` is set to the received signal name.
     - Variable `L_SIGNUM` is set to the received signal number.
     - Variable `L_SIGRET` is set to the value of `$?` when trap is expanded.
     - It is not allowed to call `return` on top level. This would just return from the `L_finally` handler.
  - If you want to provide your own signal handlers, it is important to first call `L_finally` without or with arguments.
    The first call to `L_finally` will register the signal handlers _for this BASHPID_!
    They will not be re-registered later, so they allow to overwrite the handler.
  - Consider using `L_eval` to properly escape arguments when evaluating them.


## Examples

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
option_func() {
  local tmpf=$(mktemp)
  L_finally -r rm -rf "$tmpf"
  echo Do something with temporary file >"$tmpf"

  # exit 1         # this will remove the tempfile
  # return 1       # this will also remove the tempfile
  # kill $BASHPID  # this will also remove the tempfile
  # the tempfile is automatically removed on the end of function
}

main() {
  tmpf=$(mktemp)
  L_finally -r rm -rf "$tmpf"
  if [[ -n "$option" ]]; then
    option_func
  fi
}
```

Custom action on signal:

```
increase_volume() { : your function to increase volume; }

L_finally                    # with no arguments, just registers the action on all traps for this BASHPID.
# kill -USR1 $BASHPID        # would terminate the process executing L_finally_run
trap 'increase_volume' USR1
kill -USR1 $BASHPID          # will increase volume and continue execution
```

## Implementation notes

There have been multiple iterations of the design with multiple arrays.
Bottom line, the idea was that "choosing" which traps to execute should be as fast as possible.

The simplest design with just two array of commands to execute turned out to be most effective and efficient and easy.
Each element has an index, can be easily removed and navigate.

The only downside is that during `L_finally_pop` the code needs to find the index of RETURN array element connected to the EXIT array element. This is a simple loop. It is still faster than any `${//} ${##}` parsing I have come up with before this design.

Users do not need an array on custom signals. I decided there is little need for "expanding" the features of this library into a ultra-signal-manager. 99.9% of the time I require a simple "try finally" block, nothing more, nothing less, and this covers most usages.

# Generated documentation from source:

::: bin/L_lib.sh finally
