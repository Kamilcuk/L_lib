# String Utilities

This section covers string manipulation, formatting, evaluation, and safe quoting/unquoting utilities.

______________________________________________________________________

## Safe Unquoting with `L_unquote`

`L_unquote` is a utility for safely unquoting and splitting a string according to shell quoting rules without risk of command execution or shell expansions.

### Why not `eval` or `declare`?

Standard Bash methods for parsing and unquoting strings (such as `eval` or `declare`) can be highly dangerous when processing untrusted input. They evaluate and execute arbitrary code embedded in backticks or command substitutions.

For example, using `declare`:

```
# This EXECUTEs the command inside $(...)!
declare -a array='($(echo "system compromised" >&2))'
```

`L_unquote` parses the string token-by-token in pure Bash. It handles single quotes, double quotes, escape characters, and ANSI-C quoting (`$''`), without ever evaluating or executing any part of the string.

### Basic Usage

You can parse a string and store the resulting array in a variable using `-v <var_name>`.

```
# Safely split a quoted string into an array
L_unquote -v my_array "ls -l 'somefile; rm -rf ~'"

# View the result
declare -p my_array
# Output: declare -a my_array=([0]="ls" [1]="-l" [2]="somefile; rm -rf ~")
```

### Options

- `-v <var>`: Store the parsed tokens into an array variable of that name instead of printing them.
- `-c`: Treat `#` as the start of a comment and ignore the rest of the line.
- `-A`: Disable ANSI-C quoting (`$''`) support.
- `-q`: Without `-v`, instead of printing one word per line, print words quoted with `printf %q`.

______________________________________________________________________

## Safe Quoting Family

Quoting strings in Bash is essential to prevent unintended expansion, word splitting, or execution when variables are evaluated. `L_lib` provides a robust family of quoting functions tailored for different needs and Bash versions.

### `L_quote`

`L_quote` is the primary, portable quoting utility.

- On **Bash 4.4+**, it utilizes the native and efficient parameter expansion `${*@Q}`.
- On **older Bash versions**, it automatically falls back to `L_quote_printf`.

```
L_quote -v quoted "hello 'world' & directory/name"
echo "$quoted"
# Output: 'hello '\''world'\'' & directory/name'
```

### `L_quote_printf`

Uses Bash's builtin `printf %q` to format multiple arguments as a single string, safely avoiding trailing whitespace issues that occur with simple `printf -v var "%q " "$@"`.

```
L_quote_printf -v quoted "arg1" "arg2 with spaces"
echo "$quoted"
# Output: arg1 arg2\ with\ spaces
```

### `L_quote_setx`

Leverages Bash's internal `set -x` (xtrace) formatter to output a string in the exact same style that the shell uses for trace outputs.

```
L_quote_setx -v quoted "foo'bar" "baz"
```

______________________________________________________________________

## Templating & Formatting

`L_lib` provides powerful templating and formatting helpers that resemble higher-level languages.

### `L_fstring` (f-strings)

A pure-Bash implementation of Python-style f-strings. It parses named or indexed placeholders (such as `{name}` or `{var[index]}`) and formats them using `printf` under the hood.

```
name="John"
declare -A age=([John]=42)

# Formats using the age associative array and applies formatting padding (:10s)
L_fstring 'Hello, {name}! You are {age[John]:10s} years old.\n'
# Output: Hello, John! You are         42 years old.
```

### `L_percent_format`

A pure-Bash implementation of Python-style percent formatting (`%(key)s`).

```
name="John"
declare -A age=([John]=42)

L_percent_format "Hello, %(name)s! You are %(age[John])10s years old.\n"
# Output: Hello, John! You are         42 years old.
```

______________________________________________________________________

## Float Operations in Pure Bash

Because standard Bash arithmetic `(( ... ))` does not support floating-point numbers, scripts usually fall back to calling slow subshells running `bc`. `L_lib` offers fast, built-in floating point operations.

### `L_float_cmp`

Compares two floating-point numbers using integer alignment and padding without invoking external binaries. This makes it incredibly fast and lightweight.

#### Supported Operators:

- **Standard operators:** `-lt` (or `<`), `-le` (or `<=`), `-eq` (or `==`), `-ne` (or `!=`), `-ge` (or `>=`), `-gt` (or `>`).
- **Spaceship operator (`<=>`):** Performs a three-way comparison, returning specific exit codes instead of standard true (0) or false (1):
  - **9**: if `$1 < $2`
  - **10**: if `$1 == $2`
  - **11**: if `$1 > $2`

```
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

- `-v <var>`: Store the output in variable instead of printing it.

```
# Direct print
L_float "3.14159 * 2.0"
# Output: 6.28318

# Assign to a variable
L_float -v result "3.14159 * 2.0"
echo "$result"
# Output: 6.28318
```

______________________________________________________________________

## Fuzzy Searching with `L_fuzzy`

`L_fuzzy` performs wildcard-based fuzzy matching on a list of candidate strings using an input search query, returning the matched items.

```
# Search for 'fz' in list of words
L_fuzzy -v results "fz" "fuzzy" "fizzy" "fast" "focus"

declare -p results
# Output: declare -a results=([0]="fuzzy" [1]="fizzy")
```

______________________________________________________________________

## API Reference

## string

Collection of functions to manipulate strings.

### L_is_true

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

### L_is_false

Return 0 if the string happend to be something like false.

Return 0 when argument is case-insensitive:

- false
- 0
- no
- F
- n
- the character minus '-'

**Argument:** **`$1`** str

### L_is_true_locale

Return 0 if the string happend to be something like true in locale.

**Argument:** **`$1`** str

### L_is_false_locale

Return 0 if the string happend to be something like false in locale.

**Argument:** **`$1`** str

### L_isprint

Return 0 if all characters in string are printable

**Argument:** **`$1`** string to check

### L_isdigit

Return 0 if all string characters are digits

**Argument:** **`$1`** string to check

### L_is_valid_variable_name

Return 0 if argument could be a variable name.

This function is used to make sure that eval "$1=" will e correct if L_is_valid_variable_name "$1".

**Argument:** **`$1`** string to check

**See:** [L_is_valid_variable_or_array_element](#L_lib.sh--L_is_valid_variable_or_array_element)

### L_is_valid_variable_or_array_element

Return 0 if argument could be a variable name or array element.

Example

```
L_is_valid_variable_or_array_element aa           # true
L_is_valid_variable_or_array_element 'arr[elem]'  # true
L_is_valid_variable_or_array_element 'arr[elem'   # false
```

**Argument:** **`$1`** string to check

**See:** [L_is_valid_variable_name](#L_lib.sh--L_is_valid_variable_name)

### L_is_valid_function_name

Is the string a valid Bash opinionated function name?

Almost anything is valid Bash function name.

**Argument:** **`$1`** string to check

**See:**

- <https://stackoverflow.com/a/44041384/9072753>
- <https://stackoverflow.com/a/69292370/9072753>

### L_is_integer

Return 0 if the string characters is an integer

**Argument:** **`$1`** string to check

### L_is_float

Return 0 if the string characters is a float

**Argument:** **`$1`** string to check

### $L_NL

newline

### $L_TAB

tab

### $L_SOH

Start of heading

### $L_STX

Start of text

### $L_EOT

End of Text

### $L_EOF

End of transmission

### $L_ENQ

Enquiry

### $L_ACK

Acknowledge

### $L_BEL

Bell

### $L_BS

Backspace

### $L_HT

Horizontal Tab

### $L_LF

Line Feed

### $L_VT

Vertical Tab

### $L_FF

Form Feed

### $L_CR

Carriage Return

### $L_SO

Shift Out

### $L_SI

Shift In

### $L_DLE

Data Link Escape

### $L_DC1

Device Control 1

### $L_DC2

Device Control 2

### $L_DC3

Device Control 3

### $L_DC4

Device Control 4

### $L_NAK

Negative Acknowledge

### $L_SYN

Synchronous Idle

### $L_ETB

End of Transmission Block

### $L_CAN

Cancel

### $L_EM

End of Medium

### $L_SUB

Substitute

### $L_ESC

Escape

### $L_FS

File Separator

### $L_GS

Group Separator

### $L_RS

Record Separator

### $L_US

Unit Separator

### $L_DEL

Delete

### $L_LBRACE

Left brace character

### $L_RBRACE

Right brace character

### $L_UUID

Looks random.

**See:** [L_uuid4](#L_lib.sh--L_uuid4)

### $L_ALLCHARS

255 bytes with all possible 255 values

### $L_ASCII_LOWERCASE

All lowercase characters a-z

### $L_ASCII_UPPERCASE

All uppercase characters A-Z

### $L_GPL_LICENSE_NOTICE_3_OR_LATER

The GPL3 or later License notice.

**See:** <https://www.gnu.org/licenses/gpl-howto.en.html#license-notices>

### $L_FREE_SOFTWARE_NOTICE

notice that the software is a free software.

### L_quote_setx

Output a string with the same quotating style as does bash in set -x

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

### L_quote_setx_vL_RET

### L_quote_printf

Output a string with the same quotating style as does bash with printf

For single argument, just use `printf -v var "%q" "$var"`. Use this for more arguments, like `printf -v var "%q " "$@"` results in a trailing space.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

### L_quote_printf_vL_RET

### L_quote_bin_printf

Output a string with the same quotating style as does /bin/printf

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

### L_quote_bin_printf_vL_RET

### L_quote

Quotes a string for bash to be able to re-read it.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to quote

### L_quote_vL_RET

### L_strhash

Convert a string to a number.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

### L_strhash_vL_RET

### L_strhash_bash

Convert a string to a number in pure bash.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** string

### L_strhash_bash_vL_RET

### L_strstr

Check if string contains substring.

**Arguments:**

- **`$1`** string
- **`$2`** substring

### L_strupper

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on.

### L_strlower

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on.

### L_capitalize

Capitalize first character of a string.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on

### L_uncapitalize

Lowercase first character of a string.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to operate on

### L_dedent

Remove common leading indentation from all lines.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** String to dedent.

### L_dedent_vL_RET

### L_strip

Remove characters from IFS from begining and end of string

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** String to operate on.
- **`[$2]`** Optional glob to strip, default is [:space:]

### L_strip_vL_RET

**Shellcheck disable=** [SC2295](https://www.shellcheck.net/wiki/SC2295)

### L_lstrip

Remove characters from IFS from begining of string

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** String to operate on.
- **`[$2]`** Optional glob to strip, default is [:space:]

### L_lstrip_vL_RET

**Shellcheck disable=** [SC2295](https://www.shellcheck.net/wiki/SC2295)

### L_rstrip

Remove characters from IFS from begining of string

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** String to operate on.
- **`[$2]`** Optional glob to strip, default is [:space:]

### L_rstrip_vL_RET

**Shellcheck disable=** [SC2295](https://www.shellcheck.net/wiki/SC2295)

### L_list_functions_with_prefix

list functions with prefix

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** prefix

### L_list_functions_with_prefix_vL_RET

### L_list_functions_with_prefix_removed

list functions with prefix and remove the prefix

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** prefix

**See:** [L_list_functions_with_prefix](#L_lib.sh--L_list_functions_with_prefix)

### L_list_functions_with_prefix_removed_vL_RET

### L_abbreviation

Choose elements matching prefix.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** prefix
- **`$@`** elements

### L_abbreviation_vL_RET

### L_float_cmp

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

### L_float

A simple wrapper script around awk to evaluate float expressions.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** Expression to evaluate.

### L_float_vL_RET

### L_percent_format

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

### L_percent_format_vL_RET

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

### L_fstring

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

### L_fstring_vL_RET

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059)

### L_hexdump

Convert a string to hex dump.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

### L_hexdump_vL_RET

### L_urlencode

Encode a string in percent encoding.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

### L_urlencode_vL_RET

### L_urldecode

Decode percent encoding.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

### L_urldecode_vL_RET

### L_html_escape

Escape characters for html.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

### L_html_escape_vL_RET

### L_string_replace

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

### L_string_replace_vL_RET

### L_string_count

Count the character in string.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** String.
- **`$2`** Character to count in string.

### L_string_count_vL_RET

### L_string_count_lines

Count lines in a string.

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** String.
- **`[$2]`** Line characters. Default: newline.

### L_string_count_lines_vL_RET

### L_unquote

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

### L_fuzzy

Fuzzy search a key in a list of strings, returning matches in L_RET.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** Key to search for
- **`$@`** Candidate strings

### L_fuzzy_vL_RET
