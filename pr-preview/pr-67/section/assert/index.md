These functions are used to terminate the control flow in case or errors.

## API Reference

## assert

### L_panic

Print stacktrace and the message to stderr and exit with 29.

Example

```
[[ -r "$file" ]] || L_panic "File is not readable: $file"
```

**Option:** **`-[0-9]+`** Exit with this number.

**Argument:** **`$@`** Message to print.

**See:**

- [L_assert](#L_lib.sh--L_assert)
- [L_exit](#L_lib.sh--L_exit)
- [L_check](#L_lib.sh--L_check)

### L_assert

Assert the command succeeds.

Execute a command given from the second positional argument. When the command fails, execute `L_panic`. Note: `[[` is a bash syntax sugar and is not a command. `!` is also not a standalone command or builtin, so it can't be used with this function. You could use `eval "[[ ${var@Q} = ${var@Q} ]]"`. However to prevent quoting issues it is simpler to use wrapper functions. The function `L_regex_match` `L_glob_match` `L_not` are useful for writing assertions. To invert the test use `L_not` which just executes `! "$@"`.

Example

```
L_assert 'wrong number of arguments' [ "$#" -eq 0 ]
L_assert 'first argument must be equal to insert' test "$1" = "insert
L_assert 'var has to match regex' L_regex_match "$var" ".*test.*"
L_assert 'var has to not match regex' L_not L_regex_match "$var" "[yY][eE][sS]"
L_assert 'var has to matcha glob' L_glob_match "$var" "*glob*"
```

**Arguments:**

- **`$1`**

  str Assertion description.

  If the description starts with '-[0-9]+', the number is used as the exit code for L_panic.

- **`$@`** command to test

### L_die

Print the arguments to standard error and exit wtih 28.

Example

```
test -r file || L_die "File is not readable"
```

**Option:** **`-[0-9]+`** Exit with this number.

**See:**

- [L_panic](#L_lib.sh--L_panic)
- [L_exit](#L_lib.sh--L_exit)
- [L_check](#L_lib.sh--L_check)
- [L_assert](#L_lib.sh--L_assert)

### L_exit

With no arguments or an empty string, exit with 0.

Otherwise, the arguments are printed to stderr and exit with 1.

Note

If you want to exit with number, just call builtin exit,

Example

```
err=()
test -r file || err+=("file is not readable")
test -f file || err+=("file is not a file")
L_exit "${err[@]}"
```

**See:**

- [L_panic](#L_lib.sh--L_panic)
- [L_assert](#L_lib.sh--L_assert)
- [L_check](#L_lib.sh--L_check)

### L_check

Execute a command given from the second argument. If the command fails, call `L_exit`. The difference to `L_assert` is that it prints calltrace on error. `L_check` function only prints the error message with the program name on error. Execute a command given from the second argument. If the command fails, call `L_exit`. The difference to `L_assert` is that it prints calltrace on error. `L_check` function only prints the error message with the program name on error.

**See:**

- [L_panic](#L_lib.sh--L_panic)
- [L_assert](#L_lib.sh--L_assert)
- [L_check](#L_lib.sh--L_check)
- [L_panic](#L_lib.sh--L_panic)
- [L_assert](#L_lib.sh--L_assert)
- [L_check](#L_lib.sh--L_check)
