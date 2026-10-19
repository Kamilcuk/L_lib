# L_unittest

The `L_lib.sh` framework includes a built-in, standalone unit testing facility. It is designed to be lightweight, fast, and easy to integrate into any Bash project.

## Standalone Usage

The core testing functions (like `L_unittest_eq`, `L_unittest_cmd`, `L_unittest_checkexit`) are entirely standalone. They do not require a test runner or any special environment.

If an assertion fails, these functions will print an error message to standard error and return a non-zero exit code. If the `L_unittest_exit_on_error` variable is set to a non-zero value, they will call `exit` immediately.

```
. L_lib.sh -s

# A simple standalone test
my_var="hello"
L_unittest_eq "$my_var" "hello"

# A standalone test of a command
L_unittest_cmd -e 0 echo "world"
```

## Using the Test Runner (L_unittest_main)

For larger test suites, you can use the `L_unittest_main` test runner. It discovers tests based on function prefixes, runs them (optionally in parallel), captures output, and generates a summary report.

### Writing and Running Tests

Tests are simply Bash functions. By convention, they should start with a specific prefix, like `test_`.

Create a single file for your tests, for example `run_tests.sh`:

```
#!/usr/bin/env bash
. L_lib.sh -s

test_my_math() {
    local result=$((1 + 1))
    L_unittest_eq "$result" 2
}

test_my_string() {
    local str="foo"
    L_unittest_vareq str "foo"
}

# You can source other files containing tests here if your suite grows
# . ./more_tests.sh

# Run all functions starting with 'test_'
L_unittest_main -p "test_" "$@"
```

Then, you can run your test file:

```
chmod +x run_tests.sh
./run_tests.sh
```

## API Reference

## unittest

Testing library

Simple unittesting library that does simple comparison. Testing library for testing if variables are commands are returning as expected.

Note

rather stable

Example

```
L_unittest_eq 1 1
```

### L_unittest_notice

### L_unittest_warning

### L_unittest_fail

### L_unittest_skip

Skip the current unit test with a specified reason.

**Option:** **`$1`** Skipping reason.

### L_unittest_main

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

### L_unittest_checkexit

Check if command exits with specified exitcode.

**Arguments:**

- **`$1`** exit code the command should exit with
- **`$@`** command to execute

**Shellcheck disable=** [SC2035](https://www.shellcheck.net/wiki/SC2035)

### L_unittest_success

Check if command exits with 0

**Argument:** **`$@`** command to execute

### L_unittest_failure

Check if command exits with non zero

**Argument:** **`$@`** command to execute

### L_unittest_failure_capture

capture stdout and stderr into variables of a failed command

**Arguments:**

- **`$1`** var stdout and stderr output
- **`$@`** command to execute

### L_unittest_cmd

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

### L_unittest_vareq

Test if a variable has specific value.

**Arguments:**

- **`$1`** variable nameref
- **`$2`** value
- **`$3`** Message to print on failure.

### L_unittest_eq

Test if two strings are equal.

**Arguments:**

- **`$1`** one string
- **`$2`** second string

### L_unittest_arreq

Test if array is equal to elements.

**Arguments:**

- **`$1`** array variable
- **`$@`** values

### L_unittest_ne

Test two strings are not equal.

**Arguments:**

- **`$1`** one string
- **`$2`** second string

### L_unittest_regex

test if a string matches regex

**Arguments:**

- **`$1`** string
- **`$2`** regex

### L_unittest_contains

Test if a string contains other string.

**Arguments:**

- **`$1`** string
- **`$2`** needle
