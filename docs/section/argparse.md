# `L_argparse`

The utility for command line argument parsing.

# Example

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

# Features

- no code generation or similar
- supports Bash 3.2+
- sets Bash variable values inline in the script
- help generation
- optional arguments to options
- support Bash, Zsh and Fish shell completion

## TODO

- `-y/-n` and `--yes/--no` arguments for `action=store_0/1/true/false`
- `-one_dash_long_options`

# Specification

```
L_argparse <parser_settings> \
  -- <add_argument> \
  -- call=subparser <add_subparser> \
  { \
    <parser_settings> \
    -- <add_argument> \
    -- call=subparser <add_subparser> \
    { \
      <parser_settings> \
      -- <add_argument> \
    } \
  } \
  { \
    <parser_settings> \
    -- <add_argument> \
  } \
  -- call=func <add_func> \
  ---- "$@"
```

The `L_argparse` command takes multiple "chains" of command line arguments.
Each chain is separated by `--` with sub-chains enclosed in `{` `}`.
The last chain is terminated with `----` which separates argument parsing specification from the actual command line arguments.

Each chain is composed positional arguments like `arg`, `-o` or `--option` and keyword arguments like `nargs="*"`.
There are several "types" of chains which receive different positional arguments and keyword arguments.

```
L_argparse <parser_settings> ...
```

The first chain of arguments specifies the global `parser_settings` of the command line parsing.

Next there are many chains of arguments specifying option parsing.
If the first argument of a chain is not `call=func` or `call=subparser` the it is an `add_argument` option.

The `add_argument` chains of arguments attaches individual argument specifications to the parser.
It defines how a single command-line argument should be parsed.

If the first argument of a chain is `call=subparser` then it is followed by `add_subparser` group allows for adding sub-parsers.
Each sub-parser definition starts with `{` and ends with `}`.
Multiple sub-parsers are specified with multiple `{` `}` blocks.
The first chain specifies the `parser_settings` similar to a parser.
Then the next chains can be arguments or nested subparser or a function call.

If the first argument of a chain is `call=func` then it specifies a function call.
This causes the parsing to call a function after parsing options for this chain.
Additionally, the sub-parsers of a call might be aware that they are called from parent subparser, similar to `call=subparser`.
In other words, they will display proper help message with the name of the program concatenated to the parent name.

## Reserved options

The prefix `--L_argparse_` of the first command line argument for parser is reserved for internal use.

Currently there are the following internal options:

- `--L_argparse_get_completion` - output completion stream for given arguments
- `--L_argparse_complete_bash` - print Bash completion script and exit
- `--L_argparse_complete_zsh` - print Zsh completion script and exit
- `--L_argparse_complete_fish` - print Fish completion script and exit
- `--L_argparse_print_completion` - print a helpful message how to use bash completion
- `--L_argparse_print_usage` - print usage and exit
- `--L_argparse_print_help` - print help and exit
- `--L_argparse_dump_parser` - serialize the parser to stdout surrounded by UUIDs and exit

## `parser_settings` parameters:

- `prog=` - The name of the program (defaults: `${L_NAME:-${0##*/}}`).
- `usage=` - The string describing the program usage (default: generated from arguments added to parser).
  - The string `%(prog)s` is replaced by the program name in usage messages, however `printf` formatting options are not supported.
- `description=` - Text to display before the argument help (by default, no text).
- `epilog=` - Text to display after the argument help (by default, no text).
- `add_help=` - Add a -h/--help option to the parser (default: 1).
- `allow_abbrev=` - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: 1)
- `Adest=` - Store all values as keys into a variable that is an associated dictionary.
  If the result is an array, it is properly quoted and appended. Array can be extracted with `declare -a var="(${Adest[key]})"`.
- `show_default=` - default value of `show_default` property of all options. Example `show_default=1`. (default: 0).
- any name or `name=` - If the parser is a subparser, this it the command name displayed in help messages.
  If has to be set for subparsers.

## `add_argument` options:

- name or flags - Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.
  - See https://docs.python.org/3/library/argparse.html#name-or-flags
- `action=` - The basic type of action to be taken when this argument is encountered at the command line.
  - `store` or unset - store the value given on command line. Implies `nargs=1`
  - `store_const` - when option is used, assign the value of `const` to variable `dest`
  - `store_0` - set `action=store_const` `const=0` `default=1`
  - `store_1` - set `action=store_const` `const=1` `default=0`
  - `store_1null` - set `action=store_const` `const=1` `default=`
    - Useful for `${var:+var is set}` pattern.
  - `store_true` - set `action=store_const` `const=true` `default=false`
  - `store_false` - set `action=store_const` `const=false` `default=true`
  - `append` - append the option value to array variable `dest`
  - `append_const` - when option is used, append the value of `const` to array variable `dest`
  - `count` - every time option is used, `dest` is incremented, starting from if unset
  - `eval` - evaluate the string given in `eval` argument
  - `remainder` - After first non-option argument, collect all remaining command line arguments into a list. Default nargs is `*`.
  - `help` - Print help and exit with 0. Equal to `action=eval:'L_argparse_print_help;exit 0'`.
- `nargs=` - The number of command-line arguments that should be consumed.
  - `1`. Argument from the command line will be assigned to variable `dest`.
  - An integer. Arguments from the command line will be gathered together into am array `dest`.
  - `?`. One argument will be consumed from the command line if possible and assigned to `dest`.
  - `*`. All command-line arguments present are gathered into an array `dest`.
  - `+`. Just like `*`, all command-line arguments present are gathered into an array.
    Additionally, an error message will be generated if there was not at least one command-line argument present.
- `const=` - the value to store into `dest` depending on `action`
- `eval=` - the Bash script to evaluate
- `default=` - store this default value into `dest`
  - If the result of the option is an array, this value is parsed as if by  `declare -a dest="($default)"`.
- `type=` - The type to which the command-line argument should be converted.
  - `int` - set `validate='L_is_integer "$1"'`
  - `float` - set `validate='L_is_float "$1"'`
  - `nonnegative` - set `validate='L_is_integer "$1" && [[ "$1" > 0 ]]'`
  - `positive` - set `validate'L_is_integer "$1" && [[ "$1" >= 0 ]]'`
  - `file` - set `validate='[[ -f "$1" ]]' complete=filenames`
  - `file_r` - set `validate=[[ -f "$1" && -r "$1" ]]' complete=filenames`
  - `file_w` - set `validate'[[ -f "$1" && -w "$1" ]]' complete=filenames`
  - `dir` - set `validate='[[ -d "$1" ]]' complete=dirnames`
  - `dir_r` - set `validate='[[ -d "$1" && -x "$1" && -r "$1" ]]' complete=dirnames`
  - `dir_w` - set `validate='[[ -d "$1" && -x "$1" && -w "$1" ]]' complete=dirnames`
- `choices=` - A sequence of the allowable values for the argument. Deserialized with `declare -a choices="(${_L_optspec[choices]})"`. Example: `choices="a b c 'with space'"`
- `required=` - Whether or not the command-line option may be omitted (optionals only). Example `required=1`.
- `help=` - Brief description of what the argument does. `%(prog)s` is not replaced. If `help=SUPPRESS` then the option is completely hidden from help.
- `metavar=` - A name for the argument in usage messages.
- `dest=` - The name of the variable variable that is assigned as the result of the option. Default: argument name or first long option without dashes or first short option.
- `show_default=` - append the text `(default: <default>)` to the help text of the option.
- `complete=` - The expression that completes on the command line. List of comma separated items consisting of:
  - Any of the `compopt -o` argument.
		- `bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs`
		- `default|dirnames|filenames` are handled in zsh and fish.
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
	      - Description of the completion. Relevant for ZSH only.
	  - Example: `complete='compgen -P "plain${L_TAB}" -W "a b c" -- "$1"'`
	  - Example: `complete='nospace,compgen -P "plain${L_TAB}" -S "${L_TAB}Completion description" -W "a b c" -- "$1"'`
	  - The function `L_argparse_compgen` automatically adds `-P` `-S` arguments based on `help` of an option.
	    - Example: `complete='L_argparse_compgen -W "a b c" -- "$1"'`
	  - The function `L_argparse_optspec_get_complete_description` can be used to generate completion description of an option.
	  - Note: the expression may not contain a comma. If you need comma, delegate completion to a function.
- `validate=` - The expression that evaluates if the value is valid.
  - The variable `$1` is exposed with the value of the argument
	- The associative array variable `_L_optspec` is exposed with the argument specification
  - Example: `validate='[[ "$1" =~ (a|b) ]]'`
  - Example: `validate='L_regex_match "$1" "(a|b)"`
  - Example: `validate='grep -q "(a|b)" <<<"$1"`
  - Example: `validate_my_arg() { echo "Checking is $1 of type ${_L_optspec[type]} is correct... it is not!"; return 1; }; ... validate='validate_my_arg "$1"'`

## `add_subparser` options:

Subparser takes following options from `add_argument`: `action=`, `metavar=` and `dest=`.

## `add_func` options:

Function call takes following `k=v` options:
- `prefix=` - Required. Consider all functions to call with specified prefix, with prefix removed.
- `subcall=` - Specify if the functions are also using `L_argparse`.
  The value is used to generate description for parent parser help message and to generate shell completions.
  - `1` - All functions call `L_argparse`. The will be called to generate shell completions.
  - `0` - The sub-functions do not call `L_argparse`. They will not be called to generate shell comlpetions
  - `detect` - If the sub-function definition contains a call to `L_argparse`, call it, otherwise don't.
- `required=` `metavar=` `dest=` - like in `add_argument`.

# Implementation documentation

Parser with subparsers implementation is a tree where each node is a parser and each leaf is an argument.

```
parser0 +-> argument1
        |-> argument2
        |-> subparser1 +> argument3
        |              \> argument4
        |
        \-> subparser2 +> argument5
                       \> subparser3 -> argument6
```

However Bash does not support nested data structures.

By assigning a number to each parser and argument the structure can be "flattened" out completely.
Each object property is stored as an index in an array.
The information about childs or parents are stored as an reference of an index that owns an optio.
For exmaple `_L_opt__parseri[4]=1` means that `argument4` is owned by `subparser1`.

Properties that do not map to arguments from the user are prefixed with additional `_`.

## `_L_parser`

`_L_parser_*` array variables allow to:
- access the parser settings
- find an argument associated with long `--option`
- find an argument associated with short option `-o`
- find a subparser by its name
- iterate over all options
- iterate over all arguments
- iterate over all subparsers

## `_L_opt`

`_L_opt_*` array variables store options and arguments speis an associative array used to store options and arguments specifications.
Additional keys set internally in `_L_optspec` when parsing arguments:

- `_options` - Space separated list of short and long options. Used to detect if this is an option or an argument.
- `_isarray` - Should the `dest` variable be assigned as an array? Holds 1 or missing.
- `_desc` - Description used in error messages. Metavar for arguments or list of options joined with `/`.

## Completion

### Completion cases

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

## History

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

# Reason it exists

I did not like argbash that requires some code generation. There should
be no generation required. It is just a function that executes.

::: bin/L_lib.sh argparse
