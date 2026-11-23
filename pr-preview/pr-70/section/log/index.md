Log library that provides functions for logging messages, similar to the Python logging module. It supports different log levels, custom formatting, filtering, and output redirection.

## Usage Guide

### Basic Logging

The most common way to log is using the level-specific functions. They accept a single string or a `printf` format followed by arguments.

```
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

```
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

```
# Initial default setup (maybe in a library)
L_log_configure -l info

# This call will be IGNORED because logging is already configured
L_log_configure -l debug 

# This call will WORK because -r forces a reconfiguration
L_log_configure -r -l debug
```

#### Setting Log Level

```
# Set level via name
L_log_configure -l debug

# Set level via integer constant
L_log_configure -l "$L_LOGLEVEL_ERROR"
```

#### Integration with Argparse

A common pattern is to set the verbosity via command-line flags.

```
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

```
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

```
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

## log

logging library

This library is meant to be similar to python logging library.

was log system configured?

\_L_logconf_configured=0

int current global log level

\_L_logconf_level=$L_LOGLEVEL_INFO

1 or 0 or ''. Should we use the color for logging output?

\_L_logconf_color=

if this regex is set, allow elements

\_L_logconf_selecteval=

default formatting function

\_L_logconf_formateval='L_log_format_default "$@"'

default outputting function

\_L_logconf_outputeval=L_log_output_to_stderr

Example

```
L_log_set_level ERROR
L_error "this is an error"
L_info "this is information"
L_debug "This is debug"
```

### $L_LOGLEVEL_CRITICAL

### $L_LOGLEVEL_ERROR

### $L_LOGLEVEL_WARNING

### $L_LOGLEVEL_NOTICE

### $L_LOGLEVEL_INFO

### $L_LOGLEVEL_DEBUG

### $L_LOGLEVEL_TRACE

### $L_LOGLEVEL_NAMES

convert log level to log name

### $L_LOGLEVEL_COLORS

get color associated with particular loglevel

**Shellcheck disable=** [SC2153](https://www.shellcheck.net/wiki/SC2153)

### L_log_configure

Configure L_log module.

Example

```
L_log_configure \
  -l debug \
  -c 0 \
  -f 'printf -v L_logline "${@:2}"' \
  -o 'printf "%s\n" "$L_logline" >&2' \
  -s '[[ $L_logline_source == */script.sh ]]'
```

**Options:**

- **`-h`** Print this help and return 0.

- **`-r`** Allow for reconfiguring L_log system. Otherwise the next call of this function is ignored.

- **`-l <LOGLEVEL>`** Set loglevel. Can be $L_LOGLEVEL_INFO INFO or 30. Default: $\_L_logconf_level

- **`-c <BOOL>`**

  Set to 1 to enable the use of color, set to 0 to disable the use of color.

  Set to '' empty string to detect if stdout has color support. Default: ''

- **`-f <FORMATEVAL>`**

  Evaluate expression for formatting. Default: 'L_log_format_default "$@"'

  The function should format arguments and put the message into the L_logline variable.

- **`-F <FORMATFUNC>`** Equal to -f ' "$@"'. Shorthand to use a function.

- **`-s <SELECTEVAL>`** If eval "SELECTEVAL" exits with nonzero, do not print the line. Default: ''

- **`-o <OUTPUTEVAL>`**

  Evaluate expression for outputting. Default: L_log_output_to_stderr

  The function should output the content of L_logline.

- **`-L`** Equal to -F L_log_format_long

- **`-J`** Equal to -F L_log_format_json

- **`-D <DATEFORMAT>`** Set date format.

- **`-1`** Equal to -F L_log_format_long -D "%H:%M:%S.%3N"

**Arguments:** Takes no arguments

### L_log_level_inc

increase log level

**Argument:** **`$1`** amount, default: 10

### L_log_level_dec

decrease log level

**Argument:** **`$1`** amount, default: 10

### L_log_level_to_int_into

Convert log string to number

**Arguments:**

- **`$1`** str variable name
- **`$2`** int|str loglevel like `INFO` `info` or `30`

### L_log_is_enabled_for

Check if log of such level is enabled to log.

**Argument:** **`$1`** str|int loglevel or log string

### L_log_format_default

Default logging formatting

**Arguments:**

- **`$1`** str log line printf format string
- **`$@`** any log line printf arguments

### L_log_format_long

Format logline with timestamp information.

**Arguments:**

- **`$1`** str log line printf format string
- **`$@`** any log line printf arguments

### L_log_format_json

Output logs in json format.

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

### L_log_output_to_stderr

Output L_logline to stderr.

### L_log_output_to_logger

Output L_logline with logger.

**Argument:** **`$@`** message to output

### L_log

main logging entrypoint

**Options:**

- **`-s <int>`** Increment stacklevel by this much
- **`-l <int|string>`** loglevel to print log line as

**Argument:** **`$@`** any log arguments

**Shellcheck disable=** [SC2140](https://www.shellcheck.net/wiki/SC2140)

**Return:** 0 if nothing was logged, or the exit status of formatter && outputter functions.

### L_critical

output a critical message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_error

output a error message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_warning

output a warning message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_notice

output a notice

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_info

output a information message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_debug

output a debugging message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_trace

output a tracing message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

### L_fatal

Output a critical message and exit the script with 64 ($L_EX_USAGE).

**Argument:** **`$@`** L_critical arguments

### L_logrun

log a command and then execute it

Is not affected by L_dryrun variable.

**Argument:** **`$@`** command to execute

### L_ok

Output a green information message

**Options:**

- **`-s <int>`** stacklevel increase
- **`-l <level>`** loglevel to print log line as
- **`-h`** Show help

**Argument:** **`$1`** message

### $L_dryrun

set to 1 if L_run should not execute the function.

### L_run

Logs the quoted argument with a leading +.

if L_dryrun is nonzero, executes the arguments.

**Options:**

- **`-l <loglevel>`** Set loglevel.
- **`-s <stacklevel>`** Increment stacklevel by this number.
- **`-h`** Print this help and return 0.

**Argument:** **`$@`** command to execute

**Uses environment variable:** **`L_dryrun`**
