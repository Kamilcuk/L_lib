# basic

These are some functions that I call "basic" because they are really that useful.
The create the "base" programming experience and feel I want to expect from a programming language.

The are many functions here that I am not sure how to group correctly. They should be grouped in smaller sections.

## L_assert

This function is used to assert that a condition is true. If the condition is false, it will print an error message and exit the script.

```bash
L_assert "This is a message to print" command that needs to return true
L_assert "not enough arguments" test "$#" -eq 2
```

## L_is_valid_variable_name

```
indirect_set_variable() {
  L_assert "Invalid variable name" L_is_valid_variable_name "$1"
  eval "$1=\"${2:-}\""
}
```

## L_is_main

This function is used to check if the script is being run as the main script or if it is being sourced by another script. It returns 0 if the script is being run as the main script, and 1 if it is being sourced.

# Generated section documentation:

::: bin/L_lib.sh basic
