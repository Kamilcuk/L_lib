# String Utilities

This section covers string manipulation, formatting, evaluation, and safe quoting/unquoting utilities.

---

## Safe Unquoting with `L_unquote`

`L_unquote` is a utility for safely unquoting and splitting a string according to shell quoting rules without risk of command execution or shell expansions.

### Why not `eval` or `declare`?

Standard Bash methods for parsing and unquoting strings (such as `eval` or `declare`) can be highly dangerous when processing untrusted input. They evaluate and execute arbitrary code embedded in backticks or command substitutions.

For example, using `declare`:
```bash
# This EXECUTEs the command inside $(...)!
declare -a array='($(echo "system compromised" >&2))'
```

`L_unquote` parses the string token-by-token in pure Bash. It handles single quotes, double quotes, escape characters, and ANSI-C quoting (`$''`), without ever evaluating or executing any part of the string.

### Basic Usage

You can parse a string and store the resulting array in a variable using `-v <var_name>`.

```bash
# Safely split a quoted string into an array
L_unquote -v my_array "ls -l 'somefile; rm -rf ~'"

# View the result
declare -p my_array
# Output: declare -a my_array=([0]="ls" [1]="-l" [2]="somefile; rm -rf ~")
```

### Options

*   `-v <var>`: Store the parsed tokens into an array variable of that name instead of printing them.
*   `-c`: Treat `#` as the start of a comment and ignore the rest of the line.
*   `-A`: Disable ANSI-C quoting (`$''`) support.
*   `-q`: Without `-v`, instead of printing one word per line, print words quoted with `printf %q`.

---

## Safe Quoting Family

Quoting strings in Bash is essential to prevent unintended expansion, word splitting, or execution when variables are evaluated. `L_lib` provides a robust family of quoting functions tailored for different needs and Bash versions.

### `L_quote`

`L_quote` is the primary, portable quoting utility.
- On **Bash 4.4+**, it utilizes the native and efficient parameter expansion `${*@Q}`.
- On **older Bash versions**, it automatically falls back to `L_quote_printf`.

```bash
L_quote -v quoted "hello 'world' & directory/name"
echo "$quoted"
# Output: 'hello '\''world'\'' & directory/name'
```

### `L_quote_printf`

Uses Bash's builtin `printf %q` to format multiple arguments as a single string, safely avoiding trailing whitespace issues that occur with simple `printf -v var "%q " "$@"`.

```bash
L_quote_printf -v quoted "arg1" "arg2 with spaces"
echo "$quoted"
# Output: arg1 arg2\ with\ spaces
```

### `L_quote_setx`

Leverages Bash's internal `set -x` (xtrace) formatter to output a string in the exact same style that the shell uses for trace outputs.

```bash
L_quote_setx -v quoted "foo'bar" "baz"
```

---

## Templating & Formatting

`L_lib` provides powerful templating and formatting helpers that resemble higher-level languages.

### `L_fstring` (f-strings)

A pure-Bash implementation of Python-style f-strings. It parses named or indexed placeholders (such as `{name}` or `{var[index]}`) and formats them using `printf` under the hood.

```bash
name="John"
declare -A age=([John]=42)

# Formats using the age associative array and applies formatting padding (:10s)
L_fstring 'Hello, {name}! You are {age[John]:10s} years old.\n'
# Output: Hello, John! You are         42 years old.
```

### `L_percent_format`

A pure-Bash implementation of Python-style percent formatting (`%(key)s`).

```bash
name="John"
declare -A age=([John]=42)

L_percent_format "Hello, %(name)s! You are %(age[John])10s years old.\n"
# Output: Hello, John! You are         42 years old.
```

---

## Float Operations in Pure Bash

Because standard Bash arithmetic `(( ... ))` does not support floating-point numbers, scripts usually fall back to calling slow subshells running `bc`. `L_lib` offers fast, built-in floating point operations.

### `L_float_cmp`

Compares two floating-point numbers using integer alignment and padding without invoking external binaries. This makes it incredibly fast and lightweight.

#### Supported Operators:
*   **Standard operators:** `-lt` (or `<`), `-le` (or `<=`), `-eq` (or `==`), `-ne` (or `!=`), `-ge` (or `>=`), `-gt` (or `>`).
*   **Spaceship operator (`<=>`):** Performs a three-way comparison, returning specific exit codes instead of standard true (0) or false (1):
    *   **9**: if `$1 < $2`
    *   **10**: if `$1 == $2`
    *   **11**: if `$1 > $2`

```bash
# Returns exit code 0 (success) because 123.234 <= 234.345
L_float_cmp 123.234 -le 234.345
echo $? # 0

# Supports more complex comparisons
if L_float_cmp 3.14159 ">=" 3.14; then
  echo "Greater or equal!"
fi

# Using the spaceship operator
L_float_cmp 1.1 <=> 1.1
echo $? # 10
```

### `L_float`

A simple wrapper around `awk` for evaluating floating-point expressions when full arithmetic calculations are required.

#### Options:
*   `-v <var>`: Store the output in variable instead of printing it.

```bash
# Direct print
L_float "3.14159 * 2.0"
# Output: 6.28318

# Assign to a variable
L_float -v result "3.14159 * 2.0"
echo "$result"
# Output: 6.28318
```

---

## Fuzzy Searching with `L_fuzzy`

`L_fuzzy` performs wildcard-based fuzzy matching on a list of candidate strings using an input search query, returning the matched items.

```bash
# Search for 'fz' in list of words
L_fuzzy -v results "fz" "fuzzy" "fizzy" "fast" "focus"

declare -p results
# Output: declare -a results=([0]="fuzzy" [1]="fizzy")
```

---

## API Reference

::: bin/L_lib.sh string
