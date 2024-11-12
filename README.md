# L_lib.sh

Bash library. Collection of functions and libraries that I deem usefull for writing other scripts.

# Features

## List of functions

[See the generated documentation on github pages](https://kamilcuk.github.io/L_lib.sh).

The work is split on sections, each section has separate documentation.

# Conventions

- `L_*` prefix for public symbols
- `_L_*` prefix for private symbols
  - Local variables in functions taking namereference have to start with `_L_*` prefix
- UPPER CASE for readonly variables
- lower snake case for everything else
- Many functions are taking `-v <var>` that set variables, just like `printf -v <var>` without subshell
  - For developers: use `_L_handle_v` to handle -v argument easily.

# License

LGPL
