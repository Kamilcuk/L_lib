# L_trap

Trap and other related functions.

The most important and overused function is here `L_print_traceback`. It print the full traceback with the source code locations. This is one of the features I missed in Bash a lot. Where did the error happen?

When `. L_lib.sh` is sourced without `-n` argument, it executes [`L_trap_err_init`](#L_lib.sh--L_trap_err_init). If `set -e` is set and `trap ERR` is empty, it will execute the function [`L_trap_err_enable`](#L_lib.sh--L_trap_err_enable) to set the trap on ERR to print the traceback if a command fails.

You can also `trap 'L_trap_err $?' EXIT` to print the error code and the last command that failed. This is useful for debugging.

It is all built around [`L_print_traceback`](#L_lib.sh--L_print_traceback) function which prints the whole bash traceback in a python-like format style.

Then there are [`L_trap_push`](#L_lib.sh--L_trap_push) and [`L_trap_pop`](#L_lib.sh--L_trap_pop) functions to push and pop another code block with a newline to the trap handler. This is a work in progress, as it would be amazing to handle `$?` correctly.

## API Reference

## trap

### L_print_traceback

Prints traceback

Example

```
Example traceback:
Traceback from pid 3973390 (most recent call last):
  File ./bin/L_lib.sh, line 2921, in main()
2921 >> _L_lib_main "$@"
  File ./bin/L_lib.sh, line 2912, in _L_lib_main()
2912 >>                 "test") _L_lib_run_tests "$@"; ;;
  File ./bin/L_lib.sh, line 2793, in _L_lib_run_tests()
2793 >>                 "$_L_test"
  File ./bin/L_lib.sh, line 891, in _L_test_other()
891  >>                 L_unittest_eq "$max" 4
  File ./bin/L_lib.sh, line 1412, in L_unittest_eq()
1412 >>                 _L_unittest_showdiff "$1" "$2"
  File ./bin/L_lib.sh, line 1391, in _L_unittest_showdiff()
1391 >>                 sdiff <(cat <<<"$1") - <<<"$2"
```

**Arguments:**

- **`[$1]`** int stack offset to start from (default: 0)
- **`[$2]`** int number of lines to show around the line (default: 2)

**Uses environment variable:** **`_L_print_traceback_offset`**

### L_print_caller

Print simple traceback using builtin caller command.

### L_trap_err_small

Callback to be exectued on ERR trap that prints just the caller.

Example

```
trap 'L_trap_err_small' ERR
```

### L_trap_err

Callback to be exectued on ERR trap that prints a traceback and exits.

Example

```
trap 'L_trap_err $?' ERR
trap 'L_trap_err $?' EXIT
```

**Arguments:**

- **`$1`** int exit code
- **`$2`** BASH_COMMAND

### L_trap_err_enable

Enable ERR trap with L_trap_err as callback

set -eEo functrace and register trap 'L_trap_err $?' ERR.

Example

```
L_trap_err_enable
```

### L_trap_err_disable

Disable ERR trap

Example

```
L_trap_err_disable
```

### L_trap_err_init

If set -e is set and ERR trap is not set, enable ERR trap with L_trap_err as callback

Example

```
L_trap_err_init
```

### L_trap_names

Return an array of all trap names. Index is the trap name number.

**Option:** **`-v <var>`**

### L_trap_names_vL_RET

### L_trap_to_number

Convert trap name to number.

The DEBUG ERROR and RETURN traps have a number as reported by $BASH_TRAPSIG inside the handler, but the number can't be used to register the trap with trap command.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** trap name or trap number

### L_trap_to_number_vL_RET

### L_trap_to_name

convert trap number to trap name

Example

```
L_trap_to_name -v var 0 && L_assert '' test "$var" = EXIT
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** signal name or signal number

### L_trap_to_name_vL_RET

### L_trap_get

Get the current value of trap

Example

```
trap 'echo hi' EXIT
L_trap_get -v var EXIT
L_assert '' test "$var" = 'echo hi'
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** signal name or number

### L_trap_get_vL_RET

### L_trap_push

Add a newline and the command to the trap value.

**Arguments:**

- **`$1`** str command to execute
- **`$2`** str signal to handle

**Shellcheck disable=** [SC2064](https://www.shellcheck.net/wiki/SC2064)

**See:** [L_trap_pop](#L_lib.sh--L_trap_pop)

### L_trap_pop

Remove a line from the trap value from the end up until the last newline.

**Argument:** **`$1`** str signal to handle

**Shellcheck disable=** [SC2064](https://www.shellcheck.net/wiki/SC2064)

**See:** [L_trap_push](#L_lib.sh--L_trap_push)

### L_trap

Trap function with reversed order of arguments, to force expansions upon calling.

**Arguments:**

- **`$1`** Space or comma separated list of signal names or numbers.
- **`$@`** Action to execute.
