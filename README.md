# L_lib.sh

![my labrador dog](labrador.jpg)

Labrador Bash library. Collection of functions and libraries that I deem useful for working with Bash.

<!-- vim-markdown-toc GFM -->

* [Documentation](https://kamilcuk.github.io/L_lib/)
* [Installation](#installation)
* [Features](#features)
* [Conventions](#conventions)
* [License](#license)

<!-- vim-markdown-toc -->

# Installation

## Package Managers

Install L_lib using your preferred Bash package manager:

### Basher
```bash
basher install Kamilcuk/L_lib
```

### bpkg
```bash
bpkg install Kamilcuk/L_lib
```

### Shpkg
```bash
shpkg install Kamilcuk/L_lib
```

## Manual Installation

The library is one file. Download the latest release from GitHub and put in your PATH:

```bash
mkdir -vp ~/.local/bin/
curl -o ~/.local/bin/L_lib.sh https://raw.githubusercontent.com/Kamilcuk/L_lib/refs/heads/v1/bin/L_lib.sh
export PATH=~/.local/bin:$PATH
```

## Usage

You can use the library in scripts with:

```bash
. L_lib.sh -s
```

Unless `-n`, sourcing the library will enable `extglob` and `patsub_replacement` and, if `set -e` is set, register a `ERR` trap that will print a nice traceback on unhandled error.

You can test the library ad-hoc:

```bash
bash <(curl -sS https://raw.githubusercontent.com/Kamilcuk/L_lib/refs/heads/v1/bin/L_lib.sh) L_setx L_log 'Hello world'
```

# Features

Below is some list with some of the library features. The library contains much more.

- Argument parsing in Bash with short, long options, sub-parsers, sub-functions support and shell completion
    [`L_argparse`](https://kamilcuk.github.io/L_lib/section/argparse/)
- Logging library with levels and configurable output and filtering
    [`L_log_configure`](https://kamilcuk.github.io/L_lib/section/log/)
    [`L_info`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_info)
    [`L_logrun`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_logrun)
    [`L_run`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_run)
- Pretty function stack printing usually on ERR trap
    [`L_print_traceback`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_print_traceback)
- Execute an action on EXIT, any terminating signal or RETURN trap of any function
    [`L_finally`](https://kamilcuk.github.io/L_lib/section/finally/)
- Create temporary directory and `cd` to it for the duration of a function with auto removal after return
    [`L_with_cd`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_with_cd)
    [`L_with_cd_tmpdir`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_with_cd_tmpdir)
- Create unidirectional connected two file descriptors
    [`L_pipe`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_pipe)
- Create and manage multiple processes with separate file descriptors for standard input and standard output
    [`L_proc_popen`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_proc_popen)
    [`L_proc_communicate`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_proc_communicate)
    [`L_proc_kill`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_proc_kill)
- Temporary enable or disable shell features `set -x` for the duration of a command
    [`L_setx`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_setx)
    [`L_unsetx`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_unsetx)
    [`L_extglob`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_extglob)
- Easily sort a Bash arrays containing any characters
    [`L_sort`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_sort)
- failure handling utilities
    [`L_assert`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_assert)
    [`L_die`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_die)
    [`L_check`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_check)
    [`L_panic`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_panic)
- Variables holding color codes depending on terminal support
    [`L_color_detect`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_color_detect)
    [`$L_RED`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--$L_RED)
    [`$L_BLUE`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--$L_BLUE)
- checking Bash features and version
    [`$L_BASH_VERSION`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_BASH_VERSION)
    [`$L_HAS_BASH4_0`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_HAS_BASH4_0)
    [`$L_HAS_COMPGEN_V`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_HAS_COMPGEN_V)
    [`$L_HAS_WAIT_N`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_HAS_WAIT_N)
- Waiting on multiple PIDs with a timeout ignoring signals and collecting all exit codes
    [`L_wait`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_wait)
- Simplify storing exit status of a command into a variable
    [`L_exit_to`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_exit_to)
    [`L_exit_to_10`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_exit_to_10)
- help with path operations, with `PATH` or `PYTHONPATH` manipulation
    [`L_path_stem`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_path_stem)
    [`L_dir_is_empty`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_dir_is_empty)
    [`L_path_append`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_path_append)
    [`L_path_relative_to`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_path_relative_to)
- string utilities
    [`L_strip`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_strip)
    [`L_strupper`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_strupper)
    [`L_strstr`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_strstr)
    [`L_html_escape`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_html_escape)
    [`L_urlencode`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_urlencode)
- Split string without remote execution and understand `$''` sequences
    [`L_str_split`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_str_split)
- Template output
    [`L_percent_format`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_percent_format)
    [`L_fstring`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_fstring)
- JSON escape
    [`L_json_escape`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_json_escape)
- Cache commands execution with TTL in memory or file
    [`L_cache`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_cache)
    [`L_cache_decorate`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_cache_decorate)
- Easy writing function utilities by supporting `-v <var>` option or extracting comment before function
    [`L_handle_v_scalar`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_handle_v_scalar)
    [`L_func_help`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_func_help)
    [`L_func_usage_error`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_func_usage_error)
    [`L_decorate`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_decorate)
- All with support for any Bash versions from 3.2 to latest with portability functions
    [`L_readarray`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_readarray)
    [`L_epochrealtime_usec`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_epochrealtime_usec)
    [`L_compgen -V`](https://kamilcuk.github.io/L_lib/section/all/#L_lib.sh--L_compgen)

# Talk to me

Kindly feel free to have conversations and ask questions on [GitHub discussion](https://github.com/Kamilcuk/L_lib/discussions).

Report bugs using [GitHub issue](https://github.com/Kamilcuk/L_lib/issues).

# Conventions

- `L_*` prefix for public symbols.
- `_L_*` prefix for private symbols, including local variables in functions taking a name-reference.
- Upper case used for global scope read-only variables.
- Lower case used for functions and user mutable variables
- Snake case for everything.
- The option `-v <var>` is used to store the result in a variable instead of printing it.
    - This follows the convention of `printf -v <var>`.
    - Without the `-v` option, the function outputs the elements on lines to standard output.
    - Associated function with `_v` suffix store the result in a hardcoded scratch variable `L_v`.
- return 2 on usage error, return 124 on timeout

# License

LGPL
