# L_lib Test Patterns

## Basic Test Function
```bash
_L_test_feature_name() {
    # Test logic here
    L_unittest_success L_feature_func "arg1"
}
```

## Testing for Specific Output
```bash
_L_test_output() {
    L_unittest_cmd -o "expected output" L_print_func "input"
}
```

## Testing for Errors and Stderr
```bash
_L_test_errors() {
    # -j joins stderr to stdout for comparison
    L_unittest_cmd -j -r "Usage:.*" L_argparse_fail -h
}
```

## Mocking / Isolation
Use subshells for isolation if modifying global state (though `L_unittest_main` often runs tests in subshells by default).
```bash
_L_test_isolated() {
    (
        export MOCK_VAR=1
        L_unittest_eq "$(L_some_func)" "mocked result"
    )
}
```

## Array Testing
```bash
_L_test_arrays() {
    local -a myarr=("a" "b" "c")
    L_unittest_arreq myarr "a" "b" "c"
}
```

## Variable Assignment (`-v` pattern)
```bash
_L_test_v_pattern() {
    local result
    L_string_trim -v result "  foo  "
    L_unittest_vareq result "foo"
}
```
