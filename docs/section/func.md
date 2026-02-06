Functions that are useful for writing utility functions that use `getopts` or similar and want to print simple error messages in the terminal.

The idea is to print a usable message to the user while spending no time creating it manually.

## Usage Guide

### Self-Documenting Functions

The core feature of this module is extracting documentation from comments directly above the function definition. This allows you to maintain the help message and the code in one place.

The comments should follow a specific format compatible with `mkdocstrings-sh`:

- `# @option -o <var> description`: Describes a short option taking an argument.
- `# @option -o description`: Describes a short option not taking an argument.
- `# @arg name description`: Describes a positional argument.
- `# @usage description`: (Optional) Specifies a custom usage line.

### Example Implementation

Here is a complete example of a function using `L_func` utilities:

```bash
# @description Deploys an artifact to a server.
# @option -v        Enable verbose mode.
# @option -u <user> User to deploy as. Default: current user.
# @option -h        Print this help and return 0.
# @arg file         The file to deploy.
# @arg [dest]       The destination path. Default: /tmp.
deploy_artifact() {
    local OPTIND OPTARG OPTERR opt verbose=0 user="$USER"
    while getopts vu:h opt; do
        case "$opt" in
            v) verbose=1 ;;
            u) user="$OPTARG" ;;
            h) L_func_help; return 0 ;;
            *) L_func_usage; return 2 ;;
        esac
    done
    shift "$((OPTIND-1))"
    
    # Assertions simplify error checking
    L_func_assert "File argument is required" test "$#" -ge 1 || return 2
    L_func_assert "File does not exist: $1" test -f "$1" || return 2
    
    local file="$1" dest="${2:-/tmp}"
    
    # ... logic ...
}
```

### Printing Help (`L_func_help`)

Calling `L_func_help` inside your function parses the comments above the function and prints a formatted help message to stderr.

```bash
deploy_artifact -h
# Output:
# your_script.sh: deploy_artifact: Deploys an artifact to a server.
# @option -v        Enable verbose mode.
# @option -u <user> User to deploy as. Default: current user.
# @option -h        Print this help and return 0.
# @arg file         The file to deploy.
# @arg [dest]       The destination path. Default: /tmp.
```

### Printing Usage (`L_func_usage`)

`L_func_usage` parses the comments to automatically generate a standard usage line. This is useful for `getopts` `*)` case.

```bash
deploy_artifact -x
# Output:
# your_script.sh: illegal option -- x
# your_script.sh: usage: deploy_artifact [-vh] [-u user] file [dest]
```

### Handling Errors (`L_func_error`, `L_func_usage_error`)

- `L_func_error "message"`: Prints an error message prefixed with the function name.
- `L_func_usage_error "message"`: Prints the error message followed by the usage line.

```bash
L_func_error "Connection failed"
# Output: your_script.sh: deploy_artifact: error: Connection failed

L_func_usage_error "Invalid argument"
# Output:
# your_script.sh: deploy_artifact: error: Invalid argument
# your_script.sh: usage: deploy_artifact [-vh] [-u user] file [dest]
```

### Assertions (`L_func_assert`)

`L_func_assert` allows you to write concise checks. It runs a command (usually `test` or `[[ ... ]]`). If the command fails, it prints an error message and returns 2.

```bash
# Explicit check
if [[ ! -f "$file" ]]; then
    L_func_error "File not found: $file"
    return 2
fi

# Equivalent using L_func_assert
L_func_assert "File not found: $file" test -f "$file" || return 2
```

## API Reference

::: bin/L_lib.sh func
