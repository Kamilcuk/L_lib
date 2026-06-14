# L_lib Unittest Assertions Reference

## Basic Exit Status Checks

### `L_unittest_checkexit <code|!> <command...>`
Checks if a command exits with a specific code.
- `L_unittest_checkexit 0 my_cmd arg1` -> expects exit code 0.
- `L_unittest_checkexit ! my_cmd` -> expects non-zero exit code.
- `L_unittest_checkexit 123 my_cmd` -> expects exit code 123.

### `L_unittest_success <command...>`
Alias for `L_unittest_checkexit 0 <command...>`.

### `L_unittest_failure <command...>`
Alias for `L_unittest_checkexit 0 ! <command...>`. Expects the command to fail.

## Output Comparison

### `L_unittest_cmd [options] <command...>`
Executes a command and validates its output.
- `-o <str>`: Compare stdout with string `<str>`.
- `-r <regex>`: Compare stdout with regex `<regex>`.
- `-v <var>`: Store stdout in variable `<var>`.
- `-e <int>`: Expect exit code `<int>` (default 0).
- `-j`: Join stderr to stdout (2>&1).
- `-N`: Redirect stdout to `/dev/null`.
- `-i`: Invert exit status.
- `-c`: Run in current shell environment (CAUTION: can affect state).

Example:
```bash
L_unittest_cmd -o "Hello World" echo "Hello World"
L_unittest_cmd -r "^Error:.*" ! ls non_existent_file
```

## Value Comparison

### `L_unittest_eq <str1> <str2> [msg]`
Test if two strings are equal.

### `L_unittest_ne <str1> <str2>`
Test if two strings are not equal.

### `L_unittest_vareq <varname> <value> [msg]`
Test if variable `<varname>` equals `<value>`.

### `L_unittest_arreq <arrname> <val1> [val2] ...`
Test if array `<arrname>` elements match exactly.

### `L_unittest_regex <str> <regex>`
Test if `<str>` matches `<regex>`.

### `L_unittest_contains <str> <needle>`
Test if `<str>` contains `<needle>`.

## Control Flow

### `L_unittest_skip [reason]`
Skip the current test.
