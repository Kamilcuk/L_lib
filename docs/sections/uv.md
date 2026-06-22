# L_uv: High-Performance Bash Event Loop

`L_uv` is an event loop implementation for Bash, inspired by libuv. It allows you to poll for events, in particular for timers, file descriptors, and child processes asynchronously within a single Bash process.


````bash

# 1. Initialize the event loop state
L_uv_init

# 2. Create a background process with a pipe
L_pipe pipe_fds
L_array_extract pipe_fds read_fd write_fd
( while true; do echo "SERVICE_HEARTBEAT"; sleep 1; done >&"$write_fd" ) & bg_pid=$!
# Close the write end in the parent, the child process will keep it open.
exec "$write_fd"> T&-

# 3. Define callbacks
reader_cb() {
  echo "[READER]: Received data: $2"
}

waiter_cb() {
  echo "[WAITER]: Service PID $1 exited with code $2."
  # The read FD is closed automatically by the -c flag.
}

stoptimer_cb() {
  echo "[TIMER]: 5s elapsed. Sending SIGTERM to service."
  kill "$bg_pid" 2>/dev/null || :
}

# 4. Add handles to the loop
L_uv_add_reader -c -v reader_id "$read_fd" reader_cb
L_uv_add_waiter -v waiter_id "$bg_pid" waiter_cb
L_uv_add_timer -d 5 stoptimer_cb # One-shot timer after 5s

# 5. Run the loop
echo "Event loop started. Monitoring service PID $bg_pid..."
L_uv_run
echo "Event loop finished."
````

**Expected Output:**

````
Event loop started. Monitoring service PID 34567...
[READER]: Received data: SERVICE_HEARTBEAT
[READER]: Received data: SERVICE_HEARTBEAT
[READER]: Received data: SERVICE_HEARTBEAT
[READER]: Received data: SERVICE_HEARTBEAT
[TIMER]: 5s elapsed. Sending SIGTERM to service.
[WAITER]: Service PID 34567 exited with code 143.
Event loop finished.
````

## Common Usage Examples

This section demonstrates the most frequent usage patterns. For complete option flags, please refer to the in-code documentation.

### Starting and Stopping the Loop
Always initialize the state before adding handles. The loop continues until all handles are removed or `L_uv_break` is called.

```bash
L_uv_init
# ... add handles ...
L_uv_run
```

### Repeating Timers
Timers are the core of time-based scheduling. 

```bash
count=0
tick() {
  echo "Tick $((++count))"
  if (( count >= 5 )); then
    L_uv_current_remove # Remove this specific timer
  fi
}
# Start immediately (no -d), repeat every 0.5s
L_uv_add_timer -r 0.5 tick
L_uv_run

# Expected Output:
# Tick 1
# Tick 2
# Tick 3
# Tick 4
# Tick 5
```

### Reading from Pipes
`L_uv` allows you to monitor file descriptors asynchronously. Use the `-c` flag with `L_uv_add_reader` to automatically close the file descriptor when the reader handle is removed.

```bash
L_pipe p
L_array_extract p read_fd write_fd

# Background writer
( sleep 1; echo "Message 1"; sleep 1; echo "Message 2" ) >&"$write_fd" &
exec "$write_fd"> T&- # Close write end in parent

process_message() {
  local fd=$1 line=$2
  echo "Received: $line"
  # Stop after receiving the second message
  [[ "$line" == *"Message 2"* ]] && L_uv_break
}
L_uv_add_reader -c -v reader_id "$read_fd" process_message
L_uv_run

# Expected Output:
# Received: Message 1
# Received: Message 2
```

### Reaping Background Processes
Waiters allow you to react when a child process exits, capturing its exit code without blocking the main script.

```bash
sleep 2 & bg_pid=$!

on_exit() {
  local pid=$1 exit_code=$2
  echo "Process $pid finished with code $exit_code"
  L_uv_break # Stop the loop
}
L_uv_add_waiter "$bg_pid" on_exit
L_uv_run

# Expected Output (after 2 seconds):
# Started background sleep with PID 12345.
# Process 12345 finished with code 0
```

### High-Frequency Tasks
Tasks execute on every iteration of the loop. They are useful for continuous polling but can consume CPU if not managed.

```bash
poll_sensor() {
  # Perform a fast, non-blocking check
  if [[ -f /tmp/sensor_ready ]]; then
    echo "Sensor is ready!"
    L_uv_current_remove
  fi
}
L_uv_add_task poll_sensor

# Add a timer to simulate the sensor becoming ready after 2s
L_uv_add_timer -d 2 'touch /tmp/sensor_ready'
# Add a timer to stop the loop
L_uv_add_timer -d 3 L_uv_break

rm -f /tmp/sensor_ready
L_uv_run

# Expected Output (after 2 seconds):
# Sensor is ready!
```

### Handling Signals
The `L_uv` functions (such as `L_uv_add_timer`, `L_uv_remove`, etc.) are **not signal-safe or reentrant**. For example, if a signal interrupts the internal timer heap modification and the trap handler also attempts to register a new timer, the internal memory structures will almost certainly become corrupted. Therefore, you must never manipulate the loop state directly from within a Bash `trap` handler.

Instead, trap handlers should only set state variables or call `L_uv_poke` to wake up the loop. You can then use a persistent task (`L_uv_add_task`) to poll those variables safely outside of the interrupt context.

**Signal Responsiveness**
By default, the event loop's waiting functions (`waitpid`, `sleep`, `read`) are blocking calls. While an external process execution blocks the loop, Bash will not process signals from the queue. To ensure signals are handled in a timely fashion, the loop must be prevented from blocking indefinitely.

This is achieved by forcing the optimizer to choose a "capped" delayer. By registering a minimal, empty task:
```bash
L_uv_add_task :
```
You ensure the loop will wake up at least every 50ms (the default cap) to process pending signals or other events.

*(Note on `L_uv_run -c`)*: The `-c` option registers a `SIGCHLD` trap that calls `L_uv_poke`. This is mildly useful to skip the 50ms delay when a child exits. However, because Bash lacks `sigprocmask` (signal blocking), a race condition exists: if the signal is received exactly between the loop checking the poked flag and entering the `sleep` command, the loop will still sleep. It is generally not advertised or recommended for critical logic.

### Replacing Callbacks
You can change a handle's behavior dynamically from within its own execution context.

```bash
phase_two() { echo "Phase two complete."; L_uv_current_remove; }
phase_one() { echo "Phase one complete."; L_uv_current_set phase_two; }

L_uv_add_timer -r 1 phase_one
L_uv_run

# Expected Output:
# Phase one complete.
# Phase two complete.
```



---

## Programmer Documentation: Internals

### Architectural Rationale

The design of `L_uv` is the result of several core architectural decisions aimed at maximizing performance and compatibility within the Bash environment.

#### The Single Global `L_UV` Array
A single global array, `L_UV`, is used to hold all state. This simplifies usage, as it avoids the need to pass a loop context variable to every function. Alternative methods, such as `nameref` or `eval`-based indirection, would break compatibility with older Bash versions.

This design also allows for nested loops. A function can declare a `local L_UV` to create a fresh, scoped event loop. The state of an outer loop can be preserved and restored by using `L_array_copy` to copy the `L_UV` array to a temporary variable and back.

#### Registration vs. Running Stage
An early design conflict was whether to register all callbacks at once via arguments to `L_uv_run`, or to provide a unified `L_uv_add_*` interface. The `add` interface was chosen for its flexibility and clarity.

This creates two distinct phases:
1.  **Registration Stage**: Before `L_uv_run` is called, the `L_uv_add_*` functions populate the `L_UV` array with handle data.
2.  **Running Stage**: After `L_uv_run` is called, functions like `L_uv_break`, `L_uv_poke`, and `L_uv_current_*` become meaningful as they interact with the active loop.

#### `L_UV` Memory Layout and Performance
The `L_UV` array emulates an array of structs by using large integer offsets for each handle type (e.g., `ID * X + N`). Bash internally uses three pointers for sparse arrays: `first`, `last`, and `lastref` (last referenced index). To optimize lookup speed, struct-like members for a given handle are placed at adjacent indexes with the intention of improving data locality.

- The **optimizer flag (`L_UV[1]`)** is placed first for fast access on every loop iteration.
- **Task callbacks** are placed at the end of the array (`99,000,000+`) to leverage the fast `${L_UV[*]:99000000}` expansion, which retrieves all subsequent elements without needing to store a separate task counter.

#### High-Performance Lookups & Data Structures
- **Timer Heap**: To efficiently find the next timer to fire, timer handles are organized in a min-heap structure within the `L_UV` array. This provides fast access to the timer with the lowest timeout.
- **PID-to-Waiter Hash Map**: To quickly map an exited PID to its callback, `L_uv` uses a hash map bucket system (at offset `29,000,000`). This gives an $O(1)$ lookup, avoiding a slow linear scan through all registered waiters.
- **Pre-built PID List**: A space-separated list of all active waiter PIDs is maintained (at index `20000002`) for efficient batch syscalls like `kill -0 $pids` and `wait -n $pids`.

#### Handle ID Management
"Next available ID" counters for each handle type allow for fast insertions. These counters can wrap around after 1 million registrations, so the same ID can be reused over the lifetime of a long-running script. There is an absolute limit of 1 million concurrent handles *of each type* (1M timers, 1M waiters, etc.), though Bash array access performance will degrade significantly before these limits are reached.

#### The Optimizer
The optimizer (`_L_uv_run_optimizer`) is used to pre-calculate the loop's behavior. If multiple handles are added or removed within a single iteration of the `L_uv_run` loop, the optimizer is still only run *once*. This simplifies the optimization logic and is faster than re-evaluating on every single modification.

### Full Memory Architecture
Each handle type is allocated from a block of 1 million slots. The maximum number of concurrent timers, readers, waiters, or tasks is 1 million each.

| Index Range | Description | Handle Type |
| :--- | :--- | :--- |
| `1` | Optimizer State Flag (0=Dirty, 1=Optimized) | Core |
| `10000000` | Next available Timer ID (relative) | Timer |
| `11000000` | Timer Min-Heap metadata (size at base) | Timer |
| `11000001+` | Timer Min-Heap elements (`expiry_usec:TID`) | Timer |
| `12000000 + (TID*3) + 0` | Timer: User callback string | Timer |
| `12000000 + (TID*3) + 1` | Timer: Repeat interval (usec) | Timer |
| `12000000 + (TID*3) + 2` | Timer: Heap inverse map pointer | Timer |
| `20000000` | Next available Waiter ID (relative) | Waiter |
| `20000001` | Active Waiter IDs cache (` rel_id `) | Waiter |
| `20000002` | List of space-separated PIDs | Waiter |
| `21000000 + (WID*2) + 0` | Waiter: User callback string | Waiter |
| `21000000 + (WID*2) + 1` | Waiter: PID to monitor | Waiter |
| `29000000 + (PID % 1M)` | **PID-to-WID Hash Map Bucket** | Waiter |
| `30000000` | Next available Reader ID (relative) | Reader |
| `30000001` | Active Reader IDs cache (` rel_id `) | Reader |
| `31000000 + (RID*4) + 0` | Reader: User callback string | Reader |
| `31000000 + (RID*4) + 1` | Reader: Separator (delimiter) | Reader |
| `31000000 + (RID*4) + 2` | Reader: File descriptor (FD) | Reader |
| `31000000 + (RID*4) + 3` | Reader: Accumulation buffer | Reader |
| `90000000 + TID` | `L_finally` index for resource cleanup | Core |
| `99000000 - 99999999` | User task callbacks | Task |

### The 7-Delayer Strategy
`L_uv` uses an optimized decision tree to select the most efficient waiting method (the "delayer") for the current state.

| Case            | Active Handles     | Wait Method          | Timeout            |
| :-------------- | :----------------- | :------------------- | :----------------- |
| **Single Reader** | 1 FD               | `read -u FD`         | Indefinite         |
| **Single Waiter** | 1 PID              | `wait -n` / `waitpid` / `tail --pid`  | Indefinite         |
| **Single Timer**  | Timers             | `L_sleep`            | Next Timer         |
| **Reader + Timer**| 1 FD + Timers      | `read -t $timer -u FD` | Next Timer         |
| **Waiter + Timer**| PID + Timers       | `waitpid -t $timer` / `timeout $timer tail`    | Next Timer         |
| **Capped Reader** | Multi-FD or Tasks  | `read -t 0.05 -u FD`   | min(Timer, 50ms)   |
| **Capped Waiter** | Tasks + Waiter     | `waitpid -t 0.05` / `timeout 0.05 tail`      | min(Timer, 50ms)   |

### Nested `L_uv_run` Usage
It is possible to call `L_uv_run` from within a callback of another `L_uv_run` instance. 

**Behavior**: The outer loop is effectively paused. A new, independent inner loop starts and will run until it is empty or broken. Once the inner loop completes, control returns to the outer loop's callback.

**Warning**: This should be used with caution. Handles from the outer loop (timers, readers, etc.) will **not** be serviced while the inner loop is running. This can be useful for modal dialogs or sub-tasks that must complete before the main loop continues, but can also lead to unexpected latency if not managed carefully.
