These are some functions that I call "basic" because they are really that useful. The create the "base" programming experience and feel I want to expect from a programming language.

The are many functions here that I am not sure how to group correctly. They should be grouped in smaller sections.

## API Reference

## stdlib

Some base simple definitions for every occasion.

### L_regex_match

Wrapper around =~ for contexts that require a function.

**Arguments:**

- **`$1`** string to match
- **`$2`** regex to match against

### L_regex_escape

Produce a string that is a regex escaped version of the input.

Works for both basic and extended regular expression.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** string to escape

**See:**

- <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_04>
- <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_03>

### L_regex_escape_vL_RET

### L_regex_findall

Get all matches of a regex to an array.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** string to match
- **`$2`** regex to match

### L_regex_findall_vL_RET

### L_regex_replace

Replace all matches of a regex with a string.

In a string replace all occurences of a regex with replacement string. Backreferences like & \\1 \\2 etc. are replaced in replacement string unless -B option is used. Written pure in Bash. Uses \[\[ =~ operator in a loop.

Example

```
L_regex_replace -v out 'world world' 'w[^ ]*' 'hello'
echo "$out"
```

**Options:**

- **`-v <var>`** Store the output in variable instead of printing it.
- **`-g`** Global replace
- **`-c <int>`** Limit count of replacements, default: 1
- **`-n <var>`** Variable to set with count of replacements made.
- **`-B`** Do not handle backreferences in replacement string & \\1 \\2 \\
- **`-h`** Print this help and return 0.

**Arguments:**

- **`$1`** string to match
- **`$2`** regex to match
- **`$3`** replacement string

**Exit:** If -n option is given, exit with 0, otherwise exit with 0 if at least one replacement was made, otherwise exit with 1.

### L_execute

Executes the command.

**Argument:** **`$@`** Command to execute.

### L_not

Inverts exit status.

**Argument:** **`$@`** Command to execute.

### L_return

Return the first argument

**Argument:** **`$1`** integer to return

### L_shopt_extglob

Runs the command with extglob restoring the option after return.

**Argument:** **`$@`** Command to execute

### L_shopt

Runs the command with the specified shopt option enabled temporarily.

**Arguments:**

- **`$1`** shopt option name (e.g., nullglob)
- **`$@`** command to execute

### L_set

Runs the command with the specified shell option enabled temporarily.

The design choice is to provide a scoped (RAII-like) setting that automatically restores the original shell state upon return, ensuring environment isolation. It supports both single-letter flags (-x, -f) and long options (-o pipefail).

Example

```
# Chain multiple options by nesting:
L_set -o pipefail L_set -x my_command arg1
```

**Arguments:**

- **`$1`** The shell option to apply (e.g., -x, -f, -o).
- **`[$2]`** If $1 was -o, the -o to apply.
- **`$@`** The command and its arguments to execute.

### L_setx

Runs the command under set -x restoring the setting after return.

**Argument:** **`$@`** Command to execute

### L_unsetx

Runs the command under set +x restoring the setting after return.

**Argument:** **`$@`** Command to execute

**See:** [L_setx](#L_lib.sh--L_setx)

### L_setposix

Runs the command under set -o posix restoring the setting after return.

**Argument:** **`$@`** Command to execute

### L_unsetposix

Runs the command under set +o posix restoring the setting after return.

**Argument:** **`$@`** Command to execute

### L_glob_match

Wrapper around == for contexts that require a function.

**Arguments:**

- **`$1`** string to match
- **`$2`** glob to match against

**Shellcheck disable=** [SC2053](https://www.shellcheck.net/wiki/SC2053)

**See:** [L_extglob_match](#L_lib.sh--L_extglob_match)

### L_extglob_match

Wrapper around == for contexts that require a function.

This is equal to L_glob_match when `==` has always extglob enabled. However, this was not the case for older bash. In which case this function temporary enables extglob.

**Arguments:**

- **`$1`** string to match
- **`$2`** glob to match against

**Shellcheck disable=** [SC2053](https://www.shellcheck.net/wiki/SC2053)

**See:** [L_glob_match](#L_lib.sh--L_glob_match)

### L_glob_escape

Produce a string that is a glob escaped version of the input.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** string to escape

### L_glob_escape_vL_RET

### L_source

Execute source with arguments.

This is usefull when wanting to source a script without passing a arguments.

**Arguments:**

- **`$1`** Script to source.
- **`$@`** Positional arguments to script.

**Shellcheck disable=** [SC1090](https://www.shellcheck.net/wiki/SC1090)

**See:** <https://stackoverflow.com/a/73791073/9072753>

### L_eval

Evaluate the expression by first setting the arguments.

This is usefull to properly quote the expression and still use eval and variables.

Example

```
L_assert 'variable has quotes' L_eval '[[ "$1" != *\"* ]]' "$variable"
# much simpler and easier to quote than:
L_assert 'variable has quotes' "[[ ${variable@Q} == *\\\"* ]]"
```

**Arguments:**

- **`$1`** Script to execute.
- **`$@`** Positional arguments to set for the duration of the script.

### L_subshell

Call the command in a subshell.

**Argument:** **`$@`** Command to excute.

### L_compgen

Wrapper around compgen that does not support -V argument.

Note

`copmgen -W` allows execution. For example \`compgen -W '$(echo something >&2)'\`\` executes echo.

**Option:** **`-V <var>`** Store the output in variable instead of printing it.

**Argument:** **`$@`** Any other compgen options and arguments.

### L_function_exists

Return 0 if the argument is a function

**Argument:** **`$1`** function name

### L_command_exists

Return 0 if the argument is a command.

Consider using L_hash instead. This differs from L_hash in the presence of an alias. `command -v` detects aliases. `hash` detects actual executables in PATH and bash functions.

**Argument:** **`$@`** commands names to check

**See:** [L_hash](#L_lib.sh--L_hash)

### L_hash

Execute Bash hash builtin with silenced output.

A typical mnemonic to check if a command exists is `if hash awk 2>/dev/null`. This saves to type the redirection.

Why hash and not command or type? Bash stores all executed commands from PATH in hash. Indexing it here, makes the next call faster.

**Argument:** **`$@`** commands to check

**See:** [L_command_exists](#L_lib.sh--L_command_exists)

### L_is_main

Return 0 if current script is not sourced.

### L_is_sourced

Return 0 if current script sourced.

Comparing BASH_SOURCE to $0 only works, when BASH_SOURCE is different from $0. When calling `.` or `source` builtin it will be added as an "source" into `FUNCNAME` array. This function returns false, if there exists a source element in FUNCNAME array.

### L_has_sourced_arguments

Return true if sourced script was passed any arguments.

When you source a script and do not pass any arguments, the arguments are equal to the parent scope.

```
$ set -- a b c ; source <(echo 'echo "$@"')          # script sourced with no arguments
a b c
$ set -- a b c ; source <(echo 'echo "$@"') d e f    # script sourced with arguments
d e f
```

It is hard to detect if the script arguments are real arguments passed to `source` command or not. This function detect the case by checking for a command "source" in FUNCNAME.

Example

```
if L_is_main; then
   main
   exit $?
elif L_has_sourced_arguments; then
   sourced_main "$@"
   return
else
   sourced_main
   return
fi
```

**Arguments:** Takes no arguments

**See:**

- <https://stackoverflow.com/a/79201438/9072753>
- <https://stackoverflow.com/questions/61103034/avoid-command-line-arguments-propagation-when-sourcing-bash-script/73791073#73791073>
- <https://unix.stackexchange.com/questions/568747/bash-builtin-variables-bash-argv-and-bash-argc>

### L_is_in_bash

Return 0 if running in bash shell.

Portable with POSIX shell.

### L_in_posix_mode

Return 0 if running in posix mode.

### L_var_is_set

Return 0 if variable is set

**Argument:** **`$1`** variable nameref

**Exit:** 0 if variable is set, nonzero otherwise

### L_var_is_notnull

Return 0 if variable is set and is not null (not empty)

**Argument:** **`$1`** variable nameref

**Exit:** 0 if variable is set, nonzero otherwise

### L_var_to_string

Serialize variable value to a string that can be declared.

The result is a string that is the value of variable quoted in a format that can be reused as input to declare.

For scalar variables, the function outputs a quoted value of the variable. For array and associative array variables, the function outputs a string in the form of `([a]=b)` that can be used to assign to another variable.

Use `declare` with `-a` or `-A` for arrays to load the result into a variable. Eval is not preferred and might result in invalid values on Bash\<4.4. Bash\<4.4 prepends byte 0x01 in front of bytes 0x01 and 0x7f. Single 0x01 in declare -p output results in double 0x01,0x01.

Namerefences variables are not resolved and instead result in an empty string. This is by design - checking if variable is a string, requires a call to declare, which is costly. If you know a way to check if nameref without calling declare, let me know, I would want to add.

Example

```
local -A map=([a]=b [c]=d)
L_var_to_string -v tmp map
declare -A map2=$tmp
```

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** variable name

**See:**

- [L_HAS_DECLARE_WITH_NO_QUOTES](#L_lib.sh--L_HAS_DECLARE_WITH_NO_QUOTES)
- [L_HAS_QEPAa_EXPANSIONS](#L_lib.sh--L_HAS_QEPAa_EXPANSIONS)
- [L_cache](#L_lib.sh--L_cache)

### L_var_is_notarray

Return 0 if variable is not an array neither an associative array.

**Argument:** **`$1`** variable nameref

### L_var_is_array

Return 0 if variable is an indexed integer array, not an associative array.

**Argument:** **`$1`** variable nameref

### L_var_is_readonly

Return 0 if variable is readonly.

**Argument:** **`$1`** variable nameref

### L_var_is_integer

Return 0 if variable has integer attribute set.

**Argument:** **`$1`** variable nameref

### L_var_is_exported

Return 0 if variable is exported.

**Argument:** **`$1`** variable nameref

### L_var_is_associative

Return 0 if variable is an associative array.

**Argument:** **`$1`** variable nameref

### L_var_to_string_vL_RET

### L_var_get_nameref

Get the namereference variable name that the variable references to.

If the variable is not a namereference, return 1

**Option:** **`-v <var>`** Variable to assign. If not given, print to stdout.

**Argument:** **`$1`** variable nameref

**See:** [L_var_is_nameref](#L_lib.sh--L_var_is_nameref)

### L_var_get_nameref_vL_RET

### L_var_is_nameref

Return 0 if the variable is a namereference.

**Argument:** **`$1`** variable nameref

**See:** [L_var_get_nameref](#L_lib.sh--L_var_get_nameref)

### L_printf_append

Append to the first argument if first argument is not null.

If first argument is an empty string, print the line. Used by functions optically taking a -v argument or printing to stdout, when such functions want to append the printf output to a variable for example in a loop or similar.

Example

```
func() {
  local var=
  if [[ "$1" == -v ]]; then
     var=$2
     shift 2
  fi
  L_printf_append "$var" "%s" "Hello "
  L_printf_append "$var" "%s" "world\n"
}
func          # prints hello world
func -v var   # stores hello world in $v
```

**Arguments:**

- **`$1`** variable to append to or empty string
- **`$2`** printf format specification
- **`$@`** printf arguments

**Shellcheck disable=** [SC2059](https://www.shellcheck.net/wiki/SC2059) [SC2059](https://www.shellcheck.net/wiki/SC2059)

### L_uuid4

Generate uuid in bash.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**See:** <https://digitalbunker.dev/understanding-how-uuids-are-generated/>

### L_uuid4_vL_RET

### L_init_COLUMNS

The function temporarily enables checkwinsize and runs a subshell (:) to force the parent process to reap it, triggering get_tty_state() and updating COLUMNS via ioctl.

**See:** <https://askubuntu.com/a/1199418>
