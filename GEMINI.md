# L_lib.sh - Project Context

`L_lib.sh` is a comprehensive Bash library providing a rich set of utilities for advanced shell scripting. It aims to be portable across Bash versions (3.2 to 5.2+) and provides high-level abstractions for common tasks.

## Project Overview

- **Core Functionality:** Argument parsing (`L_argparse`), logging (`L_log`), process management (`L_proc`), error handling with tracebacks, functional programming helpers, string/path manipulation, and more.
- **Architecture:** Primarily a single large file `bin/L_lib.sh` (11,000+ lines) designed to be sourced. Includes optional C-based loadable builtins in the `builtins/` directory.
- **Main Technologies:** Bash, C (for builtins), CMake (for builtins), Makefile (for orchestration), MkDocs (for documentation).

## Building and Running

- **Usage in Scripts:** Source the library with `. bin/L_lib.sh -s`.
- **Testing:**
  - Run all tests: `make test` (includes multi-bash version tests via Docker).
  - Run local tests: `./tests/test.sh`.
  - Filter tests: `./tests/test.sh -k <filter_pattern>`.
- **Linting:** Run `make shellcheck` to check the main library file.
- **Documentation:** Build with `make docs_build` or serve with `make docs_serve`.
- **Builtins:** Compile C builtins using `make -C builtins`.
- **Benchmarking:** Use `scripts/perfbash` for micro-benchmarking bash commands.

## Development Conventions

- **Symbol Prefixes:**
  - `L_`: Public functions, variables, and constants.
  - `_L_`: Internal/private implementation details and local variables.
- **Naming Style:**
  - `snake_case` for functions and user-mutable variables.
  - `UPPER_CASE` for global read-only constants (e.g., `L_EX_OK`, `L_RED`).
- **Function Patterns:**
  - **Return Values:** Prefer the `-v <var>` option to store results in a variable (like `printf -v`).
  - **Error Codes:** Use standard `sysexits.h` style codes (e.g., `L_EX_USAGE=64`, `L_EX_SOFTWARE=70`).
- **Error Handling:** Operates with `set -euo pipefail`. `L_lib.sh` can set up an `ERR` trap for automatic tracebacks.
- **Documentation Tags:** Source code uses custom tags like `@section`, `@description`, `@example`, and `@option` for documentation extraction.

## Agent Interaction Rules (MANDATORY)

- **Task Management:** ALWAYS create a todo list using `write_todos` before starting any multi-step task. Update it as you progress.
- **Brevity:** Maintain telegraphic communication. Avoid filler, apologies, and wordy explanations. Max 30 words of prose per turn.
- **Parallelism:** Maximize parallel tool calls to reduce turns.
- **Verification:** Always verify changes by running relevant tests (e.g., `make test` or `./tests/test.sh`).
- **Style Alignment:** Strictly adhere to the `L_`/`_L_` prefixing and `snake_case` naming conventions.
