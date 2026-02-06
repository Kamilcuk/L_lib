Log library that provides functions for logging messages, similar to the Python logging module. It supports different log levels, custom formatting, filtering, and output redirection.

## Usage Guide

### Basic Logging

The most common way to log is using the level-specific functions. They accept a single string or a `printf` format followed by arguments.

```bash
L_info "This is an info message"
L_error "Something went wrong with file: %s" "$filename"
L_debug "Variable x is: %d" "$x"
```

Available levels (from highest to lowest severity):
- `L_critical`
- `L_error`
- `L_warning`
- `L_notice`
- `L_info`
- `L_debug`
- `L_trace`

### L_run and L_dryrun

`L_run` is a powerful wrapper for executing commands while logging them. It respects the `L_dryrun` variable.

```bash
L_dryrun=1
L_run rm -rf /important/dir
# Outputs: DRYRUN: +rm -rf /important/dir
# Command is NOT executed.

L_dryrun=0
L_run touch new_file
# Outputs: +touch new_file
# Command is executed.
```

### Log Configuration

Use `L_log_configure` to change the behavior of the logging system.

#### The "First Call Wins" Principle

By default, `L_log_configure` follows a "configure-once" design. This means the **first call** to this function sets the global configuration, and all subsequent calls are **ignored**. 

This prevents libraries or sourced scripts from accidentally overriding your application's logging setup (e.g., changing your JSON format back to plain text).

#### Reconfiguring with `-r`

If you need to change the configuration later (for example, after parsing command-line arguments to change the log level), you **must** use the `-r` (reconfigure) flag.

```bash
# Initial default setup (maybe in a library)
L_log_configure -l info

# This call will be IGNORED because logging is already configured
L_log_configure -l debug 

# This call will WORK because -r forces a reconfiguration
L_log_configure -r -l debug
```

#### Setting Log Level

```bash
# Set level via name
L_log_configure -l debug

# Set level via integer constant
L_log_configure -l "$L_LOGLEVEL_ERROR"
```

#### Integration with Argparse

A common pattern is to set the verbosity via command-line flags.

```bash
main() {
    local verbose=0
    L_argparse -- \
        -v --verbose action=count var=verbose help="Increase verbosity" \
        ---- "$@"
    
    local level=INFO
    if ((verbose >= 2)); then level=TRACE;
    elif ((verbose >= 1)); then level=DEBUG; fi
    
    L_log_configure -r -l "$level"
}
```

#### Predefined Formats

The library comes with several built-in formatters:
- **Default:** `script:LEVEL:line:message`
- **Long (`-L`):** Includes ISO8601 timestamp, source file, function name, and line number.
- **JSON (`-J`):** Outputs one JSON object per line, ideal for log aggregators.

```bash
# Default format
L_info "hi"
# Output: my_script:info:10:hi

# Use the long format
L_log_configure -L
L_info "hi"
# Output: 2026-02-06T12:56:25+0100 my_script:main:2 info hi

# Use JSON format for structured logging
L_log_configure -J
L_info "hi"
# Output: {"timestamp":"2026-02-06T12:56:20+0100","funcname":"main","lineno":1,"source":"my_script","level":20,"levelname":"info","message":"hi","script":"my_script","pid":15653,"ppid":1170}
```

### Customization

You can fully customize how logs are filtered, formatted, and where they are sent.

```bash
my_formatter() {
  # The message is in "$@", the result must be put in L_logline
  printf -v L_logline "[%s] %s" "$L_logline_levelname" "$*"
}

my_outputter() {
  # Print the formatted L_logline
  echo "CUSTOM: $L_logline" >&2
}

L_log_configure -F my_formatter -o my_outputter
```

#### Available variables in callbacks:
- `$L_logline`: The variable to be set by the formatter and read by the outputter.
- `$L_logline_levelno`: Numeric logging level.
- `$L_logline_levelname`: Text logging level.
- `$L_logline_funcname`: Function name.
- `$L_logline_source`: Source file path.
- `$L_logline_lineno`: Line number.

## API Reference

::: bin/L_lib.sh log