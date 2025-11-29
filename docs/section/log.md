# L_log - Structured Logging for Bash

A complete logging library for Bash with configurable log levels, formatters, filters, and outputs - similar to Python's `logging` module.

## Why L_log?

Stop using bare `echo` statements for debugging! `L_log` provides:
- **Log levels** (TRACE, DEBUG, INFO, NOTICE, WARNING, ERROR, CRITICAL)
- **Automatic filtering** by level - show only what matters
- **Colored output** for better readability
- **Source tracking** - see which function/file/line logged the message
- **Custom formatters** - plain text, JSON, or your own format
- **Custom outputs** - stderr, syslog, files, or multiple destinations
- **Printf-style formatting** built-in

## Quick Start

```bash
#!/bin/bash
. L_lib.sh

# Simple logging - works out of the box
L_info "Application starting"
L_debug "Loading configuration"  # Not shown by default (level too low)
L_warning "Configuration file not found, using defaults"
L_error "Failed to connect to database"

# With printf-style formatting
L_info "Processing %d files in %s" "$count" "$directory"
```

**Output:**
```
[INFO] Application starting
[WARNING] Configuration file not found, using defaults
[ERROR] Failed to connect to database
```

## Log Levels

From lowest to highest severity:

| Function | Level | Default Visibility | Use For |
|----------|-------|-------------------|---------|
| `L_trace` | 10 | Hidden | Extremely detailed debugging |
| `L_debug` | 20 | Hidden | Detailed debugging information |
| `L_info` | 30 | **Visible** | General informational messages |
| `L_notice` | 35 | **Visible** | Notable events |
| `L_warning` | 40 | **Visible** | Warning messages |
| `L_error` | 50 | **Visible** | Error messages |
| `L_critical` | 60 | **Visible** | Critical failures |

## Basic Usage

### Simple Messages

```bash
L_debug "Entering function process_data()"
L_info "Processing started"
L_warning "Cache miss, fetching from source"
L_error "Connection timeout after 30s"
L_critical "Disk full, cannot continue"
```

### Printf-Style Formatting

```bash
# Single argument - printed as-is
L_info "hello %s"            # Output: [INFO] hello %s

# Multiple arguments - printf formatting applied
L_info "hello %s" "world"    # Output: [INFO] hello world
L_info "Processed %d/%d files" "$done" "$total"
L_debug "User: %s, ID: %d, Active: %s" "$user" "$id" "$active"
```

### Configuring Log Level

```bash
#!/bin/bash
. L_lib.sh

# Set level to DEBUG to see more details
L_log_configure -l debug

L_debug "Now you can see this!"
L_info "Regular info message"

# Integrate with argparse for --verbose flag
L_argparse \
	-- -v --verbose action=store_true help="Enable verbose logging" \
	---- "$@"

if $verbose; then
	L_log_configure -l debug
else
	L_log_configure -l info
fi
```

## Advanced Configuration

### Custom Log Formatters

Change how log messages are formatted:

```bash
# Use JSON format for structured logging
L_log_configure -l info -F L_log_format_json

L_info "User logged in"
# Output: {"timestamp":"2025-11-29T10:30:45","level":"INFO","message":"User logged in"}

# Use long format with full context
L_log_configure -F L_log_format_long
L_info "Processing data"
# Output: 2025-11-29 10:30:45 [INFO] script.sh:42:process_data() Processing data

# Custom formatter
my_formatter() {
	# Available: $L_logline_levelname, $L_logline_funcname, $L_logline_lineno, etc.
	printf -v L_logline "[%s] %s:%s - %s" \
		"$L_logline_levelname" \
		"$L_logline_funcname" \
		"$L_logline_lineno" \
		"$*"
}

L_log_configure -F my_formatter
```

**Built-in formatters:**
- `L_log_format_default` - Simple format: `[LEVEL] message`
- `L_log_format_long` - Detailed: `timestamp [LEVEL] file:line:function() message`
- `L_log_format_json` - JSON lines for log aggregation systems

### Custom Log Outputs

Send logs to different destinations:

```bash
# Send to syslog
my_syslog_outputter() {
	echo "$L_logline" | logger -t myapp
}

L_log_configure -o my_syslog_outputter

# Send to both stderr and a file
my_dual_outputter() {
	echo "$L_logline" >&2
	echo "$L_logline" >> /var/log/myapp.log
}

L_log_configure -o my_dual_outputter

# Send errors to different file
my_split_outputter() {
	if ((L_logline_level >= L_LOGLEVEL_ERROR)); then
		echo "$L_logline" >> /var/log/myapp-errors.log
	fi
	echo "$L_logline" >&2
}

L_log_configure -o my_split_outputter
```

### Custom Log Filters

Control which messages get logged:

```bash
# Only log from specific functions
my_filter() {
	# Filter: only log from functions starting with "api_"
	[[ $L_logline_funcname == api_* ]]
}

L_log_configure -f my_filter

# Filter by source file
my_file_filter() {
	# Only log from main.sh
	[[ $L_logline_source == */main.sh ]]
}

L_log_configure -f my_file_filter

# Combine filters
my_combined_filter() {
	# Log errors from anywhere, or debug from specific functions
	((L_logline_level >= L_LOGLEVEL_ERROR)) || [[ $L_logline_funcname == debug_* ]]
}

L_log_configure -f my_combined_filter
```

### Stack Level Adjustment

Wrap logging functions while preserving correct source information:

```bash
# Create a wrapper function
my_logger() {
	L_info -s 1 -- "$@"  # -s 1 adjusts stack to show caller, not my_logger
}

# Direct call
process_data() {
	L_info "processing"        # Shows: process_data()
	my_logger "via wrapper"    # Also shows: process_data() (not my_logger)
}
```

### Complete Example: Production Logging Setup

```bash
#!/bin/bash
. L_lib.sh

# Parse command line
L_argparse \
	-- -v --verbose action=count default=0 help="Increase verbosity (-v, -vv, -vvv)" \
	-- --log-file help="Log file path" \
	-- --json action=store_true help="Use JSON format" \
	---- "$@"

# Set log level based on verbosity
case $verbose in
	0) level=warning ;;
	1) level=info ;;
	2) level=debug ;;
	*) level=trace ;;
esac

# Configure output
if [[ -n $log_file ]]; then
	my_output() {
		echo "$L_logline" >&2        # Console
		echo "$L_logline" >> "$log_file"  # File
	}
	L_log_configure -l "$level" -o my_output
else
	L_log_configure -l "$level"
fi

# Configure JSON format if requested
if $json; then
	L_log_configure -F L_log_format_json
fi

# Now log normally
L_info "Application started"
L_debug "Verbose mode: level $verbose"
```

### Available variables in filter, outputter and formatter functions:

There are several variables `L_logline_*` available for callback functions:

- `$L_logline` - The variable should be set by the formatting function and printed by the outputting function.
- `$L_logline_level` - Numeric logging level for the message.
- `$L_logline_levelname` - Text logging level for the message. Empty if unknown.
- `$L_logline_funcname` - Name of function containing the logging call.
- `$L_logline_source` - The BASH_SOURCE where the logging call was made.
- `$L_logline_lineno` - The line number in the source file where the logging call was made.
- `$L_logline_stacklevel` - The offset in stack to where the logging call was made.
- `${L_LOGLEVEL_COLORS[L_logline_level]:-}` - The color for the log line.
- `$L_logline_color` - Set to 1 if line should print color. Set to empty otherwise.
    - This is used in templating. `${L_logline_color:+${L_LOGLEVEL_COLORS[L_logline_level]:-}colored${L_logline_color:+$L_COLORRESET}`

# Generated documentation from source:

::: bin/L_lib.sh log
