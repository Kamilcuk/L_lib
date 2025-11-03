Functions that are useful for writing utility functions that use getopts or similar and want to print simple error message in the terminal.

The idea is to print usable message to the user and spent no time creating it.

How it works:

- Bash function has a help message stored in the comment preceeding the function.
- We can extract the comment by finding the function definition and parsing the file.
- The comment becomes the help message.
- Usage is extracted from comment by parsing lines that match the format of https://github.com/Kamilcuk/mkdocstrings-sh .
   - `# @option -o <var> description` - describes a short option taking an argument
   - `# @option -o description` - describes a short option not taking an argument
   - `# @arg name description` - describes an argument called name.
   - `# @usage description` - allows to specify custom usage line

How to use:

- Use `L_func_help` to print the help message.
- Use `L_func_error "error message" || return 2` to print the error message with usage of the function, and then return from your function.
- Use `L_func_assert "not enough arguments" test "$#" -lt 1 || return 2` to print the error message with usage of the function and then return from your function when the command `test "$#" -lt 1` fails, which effectively checks if there are enough arguments.

::: bin/L_lib.sh func
