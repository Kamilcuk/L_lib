## L_lib.sh

### globals

some global variables

#### $L_LIB_VERSION

Version of the library

#### $L_LIB_SCRIPT

The location of L_lib.sh file

#### $L_NAME

The basename part of $0.

#### $L_DIR

The directory part of $0.

### sysexits

Standard exit codes based on sysexits.h.

These codes are used to standardize return values and exit statuses throughout the library.

#### $L_EX_OK

Successful termination.

#### $L_EX_USAGE

The command was used incorrectly, e.g., with the wrong number of arguments, a bad flag, a bad syntax in a parameter, or whatever.

#### $L_EX_DATAERR

The input data was incorrect in some way. This should only be used for user's data & not system files.

#### $L_EX_NOINPUT

An input file (not a system file) did not exist or was not readable.

#### $L_EX_NOUSER

The user specified did not exist. This might be used for mail addresses or remote logins.

#### $L_EX_NOHOST

The host specified did not exist. This is used in mail addresses or network requests.

#### $L_EX_UNAVAILABLE

A service is unavailable. This can occur if a support program or file does not exist.

#### $L_EX_SOFTWARE

An internal software error has been detected. This should be limited to non-operating system related errors as possible.

#### $L_EX_OSERR

An operating system error has been detected. This is intended to be used for such things as "cannot fork", "cannot create pipe", or the like.

#### $L_EX_OSFILE

Some system file (e.g., /etc/passwd, /var/run/utmp, etc.) does not exist, cannot be opened, or has some sort of error (e.g., syntax error).

#### $L_EX_CANTCREAT

A (user specified) output file cannot be created.

#### $L_EX_IOERR

An error occurred while doing I/O on some file.

#### $L_EX_TEMPFAIL

Temporary failure, indicating something that is not really an error.

#### $L_EX_PROTOCOL

The remote system returned something that was "not possible" during a protocol exchange.

#### $L_EX_NOPERM

You did not have sufficient permission to perform the operation.

#### $L_EX_CONFIG

Something was found in an unconfigured or misconfigured state.

#### $L_EX_TIMEOUT

The command timed out. Convention from GNU timeout utility.

### colors

Variables storing xterm ANSI escape sequences for colors.

Variables with `L_ANSI_` prefix are constant. Variables without `L_ANSI_` prefix are set or empty depending on `L_color_detect function. The`L_color_detect\` function can be used to detect if the terminal and user wishes to have output with colors.

Example

```
echo "$L_RED""hello world""$L_RESET"
```

#### $L_COLOR_VARIABLES

List of all color variable names set by L_color_enable or L_color_disable.

This is a bash array containing the names of all L\_ color/style variables.

Example

```
local "${L_COLOR_VARIABLES[@]}"
```

#### L_color_enable

The L\_ color variables are set to the ANSI escape sequences.

**Arguments:** Takes no arguments

#### L_color_disable

The L\_ color variables are set to empty strings.

**Arguments:** Takes no arguments

**Shellcheck disable=** [SC1007](https://www.shellcheck.net/wiki/SC1007)

#### L_term_has_color

Detect if colors should be used on the terminal.

**Argument:** **`[$1]`** file descriptor to check, default: 1

**Uses environment variables:**

- **`TERM`**
- **`NO_COLOR`**

**Return:** 0 if colors should be used, nonzero otherwise

**See:** <https://no-color.org/>

#### L_color_detect

Detect if colors should be used on the terminal.

**Argument:** **`[$1]`** file descriptor to check, default 1

**Shellcheck disable=** [SC2120](https://www.shellcheck.net/wiki/SC2120)

**See:** <https://en.wikipedia.org/wiki/ANSI_escape_code#Unix_environment_variables_relating_to_color_support>

#### $L_ANSI_BOLD

#### $L_ANSI_BRIGHT

#### $L_ANSI_DIM

#### $L_ANSI_FAINT

#### $L_ANSI_STANDOUT

#### $L_ANSI_UNDERLINE

#### $L_ANSI_BLINK

#### $L_ANSI_REVERSE

#### $L_ANSI_CONCEAL

#### $L_ANSI_HIDDEN

#### $L_ANSI_CROSSEDOUT

#### $L_ANSI_FONT0

#### $L_ANSI_FONT1

#### $L_ANSI_FONT2

#### $L_ANSI_FONT3

#### $L_ANSI_FONT4

#### $L_ANSI_FONT5

#### $L_ANSI_FONT6

#### $L_ANSI_FONT7

#### $L_ANSI_FONT8

#### $L_ANSI_FONT9

#### $L_ANSI_FRAKTUR

#### $L_ANSI_DOUBLE_UNDERLINE

#### $L_ANSI_NODIM

#### $L_ANSI_NOSTANDOUT

#### $L_ANSI_NOUNDERLINE

#### $L_ANSI_NOBLINK

#### $L_ANSI_NOREVERSE

#### $L_ANSI_NOHIDDEN

#### $L_ANSI_REVEAL

#### $L_ANSI_NOCROSSEDOUT

#### $L_ANSI_BLACK

#### $L_ANSI_RED

#### $L_ANSI_GREEN

#### $L_ANSI_YELLOW

#### $L_ANSI_BLUE

#### $L_ANSI_MAGENTA

#### $L_ANSI_CYAN

#### $L_ANSI_LIGHT_GRAY

#### $L_ANSI_DEFAULT

#### $L_ANSI_FOREGROUND_DEFAULT

#### $L_ANSI_BG_BLACK

#### $L_ANSI_BG_BLUE

#### $L_ANSI_BG_CYAN

#### $L_ANSI_BG_GREEN

#### $L_ANSI_BG_LIGHT_GRAY

#### $L_ANSI_BG_MAGENTA

#### $L_ANSI_BG_RED

#### $L_ANSI_BG_YELLOW

#### $L_ANSI_FRAMED

#### $L_ANSI_ENCIRCLED

#### $L_ANSI_OVERLINED

#### $L_ANSI_NOENCIRCLED

#### $L_ANSI_NOFRAMED

#### $L_ANSI_NOOVERLINED

#### $L_ANSI_DARK_GRAY

#### $L_ANSI_LIGHT_RED

#### $L_ANSI_LIGHT_GREEN

#### $L_ANSI_LIGHT_YELLOW

#### $L_ANSI_LIGHT_BLUE

#### $L_ANSI_LIGHT_MAGENTA

#### $L_ANSI_LIGHT_CYAN

#### $L_ANSI_WHITE

#### $L_ANSI_BG_DARK_GRAY

#### $L_ANSI_BG_LIGHT_BLUE

#### $L_ANSI_BG_LIGHT_CYAN

#### $L_ANSI_BG_LIGHT_GREEN

#### $L_ANSI_BG_LIGHT_MAGENTA

#### $L_ANSI_BG_LIGHT_RED

#### $L_ANSI_BG_LIGHT_YELLOW

#### $L_ANSI_BG_WHITE

#### $L_ANSI_BG_DEFAULT

#### $L_ANSI_COLORRESET

It resets color and font.

#### $L_ANSI_RESET

### ansi

Very basic functions for manipulating cursor position and color.

Note

unstable

#### L_strip_ansi

Remove ANSI esacpe sequences like \\E\[..m from string.

Uses extglob

**Option:** **`-v <var>`** assign result to this variable instead of printing it.

**Argument:** **`$1`** string to clean up

#### L_strip_ansi_vL_RET

#### L_ansi_up

Move cursor $1 lines up (CUU - Cursor Up)

**Argument:** **`$1`** int number of lines (default: 1)

#### L_ansi_down

Move cursor $1 lines down (CUD - Cursor Down)

**Argument:** **`$1`** int number of lines (default: 1)

#### L_ansi_right

Move cursor $1 columns right (CUF - Cursor Forward)

**Argument:** **`$1`** int number of columns (default: 1)

#### L_ansi_left

Move cursor $1 columns left (CUB - Cursor Backward)

**Argument:** **`$1`** int number of columns (default: 1)

#### L_ansi_next_line

Move cursor to beginning of line $1 lines down (CNL - Cursor Next Line)

**Argument:** **`$1`** int number of lines (default: 1)

#### L_ansi_prev_line

Move cursor to beginning of line $1 lines up (CPL - Cursor Previous Line)

**Argument:** **`$1`** int number of lines (default: 1)

#### L_ansi_set_column

Move cursor to column $1 (CHA - Cursor Horizontal Absolute)

**Argument:** **`$1`** int column number (1-based)

#### L_ansi_set_position

Move cursor to row $1, column $2 (CUP - Cursor Position)

**Arguments:**

- **`$1`** int row number (1-based)
- **`$2`** int column number (1-based)

#### L_ansi_set_title

Set terminal window title

**Argument:** **`$*`** str title text

#### $L_ANSI_CLEAR_SCREEN_UNTIL_END

Clear screen from cursor to end (ED 0)

#### $L_ANSI_CLEAR_SCREEN_UNTIL_BEGINNING

Clear screen from cursor to beginning (ED 1)

#### $L_ANSI_CLEAR_SCREEN

Clear entire screen (ED 2)

#### $L_ANSI_CLEAR_LINE_UNTIL_END

Clear line from cursor to end (EL 0)

#### $L_ANSI_CLEAR_LINE_UNTIL_BEGINNING

Clear line from cursor to beginning (EL 1)

#### $L_ANSI_CLEAR_LINE

Clear entire line (EL 2)

#### $L_ANSI_SAVE_POSITION

Save cursor position (DECSC)

#### $L_ANSI_RESTORE_POSITION

Restore cursor position (DECRC)

#### L_ansi_print_on_line_above

Move cursor $1 lines above, output remaining args, then move cursor $1 lines down.

**Arguments:**

- **`$1`** int lines above
- **`$2...`** str to print

#### L_ansi_8bit_fg

Set 256-color foreground color

**Argument:** **`$1`** int color index (0-255)

#### L_ansi_8bit_bg

Set 256-color background color

**Argument:** **`$1`** int color index (0-255)

#### L_ansi_8bit_fg_rgb

Set foreground color to 256-color RGB cube value

**Arguments:**

- **`$1`** red (0-5)
- **`$2`** green (0-5)
- **`$3`** blue (0-5)

#### L_ansi_8bit_bg_rgb

Set foreground color to 8bit RGB

**Arguments:**

- **`$1`** red
- **`$2`** green
- **`$3`** blue

#### L_ansi_24bit_fg

Set foreground color to 24bit RGB

**Arguments:**

- **`$1`** red
- **`$2`** green
- **`$3`** blue

#### L_ansi_24bit_bg

Set background color to 24bit RGB

**Arguments:**

- **`$1`** red
- **`$2`** green
- **`$3`** blue

### has

Set of integer variables for checking if Bash has specific feature.

#### $L_BASH_VERSION

Bash version expressed as a hexadecimal integer variable with digits 0xMMIIPP, where MM is major part, II is minor part and PP is patch part of version.

**Shellcheck disable=** [SC2004](https://www.shellcheck.net/wiki/SC2004)

#### $L_HAS_BASH5_3

#### $L_HAS_BASH5_2

#### $L_HAS_BASH5_1

#### $L_HAS_BASH5_0

#### $L_HAS_BASH4_4

#### $L_HAS_BASH4_3

#### $L_HAS_BASH4_2

#### $L_HAS_BASH4_1

#### $L_HAS_BASH4_0

#### $L_HAS_BASH3_2

#### $L_HAS_BASH3_1

#### $L_HAS_BASH3_0

#### $L_HAS_BASH2_5

#### $L_HAS_BASH2_4

#### $L_HAS_BASH2_3

#### $L_HAS_BASH2_2

#### $L_HAS_BASH2_1

#### $L_HAS_BASH2_0

#### $L_HAS_BASH1_14_7

#### $L_HAS_TRAP_P

trap has -P option

#### $L_HAS_COMPGEN_V

\`compgen' has a new option: -V varname. If supplied, it stores the generated

#### $L_HAS_NO_FORK_COMMAND_SUBSTITUTION

New form of command substitution: ${ command; } or ${|command;} to capture

#### $L_HAS_PATSUB_REPLACEMENT

New shell option: patsub_replacement. When enabled, a \`&' in the replacement

#### $L_HAS_k_EXPANSION

There is a new parameter transformation operator: @k. This is like @K, but

#### $L_HAS_SRANDOM

SRANDOM: a new variable that expands to a 32-bit random number

#### $L_HAS_WAIT_P

wait: has a new -p VARNAME option, which stores the PID returned by \`wait -n'

#### $L_HAS_UuLK_EXPASIONS

New `U',`u', and `L' parameter transformations to convert to uppercas New `K' parameter transformation to display associative arrays as key-

#### $L_HAS_EPOCHREALTIME

There is an EPOCHREALTIME variable, which expands to the time in seconds

#### $L_HAS_QEPAa_EXPANSIONS

There is a new ${parameter@spec} family of operators to transform the value of \`parameter'.

#### $L_HAS_LOCAL_DASH

Bash 4.4 introduced function scoped `local -`

#### $L_HAS_MAPFILE_D

The \`mapfile' builtin now has a -d option

#### $L_HAS_DECLARE_WITH_NO_QUOTES

The declare builtin no longer displays array variables using the compound

assignment syntax with quotes; that will generate warnings when re-used as input, and isn't necessary. Declare -p on Bash\<4.4 adds extra $'\\001' before $'\\001' and $'\\177' bytes.

#### $L_HAS_WAIT_N

The `wait' builtin has a new`-n' option to wait for the next child to

#### $L_HAS_NAMEREF

Bash 4.3 introduced declare -n nameref

#### $L_HAS_PRINTF_T

The printf builtin has a new %(fmt)T specifier

#### $L_HAS_VARIABLE_FD

If the optional left-hand-side of a redirection is of the form {var},

#### $L_HAS_EXTGLOB_IN_TESTTEST

Force extglob on temporarily when parsing the pattern argument to

the == and != operators to the \[\[ command, for compatibility.

#### $L_HAS_TEST_V

Bash 4.1 introduced test/\[/\[\[ -v variable unary operator

#### $L_HAS_PRINTF_V_ARRAY

\`printf -v' can now assign values to array indices.

#### $L_HAS_ASSOCIATIVE_ARRAY

Bash 4.0 introduced declare -A var=([a]=b)

#### $L_HAS_MAPFILE

Bash 4.0 introduced mapfile

#### $L_HAS_READARRAY

Bash 4.0 introduced readarray

#### $L_HAS_CASE_FALLTHROUGH

Bash 4.0 introduced case fallthrough ;& and ;;&

#### $L_HAS_LOWERCASE_UPPERCASE_EXPANSION

Bash 4.0 introduced ${var,,} and ${var^^} expansions

#### $L_HAS_BASHPID

Bash 4.0 introduced BASHPID variable

#### $L_HAS_COPROC

Bash 3.2 introduced coproc

#### $L_HAS_UNQUOTED_REGEX

\[\[ =~ has to be quoted or not, no one knows.

Bash4.0 change: The shell now has the notion of a `compatibility level', controlled by new variables settable by`shopt'. Setting this variable currently restores the bash-3.1 behavior when processing quoted strings on the rhs of the `=~' operator to the`\[\[' command. Bash3.2 change: Quoting the string argument to the \[\[ command's =~ operator now forces string matching, as with the other pattern-matching operators.

#### $L_HAS_PREFIX_EXPANSION

Bash 2.4 introduced ${!prefix\*} expansion

#### $L_HAS_HERE_STRING

Bash 2.05 introduced \<<\<"string"

#### $L_HAS_INDIRECT_EXPANSION

Bash 2.0 introduced ${!var} expansion

#### $L_HAS_ARRAY

Bash 1.14.7 introduced arrays

Bash 1.14.7 also introduced: New variables: DIRSTACK, PIPESTATUS, BASH_VERSINFO, HOSTNAME, SHELLOPTS, MACHTYPE. The first three are array variables.

### assert

#### L_panic

Print stacktrace and the message to stderr and exit with 29.

Example

```
[[ -r "$file" ]] || L_panic "File is not readable: $file"
```

**Option:** **`-[0-9]+`** Exit with this number.

**Argument:** **`$@`** Message to print.

**See:**

- [L_assert](#L_lib.sh--L_assert)
- [L_exit](#L_lib.sh--L_exit)
- [L_check](#L_lib.sh--L_check)

#### L_assert

Assert the command succeeds.

Execute a command given from the second positional argument. When the command fails, execute `L_panic`. Note: `[[` is a bash syntax sugar and is not a command. `!` is also not a standalone command or builtin, so it can't be used with this function. You could use `eval "[[ ${var@Q} = ${var@Q} ]]"`. However to prevent quoting issues it is simpler to use wrapper functions. The function `L_regex_match` `L_glob_match` `L_not` are useful for writing assertions. To invert the test use `L_not` which just executes `! "$@"`.

Example

```
L_assert 'wrong number of arguments' [ "$#" -eq 0 ]
L_assert 'first argument must be equal to insert' test "$1" = "insert
L_assert 'var has to match regex' L_regex_match "$var" ".*test.*"
L_assert 'var has to not match regex' L_not L_regex_match "$var" "[yY][eE][sS]"
L_assert 'var has to matcha glob' L_glob_match "$var" "*glob*"
```

**Arguments:**

- **`$1`**

  str Assertion description.

  If the description starts with '-[0-9]+', the number is used as the exit code for L_panic.

- **`$@`** command to test

#### L_die

Print the arguments to standard error and exit wtih 28.

Example

```
test -r file || L_die "File is not readable"
```

**Option:** **`-[0-9]+`** Exit with this number.

**See:**

- [L_panic](#L_lib.sh--L_panic)
- [L_exit](#L_lib.sh--L_exit)
- [L_check](#L_lib.sh--L_check)
- [L_assert](#L_lib.sh--L_assert)

#### L_exit

With no arguments or an empty string, exit with 0.

Otherwise, the arguments are printed to stderr and exit with 1.

Note

If you want to exit with number, just call builtin exit,

Example

```
err=()
test -r file || err+=("file is not readable")
test -f file || err+=("file is not a file")
L_exit "${err[@]}"
```

**See:**

- [L_panic](#L_lib.sh--L_panic)
- [L_assert](#L_lib.sh--L_assert)
- [L_check](#L_lib.sh--L_check)

#### L_check

Execute a command given from the second argument. If the command fails, call `L_exit`. The difference to `L_assert` is that it prints calltrace on error. `L_check` function only prints the error message with the program name on error. Execute a command given from the second argument. If the command fails, call `L_exit`. The difference to `L_assert` is that it prints calltrace on error. `L_check` function only prints the error message with the program name on error.

**See:**

- [L_panic](#L_lib.sh--L_panic)
- [L_assert](#L_lib.sh--L_assert)
- [L_check](#L_lib.sh--L_check)
- [L_panic](#L_lib.sh--L_panic)
- [L_assert](#L_lib.sh--L_assert)
- [L_check](#L_lib.sh--L_check)

### func

Function for writing function programs.

#### L_func_get_source

Get location of where the function was defined.

**Option:** **`-v <var>`** Variable is assigned an array of two elements: the file path of where the function was defined and line number.

**Argument:** **`$1`** Function name to inspect.

#### L_func_get_source_vL_RET

#### L_func_doc

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

#### L_func_comment

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

#### L_func_usage

Print function usage to stderr.

**Options:**

- **`-v <var>`** Store the usage message in the variable instead of printing it.
- **`-h`** Print this help and return.
- **`-s <int>`** How many stack frames up.

**Argument:** **`[$1]`** How many stack frames up.

#### L_func_help

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

#### L_func_error

Print function error to stderr.

**Arguments:**

- **`[$1]`** Message.
- **`[$2]`** How many stack frames up.

**See:** [L_func_help](#L_lib.sh--L_func_help) for example

#### L_func_usage_error

Print function error with usage.

**Arguments:**

- **`[$1]`** Message.
- **`[$2]`** How many stack frames up.

**See:** [L_func_help](#L_lib.sh--L_func_help) for example

#### L_func_assert

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

#### L_func_log

Print a line prefixed by the calling function name.

**Argument:** **`$@`** line to print

#### L_function_copy

Make a copy of a function.

Currently there is no sanitization done in the function. The second argument allows for execution under eval.

**Arguments:**

- **`$1`** existing function
- **`$2`** new function name

#### L_function_modify

Add a script on the top or the end of a function.

**Arguments:**

- **`$1`** The function to modify
- **`$2`** Script to put in front of the function body.
- **`$3`** Script to put on the end of the function body.

#### L_decorate

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

#### L_decorate_copy

Apply a decorator on a function.

This is exactly like L_decorate, but does not preserve FUNCNAME, so it is faster.

**Arguments:**

- **`$@`** Decorator to apply with arguments.
- **`$#-1`** Function.

#### L_getopts_in

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

#### L_handle_v_scalar

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

#### L_handle_v_array

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

### cache

#### L_cache

Cache the execution of a command.

The command execution is cached in \_L_CACHE global variable or in file when -f option is present. The second execution of the command will result in a cached execution. On cached execution the exit status of the command will be extracted from the cache.

Example

```
L_cache -T 10m -O output -f /tmp/cache.L_cache curl -sS https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html

myfunc() { var=$(( 1 + 2 )); }
L_decorate L_cache -s var -k myfunc myfunc
myfunc
myfunc

mydata() { curl "$@" https://website.com; }
L_decorate L_cache -O website_data mydata
mydata -sS
echo "$website_data"
mydata
echo "$website_data"

L_data -k mydata -l
```

**Options:**

- **`-o`**

  Cache the stdout of the command and output it.

  It will run the command in a process substitution.

- **`-O <var>`**

  Cache the stdout of the command and store it in variable instead of printing.

  It will run the command in a process substitution.

- **`-s <var>`** Save this variable to the cache. All cache variables will be restored on cached execution.

- **`-f <file>`**

  Use the file as cache.

  The file has a header with version number. The file stores internal cache state from declare -p \_L_CACHE variable. The file content is eval-ed upon loading.

- **`-r`**

  Instead of executing, clear the cache.

  If used with -k or with command, clear only the specific key.

- **`-l`**

  Instead of executing, list the entires in the cache in a table. Use twice to not limit to 100 characters.

  If used with -k or with command, list only the specific key.

- **`-T <ttl>`**

  Set time to live in duration string. Default: infinity.

  The TTL is checked by the caller. The option should be specified every call.

- **`-L <01>`** If 1, use flock, if 0, do not use flock. Default: autodetect based on flock availability.

- **`-k <key>`** Use this key to index the cache. Default: space joined %q quoted command.

- **`-h`** Print this help and return 0.

**Argument:** **`$@`** Command to execute.

**Sets variable:** **`_L_CACHE`**

**Uses environment variable:** **`_L_CACHE`**

**Shellcheck disable=** [SC2094](https://www.shellcheck.net/wiki/SC2094)

**Return:**

64 ($L_EX_USAGE) or other error code on invalid usage or error

otherwise returns the exit status of the cached command.

### stdlib

Some base simple definitions for every occasion.

#### L_regex_match

Wrapper around =~ for contexts that require a function.

**Arguments:**

- **`$1`** string to match
- **`$2`** regex to match against

#### L_regex_escape

Produce a string that is a regex escaped version of the input.

Works for both basic and extended regular expression.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** string to escape

**See:**

- <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_04>
- <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_03>

#### L_regex_escape_vL_RET

#### L_regex_findall

Get all matches of a regex to an array.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** string to match
- **`$2`** regex to match

#### L_regex_findall_vL_RET

#### L_regex_replace

Replace all matches of a regex with a string.

In a string replace all occurences of a regex with replacement string. Backreferences like & \\1 \\2 etc. are replaced in replacement string unless -B option is used. Written pure in Bash. Uses \[\[ =~ operator in a loop.

Example

```
L_regex_replace -v out 'world world' 'w[^ ]*' 'hello'
echo "$out"
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-g`** Global replace
- **`-c <int>`** Limit count of replacements, default: 1
- **`-n <var>`** Variable to set with count of replacements made.
- **`-B`** Do not handle backreferences in replacement string & \\1 \\2 \\
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** string to match
- **`$2`** regex to match
- **`$3`** replacement string

**Exit:** If -n option is given, exit with 0, otherwise exit with 0 if at least one replacement was made, otherwise exit with 1.

#### L_execute

Executes the command.

**Argument:** **`$@`** Command to execute.

#### L_not

Inverts exit status.

**Argument:** **`$@`** Command to execute.

#### L_return

Return the first argument

**Argument:** **`$1`** integer to return

#### L_shopt_extglob

Runs the command with extglob restoring the option after return.

**Argument:** **`$@`** Command to execute

#### L_shopt

Runs the command with the specified shopt option enabled temporarily.

**Arguments:**

- **`$1`** shopt option name (e.g., nullglob)
- **`$@`** command to execute

#### L_set

Runs the command with the specified shell option enabled temporarily.

The design choice is to provide a scoped (RAII-like) setting that automatically restores the original shell state upon return, ensuring environment isolation. It supports both single-letter flags (-x, -f) and long options (-o pipefail).

Example

```
# Chain multiple options by nesting:
L_set -o pipefail L_set -x my_command arg1
```

**Arguments:**

- **`$1`** The shell option to apply (e.g., -x, -f, -o).
- **`[$2]`** If $1 was -o, the -o to apply.
- **`$@`** The command and its arguments to execute.

#### L_setx

Runs the command under set -x restoring the setting after return.

**Argument:** **`$@`** Command to execute

#### L_unsetx

Runs the command under set +x restoring the setting after return.

**Argument:** **`$@`** Command to execute

**See:** [L_setx](#L_lib.sh--L_setx)

#### L_setposix

Runs the command under set -o posix restoring the setting after return.

**Argument:** **`$@`** Command to execute

#### L_unsetposix

Runs the command under set +o posix restoring the setting after return.

**Argument:** **`$@`** Command to execute

#### L_glob_match

Wrapper around == for contexts that require a function.

**Arguments:**

- **`$1`** string to match
- **`$2`** glob to match against

**Shellcheck disable=** [SC2053](https://www.shellcheck.net/wiki/SC2053)

**See:** [L_extglob_match](#L_lib.sh--L_extglob_match)

#### L_extglob_match

Wrapper around == for contexts that require a function.

This is equal to L_glob_match when `==` has always extglob enabled. However, this was not the case for older bash. In which case this function temporary enables extglob.

**Arguments:**

- **`$1`** string to match
- **`$2`** glob to match against

**Shellcheck disable=** [SC2053](https://www.shellcheck.net/wiki/SC2053)

**See:** [L_glob_match](#L_lib.sh--L_glob_match)

#### L_glob_escape

Produce a string that is a glob escaped version of the input.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** string to escape

#### L_glob_escape_vL_RET

#### L_source

Execute source with arguments.

This is usefull when wanting to source a script without passing a arguments.

**Arguments:**

- **`$1`** Script to source.
- **`$@`** Positional arguments to script.

**Shellcheck disable=** [SC1090](https://www.shellcheck.net/wiki/SC1090)

**See:** <https://stackoverflow.com/a/73791073/9072753>

#### L_eval

Evaluate the expression by first setting the arguments.

This is usefull to properly quote the expression and still use eval and variables.

Example

```
L_assert 'variable has quotes' L_eval '[[ "$1" != *\"* ]]' "$variable"
# much simpler and easier to quote than:
L_assert 'variable has quotes' "[[ ${variable@Q} == *\\\"* ]]"
```

**Arguments:**

- **`$1`** Script to execute.
- **`$@`** Positional arguments to set for the duration of the script.

#### L_subshell

Call the command in a subshell.

**Argument:** **`$@`** Command to excute.

#### L_compgen

Wrapper around compgen that does not support -V argument.

Note

`copmgen -W` allows execution. For example \`compgen -W '$(echo something >&2)'\`\` executes echo.

**Option:** **`-V <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** Any other compgen options and arguments.

#### L_function_exists

Return 0 if the argument is a function

**Argument:** **`$1`** function name

#### L_command_exists

Return 0 if the argument is a command.

Consider using L_hash instead. This differs from L_hash in the presence of an alias. `command -v` detects aliases. `hash` detects actual executables in PATH and bash functions.

**Argument:** **`$@`** commands names to check

**See:** [L_hash](#L_lib.sh--L_hash)

#### L_hash

Execute Bash hash builtin with silenced output.

A typical mnemonic to check if a command exists is `if hash awk 2>/dev/null`. This saves to type the redirection.

Why hash and not command or type? Bash stores all executed commands from PATH in hash. Indexing it here, makes the next call faster.

**Argument:** **`$@`** commands to check

**See:** [L_command_exists](#L_lib.sh--L_command_exists)

#### L_is_main

Return 0 if current script is not sourced.

#### L_is_sourced

Return 0 if current script sourced.

Comparing BASH_SOURCE to $0 only works, when BASH_SOURCE is different from $0. When calling `.` or `source` builtin it will be added as an "source" into `FUNCNAME` array. This function returns false, if there exists a source element in FUNCNAME array.

#### L_has_sourced_arguments

Return true if sourced script was passed any arguments.

When you source a script and do not pass any arguments, the arguments are equal to the parent scope.

```
$ set -- a b c ; source <(echo 'echo "$@"')          # script sourced with no arguments
a b c
$ set -- a b c ; source <(echo 'echo "$@"') d e f    # script sourced with arguments
d e f
```

It is hard to detect if the script arguments are real arguments passed to `source` command or not. This function detect the case by checking for a command "source" in FUNCNAME.

Example

```
if L_is_main; then
   main
   exit $?
elif L_has_sourced_arguments; then
   sourced_main "$@"
   return
else
   sourced_main
   return
fi
```

**Arguments:** Takes no arguments

**See:**

- <https://stackoverflow.com/a/79201438/9072753>
- <https://stackoverflow.com/questions/61103034/avoid-command-line-arguments-propagation-when-sourcing-bash-script/73791073#73791073>
- <https://unix.stackexchange.com/questions/568747/bash-builtin-variables-bash-argv-and-bash-argc>

#### L_is_in_bash

Return 0 if running in bash shell.

Portable with POSIX shell.

#### L_in_posix_mode

Return 0 if running in posix mode.

#### L_var_is_set

Return 0 if variable is set

**Argument:** **`$1`** variable nameref

**Exit:** 0 if variable is set, nonzero otherwise

#### L_var_is_notnull

Return 0 if variable is set and is not null (not empty)

**Argument:** **`$1`** variable nameref

**Exit:** 0 if variable is set, nonzero otherwise

#### L_var_to_string

Serialize variable value to a string that can be declared.

The result is a string that is the value of variable quoted in a format that can be reused as input to declare.

For scalar variables, the function outputs a quoted value of the variable. For array and associative array variables, the function outputs a string in the form of `([a]=b)` that can be used to assign to another variable.

Use `declare` with `-a` or `-A` for arrays to load the result into a variable. Eval is not preferred and might result in invalid values on Bash\<4.4. Bash\<4.4 prepends byte 0x01 in front of bytes 0x01 and 0x7f. Single 0x01 in declare -p output results in double 0x01,0x01.

Namerefences variables are not resolved and instead result in an empty string. This is by design - checking if variable is a string, requires a call to declare, which is costly. If you know a way to check if nameref without calling declare, let me know, I would want to add.

Example

```
local -A map=([a]=b [c]=d)
L_var_to_string -v tmp map
declare -A map2=$tmp
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** variable name

**See:**

- [L_HAS_DECLARE_WITH_NO_QUOTES](#L_lib.sh--L_HAS_DECLARE_WITH_NO_QUOTES)
- [L_HAS_QEPAa_EXPANSIONS](#L_lib.sh--L_HAS_QEPAa_EXPANSIONS)
- [L_cache](#L_lib.sh--L_cache)

#### L_var_is_notarray

Return 0 if variable is not an array neither an associative array.

**Argument:** **`$1`** variable nameref

#### L_var_is_array

Return 0 if variable is an indexed integer array, not an associative array.

**Argument:** **`$1`** variable nameref

#### L_var_is_readonly

Return 0 if variable is readonly.

**Argument:** **`$1`** variable nameref

#### L_var_is_integer

Return 0 if variable has integer attribute set.

**Argument:** **`$1`** variable nameref

#### L_var_is_exported

Return 0 if variable is exported.

**Argument:** **`$1`** variable nameref

#### L_var_is_associative

Return 0 if variable is an associative array.

**Argument:** **`$1`** variable nameref

#### L_var_to_string_vL_RET

#### L_var_get_nameref

Get the namereference variable name that the variable references to.

If the variable is not a namereference, return 1

**Option:** **`-v <var>`** Variable to assign. If not given, print to stdout.

**Argument:** **`$1`** variable nameref

**See:** [L_var_is_nameref](#L_lib.sh--L_var_is_nameref)

#### L_var_get_nameref_vL_RET

#### L_var_is_nameref

Return 0 if the variable is a namereference.

**Argument:** **`$1`** variable nameref

**See:** [L_var_get_nameref](#L_lib.sh--L_var_get_nameref)

#### L_printf_append

Append to the first argument if first argument is not null.

If first argument is an empty string, print the line. Used by functions optically taking a -v argument or printing to stdout, when such functions want to append the printf output to a variable for example in a loop or similar.

Example

```
func() {
  local var=
  if [[ "$1" == -v ]]; then
     var=$2
     shift 2
  fi
  L_printf_append "$var" "%s" "Hello "
  L_printf_append "$var" "%s" "world\n"
}
func          # prints hello world
func -v var   # stores hello world in $v
```

**Arguments:**

- **`$1`** variable to append to or empty string
- **`$2`** printf format specification
- **`$@`** printf arguments

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059) [SC2059](https://www.shellcheck.net/wiki/SC2059)

#### L_uuid4

Generate uuid in bash.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**See:** <https://digitalbunker.dev/understanding-how-uuids-are-generated/>

#### L_uuid4_vL_RET

#### L_init_COLUMNS

The function temporarily enables checkwinsize and runs a subshell (:) to force the parent process to reap it, triggering get_tty_state() and updating COLUMNS via ioctl.

**See:** <https://askubuntu.com/a/1199418>

### time

#### L_time

Measure time with the command, but include the command in the time message output and use %6l format.

**Argument:** **`$@`** command to measure.

#### L_duration_to_usec

Parse 1y2w3d4h5m6s7ms8us or 1y2w3d4h5m6.789s or 1.234 into number of microseconds.

**Option:** **`-v <var>`**

**Argument:** **`$1`** Duration string.

**See:** <https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file>

#### L_duration_to_usec_vL_RET

**Shellcheck disable=** [SC2211](https://www.shellcheck.net/wiki/SC2211) [SC2035](https://www.shellcheck.net/wiki/SC2035) [SC2035](https://www.shellcheck.net/wiki/SC2035) [SC1102](https://www.shellcheck.net/wiki/SC1102)

#### L_usec_to_duration

Convert microseconds to Prometheus duration string using L_RET.

**Option:** **`-v <var>`**

**Argument:** **`$1`** Microseconds (integer).

#### L_usec_to_duration_vL_RET

#### L_date

Print date in the format.

If the format string contains %N or the timepoint is not a number, use date command. Otherwise, try to use printf %(fmt)T.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and exit.

**Arguments:**

- **`$1`** Format string, without leading +.
- **`[$2]`** Optional timepoint in seconds with optional digit or any date understood format.

#### L_date_vL_RET

#### L_epochrealtime_usec

Return time in microseconds.

The dot or comma is removed from EPOCHREALTIME. Uses EPOCHREALTIME in newer Bash. In older Bash tries GNU date, gdate, perl, /proc/uptime, python, busybox adjtimex.

**Option:** **`-v <var>`**

#### L_epochrealtime_usec_vL_RET

#### L_sec_to_usec

Convert float seconds to microseconds.

Example

```
L_sec_to_usec 1.5 -> 1500000
```

**Option:** **`-v <var>`**

#### L_sec_to_usec_vL_RET

#### L_usec_to_sec

Convert microseconds to seconds with 6 digits after comma.

**Option:** **`-v <var>`**

#### L_usec_to_sec_vL_RET

#### L_timeout_init_into

Calculate timeout value.

The timeout value is stored in microseconds.

**Arguments:**

- **`$1`** Variable to assign with the timeout value in usec.
- **`$2`** Timeout in seconds. May be a fraction.

**See:** [L_epochrealtime_usec](#L_lib.sh--L_epochrealtime_usec)

#### L_timeout_init_usec_into

Initialize a timer with a timeout in microseconds.

**Arguments:**

- **`$1`** Variable to assign with the timeout value in usec.
- **`$2`** Timeout in microseconds.

#### L_timeout_is_expired

Is the timeout expired?

**Argument:** **`$1`** timeout value in usec.

#### L_timeout_left_usec

Get the number of microseconds left in the timer.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** timeout value in usec.

#### L_timeout_left_usec_vL_RET

#### L_timeout_left

Get the number of seconds left in the timer.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** timeout value in usec.

#### L_timeout_left_vL_RET

### exit_to

#### L_exit_into

store exit status of a command to a variable

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

#### L_exit_into_1null

convert exit code to the word yes or to nothing

Example

```
L_exit_into_1null suceeded test "$#" = 0
echo "${suceeded:+"SUCCESS"}"  # prints SUCCESS or nothing
```

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

#### L_exit_into_1unset

convert exit code to the word yes or to unset variable

Example

```
L_exit_into_1null suceeded test "$#" = 0
echo "${suceeded:+"SUCCESS"}"  # prints SUCCESS or nothing
```

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

#### L_exit_into_10

store 1 if command exited with 0, store 0 if command exited with nonzero

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

### path

#### L_basename

The filename

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

#### L_basename_vL_RET

#### L_dirname

parent of the path

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

#### L_dirname_vL_RET

#### L_path_extension

The last dot-separated portion of the final component, if any.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

**See:** <https://en.cppreference.com/w/cpp/filesystem/path/extension.html>

#### L_path_extension_vL_RET

#### L_path_extensions

A list of the path’s suffixes, often called file extensions.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

**See:** <https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.suffixes>

#### L_path_extensions_vL_RET

#### L_path_stem

The final path component, without its suffix:

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

**See:** <https://en.cppreference.com/w/cpp/filesystem/path/stem>

#### L_path_stem_vL_RET

#### L_path_with_name

Return a new path with the name changed.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** path
- **`$1`** new name

#### L_path_with_name_vL_RET

#### L_path_with_stem

Return a new path with the stem changed.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** path
- **`$2`** new stem

#### L_path_with_stem_vL_RET

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

#### L_path_with_suffix

Return a new path with the suffix changed.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** path
- **`$2`** new suffix

#### L_path_with_suffix_vL_RET

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

#### L_path_is_absolute

Return whether the path is absolute or not.

#### L_path_normalize

Replace multiple slashes by one slash.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

#### L_path_normalize_vL_RET

**Shellcheck disable=** [SC2064](https://www.shellcheck.net/wiki/SC2064)

#### L_path_relative_to

Compute a version of the original path relative to the path represented by other path.

This method is string-based.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** original path
- **`$2`** other path

**See:**

- <https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.relative_to>
- <https://stackoverflow.com/a/12498485/9072753>

#### L_path_relative_to_vL_RET

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

#### L_path_is_relative_to

Check if a path is relative to other path.

This method is string-based; it neither accesses the filesystem nor treats “..” segments specially. Consider as alternative: L_path_relative_to -v tmp "$1" "$2" && \[[ "$tmp" == ../\* ]\]

Example

```
L_path_is_relative_to /etc/passwd /etc  # return 0
L_path_is_relative_to /etc/passwd /usr  # return 1
```

**Arguments:**

- **`$1`** Path to check
- **`$2`** Path that $1 should be relative to.

#### L_path_append

Append a path to path variable if not already there.

Example

```
L_path_append PATH ~/.local/bin
```

**Arguments:**

- **`$1`** Variable name. For example PATH
- **`$2`** Path to append. For example /usr/bin
- **`[$3]`** Optional path separator. Default: ':'

#### L_path_prepend

Prepend a path to path variable if not already there.

Example

```
L_path_append PATH ~/.local/bin
```

**Arguments:**

- **`$1`** Variable name. For example PATH
- **`$2`** Path to prepend. For example /usr/bin
- **`[$3]`** Optional path separator. Default: ':'

#### L_path_remove

Remove a path from a path variable.

Example

```
L_path_append PATH ~/.local/bin
```

**Arguments:**

- **`$1`** Variable name. For example PATH
- **`$2`** Path to prepend. For example /usr/bin
- **`[$3]`** Optional path separator. Default: ':'

#### L_dir_is_empty

Return 0 if a directory is empty.

**Argument:** **`$1`** Directory.

### string

Collection of functions to manipulate strings.

#### L_is_true

Return 0 if the string happend to be something like true.

Return 0 when argument is case-insensitive:

- true
- 1
- yes
- y
- t
- any number except 0
- the character '+'

**Argument:** **`$1`** str

#### L_is_false

Return 0 if the string happend to be something like false.

Return 0 when argument is case-insensitive:

- false
- 0
- no
- F
- n
- the character minus '-'

**Argument:** **`$1`** str

#### L_is_true_locale

Return 0 if the string happend to be something like true in locale.

**Argument:** **`$1`** str

#### L_is_false_locale

Return 0 if the string happend to be something like false in locale.

**Argument:** **`$1`** str

#### L_isprint

Return 0 if all characters in string are printable

**Argument:** **`$1`** string to check

#### L_isdigit

Return 0 if all string characters are digits

**Argument:** **`$1`** string to check

#### L_is_valid_variable_name

Return 0 if argument could be a variable name.

This function is used to make sure that eval "$1=" will e correct if L_is_valid_variable_name "$1".

**Argument:** **`$1`** string to check

**See:** [L_is_valid_variable_or_array_element](#L_lib.sh--L_is_valid_variable_or_array_element)

#### L_is_valid_variable_or_array_element

Return 0 if argument could be a variable name or array element.

Example

```
L_is_valid_variable_or_array_element aa           # true
L_is_valid_variable_or_array_element 'arr[elem]'  # true
L_is_valid_variable_or_array_element 'arr[elem'   # false
```

**Argument:** **`$1`** string to check

**See:** [L_is_valid_variable_name](#L_lib.sh--L_is_valid_variable_name)

#### L_is_valid_function_name

Is the string a valid Bash opinionated function name?

Almost anything is valid Bash function name.

**Argument:** **`$1`** string to check

**See:**

- <https://stackoverflow.com/a/44041384/9072753>
- <https://stackoverflow.com/a/69292370/9072753>

#### L_is_integer

Return 0 if the string characters is an integer

**Argument:** **`$1`** string to check

#### L_is_float

Return 0 if the string characters is a float

**Argument:** **`$1`** string to check

#### $L_NL

newline

#### $L_TAB

tab

#### $L_SOH

Start of heading

#### $L_STX

Start of text

#### $L_EOT

End of Text

#### $L_EOF

End of transmission

#### $L_ENQ

Enquiry

#### $L_ACK

Acknowledge

#### $L_BEL

Bell

#### $L_BS

Backspace

#### $L_HT

Horizontal Tab

#### $L_LF

Line Feed

#### $L_VT

Vertical Tab

#### $L_FF

Form Feed

#### $L_CR

Carriage Return

#### $L_SO

Shift Out

#### $L_SI

Shift In

#### $L_DLE

Data Link Escape

#### $L_DC1

Device Control 1

#### $L_DC2

Device Control 2

#### $L_DC3

Device Control 3

#### $L_DC4

Device Control 4

#### $L_NAK

Negative Acknowledge

#### $L_SYN

Synchronous Idle

#### $L_ETB

End of Transmission Block

#### $L_CAN

Cancel

#### $L_EM

End of Medium

#### $L_SUB

Substitute

#### $L_ESC

Escape

#### $L_FS

File Separator

#### $L_GS

Group Separator

#### $L_RS

Record Separator

#### $L_US

Unit Separator

#### $L_DEL

Delete

#### $L_LBRACE

Left brace character

#### $L_RBRACE

Right brace character

#### $L_UUID

Looks random.

**See:** [L_uuid4](#L_lib.sh--L_uuid4)

#### $L_ALLCHARS

255 bytes with all possible 255 values

#### $L_ASCII_LOWERCASE

All lowercase characters a-z

#### $L_ASCII_UPPERCASE

All uppercase characters A-Z

#### $L_GPL_LICENSE_NOTICE_3_OR_LATER

The GPL3 or later License notice.

**See:** <https://www.gnu.org/licenses/gpl-howto.en.html#license-notices>

#### $L_FREE_SOFTWARE_NOTICE

notice that the software is a free software.

#### L_quote_setx

Output a string with the same quotating style as does bash in set -x

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

#### L_quote_setx_vL_RET

#### L_quote_printf

Output a string with the same quotating style as does bash with printf

For single argument, just use `printf -v var "%q" "$var"`. Use this for more arguments, like `printf -v var "%q " "$@"` results in a trailing space.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

#### L_quote_printf_vL_RET

#### L_quote_bin_printf

Output a string with the same quotating style as does /bin/printf

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

#### L_quote_bin_printf_vL_RET

#### L_quote

Quotes a string for bash to be able to re-read it.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

#### L_quote_vL_RET

#### L_strhash

Convert a string to a number.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

#### L_strhash_vL_RET

#### L_strhash_bash

Convert a string to a number in pure bash.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** string

#### L_strhash_bash_vL_RET

#### L_strstr

Check if string contains substring.

**Arguments:**

- **`$1`** string
- **`$2`** substring

#### L_strupper

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on.

#### L_strlower

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on.

#### L_capitalize

Capitalize first character of a string.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on

#### L_uncapitalize

Lowercase first character of a string.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on

#### L_dedent

Remove common leading indentation from all lines.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to dedent.

#### L_dedent_vL_RET

#### L_strip

Remove characters from IFS from begining and end of string

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** String to operate on.
- **`[$2]`** Optional glob to strip, default is [:space:]

#### L_strip_vL_RET

**Shellcheck disable=** [SC2295](https://www.shellcheck.net/wiki/SC2295)

#### L_lstrip

Remove characters from IFS from begining of string

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** String to operate on.
- **`[$2]`** Optional glob to strip, default is [:space:]

#### L_lstrip_vL_RET

**Shellcheck disable=** [SC2295](https://www.shellcheck.net/wiki/SC2295)

#### L_rstrip

Remove characters from IFS from begining of string

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** String to operate on.
- **`[$2]`** Optional glob to strip, default is [:space:]

#### L_rstrip_vL_RET

**Shellcheck disable=** [SC2295](https://www.shellcheck.net/wiki/SC2295)

#### L_list_functions_with_prefix

list functions with prefix

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** prefix

#### L_list_functions_with_prefix_vL_RET

#### L_list_functions_with_prefix_removed

list functions with prefix and remove the prefix

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** prefix

**See:** [L_list_functions_with_prefix](#L_lib.sh--L_list_functions_with_prefix)

#### L_list_functions_with_prefix_removed_vL_RET

#### L_abbreviation

Choose elements matching prefix.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** prefix
- **`$@`** elements

#### L_abbreviation_vL_RET

#### L_float_cmp

compare two float numbers

The '\<=>' operator returns 9 when $1 < $2, 10 when $1 == $2 and 11 when $1 > $2.

Example

```
L_float_cmp 123.234 -le 234.345
echo $?  # outputs 0
L_exit_into ret L_float_cmp 123.234 -le 234.345
echo "$ret"  # outputs 0
```

**Arguments:**

- **`$1`** one number
- **`$2`** operator, one of -lt -le -eq -ne -gt -ge > >= == != \<= < \<=>
- **`$3`** second number

#### L_float

A simple wrapper script around awk to evaluate float expressions.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** Expression to evaluate.

#### L_float_vL_RET

#### L_percent_format

Print a string with percent format.

Simple implementation of percent formatting in bash using regex and printf.

Example

```
name=John
declare -A age=([John]=42)
L_percent_format "Hello, %(name)s! You are %(age[John])10s years old.\n"
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** format string
- **`$@`** arguments

#### L_percent_format_vL_RET

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

#### L_fstring

print a string with f-string format

A simple implementation of f-strings in bash using regex and printf.

Example

```
name=John
declare -A age=([John]=42)
L_fstring 'Hello, {name}! You are {age[John]:10s} years old.\n'
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** Format string
- **`$@`** Arguments {$1} {$2} etc.

#### L_fstring_vL_RET

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

#### L_hexdump

Convert a string to hex dump.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

#### L_hexdump_vL_RET

#### L_urlencode

Encode a string in percent encoding.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

#### L_urlencode_vL_RET

#### L_urldecode

Decode percent encoding.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

#### L_urldecode_vL_RET

#### L_html_escape

Escape characters for html.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

#### L_html_escape_vL_RET

#### L_string_replace

Replace multiple characters in a string in order.

Note

I think this should be removed.

Example

```
L_string_replace -v string "$string" "&" "&amp;" "<" "&lt;"
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** String to operate on.
- **`$2`** String to replace.
- **`$3`** Replacement.
- **`$@`** String to replace and replacement can be repeated multiple times.

**See:** [L_html_escape](#L_lib.sh--L_html_escape)

#### L_string_replace_vL_RET

#### L_string_count

Count the character in string.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** String.
- **`$2`** Character to count in string.

#### L_string_count_vL_RET

#### L_string_count_lines

Count lines in a string.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** String.
- **`[$2]`** Line characters. Default: newline.

#### L_string_count_lines_vL_RET

#### L_unquote

Split a string with quotes without the risk of execution anything.

Rules:

- <https://www.gnu.org/software/bash/manual/html_node/Escape-Character.html>
- <https://www.gnu.org/software/bash/manual/html_node/Single-Quotes.html>
- <https://www.gnu.org/software/bash/manual/html_node/Double-Quotes.html>
- <https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html>

Why not xargs? To support ANSI-C quoting style $'' and support newlines in quotes.

Why not declare? Declare allows execution, `declare -a array='($(echo something >&2))'`executes echo.

Example

```
$ L_unquote -v cmd "ls -l 'somefile; rm -rf ~'"
$ declare -p cmd
declare -a cmd=([0]="ls" [1]="-l" [2]="somefile; rm -rf ~")
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-c`** Enable ignoring comments.
- **`-A`** Disable ANSI-C quoting.
- **`-h`** Print this help and return 0.
- **`-q`** Without -v, instead of printing one word per line, output words quoted with `printf %q`.

**Shellcheck disable=** [SC1003](https://www.shellcheck.net/wiki/SC1003)

#### L_fuzzy

Fuzzy search a key in a list of strings, returning matches in L_RET.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** Key to search for
- **`$@`** Candidate strings

#### L_fuzzy_vL_RET

### json

#### L_json_escape

Produces a string properly quoted for JSON inclusion

Poor man's jq

Example

```
L_json_escape -v tmp "some string"
echo "{\"key\":$tmp}" | jq .
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**See:**

- <https://ecma-international.org/wp-content/uploads/ECMA-404.pdf> figure 5
- <https://stackoverflow.com/a/27516892/9072753>

#### L_json_escape_vL_RET

#### L_json_create

Very simple function to create JSON.

Every second argument is quoted for JSON, unless This argument is preceeded by a previous argument ending with \] or }, when the counter starts over.

Example

```
L_json_create { \
  a : b , \
  b :[ 1 , 2 , 3 , 4 ] \
  c :[true, 1 ,null,false] \
}
#   ^^^^^^    ^^^^^^^^^^^^ - unquoted, added literally to the string
# outputs: {"a":"b","b":[1,2,3,4],"c":[true,"1",false,null]}
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

#### L_json_create_vL_RET

### array

Operations on various lists, arrays and arguments. L_array\_\*

#### L_array_len

Get array length.

Example

```
L_array_len arr
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

#### L_array_keys

Get array keys

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

#### L_array_max_index

Find the maximum index (key) in an array.

Return failure if the array is empty.

Example

```
L_array_max_index -v max_idx arr
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** array nameref

#### L_array_len_vL_RET

#### L_array_keys_vL_RET

#### L_array_assign

Set elements of array.

Example

```
L_array_assign arr 1 2 3
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** elements to set

#### L_array_set

Assign element of an array

Example

```
L_array_assign arr 5 "Hello"
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** array index
- **`$3`** value to assign

#### L_array_append

Append elements to array.

Example

```
L_array_append arr "Hello" "World"
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** elements to append

#### L_array_insert

Insert element at specific position in an array.

This will move all elements from the position to the end of the array.

Example

```
L_array_insert arr 2 "Hello" "World"
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** index position
- **`$@`** elements to append

#### L_array_pop_front

Remove first array element.

**Argument:** **`$1`** array nameref

#### L_array_pop_back

Remove last array element.

Example

```
L_array_pop_back arr
```

**Argument:** **`$1`** array nameref

#### L_array_is_dense

Return success, if all array elements are in sequence from 0.

Example

```
if L_array_is_dense arr; then echo "Array is dense"; fi
```

**Argument:** **`$1`** array nameref

#### L_array_copy

Copy an array.

**Arguments:**

- **`$1`** Source array.
- **`$2`** Destination array.

#### L_array_max_index_vL_RET

#### L_array_prepend

Append elements to the front of the array.

Example

```
L_array_prepend arr "Hello" "World"
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** elements to append

#### L_array_clear

Clear an array.

Example

```
L_array_clear arr
```

**Argument:** **`$1`** array nameref

#### L_array_extract

Assign array elements to variables in order.

Example

```
arr=("Hello" "World")
L_array_extract arr var1 var2
echo "$var1"  # prints Hello
echo "$var2"  # prints World
```

**Arguments:**

- **`$1`** array nameref
- **`$@`** variables to assign to

#### L_array_reverse

Reverse elements in an array.

Example

```
arr=("world" "Hello")
L_array_reverse arr
echo "${arr[@]}"  # prints Hello world
```

**Argument:** **`$1`** array nameref

#### L_readarray

Wrapper for readarray/mapfile for bash versions that do not have it.

Example

```
L_readarray arr <file
```

**Options:**

- **`-t`** Strip delimeter.
- **`-d <delim>`** separator to use, default: newline
- **`-u <fd>`** file descriptor to read from
- **`-s <count>`** skip first n lines
- **`-n <count>`** read at most n lines
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

#### L_array_pipe

Pipe an array to a command and then read back into an array.

Example

```
arr=("Hello" "World")
L_array_pipe arr tr '[:upper:]' '[:lower:]'
echo "${arr[@]}"  # prints hello world
```

**Option:** **`-z`** Use null byte as separator instead of newline.

**Arguments:**

- **`$1`** array nameref
- **`$@`** command to pipe to

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

#### L_array_contains

check if array variable contains value

Example

```
arr=("Hello" "World")
L_array_contains arr "Hello"
echo $?  # prints 0
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** needle

**See:** [L_args_contain](#L_lib.sh--L_args_contain)

#### L_array_filter_eval

Remove elements from array for which expression evaluates to failure.

Example

```
arr=("Hello" "World")
L_array_filter_eval arr '[[ "$1" == "Hello" ]]'
echo "${arr[@]}"  # prints Hello
```

**Arguments:**

- **`$1`** array nameref
- **`$2`** expression to `eval`uate with array element of index L_i and value $1

#### L_array_index

Find an index of an element in the array equal to second argument.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** array nameref
- **`$2`** element to find

#### L_array_index_vL_RET

#### L_array_join

Join array elements separated with the second argument.

Example

```
arr=("Hello" "World")
L_array_join -v res arr ", "
echo "$res"  # prints Hello, World
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** array nameref
- **`$2`** string to join elements with

**See:** [L_args_join](#L_lib.sh--L_args_join)

#### L_array_join_vL_RET

#### L_array_andjoin

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

**See:** [L_args_andjoin](#L_lib.sh--L_args_andjoin)

#### L_array_andjoin_vL_RET

### args

Operations on list of arguments.

#### L_args_join

Join arguments with separator

Example

```
L_args_join -v res ", " "Hello" "World"
echo "$res"  # prints Hello, World
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** separator
- **`$@`** arguments to join

**See:** [L_array_join](#L_lib.sh--L_array_join)

#### L_args_join_vL_RET

#### L_args_andjoin

Join arguments with ", " and last with " and "

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to join

#### L_args_andjoin_vL_RET

#### L_args_contain

Check if arguments starting from second contain the first argument.

Example

```
L_args_contain "Hello" "Hello" "World"
echo $?  # prints 0
```

**Arguments:**

- **`$1`** needle
- **`$@`** heystack

#### L_args_index

Get index number of argument equal to the first argument.

Example

```
L_args_index -v res "World" "Hello" "World"
echo "$res"  # prints 1
```

**Option:** **`-v <var>`**

**Arguments:**

- **`$1`** needle
- **`$@`** heystack

#### L_args_index_vL_RET

#### L_max

return max of arguments

Example

```
L_max -v max 1 2 3 4
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** int arguments

#### L_max_vL_RET

**Sets variable:** **`L_RET`**

**Shellcheck disable=** [SC1105](https://www.shellcheck.net/wiki/SC1105) [SC2094](https://www.shellcheck.net/wiki/SC2094) [SC2035](https://www.shellcheck.net/wiki/SC2035)

#### L_min

return max of arguments

Example

```
L_min -v min 1 2 3 4
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** int arguments

#### L_min_vL_RET

**Sets variable:** **`L_RET`**

**Shellcheck disable=** [SC1105](https://www.shellcheck.net/wiki/SC1105) [SC2094](https://www.shellcheck.net/wiki/SC2094) [SC2035](https://www.shellcheck.net/wiki/SC2035)

### utilities

Various self contained functions that could be separate programs.

#### L_table

Make a table

Example

```
$ L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
name1 name2 name3
    a     b c
    d     e f
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-s <separator>`** IFS column separator to use. Default: space or tab.
- **`-o <str>`** Output separator to use
- **`-R <list[int]>`** Right align columns with these indexes
- **`-X`** Ignore color escape sequences when calculting column width.
- **`-h`** Print this help and return 0.

**Argument:** **`$@`** Lines to print, joined and separated by newline.

**Shellcheck disable=** [SC1105](https://www.shellcheck.net/wiki/SC1105) [SC2201](https://www.shellcheck.net/wiki/SC2201) [SC2102](https://www.shellcheck.net/wiki/SC2102) [SC2035](https://www.shellcheck.net/wiki/SC2035) [SC2211](https://www.shellcheck.net/wiki/SC2211) [SC2283](https://www.shellcheck.net/wiki/SC2283) [SC2094](https://www.shellcheck.net/wiki/SC2094)

#### L_parse_range_list

Parse cut range list into an array.

Each LIST is made up of one range, or many ranges separated by commas. Selected input is written in the same order that it is read, and is written exactly once. Each range is one of: N N'th byte, character or field, counted from 1 N- from N'th byte, character or field, to end of line N-M from N'th to M'th (included) byte, character or field -M from first to M'th (included) byte, character or field

Example

```
$ L_parse_range_list 1-4,3-5
1
2
3
4
5
$ L_parse_range_list -v tmp '1-4 3-5'
$ echo "${tmp[@]}"
1 2 3 4 5
$ echo "${!tmp[@]}"
1 2 3 4 5
$ if L_var_is_set "tmp[3]"; then echo "yes"; else echo "no"; fi
yes
$ if L_args_contain 3 "${tmp[@]}"; then echo "yes"; else echo "no"; fi
yes
$ if L_args_contain 7 "${tmp[@]}"; then echo "yes"; else echo "no"; fi
no
```

**Options:**

- **`-v <var>`**

  Store the output in variable instead of printing it.

  The variable array has both indexes and values set.

- **`-m <int>`** Maximum number of columns. Default: 100

- **`-C`** Complement the selection.

- **`-h`** Print this help and return 0.

**Argument:** **`$1`** list of fields

#### L_pretty_print

Pretty print values.

If expression is variable prefix suffixed by '\**', print as an array of structures. If expression is variable with '*?[]' glob characteres, print all variables matching that glob. If expression is varaible, print that variable. Otherwise, just prints the expression.

Example

```
var=5 arr=(1 2); L_pp "Note:" var arr
# Outputs: Note: var=5 arr=(1 2)
key_service="Hello" url_service="World"; L_pp '*_service'
# Outputs: *_service{key_service=Hello url_service=World}
humans_name=(Carl Susan [5]=Mike) humans_age=(15 30 40); L_pp 'humans_**'
# Outputs: humans_**{[0]={age=15 name=Carl} [1]={age=30 name=Susan} [2]={age=40 names=''} [5]={age='' name=Mike}}
```

**Options:**

- **`-p <str>`** Prefix each line with this prefix
- **`-v <var>`** Store the output in variable instead of printing it.
- **`-w <int>`** Set output width for compact output.
- **`-c`** Make the output compact. The default.
- **`-m`** Multiline output. Invert of -c.
- **`-C`** Alias for -m.
- **`-h`** Print this help and return 0.

**Argument:** **`<expr...>`** Expressions to pretty print.

**Shellcheck disable=** [SC2053](https://www.shellcheck.net/wiki/SC2053)

#### L_pp

Alias for L_pretty_print

**See:** [L_pretty_print](#L_lib.sh--L_pretty_print)

#### L_argskeywords

Parse python-like positional and keyword arguments format.

The difference to python is that `@` is used instead of `*`, becuase `*` triggers filename expansion. An argument `--` signifies end of arguments definition and start of arguments to parse.

Example

```
range() {
   local start stop step
    L_argskeywords start stop step=1 -- "$@" || return "$L_EX_USAGE"
    for ((; start < stop; start += stop)); do echo "$start"; done
}
range start=1 stop=6 step=2
range 1 6

max() {
   local arg1 arg2 args key
   L_argskeywords arg1 arg2 @args key='' -- "$@" || return "$L_EX_USAGE"
   ...
}
max 1 2 3 4

int() {
   local string base
   L_argskeywords string / base=10 -- "$@" || return "$L_EX_USAGE"
   ...
}
int 10 7 # error
int 10 base=7
```

**Options:**

- **`-A <var>`** Instead of storing in variables, store values in specified associative array with variables as key.
- **`-M`** Use L_map instead of associative array, for @@kwargs and -A option. Usefull for older Bash.
- **`-E`** Exit on error
- **`-e <str>`** Prefix error messages with this prefix. Default: "${FUNCNAME[1]}:L_argskeywords:"
- **`-c <str>`** Automatically local-declare all argument variables and evaluate this command.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$@`** Python arguments format specification
- ## **`$2`**
- **`$@`** Arguments to parse

**See:**

- <https://docs.python.org/3/reference/compound_stmts.html#function-definitions>
- <https://realpython.com/python-asterisk-and-slash-special-parameters/>

#### L_version_cmp

This command has two distinct modes of operation, depending on whether the operator OP is specified.

In the first mode when OP is not specified, it will compare the two version strings and print either "VERSION1 < VERSION2", or "VERSION1 == VERSION2", or "VERSION1 > VERSION2" as appropriate.

The exit status is 0 if the versions are equal, 11 if the version of the right is smaller, and 12 if the version of the left is smaller. (This matches the convention used by rpmdev-vercmp.)

In the second mode when OP is specified, it will compare the two version strings using the operation OP and return 0 (success) if they condition is satisfied, and 1 (failure) otherwise. OP may be lt, le, eq, ne, ge, gt, \<, \<=, ==, !=, >< >=. In this mode, no output is printed. (This matches the convention used by dpkg(1) --compare-versions.)

Additionally the function supports '~=' operator, which checks if VERSION1 is a compatible release of VERSION2. For a given release identifier V.N, the compatible release clause is approximately equivalent to the pair of comparison clauses: L_version_cmp "$left" >= V.N && \[[ "$left" == V.\* ]\]

Example

```
$ L_version_cmp systemd-250~rc1.fc36.aarch64 systemd-251.fc36.aarch64
systemd-250~rc1.fc36.aarch64 < systemd-251.fc36.aarch64
$ echo $?
12
$ L_version_cmp 1 lt 2; echo $?
0
$ L_version_cmp 1 ge 2; echo $?
1
```

**Arguments:**

- VERSION1
- **`[OP]`**
- VERSION2

**Shellcheck disable=** [SC2053](https://www.shellcheck.net/wiki/SC2053)

**See:**

- <https://uapi-group.org/specifications/specs/version_format_specification/>
- <https://github.com/systemd/systemd/blob/main/src/fundamental/string-util.c#L78>
- <https://www.freedesktop.org/software/systemd/man/latest/systemd-analyze.html#systemd-analyze%20compare-versions%20VERSION1%20%5BOP%5D%20VERSION2>
- <https://peps.python.org/pep-0440/>

### log

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

#### $L_LOGLEVEL_CRITICAL

#### $L_LOGLEVEL_ERROR

#### $L_LOGLEVEL_WARNING

#### $L_LOGLEVEL_NOTICE

#### $L_LOGLEVEL_INFO

#### $L_LOGLEVEL_DEBUG

#### $L_LOGLEVEL_TRACE

#### $L_LOGLEVEL_NAMES

convert log level to log name

#### $L_LOGLEVEL_COLORS

get color associated with particular loglevel

**Shellcheck disable=** [SC2153](https://www.shellcheck.net/wiki/SC2153)

#### L_log_configure

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

#### L_log_level_inc

increase log level

**Argument:** **`$1`** amount, default: 10

#### L_log_level_dec

decrease log level

**Argument:** **`$1`** amount, default: 10

#### L_log_level_to_int_into

Convert log string to number

**Arguments:**

- **`$1`** str variable name
- **`$2`** int|str loglevel like `INFO` `info` or `30`

#### L_log_is_enabled_for

Check if log of such level is enabled to log.

**Argument:** **`$1`** str|int loglevel or log string

#### L_log_format_default

Default logging formatting

**Arguments:**

- **`$1`** str log line printf format string
- **`$@`** any log line printf arguments

#### L_log_format_long

Format logline with timestamp information.

**Arguments:**

- **`$1`** str log line printf format string
- **`$@`** any log line printf arguments

#### L_log_format_json

Output logs in json format.

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

#### L_log_output_to_stderr

Output L_logline to stderr.

#### L_log_output_to_logger

Output L_logline with logger.

**Argument:** **`$@`** message to output

#### L_log

main logging entrypoint

**Options:**

- **`-s <int>`** Increment stacklevel by this much
- **`-l <int|string>`** loglevel to print log line as

**Argument:** **`$@`** any log arguments

**Shellcheck disable=** [SC2140](https://www.shellcheck.net/wiki/SC2140)

**Return:** 0 if nothing was logged, or the exit status of formatter && outputter functions.

#### L_critical

output a critical message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_error

output a error message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_warning

output a warning message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_notice

output a notice

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_info

output a information message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_debug

output a debugging message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_trace

output a tracing message

**Option:** **`-s <int>`** stacklevel increase

**Argument:** **`$1`** message

#### L_fatal

Output a critical message and exit the script with 64 ($L_EX_USAGE).

**Argument:** **`$@`** L_critical arguments

#### L_logrun

log a command and then execute it

Is not affected by L_dryrun variable.

**Argument:** **`$@`** command to execute

#### L_ok

Output a green information message

**Options:**

- **`-s <int>`** stacklevel increase
- **`-l <level>`** loglevel to print log line as
- **`-h`** Show help

**Argument:** **`$1`** message

#### $L_dryrun

set to 1 if L_run should not execute the function.

#### L_run

Logs the quoted argument with a leading +.

if L_dryrun is nonzero, executes the arguments.

**Options:**

- **`-l <loglevel>`** Set loglevel.
- **`-s <stacklevel>`** Increment stacklevel by this number.
- **`-h`** Print this help and return 0.

**Argument:** **`$@`** command to execute

**Uses environment variable:** **`L_dryrun`**

### sort

Array sorting function.

#### L_shuf_bash

Shuffle an array

**Argument:** **`$1`** array nameref

#### L_shuf_cmd

Shuffle an array using shuf command

**Option:** **`-z --zero-terminated`** use zero separated stream with shuf -z

**Arguments:**

- **`$*`** any options are forwarded to shuf command
- **`$-1`** array nameref

#### L_shuf

Shuffle an array

**Argument:** **`$1`** array nameref

#### L_sort_bash

Quicksort an array in place in pure bash.

**Options:**

- **`-z`** ignored. Always zero sorting.
- **`-n`** Numeric sort, otherwise lexical.
- **`-g`** Floating point number sort.
- **`-r`** Reverse sort.
- **`-u`** Unique values only.
- **`-c <compare>`** Custom compare function that returns 0 when $1 > $2 and 1 otherwise.
- **`-E <eval>`** Custom expression to evaluate just like -c option.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

**See:** [L_sort](#L_lib.sh--L_sort)

#### L_sort_cmd

Sort an array using sort command.

Even in most optimized code that I could write for bash sorting, still executing sort command is faster. The difference becomes significant for large arrays. Sorting 100 element array with bash is 0.049s and with sort is 0.022s.

Example

```
arr=(5 2 5 1)
L_sort_cmd -n arr
echo "${arr[@]}"  # 1 2 5 5
```

**Options:**

- **`-z --zero-terminated`** use zero separated stream with sort -z
- **`-n`** numeric sort

**Arguments:**

- **`$*`** any options are forwarded to sort command
- **`$-1`** last argument is the array nameref

#### L_sort

Sort a bash array.

Dispatches to L_sort_bash if array length < 300 or a custom comparison (-c, -E) is provided. Otherwise, it uses L_sort_cmd for performance (calling the system sort command).

**Options:**

- **`-z`** Use zero separated stream with sort -z (forwarded to sort command)
- **`-n`** numeric sort
- **`-r`** reverse sort
- **`-u`** unique values only
- **`-c <compare>`** Custom compare function (uses L_sort_bash)
- **`-E <eval>`** Custom expression to evaluate (uses L_sort_bash)
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** array nameref

**See:**

- [L_sort_bash](#L_lib.sh--L_sort_bash)
- [L_sort_cmd](#L_lib.sh--L_sort_cmd)

### trap

#### L_print_traceback

Prints traceback

Example

```
Example traceback:
Traceback from pid 3973390 (most recent call last):
  File ./bin/L_lib.sh, line 2921, in main()
2921 >> _L_lib_main "$@"
  File ./bin/L_lib.sh, line 2912, in _L_lib_main()
2912 >>                 "test") _L_lib_run_tests "$@"; ;;
  File ./bin/L_lib.sh, line 2793, in _L_lib_run_tests()
2793 >>                 "$_L_test"
  File ./bin/L_lib.sh, line 891, in _L_test_other()
891  >>                 L_unittest_eq "$max" 4
  File ./bin/L_lib.sh, line 1412, in L_unittest_eq()
1412 >>                 _L_unittest_showdiff "$1" "$2"
  File ./bin/L_lib.sh, line 1391, in _L_unittest_showdiff()
1391 >>                 sdiff <(cat <<<"$1") - <<<"$2"
```

**Arguments:**

- **`[$1]`** int stack offset to start from (default: 0)
- **`[$2]`** int number of lines to show around the line (default: 2)

**Uses environment variable:** **`_L_print_traceback_offset`**

#### L_print_caller

Print simple traceback using builtin caller command.

#### L_trap_err_small

Callback to be exectued on ERR trap that prints just the caller.

Example

```
trap 'L_trap_err_small' ERR
```

#### L_trap_err

Callback to be exectued on ERR trap that prints a traceback and exits.

Example

```
trap 'L_trap_err $?' ERR
trap 'L_trap_err $?' EXIT
```

**Arguments:**

- **`$1`** int exit code
- **`$2`** BASH_COMMAND

#### L_trap_err_enable

Enable ERR trap with L_trap_err as callback

set -eEo functrace and register trap 'L_trap_err $?' ERR.

Example

```
L_trap_err_enable
```

#### L_trap_err_disable

Disable ERR trap

Example

```
L_trap_err_disable
```

#### L_trap_err_init

If set -e is set and ERR trap is not set, enable ERR trap with L_trap_err as callback

Example

```
L_trap_err_init
```

#### L_trap_names

Return an array of all trap names. Index is the trap name number.

**Option:** **`-v <var>`**

#### L_trap_names_vL_RET

#### L_trap_to_number

Convert trap name to number.

The DEBUG ERROR and RETURN traps have a number as reported by $BASH_TRAPSIG inside the handler, but the number can't be used to register the trap with trap command.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** trap name or trap number

#### L_trap_to_number_vL_RET

#### L_trap_to_name

convert trap number to trap name

Example

```
L_trap_to_name -v var 0 && L_assert '' test "$var" = EXIT
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** signal name or signal number

#### L_trap_to_name_vL_RET

#### L_trap_get

Get the current value of trap

Example

```
trap 'echo hi' EXIT
L_trap_get -v var EXIT
L_assert '' test "$var" = 'echo hi'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** signal name or number

#### L_trap_get_vL_RET

#### L_trap_push

Add a newline and the command to the trap value.

**Arguments:**

- **`$1`** str command to execute
- **`$2`** str signal to handle

**Shellcheck disable=** [SC2064](https://www.shellcheck.net/wiki/SC2064)

**See:** [L_trap_pop](#L_lib.sh--L_trap_pop)

#### L_trap_pop

Remove a line from the trap value from the end up until the last newline.

**Argument:** **`$1`** str signal to handle

**Shellcheck disable=** [SC2064](https://www.shellcheck.net/wiki/SC2064)

**See:** [L_trap_push](#L_lib.sh--L_trap_push)

#### L_trap

Trap function with reversed order of arguments, to force expansions upon calling.

**Arguments:**

- **`$1`** Space or comma separated list of signal names or numbers.
- **`$@`** Action to execute.

### finally

Properly preserve exit status for parent processes. <https://www.cons.org/cracauer/sigint.html> Re-signaling does not work properly on specific signals. Re-signaling does not work properly in subshells and subshell exits with 0.

Array of commands to execute on EXIT.

\_L_finally_arr=()

Array of commands to execute on function returns.

When a function returns at stack depth given by ${#BASH_LINENO[@]} the \_L_finally_return\[${#BASH_LINENO[@]}\] should be executed. \_L_finally_return=()

BASHPID that registered traps.

\_L_finally_pid=""

Holds the signal name received inside a critical section.

\_L_finally_pending=""

Use to detect nesting of signals.

\_L_finally_running=0

Currently handled signal name.

Special values: RETURN EXIT POP NONE POP - when calling from L_finally_pop NONE - used inside critical section. L_SIGNAL=""

The value of $? as expanded by trap.

L_SIGRET=""

#### L_finally_handle_return

L_finally RETURN handler.

**Arguments:**

- **`$1`** The value of $?.
- **`$2`** The value of $BASH_COMMAND.

#### L_finally_handle_exit

L_finally EXIT handler.

#### L_finally_handle_signal

L_finally signal handler.

**Arguments:**

- **`$1`** The trap signal name to handle.
- **`$2`** The value of $?.

#### L_finally_list

List elements registered by L_finally.

#### L_finally

Register an action to be executed upon termination.

The action will be executed once, even if the signal is received multiple times. The signal exit code of the program or subshell is preserved. The variable `$L_SIGNAL` is available during execution of the action and is set to the currently handled signal.

Warning

The function assumes full ownership of all trap values.

This is needed to properly set traps accross PIDs and subshells and functions and on Bash below 5.2. Bash below 5.2 does *not* execute EXIT trap in subshells after receiving a signal, so `L_finally` trap handler is registered on all possible signals. The signal exit status is preserved.

There are 3 queues available - first, normal and last. They are executed in order. The queue is chosen with options -f and -l. Elemenets added to first and normal queues are executed in the reverse order of added. Elements added to the last queue are executed in the order they were added. Usually you want to use the normal queue. However is it sometimes usefull to use last and first queues. For example, an algorithm spawning background processes might kill all background processes in the first queue, and then wait on the processes in the last queue, giving other registerered callbacks chance to executed in the normal queue before blocking waiting.

Example

```
tmpf=$(mktemp)
L_finally rm "$tmpf"

calculate_something() {
   local tmpf
   tmpf=$(mktemp)
   L_finally -r rm "$tmpf"
   echo use tmpf >"$tmpf"
   # tmpf automatically cleaned up once on RETURN or EXIT or signal, whichever comes first.
}
```

**Options:**

- **`-r`**

  Set trace attribute on the function and add RETURN trap to register the function on.

  This does not work correctly with source and instead source RETURN trap will execute parent scope actions. To mitigate this, wrap source in a function, for example use L_source.

- **`-s <int>`**

  Increment the stack offset for the RETURN trap by this number.

  The RETURN trap handler will execute the action only if called from the nth position in the stack relative to the current position. Default: 0

- **`-l`** Add action to be the last queue.

- **`-f`** Add action to be the first queue.

- **`-R`**

  Force reregister all the traps. Unless this option, traps are only

  registered on the first call of a BASHPID.

- **`-v <var>`**

  Store the action index in the variable.

  This index can be used with `L_finally_pop -i` to remove the action.

- **`-h`** Print this help and return 0.

**Argument:** **`$@`**

Action to execute. When action is missing, then only traps are registered.

The command may not call `eval 'return'`. It would just return from the handler function.

**Shellcheck disable=** [SC2089](https://www.shellcheck.net/wiki/SC2089) [SC2090](https://www.shellcheck.net/wiki/SC2090)

**See:** [L_finally_pop](#L_lib.sh--L_finally_pop)

#### L_finally_pop

Execute and unregister the last action registered with L_finally.

**Options:**

- **`-n`** Do not execute the action, only remove.
- **`-i <index>`** Remove action of index .
- **`-h`** Print this help and return 0.

**Return:**

1 if nothing was popped, 64 ($L_EX_USAGE) on invalid usage,

otherwise return the exit status of the executed action.

**See:** [L_finally](#L_lib.sh--L_finally)

#### L_finally_critical_section

Execute a command inside a critical section.

The signals will be raised after the command is finished. Prerequisite: L_finally has registered signal handlers.

**Argument:** **`$@`** Command to execute.

### with

What we can do with finally? We can do destructors.

#### L_with_cd

Change to given directory.

Register RETURN trap for parent function that will restore current working directory.

**Arguments:**

- **`$1`** Directory to cd into.
- **`[$2]`** Optional stack offset to add to RETURN trap.

#### L_with_tmpfile_into

Create a temporary directory.

Register RETURN trap for parent fuction that will remove the directory.

**Arguments:**

- **`$1`** Variable to assign the temporary file to.
- **`[$2]`** Optional stack offset to add to RETURN trap.

#### L_with_tmpdir_into

Create a temporary directory.

Register RETURN trap for parent fuction that will remove the directory.

**Arguments:**

- **`$1`** Variable to assign the temporary directory location to.
- **`[$2]`** Optional stack offset to add to RETURN trap.

#### L_with_cd_tmpdir

Create a temporary directory and cd into it.

Register RETURN trap that will remove the temporary directory and restore working directory on return from parent function.

**Argument:** **`[$1]`** Optional stack offset to add to RETURN trap.

#### L_with_process_into

Run command in background and store its PID in variable.

Register RETURN trap that will kill process on return from parent function.

**Options:**

- **`-t`** Trace.
- **`-s <int>`** Stack offset for the RETURN trap.
- **`-h`** Show help.

**Arguments:**

- **`$1`** Variable to store the PID of the background process.
- **`$@`** Command to execute in the background.

#### L_with_redirect_stdout_into

Temporary redirect stdout to string.

Non-forking command substition for the poor.

**Arguments:**

- **`$1`** Variable to capture stdout to.
- **`$2`** Optional stack offset to add to RETURN trap.

### unittest

Testing library

Simple unittesting library that does simple comparison. Testing library for testing if variables are commands are returning as expected.

Note

rather stable

Example

```
L_unittest_eq 1 1
```

#### L_unittest_notice

#### L_unittest_warning

#### L_unittest_fail

#### L_unittest_skip

Skip the current unit test with a specified reason.

**Option:** **`$1`** Skipping reason.

#### L_unittest_main

Uninteresting unittesting suite runner.

**Options:**

- **`-p <prefix>`** Get functions with this prefix to test

- **`-k <expr>`**

  Run only tests whose names match EXPR. EXPR is a boolean filter:

  ```
  PATTERN            match tests containing PATTERN (regex)
  ! EXPR             negate
  EXPR && EXPR       both must match
  EXPR & EXPR        both must match
  EXPR || EXPR       either must match
  EXPR | EXPR        either must match
  ( EXPR )           grouping
  ```

  Examples: -k foo tests matching 'foo' -k 'foo && bar' tests matching both 'foo' and 'bar' -k '! slow' tests not matching 'slow' -k '(foo || bar) && ! slow'

- **`-P <nproc>`** Run tests in parallel using NPROC worker processes. If NPROC is 'nproc', use number of cores.

- **`-l`** Do not run the tests. Instead print the tests to exeucte.

- **`-q`**

  Run tests in command substitution. Print only failed tests output.

  Great for LLM for reducing context size.

- **`-d <int>`** Print a list of the slowest number of tests. Negative to print all.

- **`-x`** Exit after the first failure.

- **`-s`** Stream output directly to terminal. Do not capture stdout and stderr.

- **`-S`** Do not stream output directly to terminal. Capture stdout and stderr. The default.

- **`-c`** Execute in current shell execution context. No subshell.

- **`-F`** Alias for -c.

- **`-T`** Disable spinner and terminal features.

- **`-v`** Increase verbosity. Call L_log_level_inc.

- **`-h`** Print this help and return 0.

- **`-E`** Execute trap - ERR.

- **`-M <global-max-time>`** If running longer then specified time, tasks are getting killed.

- **`-m <task-max-time>`** If a task is running longer then specified time, it is killed.

**Argument:** **`<patterns...>`** Like -k argument, but allows one word only and joins arguments with AND.

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

#### L_unittest_checkexit

Check if command exits with specified exitcode.

**Arguments:**

- **`$1`** exit code the command should exit with
- **`$@`** command to execute

**Shellcheck disable=** [SC2035](https://www.shellcheck.net/wiki/SC2035)

#### L_unittest_success

Check if command exits with 0

**Argument:** **`$@`** command to execute

#### L_unittest_failure

Check if command exits with non zero

**Argument:** **`$@`** command to execute

#### L_unittest_failure_capture

capture stdout and stderr into variables of a failed command

**Arguments:**

- **`$1`** var stdout and stderr output
- **`$@`** command to execute

#### L_unittest_cmd

Test execution of a command and capture and test it's stdout and/or stderr output.

Local variables used by this function start with \_L_u\*. Options with *L_uopt*\*. This function optionally runs the command in the current shell or not depending on options.

Example

```
echo Hello world /tmp/1
L_unittest_cmd -r 'world' grep world /tmp/1
L_unittest_cmd -r 'No such file or directory' ! grep something not_existing_file
```

**Options:**

- **`-h`** Print this help and return 0.
- **`-c`** Run in current execution environment, instead of using a subshell.
- **`-i`** Invert exit status. You can also use `!` or `L_not` in front of the command.
- **`-I`** Do not close stdin \<&1 . By default it is closed.
- **`-f`** Expect the command to fail. Equal to `-i -j -N`.
- **`-N`** Redirect stdout of the command to >/dev/null.
- **`-j`** Redirect stderr to stdout of the command. 2>&1
- **`-x`** Run the command inside set -x
- **`-X`** Do not modify set -x
- **`-v <var>`** Store the output in variable instead of printing it.
- **`-r <regex>`** Compare output of the command with this regex.
- **`-o <str>`** Compare output of the command with this string.
- **`-e <int>`** Command should exit with this exit status (default: 0)
- **`-s <int>`** Stack up

**Argument:** **`$@`**

Command to execute.

If a command starts with `!`, this implies -i and, if one of -v -r -o option is used, it implies -j.

#### L_unittest_vareq

Test if a variable has specific value.

**Arguments:**

- **`$1`** variable nameref
- **`$2`** value
- **`$3`** Message to print on failure.

#### L_unittest_eq

Test if two strings are equal.

**Arguments:**

- **`$1`** one string
- **`$2`** second string

#### L_unittest_arreq

Test if array is equal to elements.

**Arguments:**

- **`$1`** array variable
- **`$@`** values

#### L_unittest_ne

Test two strings are not equal.

**Arguments:**

- **`$1`** one string
- **`$2`** second string

#### L_unittest_regex

test if a string matches regex

**Arguments:**

- **`$1`** string
- **`$2`** regex

#### L_unittest_contains

Test if a string contains other string.

**Arguments:**

- **`$1`** string
- **`$2`** needle

### map

Key value store without associative array support

L_map consist of an null initial value. L_map stores keys and values separated by a tab, with an empty leading newline. Value is qouted by printf %q . Map key may not contain newline or tab characters.

```
                # empty initial newline
key<TAB>$'value'
key2<TAB>$'value2' # no trailing newline
```

This format matches the regexes used in L_map_get for easy extraction using bash variable substitution. The map depends on printf %q never outputting a newline or a tab character, instead using $'\\t\\n' form.

#### L_map_assign

Initializes a map

Example

```
local var
L_map_assign var a 1 b 2
```

**Arguments:**

- **`$1`** var variable name holding the map
- **`$@`** Pairs of keys and values to assign to the map.

#### L_map_clear

Clear a map

**Argument:** **`$1`** var variable name holding the map

#### L_map_remove

Clear a key of a map

Example

```
L_map_assign var a 1
L_map_remove var a
if L_map_has var a; then
  echo "a is set"
else
  echo "a is not set"
fi
```

**Arguments:**

- **`$1`** var map
- **`$2`** str key

#### L_map_set

Set a key in a map to value

Example

```
L_map_assign var
L_map_set var a 1
L_map_set var b 2
```

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str value

#### L_map_set_noremove

Set a key in a map to value, potentially resulting in duplicate keys.

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str value

#### L_map_get

Assigns the value of key in map.

If the key is not set, then assigns default if given and returns with 1. You want to prefer this version of L_map_get

Example

```
L_map_clear var
L_map_set var a 1
L_map_get -v tmp var a
echo "$tmp"  # outputs: 1
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`[$3]`** str default

#### L_map_get_vL_RET

#### L_map_has

Example

```
L_map_clear var
L_map_set var a 1
if L_map_has var a; then
  echo "a is set"
fi
```

**Arguments:**

- **`$1`** var map
- **`$2`** str key

**Exit:** 0 if map contains key, nonzero otherwise

#### L_map_setdefault

set value of a map if not set

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str default value

#### L_map_append

Append value to an existing key in map

**Arguments:**

- **`$1`** var map
- **`$2`** str key
- **`$3`** str value to append

#### L_map_keys

List all keys in the map.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_keys -v tmp var
echo "${tmp[@]}"  # outputs: 'a b'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** var map

#### L_map_keys_vL_RET

#### L_map_values

List all values in the map.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_values -v tmp var
echo "${tmp[@]}"  # outputs: '1 2'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** var map

#### L_map_values_vL_RET

#### L_map_items

List items on newline separated key value pairs.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_items -v tmp var
echo "${tmp[@]}"  # outputs: 'a 1 b 2'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** var map

#### L_map_items_vL_RET

#### L_map_load

Load all keys to variables with the name of $prefix$key.

Example

```
L_map_clear var
L_map_set var a 1
L_map_set var b 2
L_map_load var PREFIX_
echo "$PREFIX_a $PREFIX_b"  # outputs: 1 2
```

**Arguments:**

- **`$1`** map variable
- **`$2`** prefix
- **`$@`** Optional list of keys to load. If not set, all are loaded.

#### L_map_save

Save all variables with prefix to a map.

Example

```
L_map_clear var
PREFIX_a=1
PREFIX_b=2
L_map_save var PREFIX_
L_map_items -v tmp var
echo "${tmp[@]}"  # outputs: 'a 1 b 2'
```

**Arguments:**

- **`$1`** map variable
- **`$2`** prefix

### asa

Collection of function to work on associative array.

Maybe will renamed to dict. "asa" sounds better than "assarray", less confusing than "asarray" and shorter that associative array.

Note

unstable

#### L_asa_copy

Copy associative dictionary

Notice: the destination array is cleared. Much faster then L_asa_copy. Note: Arguments are in different order.

Example

```
local -A map=([a]=b [c]=d)
local -A mapcopy=()
L_asa_copy map mapcopy
```

**Arguments:**

- **`$1`** var Source associative array
- **`$2`** var Destination associative array

#### L_asa_has

check if associative array has key

**Arguments:**

- **`$1`** associative array nameref
- **`$2`** key

#### L_asa_get

Get value from associative array

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** associative array nameref
- **`$2`** key
- **`[$3]`** optional default value

**Exit:** 1 if no key found and no default value

#### L_asa_get_vL_RET

#### L_asa_len

get the length of associative array

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** associative array nameref

#### L_asa_len_vL_RET

#### L_asa_keys

get keys of an associative array

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** associative array nameref

#### L_asa_keys_vL_RET

#### L_asa_set

assign value to associative array

You might think why this function exists? In case you have associative array name in a variable.

Example

```
local -A map
printf -v "map[a]" "%s" val  # will fail in bash 4.0
L_asa_set map a val  # will work in bash4.0
```

**Arguments:**

- **`$1`** assoatiative array variable
- **`$2`** key to assign to
- **`$3`** value to assign

#### L_asa_cmp

check if one associative array is equal to another

Example

```
local -A a=([a]=1 [b]=2)
local -A b=([a]=1 [b]=2)
if L_asa_cmp a b; then
    echo "equal"
fi
```

**Arguments:**

- **`$1`** associative array name
- **`$2`** associative array name

**Exit:** 0 if equal, 1 otherwise

### argparse

argument parsing in bash

#### L_argparse_fatal

Print argument parsing error and exit.

**Uses environment variables:**

- **`L_NAME`**
- **`_L_parser`**

**Exit:** 1

#### L_argparse_print_help

Print help for current parser.

Syntax:

```
Usage: prog_name cmd1 cmd2 [-abcd] [+abcd] [--option1] [-o ARG] arg
                                                                ^^^  - _L_args_usage
                                           ^^^^^^^^^^^^^^^^^^^^      - _L_options_usage
                           ^^^^^^^ ^^^^^^                            - _L_options_usage_noargs
       ^^^^^^^^^^^^^^^^^^^                                           - _L_prog
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  - usage string
Options:
  -o --option ARG     Help message
                      ^^^^^^^^^^^^   - help message
  ^^^^^^^^^^^^^^^                    - header
  ^^^^^^^^^^^^^^^$'\n'^^^^^^^^^^^    - _L_usage_args_helps _L_usage_cmds_helps _L_options_helps
```

**Options:**

- **`-u`** print only usage, not full help
- **`-s`** Alias to -u
- **`-e`** Print this error message
- **`-h`** Print this help and return 0.

**Argument:** **`$@`** error message to print

**Shellcheck disable=** [SC2120](https://www.shellcheck.net/wiki/SC2120)

#### L_argparse_print_usage

Print usage.

**Shellcheck disable=** [SC2120](https://www.shellcheck.net/wiki/SC2120)

#### $L_argparse_template_help

Add -h --help option

Example

```
L_argparse -- "${L_argparse_template_help[@]}" ---- "$@"
```

**See:** [L_argparse_template_verbose](#L_lib.sh--L_argparse_template_verbose)

#### $L_argparse_template_verbose

Add -v --verbose option that increases log level

Example

```
L_argparse -- "${L_argparse_template_verbose[@]}" ---- "$@"
```

**See:** [L_argparse_template_quiet](#L_lib.sh--L_argparse_template_quiet)

#### $L_argparse_template_quiet

Add -q --quiet options that decreses log level

Example

```
L_argparse -- "${L_argparse_template_quiet[@]}" ---- "$@"
```

**See:** [L_argparse_template_dryrun](#L_lib.sh--L_argparse_template_dryrun)

#### $L_argparse_template_dryrun

Add -n --dryrun argument to argparse.

Example

```
L_argparse -- "${_L_argparse_template_dryrun[@]}" ---- "$@"
```

**See:** [L_argparse_template_help](#L_lib.sh--L_argparse_template_help)

#### L_argparse_compgen

Run compgen that outputs correctly formatted completion stream.

With option description prefixed with the 'plain' prefix. Any compgen option is accepted, arguments are forwarded to compgen.

**Options:**

- **`-ANY`** Any options supported by compgen, except -P and -S
- **`-D <str>`** Specify the description of appended to the result. If description is an empty string, it is not printed. Default: help of the option.

**Argument:** **`$1`** incomplete

**Exit:** 0 if compgen returned 0 or 1, otherwise 64 ($L_EX_USAGE)

#### L_argparse

Parse command line aruments according to specification.

This command takes groups of command line arguments separated by `--` with sentinel `----` . The first group of arguments are arguments \_L_parser. The next group of arguments are arguments \_L_optspec. The last group of arguments are command line arguments passed to `_L_argparse_parse_args`.

Note

the last separator `----` is different to make it more clear and restrict parsing better.

### proc

Processes and jobs related functions.

#### L_bashpid_into

Get bashpid in a way compatible with Bash before 4.0.

**Argument:** **`$1`** Variable to store the result to.

#### L_raise

Send signal to itself.

**Argument:** **`$@`** Kill arguments. See kill --help.

**Shellcheck disable=** [SC2119](https://www.shellcheck.net/wiki/SC2119) [SC2120](https://www.shellcheck.net/wiki/SC2120)

#### L_kill_all_jobs

#### L_wait_all_jobs

#### L_get_all_childs

Get all pids of all child processes including grandchildren recursively.

**Option:** **`-v <var>`**

**Argument:** **`[$1]`** Pid of the parent. Default: $BASHPID.

**See:** <https://stackoverflow.com/a/52544126/9072753>

#### L_get_all_childs_vL_RET

**Shellcheck disable=** [SC2207](https://www.shellcheck.net/wiki/SC2207)

#### L_kill_all_childs

Kills all childs of the pid recursive.

**Arguments:**

- **`-sigspec`** Signal to use.
- **`[$1]`** Pid of the process to kill all childs of. Defualt: $BASHPID

#### L_is_fd_open

Check if file descriptor is open.

**Argument:** **`$1`** file descriptor

**Shellcheck disable=** [SC2188](https://www.shellcheck.net/wiki/SC2188)

#### L_get_free_fd_into

Get free file descriptors

Note

No valid variable name check is done on .

**Arguments:**

- **`<var>`** Variable to assign file descriptors to.
- **`[int]`** Number of array elements to assign.

#### L_mktemp

Create a temporary file natively in Bash.

This avoids the overhead of calling the mktemp utility. Performance: ~2x faster than 'mktemp' utility by avoiding subshells and external binary execution. No L_mktemp -d, cause mktemp -d is faster then shell implementation. It uses 'set -C' (noclobber) for atomic file creation.

Example

```
L_mktemp -v tmp
echo "data" > "$tmp"
rm "$tmp"
```

**Option:** **`-v <var>`** variable name to assign result to

**Argument:** **`[str]`** template temporary filename, default: ${TMPDIR:/tmp}/L_mktemp.XXXXXXXXXX

#### L_mktemp_vL_RET

**Shellcheck disable=** [SC2188](https://www.shellcheck.net/wiki/SC2188)

#### L_pipe

Open two connected file descriptors.

This internally creates a temporary file with mkfifo. It avoids the overhead of calling the mktemp utility. The result variable is assigned an array that:

- [0] element is the output from the pipe (read end),
- [1] element is the input to the pipe (write end). This is meant to mimic the pipe() C function.

Example

```
L_pipe tmp
L_array_extract tmp out in
echo 123 >&"$in"
exec "$in">&-
cat <&"$out"
exec "$out"<&-
```

**Arguments:**

- **`<var>`** variable name to assign result to
- **`[str]`** template temporary filename, default: ${TMPDIR:/tmp}/L_pipe.XXXXXXXXXX

#### L_mkstemp

Open file descriptors read-write connected to a deleted temporary file.

This internally creates a temporary file and immidately removes it.

**Arguments:**

- var Variable to assign file descriptors to.
- **`[int]`** Number of array elements to assign.

**Shellcheck disable=** [SC2093](https://www.shellcheck.net/wiki/SC2093) [SC2102](https://www.shellcheck.net/wiki/SC2102)

#### L_close_fd

Note

No checking is performed.

**Argument:** **`<int..>`** File descriptors to close.

**Shellcheck disable=** [SC2294](https://www.shellcheck.net/wiki/SC2294)

#### L_proc_popen

Process open. Coproc replacement.

The input/output options are in three groups:

- -I and -i for stdin,
- -O and -o for stdout,
- -E and -e for stderr.

Uppercase letter option specifies the mode for the file descriptor.

There are following modes available that you can give to uppercase options -I -O and -E:

- null - redirect to or from /dev/null
- close - close the file descriptor >&-
- input - -i specifies the string to forward to stdin. Only allowed for -I.
- stdout - connect file descriptor to stdout. -o or -e value are ignored.
- stderr - connect file descriptor to stderr. -o or -e value are ignored.
- pipe - create a fifo and connect file descriptor to it. -i -o or -e option specifies part of the temporary filename.
- file - connect file descriptor to file specified by -i -o or -e option
- fd - connect file descriptor to another file descriptor specified by -i -o or -e option

There first argument specifies an output variable that will be assigned the PID.

Several global array variables hold additional information about the process:

- `_L_PROC_EXIT[PID]` - Exitcode or empty if not yet finished.
- `_L_PROC_FD0[PID]` - If -Ipipe the file descriptor connected to stdin of the program, otherwise empty.
- `_L_PROC_FD1[PID]` - If -Opipe the file descriptor connected to stdout of the program, otherwise empty.
- `_L_PROC_FD2[PID]` - If -Epipe the file descriptor connected to stderr of the program, otherwise empty.
- `_L_PROC_CMD[PID]` - The %q escaped command that was executed.

You should use getters `L_proc_get_*` to extract the data from them variable.

Example

```
L_proc_popen -Ipipe -Opipe -Estdout proc sed 's/w/W/g'
L_proc_printf proc "%s\n" "Hello world"
L_proc_read proc line
L_proc_wait -c -v exitcode proc
echo "$line"
echo "$exitcode"
```

**Options:**

- **`-I <mode>`** stdin mode
- **`-i <param>`** string for -Iinput, file for -Ifile, fd for -Ifd
- **`-O <mode>`** stdout mode
- **`-o <param>`** file for -Ifile, fd for -Ifd
- **`-E <mode>`** stderr mode
- **`-e <param>`** file for -Efile, fd for -Efd
- **`-n`** Dryrun mode. Do not execute the generated command. Instead print it to stdout.
- **`-W <int>`** Register with L_finally a return trap on stacklevel that will wait for the popen to finish. Typically -W 0
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** variable name to store the result to.
- **`$@`** command to execute.

#### L_proc_get_exitcode

Get exitcode of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_get_exitcode_vL_RET

#### L_proc_get_pid

Get PID from L_proc_popen of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_get_pid_vL_RET

#### L_proc_get_stdin

Get file descriptor for stdin of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_get_stdin_vL_RET

#### L_proc_get_stdout

Get file descriptor for stdout of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_get_stdout_vL_RET

#### L_proc_get_stderr

Get file descriptor for stderr of L_proc.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_get_stderr_vL_RET

#### L_proc_get_cmd

Get command of L_proc.

**Option:** **`-v <var>`** Store the output in the array variable instead of printing it.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_get_cmd_vL_RET

#### L_proc_free

#### L_proc_popen_finally

Handler that can be closed from L_finally or a signal handler.

Closes file descriptors. If L_SIGNAL is a signal, forwards it to the process. Then wait for the process termination.

Example

```
L_proc_popen pid sleep infinity
L_finally L_proc_popen_finally "$pid"

# or, defer reading the variable until cleanup runs (e.g. if it may go out of scope):
L_proc_popen pid sleep infinity
L_finally L_eval 'L_proc_popen_finally "${!1}"' pid
```

**Argument:** **`$1`**

L_proc **value**. This is because the variable may go out of scope.

This is bad. when closing a file descriptor, we "remember" that the file descriptor was closed in the variable. This is less then ideal, but I do not know at this time how to fix it better. Potentially, this can cause unrelated file descriptors to get closed. This might change in the future.

#### L_proc_printf

Write printf formatted string to coproc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$@`** any printf arguments

#### L_proc_read

Exec read bultin with -u file descriptor of stdout of coproc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$@`** any builtin read options

#### L_proc_read_stderr

Exec read bultin with -u file descriptor of stderr of coproc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$@`** any builtin read options

**See:** [L_proc_read](#L_lib.sh--L_proc_read)

#### L_proc_close

Close stdin, stdout and stderr of L_proc

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_close_stdin

Close stdin of L_proc.

Does nothing if already closed or not started with -Opipe.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_close_stdout

Close stdout of L_proc.

Does nothing if already closed or not started with -Opipe

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_close_stderr

Close stderr of L_proc.

Does nothing if already closed or not started with -Epipe.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_poll

Check if L_proc is finished.

**Argument:** **`$1`** PID from L_proc_popen

**Exit:** 0 if L_proc is running, 1 otherwise

#### L_wait

Wait for pids to be finished with a timeout and capture exit codes.

Tries to use waitpid or tail --pid or a busy loop for best performance.

The waiting is uninterruptible by signals.

Note: builtin kill with multiple pids has different exit code depending on posix mode.

**Options:**

- **`-t <timeout>`** Wait for this long. Timeout 0 results in just collecting all pids.
- **`-v <var>`** Exit code of PIDs will be assigned to . The elements of -v and -p arrays are pairs.
- **`-p <var>`** PIDs that exited will be assigned to array variable .
- **`-l <var>`** Left running PIDs will be assigned to array variable .
- **`-P <polltime>`** The time to poll processes when not possible to use waitpid or tail. Default: 0.1
- **`-n`** Return 0 when at least one of the pids is finished.
- **`-b`** Bash only. Do not use waitpid or tail.
- **`-h`** Print this help and exit.

**Argument:** **`$@`** pids to wait on

**Return:**

0 on success

64 ($L_EX_USAGE) usage error 124 ($L_EX_TIMEOUT) timeout

#### L_proc_wait

Wait for L_proc to finish.

If L_proc has already finished execution, will only evaluate -v option.

**Options:**

- **`-t <int>`** Timeout in seconds. Will try to use waitpid, tail --pid or busy loop with sleep.
- **`-v <var>`** Store the L_proc exit code in the variable.
- **`-c`** Close L_proc file descriptors before waiting.
- **`-h`** Print this help and return 0.

**Argument:** **`$1`** PID from L_proc_popen

**Exit:**

0 if L_proc has finished

124 ($L_EX_TIMEOUT) if timeout expired

#### L_read_fds

Read from multiple file descriptors at the same time.

Note

The minimum read -t argument in Bash3.2 is 1 second. It is not possible

to set it lower or to a fraction. This does not work great for Bash3.2 for short timeout, as one read takes at least 1 second to execute.

Example

```
exec 10< <(for ((i=0;i<5;++i)); do echo $i; sleep 1; done)
exec 11< <(for ((i=0;i<5;++i)); do echo $i; sleep 2; done)
L_read_fds 10 a 11 b
echo "read from 10 fd text: $a"
echo "read from 11 fd text: $b"
```

**Options:**

- **`-t <timeout>`** Timeout in seconds.
- **`-p <timeout>`** Poll timeout. The read -t argument value. Default: 0.05 or 1 in Bash3.2
- **`-h`** Print this help and return 0.
- **`-v <var>`** After first fd EOF or error, assign the fd number to and return 0.
- **`-i <var>`** After first fd EOF or error, assign the argument fd number to and return 0.
- **`-d <delim>`** Read -d argument. Default: ''
- **`-n`** Run the reading loop possible once.

**Arguments:**

- **`$1`** File descriptor to read from.

- **`$2`** Variable to assign the output of $1.

- **`$@`**

  Continued pairs of file descriptor and variable names.

  I do not like this. This should just read from two arrays and return array index.

**Return:**

0 on success

124 ($L_EX_TIMEOUT) on timeout

#### L_proc_communicate

Communicate with L_proc.

Interact with process: Send data to stdin. Read data from stdout and stderr, until end-of-file is reached. Wait for process to terminate.

**Options:**

- **`-i <str>`**

  Send string to stdin.

  Note that if you want to send data to the process’s stdin, you need to create the L_proc object with -I PIPE.

- **`-o <var>`**

  Append stdout data to this variable. Variable is not cleared.

  To get anything, you need to create L_proc object with -O PIPE.

- **`-e <var>`**

  Append stderr to this variable. Variable is not cleared.

  To get anything, you need to create L_proc object with -E PIPE.

- **`-t <int>`** Timeout in seconds.

- **`-k`** Kill L_proc after communication.

- **`-v <var>`** Store the output in variable instead of printing it.

- **`-h`** Print this help and return 0.

**Argument:** **`$1`** PID from L_proc_popen

**Exit:** 0 on success. 64 ($L_EX_USAGE) on usage error. 124 ($L_EX_TIMEOUT) on timeout.

#### L_proc_send_signal

Send signal to L_proc.

**Arguments:**

- **`$1`** PID from L_proc_popen
- **`$2`** signal to send

#### L_proc_terminate

Terminate L_proc.

**Argument:** **`$1`** PID from L_proc_popen

#### L_proc_kill

Kill L_proc.

**Argument:** **`$1`** PID from L_proc_popen

### foreach

#### L_printf_v

Compatibility printf implementation for Bash\<4.1

That properly sets the -v variable when it is an array. The variables are like printf -v $1 fmt args...

**Arguments:**

- **`$1`** variable to set
- **`$2`** fmt printf format string
- **`$@`** arg printf arguments....

#### L_foreach

Iterate over elements of an array by assigning it to variables.

Each loop the arguments to the function are REQUIRED to be exactly the same.

The function takes positional arguments in the form:

- at least one variable name to assign to,
- followed by a required ':' colon character,
- followed by at least one array variable to iterate over.

Without -k option:

- For each array variable:
- If -s option, sort array keys.
- For each element in the array:
- Assign the element to the variables in order.

With -k option:

- Accumulate all keys of all arrays into a set of keys.
- If -s option, sort the set.
- For each value in the set of keys:
- Assign the values of each array[key] to corresponding variable.

Example

```
local array1=(a b c d) array2=(d e f g)
while L_foreach a : array1; do echo $a; done  # a b c d
while L_foreach a b : array1; do echo $a,$b; done  # a,b c,d
while L_foreach a b : array1 array2; do echo $a,$b; done  # a,d b,e c,f g,d
while L_foreach a b c : array1 array2; do echo $a,$b; done  # a,d,b e,c,f g,d,<unset>
while L_foreach -R 3 a : array1; do echo ${#a[@]},${a[*]},; done  # 3,a b c, 1,d,

local -A dict1=([a]=b [c]=d) dict2=([a]=e [c]=f)
while L_foreach -R 3 a : dict1; do echo ${#a[@]},${a[*]},; done  # 2,b d or 2,d b
                        # the order of elements is unknown in associative arrays
while L_foreach -s -k k a b : dict1 dict2; do echo $k,$a,$b; done  # a,b,e  c,d,f
while L_foreach -s -k k a b : dict1 dict2; do echo $k,$a,$b; done  # a,b,e  c,d,f
```

**Options:**

- **`-s`** Output in sorted keys order. Does nothing on non-associative arrays.

- **`-r`** Output in reverse sorted keys order. Implies -s.

- **`-n`** Output in numeric sorted order. Implies -s.

- **`-V`** Output in sorted values order. Implies -s.

- **`-R <num>`**

  Repeat each variable name as an array variable with indexes from 0 to num-1.

  For example: '-R 3 a : arr' is equal to 'a[0] a[1] a[2] : arr'.

- **`-i <var>`** Index of the loop is sroted in the specified variable. First loop has index 0.

- **`-v <var>`** Store iterator state in the variable, instead of picking unique name starting with *L_FOREACH*\*.

- **`-k <var>`** Key of the first assigned element is stored in the specified variable. Usefull with -s.

- **`-f <var>`** First loop stores 1 into the variable, otherwise 0 is stored in the variable.

- **`-l <var>`** Last loop stores 1 into the variable, otherwise 0 is stored in the variable.

- **`-c <var>`** Count of assigned variables is stored in the variable var.

- **`-e <var>`**

  Existing values are assigned 1 in the corresponding indexes of the specified array variable.

  The indexes of elements with the value 1 are the indexes of assigned variable names. The indexes of empty elements are the indexes of unassigned varaible names.

- **`-h`** Print this help and return 0.

**Argument:** **`$@`** Variable names to assign, followed by : colon character, followed by arrays variables.

**Uses environment variables:**

- **`_L_FOREACH`**
- **`_L_FOREACH_[0-9]+`**

**Return:**

0 if iteration should be continued,

1 on interanl error, 64 ($L_EX_USAGE) on usage error, 4 if iteration should stop.

### uv

The global uv loop variable.

L_UV=()

#### L_uv_init

Initialize a loop array.

Note

Panics if trying to initialize a currently running L_UV loop (detected via L_UV[2]).

#### L_uv_add_timer

Add a timer to the loop.

**Options:**

- **`-d <duration>`** Initial delay (e.g., 1s, 500ms; bare number is seconds) (defaults to 0)
- **`-r <duration>`** Repeat interval (e.g., 1s, 500ms; bare number is seconds) (defaults to 0)
- **`-v <var>`** Variable to assign the handle ID to
- **`-h`** Show help

**Argument:** **`$@`** Callback function and its arguments. The callback is invoked with its arguments only.

#### L_uv_timer_get_repeat_vL_RET

#### L_uv_add_waiter

Add a process wait handle to the loop.

**Options:**

- **`-v <var>`** Variable to assign the handle ID to
- **`-h`** Show help

**Arguments:**

- **`$1`** PID to wait for
- **`$@`** Callback function and its arguments. The callback is invoked with its arguments, followed by the PID and exit status.

#### L_uv_add_reader

Add a line-buffered read handle to the loop.

**Options:**

- **`-d`** Delimiter character (defaults to newline)
- **`-v <var>`** Variable to assign the handle ID to
- **`-c`** Close file descriptor on EOF
- **`-h`** Show help

**Arguments:**

- **`$1`** Target file descriptor
- **`$@`** Callback function and its arguments. The callback is invoked with its arguments, followed by the FD and the line read. On EOF or error, the callback is invoked with its arguments and the FD only (no line argument).

#### L_uv_add_task

Add a task callback to the loop.

**Options:**

- **`-v <var>`** Variable to assign the handle ID to
- **`-h`** Show help

**Argument:** **`$@`** Callback function and its arguments. The callback is invoked with its arguments only.

#### L_uv_add_once

Add a callback that runs once when a condition is met.

**Options:**

- **`-c <condition>`** Condition command to evaluate (defaults to 'true')
- **`-v <var>`** Variable to assign the handle ID to
- **`-h`** Show help

**Argument:** **`$@`** Callback function and its arguments

#### L_uv_set

Set a callback for a specific handle ID in the loop.

**Arguments:**

- **`$1`** Handle ID to set
- **`$@`** Callback function and its arguments

#### L_uv_remove

Remove a callback from the loop by handle ID.

**Argument:** **`$1`** Handle ID to remove

#### L_uv_current_set

Update the callback of the currently running handle.

**Argument:** **`$@`** New callback function and its arguments. This replaces both the function and any previously assigned arguments.

**Uses environment variable:** **`L_UV_CURRENT`** The ID of the currently executing handle.

#### L_uv_current_remove

Remove the current executing callback.

**Uses environment variable:** **`L_UV_CURRENT`**

#### L_uv_run

Run the event loop until it's empty or timed out.

Note

You can call L_uv_add functions while the loop is running to add more tasks dynamically.

Example

```
L_uv_add_timer 1 echo "hello"; L_uv_run
```

**Options:**

- **`-s <duration>`** Polling interval (e.g., 1s, 500ms; bare number is seconds) (defaults to 0.1)
- **`-1`** Run only one iteration of the loop.
- **`-t <duration>`** Timeout (e.g., 1s, 500ms; bare number is seconds) (defaults to none)
- **`-c`** Set sigchild trap.
- **`-h`** Show help

**Shellcheck disable=** [SC2120](https://www.shellcheck.net/wiki/SC2120)

**Return:** 0 on success, 124 on timeout, or task exit code.

#### L_uv_break

Break the current event loop.

Note

This sets a flag that causes L_uv_run to exit after the current iteration completes. It has no effect if the loop is not running.

#### L_uv_poke

Wake up the event loop immediately.

Note

This skips the next polling delay (sleep), causing the loop to proceed immediately to the next iteration. Useful for signaling state changes from traps or async callbacks.

### xargs

#### L_nproc

Returns the number of CPU cores.

Caches result in \_L_NPROC.

**Options:**

- **`-v <var>`**
- **`-h`**

#### L_nproc_vL_RET

#### L_sleep

Pause for a specified duration using the best available sleep method.

**Argument:** **`$1`** Duration in floating point seconds.

#### L_xargs

Bash implementation of the `xargs` utility designed for seamless

integration with local shell environments. Unlike binary `xargs`, `L_xargs` executes within the current shell context, enabling the direct use of unexported Bash functions, aliases, and variables without requiring `export` or `export -f`.

The tool operates on a dual-unit architecture:

1. Records: Discrete segments of input defined by a delimiter (default: `\n`).
1. Atoms: The individual arguments passed to the command.

By default, `L_xargs` operates in `-s -0` mode. If `-d` `-0` `-a` options are specified without `-z -Z`, `-Z` is implied.

Execution follows a first-to-threshold trigger system: the command is dispatched as soon as either the Atom limit (-n) or the Record limit (-L) is reached. If no limits are specified, the command executes exactly once upon reaching EOF.

**Options:**

- **`-0`** Use the null character (\\0) as the Record separator.

- **`-a <file>`** Read Records from the specified file.

- **`-A <var>`** Read Records from the specified Bash array variable.

- **`-C <callback>`** Execute an eval string to fetch the next Record. Must populate L_RET=() and return 0.

- **`-d <delimiter>`** Set the Record separator to the specified character.

- **`-e <eof-str>`** Like -E, compatibility wtih GNU xargs, use -E.

- **`-E <eof-str>`** Set the end of file string to eof-str. If the end of file string occurs as a line of input, the rest of the input is ignored.

- **`-F`** Run the command in current shell execution context. Do not fork.

- **`-h`** Display this help documentation and exit.

- **`-I <replace-str>`** Replace occurrences of replace-str in the command. Sets -n 1.

- **`-i`** Shorthand for -I{}.

- **`-L <max-records>`** Trigger execution once have been accumulated.

- **`-l`** Shorthand for -L1.

- **`-M <global-max-time>`**

  If xargs is running longer then specified time, tasks are getting killed and xargs returns.

  If specified second time, it specifies timeout before SIGKILL.

- **`-m <task-max-time>`**

  If a task is running longer then specified time, it is killed.

  If specified second time, it specifies timeout before SIGKILL.

- **`-n <max-atoms>`** Trigger execution once have been accumulated.

- **`-O`** Separate output of each command by using pipes. Use twice to keep the output of pipes in order.

- **`-P <max-procs>`** Concurrent process limit. Supports an integer or 'nproc' for CPU count.

- **`-q`** Be quiet.

- **`-r`** If the input does not contain any atoms, do not run the command. Normally, the command is run once even if there is no input.

- **`-s <max-chars>`** Use at most max-chars characters per command line.

- **`-t`** Verbose: Print each command to STDERR before execution.

- **`-u <fd>`** Read the input stream from the specified file descriptor.

- **`-v <var>`** Assign array variable the exit statuses of commands. Do not exit with 123-127 exit codes.

- **`-X <func>`**

  Register custom function event callback that will be called

  with arguments: `PREEXEC`, `POSTEXEC $pid`, `EXIT $pid $?`.

- **`-Z`** Solid Mode: Treat the entire delimited Record as a single literal Atom (Default).

- **`-z`** Split Mode: Parse internal Records into multiple Atoms using L_unquote.

- **`-^`** Prefix Mode: Prepends the command arguments and a colon to each line of output.

**Argument:** **`$@`** Command to execute. Default: L_quote_printf.

**Uses environment variable:** **`L_XARGS_INDEX`** The index of the job being executed.

**Return:**

0 on success

1 on some other error 64 ($L_EX_USAGE) on invalid usage 123 if any invocation of the command exited with status 1-125 and 192-254 124 if the command exited with status 255 125 if the command exited with the status 128-192 126 if the command cannot be run 127 if the command is not found

### lib

internal functions and section.

Internal functions to handle terminal interaction.
