## L_argparse

The utility for command line argument parsing.

## Getting Started: A User Guide to L_argparse

`L_argparse` is a powerful utility for parsing command-line arguments in Bash scripts. It helps you define expected arguments, generate help messages, and handle input gracefully.

## Features

- **No Code Generation:** Operates as a pure Bash library, eliminating the need for build steps or generated code.
- **Bash 3.2+ Compatibility:** Supports a wide range of Bash versions, ensuring broad compatibility.
- **Inline Variable Assignment:** Directly sets Bash variable values within your script for seamless integration.
- **Automatic Help Generation:** Generates comprehensive and user-friendly help messages based on argument definitions.
- **Flexible Option Handling:** Supports optional arguments for options, enhancing command flexibility.
- **Shell Completion Support:** Provides robust command-line completion for Bash, Zsh, and Fish shells.
- **Single-Dash Long Options:** Allows for long options to be specified with a single dash (e.g., `-longoption`).
- **Customizable Option Prefix:** Enables definition of custom characters to prefix optional arguments.
- **Colorized Help Output:** Enhances readability of help messages with color support.
- **Argument Type Checking:** Automatically validates argument types (e.g., `int`, `file`, `dir`).
- **Collecting Remaining Arguments:** Easily gather all arguments after a certain point using `nargs=remainder` or handle unrecognized arguments with `unknown_args=`.

### Basic Usage Example

Let's start with a simple script that demonstrates how to define program information, optional flags, and a positional argument.

```bash
#!/bin/bash
# Source the L_lib library. The -s flag makes it silent.
. L_lib.sh -s

L_argparse \
  prog="MyProgram" \
  description="This is a sample program demonstrating L_argparse." \
  epilog="Thank you for using MyProgram!" \
  -- filename help="The name of the file to process." \
  -- -c --count help="Count the occurrences of something. Increments with each use." action=count \
  -- -v --verbose help="Enable verbose output." action=store_true \
  -- -o --output help="Specify an output file." dest=output_file \
  ---- "$@"

# Access the parsed variables directly
echo "Filename: $filename"
echo "Count: $count"
echo "Verbose: $verbose"
echo "Output File: $output_file"

# Example of how you might use the variables
if [[ "$verbose" == "true" ]]; then
  echo "Verbose mode is enabled."
fi

for ((i=0; i<count; i++)); do
  echo "Counting... $((i+1))"
done

if [[ -n "$output_file" ]]; then
  echo "Results will be written to $output_file"
fi
```

### Running the Example

Save the above code as `my_script.sh` and make it executable (`chmod +x my_script.sh`).

*   **View help:**
    ```bash
    ./my_script.sh --help
    ```
    This will display the `prog`, `description`, `epilog`, and help messages for each defined argument.

*   **Run with arguments:**
    ```bash
    ./my_script.sh my_data.txt -v -c --count --output my_results.log
    ```
    Output:
    ```
    Filename: my_data.txt
    Count: 2
    Verbose: true
    Output File: my_results.log
    Verbose mode is enabled.
    Counting... 1
    Counting... 2
    Results will be written to my_results.log
    ```

### How to Define Arguments

`L_argparse` uses a simple `key=value` syntax for defining parser settings and individual arguments.

1.  **Start with `L_argparse`:** This is the main function call.
2.  **Global Parser Settings:** Define program-wide options like `prog=`, `description=`, and `epilog=`. These come before any argument definitions.
3.  **Argument/Option Chains:** Each argument or option is defined in its own "chain," separated by `--`.
    *   **Positional Arguments:** These are simple names without leading dashes, e.g., `-- filename help="Description"`.
    *   **Optional Arguments (Flags):** These start with one or two dashes, e.g., `-- -f --flag help="Description"`. You can define both short (`-f`) and long (`--flag`) versions.
4.  **End with `---- "$@"`:** This explicitly tells `L_argparse` to start parsing the command-line arguments provided to your script. `"$@"` expands to all positional parameters passed to the script.

### Common Argument Types and Actions

Here's a breakdown of common ways to define arguments:

#### 1. Positional Arguments

These are required arguments that users provide without a flag.

```bash
L_argparse \
  -- input_file help="The file to read." \
  ---- "$@"
# Access as $input_file
```

#### 2. Optional Arguments (Flags)

These are options that can be provided with a leading dash.

**Simple Option with Value:**
```bash
L_argparse \
  -- -o --output help="Specify an output path." \
  ---- "$@"
# Access as $output. If --output is used, $output will hold its value.
```

**Boolean Flags (`action=store_true`/`action=store_false`):**
Useful for simple on/off switches.

```bash
L_argparse \
  -- -d --debug help="Enable debug mode." action=store_true \
  -- -q --quiet help="Suppress output." action=store_false \
  ---- "$@"
# If -d is used, $debug will be "true". Default is "false".
# If -q is used, $quiet will be "false". Default is "true".
```

**Numerical Boolean Flags (`action=store_1`/`action=store_0`):**
For flags that should result in `1` (for true) or `0` (for false), which is useful for shell arithmetic.

*   `action=store_1`: If the flag is present, the variable is set to `1`. The default is `0`.
*   `action=store_0`: If the flag is present, the variable is set to `0`. The default is `1`.

```bash
L_argparse \
  -- -f --force help="Force the operation." action=store_1 \
  ---- "$@"

# $force will be 0 by default.
# If -f or --force is used, $force will be 1.

if (( force )); then
  echo "Forcing the operation."
fi
```

**Counter Flags (`action=count`):**
Increments a variable each time the flag is used.

```bash
L_argparse \
  -- -v --verbose help="Increase verbosity level." action=count \
  ---- "$@"
# If -v is used once, $verbose=1. If twice, $verbose=2, etc. Default is 0.
```

**Options with Constant Values (`action=store_const`):**
Assigns a predefined value when the option is present.

```bash
L_argparse \
  -- --mode-a help="Set mode to A." action=store_const const="mode_A_value" dest=program_mode \
  -- --mode-b help="Set mode to B." action=store_const const="mode_B_value" dest=program_mode \
  ---- "$@"
# If --mode-a is used, $program_mode will be "mode_A_value".
```

**Appending Values to an Array (`action=append`):**
Collects multiple values into an array.

```bash
L_argparse \
  -- -i --item help="Add an item to the list." action=append dest=item_list \
  ---- "$@"
# Usage: my_script.sh -i apple -i banana
# $item_list will be an array: ("apple" "banana")
```

#### 3. Type Checking and Validation (`type=`, `choices=`, `validate=`)

`L_argparse` can automatically validate input types or against a set of choices.

**Basic Types (`type=`):**
```bash
L_argparse \
  -- -n --number help="A numeric input." type=int \
  -- -f --file help="Path to an existing file." type=file \
  ---- "$@"
# Will automatically validate if $number is an integer and $file exists.
```

**Predefined Choices (`choices=`):**
Restricts input to a specific set of values.

```bash
L_argparse \
  -- --color help="Choose a color." choices="red green blue" \
  ---- "$@"
# Usage: my_script.sh --color red (valid)
#        my_script.sh --color yellow (invalid, will show error)
```

**Custom Validation (`validate=`):**
For more complex validation rules, you can provide a Bash expression or a function call.

```bash
# Define a custom validation function
my_custom_validator() {
  if [[ "$1" == "secret" ]]; then
    echo "Error: 'secret' is not allowed." >&2
    return 1 # Indicate failure
  fi
  return 0 # Indicate success
}

L_argparse \
  -- --name help="Enter a name." validate="my_custom_validator "$1"" \
  ---- "$@"
# If --name secret is used, my_custom_validator will be called and fail.
```

#### 4. Handling Remaining and Unknown Arguments

**Collecting All Remaining Arguments (`nargs=remainder`):**
This is useful when your script acts as a wrapper for another command and needs to pass all subsequent arguments through.

```bash
L_argparse \
  -- -v --verbose action=store_true \
  -- cmd_args nargs=remainder \
  ---- "$@"
# Usage: ./script.sh -v -- some_other_command -a -b
# $verbose will be "true"
# $cmd_args will be an array: ("some_other_command" "-a" "-b")
```

**Handling Unrecognized Arguments (`unknown_args=`):**
By default, `L_argparse` fails if it encounters an argument it doesn't recognize. You can use `unknown_args=` to collect these instead of failing.

```bash
L_argparse \
  unknown_args=my_extra_stuff \
  -- -v --verbose action=store_true \
  ---- "$@"
# Usage: ./script.sh -v --custom-option value positional
# $verbose will be "true"
# $my_extra_stuff will be an array: ("--custom-option" "value" "positional")
```

#### 5. Sub-commands (Sub-parsers)

Use `call=subparser` to define sub-commands with their own arguments. This is ideal for complex CLI tools with multiple modes of operation (like `git` or `docker`).

```bash
L_argparse \
  -- call=subparser dest=cmd \
  { \
    name=run help="Run an image" \
    -- image help="The image name" \
  } \
  { \
    name=exec help="Execute into container" \
    -- container help="The container ID" \
    -- command help="The command to run" nargs=remainder \
  } \
  ---- "$@"

case "$cmd" in
  run) echo "Running $image" ;;
  exec) echo "Exec into $container: ${command[*]}" ;;
esac
```

#### 6. Dynamic Sub-commands from Functions

Use `call=function` to automatically generate sub-commands from Bash functions that share a specific prefix. This is a clean way to organize large scripts.

```bash
# Define functions with a common prefix
CMD_run() {
  L_argparse -- image ---- "$@"
  echo "Running $image"
}

CMD_ps() {
  echo "Listing containers..."
}

# Automatically discover all functions starting with "CMD_"
L_argparse \
  -- call=function prefix=CMD_ dest=cmd \
  ---- "$@"

# The chosen command is stored in $cmd
```


## Specification

The `L_argparse` function call is structured as follows:

```
L_argparse <parser_definition> ---- <command_line_arguments>
```

The function takes two sets of arguments separated by `----`:
-   The `<parser_definition>` configures how arguments should be parsed.
-   The `<command_line_arguments>` are the actual arguments to be parsed (typically `"$@"`).

### Parser Definition Syntax

The parser definition consists of a series of groups, separated by `--`.

```
L_argparse [parser_settings] \
    [-- argument_definition]... \
    [-- call=subparser [subparser_settings]]... \
    [-- call=function [function_settings]]... \
    ---- <command_line_arguments>
```

-   The first group, `[parser_settings]`, contains global settings for the parser.
-   Each subsequent `-- argument_definition` group defines a positional argument or an optional flag.
-   A group starting with `-- call=subparser` defines a sub-command.
-   A group starting with `-- call=function` defines a way to dynamically generate sub-commands from shell functions.

Each setting or definition within a group is a `key=value` pair. Values are treated as strings by default, but some keys interpret the value as an array (a space-separated list of quoted values) or a boolean (`1` or `0`).

### `parser_settings` parameters

The main parser and any sub-parsers can be configured with the following options:

- `prog=` - The name of the program (Default: the script's basename, e.g., `${0##*/}`).
- `usage=` - A custom string describing the program usage (Default: auto-generated from arguments).
  - The string `%(prog)s` is replaced by the program name.
- `description=` - Text to display before the argument help.
- `epilog=` - Text to display after the argument help.
- `add_help=` (boolean) - Add `-h, --help` options to the parser. (Default: 1)
- `allow_abbrev=` (boolean) - Allows long options to be abbreviated if the abbreviation is unambiguous. Inherited by subparsers. (Default: 0)
- `allow_subparser_abbrev=` (boolean) - Allows sub-parser command names to be abbreviated if the abbreviation is unambiguous. Inherited by subparsers. (Default: 0)
- `dest_map=` (string) - Store all parsed arguments in an associative array named by this variable (requires Bash 4+).
    If a key receives multiple values (e.g., from `action=append`), they are stored as a space-separated, quoted string that can be loaded back into an array, e.g., `declare -a var="(${dest_map[key]})"`.
- `dest_prefix=` (string) - A prefix to add to all destination variable names.
- `show_default=` (boolean) - If true, default values are added to help messages. Inherited by subparsers. (Default: 0).
- `prefix_chars=` (string) - The set of characters that prefix optional arguments. (Default: '-')
    - Note: If `-` is included, it must be the first or last character to be treated literally. Example: `prefix_chars=+-`.
- `color=` (boolean) - Allow colors in help output. (Default: 1)
- `fromfile_prefix_chars=` - A set of characters that prefix file paths from which arguments should be read (one argument per line).
    - Example: `L_argparse fromfile_prefix_chars=@ ---- @file.txt` reads arguments from `file.txt`.
- `unknown_args=` - If set to an array variable name, unrecognized arguments are stored in this array instead of causing a parsing error.
- `remainder=` (boolean) - If true, all arguments after the first positional argument are treated as non-options. (Default: 0)
- `name=` - The name of a sub-parser command, displayed in help messages. Required for sub-parsers.

### `add_argument` options

Each `add_argument` group defines how a single command-line argument should be parsed.

- name or flags - A name for a positional argument (e.g., `filename`) or a list of flags for an optional argument (e.g., `-f, --foo`).
   - See also: https://docs.python.org/3/library/argparse.html#name-or-flags
- `action=` - The basic action to take when the argument is encountered.
    - `action=store` (or unset) - Stores the provided value. This is the default action and implies `nargs=1`.
    - `action=store_const` - Stores the value specified by the `const=` property.
    - `action=store_0` - A shorthand for `action=store_const`, `const=0`, `default=1`.
    - `action=store_1` - A shorthand for `action=store_const`, `const=1`, `default=0`.
    - `action=store_1null` - A shorthand for `action=store_const`, `const=1`, `default=`.
        - Useful for the `if [[ -n "${var+set}" ]]` pattern to check if an option was present.
    - `action=store_true` - A shorthand for `action=store_const`, `const=true`, `default=false`.
    - `action=store_false` - A shorthand for `action=store_const`, `const=false`, `default=true`.
    - `action=append` - Appends the value to an array.
    - `action=append_const` - Appends the value of `const=` to an array.
    - `action=count` - Increments a variable each time the option is present.
    - `action=eval` - Evaluates the string given in the `eval=` property.
    - `action=help` - Prints the help message and exits successfully.
- `nargs=` - The number of command-line arguments that should be consumed.
    - `nargs=1` - One argument from the command line will be consumed.
    - `nargs=[integer]` - The specified number of arguments will be consumed and gathered into an array.
    - `nargs=?` - One argument will be consumed if possible.
    - `nargs=*` - All available arguments are gathered into an array.
    - `nargs=+` - Like `*`, but generates an error if at least one argument is not present.
    - `nargs=remainder` - All remaining arguments are gathered into an array, and the parser's `remainder` setting is implicitly set to `true`.
- `const=` - A constant value required for `action=store_const` and `action=append_const`.
- `eval=` - A Bash script to evaluate when an option is used. Implies `nargs=0` and `action=eval`.
    - **Note:** The script is evaluated each time the option appears. For example, `-vvv` would execute the script three times.
- `flag=` - A shorthand for `action=store_*`.
    - `flag=0` is equivalent to `action=store_0`.
    - `flag=1` is equivalent to `action=store_1`.
    - `flag=true` is equivalent to `action=store_true`.
    - `flag=false` is equivalent to `action=store_false`.
- `default=` - The value to be stored if the argument is not present.
    - For cases where the result is an array (e.g., `action=append`, `nargs=2`, `nargs=*`, `nargs=+`), this value is parsed as if by `declare -a dest="($default)"`. Example: `default='first_element "second element"'`.
- `type=` - The type to which the command-line argument should be converted or validated against.
    - `type=int` - Validates if the value is an integer.
    - `type=float` - Validates if the value is a float.
    - `type=nonnegative` - Validates if the value is an integer >= 0.
    - `type=positive` - Validates if the value is an integer > 0.
    - `type=file` - Validates if the path is an existing file. Sets `complete=filenames`.
    - `type=file_r` - Validates if the path is a readable file. Sets `complete=filenames`.
    - `type=file_w` - Validates if the path is a writable file. Sets `complete=filenames`.
    - `type=dir` - Validates if the path is an existing directory. Sets `complete=dirnames`.
    - `type=dir_r` - Validates if the path is a readable directory. Sets `complete=dirnames`.
    - `type=dir_w` - Validates if the path is a writable directory. Sets `complete=dirnames`.
- `choices=` - A space-separated list of allowable values for the argument. Example: `choices="a b c 'with space'"`
- `required=` (boolean) - If true, the option must be provided. (Applies to optional arguments only).
- `help=` - A brief description of the argument for the help message. If `help=SUPPRESS`, the argument is hidden.
- `metavar=` - A name for the argument in usage messages.
- `dest=` - The name of the variable that will store the argument's value.
    - **For options:** Derived from the first long option (e.g., `--long-option` becomes `long_option`). If no long option, derived from the first short option (e.g., `-o` becomes `o`).
    - **For positional arguments:** Derived directly from the argument name (e.g., `filename` becomes `filename`).
- `show_default=1` - Appends the text `(default: <default>)` to the help text of the option.
- `complete=` - An expression for generating command-line completions. This is a comma-separated list containing:
    - Any `compopt -o` option (e.g., `nospace`, `filenames`).
	- Any `compgen -A` option (e.g., `function`, `variable`).
	- A custom `eval` string that generates completion words.
- `validate=` - A Bash expression or function call to validate the argument's value. The value is passed as `$1`.
     - **Note:** If the validation expression returns a non-zero exit code, `L_argparse` will print an error message and *halt the script's execution*.
     - Example: `validate='[[ "$1" =~ (a|b) ]]'`
     - Example:
            validate_my_arg() {
                 if ! [[ "$1" =~ ^[0-9]+$ ]]; then
                    echo "Error: Value must be an integer." >&2
                    return 1
                 fi
                 if [[ "$1" == "secret" ]]; then
                    echo "Error: 'secret' is not allowed." >&2
                    return 1 # This will now halt the script
                 fi
            }
            # ...
            L_argparse ... validate='validate_my_arg "$1"'

### `add_subparser` options:

To define sub-commands (like `git pull`), use the `call=subparser` group, followed by one or more parser definitions enclosed in curly braces `{ ... }`.

```
L_argparse \
  [main_parser_settings] \
  -- call=subparser dest=command \
  { \
     name=clone \
     description="Clone a repository" \
     -- repo help="Repository URL" \
  } \
  { \
     name=push \
     description="Push changes" \
     -- --force action=store_true \
  } \
  ---- "$@"
```
-   The `call=subparser` group can take `dest`, `required`, and `metavar` options, which behave like their `add_argument` counterparts. `dest` is required to store the name of the chosen sub-command.
-   Each sub-parser definition (`{...}`) is a self-contained parser with its own settings and arguments.
-   The `name=` setting is required for each sub-parser.

### `add_function` options:

This provides a way to dynamically create sub-commands from existing shell functions.

- `prefix=` - Required. All functions with this prefix are treated as potential sub-commands. The prefix is removed to form the command name.
- `required=`, `metavar=`, `dest=` - Same as in `add_argument`.
- `subcall=` - Controls how `L_argparse` inspects the discovered functions to generate help and completions.
    - `0` (Default) - Functions are not called during help/completion generation. Help text for these commands will be empty unless a help variable is defined.
    - `1` - The function is called with special internal arguments to request its `L_argparse` definition.
    - `detect` - `L_argparse` inspects the function's source code for a call to `L_argparse`. If found, it behaves like `subcall=1`.

To provide a help message for a function-based command without relying on `subcall=1` or `subcall=detect`, define a variable named `<prefix>_<funcname>_help`.

Example:
```
--8<-- "scripts/argparse_function_example.sh"
```

### Reserved Command Line Arguments

Arguments starting with `--L_argparse_` are reserved for internal use. These are crucial for functionalities like shell completion and internal debugging.

-   `--L_argparse_get_completion`: Used internally to output completion stream for given arguments.
-   `--L_argparse_complete_bash`: Prints the Bash completion script to standard output and exits. This script can be sourced to enable completion.
-   `--L_argparse_complete_zsh`: Prints the Zsh completion script to standard output and exits. This script can be sourced to enable completion.
-   `--L_argparse_complete_fish`: Prints the Fish completion script to standard output and exits. This script can be sourced to enable completion.
-   `--L_argparse_print_completion`: Prints a helpful message explaining how to enable Bash completion.
-   `--L_argparse_print_usage`: Prints the usage message and exits.
-   `--L_argparse_print_help`: Prints the full help message and exits.
-   `--L_argparse_dump_parser`: Serializes the parser's internal state to standard output (surrounded by UUIDs) and exits.

### Shell Completion

`L_argparse` provides robust shell completion for Bash, Zsh, and Fish. Setting this up enhances the user experience by offering suggestions for commands, options, and arguments as they type.

#### How it Works

When `L_argparse` is sourced, it registers special functions with your shell's completion system. When you type a command using `L_argparse` and press `[TAB]`, the shell calls one of the internal `--L_argparse_complete_*` commands to generate possible completions dynamically.

#### Setup Instructions

To enable shell completion for your scripts that use `L_argparse`, you need to source the appropriate completion script for your shell. This example assumes your script is named `foo-bar`.

##### Bash

For Bash, add the following to your `~/.bashrc`:

```bash
  eval "$(foo-bar --L_argparse_complete_bash)"
```



##### Zsh

For Zsh, add the following to your `~/.zshrc`:

```zsh
# Ensure compinit is run
autoload -Uz compinit && compinit

# Enable completion for your script
eval "$(foo-bar --L_argparse_complete_zsh)"
```

##### Fish

Add this to `~/.config/fish/completions/foo-bar.fish`:

```fish
foo-bar --L_argparse_complete_fish | source
```

## Implementation documentation

The parser and its arguments are stored internally as a flattened tree structure using Bash arrays. Each parser and argument is assigned a unique ID, and their properties and relationships (e.g., parent-child) are stored in arrays indexed by this ID. This avoids the performance overhead of using associative arrays or `declare -p` for serialization, which were bottlenecks in previous versions.

### `_L_parser_*`

`_L_parser_*` arrays store settings for each parser node in the tree, enabling traversal and lookup of sub-parsers and arguments.

### `_L_opt_*`

`_L_opt_*` array variables store the properties for each argument or option.

### Completion

#### Completion cases

`''` denotes the cursor position.

| Case        | Completion Result                                                 |
| :---------- | :---------------------------------------------------------------- |
| `''`          | Arguments, long options, or short options.                      |
| `-''`         | Long options or short options.                                  |
| `-f''`        | Another short option (e.g., `-fx`), or a space if `-f` is final.|
| `-o''`        | Value for `-o`, prefixed with `-o` (e.g., `-ovalue`).            |
| `-o ''`       | Value for `-o`.                                                 |
| `--''`        | Long options.                                                   |
| `--flag''`    | A space if the flag takes no arguments.                         |
| `--option''`  | `=` if the option takes an argument.                            |
| `--option='' `| The value for the option.                                       |
| `--option ''` | The value for the option.                                       |

### History

The initial version of this library serialized arguments and invoked a Python script that used the standard `argparse` library. This approach was safe but introduced significant performance overhead (over 200ms) due to process creation and data serialization, making it unsuitable for shell scripts. It also prevented shell completion integration.

A subsequent rewrite used Bash associative arrays to store the parser structure, serializing and deserializing them with `declare -p`. While avoiding the Python dependency, the frequent use of subshells and `declare` statements still resulted in high latency (over 100ms) and was incompatible with older Bash versions.

The current implementation flattens the parser data structure into standard Bash arrays. This model is highly efficient, with typical parsing times around 20ms, and maintains compatibility with Bash 3.2+.

## Reason it exists

This library was created as an alternative to tools like `argbash` that rely on code generation. The goal was a self-contained library that could be sourced and used directly as a single function call, without any build steps.

::: bin/L_lib.sh argparse
