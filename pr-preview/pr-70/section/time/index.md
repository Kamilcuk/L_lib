# Time Utilities

Functions for managing time, parsing and formatting durations, and implementing timeout-based operations.

## Usage Guide

### Measuring Command Execution Time

Use `L_time` to measure and print execution time of a command.

```
L_time sleep 1
# Output:
# real=0m1.002581s user=0m0.002502s system=0m0.000000s [sleep 1]
```

### Parsing and Converting Durations

Convert duration strings to microseconds with `L_duration_to_usec`, or convert microseconds back to duration strings with `L_usec_to_duration`.

```
# Parse 5m30s to microseconds (using -v to store in variable)
L_duration_to_usec -v usec "5m30s"
echo "Microseconds: $usec" # 330000000

# Or capture stdout
usec=$(L_duration_to_usec "5m30s")
echo "Microseconds: $usec" # 330000000

# Convert back to Prometheus duration string (using -v)
L_usec_to_duration -v dur 330000000
echo "Duration: $dur" # 5m30s

# Or capture stdout
dur=$(L_usec_to_duration 330000000)
echo "Duration: $dur" # 5m30s
```

### Date Formatting

Use `L_date` for date formatting, supporting `%f` (microseconds) and subsecond timepoints. It selects the optimal method based on available capabilities and the format string.

```
# Print current time with microseconds (using -v to store in variable)
L_date -v dt "%Y-%m-%d %H:%M:%S.%f"
echo "$dt"

# Or capture stdout
dt=$(L_date "%Y-%m-%d %H:%M:%S.%f")
echo "$dt"

# Format a specific unix timestamp (using -v)
L_date -v dt "%H:%M:%S" 1700000000
echo "$dt"

# Or capture stdout
dt=$(L_date "%H:%M:%S" 1700000000)
echo "$dt"
```

### Microsecond Epoch Time

Retrieve the current epoch time in microseconds. It works across different environments and Bash versions, including those where the native `${EPOCHREALTIME}` variable is not available.

```
# Using -v to store in variable
L_epochrealtime_usec -v usec
echo "Current epoch (usec): $usec"

# Or capture stdout
usec=$(L_epochrealtime_usec)
echo "Current epoch (usec): $usec"
```

### Timeouts

Implement timeouts with helper functions:

```
# Initialize a 5-second timeout variable
L_timeout_init_into timeout 5

while ! L_timeout_is_expired "$timeout"; do
    # Perform some task...
    L_timeout_left -v left "$timeout"
    echo "Time remaining: $left seconds"
    sleep 0.5
done
```

## API Reference

## time

### L_time

Measure time with the command, but include the command in the time message output and use %6l format.

**Argument:** **`$@`** command to measure.

### L_duration_to_usec

Parse 1y2w3d4h5m6s7ms8us or 1y2w3d4h5m6.789s or 1.234 into number of microseconds.

**Option:** **`-v <var>`**

**Argument:** **`$1`** Duration string.

**See:** <https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file>

### L_duration_to_usec_vL_RET

**Shellcheck disable=** [SC2211](https://www.shellcheck.net/wiki/SC2211) [SC2035](https://www.shellcheck.net/wiki/SC2035) [SC2035](https://www.shellcheck.net/wiki/SC2035) [SC1102](https://www.shellcheck.net/wiki/SC1102)

### L_usec_to_duration

Convert microseconds to Prometheus duration string using L_RET.

**Option:** **`-v <var>`**

**Argument:** **`$1`** Microseconds (integer).

### L_usec_to_duration_vL_RET

### L_date

Print date in the format.

If the format string contains %N or the timepoint is not a number, use date command. Otherwise, try to use printf %(fmt)T.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and exit.

**Arguments:**

- **`$1`** Format string, without leading +.
- **`[$2]`** Optional timepoint in seconds with optional digit or any date understood format.

### L_date_vL_RET

### L_epochrealtime_usec

Return time in microseconds.

The dot or comma is removed from EPOCHREALTIME. Uses EPOCHREALTIME in newer Bash. In older Bash tries GNU date, gdate, perl, /proc/uptime, python, busybox adjtimex.

**Option:** **`-v <var>`**

### L_epochrealtime_usec_vL_RET

### L_sec_to_usec

Convert float seconds to microseconds.

Example

```
L_sec_to_usec 1.5 -> 1500000
```

**Option:** **`-v <var>`**

### L_sec_to_usec_vL_RET

### L_usec_to_sec

Convert microseconds to seconds with 6 digits after comma.

**Option:** **`-v <var>`**

### L_usec_to_sec_vL_RET

### L_timeout_init_into

Calculate timeout value.

The timeout value is stored in microseconds.

**Arguments:**

- **`$1`** Variable to assign with the timeout value in usec.
- **`$2`** Timeout in seconds. May be a fraction.

**See:** [L_epochrealtime_usec](#L_lib.sh--L_epochrealtime_usec)

### L_timeout_init_usec_into

Initialize a timer with a timeout in microseconds.

**Arguments:**

- **`$1`** Variable to assign with the timeout value in usec.
- **`$2`** Timeout in microseconds.

### L_timeout_is_expired

Is the timeout expired?

**Argument:** **`$1`** timeout value in usec.

### L_timeout_left_usec

Get the number of microseconds left in the timer.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** timeout value in usec.

### L_timeout_left_usec_vL_RET

### L_timeout_left

Get the number of seconds left in the timer.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** timeout value in usec.

### L_timeout_left_vL_RET
