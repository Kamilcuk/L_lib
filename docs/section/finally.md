# L_finally: Robust Cleanup & Signal Handling

The `L_finally` library provides a robust "try-finally" mechanism for Bash scripting, addressing the limitations and complexities of raw `trap` commands. It ensures that cleanup actions are reliably executed, whether a script exits normally, a function returns, or a signal is received.

For advanced usage involving resource management contexts, see the [with](https://kamilcuk.github.io/L_lib/section/with/) section.

## Why not just use `trap`?

Using the native `trap` builtin correctly in complex scripts is notoriously difficult:

*   **Stacking is hard:** Appending multiple actions to a trap without overwriting existing ones is clumsy.
*   **Signal Complexity:** Deciding which signals to trap (EXIT, INT, TERM, HUP) and handling their differences is error-prone.
*   **EXIT vs. Signals:** The `EXIT` trap behavior varies (e.g., inside command substitutions) and doesn't always catch termination signals.
*   **Double Execution:** Registering for both `EXIT` and specific signals can lead to actions running twice (or not at all).
*   **Exit Status:** Preserving the correct exit code (especially `128 + SIGNUM` for signals) requires boilerplate code (`trap - SIG; kill -SIG $$`).
*   **Function Scope:** There is only one global `RETURN` trap. Inner functions overwriting it break the outer function's cleanup logic.

`L_finally` abstracts these problems away, giving you a clean, stack-based API.

## Key Features

*   **Guaranteed Execution:** Actions registered with `L_finally` run when the script exits, no matter the cause (success, error, or signal).
*   **Function-Scoped Cleanup:** Use `L_finally -r` to bind cleanup to the *current function's return*.
*   **Stack-Based Order:** Actions execute in **reverse order** of registration (LIFO), ensuring dependencies are cleaned up correctly (e.g., delete file before removing directory).
*   **Manual Control:**
    *   `L_finally_pop`: Remove and run the most recent action immediately.
    *   `L_finally_pop -n`: Remove the most recent action *without* running it (useful for "commit" logic).
*   **Correct Exit Codes:** Preserves the exit status as `WIFSIGNALED` reports, ensuring parent processes know why the script died.
*   **Safety:** Detects double-signal loops (e.g., spamming Ctrl+C) and terminates gracefully.

## Usage Guide

### 1. Basic Script Cleanup
Register commands to run when the script exits.

```bash
# Create a temporary file
tmpf=$(mktemp)

# Register cleanup immediately
L_finally rm -f "$tmpf"

# Use the file
echo "data" > "$tmpf"
# ... script continues ...

# When the script ends (or is killed), 'rm -f' runs automatically.
```

### 2. Function-Scoped Cleanup (`-r`)
Use the `-r` flag to execute the action when the *function returns*.

```bash
process_data() {
  local work_dir=$(mktemp -d)
  # Cleanup work_dir when this function returns
  L_finally -r rm -rf "$work_dir"

  # Do work...
  if [[ -f "$work_dir/error" ]]; then
    return 1 # Cleanup runs here
  fi
  
  # ...
  # Cleanup runs here automatically at end of function
}
```

### 3. Conditional Cleanup (Pop)
Sometimes you only want to cleanup on failure, or you want to "commit" a result.

```bash
prepare_file() {
  local tmpf=$(mktemp)
  L_finally rm -f "$tmpf" # Remove if we fail early

  generate_data > "$tmpf" || return 1 # 'rm' runs if this returns

  # Success! Move the file to its final location.
  mv "$tmpf" "./final_output.txt"
  
  # We don't need the cleanup anymore, and we don't want to run it.
  L_finally_pop -n
}
```

### 4. Custom Signal Handlers
You can still use custom traps while `L_finally` manages the rest. Call `L_finally` (no args) first to initialize the unified handler.

```bash
# Initialize L_finally logic for this process
L_finally

increase_volume() { echo "Volume up!"; }

# Register custom handler for specific signal
trap 'increase_volume' USR1

# Usage:
# kill -USR1 $$  -> Prints "Volume up!", script continues.
# kill -TERM $$  -> L_finally cleanup runs, script exits.
```

## Internal Variables
Inside an `L_finally` handler (the command you registered), you can access:

*   `L_SIGNAL`: Name of the received signal (e.g., `SIGINT`), `EXIT`, or `RETURN`.
*   `L_SIGNUM`: Number of the received signal.
*   `L_SIGRET`: The exit code (`$?`) at the moment the trap was triggered.

> **Note:** Do not use `return` in a top-level `L_finally` action; it only returns from the handler, not the script.

---

# Generated documentation from source:

::: bin/L_lib.sh finally