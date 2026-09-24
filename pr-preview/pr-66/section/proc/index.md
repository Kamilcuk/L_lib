This section contains functions related to handling co-processes. The Bash builtin `coproc` is missing features, in particular there may be only one coproc open at any time.

This library comes with `L_proc_popen` which allows to open any number of child processes for writing and reading.

## Usage Guide

The core function is `L_proc_popen`. It launches a command asynchronously (like `coproc`) but gives you a handle to manage it. This handle is the PID of the process, stored in the variable you provide.

### Basic Interaction

The most common use case is opening a process, writing to it, and reading from it.

```
# Open a process (cat) that reads from stdin and writes to stdout
# -I pipe: We want to write to its stdin
# -O pipe: We want to read from its stdout
L_proc_popen -I pipe -O pipe pid cat

# Write to the process's stdin
L_proc_printf "$pid" "Hello World\n"

# Close stdin to signal EOF to the process (cat will then finish and exit)
L_proc_close_stdin "$pid"

# Read the process's output
L_proc_read "$pid" line
echo "Got: $line"

# Wait for the process to clean up
L_proc_wait "$pid"
```

### Input/Output Modes

`L_proc_popen` is powerful because it allows precise control over standard input (`-I`), output (`-O`), and error (`-E`) streams. You can mix and match these modes.

#### Pipe (Default for interaction)

Use `pipe` when you want to interact with the stream using `L_proc_printf`, `L_proc_read`, or `L_proc_communicate`.

```
L_proc_popen -I pipe -O pipe -E pipe pid my_command
# Now you can write to proc stdin, and read from proc stdout and stderr
```

#### Fixed Input String

Use `-I input` with `-i "string"` to pass a fixed string to the process's stdin immediately. This is useful when you don't need to interactively write to the process.

```
# Pass "hello" to grep's stdin
L_proc_popen -I input -i "hello" -O pipe pid grep "h"
L_proc_communicate -o output "$pid"
echo "$output" # hello
```

#### File Redirection

Redirect streams directly to or from files using `file`. This avoids the overhead of reading/writing in the shell.

```
# Write stdout directly to a file
L_proc_popen -O file -o "/tmp/output.log" pid echo "log entry"
L_proc_wait "$pid"
cat /tmp/output.log
```

```
# Read stdin directly from a file
echo "data" > /tmp/input.txt
L_proc_popen -I file -i "/tmp/input.txt" -O pipe pid cat
L_proc_communicate -o output "$pid"
```

#### Discarding Output (Null)

Use `null` to redirect a stream to `/dev/null`.

```
# Ignore stderr
L_proc_popen -O pipe -E null pid command_with_noisy_stderr
```

#### Closing Streams

Use `close` to completely close the file descriptor for the process.

```
# Process will receive "Bad file descriptor" if it tries to write to stdout
L_proc_popen -O close pid echo "this will fail"
```

#### Existing File Descriptors

Use `fd` to connect streams to existing file descriptors open in your current shell.

```
# Connect process stderr to the current shell's stderr (pass-through)
L_proc_popen -E fd -e 2 pid my_command
```

### Automatic Cleanup

You can register a "finally" trap to ensure the process is waited upon when your function returns, preventing zombie processes.

```
my_func() {
    # -W 0 registers a cleanup handler for the current stack level
    L_proc_popen -W 0 -I pipe -O pipe pid sleep 10
    # Even if we return early or error out here, the process will be cleaned up
}
```

### Managing Multiple Processes

Since `L_proc_popen` uses variables to store PIDs, you can manage multiple processes easily using arrays.

```
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
```

## API Reference

## proc

Processes and jobs related functions.

### L_bashpid_into

Get bashpid in a way compatible with Bash before 4.0.

**Argument:** **`$1`** Variable to store the result to.

### L_raise

Send signal to itself.

**Argument:** **`$@`** Kill arguments. See kill --help.

**Shellcheck disable=** [SC2119](https://www.shellcheck.net/wiki/SC2119) [SC2120](https://www.shellcheck.net/wiki/SC2120)

### L_kill_all_jobs

### L_wait_all_jobs

### L_get_all_childs

Get all pids of all child processes including grandchildren recursively.

**Option:** **`-v <var>`**

**Argument:** **`[$1]`** Pid of the parent. Default: $BASHPID.

**See:** <https://stackoverflow.com/a/52544126/9072753>

### L_get_all_childs_vL_RET

**Shellcheck disable=** [SC2207](https://www.shellcheck.net/wiki/SC2207)

### L_kill_all_childs

Kills all childs of the pid recursive.

**Arguments:**

- **`-sigspec`** Signal to use.
- **`[$1]`** Pid of the process to kill all childs of. Defualt: $BASHPID

### L_is_fd_open

Check if file descriptor is open.

**Argument:** **`$1`** file descriptor

**Shellcheck disable=** [SC2188](https://www.shellcheck.net/wiki/SC2188)

### L_get_free_fd_into

Get free file descriptors

Note

No valid variable name check is done on .

**Arguments:**

- **`<var>`** Variable to assign file descriptors to.
- **`[int]`** Number of array elements to assign.

### L_mktemp

Create a temporary file natively in Bash.

This avoids the overhead of calling the mktemp utility. Performance: ~2x faster than 'mktemp' utility by avoiding subshells and external binary execution. No L_mktemp -d, cause mktemp -d is faster then shell implementation. It uses 'set -C' (noclobber) for atomic file creation.

Example

```
L_mktemp -v tmp
echo "data" > "$tmp"
rm "$tmp"
```

**Option:** **`-v <var>`** variable name to assign result to

**Argument:** **`[str]`** template temporary filename, default: ${TMPDIR:/tmp}/L_mktemp.XXXXXXXXXX

### L_mktemp_vL_RET

**Shellcheck disable=** [SC2188](https://www.shellcheck.net/wiki/SC2188)

### L_pipe

Open two connected file descriptors.

This internally creates a temporary file with mkfifo. It avoids the overhead of calling the mktemp utility. The result variable is assigned an array that:

- [0] element is the output from the pipe (read end),
- [1] element is the input to the pipe (write end). This is meant to mimic the pipe() C function.

Example

```
L_pipe tmp
L_array_extract tmp out in
echo 123 >&"$in"
exec "$in">&-
cat <&"$out"
exec "$out"<&-
```

**Arguments:**

- **`<var>`** variable name to assign result to
- **`[str]`** template temporary filename, default: ${TMPDIR:/tmp}/L_pipe.XXXXXXXXXX

### L_mkstemp

Open file descriptors read-write connected to a deleted temporary file.

This internally creates a temporary file and immidately removes it.

**Arguments:**

- var Variable to assign file descriptors to.
- **`[int]`** Number of array elements to assign.

**Shellcheck disable=** [SC2093](https://www.shellcheck.net/wiki/SC2093) [SC2102](https://www.shellcheck.net/wiki/SC2102)

### L_close_fd

Note

No checking is performed.

**Argument:** **`<int..>`** File descriptors to close.

**Shellcheck disable=** [SC2294](https://www.shellcheck.net/wiki/SC2294)

### L_proc_popen

Process open. Coproc replacement.

The input/output options are in three groups:

- -I and -i for stdin,
- -O and -o for stdout,
- -E and -e for stderr.

Uppercase letter option specifies the mode for the file descriptor.

There are following modes available that you can give to uppercase options -I -O and -E:

- null - redirect to or from /dev/null
- close - close the file descriptor >&-
- input - -i specifies the string to forward to stdin. Only allowed for -I.
- stdout - connect file descriptor to stdout. -o or -e value are ignored.
- stderr - connect file descriptor to stderr. -o or -e value are ignored.
- pipe - create a fifo and connect file descriptor to it. -i -o or -e option specifies part of the temporary filename.
- file - connect file descriptor to file specified by -i -o or -e option
- fd - connect file descriptor to another file descriptor specified by -i -o or -e option

There first argument specifies an output variable that will be assigned the PID.

Several global array variables hold additional information about the process:

- `_L_PROC_EXIT[PID]` - Exitcode or empty if not yet finished.
- `_L_PROC_FD0[PID]` - If -Ipipe the file descriptor connected to stdin of the program, otherwise empty.
- `_L_PROC_FD1[PID]` - If -Opipe the file descriptor connected to stdout of the program, otherwise empty.
- `_L_PROC_FD2[PID]` - If -Epipe the file descriptor connected to stderr of the program, otherwise empty.
- `_L_PROC_CMD[PID]` - The %q escaped command that was executed.

You should use getters `L_proc_get_*` to extract the data from them variable.

Example

```
L_proc_popen -Ipipe -Opipe -Estdout proc sed 's/w/W/g'
L_proc_printf proc "%s\n" "Hello world"
L_proc_read proc line
L_proc_wait -c -v exitcode proc
echo "$line"
echo "$exitcode"
```

**Options:**

- **`-I <mode>`** stdin mode
- **`-i <param>`** string for -Iinput, file for -Ifile, fd for -Ifd
- **`-O <mode>`** stdout mode
- **`-o <param>`** file for -Ifile, fd for -Ifd
- **`-E <mode>`** stderr mode
- **`-e <param>`** file for -Efile, fd for -Efd
- **`-n`** Dryrun mode. Do not execute the generated command. Instead print it to stdout.
- **`-W <int>`** Register with L_finally a return trap on stacklevel that will wait for the popen to finish. Typically -W 0
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** variable name to store the result to.
- **`$@`** command to execute.

### L_proc_get_exitcode

Get exitcode of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_get_exitcode_vL_RET

### L_proc_get_pid

Get PID from L_proc_popen of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_get_pid_vL_RET

### L_proc_get_stdin

Get file descriptor for stdin of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_get_stdin_vL_RET

### L_proc_get_stdout

Get file descriptor for stdout of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_get_stdout_vL_RET

### L_proc_get_stderr

Get file descriptor for stderr of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_get_stderr_vL_RET

### L_proc_get_cmd

Get command of L_proc.

**Option:** **`-v <var>`** Store the output in the array variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_get_cmd_vL_RET

### L_proc_free

### L_proc_popen_finally

Handler that can be closed from L_finally or a signal handler.

Closes file descriptors. If L_SIGNAL is a signal, forwards it to the process. Then wait for the process termination.

Example

```
L_proc_popen pid sleep infinity
L_finally L_proc_popen_finally "$pid"

# or, defer reading the variable until cleanup runs (e.g. if it may go out of scope):
L_proc_popen pid sleep infinity
L_finally L_eval 'L_proc_popen_finally "${!1}"' pid
```

**Argument:** **`$1`**

L_proc **value**. This is because the variable may go out of scope.

This is bad. when closing a file descriptor, we "remember" that the file descriptor was closed in the variable. This is less then ideal, but I do not know at this time how to fix it better. Potentially, this can cause unrelated file descriptors to get closed. This might change in the future.

### L_proc_printf

Write printf formatted string to coproc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$@`** any printf arguments

### L_proc_read

Exec read bultin with -u file descriptor of stdout of coproc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$@`** any builtin read options

### L_proc_read_stderr

Exec read bultin with -u file descriptor of stderr of coproc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$@`** any builtin read options

**See:** [L_proc_read](#L_lib.sh--L_proc_read)

### L_proc_close

Close stdin, stdout and stderr of L_proc

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_close_stdin

Close stdin of L_proc.

Does nothing if already closed or not started with -Opipe.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_close_stdout

Close stdout of L_proc.

Does nothing if already closed or not started with -Opipe

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_close_stderr

Close stderr of L_proc.

Does nothing if already closed or not started with -Epipe.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_poll

Check if L_proc is finished.

**Argument:** **`$1`** PID from L_proc_popen

**Exit:** 0 if L_proc is running, 1 otherwise

### L_wait

Wait for pids to be finished with a timeout and capture exit codes.

Tries to use waitpid or tail --pid or a busy loop for best performance.

The waiting is uninterruptible by signals.

Note: builtin kill with multiple pids has different exit code depending on posix mode.

**Options:**

- **`-t <timeout>`** Wait for this long. Timeout 0 results in just collecting all pids.
- **`-v <var>`** Exit code of PIDs will be assigned to . The elements of -v and -p arrays are pairs.
- **`-p <var>`** PIDs that exited will be assigned to array variable .
- **`-l <var>`** Left running PIDs will be assigned to array variable .
- **`-P <polltime>`** The time to poll processes when not possible to use waitpid or tail. Default: 0.1
- **`-n`** Return 0 when at least one of the pids is finished.
- **`-b`** Bash only. Do not use waitpid or tail.
- **`-h`** Print this help and exit.

**Argument:** **`$@`** pids to wait on

**Return:**

0 on success

64 ($L_EX_USAGE) usage error 124 ($L_EX_TIMEOUT) timeout

### L_proc_wait

Wait for L_proc to finish.

If L_proc has already finished execution, will only evaluate -v option.

**Options:**

- **`-t <int>`** Timeout in seconds. Will try to use waitpid, tail --pid or busy loop with sleep.
- **`-v <var>`** Store the L_proc exit code in the variable.
- **`-c`** Close L_proc file descriptors before waiting.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** PID from L_proc_popen

**Exit:**

0 if L_proc has finished

124 ($L_EX_TIMEOUT) if timeout expired

### L_read_fds

Read from multiple file descriptors at the same time.

Note

The minimum read -t argument in Bash3.2 is 1 second. It is not possible

to set it lower or to a fraction. This does not work great for Bash3.2 for short timeout, as one read takes at least 1 second to execute.

Example

```
exec 10< <(for ((i=0;i<5;++i)); do echo $i; sleep 1; done)
exec 11< <(for ((i=0;i<5;++i)); do echo $i; sleep 2; done)
L_read_fds 10 a 11 b
echo "read from 10 fd text: $a"
echo "read from 11 fd text: $b"
```

**Options:**

- **`-t <timeout>`** Timeout in seconds.
- **`-p <timeout>`** Poll timeout. The read -t argument value. Default: 0.05 or 1 in Bash3.2
- **`-h`** Print this help and return 0.
- **`-v <var>`** After first fd EOF or error, assign the fd number to and return 0.
- **`-i <var>`** After first fd EOF or error, assign the argument fd number to and return 0.
- **`-d <delim>`** Read -d argument. Default: ''
- **`-n`** Run the reading loop possible once.

**Arguments:**

- **`$1`** File descriptor to read from.

- **`$2`** Variable to assign the output of $1.

- **`$@`**

  Continued pairs of file descriptor and variable names.

  I do not like this. This should just read from two arrays and return array index.

**Return:**

0 on success

124 ($L_EX_TIMEOUT) on timeout

### L_proc_communicate

Communicate with L_proc.

Interact with process: Send data to stdin. Read data from stdout and stderr, until end-of-file is reached. Wait for process to terminate.

**Options:**

- **`-i <str>`**

  Send string to stdin.

  Note that if you want to send data to the process’s stdin, you need to create the L_proc object with -I PIPE.

- **`-o <var>`**

  Append stdout data to this variable. Variable is not cleared.

  To get anything, you need to create L_proc object with -O PIPE.

- **`-e <var>`**

  Append stderr to this variable. Variable is not cleared.

  To get anything, you need to create L_proc object with -E PIPE.

- **`-t <int>`** Timeout in seconds.

- **`-k`** Kill L_proc after communication.

- **`-v <var>`** Store the output in variable instead of printing it.

- **`-h`** Print this help and return 0.

**Argument:** **`$1`** PID from L_proc_popen

**Exit:** 0 on success. 64 ($L_EX_USAGE) on usage error. 124 ($L_EX_TIMEOUT) on timeout.

### L_proc_send_signal

Send signal to L_proc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$2`** signal to send

### L_proc_terminate

Terminate L_proc.

**Argument:** **`$1`** PID from L_proc_popen

### L_proc_kill

Kill L_proc.

**Argument:** **`$1`** PID from L_proc_popen
