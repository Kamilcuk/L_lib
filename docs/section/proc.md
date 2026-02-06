This section contains functions related to handling co-processes. The Bash builtin `coproc` is missing features, in particular there may be only one coproc open at any time.

This library comes with `L_proc_popen` which allows to open any number of child processes for writing and reading.

## Usage Guide

The core function is `L_proc_popen`. It launches a command asynchronously (like `coproc`) but gives you a handle to manage it. This handle is the PID of the process, stored in the variable you provide.

### Basic Interaction

The most common use case is opening a process, writing to it, and reading from it.

```bash
# Open a process (cat) that reads from stdin and writes to stdout
# -I pipe: We want to write to its stdin
# -O pipe: We want to read from its stdout
L_proc_popen -I pipe -O pipe proc cat

# Write to the process's stdin
L_proc_printf "$proc" "Hello World\n"

# Close stdin to signal EOF to the process (cat will then finish and exit)
L_proc_close_stdin "$proc"

# Read the process's output
L_proc_read "$proc" line
echo "Got: $line"

# Wait for the process to clean up
L_proc_wait "$proc"
```

### Input/Output Modes

`L_proc_popen` is powerful because it allows precise control over standard input (`-I`), output (`-O`), and error (`-E`) streams. You can mix and match these modes.

#### Pipe (Default for interaction)

Use `pipe` when you want to interact with the stream using `L_proc_printf`, `L_proc_read`, or `L_proc_communicate`.

```bash
L_proc_popen -I pipe -O pipe -E pipe proc my_command
# Now you can write to proc stdin, and read from proc stdout and stderr
```

#### Fixed Input String

Use `-I input` with `-i "string"` to pass a fixed string to the process's stdin immediately. This is useful when you don't need to interactively write to the process.

```bash
# Pass "hello" to grep's stdin
L_proc_popen -I input -i "hello" -O pipe proc grep "h"
L_proc_communicate -o output "$proc"
echo "$output" # hello
```

#### File Redirection

Redirect streams directly to or from files using `file`. This avoids the overhead of reading/writing in the shell.

```bash
# Write stdout directly to a file
L_proc_popen -O file -o "/tmp/output.log" proc echo "log entry"
L_proc_wait "$proc"
cat /tmp/output.log
```

```bash
# Read stdin directly from a file
echo "data" > /tmp/input.txt
L_proc_popen -I file -i "/tmp/input.txt" -O pipe proc cat
L_proc_communicate -o output "$proc"
```

#### Discarding Output (Null)

Use `null` to redirect a stream to `/dev/null`.

```bash
# Ignore stderr
L_proc_popen -O pipe -E null proc command_with_noisy_stderr
```

#### Closing Streams

Use `close` to completely close the file descriptor for the process.

```bash
# Process will receive "Bad file descriptor" if it tries to write to stdout
L_proc_popen -O close proc echo "this will fail"
```

#### Existing File Descriptors

Use `fd` to connect streams to existing file descriptors open in your current shell.

```bash
# Connect process stderr to the current shell's stderr (pass-through)
L_proc_popen -E fd -e 2 proc my_command
```

### Automatic Cleanup

You can register a "finally" trap to ensure the process is waited upon when your function returns, preventing zombie processes.

```bash
my_func() {
    # -W 0 registers a cleanup handler for the current stack level
    L_proc_popen -W 0 -I pipe -O pipe proc sleep 10
    # Even if we return early or error out here, the process will be cleaned up
}
```

### Managing Multiple Processes

Since `L_proc_popen` uses variables to store handles, you can manage multiple processes easily using arrays.

```bash
--8<-- "scripts/proc_example.sh"
```

## API Reference

::: bin/L_lib.sh proc