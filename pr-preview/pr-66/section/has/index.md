`L_HAS_` is a collection of variables to detect bash features.

```
if ((L_HAS_SRANDOM)); then
  echo "SRANDOM is supported $SRANDOM"
else
  echo "SRANDOM is not supported"
fi
```

## API Reference

## has

Set of integer variables for checking if Bash has specific feature.

### $L_BASH_VERSION

Bash version expressed as a hexadecimal integer variable with digits 0xMMIIPP, where MM is major part, II is minor part and PP is patch part of version.

**Shellcheck disable=** [SC2004](https://www.shellcheck.net/wiki/SC2004)

### $L_HAS_BASH5_3

### $L_HAS_BASH5_2

### $L_HAS_BASH5_1

### $L_HAS_BASH5_0

### $L_HAS_BASH4_4

### $L_HAS_BASH4_3

### $L_HAS_BASH4_2

### $L_HAS_BASH4_1

### $L_HAS_BASH4_0

### $L_HAS_BASH3_2

### $L_HAS_BASH3_1

### $L_HAS_BASH3_0

### $L_HAS_BASH2_5

### $L_HAS_BASH2_4

### $L_HAS_BASH2_3

### $L_HAS_BASH2_2

### $L_HAS_BASH2_1

### $L_HAS_BASH2_0

### $L_HAS_BASH1_14_7

### $L_HAS_TRAP_P

trap has -P option

### $L_HAS_COMPGEN_V

\`compgen' has a new option: -V varname. If supplied, it stores the generated

### $L_HAS_NO_FORK_COMMAND_SUBSTITUTION

New form of command substitution: ${ command; } or ${|command;} to capture

### $L_HAS_PATSUB_REPLACEMENT

New shell option: patsub_replacement. When enabled, a \`&' in the replacement

### $L_HAS_k_EXPANSION

There is a new parameter transformation operator: @k. This is like @K, but

### $L_HAS_SRANDOM

SRANDOM: a new variable that expands to a 32-bit random number

### $L_HAS_WAIT_P

wait: has a new -p VARNAME option, which stores the PID returned by \`wait -n'

### $L_HAS_UuLK_EXPASIONS

New `U',`u', and `L' parameter transformations to convert to uppercas New `K' parameter transformation to display associative arrays as key-

### $L_HAS_EPOCHREALTIME

There is an EPOCHREALTIME variable, which expands to the time in seconds

### $L_HAS_QEPAa_EXPANSIONS

There is a new ${parameter@spec} family of operators to transform the value of \`parameter'.

### $L_HAS_LOCAL_DASH

Bash 4.4 introduced function scoped `local -`

### $L_HAS_MAPFILE_D

The \`mapfile' builtin now has a -d option

### $L_HAS_DECLARE_WITH_NO_QUOTES

The declare builtin no longer displays array variables using the compound

assignment syntax with quotes; that will generate warnings when re-used as input, and isn't necessary. Declare -p on Bash\<4.4 adds extra $'\\001' before $'\\001' and $'\\177' bytes.

### $L_HAS_WAIT_N

The `wait' builtin has a new`-n' option to wait for the next child to

### $L_HAS_NAMEREF

Bash 4.3 introduced declare -n nameref

### $L_HAS_PRINTF_T

The printf builtin has a new %(fmt)T specifier

### $L_HAS_VARIABLE_FD

If the optional left-hand-side of a redirection is of the form {var},

### $L_HAS_EXTGLOB_IN_TESTTEST

Force extglob on temporarily when parsing the pattern argument to

the == and != operators to the \[\[ command, for compatibility.

### $L_HAS_TEST_V

Bash 4.1 introduced test/\[/\[\[ -v variable unary operator

### $L_HAS_PRINTF_V_ARRAY

\`printf -v' can now assign values to array indices.

### $L_HAS_ASSOCIATIVE_ARRAY

Bash 4.0 introduced declare -A var=([a]=b)

### $L_HAS_MAPFILE

Bash 4.0 introduced mapfile

### $L_HAS_READARRAY

Bash 4.0 introduced readarray

### $L_HAS_CASE_FALLTHROUGH

Bash 4.0 introduced case fallthrough ;& and ;;&

### $L_HAS_LOWERCASE_UPPERCASE_EXPANSION

Bash 4.0 introduced ${var,,} and ${var^^} expansions

### $L_HAS_BASHPID

Bash 4.0 introduced BASHPID variable

### $L_HAS_COPROC

Bash 3.2 introduced coproc

### $L_HAS_UNQUOTED_REGEX

\[\[ =~ has to be quoted or not, no one knows.

Bash4.0 change: The shell now has the notion of a `compatibility level', controlled by new variables settable by`shopt'. Setting this variable currently restores the bash-3.1 behavior when processing quoted strings on the rhs of the `=~' operator to the`\[\[' command. Bash3.2 change: Quoting the string argument to the \[\[ command's =~ operator now forces string matching, as with the other pattern-matching operators.

### $L_HAS_PREFIX_EXPANSION

Bash 2.4 introduced ${!prefix\*} expansion

### $L_HAS_HERE_STRING

Bash 2.05 introduced \<<\<"string"

### $L_HAS_INDIRECT_EXPANSION

Bash 2.0 introduced ${!var} expansion

### $L_HAS_ARRAY

Bash 1.14.7 introduced arrays

Bash 1.14.7 also introduced: New variables: DIRSTACK, PIPESTATUS, BASH_VERSINFO, HOSTNAME, SHELLOPTS, MACHTYPE. The first three are array variables.
