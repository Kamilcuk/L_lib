## L_argparse

The utility for command line argument parsing.

## Example

```
set -- -c 5 -v ./file1
L_argparse \
  prog=ProgramName \
  description="What the program does" \
  epilog="Text at the bottom of help" \
  -- filename help="this is a filename" \
  -- -c --count \
  -- -v --verbose action=store_1 \
  ---- "$@"
echo "$count $verbose $filename"  # outputs: 5 1 ./file1
```

## Features

- no code generation or similar
- supports Bash 3.2+
- Sets Bash variable values inline in the script
- help generation
- optional arguments to options
- support Bash, Zsh and Fish shell completion
- `-one_dash_long_options`
- custom option prefix
- colors

## Specification

```
L_argparse <parser_specification> ---- <command_line_arguments>
```

The `L_argparse` utility takes two set of arguments separated by `----` argument.

- The `<parser_specifation>` defines how the parser parses the arguments.
- The `<command_line_arguments>` are the actual command line arguments to parse.

### Parser specification

```
L_argparse [parser_settings chain] \
    [-- <add_argument chain>]... \
    [-- call=subparser <add_subparser chain>]... \
    [-- call=function <add_function chain>]... \
    ---- <command_line_arguments>
```

The parser specification consists of a list of "chains" of key=value arguments separated by `--`.

The first argument of the chain determines the type of the chain. `call=subparser` follows sub-parser chain arguments, while `call=function` follows function chain arguments. Any other means an `add_argument` chain type.

Chain `key=value` arguments have types of values:

- String - the default type,
- Array - list of quotes values separated by whitespaces. The list will be parsed with `declare -a arr="($value)"`,
- Boolean - the truth of value is determined with `L_is_true`.

### `parser_settings` parameters

The parser takes the following chain options:

- `prog=` - The name of the program (defaults: `${L_NAME:-${0##*/}}`).
- `usage=` - The string describing the program usage (default: generated from arguments added to parser).
  - The string `%(prog)s` is replaced by the program name in usage messages. `printf` formatting options are not supported.
- `description=` - Text to display before the argument help (by default, no text).
- `epilog=` - Text to display after the argument help (by default, no text).
- `add_help=` (bool) - Add `-h --help` options to the parser (default: 1).
- `allow_abbrev=` (bool) - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: 0)
- `allow_subparser_abbrev=` - Allows sub-parser command names to be abbreviated if the abbreviation is unambiguous. (default: 0)
- `Adest=` - Store all values as keys into a variable that is an associated dictionary.
  If the result is an array, it is properly quoted and appended. Array can be extracted with `declare -a var="(${Adest[key]})"`.
- `show_default=` (bool) - Default value of `show_default` property of all options. Example `show_default=1`. (default: 0).
- `prefix_chars=` - The set of characters that prefix optional arguments (default: '-')
- `color=` (bool) - Allow colors (default: 1)
- `fromfile_prefix_chars=` - The set of characters that prefix files from which additional arguments should be read (by default, no prefix is special)
    - The arguments are read from the file split by lines.
    - Example: `L_argparse fromfile_prefix_chars=@ ---- @file.txt` read options from `file.txt`.
- `unknown_args=` - Unrecognized arguments do not fail the parsing and are instead assigned to the specified array variable. (by default, unrecognized arguments fail the parsing)
- `remainder=` (boolean) - Options are not considered after the first non-option arguments. (default: 0)
- `name=` - If the parser is a sub-parser, this is the command name displayed in help messages.
  This has to be set for sub-parsers.
- `aliases=` (array) - Not implemented. Ping me if needed. Additional aliases for `name=` for sub-parsers.

### `add_argument` options

The `add_argument` chains of arguments attaches individual argument specifications to the parser.
It defines how a single command-line argument should be parsed.

- name or flags - Either a name or a list of option strings, e.g. `foo` or `-f`, `--foo`.
   - See https://docs.python.org/3/library/argparse.html#name-or-flags
- `action=` - The basic type of action to be taken when this argument is encountered at the command line.
    - `action=store` or unset - store the value given on command line. Implies `nargs=1`
    - `action=store_const` - when option is used, assign the value of `const` to variable `dest`
    - `action=store_0` - set `action=store_const` `const=0` `default=1`
    - `action=store_1` - set `action=store_const` `const=1` `default=0`
    - `action=store_1null` - set `action=store_const` `const=1` `default=`
        - Useful for `action=${var:+var is set}` pattern.
    - `action=store_true` - set `action=store_const` `const=true` `default=false`
    - `action=store_false` - set `action=store_const` `const=false` `default=true`
    - `action=append` - append the option value to array variable `dest`
    - `action=append_const` - when option is used, append the value of `const` to array variable `dest`
    - `action=count` - every time option is used, `dest` is incremented, starting from if unset
    - `action=eval` - evaluate the string given in `eval` argument
    - `action=help` - Print help to standard output and exit with 0. Equal to `eval='L_argparse_print_help;exit 0'`.
- `nargs=` - The number of command-line arguments that should be consumed.
    - `nargs=1`. Argument from the command line will be assigned to the variable.
    - `nargs=[0-9]+`. An integer. Arguments from the command line will be gathered together into an array variable.
    - `nargs=?`. One argument will be consumed from the command line if possible and assigned.
    - `nargs=*`. All command-line arguments present are gathered into an array.
    - `nargs=+`. Just like `*`, all command-line arguments present are gathered into an array.
      Additionally, an error message will be generated if there was not at least one command-line argument present.
    - `nargs=remainder` - equal to `nargs=*` and setting `remainder=true` parser setting
- `const=` - The constant value to store into `dest` depending on `action`.
- `eval=` - The Bash script to evaluate when option is used. Implies `action=eval`. Note: the command is evaluated upon parsing options. Multiple repeated options like `-a -a -a` will execute the script multiple times. The script should be stateless. Example: `-- -v --verbose eval='((verbose_level++))'`.
- `flag=` - Shorthand for `action=store_*`.
    - `flag=0` - equal to `action=store_0`
    - `flag=1` - equal to `action=store_1`
    - `flag=true` - equal to `action=store_true`
    - `flag=false` - equal to `action=store_false`
- `default=` - store this default value into `dest`
    - If the result of the option is an array, this value is parsed as if by `declare -a dest="($default)"`. Example: `-- -a --append action=append default='first_element "second element"'`.
    - `default=""` sets the default to an empty string.
- `type=` - The type to which the command-line argument should be converted.
    - `type=int` - set `validate='L_is_integer "$1"'`
    - `type=float` - set `validate='L_is_float "$1"'`
    - `type=nonnegative` - set `validate='L_is_integer "$1" && [[ "$1" > 0 ]]'`
    - `type=positive` - set `validate'L_is_integer "$1" && [[ "$1" >= 0 ]]'`
    - `type=file` - set `validate='[[ -f "$1" ]]' complete=filenames`
    - `type=file_r` - set `validate=[[ -f "$1" && -r "$1" ]]' complete=filenames`
    - `type=file_w` - set `validate'[[ -f "$1" && -w "$1" ]]' complete=filenames`
    - `type=dir` - set `validate='[[ -d "$1" ]]' complete=dirnames`
    - `type=dir_r` - set `validate='[[ -d "$1" && -x "$1" && -r "$1" ]]' complete=dirnames`
    - `type=dir_w` - set `validate='[[ -d "$1" && -x "$1" && -w "$1" ]]' complete=dirnames`
- `choices=` - A sequence of the allowable values for the argument. Deserialized with `declare -a choices="(${_L_opt_choices[_L_opti]})"`. Example: `choices="a b c 'with space'"`
- `required=` - Whether or not the command-line option may be omitted (options arguments only). Example `required=1`.
- `help=` - Brief description of what the argument does. `%(prog)s` is not replaced. If `help=SUPPRESS` then the option is completely hidden from help.
- `metavar=` - A name for the argument in usage messages.
- `dest=` - The name of the variable variable that is assigned as the result of the option. Default: argument name or first long option without dashes or first short option.
- `show_default=1` - append the text `(default: <default>)` to the help text of the option.
- `complete=` - The expression that completes on the command line. List of comma separated items consisting of:
    - Any of the `compopt -o` argument.
		    - `bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs`
		    - `default|dirnames|filenames` are handled in Zsh and Fish.
	  - Any of `compgen -A` argument:
        - `alias|arrayvar|binding|builtin|command|directory|disabled|enabled|export|file|function|group|helptopic|hostname|job|keyword|running|service|setopt|shopt|signal|stopped|user|variable`
	  - Any other string containing a space:
	      - The string will be `eval`ed and should generate standard output consisting of:
	          - Lines with tab separated elements:
	              - The keyword `plain`
	              - The generated completion word.
	              - Optionally, the description of the completion.
	          - Or lines with tab separated elements:
	              - First field is any of the `compopt -o` or `compgen -A` argument
	              - Empty second field.
	              - Description of the completion. Relevant for Zsh only.
	     - Example: `complete='compgen -P "plain${L_TAB}" -W "a b c" -- "$1"'`
	     - The function `L_argparse_compgen` automatically adds `-P` `-S` arguments to `compgen` based on the `help=` of an option.
	          - Example: `complete='L_argparse_compgen -W "a b c" -- "$1"'`
	     - Example: `complete='nospace,compgen -P "plain${L_TAB}" -S "${L_TAB}Completion description" -W "a b c" -- "$1"'`
	     - The function `L_argparse_optspec_get_description` can be used to get the completion description of an option.
	     - Note: the `complete=` argument expression may not contain a comma, as comma is used to separate elements.
	       If you need comma, delegate completion to a function.
- `validate=` - The expression that evaluates if the value is valid.
     - The variable `$1` is exposed with the value of the argument
     - Example: `validate='[[ "$1" =~ (a|b) ]]'`
     - Example: `validate='L_regex_match "$1" "(a|b)"'`
     - Example: `validate='grep -q "(a|b)" <<<"$1"'`
     - Example:

            validate_my_arg() {
                 echo "Checking is $1 of type ${_L_opt_type[_L_opti]} is correct... it is not!"
                 return 1
            }
            L_argparse ... validate='validate_my_arg "$1"'

### `add_subparser` options:

```
L_argparse \
  -- call=subparser [call_subparser_settings] \
  { \
     [parser_settings chain] \
     [-- <chains>]... \
  } \
  { \
     [parser_settings chain] \
     [-- <chains>]... \
  } \
  ---- "$@"
```

The `call=subparser` starts call sub-parser settings chain that follows one or more sub-parsers specifications.

Each sub-parser specification consists of parser settings and argument chains just like root parser.

The sub-parsers can be nested freely. The sub-parser might include `call=subparser {` and another level of sub-parser specification, and so on.

The `name=` value of `parser_settings` is required and determines the name of the sub-parser to call.

Example:

```
--8<-- "scripts/argparse_subparser_example.sh"
```

#### `call_subparser_settings` options

The sub-parser settings takes options from `add_argument` with the same meaning: `action=`, `metavar=` and `dest=`.

When `dest=` is set, the sub-parser `parser_settings` name is extracted assigned to the value.

### `add_function` options:

Function call takes following `key=value` options:

- `prefix=` - Required. Consider all functions to call with specified prefix, with prefix removed.
- `required=` `metavar=` `dest=` - like in `add_argument`.
- `subcall=` - Specify if parent parser is allowed to call the function when generating descriptions for parent parser help messages and to generate shell completions.
    - `0` - Sub-functions will not be called. The help messages will be empty and shell completions for sub-parsers will not work. This is the default.
    - `1` - Sub-functions will be called.
    - `detect` - It is checked with a regex is the sub-function definition contains a call to `L_argparse`. If it does, then the sub-function will be called.

When generating help message `--help` for the parent parser or when generating shell completion, the parent parser needs to decide if it is ok to call the function or not. The function is called with a built-in `--L_argparse_*` option to generate the proper messages for parent parser.

There might be defined a variable named `<prefix>_<funcname>_help` that will be used as the description message of the option for the parent parser. It takes precedence over `subcall=1`.

Example:

```
--8<-- "scripts/argparse_function_example.sh"
```

#### `add_function` option `subcall=`

Consider the following script:

```
--8<-- "scripts/argparse_detect_example.sh"
```

Calling the script results in:

```
$ ./scripts/argparse_detect_example.sh -h
Usage: ./scripts/argparse_detect_example.sh [-h] COMMAND [ARGS ...]

Available commands:
  clone  clone repository
  fetch  fetch help
  pull

Options:
  -h, --help  show this help message and exit
```

The `clone` command description was generated by a child `L_argparse`, which was detected by `subcall=detect` mode.

The `fetch` description was taken from `CMD_fetch_help` variable.

The `pull` command has no description, as neither the `CMD_pull_help` variable exists neither the function calls `L_argparse`.

### Reserved command line arguments

The prefix `--L_argparse_` of the first command line argument for parser is reserved for internal use.

Currently, there are the following internal options:

- `--L_argparse_get_completion` - output completion stream for given arguments
- `--L_argparse_complete_bash` - print Bash completion script and exit
- `--L_argparse_complete_zsh` - print Zsh completion script and exit
- `--L_argparse_complete_fish` - print Fish completion script and exit
- `--L_argparse_print_completion` - print a helpful message how to use bash completion
- `--L_argparse_print_usage` - print usage and exit
- `--L_argparse_print_help` - print help and exit
- `--L_argparse_dump_parser` - serialize the parser to standard output surrounded by UUIDs and exit

## Implementation documentation

Parser with sub-parsers implementation is a tree where each node is a parser and each leaf is an argument.

```
parser0 +-> argument1
        |-> argument2
        |-> subparser1 +> argument3
        |              \> argument4
        |
        \-> subparser2 +> argument5
                       \> subparser3 -> argument6
```

However, Bash does not support nested data structures.

By assigning a number to each parser and argument the structure can be "flattened" out completely.
Each object property is stored as an index in an array.
The information about children or parents are stored as a reference of an index that owns an option.
For example `_L_opt__parseri[4]=1` means that `argument4` is owned by `subparser1`.

Properties that do not map to arguments from the user are prefixed with additional `_`.

### `_L_parser_*`

`_L_parser_*` array variables allow to:
- access the parser settings
- find an argument associated with long `--option`
- find an argument associated with short option `-o`
- find a sub-parser by its name
- iterate over all options
- iterate over all arguments
- iterate over all sub-parsers
- first parser has index 1!

### `_L_opt_*`

`_L_opt_*` array variables store options and arguments speis an associative array used to store options and arguments specifications.
Additional keys set internally in `_L_optspec` when parsing arguments:

- `_options` - Space separated list of short and long options. Used to detect if this is an option or an argument.
- `_isarray` - Should the `dest` variable be assigned as an array? Holds 1 or missing.
- `_desc` - Description used in error messages. Metavar for arguments or list of options joined with `/`.

### Completion

#### Completion cases

`''` denotes cursor position.

| what        | complete                                                          |
| ---         | ---                                                               |
| ''          | arguments if any, otherwise long options, otherwise short options |
| -''         | long options, otherwise short options                             |
| -f''        | another short options, or space if this is the only option        |
| -o''        | options of `-o` prefixed with `-o`                                |
| -fo''       | options of `-o` prefixed with `-fo`                               |
| -o ''       | options of `-o`                                                   |
| --''        | long options                                                      |
| --flag''    | space                                                             |
| --option''  | `=`                                                               |
| --option='' | options                                                           |
| --option '' | options                                                           |

### History

The initial implementation of the library took the arguments and serialized them to a python program calling python `argparse`.
This was very slow and quite unsafe. Once the Bash code needed to properly quote everything, then Python is super very slow.
Then the Python output needed to be loaded. This took more than 200ms. Additionally, no completion was possible with this method.

Then the actual implementation of the library stored `parser` and `argument` properties in an associative array.
The arguments and sub-parsers were serialized with `declare -p` and deserialized with `declare -A` to store nested data structures.
This proved to be very slow because of all the `declare` calls, a lot of strings and subshells.
Calling argparse took more than 100ms, and also was incompatible with Bash without associative arrays.

Then lately I have rewritten everything by flattening out the data structure and storing everything in Bash arrays.
This proved effective. It requires some consistency when iterating over elements.
This works great. The call to `L_argparse` take around 20ms.

## Reason it exists

I did not like `argbash` that requires some code generation. There should
be no generation required. It is just a function that executes.

::: bin/L_lib.sh argparse
