# L_utilities: Helper Utilities

The `L_utilities` library provides self-contained helper functions for formatting, parsing arguments, comparing versions, and parsing numeric ranges.

### Python-style Positional & Keyword Arguments (`L_argskeywords`)

`L_argskeywords` provides Python-style parameter binding for functions with optional or keyword arguments.

#### Syntax & Special Symbols

`L_argskeywords` supports standard Python-like parameter binding using the following syntax and symbols:

- **`var=default` (Optional arguments):** Assigns a default value to the variable if not specified by the caller.
- **`/` (Positional-only separator):** All arguments before `/` **must** be passed positionally. Arguments after `/` can be passed positionally or as keywords.
- **`@` (Keyword-only separator):** All arguments after `@` **must** be passed as keyword arguments (e.g., `key=value`).
- **`@args` (Arbitrary positional capture):** Collects excess positional arguments into a regular Bash array named `args` (similar to Python's `*args`).
- **`@@kwargs` (Arbitrary keyword capture):** Collects excess keyword arguments into an associative array named `kwargs` (similar to Python's `**kwargs`).

#### Associative Arrays & Compatibility Note

For all Bash versions supporting associative arrays (Bash 4.0+), you **must** declare keyword-capture arrays and configuration destination arrays using `local -A`. On older Bash versions (such as Bash 3.2) that do not support native associative arrays, `L_argskeywords` supports the `L_map` utility instead (enabled with the `-M` flag).

#### Special Command-Line Flags

When calling `L_argskeywords`, you can supply options before the parameter specification:

- `-A <assoc_array>`: Store all parsed parameters as keys in the specified associative array instead of creating separate local variables.
- `-M`: Use the `L_map` interface instead of native associative arrays to support older Bash versions (like 3.2).
- `-E`: Exit the script immediately on parameter validation errors rather than returning a non-zero exit status.
- `-e <prefix>`: Prefix validation error messages with this custom string.
- `-c <command>`: Dynamically declare all arguments as local variables, bind them, and evaluate this command. This removes the need for manual `local` declarations in the calling function, as variables are kept strictly local and cleaned up automatically when `L_argskeywords` exits.

______________________________________________________________________

#### Detailed Examples

##### Example A: Basic Defaults

A function with positional and optional keyword arguments:

```
range() {
    local start stop step
    L_argskeywords start stop step=1 -- "$@" || return "$L_EX_USAGE"

    for (( i = start; i < stop; i += step )); do
        echo "$i"
    done
}

# Usage:
range 1 5       # prints: 1, 2, 3, 4
range 1 5 step=2 # prints: 1, 3
```

##### Example B: Positional-Only and Keyword-Only (`/` and `@`)

Force callers to pass the main argument positionally, and the configuration as keywords. Note: Pass only valid variable names (not special dividers `/` or `@`) to the `local` declaration.

```
request() {
    # Declare only valid variable names as local
    local url method headers timeout
    L_argskeywords url / method='GET' headers='' @ timeout=30 -- "$@" || return "$L_EX_USAGE"

    echo "Sending $method to $url (timeout: $timeout)..."
}

# Usage:
request "https://example.com" method="POST" timeout=10 # OK
request url="https://example.com"                      # Error: url is positional-only
request "https://example.com" "GET" "" 30              # Error: takes 3 positional arguments but more were given: 30
```

##### Example C: Capturing Excess Arguments (`@args` and `@@kwargs`)

Collect any additional arguments passed to the function. Associative arrays **must** be declared using `local -A` where supported.

```
log_event() {
    # Declare only valid variable names as local
    local message extra_args
    local -A extra_kwargs # Required on Bash 4.0+
    L_argskeywords message @extra_args @@extra_kwargs -- "$@" || return "$L_EX_USAGE"

    echo "Log: $message"
    if (( ${#extra_args[@]} > 0 )); then
        echo "Extra positional arguments: ${extra_args[*]}"
    fi
    if (( ${#extra_kwargs[@]} > 0 )); then
        echo "Extra keyword parameters:"
        for key in "${!extra_kwargs[@]}"; do
            echo "  $key = ${extra_kwargs[$key]}"
        done
    fi
}

# Usage:
log_event "System updated" "rebooted" "silently" level="info" user="admin"
```

##### Example D: Parsing into an Associative Array (`-A`)

Rather than declaring many local variables, parse all arguments directly into a configuration associative array. The destination array **must** be declared using `local -A`.

```
configure_server() {
    local -A cfg # Required on Bash 4.0+
    L_argskeywords -A cfg host="localhost" port=8080 debug=false -- "$@" || return "$L_EX_USAGE"

    echo "Starting server on ${cfg[host]}:${cfg[port]} (Debug: ${cfg[debug]})"
}

# Usage:
configure_server host="127.0.0.1" debug=true
```

##### Example E: Zero-Boilerplate Arguments using Subcall (`-c`)

Rather than manually declaring `local start stop step`, use the `-c` option to automatically localize all arguments and run the logic from a separate function inside `L_argskeywords`. Because the wrapper does nothing but call `L_argskeywords`, no `|| return` is needed — `L_argskeywords` already returns `L_EX_USAGE` on failure:

```
_range() {
    for (( i = start; i < stop; i += step )); do
        echo "$i"
    done
}
range() {
    L_argskeywords -c _range start stop step=1 -- "$@"
}

# Usage:
range 1 5 step=2 # prints: 1, 3
```

______________________________________________________________________

### Version Comparison (`L_version_cmp`)

`L_version_cmp` compares version strings using standard comparison operators, fully aligning with PEP-0440 rules.

#### Supported Operators

| Operator | Symbolic Alias | Meaning               | Description                                                     |
| -------- | -------------- | --------------------- | --------------------------------------------------------------- |
| `lt`     | `<`            | Less Than             | True if the first version is older than the second.             |
| `le`     | `<=`           | Less Than or Equal    | True if the first version is older than or equal to the second. |
| `eq`     | `==`           | Equal                 | Strict string equality check on version segments.               |
| `ne`     | `!=`           | Not Equal             | Strict string inequality check on version segments.             |
| `gt`     | `>`            | Greater Than          | True if the first version is newer than the second.             |
| `ge`     | `>=`           | Greater Than or Equal | True if the first version is newer than or equal to the second. |
| `~=`     |                | Compatible Release    | Compatible with a version range (per PEP-0440 rules).           |

#### Segment Accuracy Option

An optional fourth argument `accuracy` specifies the maximum number of segments (dot-separated numbers) to compare. The default is `3`.

```
# Compare versions with standard operators (lt, le, eq, ne, gt, ge)
if L_version_cmp "1.2.3" gt "1.2.0"; then
    echo "Version is greater"
fi

# Compare with symbolic operators or ~= compatibility operator
if L_version_cmp "1.5.0" ~="1.5"; then
    echo "Version is compatible"
fi

# Compare up to a maximum segments accuracy of 2 (ignores minor segments)
if L_version_cmp "1.2.9" == "1.2.0" 2; then
    echo "Major and minor versions are identical (1.2)"
fi
```

### Parse Cut Range Lists (`L_parse_range_list`)

`L_parse_range_list` expands standard cut-like range sequences (e.g. `1-3,5`) into a dense array of indexes.

```
# Expand a range list
local -a selected_fields
L_parse_range_list -v selected_fields 10 "1-3,5,8-"

# 'selected_fields' now contains indices: 1, 2, 3, 5, 8, 9, 10
for field in "${selected_fields[@]}"; do
    echo "Processing field $field"
done
```

### Print Structured Tables (`L_table`)

`L_table` is a pure-Bash replacement for the standard `column -t` command. It formats space/tab-separated strings into aligned tables.

```
# Print a table with right-aligned first and second columns
L_table -R 1-2 "ID NAME SCORE" "1 Alice 95" "2 Bob 100"
```

### Debug Variables (`L_pretty_print` / `L_pp`)

`L_pretty_print` formats variables, sparse arrays, and associative arrays for debugging. `L_pp` is a shorter alias.

**Options:**

- `-C` / `-m` — Multiline output for arrays (default: compact single-line)
- `-c` — Force compact single-line output
- `-w <width>` — Set output width for compact mode (default: `$COLUMNS` or 80)
- `-p <prefix>` — Prefix each output line
- `-v <var>` — Store output in variable instead of printing

#### Variable Prefix Expansion (`VAR*`)

Pass a variable name ending with `*` (e.g., `config_*`) to pretty-print all variables matching that prefix:

```
local config_host="localhost" config_port=8080 config_debug=true
L_pretty_print config_*
# Prints:
# config_*{ config_debug=true config_host=localhost config_port=8080 }
```

#### Compact Mode (Default)

By default, arrays are printed as a single compact line:

```
local -A config=([host]="localhost" [port]="8080")
L_pretty_print config
# Prints:
# config=([host]=localhost [port]=8080)
```

#### Multiline Mode (`-C`)

Using the non-compact `-C` option forces associative and sparse arrays to be pretty printed on separate lines:

```
local -A config=([host]="localhost" [port]="8080" [debug]="true")
L_pretty_print -C config
# Prints:
# config=(
#   [debug]=true
#   [host]=localhost
#   [port]=8080
# )
```

#### Variable Output (`-v`)

Store output in a variable instead of printing:

```
local -A assoc=([x]=1)
L_pretty_print -v out assoc
# out="assoc=([x]=1)"
```

#### Sparse Arrays

Sparse arrays show their indices explicitly:

```
local sparse=([0]=first [2]=third)
L_pretty_print sparse
# Prints: sparse=([0]=first [2]=third)
```

#### Namerefs

Namereferences show the reference chain:

```
local -n ref=assoc
L_pretty_print ref
# Prints: ref->assoc=([x]=1)
```

#### Literal Strings

Arguments that are not variable names are printed as literal strings.

______________________________________________________________________

## API Reference

## utilities

Various self contained functions that could be separate programs.

### L_table

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

### L_parse_range_list

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

### L_pretty_print

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

### L_pp

Alias for L_pretty_print

**See:** [L_pretty_print](#L_lib.sh--L_pretty_print)

### L_argskeywords

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

### L_version_cmp

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
