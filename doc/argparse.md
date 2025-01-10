# `L_argparse`

The utility for command line argument parsing.

<!-- vim-markdown-toc GFM -->

* [Example](#example)
* [Features](#features)
* [Specification](#specification)
  * [parser settings parameters](#main-settings-parameters)
  * [argument parameters](#argument-parameters)
* [Implementation documentation](#implementation-documentation)
  * [`_L_parser`](#_l_parser)
* [Reason it exists](#reason-it-exists)

<!-- vim-markdown-toc -->

# Example

```
L_argparse \
  prog=ProgramName \
  description="What the program does" \
  epilog="Text at the bottom of help" \
  -- filename help="this is a filename" \
  -- -c --count \
  -- -v --verbose action=store_1 \
  ---- -c 5 -v ./file1
echo "$count $verbose $filename"  # outputs: 5 1 ./file1
```

# Features

- no code generation or similar
- requires bash with associative arrays, so bash 4.0 or newer
- sets Bash variable values inline in the script
- supports `argparse.ArgumentParser` options
- supports `argparse.add_argument` options
- support Bash, Zsh and Fish completion
- TODO: support fully some edge cases like --option nargs='*' or --option nargs='?' or --option nargs='+'

# Specification

```
L_argparse <parsersettings> \
  -- <add_argument> \
  -- class=group <add_group> \
  -- class=subparser <add_subparsers> \
  { \
    <subparsersettings> \
    -- <add_argument> \
  } \
  { \
    <subparsersettings> \
    -- <add_argument> \
  } \
  -- class=func CMD_ <func_subparsers> \
  ---- "$@"
```

```
parserargs ::= "--" ( add_argument | group )* [ add_subparsers | func_subparsers ]
"L_argparse" parserargs "----" "$@"
```

The `L_argparse` command takes multiple "chains" of command line arguments. Each chain is separated by `--` with sub-chains enclosed in `{` `}`. The last chain is terminated with `----` which separates argument parsing specification from the actual command line arguments.

```
char = <any char except "=">
dash = "-" | "+"
short_option = dash char ( "/" dash char )? | "/" dash char
long_option = dash dash char+ ( "/" dash dash char+ )? | "/" dash dash char
positional_args ::= ( char+ | short_option | long_option )*
keywords ::= ( "k=v" )*
parameters ::= positional_args keywords
```

Each chain is composed positional arguments like `arg`, `-o` or `--option` and separately keyword arguments like `nargs="*"`, which are differentiated with the `=` sign. There are several "types" of chains which receive different positional arguments and keyword arguments.

```
parsersettings ::= parameters
```

The first chain of arguments specifies the global `parsersettings` of the command line. The options are similar to python `argparse.ArgumentParser` options.

```
add_argument ::= parameters
```

Then next `add_argument` chains of arguments attaches individual argument specifications to the parser. It defines how a single command-line argument should be parsed. This is similar to python `argparse.add_argument` function.

```
add_group ::= "class=group" parameters
```

The `add_group` chain adds a group for the command line parsing, that arguments can join with `group=`. Group has to be specified before the arguments. The types of chain is determinates by the `action` parameter.

```
add_subparsers ::= "class=subparser" parameters ( "{" parsersettings ( parserargs ) "}" )+
```

The `add_subparsers` group allows for adding sub-parsers. Each sub-parser definition starts with `{` and ends with `}` and may contain separate arguments, groups and nested sub-parsers. Multiple sub-parsers are specified by separate `{` `}`.

```
func_subparsers ::= "class=func" parameters
```

Alternatively for `add_subparsers` you can specify `func_subparsers`. This causes to get the sub-parsers definitions by running all functions that start with the specified `<prefix>` with one argument `--L_argparse_dump_parser`. These parser dumps are then used as sub-parsers. Functions are executed in sub-shells.

## Reserved options

The prefix `--L_argparse_` of the first command line argument for parser is reserved for internal use. There are the following internal options:

- `--L_argparse_get_completion` - output completion stream for given arguments
- `--L_argparse_complete_bash` - print Bash completion script and exit
- `--L_argparse_complete_zsh` - print Zsh completion script and exit
- `--L_argparse_complete_fish` - print Fish completion script and exit
- `--L_argparse_print_completion` - print a helpy message how to use bash completion
- `--L_argparse_print_usage` - print usage and exit
- `--L_argparse_print_help` - print help and exit
- `--L_argparse_dump_parser` - serialize the parser to stdout surrounded by UUIDs and exit

## `parsersettings` parameters:

- `prog=` - The name of the program (default: `${0##*/}`)
- `usage=` - The string describing the program usage (default: generated from arguments added to parser).
  - The string `%(prog)s` is __not__ replaced by the program name in usage messages.
- `description=` - Text to display before the argument help (by default, no text)
- `epilog=` - Text to display after the argument help (by default, no text)
- `add_help=` - Add a -h/--help option to the parser (default: 1)
- `allow_abbrev=` - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: 1)
- `Adest=` - Store all values as keys into this associated dictionary.
  If the result is an array, it is properly quoted and can be deserialized with `declare -a var="(${Adest[key]})"`.
- `show_default=` - default value of `show_default` property of all options. Example `show_default=1`.
- `name=` - The name of the parser. Only relevant when used as a sub-parser.
- `aliases=` - Serialized array of strings with the aliases of the command. Only relevant when used as a sub-parser.

## `add_argument` options:

- name or flags - Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.
  - see https://docs.python.org/3/library/argparse.html#name-or-flags
- `action` - The basic type of action to be taken when this argument is encountered at the command line.
  - `store` or unset - store the value given on command line. Implies `nargs=1`
  - `store_const` - when option is used, assign the value of `const` to variable `dest`
  - `store_0` - set `action=store_const` `const=0` `default=1`
  - `store_1` - set `action=store_const` `const=1` `default=0`
  - `store_1null` - set `action=store_const` `const=1` `default=`
    - useful for `${var:+var is set}` pattern
  - `store_true` - set `action=store_const` `const=true` `default=false`
  - `store_false` - set `action=store_const` `const=false` `default=true`
  - `append` - append the option value to array variable `dest`
  - `append_const` - when option is used, append the value of `const` to array variable `dest`
  - `count` - every time option is used, `dest` is incremented, starting from if unset
  - `eval:<expr>` - evaluate the string after `eval:` whenever option is set.
  - `remainder` - After first non-option argument, collect all remaining command line arguments into a list. Default nargs is `*`.
  - `help` - Print help and exit with 0. Equal to `action=eval:'L_argparse_print_help;exit 0'`.
- `nargs` - The number of command-line arguments that should be consumed.
  - `1`. Argument from the command line will be assigned to variable `dest`.
  - `N` (an integer). `N` arguments from the command line will be gathered together into a array.
  - `?`. One argument will be consumed from the command line if possible.
  - `*`. All command-line arguments present are gathered into a list.
  - `+`. Just like `*`, all command-line arguments present are gathered into a list. Additionally, an error message will be generated if there was not at least one command-line argument present.
- `const` - the value to store into `dest` depending on `action`
- `default` - store this default value into `dest`
  - If the result of the option is an array, this value is parsed as if by  `declare -a dest="($default)"`.
- `type` - The type to which the command-line argument should be converted.
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
- `choices` - A sequence of the allowable values for the argument. Deserialized with `declare -a choices="(${_L_optspec[choices]})"`. Example: `choices="a b c 'with space'"`
- `required` - Whether or not the command-line option may be omitted (optionals only). Example `required=1`.
- `help` - Brief description of what the argument does. `%(prog)s` is not replaced. If `help=SUPPRESS` then the option is completely hidden from help.
- `metavar` - A name for the argument in usage messages.
- `dest` - The name of the variable variable that is assigned as the result of the option. Default: argument name or first long option without dashes or first short option.
- `show_default` - append the text `(default: <default>)` to the help text of the option.
- `complete` - The expression that completes on the command line. List of comma separated items consisting of:
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
- `validate` - The expression that evaluates if the value is valid.
  - The variable `$1` is exposed with the value of the argument
	- The associative array variable `_L_optspec` is exposed with the argument specification
  - Example: `validate='[[ "$1" =~ (a|b) ]]'`
  - Example: `validate='L_regex_match "$1" "(a|b)"`
  - Example: `validate='grep -q "(a|b)" <<<"$1"`
  - Example: `validate_my_arg() { echo "Checking is $1 of type ${_L_optspec[type]} is correct... it is not!"; return 1; }; ... validate='validate_my_arg "$1"'`

## `add_subparsers` options:

# Implementation documentation

Internal associative array keys start with `_`.

## `_L_parser`

`_L_parser` is an associative array that allows to:
- access the parser settings
- find an long --option
- find an short option -o
- find an sub-parser with name
- iterate over all options
- iterate over all arguments
- iterate over all sub-parsers
- iterate over all option groups
- iterate over all options with in a group

`_L_parser` contains the following keys:
- all keys of parser settings
- `_option_cnt` - string length is equal to the number of options
- `_option_N` - where N is a non-negative integer - the `optspec` of option number `N`
- `_arg_cnt` - string length is equal to the number of arguments
- `_arg_N` - where N is a non-negative integer - the `optspec` of argument number `N`
- `_group_cnt` - string length is equal to the number of groups
- `_group_N` - where N is a non-negative integer - the `groupspec` of group number `N`
- `_group_N_options` - space separated indexes of options in the group N separated by spaces
- `_helpgroups` - space separaated indexes of groups that are not required and not exclusive
- `_has_subparsers` - 1 if there are sub-parsers. Used for checking if user provided two sub-parsers.
- `_subparser_<alias>` - Sub-parser `_L_parser` with the alias `<alias>`.
- `_func` - the name of the function that is executed when the parser is run
- `-o` or `--option` - the `optspec` of the particular option for fast lookup

## `_L_optspec`

`_L_optspec` is an associative array used to store options and arguments specifications.
Additional keys set internally in `_L_optspec` when parsing arguments:

- `_options` - Space separated list of short and long options. Used to detect if this is an option or argument.
- `_index` - Key in `_L_parser`. Used to uniquely identify the entity.
- `_isarray` - Should the `dest` variable be assigned as an array? Holds 1 or missing.
- `_desc` - Description used in error messages. Metavar for arguments or list of options joined with `/`.

# Reason it exists

I did not like argbash that requires some code generation. There should
be no generation required. It is just a function that executes.

