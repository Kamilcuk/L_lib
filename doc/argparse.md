# `L_argparse`

## `_L_parser`

An associative array of associative arrays. The array exists to achieve the following goals:
- extract the mainsettings of the argparse
- iterate over all --options optspec
- find an --option or -o
- iterate over all arguments optspec

The array contains the following keys:
- `mainsettings` - for the main settings of the option
- `-o` or `--options` - the optspec of a particular option for fast lookup
- `optionN` where N is a non-negative integer - the optspec of option number `N`
- `argN` where N is a non-negative integer - the optspec of argument number `N`

An array of associative arrays of values.
- `0` index contains main settings of the parser
- `N` further indexes contain options as specified by the user

## `_L_mainsettings` fields documentation

User settable parameters:

- `prog` - The name of the program (default: `${0##*/}`)
- `usage` - The string describing the program usage (default: generated from arguments added to parser)
- `description` - Text to display before the argument help (by default, no text)
- `epilog` - Text to display after the argument help (by default, no text)
- `add_help` - Add a -h/--help option to the parser (default: True)
- `allow_abbrev` - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: True)
- `Adest` - Store all values as keys into this associated dictionary.
  Array result is properly quoted and can be deserialized with `declare -a var="($value)"`.

## `_L_optspec` fields documentation

User settable fields:

- name or flags - Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.
- `dest` - The name of the variable variable that is assigned as the result of the option.
- `metavar` - A name for the argument in usage messages.
- `default` - store this default value into `dest`
  - If the result of the option is an array, this value is parsed as if by  `declare -a dest="($default)"`.
- `const` - the value to store into `dest` depending on `action`
- `nargs` - The number of command-line arguments that should be consumed.
  - `1`. Argument from the command line will be assigned to variable `dest`.
  - `N` (an integer). `N` arguments from the command line will be gathered together into a array.
  - `?`. One argument will be consumed from the command line if possible.
  - `+`. All command-line arguments present are gathered into a list.
  - `*`. Just like '*', all command-line `args` present are gathered into a list. Additionally, an error message will be generated if there was not at least one command-line argument present.
  - `remainder` - After first non-option argument, collect all remaining command line arguments into a list.
- `choices` - A sequence of the allowable values for the argument.
- `required` - Whether or not the command-line option may be omitted (optionals only).
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
- `type` - The type to which the command-line argument should be converted.
  - `int` - set `validate` to assert value is a number
  - `float` - set `validate` to assert value is a float number
  - `nonnegative` - set `validate` to assert value is a non-negative integer number
  - `positive` - set `validate` to assert value is a positive integer number
  - `file` - set `complete=filenames`
  - `file_r` - set `validate` to assert file exists and is readable and set `complete=filenames`
  - `file_r` - set `validate` to assert file exists and is writable and set `complete=filenames`
  - `dir` - set `complete=dirnames`
  - `dir_r` - set `validate` to assert directory exist and is readable and set `complete=dirnames`
  - `dir_r` - set `validate` to assert directory exist and is writable and set `complete=dirnames`
- `completor` - The expression that completes on the command line.
  - any of the `compopt -o` argument:
	  - `bashdefault` `default` `dirnames` `filenames` `noquote` `nosort` `nospace` `plusdirs`
	- any other `<string>`
	  - evaluate the `<string>` to generate completion
	  - completion expression should repeatedly output two lines:
	    - first line containing the string `plain`
	    - followed by a line with completion value
- `validator` - The expression that evaluates if the value is valid.
  - the variable `$1` is exposed with the value of the argument
- `help` - Brief description of what the argument does.

Internal fields:

- `options` - space separated list of short and long options
- `index` - index of the `optspec` into an array, used to uniquely identify the option
- `isarray` - if `dest` is assigned an array, 0 or 1
- `mainoption` - used in error messages to signify which option is the main one
