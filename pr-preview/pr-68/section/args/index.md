## API Reference

## args

Operations on list of arguments.

### L_args_join

Join arguments with separator

Example

```
L_args_join -v res ", " "Hello" "World"
echo "$res"  # prints Hello, World
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** separator
- **`$@`** arguments to join

**See:** [L_array_join](#L_lib.sh--L_array_join)

### L_args_join_vL_RET

### L_args_andjoin

Join arguments with ", " and last with " and "

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** arguments to join

### L_args_andjoin_vL_RET

### L_args_contain

Check if arguments starting from second contain the first argument.

Example

```
L_args_contain "Hello" "Hello" "World"
echo $?  # prints 0
```

**Arguments:**

- **`$1`** needle
- **`$@`** heystack

### L_args_index

Get index number of argument equal to the first argument.

Example

```
L_args_index -v res "World" "Hello" "World"
echo "$res"  # prints 1
```

**Option:** **`-v <var>`**

**Arguments:**

- **`$1`** needle
- **`$@`** heystack

### L_args_index_vL_RET

### L_max

return max of arguments

Example

```
L_max -v max 1 2 3 4
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** int arguments

### L_max_vL_RET

**Sets variable:** **`L_RET`**

**Shellcheck disable=** [SC1105](https://www.shellcheck.net/wiki/SC1105) [SC2094](https://www.shellcheck.net/wiki/SC2094) [SC2035](https://www.shellcheck.net/wiki/SC2035)

### L_min

return max of arguments

Example

```
L_min -v min 1 2 3 4
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** int arguments

### L_min_vL_RET

**Sets variable:** **`L_RET`**

**Shellcheck disable=** [SC1105](https://www.shellcheck.net/wiki/SC1105) [SC2094](https://www.shellcheck.net/wiki/SC2094) [SC2035](https://www.shellcheck.net/wiki/SC2035)
