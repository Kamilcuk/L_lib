# L_utilities: Helper Utilities

The `L_utilities` library provides self-contained helper functions for formatting, parsing arguments, comparing versions, and parsing numeric ranges.

### Python-style Positional & Keyword Arguments (`L_argskeywords`)

`L_argskeywords` provides Python-style parameter binding for functions with optional or keyword arguments.

#### Syntax & Special Symbols

`L_argskeywords` supports standard Python-like parameter binding using the following syntax and symbols:

*   **`var=default` (Optional arguments):** Assigns a default value to the variable if not specified by the caller.
*   **`/` (Positional-only separator):** All arguments before `/` **must** be passed positionally. Arguments after `/` can be passed positionally or as keywords.
*   **`@` (Keyword-only separator):** All arguments after `@` **must** be passed as keyword arguments (e.g., `key=value`).
*   **`@args` (Arbitrary positional capture):** Collects excess positional arguments into a regular Bash array named `args` (similar to Python's `*args`).
*   **`@@kwargs` (Arbitrary keyword capture):** Collects excess keyword arguments into an associative array named `kwargs` (similar to Python's `**kwargs`).

#### Associative Arrays & Compatibility Note

For all Bash versions supporting associative arrays (Bash 4.0+), you **must** declare keyword-capture arrays and configuration destination arrays using `local -A`. On older Bash versions (such as Bash 3.2) that do not support native associative arrays, `L_argskeywords` supports the `L_map` utility instead (enabled with the `-M` flag).

#### Special Command-Line Flags

When calling `L_argskeywords`, you can supply options before the parameter specification:

*   `-A <assoc_array>`: Store all parsed parameters as keys in the specified associative array instead of creating separate local variables.
*   `-M`: Use the `L_map` interface instead of native associative arrays to support older Bash versions (like 3.2).
*   `-E`: Exit the script immediately on parameter validation errors rather than returning a non-zero exit status.
*   `-e <prefix>`: Prefix validation error messages with this custom string.
*   `-c <command>`: Dynamically declare all arguments as local variables, bind them, and evaluate this command. This removes the need for manual `local` declarations in the calling function, as variables are kept strictly local and cleaned up automatically when `L_argskeywords` exits.

---

#### Detailed Examples

##### Example A: Basic Defaults
A function with positional and optional keyword arguments:
```bash
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
Force callers to pass the main argument positionally, and the configuration as keywords.
Note: Pass only valid variable names (not special dividers `/` or `@`) to the `local` declaration.
```bash
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
```bash
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
```bash
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
```bash
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

---

### Version Comparison (`L_version_cmp`)

`L_version_cmp` compares version strings using standard comparison operators, fully aligning with PEP-0440 rules.

#### Supported Operators

| Operator | Symbolic Alias | Meaning | Description |
| :--- | :--- | :--- | :--- |
| `lt` | `<` | Less Than | True if the first version is older than the second. |
| `le` | `<=` | Less Than or Equal | True if the first version is older than or equal to the second. |
| `eq` | `==` | Equal | Strict string equality check on version segments. |
| `ne` | `!=` | Not Equal | Strict string inequality check on version segments. |
| `gt` | `>` | Greater Than | True if the first version is newer than the second. |
| `ge` | `>=` | Greater Than or Equal | True if the first version is newer than or equal to the second. |
| `~=` | | Compatible Release | Compatible with a version range (per PEP-0440 rules). |

#### Segment Accuracy Option

An optional fourth argument `accuracy` specifies the maximum number of segments (dot-separated numbers) to compare. The default is `3`.

```bash
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

```bash
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

```bash
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
```bash
local config_host="localhost" config_port=8080 config_debug=true
L_pretty_print config_*
# Prints:
# config_*{ config_debug=true config_host=localhost config_port=8080 }
```

#### Compact Mode (Default)
By default, arrays are printed as a single compact line:
```bash
local -A config=([host]="localhost" [port]="8080")
L_pretty_print config
# Prints:
# config=([host]=localhost [port]=8080)
```

#### Multiline Mode (`-C`)
Using the non-compact `-C` option forces associative and sparse arrays to be pretty printed on separate lines:
```bash
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
```bash
local -A assoc=([x]=1)
L_pretty_print -v out assoc
# out="assoc=([x]=1)"
```

#### Sparse Arrays
Sparse arrays show their indices explicitly:
```bash
local sparse=([0]=first [2]=third)
L_pretty_print sparse
# Prints: sparse=([0]=first [2]=third)
```

#### Namerefs
Namereferences show the reference chain:
```bash
local -n ref=assoc
L_pretty_print ref
# Prints: ref->assoc=([x]=1)
```

#### Literal Strings
Arguments that are not variable names are printed as literal strings.

---

## API Reference

::: bin/L_lib.sh utilities
