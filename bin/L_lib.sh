#!/usr/bin/env bash
# vim: foldmethod=marker foldmarker=[[[,]]] ft=bash
# shellcheck disable=SC2034,SC2178,SC2016,SC2128,SC1083,SC1087
# SPDX-License-Identifier: LGPL-3.0
#    L_lib.sh
#    Copyright (C) 2024 Kamil Cukrowski
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# globals [[[
# @section globals
# @description some global variables

# @description Version of the library
L_LIB_VERSION=1.0.4
# @description The location of L_lib.sh file
L_LIB_SCRIPT=${BASH_SOURCE[0]}
# @description The basename part of $0.
L_NAME=${0##*/}
if [[ "$0" == */* ]]; then
# @description The directory part of $0.
L_DIR=${0%/*}
else
	L_DIR=$PWD
fi

# ]]]
# colors [[[
# @section colors
# @description Variables storing xterm ANSI escape sequences for colors.
# Variables with `L_ANSI_` prefix are constant.
# Variables without `L_ANSI_` prefix are set or empty depending on `L_color_detect function.
# The `L_color_detect` function can be used to detect if the terminal and user wishes to have output with colors.
# @example echo "$L_RED""hello world""$L_RESET"

# @description Text to be evaled to enable colors.
_L_COLOR_SWITCH="

L_BOLD=$'\E[1m'
L_BRIGHT=$'\E[1m'
L_DIM=$'\E[2m'
L_FAINT=$'\E[2m'
L_ITALIC=$'\E[3m'
# @description Standaout means italic font.
L_STANDOUT=$'\E[3m'
L_UNDERLINE=$'\E[4m'
L_BLINK=$'\E[5m'
L_REVERSE=$'\E[7m'
L_CONCEAL=$'\E[8m'
L_HIDDEN=$'\E[8m'
L_CROSSEDOUT=$'\E[9m'

L_FONT0=$'\E[10m'
L_FONT1=$'\E[11m'
L_FONT2=$'\E[12m'
L_FONT3=$'\E[13m'
L_FONT4=$'\E[14m'
L_FONT5=$'\E[15m'
L_FONT6=$'\E[16m'
L_FONT7=$'\E[17m'
L_FONT8=$'\E[18m'
L_FONT9=$'\E[19m'

L_FRAKTUR=$'\E[20m'
L_DOUBLE_UNDERLINE=$'\E[21m'
L_NODIM=$'\E[22m'
L_NOSTANDOUT=$'\E[23m'
L_NOUNDERLINE=$'\E[24m'
L_NOBLINK=$'\E[25m'
L_NOREVERSE=$'\E[27m'
L_NOHIDDEN=$'\E[28m'
L_REVEAL=$'\E[28m'
L_NOCROSSEDOUT=$'\E[29m'

L_BLACK=$'\E[30m'
L_RED=$'\E[31m'
L_GREEN=$'\E[32m'
L_YELLOW=$'\E[33m'
L_BLUE=$'\E[34m'
L_MAGENTA=$'\E[35m'
L_CYAN=$'\E[36m'
L_LIGHT_GRAY=$'\E[37m'
L_DEFAULT=$'\E[39m'
L_FOREGROUND_DEFAULT=$'\E[39m'

L_BG_BLACK=$'\E[40m'
L_BG_BLUE=$'\E[44m'
L_BG_CYAN=$'\E[46m'
L_BG_GREEN=$'\E[42m'
L_BG_LIGHT_GRAY=$'\E[47m'
L_BG_MAGENTA=$'\E[45m'
L_BG_RED=$'\E[41m'
L_BG_YELLOW=$'\E[43m'

L_FRAMED=$'\E[51m'
L_ENCIRCLED=$'\E[52m'
L_OVERLINED=$'\E[53m'
L_NOENCIRCLED=$'\E[54m'
L_NOFRAMED=$'\E[54m'
L_NOOVERLINED=$'\E[55m'

L_DARK_GRAY=$'\E[90m'
L_LIGHT_RED=$'\E[91m'
L_LIGHT_GREEN=$'\E[92m'
L_LIGHT_YELLOW=$'\E[93m'
L_LIGHT_BLUE=$'\E[94m'
L_LIGHT_MAGENTA=$'\E[95m'
L_LIGHT_CYAN=$'\E[96m'
L_WHITE=$'\E[97m'

L_BG_DARK_GRAY=$'\E[100m'
L_BG_LIGHT_BLUE=$'\E[104m'
L_BG_LIGHT_CYAN=$'\E[106m'
L_BG_LIGHT_GREEN=$'\E[102m'
L_BG_LIGHT_MAGENTA=$'\E[105m'
L_BG_LIGHT_RED=$'\E[101m'
L_BG_LIGHT_YELLOW=$'\E[103m'
L_BG_WHITE=$'\E[107m'

L_COLORRESET=$'\E[m'
L_RESET=$'\E[m'

"

# @description The L_ color variables are set to the ANSI escape sequences.
# @noargs
L_color_enable() {
	eval "${_L_COLOR_SWITCH}"
}

# @description The L_ color variables are set to empty strings.
# @noargs
L_color_disable() {
	eval "${_L_COLOR_SWITCH//=/= #}"
}

# @description Detect if colors should be used on the terminal.
# @return 0 if colors should be used, nonzero otherwise
# @arg [$1] file descriptor to check, default: 1
# @see https://no-color.org/
# @env TERM
# @env NO_COLOR
L_term_has_color() {
	[[ -t "${1:-1}" && -z "${NO_COLOR:-}" && "${TERM:-dumb}" != "dumb" ]]
}

# shellcheck disable=SC2120
# @description Detect if colors should be used on the terminal.
# @see https://en.wikipedia.org/wiki/ANSI_escape_code#Unix_environment_variables_relating_to_color_support
# @arg [$1] file descriptor to check, default 1
L_color_detect() {
	if L_term_has_color "$@"; then
		if [[ -z "${L_RESET:-}" ]]; then
			L_color_enable
		fi
	else
		if [[ -z "${L_RESET+yes}" || -n "$L_RESET" ]]; then
			L_color_disable
		fi
	fi
}
L_color_detect

L_ANSI_BOLD=$'\E[1m'
L_ANSI_BRIGHT=$'\E[1m'
L_ANSI_DIM=$'\E[2m'
L_ANSI_FAINT=$'\E[2m'
L_ANSI_STANDOUT=$'\E[3m'
L_ANSI_UNDERLINE=$'\E[4m'
L_ANSI_BLINK=$'\E[5m'
L_ANSI_REVERSE=$'\E[7m'
L_ANSI_CONCEAL=$'\E[8m'
L_ANSI_HIDDEN=$'\E[8m'
L_ANSI_CROSSEDOUT=$'\E[9m'

L_ANSI_FONT0=$'\E[10m'
L_ANSI_FONT1=$'\E[11m'
L_ANSI_FONT2=$'\E[12m'
L_ANSI_FONT3=$'\E[13m'
L_ANSI_FONT4=$'\E[14m'
L_ANSI_FONT5=$'\E[15m'
L_ANSI_FONT6=$'\E[16m'
L_ANSI_FONT7=$'\E[17m'
L_ANSI_FONT8=$'\E[18m'
L_ANSI_FONT9=$'\E[19m'

L_ANSI_FRAKTUR=$'\E[20m'
L_ANSI_DOUBLE_UNDERLINE=$'\E[21m'
L_ANSI_NODIM=$'\E[22m'
L_ANSI_NOSTANDOUT=$'\E[23m'
L_ANSI_NOUNDERLINE=$'\E[24m'
L_ANSI_NOBLINK=$'\E[25m'
L_ANSI_NOREVERSE=$'\E[27m'
L_ANSI_NOHIDDEN=$'\E[28m'
L_ANSI_REVEAL=$'\E[28m'
L_ANSI_NOCROSSEDOUT=$'\E[29m'

L_ANSI_BLACK=$'\E[30m'
L_ANSI_RED=$'\E[31m'
L_ANSI_GREEN=$'\E[32m'
L_ANSI_YELLOW=$'\E[33m'
L_ANSI_BLUE=$'\E[34m'
L_ANSI_MAGENTA=$'\E[35m'
L_ANSI_CYAN=$'\E[36m'
L_ANSI_LIGHT_GRAY=$'\E[37m'
L_ANSI_DEFAULT=$'\E[39m'
L_ANSI_FOREGROUND_DEFAULT=$'\E[39m'

L_ANSI_BG_BLACK=$'\E[40m'
L_ANSI_BG_BLUE=$'\E[44m'
L_ANSI_BG_CYAN=$'\E[46m'
L_ANSI_BG_GREEN=$'\E[42m'
L_ANSI_BG_LIGHT_GRAY=$'\E[47m'
L_ANSI_BG_MAGENTA=$'\E[45m'
L_ANSI_BG_RED=$'\E[41m'
L_ANSI_BG_YELLOW=$'\E[43m'

L_ANSI_FRAMED=$'\E[51m'
L_ANSI_ENCIRCLED=$'\E[52m'
L_ANSI_OVERLINED=$'\E[53m'
L_ANSI_NOENCIRCLED=$'\E[54m'
L_ANSI_NOFRAMED=$'\E[54m'
L_ANSI_NOOVERLINED=$'\E[55m'

L_ANSI_DARK_GRAY=$'\E[90m'
L_ANSI_LIGHT_RED=$'\E[91m'
L_ANSI_LIGHT_GREEN=$'\E[92m'
L_ANSI_LIGHT_YELLOW=$'\E[93m'
L_ANSI_LIGHT_BLUE=$'\E[94m'
L_ANSI_LIGHT_MAGENTA=$'\E[95m'
L_ANSI_LIGHT_CYAN=$'\E[96m'
L_ANSI_WHITE=$'\E[97m'

L_ANSI_BG_DARK_GRAY=$'\E[100m'
L_ANSI_BG_LIGHT_BLUE=$'\E[104m'
L_ANSI_BG_LIGHT_CYAN=$'\E[106m'
L_ANSI_BG_LIGHT_GREEN=$'\E[102m'
L_ANSI_BG_LIGHT_MAGENTA=$'\E[105m'
L_ANSI_BG_LIGHT_RED=$'\E[101m'
L_ANSI_BG_LIGHT_YELLOW=$'\E[103m'
L_ANSI_BG_WHITE=$'\E[107m'

# It resets color and font.
L_ANSI_COLORRESET=$'\E[m'
L_ANSI_RESET=$'\E[m'

# ]]]
# ansi [[[
# @section ansi
# @description Very basic functions for manipulating cursor position and color.
# @note unstable

L_ansi_up() { printf '\E[%dA' "$@"; }
L_ansi_down() { printf '\E[%dB' "$@"; }
L_ansi_right() { printf '\E[%dC' "$@"; }
L_ansi_left() { printf '\E[%dD' "$@"; }
L_ansi_next_line() { printf '\E[%dE' "$@"; }
L_ansi_prev_line() { printf '\E[%dF' "$@"; }
L_ansi_set_column() { printf '\E[%dG' "$@"; }
L_ansi_set_position() { printf '\E[%d;%dH' "$@"; }
L_ansi_set_title() { printf '\E]0;%s\a' "$*"; }
L_ANSI_CLEAR_SCREEN_UNTIL_END=$'\E[0J'
L_ANSI_CLEAR_SCREEN_UNTIL_BEGINNING=$'\E[1J'
L_ANSI_CLEAR_SCREEN=$'\E[2J'
L_ANSI_CLEAR_LINE_UNTIL_END=$'\E[0K'
L_ANSI_CLEAR_LINE_UNTIL_BEGINNING=$'\E[1K'
L_ANSI_CLEAR_LINE=$'\E[2K'
L_ANSI_SAVE_POSITION=$'\E7'
L_ANSI_RESTORE_POSITION=$'\E8'

# @description Move cursor $1 lines above, output second argument, then move cursor $1 lines down.
# @arg $1 int lines above
# @arg $2 str to print
L_ansi_print_on_line_above() {
	if ((!$1)); then
		printf "\r\E[2K%s" "${*:2}"
	else
		printf "\E[%dA\r\E[2K%s\E[%dB\r" "$1" "${*:2}" "$1"
	fi
}

L_ansi_8bit_fg() { printf '\E[37;5;%dm' "$@"; }
L_ansi_8bit_bg() { printf '\E[47;5;%dm' "$@"; }
# @description Set foreground color to 8bit RGB
# @arg $1 red
# @arg $2 green
# @arg $3 blue
L_ansi_8bit_fg_rgb() { L_ansi_8bit_fg "$((16 + 36 * $1 + 6 * $2 + $3))"; }
# @description Set foreground color to 8bit RGB
# @arg $1 red
# @arg $2 green
# @arg $3 blue
L_ansi_8bit_bg_rgb() { L_ansi_8bit_bg "$((16 + 36 * $1 + 6 * $2 + $3))"; }
# @description Set foreground color to 24bit RGB
# @arg $1 red
# @arg $2 green
# @arg $3 blue
L_ansi_24bit_fg() { printf '\E[38;2;%d;%d;%dm' "$@"; }
# @description Set background color to 24bit RGB
# @arg $1 red
# @arg $2 green
# @arg $3 blue
L_ansi_24bit_bg() { printf '\E[48;2;%d;%d;%dm' "$@"; }

# ]]]
# has [[[
# @section has
# @description Set of integer variables for checking if Bash has specific feature.

# Bash version expressed as a hexadecimal integer variable with digits 0xMMIIPP,
# where MM is major part, II is minor part and PP is patch part of version.
# shellcheck disable=SC2004
L_BASH_VERSION=$((BASH_VERSINFO[0] << 16 | BASH_VERSINFO[1] << 8 | BASH_VERSINFO[2]))
L_HAS_BASH5_3=$((   L_BASH_VERSION >= 0x050300))
L_HAS_BASH5_2=$((   L_BASH_VERSION >= 0x050200))
L_HAS_BASH5_1=$((   L_BASH_VERSION >= 0x050100))
L_HAS_BASH5_0=$((   L_BASH_VERSION >= 0x050000))
L_HAS_BASH4_4=$((   L_BASH_VERSION >= 0x040400))
L_HAS_BASH4_3=$((   L_BASH_VERSION >= 0x040300))
L_HAS_BASH4_2=$((   L_BASH_VERSION >= 0x040200))
L_HAS_BASH4_1=$((   L_BASH_VERSION >= 0x040100))
L_HAS_BASH4_0=$((   L_BASH_VERSION >= 0x040000))
L_HAS_BASH3_2=$((   L_BASH_VERSION >= 0x030200))
L_HAS_BASH3_1=$((   L_BASH_VERSION >= 0x030100))
L_HAS_BASH3_0=$((   L_BASH_VERSION >= 0x030000))
L_HAS_BASH2_5=$((   L_BASH_VERSION >= 0x020500))
L_HAS_BASH2_4=$((   L_BASH_VERSION >= 0x020400))
L_HAS_BASH2_3=$((   L_BASH_VERSION >= 0x020300))
L_HAS_BASH2_2=$((   L_BASH_VERSION >= 0x020200))
L_HAS_BASH2_1=$((   L_BASH_VERSION >= 0x020100))
L_HAS_BASH2_0=$((   L_BASH_VERSION >= 0x020000))
L_HAS_BASH1_14_7=$((L_BASH_VERSION >= 0x010E07))

# @description trap has -P option
L_HAS_TRAP_P=$L_HAS_BASH5_3
# @description `compgen' has a new option: -V varname. If supplied, it stores the generated
L_HAS_COMPGEN_V=$L_HAS_BASH5_3
# @description New form of command substitution: ${ command; } or ${|command;} to capture
L_HAS_NO_FORK_COMMAND_SUBSTITUTION=$L_HAS_BASH5_3
# @description New shell option: patsub_replacement. When enabled, a `&' in the replacement
L_HAS_PATSUB_REPLACEMENT=$L_HAS_BASH5_2
# @description There is a new parameter transformation operator: @k. This is like @K, but
L_HAS_k_EXPANSION=$L_HAS_BASH5_2
# @description SRANDOM: a new variable that expands to a 32-bit random number
L_HAS_SRANDOM=$L_HAS_BASH5_1
# @description wait: has a new -p VARNAME option, which stores the PID returned by `wait -n'
L_HAS_WAIT_P=$L_HAS_BASH5_1
# @description New `U', `u', and `L' parameter transformations to convert to uppercas
# @description New `K' parameter transformation to display associative arrays as key-
L_HAS_UuLK_EXPASIONS=$L_HAS_BASH5_0
# There is an EPOCHREALTIME variable, which expands to the time in seconds
L_HAS_EPOCHREALTIME=$L_HAS_BASH5_0
# @description There is a new ${parameter@spec} family of operators to transform the value of `parameter'.
L_HAS_QEPAa_EXPANSIONS=$L_HAS_BASH4_4
# @description Bash 4.4 introduced function scoped `local -`
L_HAS_LOCAL_DASH=$L_HAS_BASH4_4
# @description The `mapfile' builtin now has a -d option
L_HAS_MAPFILE_D=$L_HAS_BASH4_4
# @description The declare builtin no longer displays array variables using the compound
# assignment syntax with quotes; that will generate warnings when re-used as
# input, and isn't necessary.
# Declare -p on Bash<4.4 adds extra $'\001' before $'\001' and $'\177' bytes.
L_HAS_DECLARE_WITH_NO_QUOTES=$L_HAS_BASH4_4
# @description The `wait' builtin has a new `-n' option to wait for the next child to
L_HAS_WAIT_N=$L_HAS_BASH4_3
# @description Bash 4.3 introduced declare -n nameref
L_HAS_NAMEREF=$L_HAS_BASH4_3
# @description The printf builtin has a new %(fmt)T specifier
L_HAS_PRINTF_T=$L_HAS_BASH4_2
# @description If the optional left-hand-side of a redirection is of the form {var},
L_HAS_VARIABLE_FD=$L_HAS_BASH4_2
# @description Force extglob on temporarily when parsing the pattern argument to
# the == and != operators to the [[ command, for compatibility.
L_HAS_EXTGLOB_IN_TESTTEST=$L_HAS_BASH4_1
# @description Bash 4.1 introduced test/[/[[ -v variable unary operator
L_HAS_TEST_V=$L_HAS_BASH4_1
# @description `printf -v' can now assign values to array indices.
L_HAS_PRINTF_V_ARRAY=$L_HAS_BASH4_1
# @description Bash 4.0 introduced declare -A var=([a]=b)
L_HAS_ASSOCIATIVE_ARRAY=$L_HAS_BASH4_0
# @description Bash 4.0 introduced mapfile
L_HAS_MAPFILE=$L_HAS_BASH4_0
# @description Bash 4.0 introduced readarray
L_HAS_READARRAY=$L_HAS_BASH4_0
# @description Bash 4.0 introduced case fallthrough ;& and ;;&
L_HAS_CASE_FALLTHROUGH=$L_HAS_BASH4_0
# @description Bash 4.0 introduced ${var,,} and ${var^^} expansions
L_HAS_LOWERCASE_UPPERCASE_EXPANSION=$L_HAS_BASH4_0
# @description Bash 4.0 introduced BASHPID variable
L_HAS_BASHPID=$L_HAS_BASH4_0
# @description Bash 3.2 introduced coproc
L_HAS_COPROC=$L_HAS_BASH3_2
# @description [[ =~ has to be quoted or not, no one knows.
# Bash4.0 change: The shell now has the notion of a `compatibility level', controlled by
# new variables settable by `shopt'.  Setting this variable currently
# restores the bash-3.1 behavior when processing quoted strings on the rhs
# of the `=~' operator to the `[[' command.
# Bash3.2 change: Quoting the string argument to the [[ command's
# =~ operator now forces string matching, as with the other pattern-matching operators.
L_HAS_UNQUOTED_REGEX=$L_HAS_BASH3_2  # TODO: shopt
# @description Bash 2.4 introduced ${!prefix*} expansion
L_HAS_PREFIX_EXPANSION=$L_HAS_BASH2_4
# @description Bash 2.05 introduced <<<"string"
L_HAS_HERE_STRING=$L_HAS_BASH2_5
# @description Bash 2.0 introduced ${!var} expansion
L_HAS_INDIRECT_EXPANSION=$L_HAS_BASH2_0
# @description Bash 1.14.7 introduced arrays
# Bash 1.14.7 also introduced:
# New variables: DIRSTACK, PIPESTATUS, BASH_VERSINFO, HOSTNAME, SHELLOPTS, MACHTYPE.  The first three are array variables.
L_HAS_ARRAY=$L_HAS_BASH1_14_7

# ]]]
# assert [[[
# @section assert

# @description Print stacktrace and the message to stderr and exit with 29.
# @option -[0-9]+ Exit with this number.
# @arg $@ Message to print.
# @example [[ -r "$file" ]] || L_panic "File is not readable: $file"
# @see L_assert
# @see L_exit
# @see L_check
L_panic() {
	set +x
	L_print_traceback 1 >&2
	if [[ "$1" =~ ^-([0-9]+)$ ]]; then
		local e="${1#-}"
		shift
	else
		local e=29
	fi
	if [[ "$1" == -- ]]; then
		shift
	fi
	printf "%s\n" "$*" >&2
	exit "$e"
}

# @description Assert the command succeeds.
# Execute a command given from the second positional argument.
# When the command fails, execute `L_panic`.
# Note: `[[` is a bash syntax sugar and is not a command.
# `!` is also not a standalone command or builtin, so it can't be used with this function.
# You could use `eval "[[ ${var@Q} = ${var@Q} ]]"`.
# However to prevent quoting issues it is simpler to use wrapper functions.
# The function `L_regex_match` `L_glob_match` `L_not` are useful for writing assertions.
# To invert the test use `L_not` which just executes `! "$@"`.
# @arg $1 str Assertion description.
# If the description starts with '-[0-9]+', the number is used as the exit code for L_panic.
# @arg $@ command to test
# @example
#   L_assert 'wrong number of arguments' [ "$#" -eq 0 ]
#   L_assert 'first argument must be equal to insert' test "$1" = "insert
#   L_assert 'var has to match regex' L_regex_match "$var" ".*test.*"
#   L_assert 'var has to not match regex' L_not L_regex_match "$var" "[yY][eE][sS]"
#   L_assert 'var has to matcha glob' L_glob_match "$var" "*glob*"
L_assert() {
	if ! "${@:2}"; then
		set +x
		if [[ "${1:-}" =~ ^(-[0-9]+)$' \t\r\n'*(.*)$ ]]; then
			L_panic "${BASH_REMATCH[1]}" -- "$L_NAME: ERROR: assertion [$(L_quote_printf "${@:2}")] failed${BASH_REMATCH[2]:+: ${BASH_REMATCH[2]}}"
		else
			L_panic -- "$L_NAME: ERROR: assertion [$(L_quote_printf "${@:2}")] failed${1:+: $1}"
		fi
	fi
}

# @description Print the arguments to standard error and exit wtih 28.
# @option -[0-9]+ Exit with this number.
# @example test -r file || L_die "File is not readable"
# @see L_panic
# @see L_exit
# @see L_check
# @see L_assert
L_die() {
	if [[ "$1" =~ ^-([0-9]+)$ ]]; then
		local e="${1#-}"
		shift
	else
		local e=28
	fi
	if [[ "$1" == -- ]]; then
		shift
	fi
	printf "%s\n" "$*" >&2
	exit "$e"
}

# @description With no arguments or an empty string, exit with 0.
# Otherwise, the arguments are printed to stderr and exit with 27.
# @note If you want to exit with number, just call builtin exit,
# @example
# 	err=()
# 	test -r file || err+=("file is not readable")
# 	test -f file || err+=("file is not a file")
# 	L_exit "${err[@]}"
# @see L_panic
# @see L_assert
# @see L_check
L_exit() {
	if [[ -n "$*" ]]; then
		printf "%s\n" "$*" >&2
		exit 27
	else
		exit 0
	fi
}

# @description
# Execute a command given from the second argument.
# If the command fails, call `L_exit`.
# The difference to `L_assert` is that it prints calltrace on error.
# `L_check` function only prints the error message with the program name on error.
# @see L_panic
# @see L_assert
# @see L_check
L_check() {
	if ! "${@:2}"; then
		L_exit "$L_NAME: ERROR: $1"
	fi
}

# ]]]
# func [[[
# @section func
# @description Function for writing function programs.

_L_func_line_is_function_definition_with_comment() {
	[[
		"$_L_i" -gt 0 &&
		"${_L_lines[_L_i]}" =~ \
		^[[:space:]]*(function[[:space:]]+"$_L_funcname"([[:space:]\(]|$)|"$_L_funcname"[[:space:]]*\() \
		&& \
		"${_L_lines[_L_i-1]}" == "#"*
	]] # ))
}

# @description Extract the comment above the function.
# By default, get the comment of the calling function.
# @option -v <var> Assign result to this variable.
# @option -f <funcname> Print the comment of given function instead of the calling function.
# @option -s <int> Consider the calling function this many stackframes above. Default: 0
# @option -b Use Bash, do not use sed. For testing.
# @option -h Print this help and return 0.
# @return 0 if extracted an non-empty comment above the function definition.
# @example
#
#    # some unrelated comment followed by an empty line
#
#    # some comment
#    somefunc() {
#       L_func_comment
#    }
#
#    somefunc  # outputs '# some comment'
#
#    L_func_comment -f somefunc
L_func_comment() {
	local OPTIND OPTARG OPTERR _L_lines _L_i _L_v="" _L_lineno _L_source _L_funcname \
		_L_f="" _L_usebash=0 L_v="" _L_up=0 _L_funcname_escaped
	while getopts v:f:bs:h _L_i; do
		case "$_L_i" in
			v) _L_v=$OPTARG ;;
			f)
				if
					! _L_f=$(shopt -s extdebug && declare -F "$OPTARG") ||
						! IFS=' ' read -r _L_funcname _L_lineno _L_source <<<"$_L_f"
				then
					L_func_error "Could not get function $OPTARG location"; return 2
				fi
				;;
			b) _L_usebash=1 ;;
			s) _L_up=$OPTARG ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	_L_up=${_L_up:-${1:-0}}
	# L_print_traceback
	# declare -p BASH_SOURCE FUNCNAME BASH_LINENO
	# local -; set -x
	_L_funcname=${_L_funcname:-${FUNCNAME[1+_L_up]}}
	_L_lineno=${_L_lineno:-${BASH_LINENO[_L_up]}}
	_L_source=${_L_source:-${BASH_SOURCE[1+_L_up]}}
	#
	if ! {
		# Try using sed.
		((!_L_usebash)) &&
		L_hash sed &&
		L_regex_escape -v _L_funcname_escaped "$_L_funcname" &&
		L_v=$(
		  sed -n '/^#/{H;d;}; /^[[:space:]]*\(function[[:space:]]\+'"$_L_funcname_escaped"'\([[:space:](]\|$\)\|'"$_L_funcname_escaped"'[[:space:]]*(\)/{x;s/^\n//;p;x;}; {x;s/.*//;x;}' "$_L_source"
		)
	}; then
		# If there is no sed or sed failed, try to use Bash.
		L_readarray _L_lines <"$_L_source" || return 1
		#
		_L_i=$((_L_lineno-1))
		if ! _L_func_line_is_function_definition_with_comment; then
			# In interactive shells, BASH_LINENO is all wrong. extdebug is fast and works.
			if
				if [[ -z "$_L_f" ]]; then
          ! {
          	_L_f=$(shopt -s extdebug && declare -F "$_L_funcname") &&
          	IFS=' ' read -r _L_funcname _L_lineno _L_source <<<"$_L_f" &&
          	_L_i=$((_L_lineno-1)) &&
          	_L_func_line_is_function_definition_with_comment
          }
				fi
			then
				# Still couldn't find it. Traverse the whole file to find the function.
				for ((_L_i = ${#_L_lines[@]} - 1; _L_i >= 0; --_L_i)); do
					# Does line _L_i look like a definition of the function?
					if _L_func_line_is_function_definition_with_comment; then
						break
					fi
				done
			fi
		fi
		# Assign the result, read comment lines.
		for ((--_L_i; _L_i >= 0; --_L_i)); do
			if [[ "${_L_lines[_L_i]}" == "#"* ]]; then
				L_v="${_L_lines[_L_i]}"$'\n'$L_v
			else
				break
			fi
		done
	fi
	#
	[[ -n "$L_v" ]] && printf -v "$_L_v" "%s\n" "${L_v%$'\n'}"
}

# @description Print function comment as usage message.
# @arg [int] How many stack frames up.
# @see L_func_comment
# @see L_func_error
# @return 0
# @example:
#
#    # @option -t this is an option
#    # @option -g <arg> this is an option with an argument
#    # @option -h Print this help and return 0.
#    # @arg arg This is an argument
#    utility() {
#      local OPTIND OPTARG OPTERR opt t g
#      while getopts tg:h opt; do
#        case "$opt" in
#          t) t=1 ;;
#          g) g=$OPTARG ;;
#          h) L_func_help; return 0 ;;
#          *) L_func_usage; return 2 ;;
#        esac
#      done
#      shift "$((OPTARG-1))"
#      L_func_assert "one positional argument required" test "$#" -eq 1 || return 2
#      #
#      : utility logic
#    }
#
#    utility -h        # prints the comment above the function
#    utility -invalid  # prints 'Usage: utility [-th] [-g arg] arg'
#
L_func_help() {
	local up="$((${1:-0}+1))" v=""
	if L_func_comment -v v -s "$up" "$@"; then
		v="${v###}"
		v="${v## }"
		v="${v//$'\n' /$'\n'}"
		v="${v//$'\n'#/$'\n'}"
		v="${v//$'\n' /$'\n'}"
		v="${v%%$'\n'}"
		v="${v%%$'\n'}"
		v=${v#@description }
		if [[ "$v" == @* && "$v" == *$'\n'* ]]; then
			v=$'\n'$v
		fi
	else
		v="unknown help"
	fi
	echo "$0: ${FUNCNAME[up]}: $v" >&2
}

# @description Print funtion usage to stderr.
# @arg [$1] How many stack frames up.
L_func_usage() {
	local up="$((${1:-0}+1))" v i short="" long="" args="" usage="" line
	if L_func_comment -v v -s "$up"; then
		while IFS= read -r line; do
			if [[ "$line" =~ ^\#[[:space:]]+@(usage|option|arg)[[:space:]]+(.*)$ ]]; then
				line=${BASH_REMATCH[2]}
				if [[ "${BASH_REMATCH[1]}" == "usage" ]]; then
					usage=$line
					break
				elif [[ "$line" =~ --([^\ ]+)[^\<]*\<([^\>]+)\> ]]; then
					long+=" [--${BASH_REMATCH[1]} ${BASH_REMATCH[2]}]"
				elif [[ "$line" =~ --([^[:space:]]+) ]]; then
					long+=" [--${BASH_REMATCH[1]}"
				elif [[ "$line" =~ -(.)[^\<]*\<([^\>]+)\> ]]; then
					long+=" [-${BASH_REMATCH[1]} ${BASH_REMATCH[2]}]"
				elif [[ "$line" =~ -(.) ]]; then
					short+="${BASH_REMATCH[1]}"
				elif [[ "$line" =~ ([^[:space:]]+) ]]; then
					args+=" ${BASH_REMATCH[1]}"
				fi
			fi
		done <<<"$v"
		if [[ -n "${usage:=${short:+ [-$short]}$long$args}" ]]; then
			echo "${FUNCNAME[up]}: usage: ${FUNCNAME[up]}$usage" >&2
		fi
	fi
}

# @description Print function error to stderr.
# @arg [$1] Message.
# @arg [$2] How many stack frames up.
# @see L_func_help for example
L_func_error() {
	if [[ -n "${1:-}" ]]; then
		echo "$0: ${FUNCNAME[1+${2:-0}]}: error: $1" >&2
	fi
}

# @description Print function error with usage.
# @arg [$1] Message.
# @arg [$2] How many stack frames up.
# @see L_func_help for example
L_func_usage_error() {
	L_func_error "$1" "$((${2:-0}+1))"
	L_func_usage "$((${2:-0}+1))"
}

# @description Assert that the command exits with 0.
# If it does not, call L_func_error and return 2.
# If the message starts with -[0-9]+, the number is used as the number of stackframes up the message is about.
# @arg $1 Message to print, may be empty.
# @arg $@ Arguments to test.
# @return 2 if the expression failed.
# @example
#    utility() {
#      local num="$1"
#      L_func_assert "not a number: $num" L_is_integer "$num" || return 2
#    }
L_func_assert() {
	if ! "${@:2}"; then
		L_quote_printf_v "${@:2}"
		if [[ "$1" =~ ^-([0-9]+)[$' \t\r\n']*(.*)$ ]]; then
			set -- "${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}"
		else
			set -- "$1" 1
		fi
		L_func_error "assertion [$L_v] failed${1:+: $1}" "$2"
		return 2
	fi
}

# @description Print a line prefixed by the calling function name.
# @arg $@ line to print
L_func_log() {
	echo "${FUNCNAME[1]}: $*" >&2
}

# @description Make a copy of a function.
# Currently there is no sanitization done in the function.
# The second argument allows for execution under eval.
# @arg $1 existing function
# @arg $2 new function name
L_function_copy() {
  local tmp
  tmp="$(declare -f "$1")" &&
    eval "${tmp/"$1"/$2}"
}

# @description Add a script on the top or the end of a function.
# @arg $1 The function to modify
# @arg $2 Script to put in front of the function body.
# @arg $3 Script to put on the end of the function body.
L_function_modify() {
  local def middle
  def=$(declare -f "$1") &&
    middle=${def%\}*} &&
    eval "${def%%\{*} { ${2:+$'\n'$2$'\n'} ${middle#*\{} ${3:+$'\n'$3$'\n'} }"  # } }
}

# @arg $@ Decorator to apply.
# @arg $#-2 Function to decorate.
# @arg $#-1 Result of declare -f of the function to decorate.
_L_redecorate() {
	# local -;set -x
  local deco restore
  printf -v deco "%q " "${@:1:$#-1}"
	printf -v restore "%q" "${*:$#}"
	printf -v restore "%q" "_L_redecorate $deco$restore"
  eval "${*:$#-1:1}(){ ${*:$#};$deco\"\$@\";eval $restore\";return \$?\";}"
  #                                              ^^^^^^^^   - _L_redecorate decorator args func "$(declare -f func)"
  #                            ^^^^^                        - decorator args func
  #                    ^^^^^^^                              - declare -f func
  #     ^^^^^^^^^^^                                         - func
}

# @description Apply a decorator on a function.
# The next call on a function will call the decorator with arguments followed by function name with arguments.
# @arg $@ Decorator to apply with arguments.
# @arg $#-1 Function.
# @example
# 	func() { echo something; }
# 	print_and_call() {
# 		echo "CALLING: $@" >&2
# 		"$@"
# 	}
# 	func  # outputs something
# 	func  # outputs something
# 	L_decorate print_and_call func
# 	func  # outputs "CALLING func" and then "something"
# 	func  # outputs "CALLING func" and then "something"
#
# @example
# 	func() { L_print_traceback; }
# 	L_decorate L_setx func
# 	L_decorate time func
# 	L_decorate L_setx time func
# 	func arg  # calls: [L_setx time func arg]
# 	          # which calls [time func arg]
# 	          # which calls L_setx func arg
#
L_decorate() {
  local def deco func="${*:$#}"
  def=$(declare -f "$func") || return 2
  # if [[ "$def" == "$func"*"()"*"{"*":"*"eval"*"$func"*"\"\$@\""*"_L_redecorate"*"$func"*"}" ]]; then
  # def=$(
  # 	:() { printf "%q " "$@"; exit 1; }
  # 	"$func"
  # )
  # eval "def=($def)"
  # 	_L_redecorate "${@:1:$#-1}" "${def[@]}"
  # else
  _L_redecorate "$@" "$def"
}
# L_decorate() {
#   local deco func="${*:$#}" new="_L_decorate_${*:$#}_0"
#   # Find a new unused function name.
#   while L_hash "$new"; do
#     new=${new%_*}_$(( ${new##*_}+1 ))
#   done
#   # Decorate the function.
#   L_function_copy "$func" "$new" &&
#     printf -v deco " %q" "${@:1:$#-1}" "$new" &&
#     eval "$func(){$deco \"\$@\";}"
# }

# @description Measure time with the command, but include the command in the time message output and use %6l format.
# @arg $@ command to measure.
L_time() {
	local _L_time=${TIMEFORMAT:-$'\nreal\t%3lR\nuser\t%3lU\nsys\t%3lS'} TIMEFORMAT="real=%6lR user=%6lU system=%6lS [${*//$'\n'}]"
	time TIMEFORMAT="$_L_time" "$@"
}

# @description Parse 1w1d1h2m2s into number of microseconds.
# @option -v <var>
# @arg $1 Duration string.
# @see https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file
L_duration_to_usec() { L_handle_v_scalar "$@"; }
L_duration_to_usec_v() {
  [[ "$*" =~ ^((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|([0-9]+))([.]([0-9]*))?$ ]] &&
    #         123          45          67          89          01          23          45            6        7   8
    printf -v L_v "%s%06d" "$(( ( ( ( ( BASH_REMATCH[3] * 365 ) + ( BASH_REMATCH[5] * 7 ) + BASH_REMATCH[7] )
      * 24 + BASH_REMATCH[9] ) * 60 + BASH_REMATCH[11] ) * 60 + BASH_REMATCH[13] + BASH_REMATCH[16] ))" "${BASH_REMATCH[18]:-0}" &&
    # Remove leading zeros.
    L_v=$(( 10#$L_v ))
}

_L_cache_remove_append() {
  # Remove the key from cache.
  for ((_L_i = 0; _L_i < ${_L_cache[@]:+${#_L_cache[@]}}+0; _L_i += 3)); do
    if [[ "${_L_cache[_L_i]}" == "$_L_key" ]]; then
      if ((_L_clear)); then
        # Remove the element.
        _L_cache=("${_L_cache[@]::_L_i}" "${_L_cache[@]:_L_i+3}")
      else
        # We can just overwrite.
        _L_cache[_L_i+1]=$_L_now
        _L_cache[_L_i+2]=$_L_data
      fi
      return
    fi
  done
  if ((!_L_clear)); then
    # Append the new entry to cache and save it.
    _L_cache+=("$_L_key" "$_L_now" "$_L_data")
  fi
}

# @description Cache the execution of a command.
# The command execution is cached in _L_CACHE global variable or in file when -f option is present.
# The second execution of the command will result in a cached execution.
# On cached execution the exit status of the command will be extracted from the cache.
#
# @option -o Cache the stdout of the command.
#            It will run the command in a process substitution.
# @option -O <var> Cache the stdout of the command and store it in variable <var> instead of printing.
#            It will run the command in a process substitution.
# @option -s <var> Add this variable to the cache. All cache variables will be restored on cached execution.
# @option -f <file> Use the file as cache.
#            The file has a header with version number.
#            The file stores internal cache state from declare -p _L_cache variable.
#            The file content is eval-ed upon loading.
# @option -r Instead of executing, remove the cache entry associated with the command.
# @option -l Instead of executing, only list the entires in the cache.
# @option -T <ttl> Set time to live in duration string. Default: infinity.
# @option -L <01> Lock the file with flock. Default: use flock if available.
# @option -k <key> Use this key to index the cache. Default: %q quoted command with argumnets.
# @option -h Print this help and return 0.
# @arg $1 Command to execute.
# @arg $@ Arguments.
# @set _L_CACHE
# @env _L_CACHE
# @return 222 on internal error
#         otherwise returns the exit status of the cached command.
#
# @example
#    L_cache -T 10m -O output -f /tmp/cache.L_cache curl -sS https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
#
#    myfunc() {
#       var=$(( 1 + 2 ))
#    }
#    L_decorate L_cache -v var -k myfunc myfunc
#    myfunc
#    myfunc
# shellcheck disable=SC2094
L_cache() {
  local OPTIND OPTARG OPTERR _L_i _L_file="" _L_vars=() _L_ret=0 _L_stdout_var="" _L_stdout_output=0 _L_stdout="" \
    _L_clear=0 _L_ttl="" _L_flock="" _L_cache="" _L_cache_timestamp _L_cache_row _L_data="" _L_key="" _L_now \
    _L_cache_header="# L_cache version 1 $L_HAS_DECLARE_WITH_NO_QUOTES"$'\n'"declare -a _L_cache=" _L_list=0 _L_tmp=""
  while getopts oO:s:f:rlk:T:L:h _L_i; do
    case "$_L_i" in
      o) _L_stdout_output=1 ;;
      O) _L_stdout_var="$OPTARG" ;;
      s) _L_vars+=("$OPTARG") ;;
      f) _L_file=$OPTARG ;;
      r) _L_clear=1 ;;
      l) _L_list=1 ;;
      k) _L_key=$OPTARG ;;
      T)
        if ! L_duration_to_usec -v _L_ttl "$OPTARG"; then
          L_func_usage_error "invalid ttl: $OPTARG"
          return 222
        fi
        ;;
      L) _L_flock=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage; return 222 ;;
    esac
  done
  shift "$((OPTIND-1))"
  #
  if (( ${_L_vars[@]:+1} )); then
    if (( _L_stdout_output )) || [[ -n "$_L_stdout_var" ]]; then
      L_func_usage_error "can't cache variables while running the command in process substitution. Remove -s or remove -o or -O options."
      return 222
    fi
  fi
  if ((!_L_list)); then
    if (($# == 0)); then
      L_func_usage_error "nothing to execute"
      return 222
    fi
    printf -v _L_key "%q " "${_L_key:-$1}" "${@:2}"
    # Key already has escaped elements.
    _L_key=${_L_key%% }
  fi
  #
  if ((!_L_clear)); then
    # Extract current cache content.
    if [[ -z "$_L_file" ]]; then
      _L_cache=(${_L_CACHE[@]:+"${_L_CACHE[@]}"})
    else
      if [[ -z "$_L_flock" ]]; then
        L_exit_to_10 _L_flock L_hash flock
      fi
      if
        { ((_L_flock)) && { _L_cache=$(flock "$_L_file" cat "$_L_file") || return 222; }; } ||
        { [[ -e "$_L_file" ]] && { _L_cache=$(< "$_L_file") || return 222; }; }
      then
        if [[ "$_L_cache" != "$_L_cache_header"* ]]; then
          _L_cache=()
        else
          eval "$_L_cache"
        fi
      fi
    fi
    if ((_L_list)); then
    	local res=($'cmd\ttimestamp\teval') tmp
      for ((_L_i = 0; _L_i < ${#_L_cache[@]}; _L_i += 3)); do
        local ts="${_L_cache[_L_i+1]}"
        if L_hash date; then
          ts="[$(date -d @"${ts::${#ts}-6}" +"%Y-%m-%dT%H:%M:%S.${ts:${#ts}-6}%z")]"
        fi
        printf -v tmp "%q\t%s\t%q" "${_L_cache[_L_i]}" "$ts" "${_L_cache[_L_i+2]}"
        res+=("$tmp")
      done
      L_table -s $'\t' "${res[@]}"
      return 0
    fi
    # Is the key in cache and ttl is ok?
    for ((_L_i = 0; _L_i < ${#_L_cache[@]}; _L_i += 3)); do
      if [[ "${_L_cache[_L_i]}" == "$_L_key" ]]; then
        if
          if [[ -n "$_L_ttl" ]]; then
            L_epochrealtime_usec -v _L_now || return 222
            # echo "${_L_cache[_L_i+1]} ${_L_ttl} ${_L_now}" >&2
            (( _L_cache[_L_i+1] + _L_ttl >= _L_now ))
          fi
        then
          eval "${_L_cache[_L_i+2]}"
          if [[ -n "$_L_stdout_var" ]]; then
            printf -v "$_L_stdout_var" "%s" "$_L_stdout"
          fi
          if ((_L_stdout_output)); then
            printf "%s\n" "$_L_stdout"
          fi
          return "$_L_ret"
        fi
        break
      fi
    done
    # Cache was not hit, execute the command and capture what we need.
    if [[ -n "$_L_stdout_var" ]] || ((_L_stdout_output)); then
      _L_stdout=$("$@") || _L_ret=$?
      if [[ -n "$_L_stdout_var" ]]; then
        printf -v "$_L_stdout_var" "%s" "$_L_stdout"
      fi
      if ((_L_stdout_output)); then
        printf "%s\n" "$_L_stdout"
      fi
    else
      "$@" || _L_ret=$?
    fi
    for _L_i in ${_L_vars[@]:+"${_L_vars[@]}"} _L_ret _L_stdout; do
    	L_var_to_string -v _L_tmp "$_L_i" || return 222
    	_L_data+="${_L_data:+ }$_L_i=$_L_tmp"
    done
    # printf "%q\n" "_L_data=$_L_data" >&2
    L_epochrealtime_usec -v _L_now || return 222
  fi
  # Store data back in the cache.
  if [[ -z "$_L_file" ]]; then
    _L_cache=(${_L_CACHE[@]:+"${_L_CACHE[@]}"})
    _L_cache_remove_append
    _L_CACHE=(${_L_cache[@]:+"${_L_cache[@]}"})
  else
    {
      if ((_L_flock)); then flock 9; fi
      _L_cache=$(cat <&9)$'\n'
      if [[ "$_L_cache" != "$_L_cache_header"* ]]; then
        # Cache has wrong version or wrong header - clear it.
        _L_cache=()
      else
        eval "$_L_cache"
      fi
      _L_cache_remove_append
      {
        printf "%s\n" "${_L_cache_header%%$'\n'*}"
        declare -p _L_cache
      } >"$_L_file"
    } 9<"$_L_file"
  fi
  return "$_L_ret"
}

_L_getopts_forward() {
  local OPTIND OPTARG OPTERR _L_v="$1" _L_spec="$2" _L_ret=()
  shift 2
  while getopts "$_L_spec" _L_i; do
    if [[ "$_L_spec" == *"$_L_i:"* ]]; then
      _L_ret+=("-$_L_i" "$OPTARG")
    elif [[ "$_L_spec" == *"$_L_i"* ]]; then
      _L_ret+=("-$_L_i")
    else
      return 2
    fi
  done
  L_array_assign "$_L_v" "$((OPTIND-1))" "${_L_ret[@]}"
}

if ((!L_HAS_NAMEREF)); then

# @description Wrapper function for handling -v arguments to other functions.
# It calls a function called `<caller>_v` with arguments, but without `-v <var>`.
# The function `<caller>_v` should set the variable nameref L_v to the returned value.
# When the caller function is called without -v, the value of L_v is printed to stdout with a newline.
# Otherwise, the value is a nameref to user requested variable and nothing is printed.
#
# The fucntion L_handle_v_scalar handles only scalar value of `L_v` or 0-th index of `L_v` array.
# To assign an array, prefer L_handle_v_array.
#
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ arbitrary function arguments
# @exitcode Whatever exitcode does the `<caller>_v` funtion exits with.
# @example:
#    L_hello() { L_handle_v_arr "$@"; }
#    L_hello_v() { L_v="hello world"; }
#    L_hello          # outputs 'hello world'
#    L_hello -v var   # assigns var="hello world"
# @see L_handle_v_array
# shellcheck disable=SC2317
L_handle_v_scalar() {
	local L_v
	case "${1:-}" in
	-v?*)
		if
			if [[ "${2:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:3}"
			else
				"${FUNCNAME[1]}"_v "${@:2}"
			fi
		then
			printf -v "${1##-v}" "%s" "${L_v:-}" || return "$?"
		else
			local _L_r=$?
			printf -v "${1##-v}" "%s" "${L_v:-}" || return "$?"
			return "$_L_r"
		fi
		;;
	-v)
		if
			if [[ "${3:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:4}"
			else
				"${FUNCNAME[1]}"_v "${@:3}"
			fi
		then
			printf -v "$2" "%s" "${L_v:-}" || return "$?"
		else
			local _L_r=$?
			printf -v "$2" "%s" "${L_v:-}" || return "$?"
			return "$_L_r"
		fi
		;;
	--)
		if "${FUNCNAME[1]}"_v "${@:2}"; then
			printf "%s" "${L_v+$L_v$'\n'}" || return "$?"
		else
			local _L_r=$?
			printf "%s" "${L_v+$L_v$'\n'}" || return "$?"
			return "$_L_r"
		fi
		;;
	-h) L_func_help 1; return 0 ;;
	*)
		if "${FUNCNAME[1]}"_v "$@"; then
			printf "%s" "${L_v+$L_v$'\n'}" || return "$?"
		else
			local _L_r=$?
			printf "%s" "${L_v+$L_v$'\n'}" || return "$?"
			return "$_L_r"
		fi
	esac
}

# @description Version of L_handle_v_scalar for arrays.
# The options and arguments and exitcode is the same as L_handle_v_scalar.
#
# This additionally supports assignment to arrays. This is not possible with L_handle_v_scalar.
#
# The function L_handle_v_scalar is slightly faster and uses `printf -v` to assign the result.
# On newer Bash, `printf -v` can assign to array and associative arrays variable indexes.
#
# In constract, `L_handle_v_array` has to first assert if the string is a valid variable name.
# Only then it uses `eval` with an array assignment syntax to assign the result to the user requsted variable.
#
# Currently array indexes are not preserved. This could be worked on in the future when needed.
#
# @example:
#    L_hello() { L_handle_v_arr "$@"; }
#    L_hello_v() { L_v=(hello world); }
#    L_hello          # outputs two lines 'hello' and 'world'
#    L_hello -v var   # assigns var=(hello world)
# @see L_handle_v_scalar.
# shellcheck disable=SC2317
L_handle_v_array() {
	local L_v
	case "${1:-}" in
	-v?*)
		if ! L_is_valid_variable_name "${1##-v}"; then
			L_func_error "not a valid identifier: ${1##-v}" 1; return 2
		fi
		if
			if [[ "${2:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:3}"
			else
				"${FUNCNAME[1]}"_v "${@:2}"
			fi
		then
			eval "${1##-v}"'=(${L_v[@]+"${L_v[@]}"})' || return "$?"
		else
			local _L_r=$?
			eval "${1##-v}"'=(${L_v[@]+"${L_v[@]}"})' || return "$?"
			return "$_L_r"
		fi
		;;
	-v)
		if ! L_is_valid_variable_name "${2:-}"; then
			L_func_error "not a valid identifier: $2" 1; return 1
		fi
		if
			if [[ "${3:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:4}"
			else
				"${FUNCNAME[1]}"_v "${@:3}"
			fi
		then
			eval "$2"'=(${L_v[@]+"${L_v[@]}"})' || return "$?"
		else
			local _L_r=$?
			eval "$2"'=(${L_v[@]+"${L_v[@]}"})' || return "$?"
			return "$_L_r"
		fi
		;;
	--)
		if "${FUNCNAME[1]}"_v "${@:2}"; then
			printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
		else
			local _L_r=$?
			printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
			return "$_L_r"
		fi
		;;
	-h) L_func_help 1; return 0 ;;
	*)
		if "${FUNCNAME[1]}"_v "$@"; then
			printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
		else
			local _L_r=$?
			printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
			return "$_L_r"
		fi
	esac
}

else  # L_HAS_NAMEREF

	L_handle_v_scalar() {
		case "${1:-}" in
		-v?*)
			local -n L_v="${1##-v}" || return 2
			if [[ "${2:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:3}"
			else
				"${FUNCNAME[1]}"_v "${@:2}"
			fi
			;;
		-v)
			local -n L_v="$2" || return 2
			if [[ "${3:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:4}"
			else
				"${FUNCNAME[1]}"_v "${@:3}"
			fi
			;;
		--)
			local L_v
			if "${FUNCNAME[1]}"_v "${@:2}"; then
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
			else
				local _L_r=$?
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
				return "$_L_r"
			fi
			;;
		-h) L_func_help 1; return 0 ;;
		*)
			local L_v
			if "${FUNCNAME[1]}"_v "$@"; then
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
			else
				local _L_r=$?
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
				return "$_L_r"
			fi
		esac
	}

	L_handle_v_array() {
		case "${1:-}" in
		-v?*)
			local -n L_v="${1##-v}" || return 2
			if [[ "${2:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:3}"
			else
				"${FUNCNAME[1]}"_v "${@:2}"
			fi
			;;
		-v)
			local -n L_v="$2" || return 2
			if [[ "${3:-}" == -- ]]; then
				"${FUNCNAME[1]}"_v "${@:4}"
			else
				"${FUNCNAME[1]}"_v "${@:3}"
			fi
			;;
		--)
			local L_v
			if "${FUNCNAME[1]}"_v "${@:2}"; then
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
			else
				local _L_r=$?
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
				return "$_L_r"
			fi
			;;
		-h) L_func_help 1; return 0 ;;
		*)
			local L_v
			if "${FUNCNAME[1]}"_v "$@"; then
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
			else
				local _L_r=$?
				printf "%s" "${L_v[@]+${L_v[@]/%/$'\n'}}" || return "$?"
				return "$_L_r"
			fi
		esac
	}

fi  # L_HAS_NAMEREF

# ]]]
# stdlib [[[
# @section stdlib
# @description Some base simple definitions for every occasion.

# @description Wrapper around =~ for contexts that require a function.
# @arg $1 string to match
# @arg $2 regex to match against
L_regex_match() { [[ "$1" =~ $2 ]]; }

# @description Produce a string that is a regex escaped version of the input.
# Works for both basic and extended regular expression.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ string to escape
# @see https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_04
# @see https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_03
L_regex_escape() { L_handle_v_scalar "$@"; }
L_regex_escape_v() {
	# ERE . [ \ ( * + ? { | ^ $
	# BRE . [ \   *         ^ $
	# Most of the time there are none of these characters, so it makes sense to speed up.
	if [[ "$*" == *[".[\\(*+?{|^$"]* ]]; then
		L_v=${*//\\/\\\\}
		L_v=${L_v//\[/[\[]}  # ]]
		L_v=${L_v//\./\\\.}
		L_v=${L_v//\+/[\+]}
		L_v=${L_v//\*/\\\*}
		L_v=${L_v//\?/[\?]}
		L_v=${L_v//\^/\\\^}
		L_v=${L_v//\$/\\\$}
		L_v=${L_v//\(/[\(]}
		L_v=${L_v//\{/[\{]}
		L_v=${L_v//\|/[\|]}
	else
		L_v=$*
	fi
}

# @description Get all matches of a regex to an array.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 string to match
# @arg $2 regex to match
L_regex_findall() { L_handle_v_array "$@"; }
L_regex_findall_v() {
	L_v=()
	while L_regex_match "$1" "($2)(.*)"; do
		L_v+=("${BASH_REMATCH[1]}")
		set -- "${BASH_REMATCH[2]}" "$2"
	done
}

# @description Replace all matches of a regex with a string.
# In a string replace all occurences of a regex with replacement string.
# Backreferences like \& \1 \2 etc. are replaced in replacement string unless -B option is used.
# Written pure in Bash. Uses [[ =~ operator in a loop.
# @option -v <var> Store the output in variable instead of printing it.
# @option -g Global replace
# @option -c <int> Limit count of replacements, default: 1
# @option -n <var> Variable to set with count of replacements made.
# @option -B Do not handle backreferences in replacement string \& \1 \2 \\
# @option -h Print this help and return 0.
# @arg $1 string to match
# @arg $2 regex to match
# @arg $3 replacement string
# @exitcode If -n option is given, exit with 0, otherwise exit with 0 if at least one replacement was made, otherwise exit with 1.
# @example
#   L_regex_replace -v out 'world world' 'w[^ ]*' 'hello'
#   echo "$out"
L_regex_replace() {
	local OPTIND OPTARG OPTERR _L_countmax=1 _L_count=0 _L_v="" _L_backref=1 _L_count_v="" _L_i _L_repl
	while getopts gBv:c:n:h _L_i; do
		case $_L_i in
		g) _L_countmax=-1 ;;
		B) _L_backref=0 ;;
		v) _L_v=$OPTARG; printf -v "$_L_v" "%s" ""; ;;
		c) _L_countmax=$OPTARG ;;
		n) _L_count_v=$OPTARG ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	local _L_str="${1?Missing string argument}" _L_rgx="${2:?Missing regex argument}"
	while L_regex_match "$_L_str" "($_L_rgx)(.*)"; do
		# declare -p BASH_REMATCH
		_L_repl=${3?Missing replacement argument}
		if (( _L_backref )); then
			_L_repl=${_L_repl//\\&/${BASH_REMATCH[1]}}
			for ((_L_i=1;_L_i<${#BASH_REMATCH[@]}-2;_L_i++)); do
				_L_repl=${_L_repl//\\$_L_i/${BASH_REMATCH[_L_i+1]}}
			done
			_L_repl=${_L_repl//\\\\/\\}
		fi
		L_printf_append "$_L_v" "%s" "${_L_str::${#_L_str}-${#BASH_REMATCH[0]}}$_L_repl"
		_L_str=${BASH_REMATCH[${#BASH_REMATCH[@]}-1]}
		if (( ++_L_count == _L_countmax )); then
			break
		fi
	done
	L_printf_append "$_L_v" "%s" "$_L_str"
	if [[ -n "$_L_count_v" ]]; then
		printf -v "$_L_count_v" "%s" "$_L_count"
	elif (( _L_count == 0 )); then
		return 1
	fi
}

# @description Executes the command.
# @arg $@ Command to execute.
L_execute() { "$@"; }

# @description Inverts exit status.
# @arg $@ Command to execute.
L_not() { ! "$@"; }

# @description Return the first argument
# @arg $1 <int> integer to return
L_return() { return "$1"; }

# @description Runs the command with extglob restoring the option after return.
# @arg $@ Command to execute
L_shopt_extglob() {
	if shopt -p extglob >/dev/null; then "$@"
	else
		shopt -s exglob; if "$@"; then shopt -u extglob
		else eval "shopt -u extglob;return \"$?\""; fi
	fi
}

if ((L_HAS_LOCAL_DASH)); then

# @description Runs the command under set -x restoring the setting after return.
# @arg $@ Command to execute
L_setx() {
	local -
	set -x
	"$@"
}

# @description Runs the command under set +x restoring the setting after return.
# @arg $@ Command to execute
# @see L_setx
L_unsetx() {
	local -
	set +x
	"$@"
}

# @description Runs the command under set -o posix restoring the setting after return.
# @arg $@ Command to execute
L_setposix() {
	local -
	set -o posix
	"$@"
}

# @description Runs the command under set +o posix restoring the setting after return.
# @arg $@ Command to execute
L_unsetposix() {
	local -
	set +o posix
	"$@"
}

else

	L_setx() {
		if shopt -po xtrace >/dev/null; then
			"$@"
		else
			set -x
			"$@"
			eval "set +x;return \"$?\""
		fi
	}
	L_unsetx() {
		if shopt -po xtrace >/dev/null; then
			set +x
			"$@"
			eval "set -x;return \"$?\""
		else
			"$@"
		fi
	}

	L_setposix() {
		if shopt -po posix >/dev/null; then
			"$@"
		else
			set -o posix
			"$@"
			eval "set +o posix;return \"$?\""
		fi
	}
	L_unsetposix() {
		if shopt -po posix >/dev/null; then
			set +o posix
			"$@"
			eval "set -o posix;return \"$?\""
		else
			"$@"
		fi
	}

fi

# shellcheck disable=2053
# @description Wrapper around == for contexts that require a function.
# @arg $1 string to match
# @arg $2 glob to match against
# @see L_extglob_match
L_glob_match() { [[ "$1" == $2 ]]; }

if ((L_HAS_EXTGLOB_IN_TESTTEST)); then
# shellcheck disable=2053
# @description Wrapper around == for contexts that require a function.
# This is equal to L_glob_match when `==` has always extglob enabled.
# However, this was not the case for older bash. In which case this function
# temporary enables extglob.
# @arg $1 string to match
# @arg $2 glob to match against
# @see L_glob_match
L_extglob_match() { [[ "$1" == $2 ]]; }
else
	L_extglob_match() { L_shopt_extglob _L_extglob_match_in "$@"; }
	# shellcheck disable=SC2053
	_L_extglob_match_in() { [[ "$1" == $2 ]]; }
fi

# @description Produce a string that is a glob escaped version of the input.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ string to escape
L_glob_escape() { L_handle_v_scalar "$@"; }
L_glob_escape_v() {
	L_v=${*//\\/\\\\}
	L_v=${L_v//\?/\\\?}
	L_v=${L_v//\*/\\\*}
	L_v=${L_v//\(/\\\(}
}

# @description Execute source with arguments.
# This is usefull when wanting to source a script without passing a arguments.
# @arg $1 Script to source.
# @arg $@ Positional arguments to script.
# @see https://stackoverflow.com/a/73791073/9072753
# shellcheck disable=SC1090
L_source() {
	local _L_f="$1"
	shift
	source "$_L_f" "$@"
}

# @description Evaluate the expression by first setting the arguments.
# This is usefull to properly quote the expression and still use eval and variables.
# @arg $1 Script to execute.
# @arg $@ Positional arguments to set for the duration of the script.
# @example
#    L_assert 'variable has quotes' L_eval '[[ "$1" != *\"* ]]' "$variable"
#    # much simpler and easier to quote than:
#    L_assert 'variable has quotes' "[[ ${variable@Q} == *\\\"* ]]"
L_eval() {
	local _L_f="$1"
	shift
	eval "$_L_f"
}


# @description Call the command in a subshell.
# @arg $@ Command to excute.
L_subshell() { ( "$@" ); }

if ((L_HAS_COMPGEN_V)); then
# @description Wrapper around compgen that does not support -V argument.
#
# @note `copmgen -W` allows execution. For example `compagen -W '$(echo something >&2)'`` executes echo.
#
# @option -V <var> Store the output in variable instead of printing it.
# @arg $@ Any other compgen options and arguments.
L_compgen() { compgen "$@"; }
else
	L_compgen() {
		case "$1" in
		-V)
			local _L_tmp
			if _L_tmp=$(trap - ERR; compgen "${@:3}"); then
				L_readarray "$2" <<<"$_L_tmp"
			else
				return "$?"
			fi
			;;
		-V*)
			local _L_tmp
			if _L_tmp=$(trap - ERR; compgen "${@:2}"); then
				L_readarray "${1#-V}" <<<"$_L_tmp"
			else
				return "$?"
			fi
			;;
		*) compgen "$@" ;;
		esac
	}
fi

# @description Return 0 if the argument is a function
# @arg $1 function name
L_function_exists() { declare -f "$@" >/dev/null; }

# @description Return 0 if the argument is a command.
# Consider using L_hash instead.
# This differs from L_hash in the presence of an alias.
# `command -v` detects aliases.
# `hash` detects actual executables in PATH and bash functions.
# @arg $@ commands names to check
# @see L_hash
L_command_exists() { command -v "$@" >/dev/null 2>&1; }

# @description Execute Bash hash builtin with silenced output.
# A typical mnemonic to check if a command exists is `if hash awk 2>/dev/null`.
# This saves to type the redirection.
#
# Why hash and not command or type?
# Bash stores all executed commands from PATH in hash.
# Indexing it here, makes the next call faster.
#
# @arg $@ commands to check
# @see L_command_exists
L_hash() { hash "$@" >/dev/null 2>&1; }

# @description Return 0 if current script is not sourced.
L_is_main() { ! L_is_sourced; }

# @description Return 0 if current script sourced.
# Comparing BASH_SOURCE to $0 only works, when BASH_SOURCE is different from $0.
# When calling `.` or `source` builtin it will be added as an "source" into `FUNCNAME` array.
# This function returns false, if there exists a source element in FUNCNAME array.
L_is_sourced() {
	local IFS=" "
	[[ " ${FUNCNAME[*]} " == *" source "* ]]
	# [[ "${BASH_SOURCE[0]}" != "$0" ]];
}

# @description Return true if sourced script was passed any arguments.
# When you source a script and do not pass any arguments, the arguments are equal to the parent scope.
#
#     $ set -- a b c ; source <(echo 'echo "$@"')          # script sourced with no arguments
#     a b c
#     $ set -- a b c ; source <(echo 'echo "$@"') d e f    # script sourced with arguments
#     d e f
#
# It is hard to detect if the script arguments are real arguments passed to `source` command or not.
# This function detect the case by checking for a command "source" in FUNCNAME.
#
# @example
#    if L_is_main; then
#       main
#       exit $?
#    elif L_has_sourced_arguments; then
#       sourced_main "$@"
#       return "$?"
#    else
#       sourced_main
#       return "$?"
#    fi
#
# @noargs
# @see https://stackoverflow.com/a/79201438/9072753
# @see https://stackoverflow.com/questions/61103034/avoid-command-line-arguments-propagation-when-sourcing-bash-script/73791073#73791073
# @see https://unix.stackexchange.com/questions/568747/bash-builtin-variables-bash-argv-and-bash-argc
L_has_sourced_arguments() {
	# Check if we are sourced.
	local IFS=' '
	if [[ " ${FUNCNAME[*]} " != *" source "* ]]; then
		return 2
	fi
	# Find the source function position.
	local i
	for i in "${!FUNCNAME[@]}"; do
		if [[ "${FUNCNAME[i]}" == "source" ]]; then
			break
		fi
	done
	[[ "${BASH_ARGV[0]:-}" != "${BASH_SOURCE[i]}" ]]
}

# @description Return 0 if running in bash shell.
# Portable with POSIX shell.
L_is_in_bash() { [ -n "${BASH_VERSION:-}" ]; }

# @description Return 0 if running in posix mode.
L_in_posix_mode() { case ":$SHELLOPTS:" in *:posix:*) ;; *) false ;; esac; }

# @description Return 0 if variable is set
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_set() { [[ -n "${!1+y}" ]]; }

# @description Return 0 if variable is set and is not null (not empty)
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_notnull() { [[ -n "${!1:+y}" ]]; }

# @description Serialize variable value to a string that can be declared.
#
# The result is a string that is the value of variable quoted
# in a format that can be reused as input to declare.
#
# For scalar variables, the function outputs a quoted value of the variable.
# For array and associative array variables, the function outputs
# a string in the form of `([a]=b)` that can be used to assign to another variable.
#
# Use `declare` with `-a` or `-A` for arrays to load the result into a variable.
# Eval is not preferred and might result in in valid values on Bash<4.4.
# Bash<4.4 prepends byte 0x01 in front of bytes 0x01 and 0x7f.
# Single 0x01 in declare -p output results in double 0x01,0x01.
#
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 <var> variable name
# @example
#    local -A map=([a]=b [c]=d)
#    L_var_to_string -v tmp map
#    declare -A map2=$tmp
# @see L_HAS_DECLARE_WITH_NO_QUOTES
# @see L_HAS_QEPAa_EXPANSIONS
# @see L_cache
L_var_to_string() { L_handle_v_scalar "$@"; }

if ((L_HAS_QEPAa_EXPANSIONS)); then
	# The set +u is needed when the variable is unset, but has attributes.
	# For example `declare -r var` makes `var` readonly without assigning any value to it.
	L_var_is_notarray() { local -; set +u; [[ -n "${!1+y}" && "${!1@a}" != *[aA]* ]]; }
	L_var_is_array() { local -; set +u; [[ "${!1@a}" == *a* ]]; }
	L_var_is_associative() { local -; set +u; [[ "${!1@a}" == *A* ]]; }
	L_var_is_readonly() { local -; set +u; [[ "${!1@a}" == *r* ]]; }
	L_var_is_integer() { local -; set +u; [[ "${!1@a}" == *i* ]]; }
	L_var_is_exported() { local -; set +u; [[ "${!1@a}" == *x* ]]; }

	L_var_to_string_v() {
		local -; set +u
		if [[ ${!1@a} == *[aA]* ]]; then
			# Indirect expansion with @A does not work in Bash5.0
			# We know $1 is a sane valid variable name, becuase above worked.
			eval "L_v=\${$1[@]@A}"
			# @A does not print =() empty arrays assignment. Fix that.
			if [[ "$L_v" != *" $1=("* ]]; then
				L_v="()"
			else
				L_v="${L_v#*=}"
			fi
		else
			# Non array variable.
			printf -v L_v "%q" "${!1}"
		fi
	}
else

# @description Return 0 if variable is not an array neither an associative array.
# @arg $1 variable nameref
L_var_is_notarray() { [[ "$(declare -p "$1" 2>/dev/null || :)" == declare\ -[^aA]* ]]; }

# @description Return 0 if variable is an indexed integer array, not an associative array.
# @arg $1 variable nameref
L_var_is_array() { [[ "$(declare -p "$1" 2>/dev/null || :)" == declare\ -a* ]]; }

# @description Return 0 if variable is an associative array.
# @arg $1 variable nameref
L_var_is_associative() { [[ "$(declare -p "$1" 2>/dev/null || :)" == declare\ -A* ]]; }

# @description Return 0 if variable is readonly.
# @arg $1 variable nameref
L_var_is_readonly() { [[ "$(declare -p "$1" 2>/dev/null || :)" =~ ^declare\ -[A-za-z]*r ]]; }

# @description Return 0 if variable has integer attribute set.
# @arg $1 variable nameref
L_var_is_integer() { [[ "$(declare -p "$1" 2>/dev/null || :)" =~ ^declare\ -[A-Za-z]*i ]]; }

# @description Return 0 if variable is exported.
# @arg $1 variable nameref
L_var_is_exported() { [[ "$(declare -p "$1" 2>/dev/null || :)" =~ ^declare\ -[A-Za-z]*x ]]; }

L_var_to_string_v() {
	L_v=$(LC_ALL=C declare -p "$1") || return 2
	# If it is an array or associative array.
	if [[ "$L_v" == declare\ -[aA]* && "${L_v#*=}" == \'\(*\)\' ]]; then
  	# Remove one level of quoting.
  	eval "L_v=${L_v#*=}"
		# Fix erroneus \001 in front of every \177 and \001.
  	L_v=${L_v//$'\001\001'/$'\001'}
  	L_v=${L_v//$'\001\177'/$'\177'}
  else
		printf -v L_v "%q" "${!1}"
  fi
}

fi

if ((L_HAS_PRINTF_V_ARRAY)); then
# shellcheck disable=SC2059
# @description Append to the first argument if first argument is not null.
# If first argument is an empty string, print the line.
# Used by functions optically taking a -v argument or printing to stdout,
# when such functions want to append the printf output to a variable
# for example in a loop or similar.
# @arg $1 variable to append to or empty string
# @arg $2 printf format specification
# @arg $@ printf arguments
# @example
#   func() {
#     local var=
#     if [[ "$1" == -v ]]; then
#        var=$2
#        shift 2
#     fi
#     L_printf_append "$var" "%s" "Hello "
#     L_printf_append "$var" "%s" "world\n"
#   }
#   func          # prints hello world
#   func -v var   # stores hello world in $v
# shellcheck disable=SC2059
L_printf_append() {
	printf ${1:+"-v$1"} ${1:+"%s"}"$2" ${1:+"${!1:-}"} "${@:3}"
}
else
	# shellcheck disable=SC2059
	L_printf_append() {
		if [[ "${1:-}" == *"["* ]]; then
			L_assert "not a valid identifier: $1" L_is_valid_variable_or_array_element "$1"
			local _L__tmp
			printf -v _L__tmp "${@:2}"
			eval "$1+=\$_L__tmp"
		else
			printf ${1:+"-v$1"} ${1:+"%s"}"$2" ${1:+"${!1:-}"} "${@:3}"
		fi
	}
fi

# @description Generate uuid in bash.
# @option -v <var> Store the output in variable instead of printing it.
# @see https://digitalbunker.dev/understanding-how-uuids-are-generated/
L_uuid4() { L_handle_v_scalar "$@"; }
L_uuid4_v() {
	# Generate 128 random bits
	# RANDOM has 16 bits. 128/16=8
	# SRANDOM has 32 bits. 128/32=4
	# Take the 7th byte and perform an AND operation with 0x0F to clear out the high nibble.
	# Then, OR it with 0x40 to set the version number to 4.
	# Next, take the 9th byte and perform an AND operation with 0x3F and then OR it with 0x80.
	# Convert the 128 bits to hexadecimal representation and insert the hyphens to achieve the canonical text representation.
	if ((L_HAS_SRANDOM)); then
		printf -v L_v "%08x%08x%08x%08x" \
			"$SRANDOM" "$(( SRANDOM & 0x3FFFFFFF | 0x40000000 ))" "$SRANDOM" "$SRANDOM"
	elif L_hash uuidgen; then
		L_v=$(uuidgen)
		return
	else
		printf -v L_v "%04x%04x%04x%04x""%04x%04x%04x%04x" \
			"$RANDOM" "$RANDOM" "$(( RANDOM & 0x3FFF | 0x4000 ))" "$RANDOM" \
			"$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM"
	fi
	L_v=${L_v::8}-${L_v:8:4}-4${L_v:13:3}-${L_v:16:4}-${L_v:20}
}

# @description Print date in the format.
# If the format string contains %N or the timepoint is not a number, use date command.
# Otherwise, try to use printf %(fmt)T.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and exit.
# @arg $1 Format string.
# @arg [$2] Optional timepoint.
L_date() { L_handle_v_scalar "$@"; }
L_date_v() {
	# Support python %f.
	L_v=${1//%f/%6N}
	# If the format string contains %N or the timestamp is not seconds since epoch.
	if [[ "$L_v" =~ (^|[^%])%[0-9]*N ]]; then
		if ! _L_has_date_N; then
			local _L_now
			L_epochrealtime_usec -v _L_now
			while [[ "$L_v" =~ (^|(.*[^%]))%([0-9]*)N(.*) ]]; do
				printf -v L_v "%s%0${BASH_REMATCH[3]:-9}d%s" \
					"${BASH_REMATCH[2]}" \
					"$(( 10#${_L_now:${#_L_now}-6}000 / 10**( 9 - ${BASH_REMATCH[3]:-9} ) ))" \
					"${BASH_REMATCH[4]}"
			done
		fi
		L_v=$(date ${2:+-d"$2"} +"$L_v")
	elif ((!L_HAS_PRINTF_T)) || [[ "${2:-}" == *[^0-9]* ]]; then
		L_v=$(date ${2:+-d"$2"} +"$L_v")
	else
		printf -v L_v "%($L_v)T" "${2:--1}"
	fi
}

# @description Return success if date supports %N option.
_L_has_date_N() {
	local tt
	if L_hash date && tt=$(date --help 2>&1) && [[ "$tt" == *" %N "* ]]; then
		_L_has_date_N() { return 0; }
	else
		_L_has_date_N() { return 1; }
	fi
	_L_has_date_N
}

# @description Return time in microseconds.
# The dot or comma is removed from EPOCHREALTIME.
# Uses EPOCHREALTIME in newer Bash.
# In older Bash tries GNU date, gdate, perl, /proc/uptime, python, busybox adjtimex.
# @option -v <var>
L_epochrealtime_usec() { L_handle_v_scalar "$@"; }
L_epochrealtime_usec_v() {
	# Pick the best method available.
	if ((L_HAS_EPOCHREALTIME)); then
		L_epochrealtime_usec_v() { L_v=${EPOCHREALTIME//[,.]}; }
	elif _L_has_date_N; then
		L_epochrealtime_usec_v() { L_v=$(date +%s%6N); }
	elif L_hash gdate; then
		L_epochrealtime_usec_v() { L_v=$(gdate +%s%6N); }
	elif L_hash perl; then
		L_epochrealtime_usec_v() { L_v=$(perl -MTime::HiRes=gettimeofday -e 'printf "%d%06d", gettimeofday'); }
	elif [[ -r /proc/uptime ]]; then
		L_epochrealtime_usec_v() { L_v=$(< /proc/uptime) && L_sec_to_usec_v "${L_v// *}"; }
	elif L_hash busybox; then
		L_epochrealtime_usec_v() {
			# https://elixir.bootlin.com/busybox/1.37.0/source/miscutils/adjtimex.c#L123
			L_v=$(busybox adjtimex)
			# https://github.com/torvalds/linux/blob/50c19e20ed2ef359cf155a39c8462b0a6351b9fa/include/uapi/linux/timex.h#L187
			local status=${L_v##*status:} sec=${L_v##*time.tv_sec:} usec=${L_v##*time.tv_usec:} STA_NANO=0x2000
			L_lstrip_v "$sec"; sec=$L_v
			L_lstrip_v "$usec"; usec=$L_v
			L_lstrip_v "$status"; status=$L_v
			sec=${sec%%[$' \t\n']*} usec=${usec%%[$' \t\n']*} status=${status%%[$' \t\n']*}
			printf -v "L_v" "%d%06d" "$sec" "$(( (status & STA_NANO) ? ( usec / 1000 ) : usec ))"
		}
	elif L_hash python3; then
		L_epochrealtime_usec_v() { L_v=$(python -c 'import time; print(int(time.time() * 1000000))'); }
	else
		return 1
	fi
	"${FUNCNAME[0]}"
}

# @description Convert float seconds to microseconds.
# @option -v <var>
# @example  L_sec_to_usec 1.5 -> 1500000
L_sec_to_usec() { L_handle_v_scalar "$@"; }
L_sec_to_usec_v() {
	case "$1" in
	*.*) printf -v L_v "%s%.6s" "${1%%.*}" "${1##*.}000000" && L_v=$(( 10#$L_v )) ;;
	*) L_v="$(( 10#${1}000000 ))" ;;
	esac
}

# @description Convert microseconds to seconds with 6 digits after comma.
# @option -v <var>
L_usec_to_sec() { L_handle_v_scalar "$@"; }
L_usec_to_sec_v() {
	printf -v L_v "%d.%06d" "$(( $1 / 1000000 ))" "$(( $1 % 1000000 ))"
}

# @description Calculate timeout value.
# The timeout value is stored in microseconds.
# @arg $1 Variable to assign with the timeout value in usec.
# @arg $2 Timeout in seconds. May be a fraction.
# @see L_epochrealtime_usec
# @note should this be L_timeout_assign -v ?
L_timeout_set_to() {
	local _L__now L_v
	L_epochrealtime_usec -v _L__now &&
	L_sec_to_usec_v "$2" &&
	printf -v "$1" "%s" "$(( ${_L__now//.} + 10#${L_v//.} ))"
}

# @description Is the timeout expired?
# @arg $1 timeout value
L_timeout_expired() {
	local L_v
	L_epochrealtime_usec_v &&
	(( ${L_v//.} >= $1 ))
}

# @description Get the number of seconds left in the timer.
# @option -v <var>
# @arg $1 timeout value
L_timeout_left() { L_handle_v_scalar "$@"; }
L_timeout_left_v() {
	L_epochrealtime_usec_v &&
	L_v=$(( $1 - ${L_v//.} )) &&
	L_usec_to_sec_v "$L_v"
}

# ]]]
# exit_to [[[
# @section exit_to

# @description store exit status of a command to a variable
# @arg $1 variable
# @arg $@ command to execute
L_exit_to() {
	if "${@:2}"; then
		printf -v "$1" 0
	else
		# shellcheck disable=2059
		printf -v "$1" "$?"
	fi
}

# @description convert exit code to the word yes or to nothing
# @arg $1 variable
# @arg $@ command to execute
# @example
#     L_exit_to_1null suceeded test "$#" = 0
#     echo "${suceeded:+"SUCCESS"}"  # prints SUCCESS or nothing
L_exit_to_1null() {
	if "${@:2}"; then
		printf -v "$1" "1"
	else
		printf -v "$1" "%s" ""
	fi
}

# @description convert exit code to the word yes or to unset variable
# @arg $1 variable
# @arg $@ command to execute
# @example
#     L_exit_to_1null suceeded test "$#" = 0
#     echo "${suceeded:+"SUCCESS"}"  # prints SUCCESS or nothing
L_exit_to_1unset() {
	if "${@:2}"; then
		printf -v "$1" "1"
	else
		unset -v "$1"
	fi
}

# @description store 1 if command exited with 0, store 0 if command exited with nonzero
# @arg $1 variable
# @arg $@ command to execute
L_exit_to_10() {
	if "${@:2}"; then
		printf -v "$1" 1
	else
		printf -v "$1" 0
	fi
}

# ]]]
# path [[[
# @section path

# @description The filename
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
L_path_basename() { L_handle_v_scalar "$@"; }
L_path_basename_v() { L_v=${*##*/}; }

# @description parent of the path
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
L_path_dirname() { L_handle_v_scalar "$@"; }
L_path_dirname_v() {
	case "$*" in
	..) L_v=. ;;
	?*/*) L_v=${*%/*} ;;
	/*) L_v=/ ;;
	*) L_v=. ;;
	esac
}

# @description The last dot-separated portion of the final component, if any.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
# @see https://en.cppreference.com/w/cpp/filesystem/path/extension.html
L_path_extension() { L_handle_v_scalar "$@"; }
L_path_extension_v() {
	L_path_basename_v "$*"
	case $L_v in
	.|..) L_v="" ;;
	?*.*) L_v=.${L_v##*.} ;;
	*) L_v="" ;;
	esac
}

# @description A list of the path’s suffixes, often called file extensions.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
# @see https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.suffixes
L_path_extensions() { L_handle_v_array "$@"; }
L_path_extensions_v() {
	L_path_basename_v "$*"
	case $L_v in
	.|..) L_v=() ;;
	?*.*)
		IFS=. read -r -d '' -a L_v <<<"$L_v" || :
		# Remove additional newline from <<< from last element.
		L_v[${#L_v[@]}-1]=${L_v[${#L_v[@]}-1]%$'\n'}
		# Remove basename.
		unset -v 'L_v[0]'
		# Add dots
		L_v=("${L_v[@]/#/.}")
		;;
	*) L_v=() ;;
	esac
}

# @description The final path component, without its suffix:
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
# @see https://en.cppreference.com/w/cpp/filesystem/path/stem
L_path_stem() { L_handle_v_scalar "$@"; }
L_path_stem_v() {
	L_path_basename_v "$*"
	case $L_v in
	.|..) ;;
	?*.*) L_v=${L_v%.*} ;;
	esac
}

# @description Return a new path with the name changed.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
# @arg $1 new name
L_path_with_name() { L_handle_v_scalar "$@"; }
L_path_with_name_v() {
	case "$1" in
	..) L_v=$2 ;;
	?*/*) L_v=${1%/*}/$2 ;;
	/*) L_v=/$2 ;;
	*) L_v=$2 ;;
	esac
}

# @description Return a new path with the stem changed.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
# @arg $2 new stem
L_path_with_stem() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2179
L_path_with_stem_v() {
	L_path_extension_v "$1"
	L_path_with_name_v "$1" "$2$L_v"
}

# @description Return a new path with the suffix changed.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
# @arg $2 new suffix
L_path_with_suffix() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2179
L_path_with_suffix_v() {
	L_path_stem_v "$1"
	L_path_with_name_v "$1" "$L_v${2:+.${2#.}}"
}

# @description Return whether the path is absolute or not.
L_path_is_absolute() { [[ "${1::1}" == / ]]; }

# @description Replace multiple slashes by one slash.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 path
L_path_normalize() { L_shopt_extglob L_handle_v_scalar "$@"; }
# shellcheck disable=SC2064
L_path_normalize_v() { L_v=${1//\/+(\/)/\/}; }

# @description Compute a version of the original path relative to the path represented by other path.
# This method is string-based.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 original path
# @arg $2 other path
# @see https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.relative_to
# @see https://stackoverflow.com/a/12498485/9072753
L_path_relative_to() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2179
L_path_relative_to_v() {
	if (($# != 2)); then
		L_func_error "invalid number of arguments" 2
		return 2
	fi
	local _L_current="${1:+"$2"}"
	local _L_target="${1:-"$2"}"
	if [[ "$_L_target" == . ]]; then
		_L_target=/
	else
		_L_target="/${_L_target##/}"
	fi
	if [[ "$_L_current" == . ]]; then
		_L_current=/
	else
		_L_current="${_L_current:="/"}"
		_L_current="/${_L_current##/}"
	fi
	local _L_appendix="${_L_target##/}"
	L_v=''
	while
		_L_appendix="${_L_target#"$_L_current"/}"
		[[ "$_L_current" != '/' && "$_L_appendix" == "$_L_target" ]]
	do
		if [ "$_L_current" = "$_L_appendix" ]; then
			L_v="${L_v:-.}"
			L_v="${L_v#/}"
			return 0
		fi
		_L_current="${_L_current%/*}"
		L_v+="${L_v:+/}.."
	done
	L_v+="${L_v:+${_L_appendix:+/}}${_L_appendix#/}"
}

# @description Check if a path is relative to other path.
# This method is string-based; it neither accesses the filesystem nor treats “..” segments specially.
# Consider as alternative: L_path_relative_to -v tmp "$1" "$2" && [[ "$tmp" == ../* ]]
# @arg $1 Path to check
# @arg $2 Path that $1 should be relative to.
# @example
#    L_path_is_relative_to /etc/passwd /etc  # return 0
#    L_path_is_relative_to /etc/passwd /usr  # return 1
L_path_is_relative_to() { [[ "$1" == "$2"* ]]; }

# @description Append a path to path variable if not already there.
# @arg $1 Variable name. For example PATH
# @arg $2 Path to append. For example /usr/bin
# @arg [$3] Optional path separator. Default: ':'
# @example L_path_append PATH ~/.local/bin
L_path_append() {
	case "${3:-:}${!1}${3:-:}" in
	*"${3:-:}$2${3:-:}"*) ;;
	*) printf -v "$1" "%s" "${!1}${3:-:}$2"
	esac
}

# @description Prepend a path to path variable if not already there.
# @arg $1 Variable name. For example PATH
# @arg $2 Path to prepend. For example /usr/bin
# @arg [$3] Optional path separator. Default: ':'
# @example L_path_append PATH ~/.local/bin
L_path_prepend() {
	case "${3:-:}${!1}${3:-:}" in
	*"${3:-:}$2${3:-:}"*) ;;
	*) printf -v "$1" "%s" "$2${3:-:}${!1}"
	esac
}

# @description Remove a path from a path variable.
# @arg $1 Variable name. For example PATH
# @arg $2 Path to prepend. For example /usr/bin
# @arg [$3] Optional path separator. Default: ':'
# @example L_path_append PATH ~/.local/bin
L_path_remove() {
	case "${!1}" in
	"$2${3:-:}"*) printf -v "$1" "%s" "${!1#"$2${3:-:}"}"; L_path_remove "$@"; ;;
	*"${3:-:}$2") printf -v "$1" "%s" "${!1%"${3:-:}$2"}"; L_path_remove "$@"; ;;
	*"${3:-:}$2${3:-:}"*) printf -v "$1" "%s" "${!1//"${3:-:}$2${3:-:}"/${3:-:}}"; L_path_remove "$@"; ;;
	"$2") printf -v "$1" "%s" "" ;;
	esac
}

# @description Return 0 if a directory is empty.
# @arg $1 Directory.
L_dir_is_empty() {
	test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"
}

# ]]]
# string [[[
# @section string
# @description Collection of functions to manipulate strings.

# @description Return 0 if the string happend to be something like true.
# Return 0 when argument is case-insensitive:
#  - true
#  - 1
#  - yes
#  - y
#  - t
#  - any number except 0
#  - the character '+'
# @arg $1 str
L_is_true() { [[ "$1" == [+1-9TtYy]* ]]; }
# L_is_true() { L_regex_match "$1" "^([+]|[+]?[1-9][0-9]*|[tT]|[tT][rR][uU][eE]|[yY]|[yY][eE][sS])$"; }

# @description Return 0 if the string happend to be something like false.
# Return 0 when argument is case-insensitive:
#  - false
#  - 0
#  - no
#  - F
#  - n
#  - the character minus '-'
# @arg $1 str
L_is_false() { [[ "$1" == [-0fFnN]* ]]; }
# L_is_false() { L_regex_match "$1" "^([-]|0+|[fF]|[fF][aA][lL][sS][eE]|[nN]|[nN][oO])$"; }

# L_is_true() { [[ "$1" == @(+|[1-9]*([0-9])|[tT]|[tT][rR][uU][eE]|[yY]|[yY][eE][sS]) ]]; }
# L_is_false() { [[ "$1" == @(-|+(0)|[fF]|[fF][aA][lL][sS][eE]|[nN]|[nN][oO]) ]]; }
# L_is_true() { case "$1" in +|[1-9]|[tT]|[tT][rR][uU][eE]|[yY]|[yY][eE][sS]) ;; *) false ;; esac; }
# L_is_false() { case "$1" in -|0|[fF]|[fF][aA][lL][sS][eE]|[nN]|[nN][oO]) ;; *) false ;; esac; }

# @description Return 0 if the string happend to be something like true in locale.
# @arg $1 str
L_is_true_locale() {
	local i
	i=$(locale yesexpr)
	[[ "$1" =~ $i ]]
}

# @description Return 0 if the string happend to be something like false in locale.
# @arg $1 str
L_is_false_locale() {
	local i
	i=$(locale noexpr)
	[[ "$1" =~ $i ]]
}

# @description Return 0 if all characters in string are printable
# @arg $1 string to check
L_isprint() { [[ "$*" != *[^[:print:]]* ]]; }

# @description Return 0 if all string characters are digits
# @arg $1 string to check
L_isdigit() { [[ "$*" != *[^0-9]* ]]; }

# @description Return 0 if argument could be a variable name.
# This function is used to make sure that eval "$1=" will e correct if L_is_valid_variable_name "$1".
# @arg $1 string to check
# @see L_is_valid_variable_or_array_element
L_is_valid_variable_name() { [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; }
# L_is_valid_variable_name() { [[ ${1:0:1} == [a-zA-Z_] && ( ${#1} == 1 || ${1:1} != *[^a-zA-Z0-9_]* ) ]]; }
# L_is_valid_variable_name() { [[ $1 == [a-zA-Z_]*([a-zA-Z0-9_]) ]]; }

# @description Return 0 if argument could be a variable name or array element.
# @arg $1 string to check
# @see L_is_valid_variable_name
# @example
#	L_is_valid_variable_or_array_element aa           # true
#	L_is_valid_variable_or_array_element 'arr[elem]'  # true
#	L_is_valid_variable_or_array_element 'arr[elem'   # false
L_is_valid_variable_or_array_element() { [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*(\[.+\])?$ ]]; } # ]

# @description Is the string a valid Bash opinionated function name?
# Almost anything is valid Bash function name.
# @arg $1 string to check
# @see https://stackoverflow.com/a/44041384/9072753
# @see https://stackoverflow.com/a/69292370/9072753
L_is_valid_function_name() {
	[[ "$1" =~ ["!*+,-./:=?@A-Z\[\]^_a-z{}~"]["#%0-9!*+,-./:=?@A-Z\[\]^_a-z{}~"]* ]]
	# [[ "$1" =~ [a-zA-Z_][0-9a-zA-Z_]* ]]
  # [[ "$1" =~ ^[^$'\x01\x7f\t\n '"!\"#$%\'()*0-9\;<>\\\`{|}"][^$'\x01\x7f\t\n '"\"$&\'();<>[\\\`|"]*$ && "$1" == *[^0-9]* ]];
}

# @description Return 0 if the string characters is an integer
# @arg $1 string to check
L_is_integer() { [[ "$1" =~ ^[-+]?[0-9]+$ ]]; }
# L_is_integer() { [[ $1 != *[^0-9]* || ( ${#1} -gt 1 && ${1:0:1} == [-+] && ${1:1} != *[^0-9]* ) ]]; }
# L_is_integer() { [[ $1 == ?([+-])+([0-9]) ]]; }

# @description Return 0 if the string characters is a float
# @arg $1 string to check
L_is_float() { [[ "$1" =~ ^[+-]?([0-9]*[.]?[0-9]+|[0-9]+[.])$ ]]; }
# L_is_float() { [[ "$*" == ?([+-])@(+([0-9])?(.)|*([0-9]).+([0-9])) ]]; }

# @description newline
L_NL=$'\n'
# @description tab
L_TAB=$'\t'
# @description Start of heading
L_SOH=$'\001'
# @description Start of text
L_STX=$'\002'
# @description End of Text
L_EOT=$'\003'
# @description End of transmission
L_EOF=$'\004'
# @description Enquiry
L_ENQ=$'\005'
# @description Acknowledge
L_ACK=$'\006'
# @description Bell
L_BEL=$'\007'
# @description Backspace
L_BS=$'\010'
# @description Horizontal Tab
L_HT=$'\011'
# @description Line Feed
L_LF=$'\012'
# @description Vertical Tab
L_VT=$'\013'
# @description Form Feed
L_FF=$'\014'
# @description Carriage Return
L_CR=$'\015'
# @description Shift Out
L_SO=$'\016'
# @description Shift In
L_SI=$'\017'
# @description Data Link Escape
L_DLE=$'\020'
# @description Device Control 1
L_DC1=$'\021'
# @description Device Control 2
L_DC2=$'\022'
# @description Device Control 3
L_DC3=$'\023'
# @description Device Control 4
L_DC4=$'\024'
# @description Negative Acknowledge
L_NAK=$'\025'
# @description Synchronous Idle
L_SYN=$'\026'
# @description End of Transmission Block
L_ETB=$'\027'
# @description Cancel
L_CAN=$'\030'
# @description End of Medium
L_EM=$'\031'
# @description Substitute
L_SUB=$'\032'
# @description Escape
L_ESC=$'\033'
# @description File Separator
L_FS=$'\034'
# @description Group Separator
L_GS=$'\035'
# @description Record Separator
L_RS=$'\036'
# @description Unit Separator
L_US=$'\037'
# @description Delete
L_DEL=$'\177'
# @description Left brace character
L_LBRACE='{'
# @description Right brace character
L_RBRACE='}'
# @description Looks random.
# @see L_uuid4
L_UUID=921c7f46-e0d8-4170-91e9-7055ee30d1e2
# @description 255 bytes with all possible 255 values
L_ALLCHARS=$'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
# @description All lowercase characters a-z
L_ASCII_LOWERCASE="abcdefghijklmnopqrstuvwxyz"
# @description All uppercase characters A-Z
L_ASCII_UPPERCASE="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# @description The GPL3 or later License notice.
# @see https://www.gnu.org/licenses/gpl-howto.en.html#license-notices
L_GPL_LICENSE_NOTICE_3_OR_LATER="\
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"

# @description notice that the software is a free software.
L_FREE_SOFTWARE_NOTICE="\
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."

# @description Output a string with the same quotating style as does bash in set -x
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ arguments to quote
L_quote_setx() { L_handle_v_scalar "$@"; }
L_quote_setx_v() {
	L_v=$(
		{ BASH_XTRACEFD=2 PS4='+ '; set -x; } 2>/dev/null >&2
		{ : "$@"; } 2>&1
	)
	L_v=${L_v#* }
	L_v=${L_v:2}
}

# @description Output a string with the same quotating style as does bash with printf
# For single argument, just use `printf -v var "%q" "$var"`.
# Use this for more arguments, like `printf -v var "%q " "$@"` results in a trailing space.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ arguments to quote
L_quote_printf() { L_handle_v_scalar "$@"; }
L_quote_printf_v() { printf -v L_v " %q" "$@"; L_v=${L_v:1}; }

# @description Output a string with the same quotating style as does /bin/printf
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ arguments to quote
L_quote_bin_printf() { L_handle_v_scalar "$@"; }
L_quote_bin_printf_v() { L_v=$(exec printf " %q" "$@"); L_v=${L_v:1}; }

# @description Convert a string to a number.
# @option -v <var> Store the output in variable instead of printing it.
L_strhash() { L_handle_v_scalar "$@"; }
L_strhash_v() {
	if L_hash cksum; then
		L_v=$(cksum <<<"$*")
		L_v=${L_v%% *}
	elif L_hash sum; then
		L_v=$(sum <<<"$*")
		L_v=${L_v%% *}
	elif L_hash shasum; then
		L_v=$(shasum <<<"$*")
		L_v=${L_v::15}
		L_v=$((0x1$L_v))
	else
		L_strhash_bash -v L_v "$*"
	fi
}

# @description Convert a string to a number in pure bash.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 string
L_strhash_bash() { L_handle_v_scalar "$@"; }
L_strhash_bash_v() {
	local _L_c
	L_v=0
	while IFS= read -r -d '' -n 1 _L_c; do
		printf -v _L_c "%d" "'$_L_c"
		L_v=$(( _L_c + 31 * L_v ))
	done <<<"$1"
}

# @description Check if string contains substring.
# @arg $1 string
# @arg $2 substring
L_strstr() {
	[[ "$1" == *"$2"* ]]
}

# @description
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 String to operate on.
L_strupper() { L_handle_v_scalar "$@"; }

# @description
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 String to operate on.
L_strlower() { L_handle_v_scalar "$@"; }

# @description Capitalize first character of a string.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 String to operate on
L_capitalize() { L_handle_v_scalar "$@"; }

# @description Lowercase first character of a string.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 String to operate on
L_uncapitalize() { L_handle_v_scalar "$@"; }

if ((L_HAS_LOWERCASE_UPPERCASE_EXPANSION)); then
	L_strupper_v() { L_v=${1^^}; }
	L_strlower_v() { L_v=${1,,}; }
	L_capitalize_v() { L_v=${1^[a-z]}; }
	L_uncapitalize_v() { L_v=${1,[A-Z]}; }
else
	L_strupper_v() {
		L_v=${1//a/A}
		L_v=${L_v//b/B}
		L_v=${L_v//c/C}
		L_v=${L_v//d/D}
		L_v=${L_v//e/E}
		L_v=${L_v//f/F}
		L_v=${L_v//g/G}
		L_v=${L_v//h/H}
		L_v=${L_v//i/I}
		L_v=${L_v//j/J}
		L_v=${L_v//k/K}
		L_v=${L_v//l/L}
		L_v=${L_v//m/M}
		L_v=${L_v//n/N}
		L_v=${L_v//o/O}
		L_v=${L_v//p/P}
		L_v=${L_v//q/Q}
		L_v=${L_v//r/R}
		L_v=${L_v//s/S}
		L_v=${L_v//t/T}
		L_v=${L_v//u/U}
		L_v=${L_v//v/V}
		L_v=${L_v//w/W}
		L_v=${L_v//x/X}
		L_v=${L_v//y/Y}
		L_v=${L_v//z/Z}
	}
	L_strlower_v() {
		L_v=${1//A/a}
		L_v=${L_v//B/b}
		L_v=${L_v//C/c}
		L_v=${L_v//D/d}
		L_v=${L_v//E/e}
		L_v=${L_v//F/f}
		L_v=${L_v//G/g}
		L_v=${L_v//H/h}
		L_v=${L_v//I/i}
		L_v=${L_v//J/j}
		L_v=${L_v//K/k}
		L_v=${L_v//L/l}
		L_v=${L_v//M/m}
		L_v=${L_v//N/n}
		L_v=${L_v//O/o}
		L_v=${L_v//P/p}
		L_v=${L_v//Q/q}
		L_v=${L_v//R/r}
		L_v=${L_v//S/s}
		L_v=${L_v//T/t}
		L_v=${L_v//U/u}
		L_v=${L_v//V/v}
		L_v=${L_v//W/w}
		L_v=${L_v//X/x}
		L_v=${L_v//Y/y}
		L_v=${L_v//Z/z}
	}
	L_capitalize_v() { L_strupper_v "${1:0:1}"; L_v="$L_v${1:1}"; }
	L_uncapitalize_v() { L_strlower_v "${1:0:1}"; L_v="$L_v${1:1}"; }
fi

# @description Remove characters from IFS from begining and end of string
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 <str> String to operate on.
# @arg [$2] <str> Optional glob to strip, default is [:space:]
L_strip() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2295
L_strip_v() {
	L_v=${1#"${1%%[!${2:-[:space:]}]*}"}
	L_v="${L_v%"${L_v##*[!${2:-[:space:]}]}"}"
}

# @description Remove characters from IFS from begining of string
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 <str> String to operate on.
# @arg [$2] <str> Optional glob to strip, default is [:space:]
L_lstrip() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2295
L_lstrip_v() {
	L_v="${1#"${1%%[!${2:-[:space:]}]*}"}"
}

# @description Remove characters from IFS from begining of string
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 String to operate on.
# @arg [$2] <str> Optional glob to strip, default is [:space:]
L_rstrip() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2295
L_rstrip_v() {
	# shellcheck disable=SC2295
	L_v="${1%"${1##*[!${2:-[:space:]}]}"}"
}

# @description list functions with prefix
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 prefix
L_list_functions_with_prefix() { L_handle_v_array "$@"; }

L_list_functions_with_prefix_v() {
	L_compgen -V L_v -A function -- "$1"
}

# @description list functions with prefix and remove the prefix
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 prefix
# @see L_list_functions_with_prefix
L_list_functions_with_prefix_removed() { L_handle_v_array "$@"; }
L_list_functions_with_prefix_removed_v() {
	L_list_functions_with_prefix_v "$1"
	local _L_len=${L_v:+${#L_v[@]}}
	# Fix a bug on Bash4.0
	L_v=(${L_v[@]+"${L_v[@]/#"$1"}"})
	if ((_L_len != ${#L_v[@]})); then
		L_v+=("")
	fi
}

# @description Choose elements matching prefix.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 prefix
# @arg $@ elements
L_abbreviation() { L_handle_v_array "$@"; }
L_abbreviation_v() {
	local _L_cur=$1
	shift
	if [[ "${*//[$' \t\n'"\"'"]}" == "$*" ]]; then
		if ! L_compgen -V L_v -W "$*" -- "$_L_cur"; then
			L_v=()
		fi
	else
		L_v=()
		while (($#)); do
			if [[ "$1" == "$_L_cur"* ]]; then
				L_v+=("$1")
			fi
			shift
		done
	fi
}

# @description compare two float numbers
# The '<=>' operator returns 9 when $1 < $2, 10 when $1 == $2 and 11 when $1 > $2.
# @arg $1 <float> one number
# @arg $2 <str> operator, one of -lt -le -eq -ne -gt -ge > >= == != <= < <=>
# @arg $3 <float> second number
# @example
#    L_float_cmp 123.234 -le 234.345
#    echo $?  # outputs 0
#    L_exit_to ret L_float_cmp 123.234 -le 234.345
#    echo "$ret"  # outputs 0
L_float_cmp() {
	local a1 a2 b1 b2 _ IFS=',.' r
	read -r a1 a2 _ <<<"$1"
	read -r b1 b2 _ <<<"$3"
	if ((${#a2} < ${#b2})); then
		printf -v a2 "%-*s" "${#b2}" "$a2"
		a2=${a2// /0}
	elif ((${#a2} > ${#b2})); then
		printf -v b2 "%-*s" "${#a2}" "$b2"
		b2=${b2// /0}
	fi
	local r=$(( 10#${a1:-0} < 10#${b1:-0} ? -1 : 10#${a1:-0} > 10#${b1:-0} ? 1 : 10#${a2:-0} < 10#${b2:-0} ? -1 : 10#${a2:-0} > 10#${b2:-0} ? 1 : 0 ))
	# echo "$a1.$a2 $2 $b1.$b2 = $r"
	case "$2" in
	-lt|'<')  ((r == -1));;
	-le|'<=') ((r <= 0));;
	-eq|'==') ((r == 0));;
	-ne|'!=') ((r));;
	-ge|'>=') ((r >= 0));;
	-gt|'>') ((r > 0));;
	'<=>') return "$((r + 10))" ;;
	*) return 255;;
	esac
}

# @description A simple wrapper script around awk to evaluate float expressions.
# @arg $1 Expression to evaluate.
L_float() {
	awk "BEGIN{print ($1);exit}" <&-
}

# @description Print a string with percent format.
# Simple implementation of percent formatting in bash using regex and printf.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 format string
# @arg $@ arguments
# @example
#   name=John
#   declare -A age=([John]=42)
#   L_percent_format "Hello, %(name)s! You are %(age[John])10s years old.\n"
L_percent_format() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2059
L_percent_format_v() {
	local _L_fmt=$1 _L_args=("")
	while [[ -n "$_L_fmt" && "$_L_fmt" =~ ^(([^%]*(%%)*[^%]*)*)(%\(([^\)]+)\)([^a-zA-Z]*[a-zA-Z]))?(.*)$ ]]; do
		#                                    12     3            4   5         6                     7
		if [[ "$_L_fmt" == "${BASH_REMATCH[7]}" ]]; then
			L_func_error "invalid format specification: $1" 2; return 2
		fi
		_L_fmt="${BASH_REMATCH[7]}"
		if [[ -n "${BASH_REMATCH[1]}" ]]; then
			_L_args[0]+="${BASH_REMATCH[1]}"
		fi
		if [[ -n "${BASH_REMATCH[5]}" ]]; then
			_L_args[0]+="%${BASH_REMATCH[6]}"
			_L_args+=("${!BASH_REMATCH[5]}")
		fi
	done
	printf -v L_v "${_L_args[@]}"
}

# @description print a string with f-string format
# A simple implementation of f-strings in bash using regex and printf.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 format string
# @example
#  name=John
#  declare -A age=([John]=42)
#  L_fstring 'Hello, {name}! You are {age[John]:10s} years old.\n'
L_fstring() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC2059
L_fstring_v() {
	local _L_fmt="$*" _L_args=("") _L_tmp
	while [[ -n "$_L_fmt" && "$_L_fmt" =~ ^(([^{}]*([{][{]|[}][}])*[^{}]*)*)([{]([^:}]+)(:([^}]*))?[}])?(.*) ]]; do
		#                                    12      3                        4   5       6 7             8
		if [[ "$_L_fmt" == "${BASH_REMATCH[8]}" ]]; then
			L_func_error "invalid format specification: $1" 2; return 2
		fi
		_L_fmt="${BASH_REMATCH[8]}"
		if [[ -n "${BASH_REMATCH[1]}" ]]; then
			_L_tmp="${BASH_REMATCH[1]//$L_LBRACE$L_LBRACE/$L_LBRACE}"
			_L_tmp="${_L_tmp//$L_RBRACE$L_RBRACE/$L_RBRACE}"
			_L_args[0]+="${_L_tmp//%/%%}"
		fi
		# Handle formatting expression
		if [[ -n "${BASH_REMATCH[5]}" ]]; then
			_L_args[0]+="%""${BASH_REMATCH[7]}"
			# Default to %s
			if [[ "${_L_args[0]:${#_L_args[0]}-1}" != [a-zA-Z] ]]; then
				_L_args[0]+="s"
			fi
			_L_args+=("${!BASH_REMATCH[5]}")
		fi
	done
	printf -v L_v "${_L_args[@]}"
}

# @description Convert a string to hex dump.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
L_hexdump() { L_handle_v_scalar "$@"; }
L_hexdump_v() {
	if L_hash xxd; then
		L_v=$(printf "%s" "$*" | xxd -p)
	else
		local _L_i _L_a="$*" LC_ALL=C
		L_v=""
		for ((_L_i=0;_L_i<${#_L_a};++_L_i)); do
			printf -v L_v "%s%x" "$L_v" "'${_L_a:$_L_i:1}"
		done
	fi
}

# @description Encode a string in percent encoding.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
L_urlencode() { L_handle_v_scalar "$@"; }
L_urlencode_v() {
	local _L_i _L_a="$*" LC_ALL=C _L_c
	L_v=""
	for ((_L_i=0;_L_i<${#_L_a};++_L_i)); do
		_L_c=${_L_a:$_L_i:1}
		case "$_L_c" in
		[A-Za-z0-9_~-]) L_v+=$_L_c ;;
		*) printf -v L_v "%s%%%02x" "$L_v" "'$_L_c" ;;
		esac
	done
}

# @description Decode percent encoding.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
L_urldecode() { L_handle_v_scalar "$@"; }
L_urldecode_v() {
	local _L_a="$*" LC_ALL=C
	L_v=""
	while [[ -n "$_L_a" ]]; do
		case "$_L_a" in
		%[0-9a-fA-Z][0-9a-fA-Z]*) printf -v L_v "%s\x${_L_a:1:2}" "$L_v"; _L_a="${_L_a:3}" ;;
		%%*) L_v+="%"; _L_a="${_L_a:2}" ;;
		*) L_v+="${_L_a:0:1}"; _L_a="${_L_a:1}" ;;
		esac
	done
}

# @description Escape characters for html.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
L_html_escape() { L_handle_v_scalar "$@"; }
L_html_escape_v() {
	L_v="$*"
	L_v=${L_v//"&"/"&amp;"}
	L_v=${L_v//"<"/"&lt;"}
	L_v=${L_v//">"/"&gt;"}
	L_v=${L_v//'"'/"&qout;"}
	L_v=${L_v//"'"/"&#39;"}
}

# @description Replace multiple characters in a string in order.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 String to operate on.
# @arg $2 String to replace.
# @arg $3 Replacement.
# @arg $@ String to replace and replacement can be repeated multiple times.
# @note I think this should be removed.
# @example L_string_replace -v string "$string" "&" "&amp;" "<" "&lt;"
# @see L_html_escape
L_string_replace() { L_handle_v_scalar "$@"; }
L_string_replace_v() {
	L_v="$1"
	shift
	while (($# > 2)); do
		L_v="${L_v//"$1"/$2}"
		shift 2
	done
}

# @description Count the character in string.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 String.
# @arg $2 Character to count in string.
L_string_count() { L_handle_v_scalar "$@"; }
L_string_count_v() {
	# This method is _MUCH_ faster then using [^"$2"].
	L_v="${1//"$2"}"
	L_v="$(( ${#1} - ${#L_v} ))"
}

# @description Count lines in a string.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 String.
# @arg [$2] Line characters. Default: newline.
L_string_count_lines() { L_handle_v_scalar "$@"; }
L_string_count_lines_v() {
	L_string_count_v "$1" "${2:-$'\n'}"
	# If there is anything after the last newline.
	if [[ -n "$1" && "${1: -1}" != "${2:-$'\n'}" ]]; then
		L_v=$((L_v+1))
	fi
}

# @description Split a string with quotes without the risk of execution anything.
#
# Rules:
# - https://www.gnu.org/software/bash/manual/html_node/Escape-Character.html
# - https://www.gnu.org/software/bash/manual/html_node/Single-Quotes.html
# - https://www.gnu.org/software/bash/manual/html_node/Double-Quotes.html
# - https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html
#
# Why not xargs? To support ANSI-C quoting style $'' and support newlines in quotes.
#
# Why not declare? Declare allows execution, `declare -a array='($(echo something >&2))'`executes echo.
#
# @option -v <var> Store the output in variable instead of printing it.
# @option -c Enable ignoring comments.
# @option -A Disable ANSI-C quoting.
# @option -h Print this help and return 0.
# @option -q Without -v, instead of printing one word per line, output words quoted with `printf %q`.
# shellcheck disable=SC1003
# @example
#   $ L_string_unquote -v cmd "ls -l 'somefile; rm -rf ~'"
#   $ declare -p cmd
#   declare -a cmd=([0]="ls" [1]="-l" [2]="somefile; rm -rf ~")
L_string_unquote() {
	# local -;set -x
	local OPTIND OPTARG OPTERR _L_i _L_v="" _L_comments=0 _L_ansic1='$' _L_ansic2="[$]'|" _L_q=0
	while getopts v:cAqh _L_i; do
		case "$_L_i" in
			v) _L_v=$OPTARG ;;
			c) _L_comments=1 ;;
			A) _L_ansic1="" _L_ansic2="" ;;
			q) _L_q=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	local _L_input="$*" _L_output=() _L_mode="" _L_new="" _L_W=$' \t\r\n' _L_started=0
	while [[ -n "$_L_input" ]]; do
		case "$_L_mode" in
		"")
			if ((_L_comments)) && [[ "$_L_input" =~ ^[$_L_W]*#[^$'\n']*(.*)$ ]]; then
				_L_input=${BASH_REMATCH[1]}
				continue
			fi
			if [[ "$_L_input" =~ ^([$_L_W]*)(([^${_L_ansic1}\'\"\\$_L_W]+)|\'([^\']*)\'|\\(.)|${_L_ansic2}[${_L_ansic1}\'\"\\])?(.*)$ ]]; then
			  #                   1         23                               4            5                                     6
			  # declare -p BASH_REMATCH
			  if [[ -n "${BASH_REMATCH[1]}" ]] && ((_L_started)); then
			  	_L_output+=("$_L_new")
			  	_L_started=0
			  	_L_new=""
			  fi
			  _L_input=${BASH_REMATCH[6]}
			  if [[ -n "${BASH_REMATCH[3]}" ]]; then
			  	_L_started=1
			  	_L_new+=${BASH_REMATCH[3]}
			  elif [[ -n "${BASH_REMATCH[4]}" ]]; then
			  	_L_started=1
			  	_L_new+=${BASH_REMATCH[4]}
			  elif [[ -n "${BASH_REMATCH[5]}" ]]; then
			  	# Escaped character. Newline is removed when escaped.
			  	if [[ "${BASH_REMATCH[5]}" != $'\n' ]]; then
			  		_L_started=1
			  		_L_new+=${BASH_REMATCH[5]}
			  	fi
			  else
			  	case "${BASH_REMATCH[2]}" in
			  		"''") _L_started=1 _L_new+="" ;;  # empty BASH_REMATCH[4]
			  		"\$'") _L_mode="\$'" ;;  # ANSI-C quoting start
				  	'$') _L_started=1 _L_new+='$' ;;  # Dollar, but not $'
			  		"'")
			  			if [[ "$_L_input" != *"'"* ]]; then
			  				L_func_error "No closing quotation '"
				  			return 2
				  		fi
				  		_L_input="'"$_L_input
				  		;;
				  	'"') _L_mode='"' ;;  # quoting started
				  	'\')
				  		if [[ -z "$_L_input" ]]; then
			  				L_func_error "No escaped character"
			  				return 2
			  			fi
				  		_L_input='\'$_L_input
				  		;;
				  	'') ;;
				  	*) L_func_error "INTERNAL ERROR 1: ${BASH_REMATCH[2]}"; return 3
				  esac
			  fi
			else
				L_func_error "INTERNAL ERROR 2: $_L_input"; return 3
			fi
			;;
		"\$'")
			# Match ' prefixed by nothing or non-slash.
			# After nothing or non-slash there may be an even number of slashes.
			# Match greedy from the back.
			# When non-slash matches single quote, it is in front an odd number of slashes.
			# Otherwise it would have matched first.
			if [[ "$_L_input" =~ ((^|[^\'\\]|\\\')(\\\\)*)\'(.*)$ ]]; then
				#                  12               3         4
				# declare -p BASH_REMATCH
				_L_i="${_L_input::${#_L_input}-${#BASH_REMATCH[0]}+${#BASH_REMATCH[1]}}"
				_L_input=${BASH_REMATCH[4]}
				# I feel confident.
				eval "printf -v _L_i %s \$'$_L_i'"
				# printf -v _L_i "%b" "$_L_i"
				# _L_i=${_L_i//\\\?/?}
				# _L_i=${_L_i//\\\'/\'}
				# _L_i=${_L_i//\\\"/\"}
				_L_started=1
				_L_new+=$_L_i
				_L_mode=""
			else
				L_func_error "No closing quotation $_L_mode"
				return 2
			fi
			;;
		'"')
			if [[ "$_L_input" =~ ^([^\"\\]*)(\\([\$\`\"\\$'\n'])|\\.|\")(.*)$ ]]; then
				#                   1         2  3                        4
				_L_new+=${BASH_REMATCH[1]}
				_L_input=${BASH_REMATCH[4]}
				_L_started=1
				if [[ -n "${BASH_REMATCH[3]}" ]]; then
					if [[ "${BASH_REMATCH[3]}" != $'\n' ]]; then
						# Add escaped character inside double quotes
						_L_new+=${BASH_REMATCH[3]}
					fi
				elif [[ "${BASH_REMATCH[2]}" == "\"" ]]; then
					# Quoting ends.
					_L_mode=""
				else
					_L_new+=${BASH_REMATCH[2]}
				fi
			else
				L_func_error "No closing quotation $_L_mode"
				return 4
			fi
			;;
		*) L_func_error "INTERNAL ERROR #4 _L_mode=$_L_mode"; return 3
		esac
	done
	if [[ -n "$_L_mode" ]]; then
		L_func_error "No closing quotation $_L_mode"
		return 5
	fi
	if ((_L_started)); then
		_L_output+=("$_L_new")
	fi
	#
	if [[ -n "$_L_v" ]]; then
		L_array_assign "$_L_v" ${_L_output+"${_L_output[@]}"}
	elif ((${#_L_output[@]})); then
		if ((_L_q)); then
			if ((${#_L_output[@]}>1)); then
				printf "%q " "${_L_output[@]::${#_L_output[@]}-1}"
			fi
			printf "%q\n" "${_L_output[@]:${#_L_output[@]}-1}"
		else
			printf "%s\n" ${_L_output+"${_L_output[@]}"}
		fi
	fi
}

# ]]]
# json [[[
# @section json

# @description Produces a string properly quoted for JSON inclusion
# Poor man's jq
# @see https://ecma-international.org/wp-content/uploads/ECMA-404.pdf figure 5
# @see https://stackoverflow.com/a/27516892/9072753
# @option -v <var> Store the output in variable instead of printing it.
# @example
#    L_json_escape -v tmp "some string"
#    echo "{\"key\":$tmp}" | jq .
L_json_escape() { L_handle_v_array "$@"; }
L_json_escape_v() {
	# This can't be $*, because \x01\x01 bug in bash<=4.4
	L_v=$1
	if [[ "$L_v" == *[$'\\\"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x7f']* ]]; then
		L_v=${L_v//\\/\\\\}
		L_v=${L_v//\"/\\\"}
		# L_v=${L_v//\//\\\/}
		L_v=${L_v//$'\x01'/\\u0001}
		L_v=${L_v//$'\x02'/\\u0002}
		L_v=${L_v//$'\x03'/\\u0003}
		L_v=${L_v//$'\x04'/\\u0004}
		L_v=${L_v//$'\x05'/\\u0005}
		L_v=${L_v//$'\x06'/\\u0006}
		L_v=${L_v//$'\x07'/\\u0007}
		L_v=${L_v//$'\b'/\\b}
		L_v=${L_v//$'\t'/\\t}
		L_v=${L_v//$'\n'/\\n}
		L_v=${L_v//$'\x0b'/\\u000b}
		L_v=${L_v//$'\f'/\\f}
		L_v=${L_v//$'\r'/\\r}
		L_v=${L_v//$'\x0e'/\\u000e}
		L_v=${L_v//$'\x0f'/\\u000f}
		L_v=${L_v//$'\x10'/\\u0010}
		L_v=${L_v//$'\x11'/\\u0011}
		L_v=${L_v//$'\x12'/\\u0012}
		L_v=${L_v//$'\x13'/\\u0013}
		L_v=${L_v//$'\x14'/\\u0014}
		L_v=${L_v//$'\x15'/\\u0015}
		L_v=${L_v//$'\x16'/\\u0016}
		L_v=${L_v//$'\x17'/\\u0017}
		L_v=${L_v//$'\x18'/\\u0018}
		L_v=${L_v//$'\x19'/\\u0019}
		L_v=${L_v//$'\x1a'/\\u001a}
		L_v=${L_v//$'\x1b'/\\u001b}
		L_v=${L_v//$'\x1c'/\\u001c}
		L_v=${L_v//$'\x1d'/\\u001d}
		L_v=${L_v//$'\x1e'/\\u001e}
		L_v=${L_v//$'\x1f'/\\u001f}
		L_v=${L_v//$'\x7f'/\\u007f}
	fi
	L_v=\"$L_v\"
}

# @description Very simple function to create JSON.
# Every second argument is quoted for JSON, unless
# This argument is preceeded by a previous argument ending with ] or },
# when the counter starts over.
# @example
#   L_json_create { \
#     a : b , \
#     b :[ 1 , 2 , 3 , 4 ] \
#     c :[true, 1 ,null,false] \
#   }
#   #   ^^^^^^    ^^^^^^^^^^^^ - unquoted, added literally to the string
#   # outputs: {"a":"b","b":[1,2,3,4],"c":[true,"1",false,null]}
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
L_json_create() { L_handle_v_scalar "$@"; }
L_json_create_v() {
  local _L_escape=0 _L_o=""
  while (($#)); do
    if ((_L_escape++ % 2)); then
      L_json_escape_v "$1"
      _L_o+="$L_v"
    else
      if [[ "${1:${#1}-1}" == ["]}"] ]]; then
        _L_escape=$((_L_escape+1))
      fi
      _L_o+="$1"
    fi
    shift
  done
  L_v="$_L_o"
}

# ]]]
# array [[[
# @section array
# @description Operations on various lists, arrays and arguments. L_array_*

# @description Get array length.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 <var array nameref
# @example L_array_len arr
L_array_len() { L_handle_v_scalar "$@"; }

if ((L_HAS_NAMEREF)); then

L_array_len_v() { local -n _L_arr="$1" || return 2; L_v=${#_L_arr[@]}; }

# @description Set elements of array.
# @arg $1 <var> array nameref
# @arg $@ elements to set
# @example L_array_assign arr 1 2 3
L_array_assign() { local -n _L_arr="$1" || return 2; _L_arr=("${@:2}"); }

# @description Assign element of an array
# @arg $1 <var> array nameref
# @arg $2 <int> array index
# @arg $3 <str> value to assign
# @example L_array_assign arr 5 "Hello"
L_array_set() { local -n _L_arr="$1" || return 2; _L_arr["$2"]="$3"; }

# @description Append elements to array.
# @arg $1 <var> array nameref
# @arg $@ elements to append
# @example L_array_append arr "Hello" "World"
L_array_append() { local -n _L_arr="$1" || return 2; _L_arr+=("${@:2}"); }

# @description Insert element at specific position in an array.
# This will move all elements from the position to the end of the array.
# @arg $1 <var> array nameref
# @arg $2 <int> index position
# @arg $@ elements to append
# @example L_array_insert arr 2 "Hello" "World"
L_array_insert() { local -n _L_arr="$1" || return 2; _L_arr=(${_L_arr[@]+"${_L_arr[@]::$2}"} "${@:3}" ${_L_arr[@]+"${_L_arr[@]:$2}"}); }

# @description Remove first array element.
# @arg $1 <var> array nameref
L_array_pop_front() { local -n _L_arr="$1" || return 2; _L_arr=(${_L_arr[@]+"${_L_arr[@]:1}"}); }

# @description Remove last array element.
# @arg $1 <var> array nameref
# @example L_array_pop_back arr
L_array_pop_back() { local -n _L_arr="$1" || return 2; unset -v "_L_arr[${#_L_arr[@]}-1]"; }

# @description Return success, if all array elements are in sequence from 0.
# @arg $1 <var> array nameref
# @example if L_array_is_dense arr; then echo "Array is dense"; fi
L_array_is_dense() {
	local -n _L_arr="$1" || return 2
	[[ "${#_L_arr[*]}" = 0 || " ${!_L_arr[*]}" == *" $((${#_L_arr[*]}-1))" ]]
}

else  # L_HAS_NAMEREF
	L_array_len_v() { L_is_valid_variable_name "$1" && eval "L_v=\${#$1[@]}"; }
	L_array_assign() { L_is_valid_variable_name "$1" && eval "$1=(\"\${@:2}\")"; }
	L_array_set() { L_is_valid_variable_name "$1" && eval "$1[\"\$2\"]=\"\$3\""; }
	L_array_append() { L_is_valid_variable_name "$1" && eval "$1+=(\"\${@:2}\")"; }
	L_array_insert() {
		L_is_valid_variable_name "$1" &&
		eval "$1=(\${$1[@]+\"\${$1[@]::\$2}\"} \"\${@:3}\" \${$1[@]+\"\${$1[@]:\$2}\"})"
	}
	L_array_pop_front() {
		L_is_valid_variable_name "$1" &&
		eval "$1=(\${$1[@]+\"\${$1[@]:1}\"})";
	}
	L_array_pop_back() { L_is_valid_variable_name "$1" && eval "unset -v \"$1[\${#$1[@]}-1]\""; }
	L_array_is_dense() {
		L_is_valid_variable_name "$1" &&
		eval "[[ \"\${#$1[*]}\" = 0 || \" \${!$1[*]}\" == *\" \$((\${#$1[*]}-1))\" ]]"
	}
fi  # L_HAS_NAMEREF

# @description Append elements to the front of the array.
# @arg $1 <var> array nameref
# @arg $@ elements to append
# @example L_array_prepend arr "Hello" "World"
L_array_prepend() { L_array_insert "$1" 0 "${@:2}"; }

# @description Clear an array.
# @arg $1 <var> array nameref
# @example L_array_clear arr
L_array_clear() { L_array_assign "$1"; }

# @description Assign array elements to variables in order.
# @arg $1 <var> array nameref
# @arg $@ variables to assign to
# @example
#   arr=("Hello" "World")
#   L_array_extract arr var1 var2
#   echo "$var1"  # prints Hello
#   echo "$var2"  # prints World
L_array_extract() {
	local _L_v _L_i=0 _L_r
	for _L_v in "${@:2}"; do
		_L_r="$1[$((_L_i++))]"
		printf -v "$_L_v" "%s" "${!_L_r}"
	done
}

# @description Reverse elements in an array.
# @arg $1 <var> array nameref
# @example
# 	arr=("world" "Hello")
# 	L_array_reverse arr
# 	echo "${arr[@]}"  # prints Hello world
L_array_reverse() {
	# eval is the fastest, see scripts/array_reverse_test.sh
	L_assert "not a valid variable name: $1" L_is_valid_variable_name "$1"
	eval "local _L_len=\${#$1[@]}"
	if ((_L_len)); then
		eval eval "'$1=(' '\"\${$1['{$((_L_len-1))..0}']}\"' ')'"
	fi
}

# @description Wrapper for readarray/mapfile for bash versions that do not have it.
# @option -t Ignored, does nothing.
# @option -d <delim> separator to use, default: newline
# @option -u <fd> file descriptor to read from
# @option -s <count> skip first n lines
# @option -h Print this help and return 0.
# @arg $1 <var> array nameref
# @example L_readarray arr <file
L_readarray() {
	local OPTIND OPTARG OPTERR _L_d=$'\n' _L_t=0 _L_c _L_read=(read -r) _L_mapfile=(mapfile -t) _L_s=0 _L_i=0
	while getopts td:u:sh _L_c; do
		case $_L_c in
		t) _L_t=1 ;;
		d) _L_d=$OPTARG ;;
		u) _L_read+=(-u"$OPTARG"); _L_mapfile+=(-u"$OPTARG") ;;
		s) _L_s=$OPTARG; _L_mapfile+=(-s"$_L_s") ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if ((L_HAS_MAPFILE_D)); then
		"${_L_mapfile[@]}" -d "$_L_d" "$1"
	elif ((L_HAS_MAPFILE)) && [[ "$_L_d" == $'\n' ]]; then
		"${_L_mapfile[@]}" "$1"
	else
		while ((_L_s--)); do
			"${_L_read[@]}" -d "$_L_d" _L_c || return
		done
		if [[ -z "$_L_d" ]]; then
			while IFS= "${_L_read[@]}" -d '' "$1[$((_L_i++))]"; do :; done
			unset -v "$1[$((_L_i-1))]"
		elif [[ $' \t\n' != *"$_L_d"* ]]; then
			# POSIX specifies that multiple whitespaces in IFS are merged together.
			# We do not want that.
			if ((!L_HAS_BASH4_0)); then
				IFS="$_L_d" "${_L_read[@]}" -d '' -a "$1" || :
			else
				IFS="$_L_d" "${_L_read[@]}" -d '' -a "$1"
			fi
		else
			_L_s=()
			while IFS= "${_L_read[@]}" _L_c; do
				_L_s+=("$_L_c")
			done
			L_array_assign "$1" "${_L_s[@]}"
		fi
	fi
}

# @description Pipe an array to a command and then read back into an array.
# @option -z Use null byte as separator instead of newline.
# @arg $1 array nameref
# @arg $@ command to pipe to
# shellcheck disable=SC2059
# @example
#   arr=("Hello" "World")
#   L_array_pipe arr tr '[:upper:]' '[:lower:]'
#   echo "${arr[@]}"  # prints hello world
L_array_pipe() {
	if [[ "$1" == -z ]]; then
		local _L_i=0 _L_arr="$2" _L_arrpnt="${2}[@]"
		if ((L_HAS_MAPFILE_D)); then
			mapfile -d '' -t "$_L_arr"
		else
			while IFS= read -d '' -r "$_L_arr[$((_L_i++))]"; do :; done
			unset -v "$_L_arr[$((_L_i-1))]"
		fi < <(
			printf ""${!_L_arrpnt:+"%s\0"} ${!_L_arrpnt:+"${!_L_arrpnt}"} | "${@:3}"
		)
	else
		local _L_arr="$1" _L_arrpnt="$1[@]"
		if ((L_HAS_MAPFILE)); then
			mapfile -t "$_L_arr" < <(
				printf ""${!_L_arrpnt:+"%s\n"} ${!_L_arrpnt:+"${!_L_arrpnt}"} | "${@:2}"
			)
		else
			IFS=$'\n' read -d '' -r -a "$_L_arr" < <(
				printf ""${!_L_arrpnt:+"%s\n"} ${!_L_arrpnt:+"${!_L_arrpnt}"} | "${@:2}"
				printf "\0"
			)
		fi
	fi
}

# @description check if array variable contains value
# @arg $1 array nameref
# @arg $2 needle
# @example
#   arr=("Hello" "World")
#   L_array_contains arr "Hello"
#   echo $?  # prints 0
L_array_contains() {
	local _L_arr="$1[@]"
	L_args_contain "$2" ${!_L_arr:+"${!_L_arr}"}
}

# @description Remove elements from array for which expression evaluates to failure.
# @arg $1 array nameref
# @arg $2 expression to `eval`uate with array element of index L_i and value $1
# @example
#  arr=("Hello" "World")
#  L_array_filter_eval arr '[[ "$1" == "Hello" ]]'
#  echo "${arr[@]}"  # prints Hello
L_array_filter_eval() {
	local L_i _L_array _L_expr _L_v
	_L_v="$1[@]"
	_L_array=(${!_L_v+"${!_L_v}"})
	_L_expr=${*:2}
	for ((L_i = ${#_L_array[@]} - 1; L_i >= 0; --L_i )); do
		set -- "${_L_array[L_i]}"
		if ! eval "$_L_expr"; then
			unset -v "_L_array[$L_i]"
		fi
	done
	eval "${_L_v%[*}=(\${_L_array[@]+\"\${_L_array[@]}\"})"
}

# @description Find an index of an element in the array equal to second argument.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 array nameref
# @arg $2 element to find
L_array_index() { L_handle_v_scalar "$@"; }
L_array_index_v() {
	local _L_i="$1[@]"
	(( ${!_L_i:+1}+0 )) && {
		eval "local _L_i=(\"\${!$1[@]}\")"
		for L_v in "${_L_i[@]}"; do
			_L_i="$1[$L_v]"
			if [[ "$2" == "${!_L_i}" ]]; then
				return 0
			fi
		done
		return 1
	}
}

# @description Join array elements separated with the second argument.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 <var> array nameref
# @arg $2 <str> string to join elements with
# @see L_args_join
# @example
#   arr=("Hello" "World")
#   L_array_join -v res arr ", "
#   echo "$res"  # prints Hello, World
L_array_join() { L_handle_v_scalar "$@"; }
L_array_join_v() {
	local _L_arr="$1[@]"
	L_args_join_v "$2" ${!_L_arr:+"${!_L_arr}"}
}

# @description
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 <var> array nameref
# @see L_args_andjoin
L_array_andjoin() { L_handle_v_scalar "$@"; }
L_array_andjoin_v() {
	local _L_arr="$1[@]"
	L_args_andjoin_v ${!_L_arr+"${!_L_arr}"}
}

# ]]]
# args [[[
# @section args
# @description Operations on list of arguments.

# @description Join arguments with separator
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 <str> separator
# @arg $@ arguments to join
# @see L_array_join
# @example
#   L_args_join -v res ", " "Hello" "World"
#   echo "$res"  # prints Hello, World
L_args_join() { L_handle_v_scalar "$@"; }
L_args_join_v() {
	printf -v L_v "${1//%/%%}%s" "${@:2}"
	L_v=${L_v:${#1}}
}

# @description Join arguments with ", " and last with " and "
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ arguments to join
L_args_andjoin() { L_handle_v_scalar "$@"; }
L_args_andjoin_v() {
	case "$#" in
	0) L_v="" ;;
	1) L_v=$1 ;;
	*)
		printf -v L_v ", %s" "${@:1:$#-1}"
		L_v="${L_v#, }"" and ""${*:$#}"
		;;
	esac
}

# @description Check if arguments starting from second contain the first argument.
# @arg $1 needle
# @arg $@ heystack
# @example
#   L_args_contain "Hello" "Hello" "World"
#   echo $?  # prints 0
L_args_contain() {
	local IFS=$'\x1D' i
	if [[ "${*//"$IFS"}" == "$*" ]]; then
		[[ "$IFS${*:2}$IFS" == *"$IFS$1$IFS"* ]]
	else
		for i in "${@:2}"; do
			if [[ "$i" == "$1" ]]; then
				return 0
			fi
		done
		return 1
	fi
}

# @description Get index number of argument equal to the first argument.
# @option -v <var>
# @arg $1 needle
# @arg $@ heystack
# @example
#   L_args_index -v res "World" "Hello" "World"
#   echo "$res"  # prints 1
L_args_index() { L_handle_v_scalar "$@"; }
L_args_index_v() {
	local _L_needle="$1" _L_start="$#" IFS=$'\x1D'
	(( $# > 1 )) && {
		if [[ "${*//"$IFS"}" == "$*" ]]; then
			L_v="$IFS${*:2}$IFS"
			L_v="${L_v%%"$IFS$1$IFS"*}"
			L_v="${L_v//[^$IFS]}"
			L_v=${#L_v}
			[[ "$L_v" -lt "$#" ]]
		else
			shift
			while (($#)); do
				if [[ "$1" == "$_L_needle" ]]; then
					L_v=$((_L_start-1-$#))
					return 0
				fi
				shift
			done
			return 1
		fi
	}
}

# @description return max of arguments
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ int arguments
# @example L_max -v max 1 2 3 4
L_max() { L_handle_v_scalar "$@"; }
# shellcheck disable=SC1105,SC2094,SC2035
# @set L_v
L_max_v() {
	L_v=$1
	shift
	while (($#)); do
		if (("$1" > L_v)); then
			L_v="$1"
		fi
		shift
	done
}

# @description return max of arguments
# @option -v <var> Store the output in variable instead of printing it.
# @arg $@ int arguments
# @example L_min -v min 1 2 3 4
L_min() { L_handle_v_scalar "$@"; }
# shellcheck disable=1105,2094,2035
# @set L_v
L_min_v() {
	L_v=$1
	shift
	while (($#)); do
		if (($1 < L_v)); then
			L_v="$1"
		fi
		shift
	done
}

# ]]]
# utilities [[[
# @section utilities
# @description Various self contained functions that could be separate programs.

# shellcheck disable=SC1105,SC2201,SC2102,SC2035,SC2211,SC2283,SC2094
# @description Make a table
# @option -v <var> Store the output in variable instead of printing it.
# @option -s <separator> IFS column separator to use. Default: space or tab.
# @option -o <str> Output separator to use
# @option -R <list[int]> Right align columns with these indexes
# @option -h Print this help and return 0.
# @arg $@ Lines to print, joined and separated by newline.
# @example
#     $ L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
#     name1 name2 name3
#         a     b c
#         d     e f
L_table() {
	local OPTIND OPTARG OPTERR IFS=$'\n ' _L_i _L_s=$' \t' _L_v="" _L_arr=() _L_tmp="" _L_column=0 _L_columns=0 _L_rows=0 _L_row=0 _L_widths=() _L_o=" " _L_R="" _L_last
	while getopts v:s:o:R:h _L_i; do
		case $_L_i in
		v) _L_v=$OPTARG; printf -v "$_L_v" "%s" "" ;;
		s) _L_s=$OPTARG ;;
		o) _L_o=$OPTARG ;;
		R) _L_R=$OPTARG ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	# Fill the array, find number of columns and rows.
	while IFS="$_L_s" read -r -a _L_tmp; do
		for _L_column in "${!_L_tmp[@]}"; do
			_L_arr[100 * _L_rows + _L_column]=${_L_tmp[_L_column]}
			(( _L_widths[_L_column] < ${#_L_tmp[_L_column]} ? _L_widths[_L_column] = ${#_L_tmp[_L_column]} : 0, 1 ))
		done
		(( _L_column > _L_columns ? _L_columns = _L_column + 1 : 0, ++_L_rows ))
	done <<<"$*"
	#
	L_parse_range_list -v _L_R "$_L_columns" "$_L_R"
	#
	for ((_L_row = 0; _L_row < _L_rows; _L_row++)); do
		if L_var_is_set "_L_arr[100 * _L_row + 0]"; then
			for ((_L_column = 0; _L_column < _L_columns; _L_column++)); do
				_L_tmp=${_L_arr[100 * _L_row + _L_column]:-}
				L_exit_to _L_last L_var_is_set "_L_arr[100 * _L_row + _L_column + 1]"
				if L_args_contain "$((_L_column+1))" ${_L_R[@]+"${_L_R[@]}"}; then
					L_printf_append "$_L_v" "%*s" "${_L_widths[_L_column]}" "$_L_tmp"
				else
					if ((_L_last)); then
						L_printf_append "$_L_v" "%s" "$_L_tmp"
					else
						L_printf_append "$_L_v" "%-*s" "${_L_widths[_L_column]}" "$_L_tmp"
					fi
				fi
				if ((_L_last)); then
					break
				fi
				if ((_L_column + 1 < _L_columns)); then
					L_printf_append "$_L_v" "%s" "$_L_o"
				fi
			done
		fi
		L_printf_append "$_L_v" "\n"
	done
}

# @description Parse cut range list into an array.
# Each LIST is made up of one range, or many ranges separated by commas.
# Selected input is written in the same order that it is read, and is written exactly once.
# Each range is one of:
#     N      N'th byte, character or field, counted from 1
#     N-     from N'th byte, character or field, to end of line
#     N-M    from N'th to M'th (included) byte, character or field
#     -M     from first to M'th (included) byte, character or field
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 max number of fields
# @arg $2 list of fields
# @example
#     $ L_parse_range_list 100 1-4,3-5
#     1
#     2
#     3
#     4
#     5
#     $ L_parse_range_list -v tmp 100 '1-4 3-5'
#     $ echo "${tmp[@]}"
#     1 2 3 4 5
#     $ if L_args_contain 3 "${tmp[@]}"; then echo "yes"; else echo "no"; fi
#     yes
#     $ if L_args_contain 7 "${tmp[@]}"; then echo "yes"; else echo "no"; fi
#     no
L_parse_range_list() { L_handle_v_array "$@"; }
L_parse_range_list_v() {
	local _L_max=$1 _L_list _L_i _L_j _L_k _L_t
	shift
	L_assert 'not enough argumenst' test "$#" -gt 0
	IFS=$' \t\n' read -r -a _L_list <<<"${*//[^0-9-]/ }"
	L_v=()
	for _L_i in ${_L_list[@]+"${_L_list[@]}"}; do
		if [[ $_L_i == *-* ]]; then
			_L_j=${_L_i%-*}
			_L_k=${_L_i#*-}
			: "${_L_j:=1}"
			: "${_L_k:=$_L_max}"
			if ((_L_j > _L_k)); then
				_L_t=$_L_j
				_L_j=$_L_k
				_L_k=$_L_t
			fi
			for ((_L_t = _L_j; _L_t <= _L_k; _L_t++)); do
				L_v[_L_t]=$_L_t
			done
		else
			L_v[_L_i]=$_L_i
		fi
	done
}

if ((L_HAS_DECLARE_WITH_NO_QUOTES)); then
	# @description extglob that matches declare -p output from array or associative array
	_L_DECLARE_P_ARRAY_EXTGLOB="declare -[aA]*([a-zA-Z]) [a-zA-Z_]*([a-zA-Z_0-9-])=\(@(|\[?*\]=?*)\)"
else
	_L_DECLARE_P_ARRAY_EXTGLOB="declare -[aA]*([a-zA-Z]) [a-zA-Z_]*([a-zA-Z_0-9-])='\(@(|\[?*\]=?*)\)'"
fi

# @description Add stuff to output from pretty_print
# @arg $1 <str> printf format string
# @arg $@ <any> any printf arguments
# @env _L_pp_compact
# @env _L_pp_prefix_sav
# @env _L_pp_line
# @env _L_pp_width
# @env _L_pp_v
_L_pretty_print_output() {
	if ((_L_pp_compact)); then
		local _L_pp_tmp
		# shellcheck disable=SC2059
		printf -v _L_pp_tmp "$@"
		# If the line would be widther then terminal width, output it.
		if (( ${#_L_pp_prefix_sav} + ${#_L_pp_line} + !!${#_L_pp_line} + ${#_L_pp_tmp} > _L_pp_width )); then
			_L_pretty_print_flush
		fi
		_L_pp_line+=${_L_pp_line:+ }$_L_pp_tmp
	else
		L_printf_append "$_L_pp_v" "%s$1\n" "$_L_pp_prefix" "${@:2}"
	fi
}

# @description Flush the output of pretty_print
# @noargs
# @env _L_pp_nested
# @env _L_pp_line
# @env _L_pp_prefix_sav
# @env _L_pp_prefix
_L_pretty_print_flush() {
	if ((_L_pp_compact && ${#_L_pp_line})); then
		L_printf_append "$_L_pp_v" "%s%s\n" "$_L_pp_prefix_sav$_L_pp_line"
		_L_pp_prefix_sav=$_L_pp_prefix
		_L_pp_line=""
	fi
}

# @description Handle nested arrays by L_pretty_print
# @arg $1 <str> key value
# @arg $2 <str> declare -p output with removed =
# @env _L_pp_v
# @env _L_pp_width
_L_pretty_print_nested() {
	set -- "${1##* }" "$2"
	local -A _L_pp_array="$2"
	if ((${#_L_pp_array[@]} == 0)); then
		_L_pretty_print_output "%s=()" "$1"
	else
		local _L_pp_key _L_pp_keys=("${!_L_pp_array[@]}") L_v
		# Associative array indexes are not sorted.
		LC_ALL=C L_sort _L_pp_keys
		#
		_L_pretty_print_flush
		_L_pretty_print_output "%s=(" "$1"
		_L_pp_prefix+="  "
		for _L_pp_key in "${_L_pp_keys[@]}"; do
			local _L_pp_value="${_L_pp_array["$_L_pp_key"]}"
			if (( _L_pp_nested && ${#_L_pp_value} > _L_pp_width )); then
				# shellcheck disable=SC2053
				if [[ "$_L_pp_value" == "(["?*"]="*")" ]]; then
					_L_pretty_print_nested "[$_L_pp_key]" "$_L_pp_value"
					continue
				elif [[ "$_L_pp_value" == $_L_DECLARE_P_ARRAY_EXTGLOB ]]; then
					_L_pretty_print_nested "[$_L_pp_key]" "${_L_pp_value#*=}"
					continue
				fi
			fi
			if [[ "$_L_pp_value" == *$'\n'* ]]; then
				printf -v L_v "%q" "$_L_pp_value"
			else
				L_quote_setx_v "$_L_pp_value"
			fi
			_L_pretty_print_output "[%q]=%s" "$_L_pp_key" "$L_v"
		done
		if ((_L_pp_compact)); then
			_L_pretty_print_output ")"
			_L_pp_prefix=${_L_pp_prefix%"  "}
		else
			_L_pp_prefix=${_L_pp_prefix%"  "}
			_L_pretty_print_output ")"
		fi
		_L_pretty_print_flush
	fi
}

# @description Prints values with declare, but array values are on separate lines.
# @option -p <str> Prefix each line with this prefix
# @option -v <var> Store the output in variable instead of printing it.
# @option -w <int> Set terminal width. This modifies compact output line wrapping.
# @option -n Enable pretty printing nested arrays
# @option -C Disable compact output for arrays, i.e. each key is on separate line.
# @option -h Print this help and return 0.
# @option -c Compact output.
# @arg $@ variable names to pretty print
L_pretty_print() {
	local OPTIND OPTARG OPTERR _L_pp_opt _L_pp_declare _L_pp_prefix="" _L_pp_v="" _L_pp_width=${COLUMNS:-80} _L_pp_nested=0 _L_pp_line="" _L_pp_compact=0 _L_pp_prefix_sav=""
	while getopts :p:v:w:nch _L_pp_opt; do
		case $_L_pp_opt in
		p) _L_pp_prefix="$OPTARG " ;;
		v) _L_pp_v=$OPTARG; printf -v "$_L_pp_v" "%s" "" ;;
		w) _L_pp_width=$OPTARG ;;
		n) _L_pp_nested=1 ;;
		c) _L_pp_compact=1 ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	while (($#)); do
		if ! L_is_valid_variable_name "$1" || ! _L_pp_declare=$(declare -p "$1" 2>/dev/null); then
			_L_pretty_print_output "%s" "$1"
		elif
			((${#_L_pp_declare} <= _L_pp_width)) ||
				[[ "$_L_pp_declare" != "declare -"[aA]* ]] ||
				((!L_HAS_ASSOCIATIVE_ARRAY))
		then
			if L_isprint "$_L_pp_declare"; then
				_L_pretty_print_output "%s" "$_L_pp_declare"
			else
				_L_pretty_print_output "%q" "$_L_pp_declare"
			fi
		else
			_L_pretty_print_nested "${_L_pp_declare%%=*}" "${_L_pp_declare#*=}"
		fi
		_L_pretty_print_flush
		shift
	done
}

# @see L_argskeywords
_L_argskeywords_assert() {
	if ! "${@:2}"; then
		L_error -s 2 "%s" "${_L_errorprefix:+$_L_errorprefix }$1"
		if ((_L_errorexit)); then
			exit 2
		else
			return 2
		fi
	fi
}

# @arg $1 variable
# @arg $2 value
# @see L_argskeywords
_L_argskeywords_assign() {
	if [[ -n "$_L_asa" ]]; then
		if ((_L_use_map)); then
			L_map_set "$_L_asa" "$1" "$2"
		else
			L_asa_set "$_L_asa" "$1" "$2"
		fi
	else
		printf -v "$1" "%s" "$2"
	fi
}

# @description Parse python-like positional and keyword arguments format.
# The difference to python is that `@` is used instead of `*`, becuase `*` triggers filename expansion.
# An argument `--` signifies end of arguments definition and start of arguments to parse.
# @see https://docs.python.org/3/reference/compound_stmts.html#function-definitions
# @see https://realpython.com/python-asterisk-and-slash-special-parameters/
# @option -A <var> Instead of storing in variables, store values in specified associative array with variables as key.
# @option -M Use L_map instead of associative array, for @@kwargs and -A option. Usefull for older Bash.
# @option -E Exit on error
# @option -e <str> Prefix error messages with this prefix. Default: "${FUNCNAME[1]}:L_argskeywords:"
# @option -h Print this help and return 0.
# @arg $@ Python arguments format specification
# @arg $2 <str> --
# @arg $@ Arguments to parse
# @example
#   range() {
#      local start stop step
#       L_argskeywords start stop step=1 -- "$@" || return 2
#       for ((; start < stop; start += stop)); do echo "$start"; done
#   }
#   range start=1 stop=6 step=2
#   range 1 6
#
#   max() {
#      local arg1 arg2 args key
#      L_argskeywords arg1 arg2 @args key='' -- "$@" || return 2
#      ...
#   }
#   max 1 2 3 4
#
#   int() {
#      local string base
#      L_argskeywords string / base=10 -- "$@" || return 2
#      ...
#   }
#   int 10 7 # error
#   int 10 base=7
L_argskeywords() {
	{
		# parse arguments
		local OPTIND OPTARG OPTERR _L_i _L_errorexit=0 _L_errorprefix="${FUNCNAME[1]}:${FUNCNAME[0]}:" _L_asa="" _L_use_map=0
		while getopts A:MEe:h _L_i; do
			case $_L_i in
			A) _L_asa=$OPTARG ;;
			M) _L_use_map=1 ;;
			E) _L_errorexit=1 ;;
			e) _L_errorprefix=$OPTARG ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
			esac
		done
		shift "$((OPTIND-1))"
	}
	{
		# parse arguments specification
		# _L_arguments - stores the names of the arguments
		# _L_positional_cnt - the number of positional allowed arguments
		# _L_nonkeyword_cnt - the number of only-positional arguments
		local _L_arguments=() _L_positional_cnt="" _L_nonkeyword_cnt="" _L_seen_star=0 _L_seen_slash=0 _L_excess_positional="" _L_excess_keyword="" _L_isset=() IFS=' '
		while (($#)); do
			case "$1" in
			--) break ;;
			@) # <positional or keyword> * <keyword only>
				_L_argskeywords_assert '* argument may appear only once' test "$_L_seen_star" = 0 || return 2
				_L_argskeywords_assert 'named arguments must follow bare @' test "${2:-}" != "--" || return 2
				_L_positional_cnt=${#_L_arguments[@]}
				_L_seen_star=1
				;;
			/) # <positional only> / <positional or keyword>
				_L_argskeywords_assert '/ may appear only once' test "$_L_seen_slash" = 0 || return 2
				_L_argskeywords_assert '/ must be ahead of @' test "$_L_seen_star" = 0 || return 2
				_L_nonkeyword_cnt=${#_L_arguments[@]}
				_L_seen_slash=1
				;;
			@@*)
				_L_argskeywords_assert "${1#@@} is not a valid variable name" L_is_valid_variable_name "${1#@@}" || return 2
				_L_argskeywords_assert "arguments cannot follow var-keyword argument: ${2:-}" test "${2:-}" == "--" || return 2
				_L_excess_keyword="${1#@@}"
				if ((_L_use_map)); then
					L_map_clear "$_L_excess_keyword"
				else
					_L_argskeywords_assert "$1 must be an associative array" L_var_is_associative "$_L_excess_keyword" || return 2
					eval "$_L_excess_keyword=()"
				fi
				;;
			@*)
				_L_argskeywords_assert '* argument may appear only once' test "$_L_seen_star" = 0 || return 2
				_L_excess_positional="${1#@}"
				_L_argskeywords_assert "${_L_excess_positional} is not a valid variable name" L_is_valid_variable_name "${_L_excess_positional}" || return 2
				_L_seen_star=1
				_L_positional_cnt=${#_L_arguments[@]}
				eval "$_L_excess_positional=()"
				;;
			*=*)
				_L_argskeywords_assert "${1##=*} is not a valid variable name" L_is_valid_variable_name "${1%%=*}" || return 2
				_L_argskeywords_assert "duplicate argument ${1##=*}" L_not L_args_contain "${1%%=*}" ${_L_arguments[@]:+"${_L_arguments[@]}"} || return 2
				_L_argskeywords_assign "${1%%=*}" "${1#*=}"
				_L_isset[${#_L_arguments[@]}]=1
				_L_arguments+=("${1%%=*}")
				;;
			*)
				_L_argskeywords_assert "parameter without a default follows parameter with a default: $1" test "${#_L_isset[@]}" -eq 0 || return 2
				_L_argskeywords_assert "$1 is not a valid variable name" L_is_valid_variable_name "$1" || return 2
				_L_argskeywords_assert "duplicate argument $1" L_not L_args_contain "$1" ${_L_arguments[@]:+"${_L_arguments[@]}"} || return 2
				_L_arguments+=("$1")
				;;
			esac
			shift
		done
		_L_argskeywords_assert '"--" separator argument is missing' test "${1:-}" = "--" || return 2
		shift
		: "${_L_positional_cnt:=${#_L_arguments[@]}}" "${_L_nonkeyword_cnt:=0}"
	}
	{
		# local -; set -x
		# parse args and assign to variables like python would
		local _L_seen_equal=0 _L_positional_idx=0
		while (($#)); do
			if [[ "$1" == *=* ]]; then
				_L_seen_equal=1
				local _L_key=${1%%=*} _L_value=${1#*=} _L_i
				for _L_i in ${_L_arguments[@]:+"${!_L_arguments[@]}"}; do
					if [[ "${_L_arguments[_L_i]}" == "$_L_key" ]]; then
						if ((_L_nonkeyword_cnt <= _L_i)); then
							_L_isset[_L_i]=1
							_L_argskeywords_assign "${_L_arguments[_L_i]}" "$_L_value"
							shift
							continue 2
						else
							# declare -p _L_nonkeyword_cnt _L_arguments _L_positional_cnt
							_L_argskeywords_assert "got some positional only arguments passed as keyword arguments: $1" false || return 2
						fi
					fi
				done
				if [[ -n "$_L_excess_keyword" ]]; then
					if ((_L_use_map)); then
						L_map_set "$_L_excess_keyword" "${1%%=*}" "${1#*=}"
					else
						L_asa_set "$_L_excess_keyword" "${1%%=*}" "${1#*=}"
					fi
				else
					_L_argskeywords_assert "got an unexpected keyword argument: $_L_key" false || return 2
				fi
			elif ((_L_seen_equal)); then
				_L_argskeywords_assert "positional argument follows keyword argument: $1" false || return 2
			elif ((_L_positional_idx < _L_positional_cnt)); then
				_L_isset[_L_positional_idx]=1
				_L_argskeywords_assign "${_L_arguments[_L_positional_idx++]}" "$1"
			elif [[ -n "$_L_excess_positional" ]]; then
				eval "$_L_excess_positional+=(\"\$1\")"
			else
				_L_argskeywords_assert "takes $_L_positional_cnt positional arguments but more were given: $1" false || return 2
			fi
			shift
		done
	}
	{
		# check all are set
		if ((${#_L_isset[@]} != ${#_L_arguments[@]})); then
			local positional_cnt=0 positional_str="" keyword_cnt=0 keyword_str=""
			for _L_i in "${!_L_arguments[@]}"; do
				if ((!_L_isset[_L_i])); then
					if ((_L_i < _L_positional_cnt)); then
						((++positional_cnt))
						positional_str+=${positional_str:+ }${_L_arguments[_L_i]}
					elif ((_L_nonkeyword_cnt < _L_i)); then
						((++keyword_cnt))
						keyword_str+=${keyword_str:+ }${_L_arguments[_L_i]}
					fi
				fi
			done
			_L_argskeywords_assert "missing $positional_cnt required positional arguments: $positional_str" test "$positional_cnt" -eq 0 || return 2
			_L_argskeywords_assert "missing $keyword_cnt required keyword-only arguments: $keyword_str" test "$keyword_cnt" -eq 0 || return 2
		fi
	}
}

# @description Compare version numbers.
# @see https://peps.python.org/pep-0440/
# @arg $1 str one version
# @arg $2 str one of: -lt -le -eq -ne -gt -ge '<' '<=' '==' '!=' '>' '>=' '~='
# @arg $3 str second version
# @arg [$4] int accuracy, how many at max elements to compare? By default up to 3.
# shellcheck disable=SC2053
L_version_cmp() {
	case "$2" in
	'~=')
		L_version_cmp "$1" '>=' "$3" && L_version_cmp "$1" "==" "${3%.*}.*"
		;;
	'=='|'-eq') [[ "$1" == $3 ]] ;;
	'!='|'-ne') [[ "$1" != $3 ]] ;;
	*)
		local op res='=' i max a=() b=() accuracy="${4:-3}"
		case "$2" in
		'-le') op='<=' ;;
		'-lt') op='<' ;;
		'-gt') op='>' ;;
		'-ge') op='>=' ;;
		'<='|'<'|'>'|'>=') op="$2" ;;
		*)
			L_error "L_version_cmp: invalid second argument: $op"
			return 2
		esac
		IFS=' .-()' read -r -a a <<<"$1"
		IFS=' .-()' read -r -a b <<<"$3"
		max=$(( ${#a[@]} > ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
		if (( max > accuracy )); then
			max=$accuracy
		fi
		for (( i = 0; i < max; ++i )); do
			if (( a[i] > b[i] )); then
				res='>'
				break
			elif (( a[i] < b[i] )); then
				res='<'
				break
			fi
		done
		[[ "$op" == *"$res"* ]]
		;;
	esac
}

# ]]]
# log [[[
# @section log
# @description logging library
# This library is meant to be similar to python logging library.
# @example
#     L_log_set_level ERROR
#     L_error "this is an error"
#     L_info "this is information"
#     L_debug "This is debug"
#
# @description was log system configured?
# _L_logconf_configured=0
# @description int current global log level
# _L_logconf_level=$L_LOGLEVEL_INFO
# @description 1 or 0 or ''. Should we use the color for logging output?
# _L_logconf_color=
# @description if this regex is set, allow elements
# _L_logconf_selecteval=
# @description default formatting function
# _L_logconf_formateval='L_log_format_default "$@"'
# @description default outputting function
# _L_logconf_outputeval=L_log_output_to_stderr

L_LOGLEVEL_CRITICAL=50
L_LOGLEVEL_ERROR=40
L_LOGLEVEL_WARNING=30
L_LOGLEVEL_NOTICE=25
L_LOGLEVEL_INFO=20
L_LOGLEVEL_DEBUG=10
L_LOGLEVEL_TRACE=5
# @description convert log level to log name
L_LOGLEVEL_NAMES=(
	[L_LOGLEVEL_CRITICAL]="critical"
	[L_LOGLEVEL_ERROR]="error"
	[L_LOGLEVEL_WARNING]="warning"
	[L_LOGLEVEL_NOTICE]="notice"
	[L_LOGLEVEL_INFO]="info"
	[L_LOGLEVEL_DEBUG]="debug"
	[L_LOGLEVEL_TRACE]="trace"
)
# @description get color associated with particular loglevel
# shellcheck disable=SC2153
L_LOGLEVEL_COLORS=(
	[L_LOGLEVEL_CRITICAL]="${L_ANSI_STANDOUT}${L_ANSI_BOLD}${L_ANSI_RED}"
	[L_LOGLEVEL_ERROR]="${L_ANSI_BOLD}${L_ANSI_RED}"
	[L_LOGLEVEL_WARNING]="${L_ANSI_BOLD}${L_ANSI_YELLOW}"
	[L_LOGLEVEL_NOTICE]="${L_ANSI_BOLD}${L_ANSI_CYAN}"
	[L_LOGLEVEL_INFO]="$L_ANSI_BOLD"
	[L_LOGLEVEL_DEBUG]=""
	[L_LOGLEVEL_TRACE]="$L_ANSI_LIGHT_GRAY"
)

# @description Configure L_log module.
# @option -h               Print this help and return 0.
# @option -r               Allow for reconfiguring L_log system. Otherwise the next call of this function is ignored.
# @option -l <LOGLEVEL>    Set loglevel. Can be \$L_LOGLEVEL_INFO INFO or 30. Default: $_L_logconf_level
# @option -c <BOOL>        Set to 1 to enable the use of color, set to 0 to disable the use of color.
#                          Set to '' empty string to detect if stdout has color support. Default: ''
# @option -f <FORMATEVAL>  Evaluate expression for formatting. Default: 'L_log_format_default "$@"'
#                          The function should format arguments and put the message into the L_logline variable.
# @option -F <FORMATFUNC>  Equal to -f '<FORMATFUNC> "$@"'. Shorthand to use a function.
# @option -s <SELECTEVAL>  If eval "SELECTEVAL" exits with nonzero, do not print the line. Default: ''
# @option -o <OUTPUTEVAL>  Evaluate expression for outputting. Default: L_log_output_to_stderr
#                          The function should output the content of L_logline.
# @option -L               Equal to -F L_log_format_long
# @option -J               Equal to -F L_log_format_json
# @noargs
# @example
#   L_log_configure \
#     -l debug \
#     -c 0 \
#     -f 'printf -v L_logline "${@:2}"' \
#     -o 'printf "%s\n" "$L_logline" >&2' \
#     -s '[[ $L_logline_source == */script.sh ]]'
L_log_configure() {
	local OPTIND OPTARG OPTERR _L_opt
	while getopts hrl:c:f:F:s:o:LJ _L_opt; do
		case "$_L_opt" in
			h) L_func_help; return 0; ;;
			r) _L_logconf_configured=0 ;;
			[lcfFsoLJ])
				if ((${_L_logconf_configured:-0} == 0)); then
					case "$_L_opt" in
						l) L_log_level_to_int_to _L_logconf_level "$OPTARG" ;;
						c) L_exit_to_1null _L_logconf_color L_is_true "$OPTARG" ;;
						f) _L_logconf_formateval=$OPTARG ;;
						F) _L_logconf_formateval="$OPTARG"' "$@"' ;;
						s) _L_logconf_selecteval=$OPTARG ;;
						o) _L_logconf_outputeval=$OPTARG ;;
						L) _L_logconf_formateval='L_log_format_long "$@"' ;;
						J) _L_logconf_formateval='L_log_format_json "$@"' ;;
					esac
				fi
				;;
			*) L_func_error; return 2; ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_func_assert "invalid arguments: $*" test "$#" -eq 0 || return 2
	_L_logconf_configured=1
}

# @description increase log level
# @arg $1 <int> amount, default: 10
L_log_level_inc() {
	_L_logconf_level=$(( ${_L_logconf_level:-$L_LOGLEVEL_INFO} - ${1:-10} ))
}

# @description decrease log level
# @arg $1 <int> amount, default: 10
L_log_level_dec() {
	_L_logconf_level=$(( ${_L_logconf_level:-$L_LOGLEVEL_INFO} + ${1:-10} ))
}

# @description Convert log string to number
# @arg $1 str variable name
# @arg $2 int|str loglevel like `INFO` `info` or `30`
L_log_level_to_int_to() {
	local L_v=${2##*_}
	case "$L_v" in
	[0-9]*) L_v=$2 ;;
	*[Cc][Rr][Ii][Tt]*) L_v=$L_LOGLEVEL_CRITICAL ;;
	*[Ee][Rr][Rr]*) L_v=$L_LOGLEVEL_ERROR ;;
	*[Ww][Aa][Rr][Nn]*) L_v=$L_LOGLEVEL_WARNING ;;
	*[Nn][Oo][Tt][Ii][Cc][Ee]) L_v=$L_LOGLEVEL_NOTICE ;;
	*[Ii][Nn][Ff][Oo]) L_v=$L_LOGLEVEL_INFO ;;
	*[Dd][Ee][Bb][Uu][Gg]) L_v=$L_LOGLEVEL_DEBUG ;;
	*[Tt][Rr][Aa][Cc][Ee]) L_v=$L_LOGLEVEL_TRACE ;;
	*)
		L_strupper_v "$L_v"
		L_v=L_LOGLEVEL_$L_v
		L_v=${!L_v:-$L_LOGLEVEL_INFO}
		;;
	esac
	printf -v "$1" "%d" "$L_v"
}

# @description Check if log of such level is enabled to log.
# @arg $1 str|int loglevel or log string
L_log_is_enabled_for() {
	local v
	L_log_level_to_int_to v "$1"
	_L_log_is_enabled_for "$v"
}

# @description Check if log of such level is enabled to log.
# @env _L_logconf_level
# @arg $1 int loglevel
_L_log_is_enabled_for() {
	# echo "$L_logline_levelno $L_log_level"
	(( ${_L_logconf_level:-$L_LOGLEVEL_INFO} <= $1 ))
}

# @description Default logging formatting
# @arg $1 str log line printf format string
# @arg $@ any log line printf arguments
L_log_format_default() {
	if (($# == 1)); then set -- "%s" "$*"; fi
	printf -v L_logline "%s:%s:%d:$1" \
		"$L_NAME" \
		"$L_logline_levelname" \
		"$L_logline_lineno" \
		"${@:2}"
}

# @description Format logline with timestamp information.
# @arg $1 str log line printf format string
# @arg $@ any log line printf arguments
L_log_format_long() {
	if (($# == 1)); then set -- "%s" "$*"; fi
	local L_v
	L_date_v %Y-%m-%dT%H:%M:%S%z
	printf -v L_logline "%s %q:%s:%d %s $1" \
		"$L_v" \
		"$L_NAME" \
		"$L_logline_funcname" \
		"$L_logline_lineno" \
		"$L_logline_levelname" \
		"${@:2}"
}

# @description Output logs in json format.
# shellcheck disable=SC2059
L_log_format_json() {
	local msg out="" ts L_v i pid
	if (($# == 1)); then set -- "%s" "$*"; fi
	printf -v msg "$@"
	L_date_v %Y-%m-%dT%H:%M:%S%z
	L_bashpid_to pid
	for i in \
		timestamp:"$L_v" \
		funcname:"$L_logline_funcname" \
		\"lineno\":"$L_logline_lineno" \
		source:"$L_logline_source" \
		\"level\":"$L_logline_levelno" \
		levelname:"$L_logline_levelname" \
		message:"$msg" \
		script:"$0" \
		\"pid\":"$pid" \
		${PPID:+\"ppid\":"$PPID"} \
	; do
		if [[ "${i::1}" == \" ]]; then
			out+=",$i"
		else
			out+=",\"${i%%:*}\":"
			L_json_escape_v "${i#*:}"
			out+="$L_v"
		fi
	done
	printf -v L_logline "%s" "{${out#,}}"
}

# @description Output L_logline to stderr.
L_log_output_to_stderr() {
	printf "%s\n" \
		"${L_logline_color:+${L_LOGLEVEL_COLORS[L_logline_levelno]:-}}$L_logline${L_logline_color:+$L_COLORRESET}" >&2
}

# @description Output L_logline with logger.
# @arg $@ message to output
L_log_output_to_logger() {
	logger \
		--tag="$L_NAME" \
		--id=$$ \
		${L_logline_levelname:+--priority="user.$L_logline_levelname"} \
		--skip-empty \
		-- "$L_logline"
}

# shellcheck disable=SC2140
# @description main logging entrypoint
# @option -s <int> Increment stacklevel by this much
# @option -l <int|string> loglevel to print log line as
# @arg $@ any log arguments
# @return 0 if nothing was logged, or the exit status of formatter && outputter functions.
L_log() {
	local OPTIND OPTARG OPTERR _L_opt _L_stacklevel=1 \
		L_logline_levelno="$L_LOGLEVEL_INFO" \
		L_logline=""
	while getopts :s:l: _L_opt; do
		case "$_L_opt" in
		s) _L_stacklevel=$((OPTARG + _L_stacklevel)) ;;
		l) L_log_level_to_int_to L_logline_levelno "$OPTARG" ;;
		*) break ;;
		esac
	done
	if _L_log_is_enabled_for "$L_logline_levelno"; then
		shift "$((OPTIND-1))"
		if (($#)); then
			local \
				L_logline_stacklevel="$_L_stacklevel" \
				L_logline_funcname="${FUNCNAME[_L_stacklevel]-main}" \
				L_logline_source="${BASH_SOURCE[_L_stacklevel-1]}" \
				L_logline_lineno="${BASH_LINENO[_L_stacklevel-1]}" \
				L_logline_levelname="${L_LOGLEVEL_NAMES[L_logline_levelno]:-}"
			if ${_L_logconf_selecteval:+eval} ${_L_logconf_selecteval:+"$_L_logconf_selecteval"}; then
				# Detect color.
				if [[ -n "${_L_logconf_color:-}" ]]; then
					local L_logline_color="$_L_logconf_color"
				elif L_term_has_color 2; then
					local L_logline_color=1
				else
					local L_logline_color=""
				fi
				# Should set L_logline from "$@"
				eval "${_L_logconf_formateval:-L_log_format_default \"\$@\"}" &&
					eval "${_L_logconf_outputeval:-L_log_output_to_stderr}"
			fi
		fi
	fi
}

# @description output a critical message
# @option -s <int> stacklevel increase
# @arg $1 message
L_critical() {
	L_log -s 1 -l "$L_LOGLEVEL_CRITICAL" "$@"
}

# @description output a error message
# @option -s <int> stacklevel increase
# @arg $1 message
L_error() {
	L_log -s 1 -l "$L_LOGLEVEL_ERROR" "$@"
}

# @description output a warning message
# @option -s <int> stacklevel increase
# @arg $1 message
L_warning() {
	L_log -s 1 -l "$L_LOGLEVEL_WARNING" "$@"
}

# @description output a notice
# @option -s <int> stacklevel increase
# @arg $1 message
L_notice() {
	L_log -s 1 -l "$L_LOGLEVEL_NOTICE" "$@"
}

# @description output a information message
# @option -s <int> stacklevel increase
# @arg $1 message
L_info() {
	L_log -s 1 -l "$L_LOGLEVEL_INFO" "$@"
}

# @description output a debugging message
# @option -s <int> stacklevel increase
# @arg $1 message
L_debug() {
	L_log -s 1 -l "$L_LOGLEVEL_DEBUG" "$@"
}

# @description output a tracing message
# @option -s <int> stacklevel increase
# @arg $1 message
L_trace() {
	L_log -s 1 -l "$L_LOGLEVEL_TRACE" "$@"
}

# @description Output a critical message and exit the script with 2.
# @arg $@ L_critical arguments
L_fatal() {
	L_critical -s 1 "$@"
	exit 2
}

# @description log a command and then execute it
# Is not affected by L_dryrun variable.
# @arg $@ command to execute
L_logrun() {
	L_log -s 1 "+ $*"
	"$@"
}

# @description Output a green information message
# @option -s <int>
# @option -l <level>
# @arg $1 message
L_ok() {
	local OPTIND OPTARG OPTERR o a=()
	while getopts s:l: o; do
		case $o in
			s) a+=(-s "$OPTARG") ;;
			l) a+=(-l "$OPTARG") ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if (($# <= 1)); then
		set -- "$L_GREEN%s$L_RESET" "${1:-}"
	else
		set -- "$L_GREEN$1$L_RESET" "${@:2}"
	fi
	L_log -s 1 -l "$L_LOGLEVEL_INFO" "${a[@]}" "$@"
}

# @description set to 1 if L_run should not execute the function.
L_dryrun=${L_dryrun:-0}

# @description Logs the quoted argument with a leading +.
# if L_dryrun is nonzero, executes the arguments.
# @option -l <loglevel> Set loglevel.
# @option -s <stacklevel> Increment stacklevel by this number.
# @option -h Print this help and return 0.
# @arg $@ command to execute
# @env L_dryrun
L_run() {
	local OPTIND OPTARG OPTERR _L_opt _L_logargs=()
	while getopts l:s:h _L_opt; do
		case $_L_opt in
			l) _L_logargs+=(-l "$OPTARG") ;;
			s) _L_logargs+=(-s "$OPTARG") ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	printf -v _L_opt " %q" "$@"
	if ((L_dryrun)); then
		_L_logargs+=("DRYRUN: +$_L_opt")
	else
		_L_logargs+=("+$_L_opt")
	fi
	L_log -s 1 "${_L_logargs[@]}"
	if ((!L_dryrun)); then
		"$@"
	fi
}

# ]]]
# sort [[[
# @section sort
# @description Array sorting function.

# @description Shuffle an array
# @arg $1 array nameref
L_shuf_bash() {
	local -n _L_arr="$1" || return 2
	local _L_i _L_j _L_tmp
	# RANDOM range is 0..32767
	for ((_L_i=${#_L_arr[@]}-1; _L_i; --_L_i)); do
		# _L_j=$(( ((_L_i < 32768 ? 0 : (_L_i < 1073741824 ? 0 : RANDOM << 30) | RANDOM << 15) | RANDOM) % _L_i ))
		_L_j=$(( RANDOM % _L_i ))
		_L_tmp=${_L_arr[_L_i]}
		_L_arr[_L_i]=${_L_arr[_L_j]}
		_L_arr[_L_j]=$_L_tmp
	done
}

# @description Shuffle an array using shuf command
# @option -z --zero-terminated use zero separated stream with shuf -z
# @arg $* any options are forwarded to shuf command
# @arg $-1 array nameref
L_shuf_cmd() {
	local _L_arr="${*: -1}[@]" _L_z=""
	if L_args_contain -z "${@:1:$#-1}" || L_args_contain --zero-terminated "${@:1:$#-1}"; then
		_L_z=-z
	fi
	L_array_pipe ${_L_z:+"$_L_z"} "${*: -1}" shuf "${@:1:$#-1}" -e ${!_L_arr:+"${!_L_arr}"}
}

# @description Shuffle an array
# @arg $1 array nameref
L_shuf() {
	if L_hash shuf; then
		L_shuf_cmd "$@"
	else
		L_shuf_bash "$@"
	fi
}

# shellcheck disable=SC2030,SC2031,SC2035
# @see L_sort_bash
_L_sort_bash_in() {
	local _L_start="$1" _L_end="$2" _L_left _L_right _L_pivot _L_tmp
	if (( _L_start < _L_end )); then
		_L_left=$((_L_start + 1))
		_L_right=$_L_end
		_L_pivot=${_L_array[_L_start]}
		while (( _L_left < _L_right )); do
			if ${_L_sort_reverse[@]+"${_L_sort_reverse[@]}"} "$_L_sort_compare" "$_L_pivot" "${_L_array[_L_left]}"; then
				(( ++_L_left, 1 ))
			elif ${_L_sort_reverse[@]+"${_L_sort_reverse[@]}"} "$_L_sort_compare" "${_L_array[_L_right]}" "$_L_pivot"; then
				(( --_L_right, 1 ))
			else
				_L_tmp=${_L_array[_L_left]}
				_L_array[_L_left]=${_L_array[_L_right]}
				_L_array[_L_right]=$_L_tmp
			fi
		done
		if ${_L_sort_reverse[@]+"${_L_sort_reverse[@]}"} "$_L_sort_compare" "$_L_pivot" "${_L_array[_L_left]}"; then
			_L_tmp=${_L_array[_L_left]}
			_L_array[_L_left]=${_L_array[_L_start]}
			_L_array[_L_start]=$_L_tmp
			(( --_L_left, 1 ))
		else
			(( --_L_left, 1 ))
			_L_tmp=${_L_array[_L_left]}
			_L_array[_L_left]=${_L_array[_L_start]}
			_L_array[_L_start]=$_L_tmp
		fi
		_L_sort_bash_in "$_L_start" "$_L_left"
		_L_sort_bash_in "$_L_right" "$_L_end"
	fi
}

# @description default nonnumeric compare function
_L_sort_compare() { [[ "$1" > "$2" ]]; }
# @description default numeric compare function
_L_sort_compare_numeric() { (( $1 > $2 )); }

# @description Quicksort an array in place in pure bash.
# @see L_sort
# @option -z ignored. Always zero sorting
# @option -n numeric sort, otherwise lexical
# @option -r reverse sort
# @option -c <compare> custom compare function that returns 0 when $1 > $2 and 1 otherwise
# @option -h Print this help and return 0.
# @arg $1 array nameref
L_sort_bash() {
	local _L_sort_numeric=0 OPTIND OPTARG OPTERR _L_c _L_array _L_sort_compare="_L_sort_compare" _L_sort_reverse=()
	while getopts znrc:h _L_c; do
		case $_L_c in
			z) ;;
			n) _L_sort_compare="_L_sort_compare_numeric" ;;
			r) _L_sort_reverse=("L_not") ;;
			c) _L_sort_compare="$OPTARG" ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_func_assert "wrong number of arguments" test "$#" = 1 || return 2
	if ((!L_HAS_NAMEREF)); then
		_L_c="$1[@]"
		_L_array=(${!_L_c+"${!_L_c}"})
	else
		local -n _L_array="$1" || return 2
	fi
	_L_sort_bash_in 0 "$((${#_L_array[@]}-1))"
	if ((!L_HAS_NAMEREF)); then
		L_array_assign "$1" ${_L_array[@]+"${_L_array[@]}"}
	fi
}

# @description Sort an array using sort command.
# Even in most optimized code that I could write for bash sorting,
# still executing sort command is faster.
# The difference becomes significant for large arrays.
# Sorting 100 element array with bash is 0.049s and with sort is 0.022s.
# @option -z --zero-terminated use zero separated stream with sort -z
# @option -n numeric sort
# @arg $* any options are forwarded to sort command
# @arg $-1 last argument is the array nameref
# @example
#    arr=(5 2 5 1)
#    L_sort_cmd -n arr
#    echo "${arr[@]}"  # 1 2 5 5
L_sort_cmd() {
	if L_args_contain -z "${@:1:$#-1}" || L_args_contain --zero-terminated "${@:1:$#-1}"; then
		L_array_pipe -z "${*: -1}" sort "${@:1:$#-1}"
	else
		L_array_pipe "${*: -1}" sort "${@:1:$#-1}"
	fi
}

# @description Sort a bash array.
# If sort command exists, use L_sort_cmd, otherwise use L_sort_bash.
# If you have a custom sorter, use L_sort_bash, otherwise prefer L_sort_cmd for speed.
# @option -z Use zero separated stream with sort -z
# @option -n numeric sort
# @option -r reverse sort
# @arg $1 <var> array nameref
# @see L_sort_bash
# @see L_sort_cmd
L_sort() {
	if L_hash sort; then
		L_sort_cmd "$@"
	else
		L_sort_bash "$@"
	fi
}

# ]]]
# trap [[[
# @section trap

# @description Prints traceback
# @arg [$1] int stack offset to start from (default: 0)
# @arg [$2] int number of lines to show around the line (default: 2)
# @example:
#   Example traceback:
#   Traceback from pid 3973390 (most recent call last):
#     File ./bin/L_lib.sh, line 2921, in main()
#   2921 >> _L_lib_main "$@"
#     File ./bin/L_lib.sh, line 2912, in _L_lib_main()
#   2912 >>                 "test") _L_lib_run_tests "$@"; ;;
#     File ./bin/L_lib.sh, line 2793, in _L_lib_run_tests()
#   2793 >>                 "$_L_test"
#     File ./bin/L_lib.sh, line 891, in _L_test_other()
#   891  >>                 L_unittest_eq "$max" 4
#     File ./bin/L_lib.sh, line 1412, in L_unittest_eq()
#   1412 >>                 _L_unittest_showdiff "$1" "$2"
#     File ./bin/L_lib.sh, line 1391, in _L_unittest_showdiff()
#   1391 >>                 sdiff <(cat <<<"$1") - <<<"$2"
L_print_traceback() {
	L_color_detect
	local i s l tmp offset=${1:-0} around=${2:-2}
	echo "${L_CYAN:-}Traceback from pid ${BASHPID:-$$} (most recent call last):${L_RESET:-}"
	for ((i = ${#BASH_SOURCE[@]} - 1; i > offset; --i)); do
		s=${BASH_SOURCE[i]}
		l=${BASH_LINENO[i - 1]}
		printf "  File %s%q%s, line %s%d%s, in %s()\n" \
			"$L_CYAN" "$s" "$L_RESET" \
			"${L_BLUE}${L_BOLD}" "$l" "$L_RESET" \
			"${FUNCNAME[i]}"
		if ((around >= 0)) && [[ -r "$s" ]]; then
			if ((L_HAS_MAPFILE)); then
				local min j lines cur cnt
				((min=l-around-1, min=min<0?0:min, cnt=around*2+1, cnt=cnt<0?0:cnt ,1))
				if ((cnt)); then
					mapfile -s "$min" -n "$cnt" -t lines <"$s"
					for ((j= 0 ; j < cnt && j < ${#lines[@]}; ++j)); do
						cur=
						if ((min+j+1==l)); then
							cur=yes
						fi
						printf "%s%-5d%s%3s%s%s\n" \
							"$L_BLUE$L_BOLD" \
							"$((min+j+1))" \
							"$L_COLORRESET" \
							"${cur:+">> $L_RED"}" \
							"${lines[j]}" \
							"${cur:+"$L_COLORRESET"}"
					done
				fi
			elif L_hash awk; then
				# shellcheck disable=1004
				awk \
					-v line="$l" \
					-v around="$((around + 1))" \
					-v RED="$L_RED" \
					-v COLORLINE="${L_BLUE}${L_BOLD}" \
					-v RESET="$L_RESET" \
					'NR > line - around && NR < line + around {
						printf "%s%-5d%s%3s%s%s\n", \
							COLORLINE, NR, RESET, \
							(NR == line ? ">> " RED : ""), \
							$0, \
							(NR == line ? RESET : "")
					}' "$s"
			fi
		fi
	done
}

# @description Print simple traceback using builtin caller command.
L_print_caller() {
	local i
	# local -; set -x
	# declare -p FUNCNAME BASH_LINENO BASH_SOURCE
	for ((i = ${#FUNCNAME[@]} - 2; i >= 0; i--)); do
		caller "$i"
	done
}

# @description Callback to be exectued on ERR trap that prints just the caller.
# @example
#   trap 'L_trap_err_small' ERR
L_trap_err_small() {
	L_critical "fatal error on $(caller)"
}

# description Callback to be exectued on ERR trap that prints a traceback and exits.
# @arg $1 int exit code
# @example
#    trap 'L_trap_err $?' ERR
#    trap 'L_trap_err $?' EXIT
L_trap_err() {
	if ((L_HAS_LOCAL_DASH)); then local -; fi
	set +x
	# Workaround for read EOF combo tripping traps
	if ((!$1)); then
		return "$1"
	fi
	{
		echo
		L_print_traceback 1
		L_critical "Command returned with non-zero exit status: $1"
	} >&2 || :
	L_trap_get_v EXIT
	case "$L_v" in 'L_trap_err $?'|'L_trap_err "$?"')
		trap - EXIT
	esac
	exit "$1"
}

# @description Enable ERR trap with L_trap_err as callback
# set -eEo functrace and register trap 'L_trap_err $?' ERR.
# @example
#  L_trap_err_enable
L_trap_err_enable() {
	set -eEo functrace
	trap 'L_trap_err "$?"' ERR
}

# @description Disable ERR trap
# @example
#   L_trap_err_disable
L_trap_err_disable() {
	trap - ERR
}

# @description If set -e is set and ERR trap is not set, enable ERR trap with L_trap_err as callback
# @example
#    L_trap_err_init
L_trap_err_init() {
	if [[ $- == *e* && -z "$(trap -p ERR)" ]]; then
		L_trap_err_enable
	fi
}

# @description String of trap numbers and names separated by spaces.
# Extracted from trap -l output.
# @see _L_TRAPS_init
# _L_TRAPS=""

# shellcheck disable=SC2329
# @description initialize _L_TRAPS variable
# @set _L_TRAPS
# @see https://github.com/bminor/bash/blob/a8a1c2fac029404d3f42cd39f5a20f24b6e4fe4b/trap.h#L40
_L_TRAPS_init() {
	# Convert the output of trap -l into list of trap names.
	_L_TRAPS=$(trap -l)
	local max=${_L_TRAPS%)*} IFS=$' \t\n'
	max=${max##*[^0-9]}
	#
	# Word splitting executes in 0.003s, but ${//[$'\t\n']/ } takes 0.2seconds?? on bash 4.1.
	# shellcheck disable=SC2086
	printf -v _L_TRAPS " %s" "0 EXIT" ${_L_TRAPS//)} "$((max+1)) DEBUG $((max+2)) ERR $((max+3)) RETURN "
	# _L_TRAPS=" 0 EXIT ${_L_TRAPS//[$'\t\n']/ } $((max+1)) DEBUG $((max+2)) ERR $((max+3)) RETURN "
	#
	# shellcheck disable=SC2317
	_L_TRAPS_init() { :; }
}

# @description Return an array of all trap names. Index is the trap name number.
# @option -v <var>
L_trap_names() { L_handle_v_array "$@"; }
L_trap_names_v() {
	_L_TRAPS_init
	L_v="${_L_TRAPS// [0-9] / }"
	L_v="${L_v// [0-9][0-9] / }"
	eval "L_v=($L_v)"
}

# @description Convert trap name to number.
# The DEBUG ERROR and RETURN traps have a number as reported by $BASH_TRAPSIG inside the handler,
# but the number can't be used to register the trap with trap command.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 trap name or trap number
L_trap_to_number() { L_handle_v_scalar "$@"; }
L_trap_to_number_v() {
	case "$1" in
	EXIT) L_v=0 ;;
	DEBUG|ERR|RETURN)
		_L_TRAPS_init
		L_v=${_L_TRAPS%%" $1 "*}
		if [[ "$L_v" == "$_L_TRAPS" ]]; then
      L_func_error "trap $1 not found"; return 1
    fi
		L_v=${L_v##* }
		;;
	[0-9]*)
		_L_TRAPS_init
		if [[ "$_L_TRAPS" != *" $1 "* ]]; then
      L_func_error "trap $1 not found"; return 1
    fi
		L_v=$1
		;;
	[A-Z][A-Z]*)
		_L_TRAPS_init
		L_v=${_L_TRAPS%%" SIG${1#SIG} "*}
		if [[ "$L_v" == "$_L_TRAPS" ]]; then
      L_func_error "trap $1 not found"; return 1
    fi
		L_v=${L_v##* }
		;;
	*) return 1
	esac
}

# @description convert trap number to trap name
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 signal name or signal number
# @example L_trap_to_name -v var 0 && L_assert '' test "$var" = EXIT
L_trap_to_name() { L_handle_v_scalar "$@"; }
L_trap_to_name_v() {
	case "$1" in
	0) L_v=EXIT ;;
	DEBUG|RETURN|EXIT|ERR) L_v="$1" ;;
	[0-9]*)
		_L_TRAPS_init
		L_v=${_L_TRAPS##*" $1 "}
		if [[ "$L_v" == "$_L_TRAPS" ]]; then
			L_func_error "trap $1 not found"; return 1
		fi
		L_v=${L_v%% *}
		;;
	[A-Z][A-Z][A-Z]*)
		_L_TRAPS_init
		L_v="SIG${1/#SIG}"
		if [[ "$_L_TRAPS" != *" $L_v "* ]]; then
			L_func_error "trap $1 not found" ; return 1
		fi
		;;
	*) return 1
	esac
}

# @description Get the current value of trap
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 <str|int> signal name or number
# @example
#   trap 'echo hi' EXIT
#   L_trap_get -v var EXIT
#   L_assert '' test "$var" = 'echo hi'
L_trap_get() { L_handle_v_scalar "$@"; }
if ((L_HAS_TRAP_P)); then
L_trap_get_v() {
	L_v=$(trap -P "$1")
}
else
	L_trap_get_v() {
		L_v=$(trap -p "$1") &&
			local -a _L_tmp="($L_v)" &&
			L_v=${_L_tmp[2]:-}
	}
fi

# @description Add a newline and the command to the trap value.
# @arg $1 str command to execute
# @arg $2 str signal to handle
# @see L_trap_pop
# shellcheck disable=SC2064
L_trap_push() {
	local L_v i
	for i in "${@:2}"; do
		L_trap_get_v "$i" &&
			trap "${L_v:+"$L_v"$'\n'}$1" "$i" ||
			return 1
	done
}

# @description Remove a line from the trap value from the end up until the last newline.
# @arg $1 str signal to handle
# @see L_trap_push
# shellcheck disable=SC2064
L_trap_pop() {
	local L_v &&
	L_trap_get_v "$1" &&
		if [[ "$L_v" == *$'\n'* ]]; then
			trap "${L_v%$'\n'*}" "$1"
		else
			trap - "$1"
		fi
}

# @description Trap function with reversed order of arguments, to force expansions upon calling.
# @arg $1 Space or comma separated list of signal names or numbers.
# @arg $@ Action to execute.
L_trap() {
	local v s
	printf -v v " %q" "${@:2}"
	IFS=$' \r\t\n,' read -r -a s <<<"$1"
	# shellcheck disable=SC2064
	trap "${v# }" "${s[@]}"
}

# ]]]
# finally [[[
# @section finally
# @description
# Properly preserve exit status for parent processes.
# https://www.cons.org/cracauer/sigint.html
# Re-signaling does not work properly on specific signals.
# Re-signaling does not work properly in subshells and subshell exits with 0.
#
# @description Array of commands to execute on EXIT.
# _L_finally_arr=()
#
# @description Array of commands to execute on function returns.
# When a function returns at stack depth given by ${#BASH_LINENO[@]}
# the _L_finally_return[${#BASH_LINENO[@]}] should be executed.
# _L_finally_return=()
#
# @description BASHPID that registered traps.
# _L_finally_pid=""
#
# @description Holds signal received inside a critical section.
# [0] - signal name
# [1] - signal number
# _L_finally_pending=()
#
# @description Currently handled signal name.
# Special values: RETURN EXIT POP NONE
# POP - when calling from L_finally_pop
# NONE - used inside critical section.
# L_SIGNAL=""
#
# @description Currently handled signal number.
# Unset when handling RETURN or POP.
# 0 for EXIT trap.
# L_SIGNUM=""
#
# @description The value of $? as expanded by trap.
# L_SIGRET=""

# @description L_finally RETURN handler.
# @arg $1 The value of $?.
# @arg $2 The value of $BASH_COMMAND.
L_finally_handle_return() {
	# Not checking if the return handler exists. It is done with :+ expansion straight in RETURN trap.
  local L_SIGNAL=RETURN L_SIGRET="$1" _L_BASH_COMMAND="${2:-}"
  if [[ "$_L_BASH_COMMAND" == ". "* || "$_L_BASH_COMMAND" == "source "* ]]; then
  	# https://stackoverflow.com/a/79783255/9072753
  	# Handle it up the stack.
		eval "${_L_finally_return[${#BASH_LINENO[*]}]:-}"
		unset -v "_L_finally_return[$((${#BASH_LINENO[*]}))]"
	else
		eval "${_L_finally_return[${#BASH_LINENO[*]}-1]}"
		unset -v "_L_finally_return[$((${#BASH_LINENO[*]}-1))]"
	fi
	#
	if ((${_L_finally_pending[@]:+1})); then
		unset -v L_SIGNAL
		kill -"${_L_finally_pending[0]}" "$_L_finally_pid"
		exit "$((128+_L_finally_pending[1]))"
	fi
}

# @description L_finally EXIT handler.
L_finally_handle_exit() {
  local L_SIGNAL=EXIT L_SIGNUM=0 L_SIGRET="${1:-}"
	${_L_finally_arr[@]+eval} ${_L_finally_arr[@]+"${_L_finally_arr[@]}"}
	# During handling exit trap we received a signal. Try to preserve the exit code.
	if ((${_L_finally_pending[@]:+1})); then
		trap - "${_L_finally_pending[0]}"  # _L_finally_arr executed above already.
		kill -"${_L_finally_pending[0]}" "$_L_finally_pid"
		exit "$((128+_L_finally_pending[1]))"
	fi
	trap - RETURN EXIT
}

# @description L_finally signal handler.
# @arg $1 The trap signal name to handle.
# @arg $2 The trap signal number to handle.
L_finally_handle_signal() {
	if [[ -n "${L_SIGNAL:-}" ]]; then
		if ((${_L_finally_pending[@]:+1})); then
  		trap - "$1" EXIT
			L_critical "While handling $L_SIGNAL received $1 after ${_L_finally_pending[0]}. Exiting immidately"
  		kill -"$1" "$_L_finally_pid"
  		exit "$((128+$2))"
		else
			_L_finally_pending+=("$@")
		fi
	else
  	trap - EXIT  # _L_finally_arr executed below, no need for EXIT trap.
  	local L_SIGNAL="$1" L_SIGNUM="$2" L_SIGRET="${3:-}"
		${_L_finally_arr[@]+eval} ${_L_finally_arr[@]+"${_L_finally_arr[@]}"}
		trap - "$1"
  	kill -"$1" "$_L_finally_pid"
  	exit "$((128+$2))"
  fi
}

# @description List elements registered by L_finally.
L_finally_list() {
	local IFS=$'\n \t' data=() idx frame tmp first=1 pid s
	for idx in ${_L_finally_arr[@]:+"${!_L_finally_arr[@]}"}; do
		data[idx]=$'\x1d'"${_L_finally_arr[idx]}"
	done
	for frame in ${_L_finally_return[@]:+"${!_L_finally_return[@]}"}; do
		IFS=$'\t' read -r -a tmp <<<"${_L_finally_return[frame]}"
		for idx in "${tmp[@]}"; do
			idx=${idx%;}
			idx=${idx#*;}
			idx=${idx//[^0-9]}
			frame=$(( ${#BASH_LINENO[@]}-frame ))
			printf -v tmp "%q" "${BASH_SOURCE[frame]}"
			tmp="#$frame $tmp:${BASH_LINENO[frame]}:${FUNCNAME[frame]}()"
			data[idx]=$tmp${data[idx]}
		done
	done
	# declare -p _L_finally_arr _L_finally_return data
	s=$'Function\x1dAction\n'
  L_table -s $'\x1d' "$s${data[*]:+${data[*]}}"
}

# @description Register an action to be executed upon termination.
# The action will be executed only exactly once, even if the signal is received multiple times.
# The signal exit code of the program or subshell is preserved.
# The variable `$L_SIGNAL` is set to the currently handled signal name and available in action.
#
# @warning The function assumes full ownership of all trap values.
# This is needed to properly set traps accross PIDs and subshells and functions and on Bash below 5.2.
# Bash below 5.2 does _not_ execute EXIT trap in subshells after receiving a signal,
# so `L_finally` trap handler is registered on all possible signals.
# The signal exit status is preserved.
#
# @option -r Set trace attribute on the function and add RETURN trap to register the function on.
#            This does not work correctly with source and instead source RETURN trap will execute parent scope actions.
#            To mitigate this, wrap source in a function, for example use L_source.
# @option -s <int> Increment the stack offset for the RETURN trap by this number.
#            The RETURN trap handler will execute the action only if called from
#            the nth position in the stack relative to the current position. Default: 0
# @option -l Add action to be executed last, not first of the stack.
#            Calling L_finally_pop after registering such action is undefined.
# @option -R Force reregister all the traps. Unless this option, traps are only registered on the first call of a BASHPID.
# @option -v <var> Store the action index in the variable.
#            This index can be used with `L_finally_pop -i` to remove the action.
# @option -h Print this help and return 0.
# @arg $@ Action to execute. When action is missing, then only traps are registered.
# The command may not call `eval 'return'`. It would just return from the handler function.
#
# @see L_finally_pop
# @example
#    tmpf=$(mktemp)
#    L_finally rm "$tmpf"
#
#    calculate_something() {
#       local tmpf
#       tmpf=$(mktemp)
#       L_finally -r rm "$tmpf"
#       echo use tmpf >"$tmpf"
#       # tmpf automatically cleaned up once on RETURN or EXIT or signal, whichever comes first.
#    }
# shellcheck disable=SC2089,SC2090
L_finally() {
  local OPTIND OPTARG OPTERR _L_i _L_onreturn=0 _L_up=1 _L_first=1 _L_pid _L_v="" \
  	_L_register=0 L_v _L_idx _L_elem
  # Parse arguments.
  while getopts rs:lRv:h _L_i; do
    case "$_L_i" in
    r) _L_onreturn=1 ;;
    s) _L_up=$((OPTARG + _L_up)) ;;
    l) _L_first=0 ;;
    R) _L_register=1 ;;
    v) _L_v=$OPTARG ;;
    h) L_func_help; return 0 ;;
    *) L_func_error; return 2 ;;
    esac
  done
  shift "$((OPTIND-1))"
  #
  L_bashpid_to _L_pid
  if [[ "${_L_finally_pid:-}" != "$_L_pid" ]]; then
  	if [[ -n "${_L_finally_pid:-}" ]]; then
  		# Reset values inherited from parent shell.
  		_L_finally_pid=""
			_L_finally_arr=()
			_L_finally_return=()
			_L_finally_pending=()
			_L_register=1
		fi
	fi
  # Add element to our array variable.
	if (($#)); then
		# Calculate new element index. This is getting slower, but we assume we will have small number of elements.
  	_L_idx=( ${_L_finally_arr[@]:+"${!_L_finally_arr[@]}"} )
  	# We want to execute in reverse order. Thus we start inputting elements at a very high index and go down.
  	_L_idx=$(( ${_L_idx[_L_first ? 0 : ${#_L_idx[@]}-1]:-10000000000} + (_L_first ? -1 : 1) ))
  	# After calculating index, store it to the user, if he wants that.
  	if [[ -n "$_L_v" ]]; then
  		printf -v "$_L_v" "%s" "$_L_idx" || return 2
  	fi
  	# Create element to insert.
  	printf -v _L_elem "%q " "$@"
  	# Add trailing semicolon. eval joins arguments with spaces.
  	_L_finally_arr[_L_idx]="${_L_elem% };"
  	if ((_L_onreturn)); then
			# Apply the trace attribute to the function, so it runs RETURN trap.
			if ! declare -f -t "${FUNCNAME[_L_up]}"; then
				if [[ "${FUNCNAME[_L_up]}" == "source" ]];then
					# source disappears before calling RETURN trap.
					# see https://stackoverflow.com/a/79783255/9072753
					# Add empty element to one level up the stack to trigger trap RETURN ${+} expansion properly
					_L_finally_return[${#BASH_LINENO[@]}-_L_up-1]="${_L_finally_return[${#BASH_LINENO[@]}-_L_up-1]:-}"
				fi
			fi
			# declare -p BASH_LINENO FUNCNAME BASH_SOURCE _L_up >&2
			# Add element to the return array. Index loop is unrolled for speed.
  		_L_elem="${_L_elem% };unset -v \"_L_finally_arr[$_L_idx]\";"
  		_L_finally_return[${#BASH_LINENO[@]}-_L_up]=$'\t'"$_L_elem${_L_finally_return[${#BASH_LINENO[@]}-_L_up]:-$'\t'}"
			# Register the trap.
			# Use ${+} expansion to execute nothing when there is nothing to execute.
			trap '${_L_finally_return[${#BASH_LINENO[*]}]+L_finally_handle_return} ${_L_finally_return[${#BASH_LINENO[*]}]+"$?"} ${_L_finally_return[${#BASH_LINENO[*]}]+"$BASH_COMMAND"}' RETURN
  	fi
	fi
  # Initialize traps with our callback.
	if [[ "${_L_finally_pid:-}" != "$_L_pid" ]] || ((_L_register)); then
		_L_finally_pid="$_L_pid"
		#
    trap 'L_finally_handle_exit "$?"' EXIT || return 1
		# List of all signals that result in termination.
  	for _L_i in SIGABRT SIGALRM SIGBUS SIGFPE SIGHUP SIGILL SIGINT SIGIO SIGPIPE SIGPROF SIGPWR SIGQUIT SIGSEGV SIGSTKFLT SIGSYS SIGTERM SIGTRAP SIGUSR1 SIGUSR2 SIGVTALRM SIGXCPU SIGXFSZ SIGRTMAX SIGRTMAX-1 SIGRTMAX-10 SIGRTMAX-11 SIGRTMAX-12 SIGRTMAX-13 SIGRTMAX-14 SIGRTMAX-2 SIGRTMAX-3 SIGRTMAX-4 SIGRTMAX-5 SIGRTMAX-6 SIGRTMAX-7 SIGRTMAX-8 SIGRTMAX-9 SIGRTMIN SIGRTMIN+1 SIGRTMIN+10 SIGRTMIN+11 SIGRTMIN+12 SIGRTMIN+13 SIGRTMIN+14 SIGRTMIN+15 SIGRTMIN+2 SIGRTMIN+3 SIGRTMIN+4 SIGRTMIN+5 SIGRTMIN+6 SIGRTMIN+7 SIGRTMIN+8 SIGRTMIN+9; do
  		# If the trap exists, extract it's number.
  		if L_trap_to_number_v "$_L_i" 2>/dev/null; then
  			# shellcheck disable=SC2064
      	trap "L_finally_handle_signal $_L_i $L_v \"\$?\"" "$_L_i" || return 1
      fi
    done
  fi
}

# @description Execute and unregister the last action registered with L_finally.
# @option -n Do not execute the action, only remove.
# @option -i <index> Remove action of index <index>.
# @option -h Print this help and return 0.
# @see L_finally
# @return 1 if nothing was popped, 2 on invalid usage,
# otherwise return the exit status of the executed action.
L_finally_pop() {
	local OPTIND OPTARG OPTERR _L_pid _L_i _L_run=1 _L_idx="" _L_prefix="" _L_ret=0 _L_elem
	while getopts ni:h _L_i; do
		case "$_L_i" in
			n) _L_run=0 ;;
			i) _L_idx=$OPTARG ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_func_assert "too many arguments" test "$#" -eq 0 || return 2
	# Protect against invalid pid.
	L_bashpid_to _L_pid
	if [[ "$_L_finally_pid" != "$_L_pid" ]]; then
		L_func_error "nothing to pop in subshell"; return 1
	fi
	if [[ -z "$_L_idx" ]]; then
		if (( ${_L_finally_arr[@]:+${#_L_finally_arr[@]}}+0 == 0 )); then
			L_func_error "nothing to pop"; return 1
		fi
		# Find first(!) index.
		_L_idx=("${!_L_finally_arr[@]}")
	else
		if [[ -z "${_L_finally_arr[_L_idx]}" ]]; then
			L_func_error "index not found: $_L_idx"; return 2
		fi
	fi
	if ((_L_run)); then
		# shellcheck disable=SC2294
		local L_SIGNAL=POP
		eval "${_L_finally_arr[_L_idx]}" || _L_ret=$?
		unset -v "_L_finally_arr[$_L_idx]" L_SIGNAL
		if ((${_L_finally_pending[@]:+1})); then
			kill -"${_L_finally_pending[0]}" "$_L_finally_pid"
			exit "$((128+_L_finally_pending[1]))"
		fi
	else
		unset -v "_L_finally_arr[$_L_idx]"
	fi
	# Remove the index from _L_finally_return.
	_L_elem=";unset -v \"_L_finally_arr[$_L_idx]\";"$'\t'
	for _L_idx in ${_L_finally_return[@]:+"${!_L_finally_return[@]}"}; do
		if [[ "${_L_finally_return[_L_idx]}" == *"$_L_elem"* ]]; then
			_L_finally_return[_L_idx]=${_L_finally_return[_L_idx]#*$'\t'*"$_L_elem"}$'\t'${_L_finally_return[_L_idx]%$'\t'*"$_L_elem"*}
			break
		fi
	done
	return "$_L_ret"
}

# @description Execute a command inside a critical section.
# The signals will be raised after the command is finished.
# Prerequisite: L_finally has registered signal handlers.
# @arg $@ Command to execute.
L_finally_critical_section() {
	local pid
	L_bashpid_to pid
	if ((pid != ${_L_finally_pid:--1})); then
		# Register the handlers.
		L_finally
	fi
	local L_SIGNAL=NONE _L_ret=0
	"$@" || _L_ret=$?
	unset -v L_SIGNAL
	if ((${_L_finally_pending[@]:+1})); then
		kill -"${_L_finally_pending[0]}" "$_L_finally_pid"
		exit "$((128+_L_finally_pending[1]))"
	fi
	return "$_L_ret"
}

# ]]]
# with [[[
# @section with
# What we can do with finally? We can do destructors.

# @description Change to given directory.
# Register RETURN trap for parent function that will restore current working directory.
# @arg $1 Directory to cd into.
# @arg $2 Optional stack offset to add to RETURN trap.
L_with_cd() {
  L_finally -r -s "$((${2-}+1))" cd "$PWD" &&
    cd "$1"
}

# @description Create a temporary directory.
# Register RETURN trap for parent fuction that will remove the directory.
# @arg $1 Variable to assign the temporary file to.
# @arg $2 Optional stack offset to add to RETURN trap.
L_with_tmpfile_to() {
	local _L_v &&
    _L_v=$(mktemp "${TMPDIR:-/tmp}/${FUNCNAME[$((${2:-}+1))]//[^a-zA-Z0-9_]}.${FUNCNAME[0]}.XXXXXX") &&
    L_finally -r -s "$((${2-}+1))" rm -f "$_L_v" &&
    printf -v "$1" "%s" "$_L_v"
}

# @description Create a temporary directory.
# Register RETURN trap for parent fuction that will remove the directory.
# @arg $1 Variable to assign the temporary directory location to.
# @arg $2 Optional stack offset to add to RETURN trap.
L_with_tmpdir_to() {
  local _L_v &&
    _L_v=$(mktemp -d "${TMPDIR:-/tmp}/${FUNCNAME[$((${2:-}+1))]//[^a-zA-Z0-9_]}.${FUNCNAME[0]}.XXXXXX") &&
    L_finally -r -s "$((${2-}+1))" rm -rf "$_L_v" &&
    printf -v "$1" "%s" "$_L_v"
}

# @description Create a temporary directory and cd into it.
# Register RETURN trap that will remove the temporary directory
# and restore working directory on return from parent function.
# @arg $2 Optional stack offset to add to RETURN trap.
L_with_cd_tmpdir() {
  local tmpdir &&
    L_with_tmpdir_to tmpdir "$((${1-}+1))" &&
    L_with_cd "$tmpdir" "$((${1-}+1))"
}

_L_with_redirect_stdout_to_finally() {
  eval "exec 1>&$3"
  printf -v "$1" "%s" "$(< "$2")"
}

# @description Temporary redirect stdout to string.
# Non-forking command substition for the poor.
# @arg $1 Variable to capture stdout to.
# @arg $2 Optional stack offset to add to RETURN trap.
L_with_redirect_stdout_to() {
  local _L_tmpf _L_savfd &&
  	L_with_tmpfile_to _L_tmpf "$((${2:-}+1))" &&
    L_get_free_fd_to _L_savfd &&
    eval "exec $_L_savfd>&1 1>\$_L_tmpf" &&
    L_finally -r -s "$((${2:-}+1))" _L_with_redirect_stdout_to_finally "$1" "$_L_tmpf" "$_L_savfd"
}

# ]]]
# unittest [[[
# @section unittest
# @description Testing library
# Simple unittesting library that does simple comparison.
# Testing library for testing if variables are commands are returning as expected.
# @note rather stable
# @example
#    L_unittest_eq 1 1

# @description Integer that increases with every failed test.
L_unittest_fails=${L_unittest_fails:-0}
# @description Set this variable to 1 to exit immediately when a test fails.
L_unittest_exit_on_error=${L_unittest_exit_on_error:-0}
# @description Set this varaible to 1 to disable set -x inside L_unittest functions, Set to 0 to don't.
L_unittest_unset_x=${L_unittest_unset_x:-$L_HAS_LOCAL_DASH}

# @description internal unittest function
# @env L_unittest_fails
# @set L_unittest_fails
# @arg $1 message to print what is testing
# @arg $2 message to print on failure
# @arg $@ command to execute, can start with '!' to invert exit status
_L_unittest_internal() {
	local _L_ret=0 _L_invert=0 IFS=' ' up=1
	if [[ "$1" == -s ]]; then
		up=$(($2+1))
		shift 2
	fi
	#
	if [[ "$3" == "!" ]]; then
		_L_invert=1
		shift
	fi
	"${@:3}" || _L_ret=$?
	if ((_L_invert)); then
		_L_ret=$((!_L_ret))
	fi
	L_unittest_fails=${L_unittest_fails:-0}
	if ((_L_ret)); then
		echo -n "${L_RED}${L_BRIGHT}"
	fi
	# Find first function in the stack that does not start with _L_unittest_
	while ((++up)); do
		case "${FUNCNAME[up]:-}" in
		"") break ;;
		_L_unittest_*|L_unittest_*) ;;
		*) break ;;
		esac
	done
	echo -n "${FUNCNAME[up]}:${BASH_LINENO[up-1]}: test: ${1:-}: "
	#
	if ((_L_ret == 0)); then
		echo "${L_GREEN}OK${L_COLORRESET}"
	else
		((++L_unittest_fails))
		echo "command [${*:3}] FAILED!${2:+ }${2:-}${L_COLORRESET}"
		if ((L_unittest_exit_on_error)); then
			exit 17
		else
			return 17
		fi
	fi
} >&2

# @description
# Get all functions that start with a prefix specified with -P and execute them one by one.
# @option -h help
# @option -P <prefix> Get functions with this prefix to test
# @option -r <regex> filter tests with regex
# @option -E exit on error
# @option -p Run in parallel.
L_unittest_main() {
	set -euo pipefail
	local OPTIND OPTARG OPTERR _L_opt _L_tests=() _L_parallel=0
	while getopts "hr:EP:p" _L_opt; do
		case $_L_opt in
		P)
			L_log "Getting function with prefix %q" "${OPTARG}"
			L_list_functions_with_prefix -v _L_tests "$OPTARG"
			;;
		r)
			L_log "filtering tests with %q" "${OPTARG}"
			L_array_filter_eval _L_tests '[[ $1 =~ $OPTARG ]]'
			;;
		E) L_unittest_exit_on_error=1 ;;
		p) _L_parallel=1 ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_assert 'too many arguments' test "$#" = 0
	L_assert 'no tests matched' test "${#_L_tests[@]}" '!=' 0
	{
		# Run the tests.
		local _L_test _L_childs=()
		for _L_test in "${_L_tests[@]}"; do
			L_log "executing $_L_test"
			if ((_L_parallel)); then
				"$_L_test" &
				_L_childs+=("$!")
			else
				"$_L_test"
			fi
		done
		# When in parallel, collect exit codes.
		if ((_L_parallel)); then
			local _L_i _L_result=()
			for _L_i in "${!_L_childs[@]}"; do
				# Assign array separately for older bash.
				L_exit_to _L_i wait "${_L_childs[_L_i]}"
				_L_result+=("$_L_i")
			done
		fi
	}
	L_log "done testing: ${_L_tests[*]}"
	{
		if ((_L_parallel)); then
			# Print results separately, to see them last on the output.
			for _L_i in "${!_L_childs[@]}"; do
				if ((_L_result[_L_i])); then
					L_error "Test ${_L_tests[_L_i]} with pid ${_L_childs[_L_i]} failed with exit status ${_L_result[_L_i]}"
					((++L_unittest_fails))
				fi
			done
		fi
	}
	if ((L_unittest_fails)); then
		L_error "testing failed"
	else
		L_ok "testing success"
	fi
	if ((L_unittest_fails)); then
		exit "$L_unittest_fails"
	fi
}

# shellcheck disable=SC2035
# @description Check if command exits with specified exitcode.
# @arg $1 <int> exit code the command should exit with
# @arg $@ command to execute
L_unittest_checkexit() {
	local _L_ret=0 _L_shouldbe _L_invert=0
	_L_shouldbe=$1
	shift
	if [[ "$1" == "!" ]]; then
		_L_invert=1
		shift
	fi
	"$@" || _L_ret=$?
	(( _L_invert ? _L_ret = !_L_ret, 1 : 1 ))
	_L_unittest_internal "[$(L_quote_printf "$@")] exited with $_L_ret" "$_L_ret != $_L_shouldbe" \
		[ "$_L_ret" -eq "$_L_shouldbe" ]
}

# @description Check if command exits with 0
# @arg $@ command to execute
L_unittest_success() {
	L_unittest_checkexit 0 "$@"
}

# @description Check if command exits with non zero
# @arg $@ command to execute
L_unittest_failure() {
	L_unittest_checkexit 0 ! "$@"
}

# @description capture stdout and stderr into variables of a failed command
# @arg $1 var stdout and stderr output
# @arg $@ command to execute
L_unittest_failure_capture() {
	L_unittest_cmd -j -i -v "$@"
}

# @description helper function executed in exit trap
_L_unittest_cmd_exit_trap() {
	printf "${L_RED}${L_BOLD}unittested command [%q] running in current shell exited with %d. It should not exit. This means you have an error in the function you are testing. It needs to _return_ a status, not exit.${L_COLORRESET}\n" "${*:2}" "$1" >&2
	exit 1
}

# @description Test execution of a command and capture and test it's stdout and/or stderr output.
# Local variables used by this function start with _L_u*. Options with _L_uopt_*.
# This function optionally runs the command in the current shell or not depending on options.
# @option -h Print this help and return 0.
# @option -c Run in current execution environment, instead of using a subshell.
# @option -i Invert exit status. You can also use `!` or `L_not` in front of the command.
# @option -I Do not close stdin <&1 . By default it is closed.
# @option -f Expect the command to fail. Equal to `-i -j -N`.
# @option -N Redirect stdout of the command to >/dev/null.
# @option -j Redirect stderr to stdout of the command. 2>&1
# @option -x Run the command inside set -x
# @option -X Do not modify set -x
# @option -v <var> Store the output in variable instead of printing it.
# @option -r <regex> Compare output of the command with this regex.
# @option -o <str> Compare output of the command with this string.
# @option -e <int> Command should exit with this exit status (default: 0)
# @option -s <int> Stack up
# @arg $@ Command to execute.
# If a command starts with `!`, this implies -i and, if one of -v -r -o option is used, it implies -j.
# @example
#   echo Hello world /tmp/1
#   L_unittest_cmd -r 'world' grep world /tmp/1
#   L_unittest_cmd -r 'No such file or directory' ! grep something not_existing_file
L_unittest_cmd() {
	if ((L_unittest_unset_x)) && [[ $- = *x* ]]; then
		local -
		# set +x
		local _L_uopt_setx=1
	else
		local _L_uopt_setx=0
	fi
	local OPTIND OPTARG OPTERR _L_uc _L_uopt_invert=0 _L_uopt_capture=0 _L_uopt_regex='' _L_uopt_output='' _L_uopt_exitcode=0 _L_uopt_invert=0 _L_uret=0 _L_uout _L_uopt_curenv=0 _L_utrap=0 _L_uopt_v='' _L_uopt_stdjoin=0 _L_uopt_devnull=0 _L_uopt_closestdin=1 _L_uopt_up=0
	while getopts cifINjxXv:r:o:e:s:h _L_uc; do
		case $_L_uc in
		c) _L_uopt_curenv=1 ;;
		i) _L_uopt_invert=1 ;;
		f) _L_uopt_invert=1 _L_uopt_devnull=1 _L_uopt_stdjoin=1 ;;
		I) _L_uopt_closestdin=0 ;;
		N) _L_uopt_devnull=1 ;;
		j) _L_uopt_stdjoin=1 ;;
		x) _L_uopt_setx=1 ;;
		X) _L_uopt_setx=0 ;;
		v) _L_uopt_capture=1 _L_uopt_v=$OPTARG ;;
		r) _L_uopt_capture=1 _L_uopt_regex=$OPTARG ;;
		o) _L_uopt_capture=1 _L_uopt_output=$OPTARG ;;
		e) _L_uopt_exitcode=$OPTARG ;;
		s) _L_uopt_up=$OPTARG ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if [[ "$1" == "!" ]]; then
		shift
		_L_uopt_invert=1
		if ((_L_uopt_capture)); then
			_L_uopt_stdjoin=1
		fi
	fi
	if ! L_hash "$1"; then
		_L_unittest_internal -s "$_L_uopt_up" "command found: [$(L_quote_printf "$@")]" "" L_hash "$1"
	fi
	if ((_L_uopt_setx)); then
		set -- L_setx "$@"
	fi
	#
	printf -v _L_uc " %q" "$@"
	if ((_L_uopt_closestdin)); then
		printf -v _L_uc "%s <&-" "$_L_uc"
	fi
	if ((_L_uopt_devnull)); then
		printf -v _L_uc "%s >/dev/null" "$_L_uc"
	fi
	if ((_L_uopt_stdjoin)); then
		printf -v _L_uc "%s 2>&1" "$_L_uc"
	fi
	#
	if ((_L_uopt_curenv)); then
		L_trap_push '_L_unittest_cmd_exit_trap $? '"$(L_quote_printf "$@")" EXIT
		# shellcheck disable=2030,2093,1083
		if ((_L_uopt_capture)); then
			# Use temporary file
			local _L_utmpf
			_L_utmpf=$(mktemp)
			# No trap EXIT - literally next command removes the file.
			# shellcheck disable=SC2094
			{
				{
					rm "$_L_utmpf"
					eval "$_L_uc || _L_uret=\$?"
				} >"$_L_utmpf" 111<&-
				_L_uout=$(cat <&111)
			} 111<"$_L_utmpf"
		else
			eval "$_L_uc || _L_uret=\$?"
		fi
		L_trap_pop EXIT
	else  # _L_uopt_curenv
		_L_uc="set +e;trap - ERR;$_L_uc"
		if ((_L_uopt_capture)); then
			_L_uout=$( eval "$_L_uc" ) || _L_uret=$?
		else
			( eval "$_L_uc" ) || _L_uret=$?
		fi
	fi  # _L_uopt_curenv
	#
	# shellcheck disable=2035
	# Invert exit code if !
	if ((_L_uopt_invert)); then
		_L_uret=$(( !_L_uret ))
		# For nice output
		set -- "!" "$@"
	fi
	_L_unittest_internal -s "$_L_uopt_up" "[$(L_quote_printf "$@")] exited with $_L_uret =? $_L_uopt_exitcode" "${_L_uout+output $(printf %q "$_L_uout")}" [ "$_L_uret" -eq "$_L_uopt_exitcode" ]
	if [[ -n $_L_uopt_regex ]]; then
		if ! _L_unittest_internal -s "$_L_uopt_up" "[$(L_quote_printf "$@")] output $(printf %q "$_L_uout") matches $(printf %q "$_L_uopt_regex")" "" L_regex_match "$_L_uout" "$_L_uopt_regex"; then
			_L_unittest_showdiff "$_L_uout" "$_L_uopt_regex"
			return 1
		fi
	fi
	if [[ -n $_L_uopt_output ]]; then
		if ! _L_unittest_internal -s "$_L_uopt_up" "[$(L_quote_printf "$@")] output $(printf %q "$_L_uout") equal $(printf %q "$_L_uopt_output")" "" [ "$_L_uout" = "$_L_uopt_output" ]; then
			_L_unittest_showdiff "$_L_uout" "$_L_uopt_output"
			return 1
		fi
	fi
	if [[ -n "$_L_uopt_v" ]]; then
		printf -v "$_L_uopt_v" "%s" "$_L_uout"
	fi
}

# @description Use to present if two variables differ.
_L_unittest_showdiff() {
	L_assert "" test "$#" = 2
	if L_hash diff; then
		# if [[ "$1" =~ ^[[:print:][:space:]]*$ && "$2" =~ ^[[:print:][:space:]]*$ ]]; then
		diff <(cat -vet <<<"$1") <(cat -vet <<<"$2")
		# else
		# 	diff <( -p <<<"$1") <(xxd -p <<<"$2")
		# fi
	else
		printf -- "--- diff ---\nL: %q\nR: %q\n\n" "$1" "$2"
	fi
}

# @description Test if a variable has specific value.
# @arg $1 variable nameref
# @arg $2 value
L_unittest_vareq() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test "$#" = 2
	if ! _L_unittest_internal "\$$1=${!1:+$(printf %q "${!1}")} == $(printf %q "$2")" "" [ "${!1:-}" == "$2" ]; then
		_L_unittest_showdiff "${!1:-}" "$2"
		return 1
	fi
}

# @description Test if two strings are equal.
# @arg $1 one string
# @arg $2 second string
L_unittest_eq() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "${FUNCNAME[0]} received invalid number of arguments" test "$#" = 2
	if ! _L_unittest_internal "$(printf "%q == %q" "$1" "$2")" "" [ "$1" == "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description Test if array is equal to elements.
# @arg $1 array variable
# @arg $@ values
L_unittest_arreq() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test "$#" -ge 1
	local _L_arr _L_n _L_i IFS=' ' _L_tmp
	_L_n=$1
	_L_i="$1[@]"
	_L_tmp=$-
	set +u
	_L_arr=(${!_L_i+"${!_L_i}"})
	if [[ "$_L_tmp" == *u* ]]; then set -u; fi
	shift
	if ! _L_unittest_internal "$(printf "\${#%s[@]}=%q == %q" "$_L_n" "${#_L_arr[@]}" "$#")" "" \
			[ "${#_L_arr[@]}" == "$#" ]; then
		return 1
	fi
	_L_i=0
	while (($#)); do
		if ! _L_unittest_internal "$(printf "%s[%d]=%q == %q" "$_L_n" "$_L_i" "${_L_arr[_L_i]}" "$1")" "" \
				[ "${_L_arr[_L_i]}" == "$1" ]; then
			_L_unittest_showdiff "$1" "${_L_arr[_L_i]}"
			return 1
		fi
		((++_L_i))
		shift
	done
}

# @description Test two strings are not equal.
# @arg $1 one string
# @arg $2 second string
L_unittest_ne() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test "$#" = 2
	if ! _L_unittest_internal "$(printf %q "$1") != $(printf %q "$2")" "" [ "$1" != "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if a string matches regex
# @arg $1 string
# @arg $2 regex
L_unittest_regex() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test "$#" = 2
	if ! _L_unittest_internal "$(printf %q "$1") =~ $(printf %q "$2")" "" L_regex_match "$1" "$2"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description Test if a string contains other string.
# @arg $1 string
# @arg $2 needle
L_unittest_contains() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test "$#" = 2
	if ! _L_unittest_internal "$(printf %q "$1") == *$(printf %q "$2")*" "" L_strstr "$1" "$2"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# ]]]
# map [[[
# @section map
# @description Key value store without associative array support
# L_map consist of an null initial value.
# L_map stores keys and values separated by a tab, with an empty leading newline.
# Value is qouted by printf %q . Map key may not contain newline or tab characters.
#
#                     # empty initial newline
#     key<TAB>$'value'
#     key2<TAB>$'value2' # no trailing newline
#
# This format matches the regexes used in L_map_get for easy extraction using bash variable substitution.
# The map depends on printf %q never outputting a newline or a tab character, instead using $'\t\n' form.

# @description Initializes a map
# @arg $1 var variable name holding the map
# @arg $@ Pairs of keys and values to assign to the map.
# @example
#    local var
#    L_map_assign var a 1 b 2
L_map_assign() {
	local _L_map="$1"
	printf -v "$_L_map" "%s" ""
	shift
	while (($#)); do
		L_map_set_noremove "$_L_map" "$2" "$3"
		shift 2 || return 2
	done
}

# @description Clear a map
# @arg $1 var variable name holding the map
L_map_clear() {
	printf -v "$1" "%s" ""
}

# @description Clear a key of a map
# @arg $1 var map
# @arg $2 str key
# @example
#     L_map_assign var a 1
#     L_map_remove var a
#     if L_map_has var a; then
#       echo "a is set"
#     else
#       echo "a is not set"
#     fi
L_map_remove() {
	local _L_key
	printf -v _L_key "%q" "$2"
	if [[ "${!1}" == *$'\n'"$_L_key"$'\t'* ]]; then
		printf -v "$1" "\n%s%s" "${!1#*$'\n'"$_L_key"$'\t'*$'\n'}" "${!1%%$'\n'"$_L_key"$'\t'*}"
	fi
}

# @description Set a key in a map to value
# @arg $1 var map
# @arg $2 str key
# @arg $3 str value
# @example
#   L_map_assign var
#   L_map_set var a 1
#   L_map_set var b 2
L_map_set() {
	L_map_remove "$1" "$2"
	L_map_set_noremove "$@"
}

# @description Set a key in a map to value, potentially resulting in duplicate keys.
# @arg $1 var map
# @arg $2 str key
# @arg $3 str value
L_map_set_noremove() {
	# This code depends on that `printf %q` _never_ prints a newline, instead it does $'\n'.
	# I add key-value pairs in chunks with preeceeding newline.
	printf -v "$1" "%s\n%q\t%q\n" "${!1%$'\n'}" "$2" "${*:3}"
}

# @description Assigns the value of key in map.
# If the key is not set, then assigns default if given and returns with 1.
# You want to prefer this version of L_map_get
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 var map
# @arg $2 str key
# @arg [$3] str default
# @example
#    L_map_clear var
#    L_map_set var a 1
#    L_map_get -v tmp var a
#    echo "$tmp"  # outputs: 1
L_map_get() { L_handle_v_scalar "$@"; }
L_map_get_v() {
	printf -v L_v "%q" "$2"
	# Remove anything in front of the newline followed by key followed by space.
	# Because the key can't have newline not space, it's fine.
	L_v=${!1##*$'\n'"$L_v"$'\t'}
	# If nothing was removed, then the key does not exists.
	if [[ "$L_v" == "${!1}" ]]; then
		if (($# >= 3)); then
			L_v="${*:3}"
		else
			return 1
		fi
	else
		# Remove from the newline until the end and print with eval.
		# The key was inserted with printf %q, so it has to go through eval now.
		eval "L_v=${L_v%%$'\n'*}"
	fi
}

# @description
# @arg $1 var map
# @arg $2 str key
# @exitcode 0 if map contains key, nonzero otherwise
# @example
#     L_map_clear var
#     L_map_set var a 1
#     if L_map_has var a; then
#       echo "a is set"
#     fi
L_map_has() {
	local _L_key
	printf -v _L_key "%q" "$2"
	[[ "${!1}" == *$'\n'"$_L_key"$'\t'* ]]
}

# @description set value of a map if not set
# @arg $1 var map
# @arg $2 str key
# @arg $3 str default value
L_map_setdefault() {
	if ! L_map_has "$@"; then
		L_map_set "$@"
	fi
}

# @description Append value to an existing key in map
# @arg $1 var map
# @arg $2 str key
# @arg $3 str value to append
L_map_append() {
	local L_v
	if L_map_get_v "$1" "$2"; then
		L_map_set "$1" "$2" "$L_v${*:3}"
	else
		L_map_set "$1" "$2" "$3"
	fi
}

# @description List all keys in the map.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 var map
# @example
#   L_map_clear var
#   L_map_set var a 1
#   L_map_set var b 2
#   L_map_keys -v tmp var
#   echo "${tmp[@]}"  # outputs: 'a b'
L_map_keys() { L_handle_v_array "$@"; }
L_map_keys_v() {
	local _L_map
	_L_map=${!1}
	_L_map=${_L_map//$'\t'/ # }$'\n'
	local -a _L_tmp="($_L_map)"
	L_v=(${_L_tmp[@]+"${_L_tmp[@]}"})
}

# @description List all values in the map.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 var map
# @example
#    L_map_clear var
#    L_map_set var a 1
#    L_map_set var b 2
#    L_map_values -v tmp var
#    echo "${tmp[@]}"  # outputs: '1 2'
L_map_values() { L_handle_v_array "$@"; }
L_map_values_v() {
	local _L_map
	_L_map=${!1}
	_L_map=${_L_map//$'\n'/ # }
	_L_map=${_L_map//$'\t'/$'\n'}
	local -a _L_tmp="($_L_map)"
	L_v=(${_L_tmp[@]+"${_L_tmp[@]}"})
}

# @description List items on newline separated key value pairs.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 var map
# @example
#   L_map_clear var
#   L_map_set var a 1
#   L_map_set var b 2
#   L_map_items -v tmp var
#   echo "${tmp[@]}"  # outputs: 'a 1 b 2'
L_map_items() { L_handle_v_array "$@"; }
L_map_items_v() {
	local -a _L_tmp="(${!1})"
	L_v=("${_L_tmp[@]}")
	((${#_L_tmp[@]} % 2 == 0))
}

# @description Load all keys to variables with the name of $prefix$key.
# @arg $1 map variable
# @arg $2 prefix
# @arg $@ Optional list of keys to load. If not set, all are loaded.
# @example
#     L_map_clear var
#     L_map_set var a 1
#     L_map_set var b 2
#     L_map_load var PREFIX_
#     echo "$PREFIX_a $PREFIX_b"  # outputs: 1 2
L_map_load() {
	local IFS=$'\t' _L_key _L_val _L_tmp
	while read -r _L_key _L_val; do
		if [[ -n "$_L_key" ]]; then
			if (($# == 2)) || [[ $'\t'"${*:3}"$'\t' == *$'\t'"$_L_key"$'\t'* ]]; then
				eval "printf -v \"\$2\$_L_key\" %s $_L_val"
			fi
		fi
	done <<<"${!1}"
}

# @description Save all variables with prefix to a map.
# @arg $1 map variable
# @arg $2 prefix
# @example
#    L_map_clear var
#    PREFIX_a=1
#    PREFIX_b=2
#    L_map_save var PREFIX_
#    L_map_items -v tmp var
#    echo "${tmp[@]}"  # outputs: 'a 1 b 2'
L_map_save() {
	local _L_i IFS=$'\n'
	for _L_i in $(compgen -v "$2"); do
		L_map_set "$1" "${_L_i#"$2"}" "${!_L_i}"
	done
}

# ]]]
if ((L_HAS_ASSOCIATIVE_ARRAY)); then
# asa [[[
# @section asa
# @description Collection of function to work on associative array.
# Maybe will renamed to dict.
# "asa" sounds better than "assarray", less confusing than "asarray"
# and shorter that associative array.
# @note unstable

# @description Copy associative dictionary.
# Notice: the destination array is _not_ cleared.
# Slowish, O(N). Iterates of keys one by one.
# Use L_asa_assign
# @see L_asa_assign
# @arg $1 var Source associative array
# @arg $2 var Destination associative array
# @arg [$3] str Filter only keys with this regex
L_asa_copy() {
	L_assert "" test "$#" = 2 -o "$#" = 3
	L_assert "" L_var_is_associative "$1"
	L_assert "" L_var_is_associative "$2"
	local _L_key
	eval "_L_key=(\"\${!$1[@]}\")"
	for _L_key in "${_L_key[@]}"; do
		if (($# == 2)) || [[ "$_L_key" =~ $3 ]]; then
			eval "$2[\"\$_L_key\"]=\${$1[\"\$_L_key\"]}"
		fi
	done
}

# @description check if associative array has key
# @arg $1 associative array nameref
# @arg $2 key
L_asa_has() {
	L_var_is_set "$1[$2]"
}

# @description check if associative array is empty
# @arg $1 associative array nameref
L_asa_is_empty() {
	L_assert "" L_var_is_associative "$1"
	eval "(( \${#$1[@]} == 0 ))"
}

# @description Get value from associative array
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 associative array nameref
# @arg $2 key
# @arg [$3] optional default value
# @exitcode 1 if no key found and no default value
L_asa_get() { L_handle_v_scalar "$@"; }
L_asa_get_v() {
	if L_var_is_set "$1[$2]"; then
		eval "L_v=\${$1[\"\$2\"]}"
	elif (($# >= 3)); then
		L_v=$3
	else
		L_v=
		return 1
	fi
}

# @description get the length of associative array
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 associative array nameref
L_asa_len() { L_handle_v_scalar "$@"; }
L_asa_len_v() {
	L_assert "" L_is_valid_variable_name "$1"
	eval "L_v=\"\${#$1[@]}\""
}

# @description get keys of an associative array
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 associative array nameref
L_asa_keys() { L_handle_v_array "$@"; }
L_asa_keys_v() {
	L_assert "" test "$#" = 1
	L_assert "" L_is_valid_variable_name "$1"
	eval "L_v=(\"\${!$1[@]}\")"
}

# @description get keys of an associative array in a sorted
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 associative array nameref
L_asa_keys_sorted() { L_handle_v_array "$@"; }
L_asa_keys_sorted_v() {
	L_asa_keys_v "$1"
	L_sort L_v
}

if ((L_HAS_PRINTF_V_ARRAY)); then
# @description assign value to associative array
# You might think why this function exists?
# In case you have associative array name in a variable.
# @arg $1 <var> assoatiative array variable
# @arg $2 <str> key to assign to
# @arg $3 <str> value to assign
# @example
#    local -A map
#    printf -v "map[a]" "%s" val  # will fail in bash 4.0
#    L_asa_set map a val  # will work in bash4.0
L_asa_set() {
	printf -v "$1[$2]" "%s" "$3"
}
else
	L_asa_set() {
		L_assert "not a valid variable name: $1" L_is_valid_variable_name "$1"
		eval "$1[\$2]=\"\$3\""
	}
fi

# @description Copy associative dictionary
# Notice: the destination array is cleared.
# Much faster then L_asa_copy.
# Note: Arguments are in different order.
# @arg $1 var Destination associative array
# @arg $2 =
# @arg $3 var Source associative array
# @see L_asa_copy
# @see L_asa_dump
# @example
#   local -A map=([a]=b [c]=d)
#   local -A mapcopy=()
#   L_asa_assign mapcopy = map
L_asa_assign() {
	local L_v
	L_var_to_string_v "$3" || return 2
	eval "$1=$L_v"
}

# @description check if one associative array is equal to another
# @arg $1 associative array name
# @arg $2 associative array name
# @exitcode 0 if equal, 1 otherwise
# @example
#    local -A a=([a]=1 [b]=2)
#    local -A b=([a]=1 [b]=2)
#    if L_asa_cmp a b; then
#        echo "equal"
#    fi
L_asa_cmp() {
	local _L_asa L_v
	L_var_to_string -v _L_asa "$1" || return 2
	L_var_to_string_v "$2" || return 2
	[[ "$_L_asa" == "$L_v" ]]
}

# ]]]
fi
# argparse [[[
# @section argparse
# @description argument parsing in bash

# @description Print argument parsing error and exit.
# @env L_NAME
# @env _L_parser
# @exitcode 1
L_argparse_fatal() {
	if ((${_L_comp_enabled:-0})); then
		return
	fi
	L_argparse_print_usage -e "$@" >&2
	if L_is_true "${_L_parser_exit_on_error[1]:-1}"; then
		exit 1
	else
		return 1
	fi
}

# @description Split string preferably on whitespaces to keep specified maximum width.
# This only just saves 0.5ms compared to fmt -w.
# @option -v <var>
# @arg $1 maximum terminal width
# @arg $2 string to format
_L_argparse_fmt() { L_handle_v_scalar "$@"; }
_L_argparse_fmt_v() {
	local _L_line _L_ws=$'\t\n ' IFS=""
	L_v=""
	if [[ -n "$2" ]]; then
		while read -r _L_line; do
			while [[ "${#_L_line}" -gt $1 ]]; do
				if [[ "$_L_line" =~ ^(.{,$(($1-1))}[^$_L_ws])[$_L_ws]+(.*)$ ]]; then
					L_v+=${L_v:+$'\n'}${BASH_REMATCH[1]}
					_L_line=${BASH_REMATCH[2]}
				else
					L_v+=${L_v:+$'\n'}${_L_line::$1}
					_L_line=${_L_line:$1}
				fi
			done
			L_v+=${L_v:+$'\n'}$_L_line
		done <<<"$2"
	fi
}

# @description given two lists indent them properly
# This is used internally by L_argparse_print_help to
# align help message of options and arguments for ouptut.
# @arg $1 <var> output destination variable nameref
# @arg $2 <str> header of the help section
# @arg $3 <var> array of metavars of options
# @arg $4 <var> array of help messages of options
# @see https://github.com/python/cpython/blob/965c48056633d3f4b41520c8cd07f0275f00fb4c/Lib/argparse.py#L533
_L_argparse_print_help_indenter() {
	local _L_helps="$3[@]" _L_i _L_len max_header_length=0 _L_line _L_tmp help_position a b c columns="${COLUMNS:-80}" free_space diff header headerlen opthelp line cur_indent
	_L_helps=(${!_L_helps+"${!_L_helps}"})
	if ((${#_L_helps[@]} == 0)); then return; fi
	L_printf_append "$1" "\n%s\n" "$cblue$2$creset"
	# Any headers with short options?
	# Any headers with long options?
	# If there are, we can indent the -a --long option such that --long options start on the same column.
	local has_short_option=0 has_long_option=0
	for _L_i in "${!_L_helps[@]}"; do
		local header=${_L_helps[_L_i]%%$'\n'*}
		header=${header//$cdel}
		if [[ "$header" == --* || "$header" == *,\ --* ]]; then
			has_long_option=1
		fi
		if [[ "$header" == -[^-]* ]];then
			has_short_option=1
		fi
	done
	# Find max header length.
	for _L_i in "${!_L_helps[@]}"; do
		local header=${_L_helps[_L_i]%%$'\n'*}
		header=${header//$cdel}
		# If has both short and long options, indent long options to the right so they start on one column.
		if ((has_long_option && has_short_option)) && [[ "$header" == --* ]]; then
			_L_helps[_L_i]="    ${_L_helps[_L_i]}"
			local header=${_L_helps[_L_i]%%$'\n'*}
			header=${header//$cdel}
		fi
		if (( max_header_length < ${#header} )); then
			max_header_length=${#header}
		fi
	done
	# <header>  <help>
	#           | - help_position
	local help_position=24
	if (( help_position > max_header_length + 4 )); then help_position=$(( max_header_length + 4 )); fi
	if (( max_header_length + 4 < columns / 2 )); then help_position=$(( max_header_length + 4 )); fi
	local help_width=$(( columns - help_position - 2 ))
	# if ((help_width > 11)); then help_width=11; fi
	for _L_i in "${!_L_helps[@]}"; do
		local header="  ${_L_helps[_L_i]%%$'\n'*}"
		local headerlen=${header//$cdel}
		headerlen=${#headerlen}
		local opthelp=${_L_helps[_L_i]#*$'\n'}
		L_strip -v opthelp "$opthelp"
		if ((${#opthelp} == 0)); then
			# no help
			L_printf_append "$1" "%s\n" "$header"
		else
			if ((diff = help_position - headerlen, diff > 0 )); then
				# short header - start help on the same line with padding
				L_printf_append "$1" "%s" "$header"
				cur_indent=$diff
			else
				# longer header - start help on the next line
				L_printf_append "$1" "%s\n" "$header"
				cur_indent=$help_position
			fi
			if [[ -n "${COLUMNS:-}" && ( "$opthelp" == *$'\n'* || "${#opthelp}" -gt "$help_width" ) ]]; then
				# Replace whitespaces by a single space.
				# L_shopt_extglob L_eval "opthelp=\${opthelp//+([\$' \\t\\n'])/ }"
				# Use fmt for formatting if available.
				# shellcheck disable=SC2154
				_L_argparse_fmt -v opthelp "$help_width" "$opthelp"
			fi
			while IFS=$' \t\n' read -r line; do
				L_printf_append "$1" "%*s%s\n" "$cur_indent" "" "$line"
				cur_indent=$help_position
			done <<<"$opthelp"
		fi
	done
	#
	return
}

# @description percent format help message
# @arg $1 <var> Variable name containing text to print.
# @arg [$2] <int> if set to 1, format also %(default)s
_L_argparse_percent_format_help() {
	printf -v "$1" "%s" "${!1//%(prog)s/$_L_prog}"
	if ((${2:-0})); then
		printf -v "$1" "%s" "${!1//%(default)s/${_L_opt_default[_L_opti]:-}}"
	fi
}

# @description Get help text.
# @arg $1 <var> variable to assign
# @env _L_parser
_L_argparse_optspec_get_help() {
	local L_v=${_L_opt_help[_L_opti]:-}
	if [[ "$L_v" == "SUPPRESS" ]]; then
		return 1
	fi
	_L_argparse_percent_format_help L_v 1
	if L_is_true "${_L_opt_show_default[_L_opti]:-${_L_parser_show_default[_L_parseri]:-0}}" && L_var_is_set "_L_opt_default[_L_opti]"; then
		printf -v "$1" "%s(default: %q)" "$L_v${L_v:+ }" "${_L_opt_default[_L_opti]}"
	else
		printf -v "$1" "%s" "$L_v"
	fi
}

# @description Get metavar value or default.
# It is here as a function, for optimization.
# @arg $1 <var> variable to assign
# @env _L_parser
_L_argparse_optspec_get_metavar() {
	local L_v=${_L_opt_metavar[_L_opti]:-}
	if [[ -z "$L_v" ]]; then
		local -a _L_choices="(${_L_opt_choices[_L_opti]:-})"
		if ((${#_L_choices[@]})); then
			# infer metavar from choices
			local IFS=","
			L_v="{${_L_choices[*]}}"
		else
			L_v=${_L_opt_dest[_L_opti]}
		fi
		if [[ -n "${_L_opt__options[_L_opti]:-}" ]]; then
			L_strupper_v "$L_v"
		fi
	fi
	printf -v "$1" "%s" "$L_v"
}

# @description Get description for error message for a particular _L_optspec
# @arg $1 <var> variable to assign
# @env _L_parser
_L_argparse_optspec_get_description() {
	local -a _L_options="(${_L_opt__options[_L_opti]:-})"
	if ((${#_L_options[@]})); then
		local IFS=' '
		printf -v "$1" "%s" "${_L_options[*]}"
	else
		_L_argparse_optspec_get_metavar "$1"
	fi
}

# @description Get the usage string in help usage message for a particular _L_optspec
# @arg $1 <var> variable to append
_L_argparse_optspec_get_usagearg() {
	local _L_nargs=${_L_opt_nargs[_L_opti]} _L_metavar _L_ret
	_L_argparse_optspec_get_metavar _L_metavar
	local meta0=$cyellow$_L_metavar$creset meta1=$cyellow${_L_metavar[1]:-$_L_metavar}$creset
	case "$_L_nargs" in
	"?") _L_ret="[$meta0]" ;;
	"*") _L_ret="[$meta0 ...]" ;;
	"+") _L_ret="$meta0 [$meta1 ...]" ;;
	remainder) _L_ret="$meta0 ..." ;;
	0) _L_ret="" ;;
	[0-9]*)
		_L_ret="$meta0"
		while ((--_L_nargs)); do
			_L_ret+=" $meta1"
		done
		;;
	*) L_fatal "invalid nargs" ;;
	esac
	L_printf_append "$1" "%s" "${_L_ret:+ $_L_ret}"
}

# @description From a chained call of subparser find the full program name from the beginning of the command line.
# @arg $1 <var> place result into this variable
# @env _L_parseri
_L_argparse_parser_get_full_program_name() {
	# Find program name, also from chained subparsers.
	local _L_ret _L_i="$_L_parseri" _L_default _L_visited=""
	while :; do
		if ((_L_i == 1)); then
			_L_default=$L_NAME
		else
			_L_default=${_L_parser_name[_L_i]:-}
		fi
		_L_ret="${_L_parser_prog[_L_i]:-$_L_default}${_L_ret:+ $_L_ret}"
		if ((_L_i == 1)); then
			break
		fi
		{
			# Protect against endless loop.
			if [[ " $_L_visited " == *" $_L_i "* ]]; then
				_L_argparse_spec_fatal "internal error: nested cycle in subparsers"
			fi
			_L_visited=" $_L_i "
		}
		_L_i=${_L_parser__parent[_L_i]:-1}
	done
	printf -v "$1" "%s" "$_L_ret"
}

# shellcheck disable=2120
# @description Print help for current parser.
#
# Syntax:
#
# ```
# Usage: prog_name cmd1 cmd2 [-abcd] [+abcd] [--option1] [-o ARG] arg
#                                                                 ^^^  - _L_args_usage
#                                            ^^^^^^^^^^^^^^^^^^^^      - _L_options_usage
#                            ^^^^^^^ ^^^^^^                            - _L_options_usage_noargs
#        ^^^^^^^^^^^^^^^^^^^                                           - _L_prog
#        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  - usage string
# Options:
#   -o --option ARG     Help message
#                       ^^^^^^^^^^^^   - help message
#   ^^^^^^^^^^^^^^^                    - header
#   ^^^^^^^^^^^^^^^$'\n'^^^^^^^^^^^    - _L_usage_args_helps _L_usage_cmds_helps _L_options_helps
# ```
#
# @option -u print only usage, not full help
# @option -s Alias to -u
# @option -e Print this error message
# @option -h Print this help and return 0.
# @arg $@ error message to print
L_argparse_print_help() {
	local IFS=' '
	{
		# parse arguments
		local _L_short=0 OPTIND OPTARG OPTERR o _L_err=0
		while getopts useh o; do
			case "$o" in
				u|s) _L_short=1 ;;
				e) _L_err=1 ;;
				h) L_func_help; return 0 ;;
				*) L_func_error; return 2 ;;
			esac
		done
		shift "$((OPTIND-1))"
	}
	{
		if ((${_L_parser_color[1]:-1})); then
			L_color_detect
		else
			L_color_disable
		fi
		# Colors
		local cred=$'\x11' cgreen=$'\x12' cyellow=$'\x13' cblue=$'\x14' cpurple=$'\x15' ccyan=$'\x16' creset=$'\x1A' cdel=$'[\x11\x12\x13\x14\x15\x16\x10]'
	}
	local _L_prog
	_L_argparse_parser_get_full_program_name _L_prog
	{
		# stores all the stuff after usage
		local _L_help_help="" L_v="${_L_parser_description[_L_parseri]:-${_L_parser_help[_L_parseri]:-}}"
		if [[ -n "${L_v}" ]]; then
			L_strip_v "$L_v"
			_L_argparse_percent_format_help L_v
			_L_help_help+=$'\n'"$L_v"$'\n'
		fi
		local _L_opthelp _L_notrequired _L_metavar
	}
	{
		# Parse positional arguments
		local _L_args_usage=""
		local _L_usage_args_helps=()  # help messages of positional arguments
		local _L_usage_cmds_helps=()  # help messages of subparsers
		local _L_opti
		for _L_opti in ${_L_parser__argumentsi[_L_parseri]:-}; do
			if _L_argparse_optspec_get_help _L_opthelp; then
				_L_argparse_optspec_get_metavar _L_metavar
				if [[ "${_L_opt_action[_L_opti]}" == _subparser ]]; then
					local _L_nargs=${_L_opt_nargs[_L_opti]} _L_add="" COMMAND=${cgreen}COMMAND$creset ARGS=${cgreen}ARGS$creset
					case "$_L_nargs" in
					"+") _L_add+=" $COMMAND [$ARGS ...]" ;;
					"*") _L_add+=" [$COMMAND [$ARGS ...]]" ;;
					"?") _L_add+=" [$COMMAND]" ;;
					[0-9]*) _L_add+=" $COMMAND"; while ((--_L_nargs)); do _L_add+=" $ARGS"; done ;;
					*) L_fatal "invalid nargs: ${_L_opt_nargs[_L_opti]}" ;;
					esac
					_L_args_usage+="$_L_add"
					local subhelps=()
					case "${_L_opt__class[_L_opti]}" in
					subparser) _L_argparse_sub_subparser_get_helps subhelps ;;
					function) _L_argparse_sub_function_get_helps subhelps ;;
					*) L_fatal "invalid class: ${_L_opt__class[_L_opti]}" ;;
					esac
					for _L_i in "${subhelps[@]}"; do
						_L_usage_cmds_helps+=("$cgreen${_L_i%%$'\n'*}$creset"$'\n'"${_L_i##*$'\n'}")
					done
				else
					# argument
					local _L_metavar
					_L_argparse_optspec_get_metavar _L_metavar
					_L_argparse_optspec_get_usagearg _L_args_usage
					_L_usage_args_helps+=("$_L_metavar"$'\n'"$_L_opthelp")
				fi
			fi
		done
		_L_argparse_print_help_indenter _L_help_help "Arguments:" _L_usage_args_helps
		_L_argparse_print_help_indenter _L_help_help "Available commands:" _L_usage_cmds_helps
	}
	{
		# Parse options
		local _L_pc="${_L_parser_prefix_chars[_L_parseri]:--}"
		local _L_options_usage=""
		local _L_options_usage_noargs=()
		local _L_options_helps=()  # help messages of options
		for loop_required in 0 1; do
			if ((loop_required)); then
				local bl="" br=""
			else
				local bl="[" br="]"
			fi
			local _L_opti
			for _L_opti in ${_L_parser__optionsi[_L_parseri]:-}; do
				local _L_required=""
				L_exit_to_10 _L_required L_is_true "${_L_opt_required[_L_opti]:-0}"
				if ((_L_required == loop_required)); then
					if _L_argparse_optspec_get_help _L_opthelp; then
						local first_option=${_L_opt__options[_L_opti]%% *} option usagearg=""
						local _L_add="" tmp
						for option in ${_L_opt__options[_L_opti]}; do
							if [[ "${#option}" == 2 ]]; then
								_L_add+=${_L_add:+, }$cgreen$option$creset
							else
								_L_add+=${_L_add:+, }$ccyan$option$creset
							fi
						done
						_L_argparse_optspec_get_usagearg usagearg
						_L_options_helps+=("$_L_add$usagearg"$'\n'"$_L_opthelp")
						if [[ "$_L_required" == 0 && "${_L_opt_nargs[_L_opti]}" == 0 && "$first_option" == ["$_L_pc"]? ]]; then
							local i next=$((${#_L_options_usage_noargs[@]}+1))
							for i in "${!_L_options_usage_noargs[@]}" "$next"; do
								if [[ "$i" == "$next" ]]; then
									_L_options_usage_noargs[i]=${first_option:0:2}
								elif [[ "${_L_options_usage_noargs[i]:0:1}" == "${first_option:0:1}" ]]; then
									_L_options_usage_noargs[i]+=${first_option:1:1}
									break
								fi
							done
						else
							# Long options are cyan, short options are green in usage.
							if [[ "$first_option" == ["$_L_pc"]["$_L_pc"]* ]]; then
								local tmp=$ccyan
							else
								local tmp=$cgreen
							fi
							_L_options_usage+=" $bl$tmp${first_option}$cyellow${usagearg}$creset$br"
						fi
					fi
				fi
			done
		done
		_L_argparse_print_help_indenter _L_help_help "Options:" _L_options_helps
	}
	{
		# output
		local _L_out="${cblue}Usage:${creset} " i
		if [[ -n "${_L_parser_usage[_L_parseri]:-}" ]]; then
			_L_out+="${_L_parser_usage[_L_parseri]}"
		else
			_L_out+="${cpurple}$_L_prog${creset}"
			for i in "${_L_options_usage_noargs[@]}"; do
				_L_out+=" [${cgreen}${i}${creset}]"
			done
			_L_out+="${_L_options_usage}${_L_args_usage}"
		fi
		if ((!_L_short)); then
			local L_v="${_L_parser_epilog[_L_parseri]:-}"
			if [[ -n "${L_v}" ]]; then
				L_strip_v "$L_v"
				_L_argparse_percent_format_help L_v
				_L_help_help+=$'\n'"$L_v"
			fi
			_L_out+=$'\n'"${_L_help_help%%$'\n'}"
		fi
		if ((_L_err)); then
			if (($# <= 1)); then
				set -- "%s" "${1:-}"
			fi
			printf -v _L_err "${cpurple}%s${creset}: ${cred}error: $1" "$_L_prog" "${@:2}"
			if [[ "$_L_err" != *$'\n'* ]]; then
				_L_out+=$'\n'$_L_err$creset
			else
				_L_out+=$'\n'${_L_err%%$'\n'*}$creset$'\n'${_L_err#*$'\n'}
			fi
		fi
		# apply colors
		_L_out=${_L_out//$cred/$L_RED$L_BOLD}
		_L_out=${_L_out//$cgreen/$L_BOLD$L_GREEN}
		_L_out=${_L_out//$cyellow/$L_BOLD$L_YELLOW}
		_L_out=${_L_out//$cblue/$L_BLUE$L_BOLD}
		_L_out=${_L_out//$cpurple/$L_MAGENTA$L_BOLD}
		_L_out=${_L_out//$ccyan/$L_BOLD$L_CYAN}
		_L_out=${_L_out//$creset/$L_RESET}
		echo "$_L_out"
	}
}

# shellcheck disable=SC2120
# @description Print usage.
L_argparse_print_usage() {
	L_argparse_print_help -u "$@"
}

# shellcheck disable=SC2030
_L_argparse_spec_fatal() {
	(
		local _L_tmp
		set +x
		echo 'L_argparse: The parsing state, usefull for debugging:'
		_L_argparse_print
		L_print_traceback 1
		printf -v _L_tmp " %q" "${_L_args[@]:_L_argsi-5:5}"
		echo "L_argparse: before args:$_L_tmp"
		printf -v _L_tmp " %q" "${_L_args[_L_argsi]:-}"
		echo "L_argparse: current arg:$_L_tmp"
		printf -v _L_tmp " %q" "${_L_args[@]:_L_argsi+1:5}"
		echo "L_argparse:   next args:$_L_tmp"
		echo 'L_argparse: The most probable cause is L_argparse specification arguments are invalid.'
		echo "L_argparse: When parsing arguments specification the following error occured: $*"
	) >&2
	if L_is_true "${_L_parser_exit_on_error[1]:-1}"; then
		exit 2
	else
		return 2
	fi
}

# @description Add -h --help option
# @example L_argparse -- "${L_argparse_template_help[@]}" ---- "$@"
# @see L_argparse_template_verbose
L_argparse_template_help=(-h --help help="show this help message and exit" action=help)
# @description Add -v --verbose option that increases log level
# @example L_argparse -- "${L_argparse_template_verbose[@]}" ---- "$@"
# @see L_argparse_template_quiet
L_argparse_template_verbose=(-v --verbose help="be more verbose" eval='L_log_level_inc')
# @description Add -q --quiet options that decreses log level
# @example L_argparse -- "${L_argparse_template_quiet[@]}" ---- "$@"
# @see L_argparse_template_dryrun
L_argparse_template_quiet=(-q --quiet help="be more quiet" eval='L_log_level_dec')
# @description Add -n --dryrun argument to argparse.
# @example L_argparse -- "${_L_argparse_template_dryrun[@]}" ---- "$@"
# @see L_argparse_template_help
L_argparse_template_dryrun=(-n --dryrun help="do not run; just print" eval='L_dryrun=1')

# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @env _L_optspec
# @set _L_parser
_L_argparse_spec_call_subparser() {
	{
		for ((--_L_argsi; ++_L_argsi < ${#_L_args[@]}; )); do
			case "${_L_args[_L_argsi]}" in
			--|----|"{") break ;; # }
			action=*) _L_opt_action[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			metavar=*) _L_opt_metavar[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			dest=*) _L_opt_dest[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			*) _L_argparse_spec_fatal "unsupported subparser argument: ${_L_args[_L_argsi]}" ;;
			esac
		done
		_L_opt__class[_L_opti]="subparser"
		_L_argparse_spec_common_subparser_function
	}
	{
		if [[ "${_L_args[_L_argsi]:-}" != "{" ]]; then
			_L_argparse_spec_fatal "Missing at least one subparser opening {"
		fi
		local parent=$_L_parseri
		while [[ "${_L_args[_L_argsi]:-}" == "{" ]]; do
			_L_parser__parent[_L_parseri+1]=$parent
			((++_L_argsi))
			_L_argparse_spec_parse_args
			if [[ -z "${_L_parser_name[_L_parseri]:-}" ]]; then
				_L_argparse_spec_fatal 'Subparser does not have name= property set'
			fi
			if [[ "${_L_args[_L_argsi]:-}" != "}" ]]; then
				_L_argparse_spec_fatal "Missing closing }"
			fi
			((++_L_argsi))
		done
		_L_parseri=$parent
	}
}

# @description callback function used by both class=subparser and class=function
_L_argparse_spec_common_subparser_function() {
	if L_is_true "${_L_opt_required[_L_opti]:-1}"; then
		_L_opt_nargs[_L_opti]="+"
	else
		_L_opt_nargs[_L_opti]="*"
	fi
	: "${_L_opt_dest[_L_opti]:=_}"
	: "${_L_opt_metavar[_L_opti]:=COMMAND}"
	case "${_L_opt__class[_L_opti]}" in
	subparser|function) ;;
	*) _L_argparse_spec_fatal "internal error class=${_L_opt__class[_L_opti]}" ;;
	esac
	_L_opt_action[_L_opti]="_subparser"
	_L_parser__argumentsi[_L_parseri]+=" $_L_opti"
	_L_argparse_spec_argument_common
}

# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @set _L_parser
_L_argparse_spec_call_function() {
	{
		for ((--_L_argsi; ++_L_argsi < ${#_L_args[@]};)); do
			case "${_L_args[_L_argsi]}" in
			--|----|"}") break ;;
			prefix=*) _L_opt_prefix[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			subcall=*) _L_opt_subcall[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			required=*) _L_opt_required[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			metavar=*) _L_opt_metavar[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			dest=*) _L_opt_dest[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			*=*|*[$' \t\n']*) _L_argparse_spec_fatal "unsupported call=function argument: ${_L_args[_L_argsi]}" ;;
			*) _L_opt_prefix[_L_opti]=${_L_args[_L_argsi]} ;;
			esac
		done
		_L_opt__class[_L_opti]="function"
		_L_argparse_spec_common_subparser_function
	}
	{
		if [[ -z "${_L_opt_prefix[_L_opti]}" ]]; then
			_L_argparse_spec_fatal "prefix= is not set"
		fi
	}
}

# @arg $1 <var> array to append with parser name
# @arg $2 <var> array to append with subparsers indexes
_L_argparse_sub_subparser_choices_indexes() {
	local i=0
	while (( ++i <= _L_parsercnt )); do
		if (( _L_parser__parent[i] == _L_parseri )); then
			L_array_append "$1" "${_L_parser_name[i]}"
			L_array_append "$2" "$i"
		fi
	done
}

# @description Insert into an array indicated by first argument
# newline separated elements of subparser name and help.
# @arg $1 <var> array to append with parser and description separated by a newline
# @arg $2 <str> additional filter function on this prefix
_L_argparse_sub_subparser_get_helps() {
	local i=0 tmp
	while (( ++i <= _L_parsercnt )); do
		if (( _L_parser__parent[i] == _L_parseri )) && [[ "${_L_parser_name[i]}" == "${2:-}"* ]]; then
			L_array_append "$1" "${_L_parser_name[i]}"$'\n'"${_L_parser_help[i]:-${_L_parser_description[i]:+${_L_parser_description[i]//$'\n'/ }}}"
		fi
	done
}

# @arg $1 <var> array to append with subcommand name
# @arg $2 <str> filter function on this prefix
_L_argparse_sub_function_choices() {
	L_list_functions_with_prefix_removed -v "$1" "${_L_opt_prefix[_L_opti]}${2:-}"
}

# @description A subfunction is ok to call when:
# - subcall=1 or
# - subcall=auto and the function matches the regex below.
# The regex matches when:
# - there is call to L_argparse in the function
# - the call to L_argparse has an argument of help= or description=
# - There is ---- "$@" ending of L_argparse call in the function.
# @arg $1 <str> the function
_L_argparse_sub_function_is_ok_to_call() {
	local _L_func="${_L_opt_prefix[_L_opti]}$1" _L_subcall="${_L_opt_subcall[_L_opti]:-detect}" _L_func_declare
	if [[ "$_L_subcall" == "detect" ]]; then
		_L_func_declare="$(declare -f "$_L_func")" &&
		L_regex_match "$_L_func_declare" "\
$_L_func[[:space:]]*\\(\\)[[:space:]]*\\{\
.*[[:space:]]+\
L_argparse([[:space:]]|[[:space:]].*[[:space:]])----[[:space:]]+\"\\\$@\"\
(;|[[:space:]]).*\
}\
"
	else
		L_is_true "$_L_subcall"
	fi
}

# @arg $1 <var>
# @arg $2 <func> the function to call without the prefix
_L_argparse_sub_function_has_helpvar() {
	local _L_helpvar="${_L_opt_prefix[_L_opti]}${2//-/_}_help"
	L_is_valid_variable_name "$_L_helpvar" &&
		[[ -n "${!_L_helpvar:-}" ]] &&
		printf -v "$1" "%s" "${!_L_helpvar}"
}

# @description Call the function with speciifed arguments.
# @arg $1 <func> the function to call without the prefix
# @env _L_args Arguments array
# @env _L_argsi Position in arguments array
_L_argparse_sub_function_prepare_call() {
	_L_parser_name[_L_parsercnt+1]="$1"
	local _L_help
	if _L_argparse_sub_function_has_helpvar _L_help "$1"; then
		_L_parser_help[_L_parsercnt+1]="$_L_help"
	fi
	_L_parser__parent[_L_parsercnt+1]="$_L_parseri"
	_L_argparse_spec_subparser_inherit_from_parent "_L_parsercnt+1"
}

# @arg $1 <var> variable to assign the subparser description
# @arg $2 <func> the function
# shellcheck disable=SC2030,SC2031
_L_argparse_sub_function_get_help() {
	local _L_func="${_L_opt_prefix[_L_opti]}$2" _L_subparser_help _L_tmp
	if _L_argparse_sub_function_has_helpvar _L_tmp "$2"; then
		printf -v "$1" "%s" "$_L_tmp"
	elif _L_argparse_sub_function_is_ok_to_call "$2"; then
		local _L_random=$((RANDOM % 100 + 100)) _L_ret=0
		_L_subparser_help=$(
				_L_argparse_sub_function_prepare_call "$2"
				"$_L_func" --L_argparse_parser_help "$_L_random"
		) || _L_ret=$?
		if ((_L_ret == _L_random)); then
			printf -v "$1" "%s" "$_L_subparser_help"
		else
			_L_argparse_spec_fatal "Calling [$_L_func --L_argparse_parser_help] did not exit with expected exit code $_L_random but exited with $_L_ret. This suggests that the function incorrectly executes L_argparse inside it. Does the function properly call L_argparse as the first command? Consider adjusting subcall value to 0, as in call=function subcall=0. This operation potentially might have executed unknown code from the function." || return "$?"
			printf -v "$1" "%s" ""
		fi
	else
		printf -v "$1" "%s" ""
	fi
}

# @description Insert into an array indicated by first argument
# newline separated elements of subparser name and help.
# @arg $1 <var> array to append with parser and help string separated by a newline
# @arg $2 <str> additional filter function on this prefix
_L_argparse_sub_function_get_helps() {
	local L_v i _L_help
	L_list_functions_with_prefix_removed_v "${_L_opt_prefix[_L_opti]}${2:-}"
	for i in ${L_v[@]+"${L_v[@]}"}; do
		i=${2:-}$i
		_L_argparse_sub_function_get_help _L_help "$i" || return "$?"
		L_array_append "$1" "${i//$'\n'}"$'\n'"${_L_help//$'\n'/ }"
	done
}

# @description Validate arguments inside validator for argparse.
# In case of validation error, prints the error message.
# @arg $1 <str> error message
# @arg $2 <str> value to validate
# @arg $@ <str> command to execute for validation
# @exitcode 1 if validation fails
# @see _L_argparse_validator_int
L_argparse_validator() { if ! "${@:3}"; then L_argparse_fatal "%s: %q" "$1" "$2" || return 1; fi; }
_L_argparse_validator_int() { L_argparse_validator "is not an integer" "$1" L_is_integer "$1"; }
_L_argparse_validator_float() { L_argparse_validator "is not a float" "$1" L_is_float "$1"; }
_L_argparse_validator_positive() {
	_L_argparse_validator_int "$1" && L_argparse_validator "is lower than 0" "$1" test "$1" -gt 0
}
_L_argparse_validator_nonnegative() {
	_L_argparse_validator_int "$1" && L_argparse_validator "is lower than 0" "$1" test "$1" -ge 0
}
_L_argparse_validator_file() {
	L_argparse_validator "file does not exists" "$1" test -e "$1" &&
		L_argparse_validator "expected a file, but received a directory" "$1" L_not test -d "$1"
}
_L_argparse_validator_file_r() {
	_L_argparse_validator_file "$1" &&
		L_argparse_validator "file not readable" "$1" test -r "$1"
}
_L_argparse_validator_file_w() {
	_L_argparse_validator_file "$1" &&
		L_argparse_validator "file not writable" "$1" test -w "$1"
}
_L_argparse_validator_dir() {
	if test -e "$1"; then
		L_argparse_validator "not a directory" "$1" test -d "$1"
	else
		L_argparse_validator "directory does not exists" "$1" test -d "$1"
	fi
}
_L_argparse_validator_dir_r() {
	_L_argparse_validator_dir "$1" &&
		L_argparse_validator "directory not readable" "$1" test -x "$1" -a -r "$1"
}
_L_argparse_validator_dir_w() {
	_L_argparse_validator_dir "$1" &&
		L_argparse_validator "directory not writable" "$1" test -x "$1" -a -w "$1"
}
_L_argparse_validator_user() {
	local IFS=$'\n'
	# shellcheck disable=SC2046
	L_argparse_validator "not a valid user" "$1" L_array_contains groups "$1" $(compgen -A user)
}
_L_argparse_validator_group() {
	local IFS=$'\n'
	# shellcheck disable=SC2046
	L_argparse_validator "not a valid group" "$1" L_array_contains groups "$1" $(compgen -A group)
}

_L_argparse_spec_call_parameter_common_option_assign() {
	_L_opt__options[_L_opti]+="${_L_opt__options[_L_opti]:+ }${_L_args[_L_argsi]}"
	if [[ "${_L_parser__optionlookup[_L_parseri]:-}" == *" ${_L_args[_L_argsi]}="* ]]; then
		_L_argparse_spec_fatal "option ${_L_args[_L_argsi]} supplied twice"
	fi
	_L_parser__optionlookup[_L_parseri]+=" ${_L_args[_L_argsi]}=$_L_opti"
}

# @description Parse parsing specification of an argument or an option.
# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @env _L_optspec
# @set _L_parser
# shellcheck disable=SC2180
_L_argparse_spec_call_parameter() {
	local first_long_option="" first_short_option="" pc="${_L_parser_prefix_chars[_L_parseri]:--}" nodefault=0
	{
		for ((--_L_argsi; ++_L_argsi < ${#_L_args[@]};)); do
			case "${_L_args[_L_argsi]}" in
			# {
			--|---*|"}") break ;;
			action=*) _L_opt_action[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			nargs=*) _L_opt_nargs[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			const=*) _L_opt_const[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			eval=*) _L_opt_eval[_L_opti]=${_L_args[_L_argsi]#*=} _L_opt_action[_L_opti]=eval ;;
			default=*) _L_opt_default[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			type=*) _L_opt_type[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			choices=?*) _L_opt_choices[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			required=?*) _L_opt_required[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			help=*) _L_opt_help[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			metavar=*) _L_opt_metavar[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			dest=?*) _L_opt_dest[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			deprecated=*) _L_opt_deprecated[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			validate=*) _L_opt_validate[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			complete=*) _L_opt_complete[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			show_default=*) _L_opt_show_default[_L_opti]=${_L_args[_L_argsi]#*=} ;;
			flag=1|flag=0|flag=true|flag=false) _L_opt_action[_L_opti]=store_${_L_args[_L_argsi]#*=} ;;
			*[$' \v\a\t\n\\=']*) _L_argparse_spec_fatal "unsupported positional argument: ${_L_args[_L_argsi]}" ;;
			["$pc"]["$pc"]?*)
				_L_argparse_spec_call_parameter_common_option_assign
				first_long_option="${first_long_option:-${_L_args[_L_argsi]##["$pc"]["$pc"]}}"
				;;
			["$pc"]??*)
				_L_argparse_spec_call_parameter_common_option_assign
				first_long_option="${first_long_option:-${_L_args[_L_argsi]##["$pc"]}}"
				;;
			["$pc"]?)
				_L_argparse_spec_call_parameter_common_option_assign
				first_short_option="${first_short_option:-${_L_args[_L_argsi]##["$pc"]}}"
				;;
			[^a-zA-Z0-9]*|*[^a-zA-Z0-9_]*) _L_argparse_spec_fatal "unsupported positional argument: ${_L_args[_L_argsi]}" ;;
			[a-zA-Z0-9_]*)
				if [[ -n "${_L_opt_dest[_L_opti]:-}" ]]; then
					_L_argparse_spec_fatal "dest supplied twice for positional argument: ${_L_args[_L_argsi]}"
				fi
				_L_opt_dest[_L_opti]=${_L_args[_L_argsi]}
				;;
			*) _L_argparse_spec_fatal "unsupported invalid positional argument: ${_L_args[_L_argsi]}" ;;
			esac
		done
	}
	{
		if [[ -n "${_L_opt__options[_L_opti]:-}" ]]; then
			_L_opt__class[_L_opti]="option"
			# Infer dest from options
			if ! L_var_is_set '_L_opt_dest[_L_opti]'; then
				_L_opt_dest[_L_opti]=${first_long_option:-${first_short_option:-}}
				_L_opt_dest[_L_opti]=${_L_opt_dest[_L_opti]//[^a-zA-Z0-9_]/_}
			fi
			_L_parser__optionsi[_L_parseri]+=" $_L_opti"
		else
			_L_opt__class[_L_opti]="argument"
			_L_parser__argumentsi[_L_parseri]+=" $_L_opti"
		fi
		# Assert dest is valid.
		if ! L_is_valid_variable_name "${_L_opt_dest[_L_opti]}"; then
			_L_argparse_spec_fatal "dest=${_L_opt_dest[_L_opti]} is invalid"
		fi
		_L_opt_dest[_L_opti]="${_L_parser_Adest[_L_parseri]:+${_L_parser_Adest[_L_parseri]}[}""${_L_opt_dest[_L_opti]}""${_L_parser_Adest[_L_parseri]:+]}"
	}
	{
		# handle type
		local _L_type=${_L_opt_type[_L_opti]:-}
		if [[ -n "$_L_type" ]]; then
			# set validate for type
			local default=""
			case "$_L_type" in
			int) default=_L_argparse_validator_int ;;
			float) default=_L_argparse_validator_float ;;
			positive) default=_L_argparse_validator_positive ;;
			nonnegative) default=_L_argparse_validator_nonnegative ;;
			file) default=_L_argparse_validator_file ;;
			file_r) default=_L_argparse_validator_file_r ;;
			file_w) default=_L_argparse_validator_file_w ;;
			dir) default=_L_argparse_validator_dir ;;
			dir_r) default=_L_argparse_validator_dir_r ;;
			dir_w) default=_L_argparse_validator_dir_w ;;
			user) default=_L_argparse_validator_user ;;
			group) default=_L_argparse_validator_group ;;
			*)
				local L_v=()
				L_list_functions_with_prefix_removed_v "_L_argparse_validator_"
				_L_argparse_spec_fatal "L_argparse: invalid type=$_L_type for option. Available types: ${L_v[*]}"
				;;
			esac
			: "${_L_opt_validate[_L_opti]:=\"$default\" \"\$1\"}"
			# set completion for type
			case "${_L_type%%_*}" in
			# file) : "${_L_opt_complete[_L_opti]:=filenames,L_argparse_compgen -A file}" ;;
			# file) : "${_L_opt_complete[_L_opti]:=filenames,L_argparse_compgen -A file}" ;;
			file) : "${_L_opt_complete[_L_opti]:=filenames,file}" ;;
			dir) : "${_L_opt_complete[_L_opti]:=filenames,directory}" ;;
			user) : "${_L_opt_complete[_L_opti]:=user}" ;;
			group) : "${_L_opt_complete[_L_opti]:=group}" ;;
			esac
		fi
	}
	{
		# set choices validate and complete
		if ((${#_L_opt_choices[_L_opti]})); then
			if [[ -n "${_L_opt_type[_L_opti]:-}" ]]; then
				_L_argparse_spec_fatal "type= incompatible with choices="
			fi
			if ! ( declare -a _L_choices="(${_L_opt_choices[_L_opti]})" ); then
				_L_argparse_spec_fatal "choices= is invalid"
			fi
			: "${_L_opt_validate[_L_opti]:=_L_argparse_choices_validate \"\$1\"}"
			: "${_L_opt_complete[_L_opti]:=_L_argparse_choices_complete \"\$1\"}"
		fi
	}
	_L_argparse_spec_argument_common
}

# @description callback function used by all arguments, options, subparser and functions
_L_argparse_spec_argument_common() {
	# Special
	if [[ "${_L_opt_nargs[_L_opti]:-}" == remainder ]]; then
		_L_parser_remainder[_L_parseri]=1
		if L_is_true "${_L_opt_required[_L_opti]:-}"; then
			_L_opt_nargs[_L_opti]="+"
		else
			_L_opt_nargs[_L_opti]="*"
		fi
	fi
	{
		# apply defaults depending on action
		case "${_L_opt_action[_L_opti]:=store}" in
		store)
			if ((${#_L_opt_choices[_L_opti]})) && L_var_is_set "_L_opt_default[_L_opti]"; then
				: "${_L_opt_nargs[_L_opti]:="?"}"
			else
				: "${_L_opt_nargs[_L_opti]:=1}"
			fi
			;;
		store_const)
			if ! L_var_is_set "_L_opt_const[_L_opti]"; then
				_L_argparse_spec_fatal "const is not set for action=store_const"
			fi
			;;
		store_true)
			_L_opt_action[_L_opti]=store_const
			: "${_L_opt_default[_L_opti]:=false}" "${_L_opt_const[_L_opti]:=true}"
			;;
		store_false)
			_L_opt_action[_L_opti]=store_const
			: "${_L_opt_default[_L_opti]:=true}" "${_L_opt_const[_L_opti]:=false}"
			;;
		store_0)
			_L_opt_action[_L_opti]=store_const
			: "${_L_opt_default[_L_opti]:=1}" "${_L_opt_const[_L_opti]:=0}"
			;;
		store_1)
			_L_opt_action[_L_opti]=store_const
			: "${_L_opt_default[_L_opti]:=0}" "${_L_opt_const[_L_opti]:=1}"
			;;
		store_1null)
			_L_opt_action[_L_opti]=store_const
			: "${_L_opt_default[_L_opti]:=}" "${_L_opt_const[_L_opti]:=1}"
			;;
		append)
			_L_opt__isarray[_L_opti]=1
			: "${_L_opt_nargs[_L_opti]:=1}"
			;;
		append_const)
			if ! L_var_is_set "_L_opt_const[_L_opti]"; then
				_L_argparse_spec_fatal "const is not set but action=append_const"
			fi
			_L_opt__isarray[_L_opti]=1
			;;
		eval)
			# if [[ -z "${_L_opt_eval[_L_opti]:-}" ]] || ! bash -nc "${_L_opt_eval[_L_opti]}"; then
			# 	_L_argparse_spec_fatal "eval=${_L_opt_eval[_L_opti]} is invalid"
			# fi
			: "${_L_opt_nargs[_L_opti]:=0}"
			;;
		_subparser|count|help) ;;
		*) _L_argparse_spec_fatal "invalid action=${_L_opt_action[_L_opti]:-}. Action has to be one of: store, store_const, store_true, store_false, store_0, store_1, store_1null, append, append_const, eval or remainder. "
		esac
	}
	{
		# assert nargs value is valid, assign isarray
		case "${_L_opt_nargs[_L_opti]:=0}" in
		'?'|0|1) ;;
		'*'|'+'|[2-9]|[1-9]*)
			_L_opt__isarray[_L_opti]=1
			: "${_L_opt_action[_L_opti]:=append}"
			;;
		*)
			if [[ "${_L_opt_nargs[_L_opti]}" -le 0 ]]; then
				_L_argparse_spec_fatal "invalid nargs=${_L_opt_nargs[_L_opti]}. It has to be one of ? * + or a number."
			fi
			_L_opt__isarray[_L_opti]=$(( _L_opt_nargs[_L_opti] > 1 ))
		esac
	}
	_L_opt__parseri[_L_opti]=$_L_parseri
}

# @description
# @env _L_parser
# @arg $1 Variable to set with optspec. Typically _L_opti
# @arg $2 Option to search for, example -a or --option.
_L_argparse_parser_find_option() {
	local _L_tmp="${_L_parser__optionlookup[_L_parseri]##*" $2="}"
	if [[ "${_L_parser__optionlookup[_L_parseri]}" == "$_L_tmp" ]]; then
		return 1
	fi
	printf -v "$1" "%d" "${_L_tmp%% *}"
}

# @description Get space separate list of all options of the current parser.
# @arg $1 <var> variable to append options to
# @set $1
_L_argparse_parser_get_all_options() {
	local IFS=' '
	local -a _L_tmp="(${_L_parser__optionlookup[_L_parseri]:-})"
	printf -v "$1" "%s" "${_L_tmp[*]//=*}"
}

# @description
# @note Long short -options are handled specially,
# as we fall back to short option parsing if long option parsing fails.
# In _L_argparse_parse_args_long_option after this function fails.
# @env _L_parser
# @set $1
# @arg $1 Variable to set with optspec. Typicall _L_opti.
# @arg $2 Long option ex. --option or -option
_L_argparse_parser_get_long_option() {
	if _L_argparse_parser_find_option "$1" "$2"; then
		return 0
	elif L_is_true "${_L_parser_allow_abbrev[_L_parseri]:-0}"; then
		local IFS=$' \t\n' _L_abbrev_matches _L_options
		_L_argparse_parser_get_all_options _L_options
		_L_abbrev_matches=$(compgen -W "$_L_options" -- "$2" || :)
		if [[ -z "$_L_abbrev_matches" ]]; then
			if [[ "${2:1:1}" != ["$_L_pc"] ]]; then return 1; fi
			L_argparse_fatal "unrecognized arguments: $2" || return "$?"
		elif [[ "$_L_abbrev_matches" == *[$' \t\n']* ]]; then
			if [[ "${2:1:1}" != ["$_L_pc"] ]]; then return 1; fi
			L_argparse_fatal "ambiguous option: $2 could match ${_L_abbrev_matches//[$' \t\n']/ }" || return "$?"
		else
			if ! _L_argparse_parser_find_option "$1" "$_L_abbrev_matches"; then
				L_argparse_fatal "internal error: could not get short option of $_L_abbrev_matches" || return "$?"
			fi
			return 0
		fi
	else
		if [[ "${2:1:1}" != ["$_L_pc"] ]]; then return 1; fi
		L_argparse_fatal "unrecognized arguments: $2" || return "$?"
	fi
	return 1
}

# @description validate values
# @arg $@ value to assign to option
# @env _L_optspec
# @env _L_comp_enabled
_L_argparse_optspec_validate_values() {
	if ((${_L_comp_enabled:-0})); then
		return
	fi
	local _L_validate=${_L_opt_validate[_L_opti]:-}
	if [[ -n "$_L_validate" ]]; then
		while (($#)); do
			if ! eval "$_L_validate"; then
				local _L_type=${_L_opt_type[_L_opti]:-} _L_desc
				_L_argparse_optspec_get_description _L_desc
				if [[ -n "$_L_type" ]]; then
					L_argparse_fatal "argument %s: invalid %s value: %q" "$_L_desc" "$_L_type" "$1" || return 1
				else
					L_argparse_fatal "argument %s: invalid value: %q, validate: %q" "$_L_desc" "$1" "$_L_validate" || return 1
				fi
			fi
			shift
		done
	fi
}

# @description clear the dest variable
# @env _L_optspec
# @set ${_L_opt_dest[_L_opti]}
_L_argparse_optspec_dest_arr_clear() {
	if [[ "${_L_opt_dest[_L_opti]}" == *"["*"]" ]]; then
		eval "${_L_opt_dest[_L_opti]}="
	else
		eval "${_L_opt_dest[_L_opti]}=()"
	fi
}

# @description store $1 in variable
# @arg $1 value to store
# @env _L_optspec
# @set ${_L_opt_dest[_L_opti]}
_L_argparse_optspec_dest_store() {
	eval "${_L_opt_dest[_L_opti]}=\$1"
}

# @description append $@ to the variable
# @arg $@ values to store
# @env _L_optspec
# @set ${_L_opt_dest[_L_opti]}
_L_argparse_optspec_dest_arr_append() {
	if [[ "${_L_opt_dest[_L_opti]}" == *"["*"]" ]]; then
		local _L_tmp
		printf -v _L_tmp "%q " "$@"
		eval "${_L_opt_dest[_L_opti]}+=\$_L_tmp"
	else
		eval "${_L_opt_dest[_L_opti]}+=(\"\$@\")"
	fi
}

# @description assign value to _L_opt_dest[_L_opti] or execute the action specified by _L_optspec
# @env _L_optspec
# @env _L_assigned_parameters
# @set _L_assigned_parameters
# @env _L_comp_enabled
# @arg $@ arguments to store
_L_argparse_optspec_execute_action() {
	_L_assigned_parameters+=" $_L_opti "
	case ${_L_opt_action[_L_opti]} in
	store|append|eval)
		_L_argparse_optspec_validate_values "$@" || return 1
	esac
	case ${_L_opt_action[_L_opti]} in
	store)
		if ((_L_opt__isarray[_L_opti])); then
			if [[ -n "${_L_opt__options[_L_opti]:-}" ]]; then
				# positional arguments are cleared in the parsing loop
				_L_argparse_optspec_dest_arr_clear
			fi
			_L_argparse_optspec_dest_arr_append "$@"
		else
			_L_argparse_optspec_dest_store "${1-${_L_opt_const[_L_opti]-}}"
		fi
		;;
	store_const) _L_argparse_optspec_dest_store "${_L_opt_const[_L_opti]}" ;;
	append) _L_argparse_optspec_dest_arr_append "$@" ;;
	append_const) _L_argparse_optspec_dest_arr_append "${_L_opt_const[_L_opti]}" ;;
	count) printf -v "${_L_opt_dest[_L_opti]}" "%s" "$(( ${!_L_opt_dest[_L_opti]:-0} + 1 ))" ;;
	help) if ((!_L_comp_enabled)); then L_argparse_print_help; exit 0; fi ;;
	eval) if ((!_L_comp_enabled)); then eval "${_L_opt_eval[_L_opti]}" || exit "$?"; fi ;;
	*) _L_argparse_spec_fatal "internal error: invalid action=${_L_opt_action[_L_opti]}. This value should have been sanitized when parsing options and not now. This is an internal error in the library of how it validates the input. Either way, action=${_L_opt_action[_L_opti]} is an invalid action in the L_argparse specification." ;;
	esac
}

# @description Run compgen that outputs correctly formatted completion stream.
# With option description prefixed with the 'plain' prefix.
# Any compgen option is accepted, arguments are forwarded to compgen.
# @option -ANY Any options supported by compgen, except -P and -S
# @option -D <str> Specify the description of appended to the result. If description is an empty string, it is not printed. Default: help of the option.
# @arg $1 <str> incomplete
# @exitcode 0 if compgen returned 0 or 1, otherwise 2
L_argparse_compgen() {
	local OPTIND OPTARG OPTERR args=() c="" prefix="" suffix="" desc
	while getopts 'abcdefgjksuvo:A:G:W:F:C:X:P:S:D:' c; do
		# shellcheck disable=SC2102
		case "$c" in
		[abcdefgjksuvo:A:G:W:F:C:X:]) args+=("-${c}" "${OPTARG:-}") ;;
		P) prefix="$OPTARG" ;;
		S) suffix="$OPTARG" ;;
		D) desc="$OPTARG" ;;
		?) compgen "-$_L_c" || L_fatal "invalid option: -$_L_c"; return 2 ;;
		esac
	done
	if ! L_var_is_set desc && ((_L_opti > 0)) && L_var_is_set "_L_opt_help[_L_opti]"; then
		desc="${_L_opt_help[_L_opti]}"
	fi
	if [[ -n "${desc:-}" ]]; then
		# shellcheck disable=SC2064
		# replace multiple spaces with one space and remove leading/trailing spaces
		L_shopt_extglob eval 'desc="${desc//+([$L_GS[:space:]])/ }"'
		L_strip -v desc "$desc"
	fi
	shift "$((OPTIND - 1))"
	if (($# == 0)) && L_var_is_set L_comp_incomplete; then
		set -- "$L_comp_incomplete"
	fi
	compgen ${args[@]:+"${args[@]}"} \
		-P "plain${L_GS}${L_comp_prefix:-}$prefix" \
		-S "$suffix${desc:+${L_GS}$desc}" \
		-- "$@" || (($? == 1)) || return 2
}

# @description validate argument with choices is correct
# @arg $1 incomplete
# @env _L_optspec
_L_argparse_choices_validate() {
	local -a _L_choices="(${_L_opt_choices[_L_opti]})"
	if ! L_args_contain "$1" "${_L_choices[@]}"; then
		local _L_choicesstr _L_desc
		L_args_join -v _L_choicesstr ", " "${_L_choices[@]}"
		_L_argparse_optspec_get_description _L_desc
		L_argparse_fatal "argument %s: invalid choice: %q (choose from %s)" "$_L_desc" "$1" "$_L_choicesstr" || return 1
	fi
}

# @description generate completion for argument with choices
# @arg $1 incomplete
# @env _L_optspec
_L_argparse_choices_complete() {
	local -a choices="(${_L_opt_choices[_L_opti]})"
	local IFS=$'\n'
	L_argparse_compgen -W "${choices[*]}" -D "" -- "$1" || return "$?"
}

# @description Generate completions for given element.
# @stdout first line is the type
# if the type is plain, the second line contains the value to complete.
# @arg $1 <str> incomplete
# @arg $2 <str> additional prefix
# @env _L_optspec
# @env _L_parser
# @env _L_comp_enabled
_L_argparse_optspec_gen_completion() {
	if ((!_L_comp_enabled)); then
		return
	fi
	local _L_complete="${_L_opt_complete[_L_opti]:-default}" L_comp_incomplete="$1" L_comp_prefix="${2:-}"
	IFS=, read -ra _L_complete <<<"$_L_complete"
	for _L_complete in "${_L_complete[@]}"; do
		case "$_L_complete" in
		bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs|file|directory)
			echo "$_L_complete${_L_opt_help[_L_opti]:+${L_GS}${L_GS}${_L_opt_help[_L_opti]//[$L_GS[:space:]]/ }}" ;;
		alias|arrayvar|binding|builtin|command|disabled|enabled|export|function|group|helptopic|hostname|job|keyword|running|service|setopt|shopt|signal|stopped|user|variable)
			L_argparse_compgen -A "$_L_complete" -- "$1" || exit $? ;;
		*" "*) eval "${_L_complete}" || return "$?" ;;
		'') ;;
		*) L_fatal "invalid $_L_complete part in complete of $(_L_argparse_print_curopt)"
		esac
	done
	exit
}

# COMP_TYPE == 9  -> single tab
# COMP_TYPE == 63 -> tab tab
# COMP_TYPE == 37 -> menu-complete/menu-complete-backward
# COMP_TYPE == 42 -> insert-completions
# @see https://github.com/containers/podman/blob/main/completions/bash/podman
_L_argparse_bash_completion_function() {
	local cur prev words cword comp_args was_split split
	local IFS=$'\n' sep=$'\035' _ COLUMNS="${COLUMNS:-80}" LINES="${LINES:-1}"
	local longestcomp=1 longestdesc=0 i response mode comp desc tmp
	if hash _comp_initialize 2>/dev/null; then
		# https://github.com/scop/bash-completion/blob/main/bash_completion#L1453
		_comp_initialize -s -- "$@" || return
	elif hash _init_completion 2>/dev/null; then
		# https://github.com/scop/bash-completion/blob/1.99/bash_completion#L649
		_init_completion -s || return
	else
		words=("${COMP_WORDS[@]}")
		cword=${COMP_CWORD}
		cur="${words[*]:cword:1}"
	fi
	response=$( "$1" --L_argparse_get_completion "${words[@]:1:cword}" ) &&
	while IFS=$sep read -r mode comp desc _; do
		case "$mode" in
		bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs) compopt -o "$mode" ;;
		file|directory)
			if tmp=$(compgen -A "$mode" ${comp:+-G"$comp"} ${desc:+-S"$sep$desc"} -- "$cur") && [[ -n "$tmp" ]]; then
				if hash mapfile; then
					mapfile -t tmp <<<"$tmp"
					COMPREPLY+=("${tmp[@]}")
				else
					# shellcheck disable=SC2206
					COMPREPLY+=($tmp)
				fi
			fi
			;;
		plain)
			if [[ "$comp" == "$cur"* ]]; then
				printf -v comp "%q" "$comp"
				longestcomp=$(( longestcomp < ${#comp} ? ${#comp} : longestcomp ))
				longestdesc=$(( longestdesc < ${#desc} ? ${#desc} : longestdesc ))
				COMPREPLY+=("$comp$sep${desc//[[:space:]]/ }")
			fi
			;;
		esac
	done <<<"$response"
	{
		# Group completions by description into lines.
		local descscomps=() colidx compsnodesc=() i j
		for i in "${!COMPREPLY[@]}"; do
			comp="${COMPREPLY[i]%%"$sep"*}"
			desc="${COMPREPLY[i]#*"$sep"}"
			if [[ -z "$desc" ]]; then
				compsnodesc+=("$comp")
			else
				for ((j = 0; j < ${#descscomps[@]}; ++j)); do
					if [[ "${descscomps[j]%%"$sep"*}" == "$desc" ]]; then
						break
					fi
				done
				descscomps[j]=${descscomps[j]:-$desc}$sep$comp
			fi
		done
		# declare -p descscomps compsnodesc
	}
	if (( longestdesc == 0 || longestcomp + 10 > COLUMNS || ${#COMPREPLY[@]} <= 1 || (${#descscomps[@]} == 1 && ${#compsnodesc[@]} == 0) )); then
		# Remove descriptions if
		# - there are no descriptions
		# - or there are not enough columns to fit the descriptions
		# - or there is only one completion
		# - or all completion have the same description (TODO)
		COMPREPLY=("${COMPREPLY[@]%%"$sep"*}")
	else
		{
			{
				# Find shortest prefix, so that completion fills only up to it even if we mess up.
				local shortestprefix="${COMPREPLY[0]}" comp i j
				for (( i = 1; i < ${#COMPREPLY[@]} && ${#shortestprefix}; ++i )); do
					comp="${COMPREPLY[i]%%"$sep"*}"
					for (( j = 1; j <= ${#shortestprefix}; ++j )); do
						if [[ "$comp" != "${shortestprefix::j}"* ]]; then
							shortestprefix=${shortestprefix::j-1}
							break
						fi
					done
				done
			}
			{
				# sort completions within each line
				local IFS="$sep" i j k LC_ALL=C sort='
				for (( i = 0; i < ${#ARRAY[@]} - 1; ++i )); do
					for (( j = 0; j + i < ${#ARRAY[@]} - 1; ++j )); do
						if [[ "${ARRAY[j]}" < "${ARRAY[j+1]}" ]]; then
							local tmp=${ARRAY[j]}
							ARRAY[j]="${ARRAY[j+1]}"
							ARRAY[j+1]="$tmp"
						fi
					done
				done
				'
				for k in "${!descscomps[@]}"; do
					IFS="$sep" read -ra desc <<<"${descscomps[k]}"
					comp=("${desc[@]:1}")
					eval "${sort//ARRAY/comp}"
					descscomps[k]="${desc[0]}$sep${comp[*]}"
				done
				# Sort completions without descriptions too.
				eval "${sort//ARRAY/compsnodesc}"
			}
			{
				# Determine column lengths.
				local collens=()
				for j in "${!descscomps[@]}"; do
					IFS="$sep" read -ra desc <<<"${descscomps[j]}"
					for ((i = 0; i < ${#desc[@]}; ++i)); do
						collens[i]=$(( collens[i] > ${#desc[i+1]} ? collens[i] : ${#desc[i+1]} ))
					done
				done
			}
			{
				# Create completions with descriptions in columns. Watch out for COLUMNS.
				local compreplysav=("${COMPREPLY[@]}") i comp line
				COMPREPLY=()
				for i in "${descscomps[@]}"; do
					IFS="$sep" read -ra desc <<<"$i"
					# fill up line
					local line=""
					for ((j=0;j<${#collens[@]};++j)); do
						if [[ -n "$line" ]] && ((${#line} + collens[j] + 1 > COLUMNS)); then
							# If line is too long for terminal, flush it.
							COMPREPLY+=("$line")
							line=""
						fi
						printf -v line "%s%-*s " "$line" "${collens[j]}" "${desc[j+1]:-}"
					done
					if ((${#desc} && ${#line} + 5 < COLUMNS)); then
						line+="-- $desc"
						if ((${#line} > COLUMNS)); then
							line="${line::COLUMNS-1}…"
						fi
					fi
					COMPREPLY+=("$line")
				done
				COMPREPLY+=("${compsnodesc[@]}")
			}
			{
				# Calculate shortest prefix again to determine if it should be added.
				local shortestprefixpre=$shortestprefix shortestprefix="${COMPREPLY[0]}" i j
				for (( i = 1; i < ${#COMPREPLY[@]} && ${#shortestprefix}; ++i )); do
					comp="${COMPREPLY[i]%%"$sep"*}"
					for (( j = 1; j <= ${#shortestprefix}; ++j )); do
						if [[ "$comp" != "${shortestprefix::j}"* ]]; then
							shortestprefix=${shortestprefix::j-1}
							break
						fi
					done
				done
				# Only add shortest prefix if it is needed.
				if [[ "$shortestprefixpre" != "$shortestprefix" ]]; then
					COMPREPLY+=("${shortestprefix}")
				fi
			}
			{
				# Can we fit the descriptions in available LINES?
				local longestline=0
				for comp in "${COMPREPLY[@]}"; do
					longestline=$(( longestline > ${#comp} ? longestline : ${#comp} ))
				done
				longestline=$(( longestline + 2 ))
				if (( LINES < ${#COMPREPLY[@]} / ( 1 + COLUMNS / longestline ) )); then
					# If we are not able to fit them, remove descriptions.
					COMPREPLY=("${compreplysav[@]%%"$sep"*}")
				fi
			}
		}
	fi
}

_L_argparse_bash_completion_function_old() {
	local compdesclen=$(( longestcomp + longestdesc + 4 ))
	local compdesccolumns=$(( COLUMNS / compdesclen + !!(COLUMNS % compdesclen) ))
	local compdesclines=$(( ${#COMPREPLY[@]} / compdesccolumns + !!(${#COMPREPLY[@]} % compdesccolumns) ))
	local compnodesclen=$(( longestcomp + 1 ))
	local compnodesccolumns=$(( COLUMNS / compnodesclen + !!(COLUMNS % compnodesclen) ))
	local compnodesclines=$(( ${#COMPREPLY[@]} / compnodesccolumns + !!(${#COMPREPLY[@]} % compnodesccolumns) ))
	if (( longestdesc == 0 || COLUMNS < longestcomp + 10 || ${#COMPREPLY[@]} <= 1 || (LINES < compdesclines && LINES > compnodesclines) )); then
		# remove descriptions if
		# - there just are no descriptions
		# - there are not enough columns to fit the descriptions
		# - or there is only one completion
		# - or there are not enough lines to print completions with descriptions
		#   but enough lines to print completions without descriptions
		for i in "${!COMPREPLY[@]}"; do
			COMPREPLY[i]="${COMPREPLY[i]%%"$sep"*}"
		done
	elif ((0)); then
		# Format the descriptions
		{
			# find shortest prefix, so that completion fills only up to it even if we mess up
			local shortestprefix="${COMPREPLY[0]}" i j
			for (( i = 1; i < ${#COMPREPLY[@]} && ${#shortestprefix}; ++i )); do
				comp="${COMPREPLY[i]%%"$sep"*}"
				for (( j = 1; j <= ${#shortestprefix}; ++j )); do
					if [[ "$comp" != "${shortestprefix::j}"* ]]; then
						shortestprefix=${shortestprefix::j-1}
						needshortestprefix=1
						break
					fi
				done
			done
			# group completions by description
			local descscomps=() collens=() colidx compsnodesc=()
			for i in "${!COMPREPLY[@]}"; do
				comp="${COMPREPLY[i]%%"$sep"*}"
				desc="${COMPREPLY[i]#*"$sep"}"
				for ((j = 0; j < ${#descscomps[@]}; ++j)); do
					if [[ "${descscomps[j]%%"$sep"*}" == "$desc" ]]; then
						break
					fi
				done
				descscomps[j]=${descscomps[j]:-$desc}$sep$comp
				colidx=${descscomps[j]//[^$sep]}
				colidx=${#colidx}
				collens[colidx]=$(( collens[colidx] > ${#comp} ? collens[colidx] : ${#comp} ))
			done
			# declare -p descscomps collens compsnodesc
			# if there was a shortestprefix, start with it
			COMPREPLY=()
			for i in "${descscomps[@]}"; do
				IFS=$sep read -ra comp <<<"$i"
				local line=""
				for ((j=1;j<${#comp[@]};++j)); do
					if ((${#line} + collens[j] + 1 > COLUMNS)); then
						COMPREPLY+=("$line")
						line=""
					fi
					printf -v line "%s%-*s " "$line" "${collens[j]}" "${comp[j]}"
				done
				if ((${#line} + 10 < COLUMNS)); then
					line+="-- ${comp[0]}"
					if ((${#line} > COLUMNS)); then
						line="${line::COLUMNS-1}…"
					fi
				fi
				if [[ -n "$line" ]]; then
					COMPREPLY+=("$line")
				fi
			done
			COMPREPLY+=("${compsnodesc[@]}")
			COMPREPLY+=("${shortestprefix}")
		}
	else
		{
			local end="..." tmp
			# If terminal supports unicode.
			if hash locale 2>/dev/null && tmp=$(locale charmap) 2>/dev/null && [[ "$tmp" == "UTF-8" ]]; then
				end="…"
			fi
			# Simply pad descriptions max one per line with spaces until end of line.
			for i in "${!COMPREPLY[@]}"; do
				comp="${COMPREPLY[i]%%"$sep"*}"
				desc="${COMPREPLY[i]#*"$sep"}"
				# If the completion has a description, format it.
				if [[ -n "$desc" ]]; then
					# Truncate too long description for the columns.
					printf -v comp "%-*s (%s)" "$longestcomp" "$comp" "$desc"
					if ((COLUMNS > 10 && ${#comp} > COLUMNS)); then
						comp="${comp::COLUMNS-${#end}}$end"
					fi
				fi
				COMPREPLY[i]=$comp
			done
		}
	fi
}

# @description Bash completion code.
_L_argparse_bash_completion='complete -F %(complete_func)s %(prog_name)s'

# @description ZSH completion code.
_L_argparse_zsh_completion=$'#compdef %(prog_name)s
%(complete_func)s() {
	local mode comp desc _ nosort=""
	local -a response completions completions_with_descriptions
	(( ! $+commands[%(prog_name)s] )) && return 1
	response="$( %(prog_name)s --L_argparse_get_completion_zsh "${words[@]:1:$((CURRENT-1))}" )"
	while IFS=$\'\\035\' read -r mode comp desc; do
		case "$mode" in
		nosort) nosort=1 ;;
		file) _path_files -f ${comp:+-g"$comp"} ${desc:+-X"$desc"} ;;
		directory) _path_files -/ ${comp:+-g"$comp"} ${desc:+-X"$desc"} ;;
		bashdefault|default) _default ;;
		plain)
			if [[ -z "$desc" ]]; then
				completions+=("$comp")
			else
				completions_with_descriptions+=("$comp:$desc")
			fi
		esac
	done <<<"$response"
	# declare -p completions_with_descriptions completions >/dev/tty
	if [[ -n "$completions_with_descriptions" ]]; then
		_describe  -J ${nosort:+un}sorted ${nosort:+-o nosort} completions_with_descriptions -U
	fi
	if [[ -n "$completions" ]]; then
		compadd -U -J ${nosort:+un}sorted ${nosort:+-o nosort} -a completions
	fi
}
if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
	# autoload from fpath, call function directly
	%(complete_func)s "$@"
else
	# eval/source/. command, register function for later
	compdef %(complete_func)s %(prog_name)s
fi
'

# @description Fish completion code
_L_argparse_fish_completion='
function %(complete_func)s;
	set -l args (commandline -pco) (commandline -pct);
	set -e args[1];
	%(prog_name)s --L_argparse_get_completion $args | while read -l -d \035 mode comp desc;
		switch "$mode";
		case file; __fish_complete_path "$key" "$desc";
		case directory; __fish_complete_directories "$key" "$desc";
		case plain; printf "%s\t%s\n" "$comp" "$desc";
		end;
			complete -c -X "$args[2]" -a "$key" -d "$desc";
		end;
		switch "$what";
		end;
	end;
end;
complete --no-files --command %(prog_name)s --arguments "(%(complete_func)s)";
'

# @description Handle completion arguments
# Handle internal arguments, ex. bash completion
# @arg $1 Argument as passed to parse_args
# @set _L_comp_enabled
_L_argparse_parse_args_internal() {
	case "${_L_args[_L_argsi]:-}" in
	--L_argparse_print) _L_argparse_print; exit ;;
	--L_argparse_parser_help) printf "%s\n" "${_L_parser_help[_L_parseri]:-${_L_parser_description[_L_parseri]:-}}"; exit "${_L_args[_L_argsi+1]}"; ;;
	--L_argparse_print_usage) L_argparse_print_usage; exit; ;;
	--L_argparse_print_help) L_argparse_print_help; exit; ;;
	--L_argparse_get_completion) _L_comp_enabled=1; ((++_L_argsi)) ;;
	--L_argparse_get_completion_bash|--L_argparse_get_completion_zsh|--L_argparse_get_completion_fish)
		_L_comp_enabled=1 _L_comp_shell=${_L_args[_L_argsi]##*_}; ((++_L_argsi)) ;;
	--L_argparse_complete_bash|--L_argparse_bash_completion|--L_argparse_zsh_completion|--L_argparse_fish_completion)
		local i=_${_L_args[_L_argsi]##--} name
		i=${i//L_argparse_complete_bash/L_argparse_bash_completion}
		i=${!i}
		if [[ "${_L_args[_L_argsi]}" == *bash* ]]; then
			i=$(declare -f _L_argparse_bash_completion_function)$'\n'"$i"$'\n'
			i=${i//_L_argparse_bash_completion_function/%(complete_func)s}
		fi
		printf -v name "%q" "$L_NAME"
		i=${i//%(prog_name)s/$name}
		i=${i//%(complete_func)s/_L_argparse_complete_${L_NAME//[^a-zA-Z0-9_]/_}}
		printf "%s\n" "$i"
		exit
		;;
	--L_argparse_completion_help)
		local bash_dst=${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion
		local fish_dst=${XDG_CONFIG_HOME:-~/.config}/fish/completions/
		local name
		printf -v name "%q" "$L_NAME"
		cat <<EOF
# Bash: To load the completion script into the current session run:
	eval "\$($name --L_argparse_bash_completion)"
# Bash: To make it available using bash-completion project:
	mdir -vp $bash_dst
	$name --L_argparse_bash_completion > $bash_dst/$name
# Zsh: To load the completion script into the current session run:
	eval "\$($name --L_argparse_zsh_completion)"
# Zsh: To make it available for all zsh sessions run
	$name --L_argparse_zsh_completion > "\${fpath[1]}/_$name"
# Fish: To load the completion script into the current session run:
	eval "\$($name --L_argparse_fish_completion)"
# Fish: To make it available for all fish sessions run:
	mkdir -vp $fish_dst
	$name --L_argparse_fish_completion > $fish_dst/$name.fish
EOF
		exit
		;;
	--L_argparse_*)
		local available_cmds
		available_cmds="$(declare -f "${FUNCNAME[0]}" | grep -o -- "--L_argparse_[a-z_]\+" | sort -u || :)"
		L_fatal "unknown internal argument: ${_L_args[_L_argsi]}, available:"$'\n'"$available_cmds"
		# shellcheck disable=SC2317
		exit 1
		;;
	esac
}

# @description Assign defaults to all options and arguments that have not been assigned.
# @env _L_assigned_parameters
_L_argparse_parse_args_set_defaults() {
	local _L_opti
	for _L_opti in ${_L_parser__optionsi[_L_parseri]:-} ${_L_parser__argumentsi[_L_parseri]:-}; do
		if [[ " $_L_assigned_parameters " != *" $_L_opti "* ]] && L_var_is_set "_L_opt_default[_L_opti]"; then
			if ((_L_opt__isarray[_L_opti])); then
				declare -a _L_tmp="(${_L_opt_default[_L_opti]})"
				_L_argparse_optspec_dest_arr_clear
				_L_argparse_optspec_dest_arr_append ${_L_tmp[@]+"${_L_tmp[@]}"}
			else
				_L_argparse_optspec_dest_store "${_L_opt_default[_L_opti]}"
			fi
		fi
	done
}

# @description complete option names
# @arg [$1] <str> partial --option like `--op`
# @arg [$2] <str> prefix to completion
_L_argparse_gen_option_names_completion() {
	if ((_L_comp_enabled)); then
		local IFS=$' \t\n' _L_options
		_L_argparse_parser_get_all_options _L_options
		L_argparse_compgen -W "$_L_options" -P "${2:-}" -- "${1:-}" || return "$?"
		exit
	fi
}

# @description parse long option
# @arg $1 long option to parse
# @arg $@ further arguments on command line
_L_argparse_parse_args_long_option() {
	# Parse long option `--rcfile file --help`
	if [[ "${_L_args[_L_argsi]}" == *=* ]]; then
		local _L_has_equal=1 _L_option="${_L_args[_L_argsi]%%=*}" _L_values=("${_L_args[_L_argsi]#*=}")
	else
		local _L_has_equal=0 _L_option="${_L_args[_L_argsi]}" _L_values=()
		if ((_L_argsi + 1 == ${#_L_args[@]})); then
			_L_argparse_gen_option_names_completion "${_L_args[_L_argsi]}" || return "$?"
		fi
	fi
	local _L_opti=0
	if ! _L_argparse_parser_get_long_option _L_opti "$_L_option"; then
		if ((_L_argsi + 1 == ${#_L_args[@]})); then
			_L_argparse_gen_option_names_completion "${_L_args[_L_argsi]}" || return "$?"
		fi
		# If this is a long option with one dash, parse it as a short option.
		if [[ "${_L_args[_L_argsi]:1:1}" != ["$_L_pc"] ]]; then
			_L_argparse_parse_args_short_option || return "$?"
			return 0
		fi
		L_argparse_fatal "unrecognized long option: ${_L_args[_L_argsi]}" || return "$?"
		# This is special - if _L_comp_enabled, then we should ignore invalid options and carry on
		((++_L_argsi))
		return 0
	fi
	((++_L_argsi))
	local _L_nargs=${_L_opt_nargs[_L_opti]}
	case "$_L_nargs" in
	0)
		if ((${#_L_values[@]})); then
			_L_argparse_optspec_get_description _L_desc
			L_argparse_fatal "option $_L_desc takes no arguments: $_L_option=${_L_values[*]}" || return "$?"
		fi
		;;
	"+"|"*") _L_values+=("${_L_args[@]:_L_argsi}"); _L_argsi=${#_L_args[@]}; ;;
	"?") _L_values=("${_L_values[0]:-${_L_opt_const[_L_opti]:-}}") ;;
	[0-9]*)
		_L_values+=("${_L_args[@]:_L_argsi:_L_nargs - _L_has_equal}")
		_L_argsi=$(( _L_argsi + (_L_nargs - _L_has_equal) ))
		if ((${#_L_values[@]} != _L_nargs)); then
			_L_argparse_optspec_get_description _L_desc
			L_argparse_fatal "argument $_L_desc: expected ${_L_opt_nargs[_L_opti]} arguments but received ${#_L_values[@]}" || return "$?"
		fi
		;;
	*) L_argparse_fatal "invalid nargs specification of $(_L_argparse_print_curopt)" || return "$?" ;;
	esac
	if ((_L_argsi == ${#_L_args[@]} && _L_comp_enabled)); then
		local _L_comp_prefix=""
		if ((_L_has_equal)); then
			_L_comp_prefix="$_L_option="
		fi
		_L_argparse_optspec_gen_completion "${_L_values[@]:+"${_L_values[${#_L_values[@]}-1]:-}"}" "$_L_comp_prefix" || return "$?"
	fi
	_L_argparse_optspec_execute_action ${_L_values[@]+"${_L_values[@]}"} || return "$?"
}

# @description parse short option
# @set _L_argsi
# @env _L_args
# @env _L_init_argsi
# @arg $1 Short option to parse. Has to start with one -.
# @arg $@ Further arguments on command line.
_L_argparse_parse_args_short_option() {
	# Parse short option -abcarg
	local _L_i
	for ((_L_i = 1; _L_argsi == _L_init_argsi; ++_L_i)); do
		local _L_option=${_L_args[_L_argsi]:0:1}${_L_args[_L_argsi]:_L_i:1}  # option with the dash, ex. -e
		local _L_value=${_L_args[_L_argsi]:_L_i+1}  # everything that follows the option, ex. -eopipefail -> pipefail
		local _L_values=(${_L_value:+"${_L_value}"})
		local _L_opti=0
		if ! _L_argparse_parser_find_option _L_opti "$_L_option"; then
			if ((_L_i == 1)); then
				L_argparse_fatal "unrecognized option ${_L_args[_L_argsi]}" || return "$?"
			else
				L_argparse_fatal "unrecognized option $_L_option in ${_L_args[_L_argsi]}" || return "$?"
			fi
			# This is special - if _L_comp_enabled, then we should ignore invalid options and carry on
			((++_L_argsi))
			return 0
		fi
		local _L_nargs=${_L_opt_nargs[_L_opti]:-}
		case "$_L_nargs" in
		0)
			# The loop above checks left arguments, so we shift here when there are no more args.
			if ((_L_i + 1 == ${#_L_args[_L_argsi]})); then ((++_L_argsi)); fi ;;
		"+"|"*") ((++_L_argsi)); _L_values+=("${_L_args[@]:_L_argsi}"); _L_argsi=${#_L_args[@]}; ;;
		"?") ((++_L_argsi)); _L_values=("${_L_values[0]:-${_L_opt_const[_L_opti]:-}}") ;;
		[0-9]*)
			local _L_req_nargs=$((_L_nargs - ${#_L_values[@]}))
			_L_values+=("${_L_args[@]:_L_argsi+1:_L_req_nargs}")
			_L_argsi=$((_L_argsi+1+_L_req_nargs))
			if ((${#_L_values[@]} != _L_nargs)); then
				L_argparse_fatal "argument $_L_option: expected ${_L_opt_nargs[_L_opti]} arguments, received ${#_L_values[@]}" || return "$?"
			fi
			;;
		*) L_argparse_fatal "invalid nargs specification of $(_L_argparse_print_curopt)" || return 1 ;;
		esac
		# Handle completion
		if ((_L_argsi == ${#_L_args[@]} && _L_comp_enabled)); then
			local _L_used_args=$((${#_L_args[@]} - _L_init_argsi))
			local _L_comp_prefix=${_L_args[_L_init_argsi]::_L_i+1}  # prefix for completion including the option
			if [[ "$_L_nargs" == 0 || ( "$_L_used_args" -eq 1 && -z "$_L_value" ) ]]; then
				# nargs=0 or this is an option without value, just add a space.
				L_argparse_compgen -W "$_L_comp_prefix" || return "$?"
				exit
			elif [[ "$_L_used_args" -eq 1 && -n "$_L_value" ]]; then
				# nargs!=0 and user started typing the value, try to complete it.
				_L_argparse_optspec_gen_completion "$_L_value" "$_L_comp_prefix" || return "$?"
			else
				# nargs!=0 and user given more arguments. Complete the last value, if any.
				# "" on the end - fix for Bash5.1
				_L_argparse_optspec_gen_completion "${_L_values[@]:+"${_L_values[${#_L_values[@]}-1]}"}""" || return "$?"
			fi
		fi
		_L_argparse_optspec_execute_action ${_L_values[@]+"${_L_values[@]}"} || return 1
	done
}

_L_argparse_parse_args_parse_options() {
	# Parse -short and --long options.
	case "${_L_args[_L_argsi]}" in
	--)
		if ((_L_argsi+1 == ${#_L_args[@]})); then _L_argparse_gen_option_names_completion "${_L_args[_L_argsi]}"; fi
		_L_options_enabled=""
		((_L_argsi++))
		;;
	["$_L_pc"]["$_L_pc"]?*) _L_argparse_parse_args_long_option || return "$?" ;;
	["$_L_pc"]?) _L_argparse_parse_args_short_option || return "$?" ;;
	["$_L_pc"]??*) _L_argparse_parse_args_long_option || return "$?" ;;
	["$_L_pc"])
		if ((_L_argsi+1 == ${#_L_args[@]})); then _L_argparse_gen_option_names_completion "${_L_args[_L_argsi]}"; fi
		;;
	esac
}

# shellcheck disable=SC2309
# @description Parse the arguments with the given parser.
# @env _L_parser*
# @env _L_opt*
# @env _L_args*
_L_argparse_parse_args() {
	local IFS=' '
	_L_argparse_parse_args_internal
	{
		local _L_pc="${_L_parser_prefix_chars[_L_parseri]:--}"
		local _L_init_argsi="" _L_options_enabled=1  # When empty, options are not parsed.
		local _L_args_accumulator=()  # arguments assigned currently to _L_optspec
		local _L_assigned_parameters=""  # List of assigned _L_opti, used for checking required ones.
		local -a _L_arguments="(${_L_parser__argumentsi[_L_parseri]:-})"  # Indexes of arguments specifications into _L_opt variables.
		local _L_argumentsi=-1  # Index into _L_arguments
		local _L_opti=-1  # Last evaluated positional argument.
		while (( (_L_init_argsi = _L_argsi) < ${#_L_args[@]})); do
			# Parse options arguments, if enabled.
			${_L_options_enabled:+_L_argparse_parse_args_parse_options}
			if ((_L_init_argsi == _L_argsi)); then
				# If no arguments were parsed, parse positional arguments.
				if ((${#_L_args_accumulator[@]} == 0)); then
					# Get the next positional argument.
					if ((++_L_argumentsi >= ${#_L_arguments[@]})); then
						L_argparse_fatal "unrecognized argument: ${_L_args[_L_argsi]}" || return "$?"
						break
					fi
					_L_opti=${_L_arguments[_L_argumentsi]}
					if ((${_L_parser_remainder[_L_parseri]:-})); then
						_L_options_enabled=""
					fi
					case "${_L_opt_action[_L_opti]}" in
					store) if ((_L_opt__isarray[_L_opti])); then _L_argparse_optspec_dest_arr_clear; fi ;;
					_subparser)
						_L_argparse_optspec_dest_arr_clear
						_L_argparse_optspec_dest_arr_append "${_L_args[@]:_L_argsi}"
						_L_options_enabled=""
						_L_subparser_opti=$_L_opti
						_L_subparser_argsi=$_L_argsi
						_L_argsi=${#_L_args[@]}
						break
						;;
					esac
				fi
				if [[ -n "${_L_parser_fromfile_prefix_chars[_L_parseri]:-}" && \
						"${_L_parser_fromfile_prefix_chars[_L_parseri]}" == *"${_L_args[_L_argsi]::1}"* ]]; then
					if [[ ! -e "${_L_args[_L_argsi]:1}" ]]; then
						L_argparse_fatal "arguments input file ${_L_args[_L_argsi]:1} does not exists" || return "$?"
					fi
					while IFS= read -r line; do
						L_array_insert _L_args "$_L_argsi" "$line"
					done <"${_L_args[_L_argsi]:1}"
				else
					_L_args_accumulator+=("${_L_args[_L_argsi]}")
					case "${_L_opt_nargs[_L_opti]}" in
					"+"|"*")
						if ((_L_options_enabled)); then
							_L_argparse_optspec_execute_action "${_L_args[_L_argsi]}" || return "$?"
						else
							_L_argparse_optspec_execute_action "${_L_args[@]:_L_argsi}" || return "$?"
							_L_argsi=${#_L_args[@]}
						fi
						;;
					"?")
						_L_argparse_optspec_execute_action "${_L_args[_L_argsi]}" || return "$?"
						_L_args_accumulator=()
						;;
					[0-9]*)
						if ((${#_L_args_accumulator[@]} == _L_opt_nargs[_L_opti])); then
							_L_argparse_optspec_execute_action "${_L_args_accumulator[@]}" || return "$?"
							_L_args_accumulator=()
						fi
						;;
					*) _L_argparse_spec_fatal "invalid nargs specification of $_L_opti nargs=${_L_opt_nargs[_L_opti]} $(_L_argparse_print_curopt)" ;;
					esac
					if ((_L_argsi+1 == ${#_L_args[@]})); then _L_argparse_optspec_gen_completion "${_L_args[_L_argsi]}" || return "$?"; fi
				fi
				((++_L_argsi))
			fi
		done
	}
	_L_argparse_parse_args_set_defaults
	{
		# Check if all required arguments have value.
		local _L_required_arguments=()  # List of _L_opti of required arguments.
		while ((${#_L_args_accumulator[@]} == 0 && ++_L_argumentsi < ${#_L_arguments[@]})); do
			_L_opti=${_L_arguments[_L_argumentsi]}
			if [[ "${_L_opt_action[_L_opti]}" == _subparser ]]; then
				_L_subparser_opti=$_L_opti
				_L_subparser_argsi=$_L_argsi
				break
			fi
			_L_argparse_optspec_gen_completion "" || return "$?"
			case "${_L_opt_nargs[_L_opti]}" in
			"+")
				if ((${#_L_args_accumulator[@]} == 0)); then
					_L_required_arguments[_L_opti]=1
				fi
				;;
			[0-9]*)
				if ((${#_L_args_accumulator[@]} != _L_opt_nargs[_L_opti])); then
					_L_required_arguments[_L_opti]=1
				fi
				;;
			esac
			_L_args_accumulator=()
		done
		if ((_L_options_enabled)); then
			# If there are no arguments to complete, complete option names.
			_L_argparse_gen_option_names_completion || return "$?"
		fi
	}
	{
		# Check if all required options have value
		local _L_required_options=()
		local _L_opti
		for _L_opti in ${_L_parser__optionsi[_L_parseri]:-}; do
			if L_is_true "${_L_opt_required[_L_opti]:-}"; then
				if [[ " $_L_assigned_parameters " != *" $_L_opti "* ]]; then
					_L_required_options[_L_opti]=1
				fi
			fi
		done
		# Check if required options are set
		if ((${#_L_required_options[@]} || ${#_L_required_arguments[@]})); then
			# declare -p _L_required_options _L_required_arguments
			local _L_required_options_str="" _L_i _L_desc
			for _L_opti in ${_L_required_options[@]:+"${!_L_required_options[@]}"} ${_L_required_arguments[@]:+"${!_L_required_arguments[@]}"}; do
				_L_argparse_optspec_get_description _L_desc
				_L_required_options_str+="${_L_required_options_str:+, }${_L_desc}"
			done
			L_argparse_fatal "the following arguments are required: ${_L_required_options_str}" || return 1
		fi
	}
}

# @description Call something with temporary _L_args.
_L_argparse_spec_call() {
	local _L_args=("${@:2}") _L_argsi=0
	"$1"
}

 # @description Setup parser values to inherit specific values of parent parser.
 # This is called when subparser is instantiated.
 # So in the case call=subparser { here }
 # But also in the call=function case.
 # The function does not inherit Adest, that would be confusing.
 # Each function is separate scope.
 # @arg $1 The parser id, usually _L_parseri. _L_parser_parent[$1] must be set.
_L_argparse_spec_subparser_inherit_from_parent() {
	: "${_L_parser_show_default[_L_parser__parent[$1]]+
		${_L_parser_show_default[$1]:="${_L_parser_show_default[_L_parser__parent[$1]]}"}}"
	: "${_L_parser_allow_abbrev[_L_parser__parent[$1]]+
		${_L_parser_allow_abbrev[$1]:="${_L_parser_allow_abbrev[_L_parser__parent[$1]]}"}}"
	: "${_L_parser_allow_subparser_abbrev[_L_parser__parent[$1]]+
		${_L_parser_allow_subparser_abbrev[$1]:="${_L_parser_allow_subparser_abbrev[_L_parser__parent[$1]]}"}}"
}

# @description The main entrypoint for parsing argument specification arguments.
# L_argparse argument specification arguments start with parser options,
# chains of options or arguments separted by --,
# nested subparsers enclosed by { },
# and all parsing ends with ----.
# @noargs
_L_argparse_spec_parse_args() {
	{
		_L_parseri=$((++_L_parsercnt))
		for ((; _L_argsi < ${#_L_args[@]}; _L_argsi++ )); do
			case "${_L_args[_L_argsi]}" in
			# {
			--|----|'}') break ;;
			Adest=?*) _L_parser_Adest[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			add_help=?*) _L_parser_add_help[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			aliases=*) _L_parser_aliases[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			allow_abbrev=?*) _L_parser_allow_abbrev[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			allow_subparser_abbrev=?*) _L_parser_allow_subparser_abbrev[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			description=*) _L_parser_description[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			epilog=*) _L_parser_epilog[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			help=*) _L_parser_help[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			name=?*) _L_parser_name[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			prefix_chars=?*) _L_parser_prefix_chars[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			prog=*) _L_parser_prog[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			show_default=?*) _L_parser_show_default[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			usage=*) _L_parser_usage[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			remainder=*) _L_parser_remainder[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			unknown_args=*) _L_parser_unknown_args[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			fromfile_prefix_chars=*) _L_parser_fromfile_prefix_chars[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			color=*) _L_parser_color[_L_parseri]=${_L_args[_L_argsi]#*=} ;;
			*[$' \r\v\t\n=']*|*=*|'') _L_argparse_spec_fatal "unknown parser k=v argument: ${_L_args[_L_argsi]}" || return 2 ;;
			*)
				if ((_L_parseri == 1)); then
					_L_argparse_spec_fatal "unknown parser positional argument: ${_L_args[_L_argsi]}" || return 2
				else
					if [[ -n "${_L_parser_name[_L_parseri]:-}" ]]; then
						_L_argparse_spec_fatal "parser or subparser received multiple positional arguments: ${_L_args[_L_argsi]}" || return 2
					fi
					_L_parser_name[_L_parseri]=${_L_args[_L_argsi]}
				fi
				;;
			esac
		done
	}
	# Is it a subparser?
	if ((_L_parseri != 1)); then
		# a subparser has to have a name
		if [[ -z "${_L_parser_name[_L_parseri]:-}" ]]; then
			_L_argparse_spec_fatal "a subparser has to have a name=" || return 2
		fi
		if ((_L_parseri == _L_parser__parent[_L_parseri])); then
			_L_argparse_spec_fatal "internal error: circular loop detected in subparsers" || return 2
		fi
		_L_argparse_spec_subparser_inherit_from_parent "$_L_parseri"
		: "${_L_parser_Adest[_L_parser__parent[_L_parseri]]+
			${_L_parser_Adest[_L_parseri]:="${_L_parser_Adest[_L_parser__parent[_L_parseri]]}"}}"
	fi
	{
		# validate Adest
		if [[ -n "${_L_parser_Adest[_L_parseri]:-}" ]]; then
			if ! L_is_valid_variable_name "${_L_parser_Adest[_L_parseri]}"; then
				_L_argparse_spec_fatal "not a valid variable name: Adest=${_L_parser_Adest[_L_parseri]}" || return 2
			fi
		fi
	}
	{
		# add help if requested
		if [[ "${_L_parser_prefix_chars[_L_parseri]:--}" == *-* ]] && L_is_true "${_L_parser_add_help[_L_parseri]:-1}"; then
			# Handle case if there already exists -h or --help options.
			local _L_tmp=("${L_argparse_template_help[@]}")
			if [[ " ${_L_parser__optionlookup[_L_parseri]:-} " == *" --help="* ]]; then
				unset -v '_L_tmp[1]'
			fi
			if [[ " ${_L_parser__optionslookup[_L_parseri]:-} " == *" -h="* ]]; then
				unset -v '_L_tmp[0]'
			fi
			if [[ -n "${_L_tmp[0]:-}${_L_tmp[1]:-}" ]]; then
				((++_L_opti))
				_L_argparse_spec_call _L_argparse_spec_call_parameter "${_L_tmp[@]}" || return 2
			fi
		fi
	}
	{
		# Parse rest of arguments
		while (( ${#_L_args[@]} - _L_argsi >= 2)) && [[ "${_L_args[_L_argsi]}" == "--" ]]; do
			((++_L_opti))
			case "${_L_args[++_L_argsi]}" in
			""|----|--|"{"|"}") _L_argparse_spec_fatal "invalid arguments: ${_L_args[_L_argsi]:-}" ;;
			call=function|class=function) ((++_L_argsi)); _L_argparse_spec_call_function || return 2 ;;
			call=subparser|class=subparser) ((++_L_argsi)); _L_argparse_spec_call_subparser || return 2 ;;
			call=*|class=*) _L_argparse_spec_fatal "invalid ${_L_args[_L_argsi]%=*}, must be subparser or function: ${_L_args[_L_argsi]:-}" ;;
			*) _L_argparse_spec_call_parameter || return 2 ;;
			esac
		done
	}
}

_L_argparse_print_var() {
	local IFS=$' \t\n' v i r idx=() ignore="" out="" line="" style="" c OPTIND OPTARG OPTERR
	while getopts "s:i:" c; do
		case "$c" in
		s) style="$OPTARG" ;;
		i) idx[OPTARG]=1 ;;
		*) return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	# shellcheck disable=SC2207
	local vars=($(compgen -A variable -- "$1" || :))
	if ((${#idx[@]} == 0)); then
		for v in "${vars[@]}"; do
			eval "i=(\"\${!$v[@]}\")"
			if ((${#i[@]})); then
				for i in "${i[@]}"; do
					idx[i]=1
				done
			else
				ignore+=" $v "
			fi
		done
	fi
	case "$style" in
	table)
		# remove ignored vars
		i=()
		for v in "${vars[@]}"; do
			if [[ " $ignore " != *" $v "* ]]; then
				i+=("$v")
			fi
		done
		vars=("${i[@]}")
		# print heading
		line=""
		for v in "${vars[@]}"; do
			line+=$'\1'${v##"$1"}
		done
		out+=$line$'\n'
		# print values
		for i in "${!idx[@]}"; do
			line="$i"
			for v in "${vars[@]}"; do
				r="$v[$i]"
				if L_var_is_set "$r"; then
					printf -v line "%s\1%q" "$line" "${!r}"
				else
					printf -v line "%s\1" "$line"
				fi
			done
			out+=$line$'\n'
		done
		L_table -s $'\1' "$out"
		# column -t -s $'\t' <<<"$out"
		;;
	kv|*)
		for i in "${!idx[@]}"; do
			printf "%s" "  $1$i:"
			for v in "${vars[@]}"; do
				r="$v[$i]"
				if L_var_is_set "$r"; then
					printf " %s=%q" "${v##"$1"}" "${!r}"
				fi
			done
			printf "\n"
		done
		;;
	esac
}

# Print the parser values
_L_argparse_print() {
	echo "  _L_parseri=$_L_parseri _L_parsercnt=$_L_parsercnt _L_opti=$_L_opti _L_optcnt=$_L_optcnt"
	_L_argparse_print_var _L_parser_
	_L_argparse_print_var _L_opt_
}

_L_argparse_print_curopt() {
	_L_argparse_print_var -i "$_L_opti" _L_opt_
}

# @description Parse command line aruments according to specification.
# This command takes groups of command line arguments separated by `--` with sentinel `----` .
# The first group of arguments are arguments _L_parser.
# The next group of arguments are arguments _L_optspec.
# The last group of arguments are command line arguments passed to `_L_argparse_parse_args`.
# @note the last separator `----` is different to make it more clear and restrict parsing better.
L_argparse() {
	if L_var_is_set _L_parseri; then
		local _L_parsercur=$((_L_parsercnt + 1))
	else
		# _L_parsercur - Index of current parser we should parse with.
		# _L_parseri - Current index in _L_parser_. Starts with 1.
		# _L_parsercnt - Count of elements in _L_parser_ arrays.
		# _L_parser__parent - Index of parent parser of a parser, in case of subparsers.
		# _L_parser__optionlookup - Space separated list of --option=$_L_opti of options to indexes separated by equal sign.
		# _L_parser__optionsi - Space separated list of options indexes.
		# _L_parser__argumentsi - Space separated list of arguments indexes.
		local \
			_L_parsercur=1 \
			_L_parseri=0 \
			_L_parsercnt=0 \
			_L_parser_prog=() \
			_L_parser_Adest \
			_L_parser_add_help \
			_L_parser_aliases \
			_L_parser_allow_abbrev \
			_L_parser_allow_subparser_abbrev \
			_L_parser_description \
			_L_parser_epilog \
			_L_parser_help \
			_L_parser_name \
			_L_parser_prefix_chars \
			_L_parser_show_default \
			_L_parser_usage \
			_L_parser_remainder \
			_L_parser_unknown_args \
			_L_parser_fromfile_prefix_chars \
			_L_parser_color \
			_L_parser__parent \
			_L_parser__optionlookup \
			_L_parser__optionsi \
			_L_parser__argumentsi \
			#
		# _L_opti - Current index in _L_opt_. Starts with 1.
		# _L_optcnt - Count of options.
		# _L_opt__class - Argument or option or function or subparser.
		# _L_opt__isarray - 1 if argument is an array.
		# _L_opt__options - space separated list of -o --options.
		# _L_opt__parseri - The index of parent parser this option belongs to.
		#                   When traversing all parser options, you have to filter on current parser index.
		local \
			_L_opti=0 \
			_L_optcnt=0 \
			_L_opt_action \
			_L_opt_choices=() \
			_L_opt_complete \
			_L_opt_const \
			_L_opt_eval \
			_L_opt_default \
			_L_opt_dest \
			_L_opt_help \
			_L_opt_metavar \
			_L_opt_nargs \
			_L_opt_required \
			_L_opt_show_default \
			_L_opt_type \
			_L_opt_validate \
			_L_opt_deprecated \
			_L_opt_prefix \
			_L_opt_subcall \
			_L_opt__class \
			_L_opt__isarray=() \
			_L_opt__options \
			_L_opt__parseri
		local _L_comp_enabled=0 # set if we are in completion.
		local _L_comp_shell="" # if we are completing, set to Bash or Zsh or Fish.
	fi
	local _L_args=("$@")  # The arguments. Using global array is way faster then passing around $@.
	local _L_argsi=0      # Index into _L_args
	local _L_subparser_argsi="" # Index in _L_args where subparser arguments start.
	local _L_subparser_opti=-1  # The option index of the subparser argument.
	_L_argparse_spec_parse_args || return 2
	# After parsing, restore the indexes.
	_L_parseri=$_L_parsercur
	unset -v _L_parsercur
	_L_optcnt=$_L_opti
	#
	if [[ "${_L_args[_L_argsi++]:-}" != "----" ]]; then
		_L_argsi=$((_L_argsi-1))
		_L_argparse_spec_fatal "missing separator ---- at ${_L_args[_L_argsi]:-}"
	fi
	# _L_argparse_print >/dev/tty
	_L_argparse_parse_args || return "$?"
	{
		# Handle subparser
		while ((_L_subparser_argsi)); do
			local _L_argsi=$_L_subparser_argsi _L_opti=$_L_subparser_opti
			local _L_subparsers=() _L_indexes=() _L_i _L_subparseri=-1 _L_subparser_guesses=() _L_subparseri_abbrev=()
			# If this is the last argument, complete it with subparsers names.
			if ((_L_comp_enabled && _L_argsi+1 == ${#_L_args[@]})); then
				case "${_L_opt__class[_L_opti]}" in
				subparser)
					_L_argparse_sub_subparser_get_helps _L_helps "${_L_args[_L_argsi]}" || return "$?"
					;;
				function)
					# Only get help of subparsers if it is going to be fast. subcall=detect is slow.
					if L_is_true "${_L_opt_subcall[_L_opti]:-}"; then
						_L_argparse_sub_function_get_helps _L_helps "${_L_args[_L_argsi]}" || return "$?"
					else
						_L_argparse_sub_function_choices _L_helps "${_L_args[_L_argsi]}"
						_L_helps=(${_L_helps[@]+"${_L_helps[@]/#/${_L_args[_L_argsi]}}"})
					fi
					;;
				esac
				_L_helps=(${_L_helps[@]+"${_L_helps[@]//$L_GS}"})
				_L_helps=(${_L_helps[@]+"${_L_helps[@]/$'\n'/$L_GS}"})
				# shellcheck disable=SC2145
				printf "${_L_helps[@]+plain$L_GS}%s" ${_L_helps[@]+"${_L_helps[@]/%/$'\n'}"}
				exit
			fi
			# Get subparsers names and indexes if using subparser.
			case "${_L_opt__class[_L_opti]}" in
			subparser) _L_argparse_sub_subparser_choices_indexes _L_subparsers _L_indexes || return "$?" ;;
			function) _L_argparse_sub_function_choices _L_subparsers || return "$?" ;;
			*) L_argparse_fatal "internal error class=${_L_opt__class[_L_opti]}" || return 2 ;;
			esac
			if ((_L_argsi < ${#_L_args[@]})); then
				# Find the subparser. Generate a list of similar subparsers to manipulate them later.
				for _L_i in "${!_L_subparsers[@]}"; do
					case "${_L_subparsers[_L_i]}" in
					"${_L_args[_L_argsi]}") _L_subparseri=$_L_i; break ;;
					"${_L_args[_L_argsi]}"*) _L_subparser_guesses+=("${_L_subparsers[_L_i]}") _L_subparseri_abbrev+=("$_L_i") ;;
					*"${_L_args[_L_argsi]}"*) _L_subparser_guesses+=("${_L_subparsers[_L_i]}") ;;
					esac
				done
			fi
			# If no subparser is found and allow_abbrev and there is only one abbreviation found, use it.
			if ((_L_subparseri == -1 && ${#_L_subparseri_abbrev[@]} == 1)) && L_is_true "${_L_parser_allow_subparser_abbrev[_L_parseri]:-0}"; then
					_L_subparseri=${_L_subparseri_abbrev[0]}
			fi
			# If no subparser is found.
			if ((_L_subparseri == -1)); then
				# Colors as used in printing help message, copied.
				local cred=$'\x11' cgreen=$'\x12' cyellow=$'\x13' cblue=$'\x14' cpurple=$'\x15' ccyan=$'\x16' creset=$'\x1A' cdel=$'[\x11\x12\x13\x14\x15\x16\x10]'
				if ((_L_comp_enabled)); then
					# Just complete option in case no subparser. We do not know which subparser to use to complete here.
					# _L_argparse_gen_option_names_completion "${_L_args[${#_L_args[@]}-1]}"
					# I feel like completing option names here is just wrong and confusing.
					exit
				fi
				#
				local _L_prog
				_L_argparse_parser_get_full_program_name _L_prog
				if ((_L_argsi < ${#_L_args[@]})); then
					local txt="unrecognized command $creset'$cpurple$_L_prog $ccyan${_L_args[_L_argsi]}$creset'"
				else
					local txt="missing command"
					_L_subparser_guesses=("${_L_subparsers[@]}")
				fi
				if ((${#_L_subparser_guesses[@]})); then
					L_sort_bash _L_subparser_guesses
					txt+=$'\n\n'"Did you mean this?"$'\n'$cgreen
					for i in "${_L_subparser_guesses[@]}"; do
						txt+=$'\t'"$i"$'\n'
					done
					txt=${txt::${#txt}-1}$creset$'\n'
				fi
				if L_is_true "${_L_parser_add_help[_L_parseri]:-1}"; then
					txt+=$'\n'"Try '$cpurple$_L_prog $ccyan--help$creset' for more information"
				fi
				L_argparse_fatal "$txt" || return 1
				return 1
			fi
			case "${_L_opt__class[_L_opti]}" in
			function)
				local _L_func="${_L_opt_prefix[_L_opti]}${_L_subparsers[_L_subparseri]}" _L_cmd="${_L_subparsers[_L_subparseri]}"
				_L_argparse_sub_function_prepare_call "$_L_cmd"
				if ((_L_comp_enabled)); then
					if _L_argparse_sub_function_is_ok_to_call "$_L_cmd"; then
						"$_L_func" --L_argparse_get_completion "${_L_args[@]:_L_argsi+1}" || exit $?
					fi
					exit
				fi
				"$_L_func" "${_L_args[@]:_L_argsi+1}" || return "$?"
				break
				;;
			subparser)
				# Child function takes parser parent index from this.
				_L_parseri=${_L_indexes[_L_subparseri]}
				# Reset sub args so we do not loop forever.
				_L_subparser_argsi=0
				_L_subparser_opti=-1
				_L_args=("${_L_args[@]:_L_argsi+1}")
				_L_argsi=0
				_L_argparse_parse_args || return "$?"
			esac
		done
	}
	{
		# Make sure we exit always here in completion and not execute user code.
		if ((_L_comp_enabled)); then
			exit
		fi
	}
	{
		# If L_argparse finished, dissallow nesting. Explicitly unset parent(!) scope _L_parseri.
		# The variables are still set, as we can be "inside" a function chain.
		# main -> L_argparse -> somefunction() { L_argparse; <here should be no nesting> }
		unset -v _L_parseri
	}
}

# ]]]
# proc [[[
# @section proc
# Processes and jobs related functions.

# @description Get bashpid in a way compatible with Bash before 4.0.
# @arg $1 Variable to store the result to.
L_bashpid_to() {
	printf -v "$1" "%s" "${BASHPID:-$(exec "${BASH:-sh}" -c 'echo "$PPID"')}"
}

# @description Send signal to itself.
# @arg $@ Kill arguments. See kill --help.
L_raise() {
	local pid
	L_bashpid_to pid
	kill "$@" "$pid"
}

# @description
L_kill_all_jobs() {
	local IFS='[]' j _
	while read -r _ j _; do
		kill "%$j"
	done <<<"$(jobs)"
}

# @description
L_wait_all_jobs() {
	local IFS='[]' j _
	while read -r _ j _; do
		wait "%$j"
	done <<<"$(jobs)"
}

# @description Get all pids of all child processes including grandchildren recursively.
# @option -v <var>
# @arg [$1] Pid of the parent. Default: $BASHPID.
# @see https://stackoverflow.com/a/52544126/9072753
L_get_all_childs() { L_handle_v_array "$@"; }
L_get_all_childs_v() {
	local _L_toppid=${1:-} IFS=$' \t\n' _L_ps_output _L_ps_pid _L_children_of _L_pid _L_ppid _L_unproc_idx
	if [[ -z "$_L_toppid" ]]; then
		L_bashpid_to _L_toppid
	fi
	#
	L_hash ps && _L_ps_output=$(
			L_bashpid_to _L_pid
			echo "$_L_pid"
			exec ps -e -o pid= -o ppid=
	) && {
		# Extract ps _L_pid that we conveniently put as the first item.
		read -r _L_ps_pid <<<"$_L_ps_output"
		# Populate a sparse array mapping pids to (string) lists of child pids.
		_L_children_of=()
		while read -r _L_pid _L_ppid; do
			if [[ -n "$_L_pid" && -n "$_L_ppid" && _L_pid -ne _L_ppid && _L_pid -ne _L_ps_pid && _L_ppid -ne _L_ps_pid ]]; then
				_L_children_of[_L_ppid]+=" $_L_pid"
			fi
		done <<<"$_L_ps_output"
		# Add children to the list of pids until all descendants are found
		L_v=("$_L_toppid")
		_L_unproc_idx=0    # Index of first process whose children have not been added
		while (( ${L_v[@]+${#L_v[@]}}+0 > _L_unproc_idx )) ; do
			_L_pid=${L_v[_L_unproc_idx++]}     # Get first unprocessed, and advance
			# shellcheck disable=SC2206
 			L_v+=(${_L_children_of[_L_pid]-})  # Add child pids (ignore ShellCheck)
		done
		# ( echo "${L_v[@]}"; pstree -p "$_L_toppid" ) | sed 's/^/init /' >&100
		# I do not want to return _L_toppid of itself.
		unset -v 'L_v[0]'
	}
}

# @description Kills all childs of the pid.
# @arg -sigspec Signal to use.
# @arg [$1] Pid of the process to kill all childs of. Defualt: $BASHPID
L_kill_all_childs() {
	local L_v sig
	while [[ "${1:-}" == -* ]]; do
		sig="$1"
		shift
	done
	L_get_all_childs_v "$@"
	if (( ${L_v[*]:+${#L_v[*]}}+0 )); then
		kill ${sig:+"$sig"} "${L_v[@]}"
	fi
}

# @description Check if file descriptor is open.
# @arg $1 file descriptor
# shellcheck disable=SC2188
L_is_fd_open() {
	{ >&"$1"; } 2>/dev/null
}

if ((L_HAS_VARIABLE_FD)); then
# @description Get free file descriptors
# @arg $@ variables to assign with the file descriptor numbers
L_get_free_fd_to() {
	local _L__fd
	for _L__fd in "$@"; do
		exec {_L__fd}>/dev/null
		printf -v "$1" "%d" "$_L__fd"
		shift
	done
}
# shellcheck disable=SC2094
_L_pipe_opener() {
	# First open the file descriptor for both, so that opening is not getting stuck.
	exec {_L_tmp}<>"$_L_file" {_L_0}<"$_L_file" {_L_1}>"$_L_file" {_L_tmp}>&-
}
else
	L_get_free_fd_to() {
		local _L__fd
		for _L__fd in {18..1023}; do
			if ! L_is_fd_open "$_L__fd"; then
				printf -v "$1" "%d" "$_L__fd"
				if (($# == 1)); then
					return
				fi
				shift
			fi
		done
		return 1
	}
	# shellcheck disable=SC2094
	_L_pipe_opener() {
		L_get_free_fd_to _L_tmp _L_0 _L_1 &&
		eval "exec ${_L_tmp}<>\"\$_L_file\" ${_L_0}<\"\$_L_file\" ${_L_1}>\"\$_L_file\" ${_L_tmp}>&-"
	}
fi

# @description Open two connected file descriptors.
# This internally creates a temporary file with mkfifo
# The result variable is assigned an array that:
#   - [0] element is input from the pipe,
#   - [1] element is the output to the pipe.
# This is meant to mimic the pipe() C function.
# @arg <var> variable name to assign result to
# @arg [str] template temporary filename, default: ${TMPDIR:/tmp}/L_pipe_XXXXXXXXXX
L_pipe() {
	local _L_i _L_file _L_1 _L_0 _L_tmp
	L_assert 'mktemp or mkfifo utilities are missing' L_hash mktemp mkfifo
	for _L_i in _ _ _ _ _; do
		if
			_L_file="$(mktemp -u "${2:-${TMPDIR:-/tmp}/L_pipe_XXXXXXXXXX}")" &&
			mkfifo "$_L_file"
		then
			if _L_pipe_opener; then
				rm "$_L_file" || return 1
				L_array_assign "$1" "$_L_0" "$_L_1" || return 1
				return 0
			else
				rm "$_L_file" || return 1
			fi
		fi
	done
	return 1
}

_L_proc_init_setup_redirs() {
	local arg="$1" redir="$2" mode="$3" val="${!4}" ret="" fd=()
	if [[ -n "$mode" ]]; then
		L_printf_append _L_redirs " %s" "$redir"
		case "$mode" in
		null) L_printf_append _L_redirs "/dev/null" ;;
		close) L_printf_append _L_redirs "%s" "&-" ;;
		input)
			if [[ "$redir" != *"<" ]]; then
				L_func_error "invalid argument $arg: not possible to input string to output" 1
				return 2
			fi
			L_printf_append _L_redirs " <(printf %%s %q)" "$val"
			;;
		stdout) L_printf_append _L_redirs "&1" ;;
		stderr) L_printf_append _L_redirs "&2" ;;
		pipe)
			L_pipe fd "${TMPDIR:-/tmp}/L_proc_${val}_XXXXXXXX" || return "$?"
			# Pipe file descriptors are inverted depending on the direction.
			if [[ "$redir" == "0<" ]]; then
				fd=("${fd[1]}" "${fd[0]}")
			fi
			_L_toclose+=" ${fd[1]}>&-"
			ret="${fd[0]}"
			# Pipe file descriptors have to be closed so that EOF is properly propagated.
			L_printf_append _L_redirs "&%d %d>&- %d>&-" "${fd[1]}" "${fd[0]}" "${fd[1]}"
			if ((_L_dryrun)); then
				_L_toclose+=" $ret>&-"
			fi
			;;
		file)
			if [[ ! -e "$val" ]]; then L_func_error "invalid argument $arg: file does not exists: $val" 1; return 2; fi
			L_printf_append _L_redirs "%q" "$val"
			;;
		fd) L_printf_append _L_redirs "&%d" "$val" ;;
		*) L_func_error "Invalid argument $arg $mode" 1; return 2; ;;
		esac
		printf -v "$4" "%s" "$ret" || return 2
	fi
}

# @description
# Process open. Coproc replacement.
#
# The input/output options are in three groups:
#
#   - -I and -i for stdin,
#   - -O and -o for stdout,
#   - -E and -e for stderr.
#
# Uppercase letter option specifies the mode for the file descriptor.
#
# There are following modes available that you can give to uppercase options -I -O and -E:
#
#   - null - redirect to or from /dev/null
#   - close - close the file descriptor >&-
#   - input - -i specifies the string to forward to stdin. Only allowed for -I.
#   - stdout - connect file descriptor to stdout. -o or -e value are ignored.
#   - stderr - connect file descriptor to stderr. -o or -e value are ignored.
#   - pipe - create a fifo and connect file descriptor to it. -i -o or -e option specifies part of the temporary filename.
#   - file - connect file descriptor to file specified by -i -o or -e option
#   - fd - connect file descriptor to another file descriptor specified by -i -o or -e option
#
# There first argument specifies an output variable that will be assigned the PID.
#
# Several global array variables hold additional information about the process:
#
#   - `_L_PROC_EXIT[PID]` - Exitcode or empty if not yet finished.
#   - `_L_PROC_FD0[PID]` - If -Ipipe the file descriptor connected to stdin of the program, otherwise empty.
#   - `_L_PROC_FD1[PID]` - If -Opipe the file descriptor connected to stdout of the program, otherwise empty.
#   - `_L_PROC_FD2[PID]` - If -Epipe the file descriptor connected to stderr of the program, otherwise empty.
#   - `_L_PROC_CMD[PID]` - The %q escaped command that was executed.
#
# You should use getters `L_proc_get_*` to extract the data from them variable.
#
# @option -I <mode> stdin mode
# @option -i <param> string for -Iinput, file for -Ifile, fd for -Ifd
# @option -O <mode> stdout mode
# @option -o <param> file for -Ifile, fd for -Ifd
# @option -E <mode> stderr mode
# @option -e <param> file for -Efile, fd for -Efd
# @option -n Dryrun mode. Do not execute the generated command. Instead print it to stdout.
# @option -W <int> Register with L_finally a return trap on stacklevel <int> that will wait for the popen to finish. Typically -W 0
# @option -h Print this help and return 0.
# @arg $1 variable name to store the result to.
# @arg $@ command to execute.
# @example
#   L_proc_popen -Ipipe -Opipe -Estdout proc sed 's/w/W/g'
#   L_proc_printf proc "%s\n" "Hello world"
#   L_proc_read proc line
#   L_proc_wait -c -v exitcode proc
#   echo "$line"
#   echo "$exitcode"
L_proc_popen() {
	local _L_inmode="" _L_in="" _L_outmode="" _L_out="" _L_errmode="" _L_err="" _L_opt="" _L_v \
		OPTIND OPTARG OPTERR _L_cmd _L_redirs="" _L_toclose="" _L_dryrun=0 _L_i _L_cleanup=""
	# Parse arguments.
	while getopts i:I:o:O:e:E:nW:h _L_opt; do
		case "$_L_opt" in
		i) _L_in="$OPTARG" ;;
		I) _L_inmode="$OPTARG" ;;
		o) _L_out="$OPTARG" ;;
		O) _L_outmode="$OPTARG" ;;
		e) _L_err="$OPTARG" ;;
		E) _L_errmode="$OPTARG" ;;
		W) _L_cleanup=$1 ;;
		n) _L_dryrun=1 ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	_L_v="$1"
	shift
	if ((!$#)); then
		L_func_usage_error "no command to execute"
		return 2
	fi
	printf -v _L_cmd "%q " "$@" || return "$?"
	_L_cmd=${_L_cmd%% }
	# Setup redirections.
	_L_proc_init_setup_redirs -I "0<" "$_L_inmode" "_L_in" || return "$?"
	_L_proc_init_setup_redirs -O "1>" "$_L_outmode" "_L_out" || return "$?"
	_L_proc_init_setup_redirs -E "2>" "$_L_errmode" "_L_err" || return "$?"
	# Execute command.
	if (( _L_dryrun )); then
		# bash -n -c "$_L_cmd"
		echo "$_L_cmd $_L_redirs"
	else
		eval "$_L_cmd $_L_redirs &"
	fi
	# Cleanup.
	eval "${_L_toclose:+exec ${_L_toclose}}"
	# Assign result.
	printf -v "$_L_v" "%s" "$!"
	_L_PROC_EXIT[$!]=
	_L_PROC_FD0[$!]=$_L_in
	_L_PROC_FD1[$!]=$_L_out
	_L_PROC_FD2[$!]=$_L_err
	_L_PROC_CMD[$!]=$_L_cmd
	# Register finally trap if requested.
	if [[ -n "$_L_cleanup" ]]; then
		L_finally -r -s "$((_L_cleanup + 1))" L_proc_popen_finally "$!"
	fi
}

# @description Get exitcode of L_proc.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 PID from L_proc_popen
L_proc_get_exitcode() { L_handle_v_scalar "$@"; }
L_proc_get_exitcode_v() { L_v=${_L_PROC_EXIT[$1]}; }

# @description Get PID from L_proc_popen of L_proc.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 PID from L_proc_popen
L_proc_get_pid() { L_handle_v_scalar "$@"; }
L_proc_get_pid_v() { L_v=$1; }

# @description Get file descriptor for stdin of L_proc.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 PID from L_proc_popen
L_proc_get_stdin() { L_handle_v_scalar "$@"; }
L_proc_get_stdin_v() { L_v=${_L_PROC_FD0[$1]}; }

# @description Get file descriptor for stdout of L_proc.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 PID from L_proc_popen
L_proc_get_stdout() { L_handle_v_scalar "$@"; }
L_proc_get_stdout_v() { L_v=${_L_PROC_FD1[$1]}; }

# @description Get file descriptor for stderr of L_proc.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 PID from L_proc_popen
L_proc_get_stderr() { L_handle_v_scalar "$@"; }
L_proc_get_stderr_v() { L_v=${_L_PROC_FD2[$1]}; }

# @description Get command of L_proc.
# @option -v <var> Store the output in the array variable instead of printing it.
# @arg $1 PID from L_proc_popen
L_proc_get_cmd() { L_handle_v_array "$@"; }
L_proc_get_cmd_v() { eval "L_v=(${_L_PROC_CMD[$1]})"; }

_L_proc_get_fd_v() {
	L_v="_L_PROC_FD$2[$1]"
	L_v=${!L_v}
}

_L_proc_rm_fd() { eval "_L_PROC_FD$2[$1]="; }

_L_proc_set_exitcode() { _L_PROC_EXIT[$1]=$2; }

L_proc_free() {
	unset "_L_PROC_EXIT[$1]" "_L_PROC_FD0[$1]" "_L_PROC_FD1[$1]" "_L_PROC_FD2[$1]" "_L_PROC_CMD[$1]"
}

# @description Handler that can be closed from L_finally or a signal handler.
# Closes file descriptors. If L_SIGNAL is a signal, forwards it to the process.
# Then wait for the process termination.
# @arg $1 L_proc **value**. This is because the variable may go out of scope.
#    This is bad. when closing a file descriptor, we "remember" that the file descriptor was closed in the variable.
#    This is less then ideal, but I do not know at this time how to fix it better.
#    Potentially, this can cause unrelated file descriptors to get closed.
#    This might change in the future.
# @example L_finally proc -W sleep infinity
# @example
#    L_finally proc sleep infinity
#    L_finally L_proc_popen_finally "$proc"
#
#    # or
#    L_finally proc sleep infinity
#    L_finally L_eval 'L_proc_popen_finally "${!1}"' proc
L_proc_popen_finally() {
	local proc="$1"
  L_proc_close proc
  if [[ "$L_SIGNAL" == SIG* ]]; then
    L_proc_send_signal proc "$L_SIGNAL"
  fi
  L_proc_wait proc
}

# @description Write printf formatted string to coproc.
# @arg $1 PID from L_proc_popen
# @arg $@ any printf arguments
L_proc_printf() {
	local L_v
	L_proc_get_stdin_v "$1"
	# shellcheck disable=SC2059
	printf "${@:2}" >&"$L_v"
}

# @description Exec read bultin with -u file descriptor of stdout of coproc.
# @arg $1 PID from L_proc_popen
# @arg $@ any builtin read options
L_proc_read() {
	local L_v
	L_proc_get_stdout_v "$1"
	read -r -u "$L_v" "${@:2}"
}

# @description Exec read bultin with -u file descriptor of stderr of coproc.
# @arg $1 PID from L_proc_popen
# @arg $@ any builtin read options
# @see L_proc_read
L_proc_read_stderr() {
	local L_v
	L_proc_get_stderr_v "$1"
	read -r -u "$L_v" "${@:2}"
}

# @description Close stdin, stdout and stderr of L_proc
# @arg $1 PID from L_proc_popen
L_proc_close() {
	_L_proc_close_fd "$1" 0
	_L_proc_close_fd "$1" 1
	_L_proc_close_fd "$1" 2
}

# @description Close stdin of L_proc.
# Does nothing if already closed or not started with -Opipe.
# @arg $1 PID from L_proc_popen
L_proc_close_stdin() {
	_L_proc_close_fd "$1" 0
}

# @description Close stdout of L_proc.
# Does nothing if already closed or not started with -Opipe
# @arg $1 PID from L_proc_popen
L_proc_close_stdout() {
	_L_proc_close_fd "$1" 1
}

# @description Close stderr of L_proc.
# Does nothing if already closed or not started with -Epipe.
# @arg $1 PID from L_proc_popen
L_proc_close_stderr() {
	_L_proc_close_fd "$1" 2
}

# @description Close file descriptor of L_proc.
# @arg $1 PID from L_proc_popen
# @arg $2 file descriptor index
_L_proc_close_fd() {
	local L_v
	_L_proc_get_fd_v "$1" "$2"
	if [[ -n "$L_v" ]]; then
		if ! [[ "$L_v" =~ ^[0-9]+$ ]]; then
			L_func_error "internal error: is not a file descriptor $2: $L_v"
			return 2
		fi
		eval "exec $L_v>&-"
		_L_proc_rm_fd "$1" "$2"
	fi
}

# @description Check if L_proc is finished.
# @arg $1 PID from L_proc_popen
# @exitcode 0 if L_proc is running, 1 otherwise
L_proc_poll() {
	local L_v
	L_proc_get_exitcode_v "$1"
	if [[ -n "$L_v" ]]; then
		return 1
	else
		L_proc_get_pid_v "$1"
		if kill -0 "$L_v" 2>/dev/null; then
			return 0
		else
			if wait "$L_v"; then
				_L_proc_set_exitcode "$1" 0
			else
				_L_proc_set_exitcode "$1" $?
			fi
			L_proc_close "$1"
			return 1
		fi
	fi
}

# @description Detect if available tail accepts --pid= option.
_L_wait_tail_has_pid() {
	local tt
	if tt=$(tail --help 2>&1) && [[ "$tt" == *"--pid="* ]]; then
		_L_wait_tail_has_pid() { return 0; }
	else
		_L_wait_tail_has_pid() { return 1; }
	fi
	_L_wait_tail_has_pid
}

_L_wait_assign_pids_done_rets() {
	# Remove from _L_pids pids that are finished.
	for _L_i in "${!_L_pids[@]}"; do
		if [[ " ${_L_done[*]+${_L_done[*]}} " == *" ${_L_pids[_L_i]} "* ]]; then
			unset -v "_L_pids[_L_i]"
		fi
	done
	# Calculate return value.
	# Timeout occurs when there are any unfinished pids.
	# Timeout in -n mode occurs when no single one pid is finished.
	if (( _L_all ? ${_L_pids[@]+${#_L_pids[@]}}+0 != 0 : ${_L_done[@]+${#_L_done[@]}}+0 == 0 )); then
		_L_return=124
	fi
	# Assign results.
	if [[ -n "$_L_pids_var" ]]; then
		L_array_assign "$_L_pids_var" ${_L_done[@]:+"${_L_done[@]}"}
	fi
	if [[ -n "$_L_rets_var" ]]; then
		L_array_assign "$_L_rets_var" ${_L_rets[@]:+"${_L_rets[@]}"}
	fi
	if [[ -n "$_L_left_var" ]]; then
		L_array_assign "$_L_left_var" ${_L_pids[@]:+"${_L_pids[@]}"}
	fi
}

# @arg $1 exit code of previous wait call
# @arg $@ wait arguments that resulted in this exit code
# shellcheck disable=SC2094
_L_wait_handle_err() {
	if (($1 == 127)); then
		# Wait returns 127 on error.
		_L_tmpf=$(mktemp) || return 1
		{
			rm "$_L_tmpf"
			wait "${@:2}" 2>&10
			err=$(cat <&11)
			if [[ -n "$err" ]]; then
				return 1
			fi
		} 10>"$_L_tmpf" 11<"$_L_tmpf"
	fi
}

_L_wait_collect_all_pids_and_assign_pids_done_rets() {
	# For wait -p _L_tmp variable to be unset, it _has to_ be local within the same scope.
	# Otherwise it will unset and fallback to the upper scope _L_tmp,
	# which might happen to have a value.
	local _L_tmp
	for _L_pid in "${_L_pids[@]}"; do
		if ((L_HAS_WAIT_P)); then
			# -p is unset when receiving a signal.
			while wait -n -p _L_tmp "$_L_pid" && _L_ret=0 || _L_ret=$?; ! L_var_is_set _L_tmp; do
				# We have received a signal, wait again.
				_L_wait_handle_err "$_L_ret" -n -p _L_tmp "$_L_pid" || return "$?"
			done
		else
			while wait "$_L_pid" && _L_ret=0 || _L_ret=$?; (( _L_ret > 128 )); do
				# If received a signal while waiting, check if the pid is finished.
				if ! kill -0 "$_L_pid" 2>/dev/null; then
					# If it is finihsed, collect it again to be extra sure.
					wait "$_L_pid" && _L_ret=0 || _L_ret=$?
					break
				fi
			done
			_L_wait_handle_err "$_L_ret" "$_L_pid" || return "$?"
		fi
		_L_rets+=("$_L_ret")
	done
	_L_done=("${_L_pids[@]}")
	_L_pids=()
	_L_wait_assign_pids_done_rets
}

_L_wait_collect_any_pids() {
	for _L_i in "${!_L_pids[@]}"; do
		if ! kill -0 "${_L_pids[_L_i]}" 2>/dev/null; then
			wait "${_L_pids[_L_i]}" && _L_ret=$? || _L_ret=$?
			_L_wait_handle_err "$_L_ret" "${_L_pids[_L_i]}" || return "$?"
			_L_rets+=("$_L_ret")
			_L_done+=("${_L_pids[_L_i]}")
			unset -v "_L_pids[$_L_i]"
			if ((!_L_all)); then
				break
			fi
		fi
	done
}

# @description Wait for pids to be finished with a timeout and capture exit codes.
# Tries to use waitpid or tail --pid or a busy loop for best performance.
#
# The waiting is uninterruptible by signals.
#
# Note: builtin kill with multiple pids has different exit code depending on posix mode.
# @option -t <timeout> Wait for this long. Timeout 0 results in just collecting all pids.
# @option -v <var> Exit code of PIDs will be assigned to <var>. The elements of -v and -p arrays are pairs.
# @option -p <var> PIDs that exited will be assigned to array variable <var>.
# @option -l <var> Left running PIDs will be assigned to array variable <var>.
# @option -P <polltime> The time to poll processes when not possible to use waitpid or tail. Default: 0.1
# @option -n Return 0 when at least one of the pids is finished.
# @option -b Bash only. Do not use waitpid or tail.
# @option -h Print this help and exit.
# @arg $@ pids to wait on
# @return 0 on success
#         2 usage error
#         124 timeout
L_wait() {
	local OPTIND OPTARG OPTERR _L_timeout="" _L_rets_var="" _L_pids_var="" _L_left_var="" \
		_L_polltime=0.1 _L_all=1 _L_bashonly=0 _L_ret _L_i _L_pid _L_tmp _L_tmpf IFS=' ' \
		_L_pids _L_done=() _L_rets=() _L_return=0
	while getopts t:v:p:l:P:nbh _L_i; do
		case "$_L_i" in
			t) _L_timeout=$OPTARG ;;
			v) _L_rets_var=$OPTARG ;;
			p) _L_pids_var=$OPTARG ;;
			l) _L_left_var=$OPTARG ;;
			P) _L_polltime=$OPTARG ;;
			n) _L_all=0 ;;
			b) _L_bashonly=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	# local -;set -x
	# _L_pids - runnign pids
	# _L_done - finished pids
	# _L_rets - pid _L_done[i] exited with _L_rets[i]
	# _L_return - the return code
	_L_pids=("$@")
	# Return with 0 with no PIDs.
	if ((!${_L_pids[*]:+1}+0)); then return 0; fi
	if [[ -z "$_L_timeout" ]]; then
		if ((_L_all || $# == 1)); then
			# Wait for all pids without a timeout.
			_L_wait_collect_all_pids_and_assign_pids_done_rets || return "$?"
		else
			# Wait for the first pid without a timeout.
			if ((L_HAS_WAIT_P)); then
				while wait -n -p _L_pid "${_L_pids[@]}" && _L_ret=0 || _L_ret=$?; ! L_var_is_set _L_pid; do
					_L_wait_handle_err "$_L_ret" -n -p _L_pid "${_L_pids[@]}" || return "$?"
				done
				_L_rets+=("$_L_ret")
				_L_done+=("$_L_pid")
			else
				# Wait for any pid to finish.
				while
					_L_wait_collect_any_pids || return "$?"
					(( ${_L_rets[@]+${#_L_rets[@]}}+0 == 0 ))
				do
					sleep "$_L_polltime"
				done
			fi
			_L_wait_assign_pids_done_rets
		fi
		return 0
	else
		# Handle timeout.
		# Wait for pids to be finished for the specified timeout.
		if ((!_L_bashonly)) && [[ "$_L_timeout" != 0 ]]; then
			if L_hash waitpid; then
				if
					if (($# == 1 || _L_all)); then
						waitpid -e -t "$_L_timeout" "$@"
					else
						# waitpid does not like in-existing pids.
						# Check if are any finished before calling it.
						# There is a slight race condition, but hope it isn't a problem.
						kill -0 "$@" 2>/dev/null && waitpid -c 1 -t "$_L_timeout" "$@" 2>/dev/null
					fi
				then
					if ((_L_all)); then
						_L_wait_collect_all_pids_and_assign_pids_done_rets || return "$?"
					else
						_L_wait_collect_any_pids || return "$?"
						_L_wait_assign_pids_done_rets
					fi
					return 0
				elif (($? == 3)); then
					_L_wait_collect_any_pids || return "$?"
					_L_wait_assign_pids_done_rets
					return "$_L_return"
				fi
			fi
			# Tail can only wait for _all_ pids, not on the first one.
			if (($# == 1 || _L_all)) && L_hash timeout tail && _L_wait_tail_has_pid; then
				if timeout "$_L_timeout" tail "${@/#/--pid=}" -f /dev/null; then
					_L_wait_collect_all_pids_and_assign_pids_done_rets || return "$?"
					return 0
				elif (($? == 124)); then
					_L_wait_collect_any_pids || return "$?"
					_L_wait_assign_pids_done_rets
					return "$_L_return"
				fi
			fi
		fi
		# Busy loop.
		L_timeout_set_to _L_timeout "$_L_timeout"
		while
			_L_wait_collect_any_pids || return "$?"
			# Are there any still running pids?
			(( ${_L_pids[@]:+1} )) &&
				# If waiting for any pid, are no pids finished?
				(( _L_all || ${_L_rets[@]+${#_L_rets[@]}}+0 == 0 )) &&
				# Has timeout not expired?
				! L_timeout_expired "$_L_timeout"
		do
			sleep "$_L_polltime"
		done
		_L_wait_assign_pids_done_rets
		return "$_L_return"
	fi
}

# @description Wait for L_proc to finish.
# If L_proc has already finished execution, will only evaluate -v option.
# @option -t <int> Timeout in seconds. Will try to use waitpid, tail --pid or busy loop with sleep.
# @option -v <var> Store the L_proc exit code in the variable.
# @option -c Close L_proc file descriptors before waiting.
# @option -h Print this help and return 0.
# @arg $1 PID from L_proc_popen
# @exitcode 0 if L_proc has finished
#           124 if timeout expired
L_proc_wait() {
	local L_v _L_v="" _L_timeout="" _L_opt _L_ret OPTIND OPTARG OPTERR _L_close=0
	while getopts t:v:ch _L_opt; do
		case "$_L_opt" in
		t) _L_timeout="$OPTARG" ;;
		v) _L_v="$OPTARG" ;;
		c) _L_close=1 ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if ((_L_close)); then
		L_proc_close "$1"
	fi
	L_proc_get_exitcode_v "$1"
	if [[ -z "$L_v" ]]; then
		L_proc_get_pid_v "$1"
		L_wait -t "$_L_timeout" -v L_v "$L_v" || return "$?"
		_L_proc_set_exitcode "$1" "$L_v"
	fi
	if [[ -n "$_L_v" ]]; then
		printf -v "$_L_v" "%s" "$L_v"
	fi
}

# @description Read from multiple file descriptors at the same time.
# @note The minimum read -t argument in Bash3.2 is 1 second. It is not possible
# to set it lower or to a fraction. This does not work great for Bash3.2 for short timeout,
# as one read takes at least 1 second to execute.
# @option -t <timeout> Timeout in seconds.
# @option -p <timeout> Poll timeout. The read -t argument value. Default: 0.05 or 1 in Bash3.2
# @option -h Print this help and return 0.
# @option -n <var> After any fd errors or becomes EOF, assign the fd number to <var> and return 0.
# @option -C <callback> Each time any chunk of data is read,
#            evaluate the expression "<callback> <fd> <variable> <line>".
# @option -d <delim> Read -d argument. Default: ''
# @option -1 Run the reading loop possible once.
# @arg $1 <int> File descriptor to read from.
# @arg $2 <var> Variable to assign the output of $1.
# @arg $@ Continued pairs of file descriptor and variable names.
# @example
#   exec 10< <(for ((i=0;i<5;++i)); do echo $i; sleep 1; done)
#   exec 11< <(for ((i=0;i<5;++i)); do echo $i; sleep 2; done)
#   L_read_fds 10 a 11 b
#   echo "read from 10 fd text: $a"
#   echo "read from 11 fd text: $b"
# @return 0 on success
#         124 on timeout
L_read_fds() {
	local _L_vars=() _L_fds=() _L_i _L_ret _L_line OPTIND OPTARG OPTERR \
		_L_timeout="" _L_poll=0.05 IFS="" _L_cb="" _L_n="" _L_once=0 _L_delim=''
	while getopts t:p:C:n:d:1h _L_i; do
		case "$_L_i" in
		t) if ! L_timeout_set_to _L_timeout "$OPTARG"; then L_func_usage_error "invalid timeout: $OPTARG"; return 2; fi ;;
		p) _L_poll="$OPTARG" ;;
		C) _L_cb="$OPTARG" ;;
		n) _L_n="$OPTARG"; printf -v "$_L_n" "%s" "" || return 2 ;;
		d) _L_delim=$OPTARG ;;
		1) _L_once=1 ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if ((!$#)); then
		L_func_usage_error "no file descriptors to read from"
		return 2
	fi
	# Collect arguments into arrays.
	while (($#)); do
		_L_fds+=("$1")
		_L_vars+=("$2")
		if ! shift 2; then
			L_func_usage_error "the number of arguments must be even"
			return 2
		fi
	done
	# The lowest timeout in read in <Bash4.0 is 1 second, cause it is an integer.
	if ((!L_HAS_BASH4_0)); then
		_L_poll=${_L_poll%.*}
		if ((_L_poll <= 0)); then
			_L_poll=1
		fi
	fi
	while ((${#_L_fds[@]})); do
		if [[ -n "$_L_timeout" ]]; then
			# If this is last file descriptor, the read timeout is equal to global timeout.
			if ((${#_L_fds[@]} == 1)); then
				L_timeout_left -v _L_poll "$_L_timeout"
				if ((!L_HAS_BASH4_0)); then
					_L_poll=${_L_poll%.*}
					if ((_L_poll <= 0)); then
						_L_poll=1
					fi
				fi
			fi
			# This check is done after calculation, so we know _L_poll is positive above.
			if L_timeout_expired "$_L_timeout"; then
				return 124
			fi
		else
			# If this is last single file descriptor, do not timeout the read.
			if ((${#_L_fds[@]} == 1)); then
				_L_poll=""
			fi
		fi
		#
		local _L_ok=0
		for _L_i in "${!_L_fds[@]}"; do
			if read -r -d "$_L_delim" ${_L_poll:+-t"$_L_poll"} -u "${_L_fds[_L_i]}" _L_line; then
				_L_line+="$_L_delim"
				# read success
				if [[ -n "$_L_cb" ]]; then
					"$_L_cb" "${_L_fds[_L_i]}" "${_L_vars[_L_i]}" "$_L_line"
				fi
				if [[ -n "${_L_vars[_L_i]}" ]]; then
					L_printf_append "${_L_vars[_L_i]}" "%s" "$_L_line"
				fi
				_L_ok=$((_L_ok+1))
			elif (($? > 128)); then
				# read timeout
				if [[ -n "$_L_line" ]]; then
					if [[ -n "$_L_cb" ]]; then
						"$_L_cb" "${_L_fds[_L_i]}" "${_L_vars[_L_i]}" "$_L_line"
					fi
					if [[ -n "${_L_vars[_L_i]}" ]]; then
						L_printf_append "${_L_vars[_L_i]}" "%s" "$_L_line"
					fi
				fi
			else
				# other error - remove fd
				if [[ -n "$_L_line" ]]; then
					if [[ -n "$_L_cb" ]]; then
						"$_L_cb" "${_L_fds[_L_i]}" "${_L_vars[_L_i]}" "$_L_line"
					fi
					if [[ -n "${_L_vars[_L_i]}" ]]; then
						L_printf_append "${_L_vars[_L_i]}" "%s" "$_L_line"
					fi
				fi
				if [[ -n "$_L_n" ]]; then
					printf -v "$_L_n" "%s" "${_L_fds[$_L_i]}"
					return 0
				fi
				unset -v "_L_fds[_L_i]" "_L_vars[_L_i]"
			fi
		done
		# If once mode and all fds have timeouted, return 0
		# echo "$_L_once $_L_ok ${#_L_fds[@]}"
		if (( _L_once && _L_ok == 0 )); then
			return 0
		fi
	done
}

# @description Communicate with L_proc.
#
# Interact with process: Send data to stdin.
# Read data from stdout and stderr, until end-of-file is reached.
# Wait for process to terminate.
#
# @option -i <str> Send string to stdin.
#                  Note that if you want to send data to the process’s stdin, you need to create the L_proc object with -I PIPE.
# @option -o <var> Append stdout data to this variable. Variable is not cleared.
#                  To get anything, you need to create L_proc object with -O PIPE.
# @option -e <var> Append stderr to this variable. Variable is not cleared.
#                  To get anything, you need to create L_proc object with -E PIPE.
# @option -t <int> Timeout in seconds.
# @option -k Kill L_proc after communication.
# @option -v <var> Store the output in variable instead of printing it.
# @option -h Print this help and return 0.
# @arg $1 PID from L_proc_popen
# @exitcode
#   0 on success.
#   2 on usage error.
#   124 on timeout.
L_proc_communicate() {
	local OPTIND OPTARG OPTERR _L_tmp=() _L_opt _L_input="" _L_output="" _L_error="" _L_timeout="" L_v _L_stdin _L_stdout _L_stderr _L_pid _L_kill=0 IFS="" _L_v
	while getopts i:o:e:t:kv:h _L_opt; do
		case "$_L_opt" in
		i) _L_input="$OPTARG" ;;
		o) _L_output="$OPTARG" ;;
		e) _L_error="$OPTARG" ;;
		t) _L_timeout="$OPTARG" ;;
		k) _L_kill=1 ;;
		v) _L_v="$OPTARG" ;;
		h) L_func_help; return 0 ;;
		*) L_func_error; return 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	if [[ -n "$_L_input" ]]; then
		L_proc_printf "$1" "%s" "$_L_input"
	fi
	L_proc_close_stdin "$1"
	# Collect stdout and stderr to read from.
	if [[ -n "$_L_output" ]]; then
		L_proc_get_stdout_v "$1"
		if [[ -n "$L_v" ]]; then
			_L_tmp+=("$L_v" "$_L_output")
		fi
	else
		L_proc_close_stdout "$1"
	fi
	if [[ -n "$_L_error" ]]; then
		L_proc_get_stderr_v "$1"
		if [[ -n "$L_v" ]]; then
			_L_tmp+=("$L_v" "$_L_error")
		fi
	else
		L_proc_close_stderr "$1"
	fi
	if [[ -n "$_L_output" || -n "$_L_error" ]]; then
		L_read_fds ${_L_timeout:+-t"$_L_timeout"} "${_L_tmp[@]}" || return "$?"
	fi
	L_proc_close_stdout "$1"
	L_proc_close_stderr "$1"
	#
	if ((_L_kill)); then
		L_proc_kill "$1"
	fi
	L_proc_wait ${_L_v:+-v"$_L_v"} ${_L_timeout:+-t"$_L_timeout"} "$1" || return "$?"
}

# @description Send signal to L_proc.
# @arg $1 PID from L_proc_popen
# @arg $2 signal to send
L_proc_send_signal() {
	local L_v
	L_proc_get_pid_v "$1"
	kill -"$2" "$L_v"
}

# @description Terminate L_proc.
# @arg $1 PID from L_proc_popen
L_proc_terminate() { L_proc_send_signal "$1" SIGTERM; }

# @description Kill L_proc.
# @arg $1 PID from L_proc_popen
L_proc_kill() { L_proc_send_signal "$1" SIGKILL; }

# ]]]
# lib [[[
# @section lib
# @description internal functions and section.
# Internal functions to handle terminal interaction.

_L_lib_name=${BASH_SOURCE[0]##*/}

_L_lib_error() {
	echo "$_L_lib_name: ERROR: $*" >&2
}

_L_lib_fatal() {
	_L_lib_error "$@"
	exit 3
}

_L_lib_drop_L_prefix() {
	for i in run fatal logl log emerg alert crit err warning notice info debug panic error warn; do
		eval "$i() { L_$i \"\$@\"; }"
	done
}

_L_lib_list_prefix_functions() {
	L_list_functions_with_prefix "$L_prefix" | sed "s/^$L_prefix//"
}

# shellcheck disable=2046
_L_lib_their_usage() {
	if L_function_exists L_cb_usage; then
		L_cb_usage "$(_L_lib_list_prefix_functions)"
		return
	fi
	local a_usage a_desc a_cmds a_footer
	a_usage="Usage: $L_NAME <COMMAND> [OPTIONS]"
	a_cmds=$(
		{
			_L_lib_list_prefix_functions
			echo "-h --help"$'\01'"print this help and exit"
			echo "--bash-completion"$'\01'"generate bash completion to be eval'ed"
		} | {
			if L_command_exists column && column -V 2>/dev/null | grep -q util-linux; then
				column -t -s $'\01' -o '   '
			else
				sed 's/#/    /'
			fi
		} | sed 's/^/  /'
	)
	cat <<EOF
$a_usage

Commands:
$a_cmds

EOF
}

_L_lib_show_best_match() {
	local tmp
	if tmp=$(
		_L_lib_list_prefix_functions |
			if L_hash fzf; then
				fzf -0 -1 -f "$1"
			else
				grep -F "$1"
			fi
	) && [[ -n "$tmp" ]]; then
		echo
		echo "The most similar commands are"
		# shellcheck disable=2001
		<<<"$tmp" sed 's/^/\t/'
	fi >&2
}

# https://stackoverflow.com/questions/14513571/how-to-enable-default-file-completion-in-bash
# shellcheck disable=2207
_L_do_bash_completion() {
	if [[ "$(LC_ALL=C type -t -- "_L_cb_bash_completion_$L_NAME" 2>/dev/null)" = function ]]; then
		"_L_cb_bash_completion_$L_NAME" "$@"
		return
	fi
	if ((COMP_CWORD == 1)); then
		COMPREPLY=($(compgen -W "${cmds[*]}" -- "${COMP_WORDS[1]}" || :))
		# add trailing space to each
		#COMPREPLY=("${COMPREPLY[@]/%/ }")
	else
		COMPREPLY=()
	fi
}

# shellcheck disable=2120
_L_lib_bash_completion() {
	local tmp cmds
	tmp=$(_L_lib_list_prefix_functions)
	mapfile -t cmds <<<"$tmp"
	local funcname
	funcname=_L_bash_completion_$L_NAME
	eval "$funcname() {
		$(declare -p cmds L_NAME)"'
		_L_do_bash_completion "$@"
	}'
	declare -f _L_do_bash_completion "$funcname"
	printf "%s" "complete -o bashdefault -o default -F"
	printf " %q" "$funcname" "$0" "$L_NAME"
	printf '\n'
}

_L_lib_run_tests() {
	L_unittest_main -P _L_test_ "$@"
}

_L_lib_usage() {
	cat <<EOF
Usage: . $_L_lib_name [OPTIONS] COMMAND [ARGS]...

Collection of usefull bash functions. See online documentation at
https://github.com/Kamilcuk/L_lib.sh .

Options:
  -s  Notify this script that it is sourced.
  -h  Print this help and exit.
  -l  Drop the L_ prefix from some of the functions.

Commands:
  cmd PREFIX [ARGS]...  Run subcommands with specified prefix
  test                  Run internal unit tests
  eval EXPR             Evaluate expression for testing
  exec ARGS...          Run command for testing
  help                  Print this help and exit

Usage example of 'cmd' command:

  # script.sh
  CMD_some_func() { echo 'yay!'; }
  CMD_some_other_func() { echo 'not yay!'; }
  .  $_L_lib_name cmd 'CMD_' "\$@"

Usage example of 'bash-completion' command:

  eval "\$(script.sh cmd 'CMD_' --bash-completion)"

$_L_lib_name Copyright (C) 2024 Kamil Cukrowski
$L_FREE_SOFTWARE_NOTICE
EOF
}

_L_lib_main_cmd() {
	if (($# == 0)); then _L_lib_fatal "prefix argument missing"; fi
	L_prefix=$1
	case "$L_prefix" in
	-*) _L_lib_fatal "prefix argument cannot start with -" ;;
	"") _L_lib_fatal "prefix argument is empty" ;;
	esac
	shift
	if L_function_exists "L_cb_parse_args"; then
		unset -v L_cb_args
		L_cb_parse_args "$@"
		if ! L_var_is_set L_cb_args; then L_error "L_cb_parse_args did not return L_cb_args array"; fi
		# shellcheck disable=2154
		set -- "${L_cb_args[@]}"
	else
		case "${1:-}" in
		--bash-completion)
			_L_lib_bash_completion
			if L_is_main; then
				exit 0
			else
				return 0
			fi
			;;
		-h | --help)
			_L_lib_their_usage "$@"
			if L_is_main; then
				exit
			else
				return
			fi
			;;
		esac
	fi
	if (($# == 0)); then
		if ! L_function_exists "${L_prefix}DEFAULT"; then
			_L_lib_their_usage "$@"
			L_error "Command argument missing."
			exit 1
		fi
	fi
	L_CMD="${1:-DEFAULT}"
	shift
	if ! L_function_exists "$L_prefix$L_CMD"; then
		_L_lib_error "Unknown command: '$L_CMD'. See '$L_NAME --help'."
		_L_lib_show_best_match "$L_CMD"
		exit 1
	fi
	"$L_prefix$L_CMD" "$@"
}

_L_lib_main() {
	local _L_mode="" _L_sourced=0 OPTIND OPTARG OPTERR _L_opt _L_init=1
	while getopts nsLh-: _L_opt; do
		case $_L_opt in
		n) _L_init=0 ;;
		s) _L_sourced=1 ;;
		L) _L_lib_drop_L_prefix ;;
		h) _L_mode=help ;;
		-) _L_mode=help; break ;;
		?) exit 1 ;;
		*) _L_lib_fatal "$_L_lib_name: Internal error when parsing arguments: $_L_opt" ;;
		esac
	done
	if ((_L_init)); then
		shopt -s extglob
		if ((L_HAS_PATSUB_REPLACEMENT)); then
			shopt -s patsub_replacement
		fi
		L_trap_err_init
	fi
	shift "$((OPTIND-1))"
	if (($#)); then
		: "${_L_mode:=$1}"
		shift
	fi
	case "$_L_mode" in
	"")
		if ((!_L_sourced)) && L_is_main; then
			_L_lib_usage
			_L_lib_fatal "missing command, or if sourced, missing -s option"
		fi
		;;
	eval) eval "$*" ;;
	exec) "$@" ;;
	L_*|_L_*) "$_L_mode" "$@" ;;
	--help | help)
		if L_is_main; then
			set -euo pipefail
			L_trap_err_enable
			trap 'L_trap_err $?' EXIT
		fi
		_L_lib_usage
		exit 0
		;;
	cmd) _L_lib_main_cmd "$@" ;;
	nop) ;;
	*) _L_lib_fatal "unknown command: $_L_mode" ;;
	esac
}

# ]]]

if L_is_main || L_has_sourced_arguments; then
	_L_lib_main "$@"
fi
