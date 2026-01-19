# L_proc - Process Management (Better than coproc)

Manage multiple child processes with separate stdin/stdout/stderr streams - like Python's `subprocess.Popen()`.

## Why L_proc?

Bash's built-in `coproc` has severe limitations:
- **Only one coproc at a time** - can't manage multiple processes
- Awkward syntax and variable naming
- Limited control over process lifecycle

`L_proc` solves this with Python-style process management, letting you:
- Run **multiple processes simultaneously**
- Read and write to each process independently
- Wait for specific processes or all at once
- Get exit codes reliably
- Send signals to processes
- Query process state (PID, command, exit code)

## Quick Start

```bash
#!/bin/bash
. L_lib.sh

# Start a process you can communicate with
L_proc_popen proc python3 -u -c '
import sys
for line in sys.stdin:
    print(f"Python received: {line.strip()}", flush=True)
'

# Write to process stdin
echo "Hello from Bash" >&"${proc[stdin]}"

# Read from process stdout
read -r response <&"${proc[stdout]}"
echo "Got: $response"

# Clean up
L_proc_kill "$proc"
```

## Core Functions

### L_proc_popen - Start a Process

```bash
# Start a process
L_proc_popen myproc command arg1 arg2

# Access file descriptors
echo "input data" >&"${myproc[stdin]}"   # Write to stdin
read -r output <&"${myproc[stdout]}"     # Read from stdout
read -r errors <&"${myproc[stderr]}"     # Read from stderr

# Get process information
pid="${myproc[pid]}"
cmd="${myproc[cmd]}"
```

### L_proc_communicate - Send Input and Capture Output

```bash
L_proc_popen proc ./my_script.sh

# Send input and capture all output
input="some data"
L_proc_communicate proc "$input"

# Process output is now available
echo "stdout: ${proc[stdout_data]}"
echo "stderr: ${proc[stderr_data]}"
echo "exit code: ${proc[exitcode]}"
```

### L_proc_wait - Wait for Completion

```bash
# Start multiple processes
L_proc_popen proc1 sleep 5
L_proc_popen proc2 sleep 3

# Wait for specific process
L_proc_wait proc2
echo "proc2 finished with exit code: ${proc2[exitcode]}"

# proc1 is still running...
L_proc_wait proc1
```

### L_proc_kill - Terminate Process

```bash
L_proc_popen proc some_long_running_command

# Send SIGTERM (default)
L_proc_kill proc

# Send specific signal
L_proc_kill proc SIGKILL
```

## Practical Examples

### Run Multiple Processes in Parallel

```bash
#!/bin/bash
. L_lib.sh

# Start multiple workers
declare -a workers
for i in {1..5}; do
	L_proc_popen worker bash -c "sleep $i; echo \"Worker $i done\""
	workers+=("$worker")
done

# Wait for all to complete
for proc in "${workers[@]}"; do
	L_proc_wait "$proc"
	echo "Exit code: ${!proc[exitcode]}, Output: $(cat <&${!proc[stdout]})"
done
```

### Interactive Process Communication

```bash
#!/bin/bash
. L_lib.sh

# Start an interactive Python session
L_proc_popen py python3 -i -u

# Send commands
echo "x = 42" >&"${py[stdin]}"
echo "print(x * 2)" >&"${py[stdin]}"

# Read response
read -r result <&"${py[stdout]}"
echo "Python calculated: $result"  # Output: 84

# Cleanup
echo "exit()" >&"${py[stdin]}"
L_proc_wait py
```

### Pipeline with Error Handling

```bash
#!/bin/bash
. L_lib.sh
set -e

# Start a data processor
L_proc_popen processor ./process_data.py
L_finally -r L_proc_kill processor  # Cleanup on exit

# Send data
for file in data/*.txt; do
	cat "$file" >&"${processor[stdin]}"

	# Check for errors
	if read -t 1 -r error <&"${processor[stderr]}"; then
		L_error "Processor error: $error"
		exit 1
	fi
done

# Close stdin to signal end of input
exec {processor[stdin]}>&-

# Wait and get final output
L_proc_wait processor
if ((processor[exitcode] != 0)); then
	L_error "Processor failed with exit code ${processor[exitcode]}"
	exit 1
fi

cat <&"${processor[stdout]}"
```

### Example from Documentation

This example shows starting multiple processes and collecting their results:

```bash
#!/bin/bash
. L_lib.sh

# Ensure cleanup on exit
L_finally wait
L_finally L_kill_all_childs

# Start multiple processes
childs=()
for script in 'sleep 1 && exit 1' 'sleep 2; exit 2' 'sleep 3; exit 3'; do
	L_proc_popen tmp bash -c "$script"
	childs+=("$tmp")
done

# Wait for each and report results
for i in "${childs[@]}"; do
	L_proc_wait "$i"
	echo "Process [$(L_proc_get_cmd "$i")] pid $(L_proc_get_pid "$i") exited with $(L_proc_get_exitcode "$i")"
done
```

## Helper Functions

- `L_proc_get_pid <proc>` - Get process PID
- `L_proc_get_cmd <proc>` - Get command that was executed
- `L_proc_get_exitcode <proc>` - Get exit code (after wait)
- `L_proc_is_running <proc>` - Check if process is still running
- `L_kill_all_childs` - Terminate all child processes

## Comparison with coproc

| Feature | `coproc` | `L_proc` |
|---------|----------|----------|
| Multiple processes | No (only 1) | Yes (unlimited) |
| Separate stderr | No | Yes |
| Process management | Limited | Full (wait, kill, query) |
| Exit code retrieval | Difficult | Easy |
| Named variables | Awkward | Clean array syntax |

::: bin/L_lib.sh proc
