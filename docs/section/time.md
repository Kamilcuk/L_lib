# Time Utilities

Functions for managing time, parsing and formatting durations, and implementing timeout-based operations.

## Usage Guide

### Measuring Command Execution Time

Use `L_time` to measure and print execution time of a command.

```bash
L_time sleep 1
# Output:
# real=0m1.002581s user=0m0.002502s system=0m0.000000s [sleep 1]
```

### Parsing and Converting Durations

Convert duration strings to microseconds with `L_duration_to_usec`, or convert microseconds back to duration strings with `L_usec_to_duration`.

```bash
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

```bash
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

```bash
# Using -v to store in variable
L_epochrealtime_usec -v usec
echo "Current epoch (usec): $usec"

# Or capture stdout
usec=$(L_epochrealtime_usec)
echo "Current epoch (usec): $usec"
```

### Timeouts

Implement timeouts with helper functions:

```bash
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

::: bin/L_lib.sh time
