# L_unittest

The `L_lib.sh` framework includes a built-in, standalone unit testing facility. It is designed to be lightweight, fast, and easy to integrate into any Bash project.

## Standalone Usage

The core testing functions (like `L_unittest_eq`, `L_unittest_cmd`, `L_unittest_checkexit`) are entirely standalone. They do not require a test runner or any special environment.

If an assertion fails, these functions will print an error message to standard error and return a non-zero exit code. If the `L_unittest_exit_on_error` variable is set to a non-zero value, they will call `exit` immediately.

```bash
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

```bash
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

```bash
chmod +x run_tests.sh
./run_tests.sh
```

::: bin/L_lib.sh unittest
