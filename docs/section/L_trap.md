# L_trap

Trap and other related functions.

The most important and overused function is here `L_print_traceback`. It print the full traceback with the source code locations. This is one of the features I missed in Bash a lot. Where did the error happen?

When `. L_lib.sh` is sourced without `-n` argument, it executes [`L_trap_err_init`](#L_lib.sh--L_trap_err_init). If `set -e` is set and `trap ERR` is empty, it will execute the function [`L_trap_err_enable`](#L_lib.sh--L_trap_err_enable) to set the trap on ERR to print the traceback if a command fails. 

You can also `trap 'L_trap_err $?' EXIT` to print the error code and the last command that failed. This is useful for debugging.

It is all built around [`L_print_traceback`](#L_lib.sh--L_print_traceback) function which prints the whole bash traceback in a python-like format style.

Then there are [`L_trap_push`](#L_lib.sh--L_trap_push) and [`L_trap_pop`](#L_lib.sh--L_trap_pop) functions to push and pop another code block with a newline to the trap handler. This is a work in progress, as it would be amazing to handle `$?` correctly.

::: bin/L_lib.sh trap

