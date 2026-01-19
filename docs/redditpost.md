# I made a Bash library that adds finally/defer, argparse, stack traces, and more

Hey r/Bash! I've been working on a library that brings some long-missing features to Bash scripting. It's called L_lib and I think you might find it useful.

## The Problem

We've all been there: writing Bash scripts that need proper cleanup, argument parsing beyond basic getopts, or debugging errors without knowing where they came from. Bash is powerful but missing some quality-of-life features that other languages have had for decades.

## What I Built

L_lib is a single-file library (works with Bash 3.2+) that adds:

### 1. **L_finally** - Finally blocks / defer for Bash

Ever wanted Python's `finally` or Go's `defer`? Now you can:

```bash
myfunc() {
    local tmpdir
    tmpdir=$(mktemp -d)
    L_finally rm -rf "$tmpdir"  # Cleanup runs on return, EXIT, or any signal

    # Do your work with tmpdir
    # Even if something fails, tmpdir gets cleaned up
}
```

This alone has saved me from so many leaked temp files and dangling resources.

### 2. **L_argparse** - Real argument parsing

Full-featured argument parser with long options, short options, subcommands, and even shell completion generation:

```bash
eval "$(L_argparse
    prog=mytool
    description="My awesome tool"
    --
    -v,--verbose action=store_true help="Enable verbose output"
    -o,--output required=1 help="Output file"
    file nargs=+ help="Input files"
    ----
    -- "$@"
)"

echo "Verbose: $verbose"
echo "Output: $output"
echo "Files: ${file[@]}"
```

Way better than writing case statements for getopts.

### 3. **Stack Traces**

When sourced with `set -e`, you get automatic stack traces on errors:

```
Error: command failed with exit status 1
  at my_function (script.sh:42)
  at process_data (script.sh:28)
  at main (script.sh:15)
```

### 4. **Process Management**

Spawn processes with separate stdin/stdout like Python's Popen:

```bash
L_proc_popen mypid python3 long_running_script.py
echo "input data" >&"${mypid[stdin]}"
read -r output <&"${mypid[stdout]}"
L_proc_kill "$mypid"
```

### Other Features

- Logging library with levels (L_info, L_warn, L_error, L_debug)
- Temporary directory with auto-cleanup (L_with_cd_tmpdir)
- String utilities (L_strip, L_urlencode, L_json_escape)
- Array sorting with custom comparators
- Path manipulation utilities
- Caching with TTL
- And much more...

## Installation

It's literally one file:

```bash
curl -o ~/.local/bin/L_lib.sh https://raw.githubusercontent.com/Kamilcuk/L_lib/refs/heads/v1/bin/L_lib.sh
```

Then in your scripts:

```bash
. L_lib.sh -s
```

Or test it right away:

```bash
bash <(curl -sS https://raw.githubusercontent.com/Kamilcuk/L_lib/refs/heads/v1/bin/L_lib.sh) \
    L_setx L_info 'Hello from L_lib!'
```

## Why I Made This

I found myself copying the same utility functions between projects and wishing Bash had better error handling and cleanup mechanisms. After using Python, Go, and other languages with `finally`/`defer`, going back to Bash felt painful. So I built what I needed.

The library is LGPL licensed and extensively tested across Bash versions 3.2 to latest.

## Links

- **Documentation**: https://kamilcuk.github.io/L_lib/
- **GitHub**: https://github.com/Kamilcuk/L_lib
- **Key docs**:
  - [L_finally](https://kamilcuk.github.io/L_lib/section/finally/)
  - [L_argparse](https://kamilcuk.github.io/L_lib/section/argparse/)
  - [All functions](https://kamilcuk.github.io/L_lib/section/all/)

---

Would love to hear your thoughts! Have you needed similar features in your Bash scripts? What other functionality would be useful?
