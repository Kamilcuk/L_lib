______________________________________________________________________

name: l-lib description: L_lib - Labrador Bash library: comprehensive Bash library for argument parsing, logging, error handling, parallel execution, string/array utilities, and more

______________________________________________________________________

# L_lib Skill

This skill provides guidance for **using** the L_lib (Labrador Bash library) in your own Bash scripts and projects. Optimized for LLM consumption with direct links to raw markdown documentation.

## Installation

### Download (Recommended)

```
mkdir -vp ~/.local/bin/
wget -O ~/.local/bin/L_lib.sh https://github.com/Kamilcuk/L_lib/releases/download/v2.0.4/L_lib.sh
chmod +x ~/.local/bin/L_lib.sh
export PATH=~/.local/bin:$PATH
```

### Pip

```
pip install L_lib
```

### Basher

```
basher install Kamilcuk/L_lib
```

## Quick Start

```
#!/usr/bin/env bash
. L_lib.sh -s

L_log "Starting script"
L_info "This is an info message"
L_warn "This is a warning"
```

The `-s` flag enables `extglob`, `patsub_replacement`, and installs an ERR traceback handler (when `set -e` is active).

## Key Conventions

| Convention              | Description                                                     |
| ----------------------- | --------------------------------------------------------------- |
| **Public functions**    | `L_*` prefix (e.g., `L_log`, `L_argparse`)                      |
| **Private/internal**    | `_L_*` prefix — do not use directly                             |
| **Global constants**    | UPPER_SNAKE_CASE (e.g., `L_RED`, `L_HAS_WAIT_N`)                |
| **Functions/variables** | lower_snake_case                                                |
| **Return values**       | Use `-v <var>` to store in variable, otherwise prints to stdout |

## Core Modules with Examples

### Argument Parsing — `L_argparse`

```
L_argparse \
  description="My script does things" \
  dest_prefix=opt_ \
  :: -v --verbose flag=1 help="Enable verbose output" \
  :: -o --output help="Output file path" \
  :: -n --dry-run flag=1 help="Show what would be done" \
  :: input nargs=1 help="Input file (required)" \
  :::: "$@"
```

Variables: `opt_verbose`, `opt_output`, `opt_dry_run`, `opt_input`

**Key options:** `dest_prefix=`, `flag=1`, `nargs=N` (1, ?, \*, +, remainder), `default=`, `help=`

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/argparse.md>

### Logging — `L_log`, `L_info`, `L_warn`, `L_error`, `L_debug`

```
L_log_configure level=info color=auto output=stderr
L_debug "Debug detail"
L_info "Information"
L_warn "Warning message"
L_error "Error occurred"
L_logrun "Building project" -- make build
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/log.md>

### Finally / Cleanup — `L_finally`, `L_finally_push`

```
main() {
  L_finally 'rm -f "$tmpfile"'
  L_finally_push 'echo "Cleaning up..."'
  tmpfile=$(mktemp)
  L_finally "rm -f '$tmpfile'"
  risky_operation
}
main "$@"
```

- `L_finally 'cmd'` — runs on EXIT (script end)
- `L_finally_push 'cmd'` — runs on RETURN (function exit)

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/finally.md>

### Error Handling — `L_panic`, `L_assert`, `L_die`, `L_check`

```
L_assert [[ -f "$config" ]] "Config file required: $config"
L_assert (( count > 0 )) "Count must be positive"
L_panic "Fatal: cannot connect to database"
L_die 64 "Usage: script <input>"
L_check [[ -r "$file" ]] && process "$file"
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/assert.md>

### Parallel Execution — `L_xargs`, `L_foreach`

```
items=(file1.txt file2.txt file3.txt)
process_file() { L_info "Processing $1"; sleep 1; }
L_xargs -P 4 -A items process_file

L_foreach item in "${items[@]}"; do
  echo "Processing $item (index: $_L_foreach_index, first: $_L_foreach_first)"
done
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/xargs.md> 📖 **Foreach docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/foreach.md>

### String Utilities

```
L_strip -v result "  hello world  "
L_strupper -v result "hello"
L_strlower -v result "HELLO"
L_strjoin -v result "," a b c
L_strsplit -v arr "," "a,b,c"
L_fstring -v result "Hello {name}!" name="World"
L_percent_format -v result "%s: %d" "Count" 42
L_html_escape -v result "<script>"
L_urlencode -v result "hello world"
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/string.md>

### Array Utilities

```
L_sort -v sorted_arr "${unsorted[@]}"
L_readarray -t lines < <(command)
L_reverse -v reversed_arr "${arr[@]}"
L_unique -v unique_arr "${arr[@]}"
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/array.md>

### Process Management — `L_proc_popen`, `L_proc_communicate`, `L_wait`

```
L_proc_popen -v pid cat
L_proc_communicate "$pid" "input data" stdout_var stderr_var
L_wait -t 10 "$pid"
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/proc.md>

### Event Loop (Async) — `L_uv_init`, `L_uv_add_timer`, `L_uv_run`

```
L_uv_init
L_uv_add_timer -v timer 1000 'L_info "Timer fired!"'
L_uv_add_timer -v timer2 500 'L_info "Half second"'
L_uv_run
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/uv.md>

### Caching — `L_cache`

```
L_cache -t 3600 -v result -- expensive_computation arg1 arg2
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/cache.md>

### Colors & Terminal

```
L_color_detect
echo "${L_RED}Error${L_RESET}"
echo "${L_GREEN}Success${L_RESET}"
echo "${L_BLUE}Info${L_RESET}"
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/colors.md>

### Path Utilities

```
L_path_stem -v stem "/path/to/file.txt"
L_path_dir -v dir "/path/to/file.txt"
L_path_relative_to -v rel "/a/b/c" "/a"
L_path_append -v newpath "/existing" "new"
L_dir_is_empty "/tmp/emptydir" && echo "Empty"
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/path.md>

### Function Utilities — `L_handle_v_scalar`, `L_func_help`, `L_decorate`

```
my_function() {
  L_handle_v_scalar varname "$@" || return
  local result="computed value"
  L_handle_v_scalar_assign varname "$result"
}
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/func.md>

### With Helpers — `L_with_tmpfile_into`, `L_with_process_into`, `L_with_cd`

```
L_with_tmpfile_into -v result -- my_command arg1 arg2
L_with_process_into -v stdout -v stderr -- my_command
L_with_cd /tmp -- my_command
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/with.md>

### JSON & Other Utilities

```
L_json_escape -v result '{"key": "value"}'
L_table -v table_data -H "Name" "Value" -R "a" "1" -R "b" "2"
L_pretty_print -v result my_array
```

📖 **Full docs**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/json.md> 📖 **Utilities**: <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/docs/section/utilities.md>

## Common Patterns

### Standard Script Template

```
#!/usr/bin/env bash
set -euo pipefail
. L_lib.sh -s

main() {
  L_argparse \
    description="My awesome script" \
    dest_prefix=opt_ \
    :: -v --verbose flag=1 \
    :: -h --help flag=1 help="Show help" \
    :: input nargs=1 help="Input file" \
    :::: "$@"

  (( opt_verbose )) && L_log_configure level=debug
  L_info "Processing ${opt_input}"
}
main "$@"
```

### Function with `-v` Output Support

```
my_function() {
  L_handle_v_scalar varname "$@" || return
  local result="computed value"
  L_handle_v_scalar_assign varname "$result"
}
my_function -v myvar
my_function  # prints to stdout
```

### Using Scratch Variable `L_RET`

```
L_strip -v L_RET "  hello  "
echo "$L_RET"  # "hello"
```

### Checking Bash Features

```
if (( L_HAS_BASH4 )); then
  declare -A mymap
fi
if (( L_HAS_WAIT_N )); then
  # wait -n available
fi
```

## Useful Global Variables (Read-Only)

| Variable                                                                   | Description                          |
| -------------------------------------------------------------------------- | ------------------------------------ |
| `L_BASH_VERSION`                                                           | Current Bash version string          |
| `L_HAS_BASH4`                                                              | 1 if Bash 4.0+ features available    |
| `L_HAS_WAIT_N`                                                             | 1 if `wait -n` supported             |
| `L_HAS_COMPGEN_V`                                                          | 1 if `compgen -v` supported          |
| `L_RED`, `L_GREEN`, `L_YELLOW`, `L_BLUE`, `L_MAGENTA`, `L_CYAN`, `L_RESET` | ANSI colors (after `L_color_detect`) |
| `L_NL`                                                                     | Newline character (`$'\n'`)          |
| `L_TAB`                                                                    | Tab character (`$'\t'`)              |

## Tips for Users

1. **Always source with `. L_lib.sh -s`** in your scripts
1. **Use `dest_prefix=`** with `L_argparse` to avoid variable collisions
1. **Prefer `L_finally` over manual `trap`** — handles signals, RETURN, EXIT correctly
1. **Use `L_panic` for fatal errors** — prints full traceback automatically
1. **Use `L_xargs` for parallel work** — handles concurrency, timeouts, error collection
1. **Check `$L_HAS_*` before using newer Bash features** — ensures portability
1. **Run `shellcheck` on your scripts** — L_lib is shellcheck-clean

## Version Compatibility

Supports **Bash 3.2 through latest** (tested on 3.2, 4.0+, 5.0+). Uses runtime feature detection (`$L_HAS_*` variables) rather than version checks.

## License

GPL-3.0 — <https://raw.githubusercontent.com/Kamilcuk/L_lib/main/LICENSE>
