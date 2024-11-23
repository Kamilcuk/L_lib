# L_lib.sh

Bash library. Collection of functions and libraries that I deem usefull for writing other scripts.

# Features

## List of functions

[See the generated documentation on github pages](https://kamilcuk.github.io/L_lib.sh).

The work is split on sections, each section has separate documentation.

# Conventions

- `L_*` prefix for public symbols
- `_L_*` prefix for private symbols
- Local variables in functions taking namereference also start with `_L_*` prefix
- UPPER CASE for readonly variables
- lower case for functions and mutable variables
- snake case for everything
- `-v <var>` option is used to store the result in a variable
  - This is similar to `printf -v <var>`
  - Without the -v option, the function outputs elements on lines.

# License

LGPL
