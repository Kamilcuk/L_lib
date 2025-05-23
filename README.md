# L_lib.sh

Bash library. Collection of functions and libraries that I deem usefull for writing other scripts.

<!-- vim-markdown-toc GFM -->

* [Features](#features)
  * [Various useful functionsand variables](#various-useful-functionsand-variables)
  * [Color](#color)
  * [Logging](#logging)
  * [Argument parsing](#argument-parsing)
  * [Unittest](#unittest)
  * [Version](#version)
  * [Trap](#trap)
  * [Map](#map)
  * [Simple subcommand utility](#simple-subcommand-utility)
* [Conventions](#conventions)
* [License](#license)

<!-- vim-markdown-toc -->

# Features

- bash >= 3.2
- speed
- colored output
- logging library
- trap library

## Various useful functionsand variables

The generated documentation on github pages contains a list of all functions and variables available at
[https://kamilcuk.github.io/L_lib/](https://kamilcuk.github.io/L_lib/) .

Variables `$L_NAME` is the name of the executable `$0` and `L_DIR` has the directory of the `$0` executable.
It is typical to start scripts with `cd "$(dirname "$(readlink -f "$0")")"` to get the full path of the script and then `cd` to the directory of the script.
The variables do not resolve `readlink`.

Example:

```
#!/usr/bin/env bash
. L_lib.sh
cd "$L_DIR" || exit 1
fail() {
  echo "$L_NAME: $1"
  exit 1
}
```
## Color

Color library that provides functions for coloring text.

```
echo "${L_RED}Red text${L_RESET}"
```

The function `L_color_detect` is used to detect if the terminal supports colors and sets the variables accordingly to empty or to ANSI escape sequence.

The variables `L_ANSI_*` like `L_ANSI_RED` are constants always set to the ANSI escape sequence for the color.

See list of variables at https://kamilcuk.github.io/L_lib/#colors .

## Logging

See [docs/section/logging.md](docs/section/log.md) for documentation.

## Argument parsing

See [docs/section/argparse.md](docs/section/argparse.md) for documentation.

## Unittest

See [docs/section/unittest.md](docs/section/unittest.md) for documentation.

## Version

`L_version_cmp` allows to check version.

```
if L_version_cmp "$BASH_VERSION" -gt 4; then
  echo "Bash version is greater than 4"
fi
```

## Trap

Trap library allows to get properly quoted trap value from `trap -l` script and append to the trap.

```
(
  tmpf=$(mktemp)
  L_trap_push 'rm "$tmpf"' EXIT
  tmpf2=$(mktemp)
  L_trap_push 'rm "$tmpf2"' EXIT
  exit # will remove both files on EXIT
  L_trap_pop
  exit # will remove only $tmpf on EXIT
  L_trap_pop
  exit # will not remove any files
)
```

## Map

A key value implementation for bash version before associative arrays suppport.

```
L_map_init themap
L_map_set themap key value
if L_map_get -v var themap key; then
  echo "The value of key in themap is $var"
fi
```

See list of functions in [https://kamilcuk.github.io/L_lib/#map](https://kamilcuk.github.io/L_lib/#map).

## Simple subcommand utility

The `. L_lib.sh` takes a `cmd` subcommand that allows to user defined functions with a prefix. It works as a simple and crude command line parsing tool.

The following script `./script.sh`:

```
#!/usr/bin/env bash

CMD_printpdf() {
  echo "Printing PDF"
}

CMD_printtxt() {
  echo "Printing TXT"
}

. L_lib.sh cmd CMD_ "$@"
```

Will allow to run `./script.sh printpdf` and `./script.sh printtxt` to run the respective functions.

Additionally bash completion is supported for the subcommands. Can be generated with:

```
eval "$(./script.sh --bash-completion)"
```

# Conventions

- `L_*` prefix for public symbols
- `_L_*` prefix for private symbols
  - used in all functions taking namereference to a variable
- Local variables in functions taking namereference also start with `_L_*` prefix
- UPPER CASE for readonly variables
- lower case for functions and mutable variables
- snake case for everything
- `-v <var>` option is used to store the result in a variable instead of printing it
  - This is similar to `printf -v <var>`
  - Without the -v option, the function outputs elements on lines.
- Function ending with `_v` store the result in a hardcoded scratch variable `L_v`.

# License

LGPL
