# L_lib Unittest Writer

This skill guides the creation of unit tests for the `L_lib.sh` library.

## Workflow

1. **Identify Functionality**: Determine the `L_` function to test.
1. **Locate Test File**: Find the corresponding test file in `tests/` (e.g., `tests/test_xargs.sh` for `L_xargs`). Create a new file if necessary.
1. **Implement Test Function**:
   - Name: `_L_test_<function_name>`
   - Use `local` for all variables.
   - Use `L_unittest_*` assertions.
1. **Register Test**: If using a new file, source it in `tests/test.sh`.
1. **Verify**: Run `./tests/test.sh -k <function_name>`.

## Core Conventions

- **Prefixes**: Test functions MUST start with `_L_test_`.
- **Assertions**: Use the built-in `L_unittest_*` framework.
- **Isolation**: Tests are typically run in subshells, but explicit subshells `( ... )` are recommended when modifying global state or environment.
- **Portability**: Ensure tests work across Bash 3.2 to 5.2+. Avoid features like `[[ -v ]]` if compatibility is required (use `L_var_is_set`).

## Resources

- **Assertions Reference**: See [references/assertions.md](https://Kamilcuk.github.io/L_lib/pr-preview/pr-64/skill-unittest/references/assertions.md) for a full list of `L_unittest_*` functions.
- **Common Patterns**: See [references/patterns.sh](https://Kamilcuk.github.io/L_lib/pr-preview/pr-64/skill-unittest/references/patterns.sh) for examples of common test scenarios.

## Verification Command

```
./tests/test.sh -k <test_name_filter>
```
