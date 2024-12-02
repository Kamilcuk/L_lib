# logging

Logging library that provides functions for logging messages similar to python `logging` module.


<!-- vim-markdown-toc GFM -->

* [Usage](#usage)
* [Configuration](#configuration)

<!-- vim-markdown-toc -->

# Usage

The logging module is initialized with level INFO on startup, in constrast to python `logging` module.

To log a message you can use `L_trace` `L_debug` `L_info` `L_notice` `L_warning` `L_error` `L_critical` functions. Each function takes a message as an argument and an `-s` option to increase logging stack information level.

```
L_info "Informational message"

my_logger() {
  L_info -s 1 "Trace message"
}
```

All these functions forward messages to `L_log` which is main entrypoint for logging. It takes two arguments, `-s` for stacklevel and `-l` for loglevel. The loglevel can be specified as a sting `info` or `INFO` or `L_LOGLEVEL_INFO` or as a number `30` or `$L_LOGLEVEL_INFO`.

```
L_log -l debug "This is a debug message"
```

# Configuration

The logging can be configured with `L_log_configure`.

```
my_log_formatter() {
  printf -v L_logrecord_msg "%(%c)T: %s %s" -1 "${L_LOGLEVEL_NAMES[L_logrecord_loglevel]}" "$*"
}
my_log_ouputter() {
  echo "$L_logrecord_msg" | logger -t mylogmessage
  echo "$L_logrecord_msg" >&2
}
my_log_filter() {
  # output only logs from functions starting with L_
  [[ "${FUNCNAME[L_logrecord_stacklevel]:-}" =~ ^L_.* ]]
}
L_log_configure -l debug -f 'my_log_formatter "$@"' -o 'my_log_ouputter' -f my_log_filter
```

Available variables:

- `L_logrecord*` variables store information about the currently to-be-outptted log record.
  - `L_logrecord_loglevel` - the current log level of the log record.
  - `L_logrecord_stacklevel` - how many stack levels is the producer of the log line.
  - `L_logrecord_msg` - the log message.
- `${FUNCNAME[L_logrecord_stacklevel]}` - the function that produced the log
- `${BASH_SOURCE[L_logrecord_stacklevel]}` - the filename that produced the log
- `${BASH_LINENO[L_logrecord_stacklevel]}` - the line number that produced the log
- `${L_LOGLEVEL_NAMES[L_logrecord_stacklevel]}` - the string `INFO` of the log level
- `${L_LOGLEVEL_COLORS[L_logrecord_stacklevel]}` - the color of the log line
- `L_log_conf_color` - set to 1 if `L_log_configure` set color to enabled, or null otherwise.

See `L_log_format_default` function implementation for formatting reference.
