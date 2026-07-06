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
# Parse 5m30s to microseconds
L_duration_to_usec "5m30s"
echo "Microseconds: $L_RET" # 330000000

# Convert back to Prometheus duration string
L_usec_to_duration 330000000
echo "Duration: $L_RET" # 5m30s
```

### Date Formatting

Use `L_date` for date formatting, supporting `%f` (microseconds) and subsecond timepoints. It selects the optimal method based on available capabilities and the format string.

```bash
# Print current time with microseconds
L_date "%Y-%m-%d %H:%M:%S.%f"
echo "$L_RET"

# Format a specific unix timestamp
L_date "%H:%M:%S" 1700000000
echo "$L_RET"
```

### Microsecond Epoch Time

Retrieve the current epoch time in microseconds. It works across different environments and Bash versions, including those where the native `${EPOCHREALTIME}` variable is not available.

```bash
L_epochrealtime_usec
echo "Current epoch (usec): $L_RET"
```

### Timeouts

Implement timeouts with helper functions:

```bash
# Initialize a 5-second timeout variable
L_timeout_init_into timeout 5

while ! L_timeout_is_expired "$timeout"; do
    # Perform some task...
    L_timeout_left "$timeout"
    echo "Time remaining: $L_RET seconds"
    sleep 0.5
done
```

## API Reference

::: bin/L_lib.sh time
