Functions that are useful for writing utility functions that use `getopts` or similar and want to print simple error messages in the terminal.

The idea is to print a usable message to the user while spending no time creating it manually.

## Usage Guide

### Self-Documenting Functions

The core feature of this module is extracting documentation from comments directly above the function definition. This allows you to maintain the help message and the code in one place.

The comments should follow a specific format compatible with `mkdocstrings-sh`:

- `# @option -o <var> description`: Describes a short option taking an argument.
- `# @option -o description`: Describes a short option not taking an argument.
- `# @arg name description`: Describes a positional argument.
- `# @usage description`: (Optional) Specifies a custom usage line.

### Example Implementation

Here is a complete example of a function using `L_func` utilities:

```
# @description Deploys an artifact to a server.
# @option -v        Enable verbose mode.
# @option -u <user> User to deploy as. Default: current user.
# @option -h        Print this help and return 0.
# @arg file         The file to deploy.
# @arg [dest]       The destination path. Default: /tmp.
deploy_artifact() {
    local OPTIND OPTARG OPTERR opt verbose=0 user="$USER"
    while getopts vu:h opt; do
        case "$opt" in
            v) verbose=1 ;;
            u) user="$OPTARG" ;;
            h) L_func_help; return 0 ;;
            *) L_func_usage; return "$L_EX_USAGE" ;;
        esac
    done
    shift "$((OPTIND-1))"

    # Assertions simplify error checking
    L_func_assert "File argument is required" test "$#" -ge 1 || return "$L_EX_USAGE"
    L_func_assert "File does not exist: $1" test -f "$1" || return "$L_EX_USAGE"

    local file="$1" dest="${2:-/tmp}"

    # ... logic ...
}
```

### Printing Help (`L_func_help`)

Calling `L_func_help` inside your function parses the comments above the function and prints a formatted help message to stderr.

```
deploy_artifact -h
# Output:
# your_script.sh: deploy_artifact: Deploys an artifact to a server.
# @option -v        Enable verbose mode.
# @option -u <user> User to deploy as. Default: current user.
# @option -h        Print this help and return 0.
# @arg file         The file to deploy.
# @arg [dest]       The destination path. Default: /tmp.
```

### Printing Usage (`L_func_usage`)

`L_func_usage` parses the comments to automatically generate a standard usage line. This is useful for `getopts` `*)` case.

```
deploy_artifact -x
# Output:
# your_script.sh: illegal option -- x
# your_script.sh: usage: deploy_artifact [-vh] [-u user] file [dest]
```

### Handling Errors (`L_func_error`, `L_func_usage_error`)

- `L_func_error "message"`: Prints an error message prefixed with the function name.
- `L_func_usage_error "message"`: Prints the error message followed by the usage line.

```
L_func_error "Connection failed"
# Output: your_script.sh: deploy_artifact: error: Connection failed

L_func_usage_error "Invalid argument"
# Output:
# your_script.sh: deploy_artifact: error: Invalid argument
# your_script.sh: usage: deploy_artifact [-vh] [-u user] file [dest]
```

### Assertions (`L_func_assert`)

`L_func_assert` allows you to write concise checks. It runs a command (usually `test` or `[[ ... ]]`). If the command fails, it prints an error message and returns 2.

```
# Explicit check
if [[ ! -f "$file" ]]; then
    L_func_error "File not found: $file"
    return "$L_EX_USAGE"
fi

# Equivalent using L_func_assert
L_func_assert "File not found: $file" test -f "$file" || return "$L_EX_USAGE"
```

### Decorators (`L_decorate`)

Apply decorators to existing functions to wrap their execution.

```
# Define a decorator that prints start and end messages
my_logger() {
    echo "Starting..."
    "$@"
    echo "Finished with status $?"
}

# Define your function
work() {
    echo "Working on: $*"
}

# Decorate the work function with my_logger
L_decorate my_logger work

# Call the decorated function
work "task 1"
```

### Simplified Argument Parsing (`L_getopts_in`)

Use `L_getopts_in` to parse command-line options and positional arguments. It translates options directly into local variables and handles help flags.

```
# Inner implementation function
deploy_in() {
    echo "Verbose: $opt_v"
    echo "User: $opt_u"
    echo "Args: ${opt_args[@]}"
}

# Declare the parsing specification
# -p defines the variable prefix (e.g., opt_)
# -n defines positional argument expectations (e.g., "+" for at least one)
deploy() {
    L_getopts_in -p opt_ -n "+" "vu:h" deploy_in "$@"
}
```

## API Reference

## func

Function for writing function programs.

### L_func_get_source

Get location of where the function was defined.

**Option:** **`-v <var>`** Variable is assigned an array of two elements: the file path of where the function was defined and line number.

**Argument:** **`$1`** Function name to inspect.

### L_func_get_source_vL_RET

### L_func_doc

Unified function-documentation dispatcher.

Backend for L_func_comment, L_func_usage and L_func_help.

**Options:**

- **`-v <var>`** Assign the result to this variable instead of printing it.
- **`-f <funcname>`** Document the given function instead of the calling function.
- **`-s <int>`** Consider the target function this many stack frames above. Default: 1 (one above the wrapper).
- **`-h`** Print this help and return 0.
- **`-i`** Read function comment from stdin, intead of parsing the file.

**Argument:** **`$1`** Mode: one of `comment`, `usage` or `help` (normally supplied by the wrapper functions).

**Return:** 0 if documentation was extracted successfully.

### L_func_comment

Extract the comment above the function.

By default, get the comment of the calling function.

Example

```
# some unrelated comment followed by an empty line

# some comment
somefunc() {
   L_func_comment
}

somefunc  # outputs '# some comment'

L_func_comment -f somefunc
```

**Options:**

- **`-v <var>`** Assign result to this variable.
- **`-f <funcname>`** Print the comment of given function instead of the calling function.
- **`-s <int>`** Consider the calling function this many stackframes above. Default: 0
- **`-h`** Print this help and return 0.

**Return:** 0 if extracted an non-empty comment above the function definition.

### L_func_usage

Print function usage to stderr.

**Options:**

- **`-v <var>`** Store the usage message in the variable instead of printing it.
- **`-h`** Print this help and return.
- **`-s <int>`** How many stack frames up.

**Argument:** **`[$1]`** How many stack frames up.

### L_func_help

Print function comment as help message.

Example

```
# @option -t this is an option
# @option -g <arg> this is an option with an argument
# @option -h Print this help and return 0.
# @arg arg This is an argument
utility() {
  local OPTIND OPTARG OPTERR opt t g
  while getopts tg:h opt; do
    case "$opt" in
      t) t=1 ;;
      g) g=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift "$((OPTARG-1))"
  L_func_assert "one positional argument required" test "$#" -eq 1 || return "$L_EX_USAGE"
  #
  : utility logic
}

utility -h        # prints the comment above the function
utility -invalid  # prints 'Usage: utility [-th] [-g arg] arg'
```

**Options:**

- **`-v <var>`** Store the help message in the variable instead of printing it.
- **`-f <func>`** Function to print help for.
- **`-s <int>`** How many stack frames up.
- **`-h`** Print this help and return 0.

**Argument:** **`[$1]`** How many stack frames up.

**Return:** 0

**See:**

- [L_func_comment](#L_lib.sh--L_func_comment)
- [L_func_error](#L_lib.sh--L_func_error)

### L_func_error

Print function error to stderr.

**Arguments:**

- **`[$1]`** Message.
- **`[$2]`** How many stack frames up.

**See:** [L_func_help](#L_lib.sh--L_func_help) for example

### L_func_usage_error

Print function error with usage.

**Arguments:**

- **`[$1]`** Message.
- **`[$2]`** How many stack frames up.

**See:** [L_func_help](#L_lib.sh--L_func_help) for example

### L_func_assert

Assert that the command exits with 0.

If it does not, call L_func_error and return 64 ($L_EX_USAGE). If the message starts with -[0-9]+, the number is used as the number of stackframes up the message is about.

Example

```
utility() {
  local num="$1"
  L_func_assert "not a number: $num" L_is_integer "$num" || return "$L_EX_USAGE"
}
```

**Arguments:**

- **`$1`** Message to print, may be empty.
- **`$@`** Arguments to test.

**Return:** 64 ($L_EX_USAGE) if the expression failed.

### L_func_log

Print a line prefixed by the calling function name.

**Argument:** **`$@`** line to print

### L_function_copy

Make a copy of a function.

Currently there is no sanitization done in the function. The second argument allows for execution under eval.

**Arguments:**

- **`$1`** existing function
- **`$2`** new function name

### L_function_modify

Add a script on the top or the end of a function.

**Arguments:**

- **`$1`** The function to modify
- **`$2`** Script to put in front of the function body.
- **`$3`** Script to put on the end of the function body.

### L_decorate

Apply a decorator on a function.

The next call on a function will call the decorator with arguments followed by function name with arguments.

Example

```
func() { echo something; }
print_and_call() {
    echo "CALLING: $@" >&2
    "$@"
}
func  # outputs something
func  # outputs something
L_decorate print_and_call func
func  # outputs "CALLING func" and then "something"
func  # outputs "CALLING func" and then "something"
```

Example

```
func() { L_print_traceback; }
L_decorate L_setx func
L_decorate time func
L_decorate L_setx time func
func arg  # calls: [L_setx time func arg]
          # which calls [time func arg]
          # which calls L_setx func arg
```

**Arguments:**

- **`$@`** Decorator to apply with arguments.
- **`$#-1`** Function.

### L_decorate_copy

Apply a decorator on a function.

This is exactly like L_decorate, but does not preserve FUNCNAME, so it is faster.

**Arguments:**

- **`$@`** Decorator to apply with arguments.
- **`$#-1`** Function.

### L_getopts_in

Wrapper around getopts that executes subcommand with local-ed variables.

The frist argument defines a getopts specification, which is like getopts with modifications. Character followed by : represents an option with required argument, just like in getopts. Character followed by :: represents an option that arguments are collected into an array. Otherwise, the characters represent short options on the command line.

Each option in getopts specification is translated to a variable named like the option. The set variables are optionally prefixed with -p argument.

Options variables are initalized with 0, and are incremented each time encountered. Array options variables are initialized with empty array. Argument options variables are unset if not specified by the user!

Option -h is always added and calls L_func_help function and returns 0.

Invalid option triggers L_func_usage_error and returns 64 ($L_EX_USAGE).

Example

```
myfunc() { L_getopts_in -p opt_ n::vq myfunc_in "$@"; }
myfunc_in() {
  echo "${opt_n[@]} $opt_v $opt_q"
}
```

**Options:**

- **`-p <str>`** Add prefix to assigned variables.
- **`-n <str>`** Check positional arguments count. Can be a number or one of "*", "+", "?". Default: "*".
- **`-s <num>`** Call L_func_help and L_func_usage_error for function number stack up. Default: 1, the calling function.
- **`-e <letter=action>`** Evaluate this string when specified letter option is encountered.
- **`-g`** Declare variables globally with `declare -g`.
- **`-w`** Just set variables, without `local` or `declare -g`.
- **`-E`** eval the command.
- **`-h`** Show this help and return 0.

**Arguments:**

- **`$1`** The getopts spec.
- **`$2`** Function to call.
- **`$@`** Arguments to parse.

**Return:**

? Sub-function return status,

70 ($L_EX_SOFTWARE) on itself usage error, 0 if -h option was given, 64 ($L_EX_USAGE) on child usage error.

### L_handle_v_scalar

Wrapper function for handling -v arguments to other functions.

It calls a function called `<caller>_vL_RET` with arguments, but without `-v <var>`. The function `<caller>_vL_RET` should set the variable nameref L_RET to the returned value. When the caller function is called without -v, the value of L_RET is printed to stdout with a newline. Otherwise, the value is a nameref to user requested variable and nothing is printed.

The fucntion L_handle_v_scalar handles only scalar value of `L_RET` or 0-th index of `L_RET` array. To assign an array, prefer L_handle_v_array.

Example

```
L_hello() { L_handle_v_arr "$@"; }
L_hello_vL_RET() { L_RET="hello world"; }
L_hello          # outputs 'hello world'
L_hello -v var   # assigns var="hello world"
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arbitrary function arguments

**Shellcheck disable=** [SC2317](https://www.shellcheck.net/wiki/SC2317)

**Exit:** Whatever exitcode does the `<caller>_vL_RET` funtion exits with.

**See:** [L_handle_v_array](#L_lib.sh--L_handle_v_array)

### L_handle_v_array

Version of L_handle_v_scalar for arrays.

The options and arguments and exitcode is the same as L_handle_v_scalar.

This additionally supports assignment to arrays. This is not possible with L_handle_v_scalar.

The function L_handle_v_scalar is slightly faster and uses `printf -v` to assign the result. On newer Bash, `printf -v` can assign to array and associative arrays variable indexes.

In constract, `L_handle_v_array` has to first assert if the string is a valid variable name. Only then it uses `eval` with an array assignment syntax to assign the result to the user requsted variable.

Currently array indexes are not preserved. This could be worked on in the future when needed.

Example

```
L_hello() { L_handle_v_arr "$@"; }
L_hello_vL_RET() { L_RET=(hello world); }
L_hello          # outputs two lines 'hello' and 'world'
L_hello -v var   # assigns var=(hello world)
```

**Shellcheck disable=** [SC2317](https://www.shellcheck.net/wiki/SC2317)

**See:** [L_handle_v_scalar](#L_lib.sh--L_handle_v_scalar).
