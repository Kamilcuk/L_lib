# L_color

Use the `L_*` variables for colored output.

Use `L_RESET` or `L_COLORRESET` to reset color to defaults.

Use `L_color_detect` to detect if the terminal is supposed to support colors.

The interface is not great. The ultimate goal was to not to use any subshells.

The `L_color_detect` function sets or clears the `L_*` variables related to colors.

The issue is that if you redirect the output, you have to call L_color_detect again for each file descriptor change.

Additionally, if you output to a different file descriptor, you have to call `L_color_detect` again each time changing the file descriptor.

Usually, colors are really used for logging output. Like the following:

The function L_color_detect is not even that costly. However, I do not enjoy the alternative of spawning a subshell.

```
exec {logfd}>&1
L_color_detect >&$logfd
echo "$L_GREEN""Hello world""$L_RESET" >&$logfd
```

## Generated documentation from source:

::: bin/L_lib.sh colors
