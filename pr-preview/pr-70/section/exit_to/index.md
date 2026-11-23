## API Reference

## exit_to

### L_exit_into

store exit status of a command to a variable

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

### L_exit_into_1null

convert exit code to the word yes or to nothing

Example

```
L_exit_into_1null suceeded test "$#" = 0
echo "${suceeded:+"SUCCESS"}"  # prints SUCCESS or nothing
```

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

### L_exit_into_1unset

convert exit code to the word yes or to unset variable

Example

```
L_exit_into_1null suceeded test "$#" = 0
echo "${suceeded:+"SUCCESS"}"  # prints SUCCESS or nothing
```

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute

### L_exit_into_10

store 1 if command exited with 0, store 0 if command exited with nonzero

**Arguments:**

- **`$1`** variable
- **`$@`** command to execute
