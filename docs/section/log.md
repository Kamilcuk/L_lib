## L_log

Log library that provides functions for logging messages.

## Usage

The `L_log` module is initialized with level INFO on startup.

To log a message you can use several functions functions.
Each of these function takes a message to print.

```
L_trace "Tracing message"
L_debug "Debugging message"
L_info "Informational message"
L_notice "Notice message"
L_warning "Warning message"
L_error "Error message"
L_critical "Critical message"
```

By default, if one argument is given to the function, it is outputted as-is.
If more arguments are given, they are parsed as a `printf` formatting string.

```
L_info "hello %s"            # logs 'hello %s'
L_info "hello %s" "world"    # logs 'hello world'
```

The configuration of log module is done with [`L_log_configure`](#L_lib.sh--L_log_configure).

```
declare info verbose
L_argparse -- -v --verbose action=store_1 ---- "$@"
if ((verbose)); then level=debug; else level=info; fi
L_log_configure -l "$level"
```

The logging functions accept the `-s` option to to increase logging stack information level.

```
your_logger() {
  L_info -s 1 -- "$@"
}
somefunc() {
  L_info hello
  your_logger world
}
```

All these functions forward messages to `L_log` which is main entrypoint for logging.
`L_log` takes two options, `-s` for stacklevel and `-l` for loglevel.
The loglevel can be specified as a sting `info` or `INFO` or `L_LOGLEVEL_INFO` or as a number `30` or `$L_LOGLEVEL_INFO`.

```
L_log -s 1 -l debug -- "This is a debug message"
```

## Configuration

The logging can be configured with `L_log_configure`.
It supports custom log line filtering, custom formatting and outputting, independent.

```
my_log_formatter() {
  printf -v L_logline "%(%c)T: %s %s" -1 "${L_LOGLEVEL_NAMES[L_logline_loglevel]}" "$*"
}
my_log_ouputter() {
  echo "$L_logline" | logger -t mylogmessage
  echo "$L_logline" >&2
}
my_log_filter() {
  # output only logs from functions starting with L_
  [[ $L_logline_funcname == L_* ]]
}
L_log_configure -l debug -F my_log_formatter -o my_log_ouputter -s my_log_selector
```

There are these formatting functions available:

- `L_log_format_default` - defualt log formatting function.
- `L_log_format_long` - long formatting with timestamp, source, function, line, level and message.
- `L_log_format_json` - format log as JSON lines.

### Available variables in filter, outputter and formatter functions:

There are several variables `L_logline_*` available for callback functions:

- `$L_logline` - The variable should be set by the formatting function and printed by the outputting function.
- `$L_logline_level` - Numeric logging level for the message.
- `$L_logline_levelname` - Text logging level for the message. Empty if unknown.
- `$L_logline_funcname` - Name of function containing the logging call.
- `$L_logline_source` - The BASH_SOURCE where the logging call was made.
- `$L_logline_lineno` - The line number in the source file where the logging call was made.
- `$L_logline_stacklevel` - The offset in stack to where the logging call was made.
- `${L_LOGLEVEL_COLORS[L_logline_levelno]:-}` - The color for the log line.
- `$L_logline_color` - Set to 1 if line should print color. Set to empty otherwise.
    - This is used in templating. `${L_logline_color:+${L_LOGLEVEL_COLORS[L_logline_levelno]:-}colored${L_logline_color:+$L_COLORRESET}`

# Generated documentation from source:

::: bin/L_lib.sh log
