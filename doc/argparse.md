# `L_argparse`

The utility for command line argument parsing.

<!-- vim-markdown-toc GFM -->

* [Example](#example)
* [Features](#features)
* [Specification](#specification)
  * [Main settings parameters](#main-settings-parameters)
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
  -- filename \
  -- -c --count \
  -- -v --verbose action=store_1 \
  ---- -c 5 -v ./file1
echo "$count $verbose $filename" # outputs: 5 1 ./file1
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

The `L_argparse` command takes multiple "chains" of command line arguments. Each chain is separated by `--`. The last chain ends with `----` and separates argument parsing specification from the actual command line arguments.

```
L_argparse prog="PROG" description="This is the first chain of options" epilog="This is an epilog" \
  -- --option action=store nargs=1 help="This is the second chain of options" \
  ---- --option "These are the arguments to parse"
echo "$option"  # outputs: These are the arguments to parse
```

Each chain is composed positional arguments like `-o` or `--option` and key-value arguments like `nargs="*"`.

The first chain of arguments specifies the "main settings" of command line parsing arguments. The options are similar to python `argparse.ArgumentParser` options.

Then each next each chain of arguments attaches individual argument specifications to the parser. It defines how a single command-line argument should be parsed. This is similar to python `argparse.add_argument` function.

See https://docs.python.org/3/library/argparse.html .

## Reserved options

Options starting what `--L_argparse_` are reserved for internal use. In particuler:

- `--L_argparse_get_completion` - output completion stream for given arguments
- `--L_argparse_complete_bash` - print Bash completion script and exit
- `--L_argparse_complete_zsh` - print Zsh completion script and exit
- `--L_argparse_complete_fish` - print Fish completion script and exit
- `--L_argparse_print_completion` - print a helpy message how to use bash completion
- `--L_argparse_print_usage` - print usage and exit
- `--L_argparse_print_help` - print help and exit

## Main settings parameters

Main settings take only the following key-value arguments:

- `prog` - The name of the program (default: `${0##*/}`)
- `usage` - The string describing the program usage (default: generated from arguments added to parser).
  - The string `%(prog)s` is __not__ replaced by the program name in usage messages.
- `description` - Text to display before the argument help (by default, no text)
- `epilog` - Text to display after the argument help (by default, no text)
- `add_help` - Add a -h/--help option to the parser (default: True)
- `allow_abbrev` - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: True)
- `Adest` - Store all values as keys into this associated dictionary.
  If the result is an array, it is properly quoted and can be deserialized with `declare -a var="(${Adest[key]})"`.
- `show_default` - default value of `show_default` property of all options. Example `show_default=1`.

## argument parameters

- name or flags - Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.
  - see https://docs.python.org/3/library/argparse.html#name-or-flags
- `action` - The basic type of action to be taken when this argument is encountered at the command line.
  - `store` or unset - store the value given on command line. Implies `nargs=1`
  - `store_const` - when option is used, assign the value of `const` to variable `dest`
  - `store_0` - set `action=store_const` `const=0` `default=1`
  - `store_1` - set `action=store_const` `const=1` `default=0`
  - `store_true` - set `action=store_const` `const=true` `default=false`
  - `store_false` - set `action=store_const` `const=false` `default=true`
  - `append_const` - when option is used, append the value of `const` to array variable `dest`
  - `append` - append the option value to array variable `dest`
  - `count` - every time option is used, `dest` is incremented, starting from if unset
  - `eval:*` - evaluate the string after `eval:` whenever option is set.
- `nargs` - The number of command-line arguments that should be consumed.
  - `1`. Argument from the command line will be assigned to variable `dest`.
  - `N` (an integer). `N` arguments from the command line will be gathered together into a array.
  - `?`. One argument will be consumed from the command line if possible.
  - `*`. All command-line arguments present are gathered into a list.
  - `+`. Just like `*`, all command-line `args` present are gathered into a list. Additionally, an error message will be generated if there was not at least one command-line argument present.
  - `remainder` - After first non-option argument, collect all remaining command line arguments into a list.
- `const` - the value to store into `dest` depending on `action`
- `default` - store this default value into `dest`
  - If the result of the option is an array, this value is parsed as if by  `declare -a dest="($default)"`.
- `type` - The type to which the command-line argument should be converted.
  - `int` - set `validate='L_is_integer "$1"'`
  - `float` - set `validate='L_is_float "$1"'`
  - `nonnegative` - set `validate='L_is_integer "$1" && [[ "$1" > 0 ]]'`
  - `positive` - set `validate'L_is_integer "$1" && [[ "$1" >= 0 ]]'`
  - `file` - set `validate='[[ -f "$1" ]]' complete=file`
  - `file_r` - set `validate=[[ -f "$1" && -r "$1" ]]' complete=filenames`
  - `file_w` - set `validate'[[ -f "$1" && -w "$1" ]]' complete=filenames`
  - `dir` - set `validate='[[ -d "$1" ]]' complete=dir`
  - `dir_r` - set `validate='[[ -d "$1" && -x "$1" && -r "$1" ]]' complete=dirnames`
  - `dir_w` - set `validate='[[ -d "$1" && -x "$1" && -w "$1" ]]' complete=dirnames`
- `choices` - A sequence of the allowable values for the argument. Deserialized with `declare -a choices="(${_L_optspec[choices]})"`. Example: `choices="a b c 'with space'"`
- `required` - Whether or not the command-line option may be omitted (optionals only).
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

# Implementation documentation

## `_L_parser`

An associative array of associative arrays. The array exists to achieve the following goals:
- extract the mainsettings of the argparse
- iterate over all --options optspec
- find an --option or -o
- iterate over all arguments optspec

The array contains the following keys:
- `0` - for the main settings of the option
- `-o` or `--options` - the optspec of a particular option for fast lookup
- `optionN` where N is a non-negative integer - the optspec of option number `N`
- `argN` where N is a non-negative integer - the optspec of argument number `N`

An associative array variable `_L_mainsettings` is used to store main settings.

An associative array `_L_optspec` is used to store argument specification.
Additional keys set internally in `_L_optspec` when parsing arguments:

- `options` - space separated list of short and long options
- `index` - index of the `optspec` into an array, used to uniquely identify the option
- `isarray` - if `dest` is assigned an array, 0 or 1
- `mainoption` - used in error messages to signify which option is the main one

# Reason it exists

I did not like argbash that requires some code generation. There should be no generation required. It is just a function that executes.
