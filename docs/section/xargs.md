# Xargs

`L_xargs` is a high-performance, pure-Bash implementation of the `xargs` utility, designed for seamless integration with local shell environments.

## User Guide

Unlike the standard GNU `xargs` which is a compiled binary, `L_xargs` runs within the current shell context. This allows it to directly execute Bash functions, use aliases, and access shell variables without needing to export them. It is a powerful tool for building complex data-processing pipelines directly in Bash.

### The Processing Pipeline: Records and Atoms

`L_xargs` operates on two levels of input units:

1.  **Records:** These are the primary chunks of input, separated by a delimiter. By default, the delimiter is a newline character (`\n`), so each line of input is one record. You can change this with the `-d` (delimiter) or `-0` (null character) options.
2.  **Atoms:** These are the final arguments that are passed to the command being executed. By default, each Record is treated as a single, solid Atom. However, if you use the `-s` (split mode) option, `L_xargs` will parse the Record using shell-like quoting rules, potentially splitting one Record into multiple Atoms.

The command is executed when either the number of accumulated Atoms reaches the limit set by `-n`, or the number of Records reaches the limit set by `-L`.

### Key Features and Differences from GNU xargs

-   **Shell Integration:** The most significant advantage. `L_xargs` can call shell functions and aliases directly, which is impossible with standard `xargs` without using `export -f`.
-   **Advanced Input Sources:** `L_xargs` can read items from a Bash array (`-a <array_name>`) or a custom callback function (`-c <callback_eval_string>`), in addition to `stdin`.
-   **Performance:** While highly optimized for shell environments, `L_xargs` is a pure Bash implementation and will generally be slower than the native C-based GNU `xargs`. For most scripting tasks, its flexibility and integration are more valuable.
-   **Granular Return Codes:** Provides specific return codes (123, 124, 125, etc.) to indicate different failure modes, allowing for more robust error handling.

### Basic Usage

```bash
# Reads newline-separated items from stdin and passes them as arguments to echo
printf "item1\nitem2\nitem3" | L_xargs echo
# Output: item1 item2 item3
```

### Options and Examples

#### Executing a Shell Function

This is a primary use case for `L_xargs`. The function does not need to be exported. Because `L_xargs` operates within the same shell, the function can also access any variables or other functions from your script.

Crucially, if the `-P` (parallel) option is **not** used, the function is executed in the *current shell execution environment*. This means any modifications to variables made by the function will persist after `L_xargs` has finished.

```bash
#!/usr/bin/env bash
. L_lib.sh -s

my_prefix="Item"
counter=0

# This function can access and modify variables from the script
process_item() {
  echo "Processing $my_prefix: $1"
  (( counter++ ))
}

printf "A\nB\nC" | L_xargs -n 1 process_item

echo "Total items processed: $counter"
# Output:
# Processing Item: A
# Processing Item: B
# Processing Item: C
# Total items processed: 3
```

#### Input from an Array (-a)

Use the `-a` option to read input directly from a Bash array.

```bash
my_items=("First item" "Second item" "Third item")
# -S ensures each element is a single argument
L_xargs -S -a my_items -n 1 echo
# Output:
# First item
# Second item
# Third item
```

#### Input from a Callback Function (-c)

The `-c` option allows you to provide a string that will be `eval`ed to generate input Records. The evaluated string must populate the `L_v` variable (as an array) and return 0 for success. A non-zero return code signals the end of input.

```bash
i=0
generate_items() {
    if (( i < 3 )); then
        L_v="item_$((++i))"
        return 0
    fi
    return 1
}

L_xargs -n 1 -c 'generate_items' echo
# Output:
# item_1
# item_2
# item_3
```

#### Delimiter and Record Handling (-d, -0)

By default, `L_xargs` uses a newline to separate records. `-d` changes the delimiter. `-0` is a shorthand for `-d ''`, using the null character, which is useful for working with `find -print0`.

The default behavior is to treat each record as a single "solid" atom. This is equivalent to `-S`. If you need to split records based on whitespace and shell quoting, use `-s`.

```bash
# Default behavior (Solid mode)
printf "A B\nC" | L_xargs -n 1 echo
# Output:
# A B
# C

# Split mode
printf "A B\nC" | L_xargs -s -n 1 echo
# Output:
# A
# B
# C
```

#### Parallel Execution (-P)

Use `-P` to run commands in parallel. `-P nproc` is a convenient shortcut to use all available CPU cores.

```bash
# Run up to 4 sleep commands in parallel
printf "1\n2\n3\n4" | L_xargs -P 4 -n 1 sleep
```

#### Ordered Parallel Output (-O)

When running in parallel with `-P`, output from different commands can be interleaved. The `-O` option ensures that the output from each command is buffered and printed atomically once the command completes. This prevents interleaving but may result in output order not matching the input order.

```bash
# Without -O, output can be mixed. With -O, each command's output is grouped.
printf "A\nB" | L_xargs -P 2 -n 1 -O -- bash -c 'echo "start $1"; sleep 0.1; echo "end $1"' --
```

#### Controlling Command Execution (-n, -L)

`-n` (max-atoms) and `-L` (max-records) control how many items are processed before the command is executed. The command is triggered as soon as *either* limit is reached.

*   **`-n 2`**: Executes the command for every 2 atoms collected.
*   **`-L 2`**: Executes the command for every 2 records read.
*   **`-n 2 -L 3`**: If 2 atoms are collected *before* 3 records are read, the command runs. If 3 records are read *before* 2 atoms are collected, the command runs.

Example:
```bash
# -s splits "A B" into two atoms. The -n 2 limit is hit after the first line.
# The command runs, and the limits are reset. Then "C" is processed.
printf "A B\nC" | L_xargs -s -n 2 -L 3 echo
# Output:
# A B
# C
```

#### Prefixing Output (-^)

The `-^` option prepends the arguments used for the command, followed by a colon, to each line of the command's output.

```bash
printf "A\nB" | L_xargs -n 1 -^ -- bash -c 'echo "Line 1"; echo "Line 2"' --
# Output:
# A: Line 1
# A: Line 2
# B: Line 1
# B: Line 2
```

:: scripts/xargs.sh L_xargs
