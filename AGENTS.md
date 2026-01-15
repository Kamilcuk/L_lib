# L_lib.sh - Agent Context

This document provides a comprehensive overview of the `L_lib.sh` project, designed to serve as essential context for future interactions with AI agents.

## Project Overview

`L_lib.sh` is a versatile Bash library offering a rich collection of functions for advanced Bash scripting. Its primary purpose is to streamline common scripting tasks, provide robust argument parsing, logging, error handling, and various utility functions, all within a single, portable shell script.

**Main Technologies:** The project is entirely implemented in Bash, leveraging its native capabilities for scripting.

**Architecture:**
The library consists of a single file, `L_lib.sh`, which is designed to be sourced into other Bash scripts. This self-contained architecture ensures ease of deployment and usage.

## Building and Running



### Usage in Scripts
To use the library functions within a Bash script, it must be sourced:
```bash
. L_lib.sh -s
```
The `-s` option notifies the script that it is being sourced. By default, sourcing the library also enables `extglob`, `patsub_replacement`, and sets up an `ERR` trap for detailed traceback on errors (if `set -e` is active).

### Ad-hoc Testing
The library can be tested ad-hoc directly from the command line:
```bash
( . bin/L_lib.sh ; L_setx L_log 'hello world' )
```

### Running Tests
The project includes a comprehensive suite of unit tests and linting checks.

To run all tests and linting:
```bash
make test
```
This command will execute tests for various Bash versions (via Docker) and also run `shellcheck` for static analysis.

To run tests for the current Bash version:
```bash
./tests/test.sh
```

To run only `shellcheck` for static analysis:
```bash
make shellcheck
```
The tests are defined within `tests/test.sh` and are executed via the `_L_lib_run_tests` function. Test functions follow a naming convention, starting with `_L_test_`, and are automatically discovered and run by the test runner.

## Development Conventions

The project adheres to strict conventions to maintain consistency and readability:

*   **Public Symbols:** All public functions, variables, and macros are prefixed with `L_` (e.g., `L_argparse`, `L_info`).
*   **Private Symbols:** Internal functions and variables are prefixed with `_L_` (e.g., `_L_lib_main`, `_L_test_z_argparse`).
*   **Variable Naming:**
    *   Global scope, read-only variables use `UPPER_CASE`.
    *   Functions and user-mutable variables use `lower_case`.
    *   All naming generally follows `snake_case`.
*   **Result Storage:** Functions designed to return values use the `-v <var>` option to store their output in the specified variable, mirroring `printf -v`. If `-v` is not provided, results are typically printed to standard output.
*   **Return Codes:**
    *   `0`: Success.
    *   `2`: Usage errors (e.g., incorrect arguments).
    *   `124`: Timeout.
*   **Shell Options:** Scripts and the library itself operate with `set -euo pipefail` to ensure robust error handling and predictable behavior.
*   **Testing Practices:** Unit tests are organized into functions prefixed with `_L_test_` within `tests/test.sh` and are executed by `L_unittest_main`.
