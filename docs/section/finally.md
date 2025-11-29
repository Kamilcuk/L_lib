# L_finally - Cleanup Actions and Defer Pattern

One of the most frustrating missing features in Bash is not try-catch blocks, but **try-finally blocks** - the ability to guarantee cleanup code runs no matter how your script exits.

`L_finally` brings Python's `finally`, Go's `defer`, and similar patterns to Bash, ensuring your cleanup code **always** runs - whether your script exits normally, returns from a function, receives a signal, or encounters an error.

## Quick Start

```bash
#!/bin/bash
. L_lib.sh

# Example 1: Clean up temporary file on script exit
tmpfile=$(mktemp)
L_finally rm -rf "$tmpfile"
# Now work with tmpfile - it will be automatically removed on any exit

# Example 2: Clean up on function return
process_data() {
    local tmpdir=$(mktemp -d)
    L_finally -r rm -rf "$tmpdir"  # -r means "on RETURN"
    # Work with tmpdir - cleaned up when function returns, exits, or receives signal
    echo "Processing..." > "$tmpdir/data.txt"
}
```

See also the [with](https://kamilcuk.github.io/L_lib/section/with/) section for higher-level functions built on top of `L_finally`.

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

### Basic Cleanup on Exit

```bash
#!/bin/bash
. L_lib.sh

# Create a temporary file and ensure it's cleaned up
tmpf=$(mktemp)
L_finally rm -rf "$tmpf"

# Do your work
echo "important data" > "$tmpf"
cat "$tmpf" | process_data

# tmpf will be automatically removed when script exits (normally or abnormally)
```

### Multiple Cleanup Actions (Stack-Based)

```bash
tmpf=$(mktemp)
L_finally rm -rf "$tmpf"

if [[ -n "$option" ]]; then
  tmpf2=$(mktemp)
  L_finally rm -rf "$tmpf2"

  # Process something with tmpf2
  echo "optional data" > "$tmpf2"

  # We're done with tmpf2, remove it now
  L_finally_pop  # Executes and removes the last registered action
fi

# Both tmpf and tmpf2 (if created) will be cleaned up
# Actions execute in reverse order (LIFO/stack)
```

### Function-Scoped Cleanup with `-r`

The `-r` option makes cleanup happen when the function returns, not when the script exits:

```bash
process_file() {
  local tmpdir=$(mktemp -d)
  L_finally -r rm -rf "$tmpdir"  # -r = cleanup on RETURN

  # Work with temporary directory
  cp "$1" "$tmpdir/"
  cd "$tmpdir" && process_data

  # Cleanup happens automatically when function returns via:
  # - normal return
  # - explicit 'return' statement
  # - 'exit' command
  # - received signal (SIGINT, SIGTERM, etc.)
  # - unhandled error with 'set -e'
}

main() {
  process_file "/path/to/input"
  # tmpdir is already cleaned up here
  echo "Processing complete"
}
```

### Real-World Example: Database Connection Cleanup

```bash
query_database() {
  local connection_id
  connection_id=$(db_connect "$DB_URL")
  L_finally -r db_disconnect "$connection_id"

  # Run queries - connection guaranteed to close
  db_query "$connection_id" "SELECT * FROM users"

  # Connection closes automatically on return/exit/signal
}
```

### Real-World Example: Lock File Management

```bash
critical_operation() {
  local lockfile="/var/lock/myapp.lock"

  # Acquire lock
  exec 200>"$lockfile"
  flock -n 200 || { echo "Already running"; return 1; }
  L_finally -r flock -u 200

  # Do critical work - lock released automatically
  modify_shared_resource
}
```

### Custom Signal Handlers

You can register custom signal handlers while still using `L_finally` for cleanup:

```bash
#!/bin/bash
. L_lib.sh

increase_volume() {
  echo "Volume increased"
}

# Register L_finally signal handlers first
L_finally

# Now override USR1 with custom handler
# USR1 will execute custom action and continue (not terminate)
trap 'increase_volume' USR1

# Send signal - will increase volume and continue
kill -USR1 $BASHPID

echo "Script continues..."
```

### Accessing Signal Information in Handlers

Inside `L_finally` handlers, special variables are available:

```bash
cleanup() {
  echo "Cleanup called by: $L_SIGNAL"  # Signal name (e.g., "SIGTERM", "EXIT", "POP")
  echo "Signal number: $L_SIGNUM"       # Signal number
  echo "Exit status was: $L_SIGRET"     # Exit status when trap fired
}

L_finally cleanup

# When script exits or receives signal, cleanup knows how it was called
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
