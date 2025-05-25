# L_lib.sh

![my labrador dog](labrador.jpg)

Labrador Bash library. Collection of functions and libraries that I deem usefull for writing other Bash scripts.

<!-- vim-markdown-toc GFM -->

* [Features](#features)
* [Documentation](#documentation)
* [Conventions](#conventions)
* [License](#license)

<!-- vim-markdown-toc -->

Kindly feel free to have converstations and ask questions on [Github discussion](https://github.com/Kamilcuk/L_lib/discussions) and report bugs using [Github issue](https://github.com/Kamilcuk/L_lib/issues).

# Features

- supports all Bash versions from 3.2
- argument parsing library
- colored output
- logging library
- printing stacktrace on error
- multiple coprocesses library
- dictionary library for Bash before associative array
- and over 250 other functions with many many more

# Documentation

Kindly visit [https://kamilcuk.github.io/L_lib/](https://kamilcuk.github.io/L_lib/) for the generated documentation.

# Conventions

- `L_*` prefix for public symbols.
- `_L_*` prefix for private symbols, including local variables in functions taking a namereference.
- Upper case used for global scope readonly variables.
- Lower case used for functions and user mutable variables
- Snake case for everything.
- The option `-v <var>` is used to store the result in a variable instead of printing it.
  - This follows the convention of `printf -v <var>`.
  - Without the `-v` option, the function outputs the elements on lines to stdout.
  - Functions ending with `_v` store the result in a hardcoded scratch variable `L_v`.

# License

LGPL
