#!/usr/bin/env bash
# vim: foldmethod=marker foldmarker=[[[,]]] ft=bash
# shellcheck disable=SC2034,SC2178,SC2016,SC2128,SC1083
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

# Globals [[[
# @section globals
# @description some global variables

# @description version of the library
L_LIB_VERSION=0.1.7
# @description The basename part of $0
L_NAME=${0##*/}
# @description The directory part of $0
L_DIR=${0%/*}

# ]]]
# Colors [[[
# @section colors
# @description colors to use
# Use the `L_*` colors for colored output.
# Use L_RESET or L_COLORRESET  to reset to defaults.
# Use L_color_detect to detect if the terimnla is supposed to support colors.
# @example:
#    echo "$L_RED""hello world""$L_RESET"

# @description Text to be evaled to enable colors.
_L_COLOR_SWITCH="

L_BOLD=$'\E[1m'
L_BRIGHT=$'\E[1m'
L_DIM=$'\E[2m'
L_FAINT=$'\E[2m'
# @description Italic font.
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

# @description
# @noargs
L_color_enable() {
	eval "${_L_COLOR_SWITCH}"
}

# @description
# @noargs
L_color_disable() {
	eval "${_L_COLOR_SWITCH//=/= #}"
}

# @description Detect if colors should be used on the terminal.
# @exitcode 0 if colors should be used, nonzero otherwise
# @arg [$1] file descriptor to check, default 1
# @see https://no-color.org/
# @env TERM
# @env NO_COLOR
L_term_has_color() {
	[[ -z "${NO_COLOR:-}" && "${TERM:-dumb}" != "dumb" && -t "${1:-1}" ]]
}

# shellcheck disable=SC2120
# @description Detect if colors should be used on the terminal.
# @see https://en.wikipedia.org/wiki/ANSI_escape_code#Unix_environment_variables_relating_to_color_support
# @arg [$1] file descriptor to check, default 1
L_color_detect() {
	if L_term_has_color "$@"; then
		L_color_enable
	else
		L_color_disable
	fi
}
L_color_detect

_L_test_color() {
	{
		L_color_enable
		L_unittest_eq "$L_RED" "$L_ANSI_RED"
		L_color_disable
		L_unittest_eq "$L_RED" ""
		L_color_detect
	}
}

# ]]]
# Color constants [[[
# @section color constants
# @description color constants. Prefer to use colors above with color usage detection.

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
# Ansi [[[
# @section ansi
# @description manipulating cursor positions

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
# @description check if bash has specific feature

if [ -n "${BASH_VERSINFO:-}" ]; then
# shellcheck disable=SC2004
# note: bash 4.4.24 segfaults when BASH_VERSINFO[0] is not inside ${ }
((
L_BASH_VERSION=${BASH_VERSINFO[0]} << 16 | ${BASH_VERSINFO[1]} << 8 | ${BASH_VERSINFO[2]},
L_HAS_BASH5_2=    L_BASH_VERSION >= 0x050200,
L_HAS_BASH5_1=    L_BASH_VERSION >= 0x050100,
L_HAS_BASH5=      L_BASH_VERSION >= 0x050000,
L_HAS_BASH4_4=    L_BASH_VERSION >= 0x040400,
L_HAS_BASH4_3=    L_BASH_VERSION >= 0x040300,
L_HAS_BASH4_2=    L_BASH_VERSION >= 0x040200,
L_HAS_BASH4_1=    L_BASH_VERSION >= 0x040100,
L_HAS_BASH4=      L_BASH_VERSION >= 0x040000,
L_HAS_BASH3_2=    L_BASH_VERSION >= 0x030200,
L_HAS_BASH3_1=    L_BASH_VERSION >= 0x030100,
L_HAS_BASH3=      L_BASH_VERSION >= 0x030000,
L_HAS_BASH2_5=    L_BASH_VERSION >= 0x020500,
L_HAS_BASH2_4=    L_BASH_VERSION >= 0x020400,
L_HAS_BASH2_3=    L_BASH_VERSION >= 0x020300,
L_HAS_BASH2_2=    L_BASH_VERSION >= 0x020200,
L_HAS_BASH2_1=    L_BASH_VERSION >= 0x020100,
L_HAS_BASH2=      L_BASH_VERSION >= 0x020000,
L_HAS_BASH1_14_7= L_BASH_VERSION >= 0x010E07,
1))
fi

# @description New shell option: patsub_replacement. When enabled, a `&' in the replacement
L_HAS_PATSUB_REPLACEMENT=$L_HAS_BASH5_2
# @description Bash 4.4 introduced function scoped `local -`
L_HAS_LOCAL_DASH=$L_HAS_BASH4_4
# @description The `mapfile' builtin now has a -d option
L_HAS_MAPFILE_D=$L_HAS_BASH4_4
# @description Bash 4.4 introduced ${var@Q}
L_HAS_AT_Q=$L_HAS_BASH4_4
# @description The declare builtin no longer displays array variables using the compound
# assignment syntax with quotes; that will generate warnings when re-used as
# input, and isn't necessary.
L_HAS_DECLARE_WITH_NO_QUOTES=$L_HAS_BASH4_4
# @description Bash 4.3 introduced declare -n nameref
L_HAS_NAMEREF=$L_HAS_BASH4_3
# @description Force extglob on temporarily when parsing the pattern argument to
# the == and != operators to the [[ command, for compatibility.
L_HAS_EXTGLOB_IN_TESTTEST=$L_HAS_BASH4_1
# @description Bash 4.1 introduced test/[/[[ -v variable unary operator
L_HAS_TEST_V=$L_HAS_BASH4_1
# @description `printf -v' can now assign values to array indices.
L_HAS_PRINTF_V_ARRAY=$L_HAS_BASH4_1
# @description Bash 4.0 introduced declare -A var=$([a]=b)
L_HAS_ASSOCIATIVE_ARRAY=$L_HAS_BASH4
# @description Bash 4.0 introduced mapfile
L_HAS_MAPFILE=$L_HAS_BASH4
# @description Bash 4.0 introduced readarray
L_HAS_READARRAY=$L_HAS_BASH4
# @description Bash 4.0 introduced case fallthrough ;& and ;;&
L_HAS_CASE_FALLTHROUGH=$L_HAS_BASH4
# @description Bash 4.0 introduced ${var,,} and ${var^^} expansions
L_HAS_LOWERCASE_UPPERCASE_EXPANSION=$L_HAS_BASH4
# @description Bash 4.0 introduced BASHPID variable
L_HAS_BASHPID=$L_HAS_BASH4
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
L_HAS_INDIRECT_EXPANSION=$L_HAS_BASH2
# @description Bash 1.14.7 introduced arrays
# Bash 1.14.7 also introduced:
# New variables: DIRSTACK, PIPESTATUS, BASH_VERSINFO, HOSTNAME, SHELLOPTS, MACHTYPE.  The first three are array variables.
L_HAS_ARRAY=$L_HAS_BASH1_14_7

# ]]]
# basic [[[
# @section basic
# @description Some base simple definitions for every occasion.

# @arg $1 str assertiong string description
# @arg $@ command to test
L_assert_fail() {
	set +x
	L_print_traceback >&2
	printf "%s: assertion (%s) failed%s\n" "$L_NAME" "$(L_quote_printf "${@:2}")" "${1:+: $1}" >&2
	exit 249
}

# @description Assert the command starting from second arguments returns success.
# Note: `[[` is a bash syntax sugar and is not a command.
# As last resort, use `eval "[[ ${var@Q} = ${var@Q} ]]"` if you really want to use it,
# Better prefer write and use wrapper functions, like `L_regex_match` or `L_glob_match`.
# To invert the test use `L_not` which just executes `! "$@"`.
# @arg $1 str assertiong string description
# @arg $@ command to test
# @example L_assert 'wrong number of arguments' [ "$#" = 0 ]
L_assert() {
	if ! "${@:2}"; then
		L_assert_fail "$@"
	fi
}

if ((L_HAS_UNQUOTED_REGEX)); then
# @description Wrapper around =~ for contexts that require a function.
# @arg $1 string to match
# @arg $2 regex to match against
L_regex_match() { [[ "$1" =~ $2 ]]; }
else
# shellcheck disable=SC2076
L_regex_match() { [[ "$1" =~ "$2" ]]; }
fi

# @description Produce a string that is a regex escaped version of the input.
# @option -v <var> variable to set
# @arg $@ string to escape
L_regex_escape() { L_handle_v "$@"; }
L_regex_escape_v() { L_v=${*//?/[&]}; }

_L_test_a_regex_match() {
	L_unittest_cmd L_regex_match "(a)" "^[(].*[)]$"
}

# @description inverts exit status
# @arg $@ Command to execute
L_not() { ! "$@"; }

# @description Return the first argument
# @arg $1 <int> integer to return
L_return() { return "$1"; }

if ((L_HAS_LOCAL_DASH)); then
# @description Runs the command under set -x.
# @arg $@ Command to execute
L_setx() {
	local -
	set -x
	"$@"
}
else
	L_setx() {
		# shellcheck disable=SC2064
		trap "$(set +o)" RETURN
		set -x
		"$@"
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
	# shellcheck disable=SC2053,SC2064
	L_extglob_match() {
		trap "$(shopt -p extglob)" RETURN
		shopt -s extglob
		[[ "$1" == $2 ]]
	}
fi

# @description Produce a string that is a glob escaped version of the input.
# @option -v <var> variable to set
# @arg $@ string to escape
L_glob_escape() { L_handle_v "$@"; }
L_glob_escape_v() { L_v="${*//[[?*\]/[&]}"; }  # $[

# @description Return 0 if the argument is a function
# @arg $1 function name
L_function_exists() { [[ "$(LC_ALL=C type -t -- "$1" 2>/dev/null)" = function ]]; }

# @description Return 0 if the argument is a command.
# Consider using L_hash instead.
# @arg $1 command name
# @see L_hash
L_command_exists() { command -v "$@" >/dev/null 2>&1; }

# @description Execute Bash hash builtin with silenced output.
# A typical mnemonic to check if a command exists is `if hash awk 2>/dev/null`.
# This saves to type the redirection.
# @arg $@ commands to check
L_hash() { hash "$@" >/dev/null 2>&1; }

# @description Return 0 if current script sourced
L_is_sourced() { [[ "${BASH_SOURCE[0]}" != "$0" ]]; }

# @description Return 0 if current script is not sourced
L_is_main() { [[ "${BASH_SOURCE[0]}" == "$0" ]]; }

# @description Return 0 if running in bash shell
# Portable with POSIX shell.
L_is_in_bash() { [ -n "${BASH_VERSION:-}" ]; }

# @description Return 0 if running in posix mode
L_in_posix_mode() { case ":$SHELLOPTS:" in *:posix:*) ;; *) false ;; esac; }

# @description Return 0 if variable is set
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_set() { [[ -n "${!1+yes}" ]]; }

# @description Return 0 if variable is set and is not null (not empty)
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_notnull() { [[ -n "${!1:+yes}" ]]; }

# @description Return 0 if variable is not set or is not an array neither an associative array
# @arg $1 variable nameref
L_var_is_notarray() { [[ "$(declare -p "$1" 2>/dev/null || :)" == "declare -"[^aA]* ]]; }

# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is an array, nonzero otherwise
L_var_is_array() { [[ "$(declare -p "$1" 2>/dev/null || :)" == "declare -a"* ]]; }

# @description Return 0 if variable is an associative array
# @arg $1 variable nameref
L_var_is_associative() { [[ "$(declare -p "$1" 2>/dev/null || :)" == "declare -A"* ]]; }

# @description Return 0 if variable is readonly
# @arg $1 variable nameref
L_var_is_readonly() { ! (eval "$1=") 2>/dev/null; }

# @description Return 0 if variable has integer attribute set
# @arg $1 variable nameref
L_var_is_integer() { L_regex_match "$(declare -p "$1" 2>/dev/null || :)" "^declare -[A-Za-z]*i"; }

# @description Return 0 if variable is exported.
# @arg $1 variable nameref
L_var_is_exported() { L_regex_match "$(declare -p "$1" 2>/dev/null || :)" "^declare -[A-Za-z]*x"; }

# @description Return 0 if the string happend to be something like true.
# @arg $1 str
L_is_true() { [[ "$1" == [+1-9TtYy]* ]]; }
# L_is_true() { L_regex_match "$1" "^([+]|[+]?[1-9][0-9]*|[tT]|[tT][rR][uU][eE]|[yY]|[yY][eE][sS])$"; }

# @description Return 0 if the string happend to be something like false.
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

# @description Return 0 if argument could be a variable name
# @arg $1 string to check
L_is_valid_variable_name() { L_regex_match "$1" '^[a-zA-Z_][a-zA-Z0-9_]*$'; }
# L_is_valid_variable_name() { [[ ${1:0:1} == [a-zA-Z_] && ( ${#1} == 1 || ${1:1} != *[^a-zA-Z0-9_]* ) ]]; }
# L_is_valid_variable_name() { [[ $1 == [a-zA-Z_]*([a-zA-Z0-9_]) ]]; }

# @description Return 0 if argument could be a variable name or array element
# @arg $1 string to check
# @example
#	L_is_valid_variable_or_array_element aa           # true
#	L_is_valid_variable_or_array_element 'arr[elem]'  # true
#	L_is_valid_variable_or_array_element 'arr[elem'   # false
L_is_valid_variable_or_array_element() { L_regex_match "$1" '^[a-zA-Z_][a-zA-Z0-9_]*(\[.+\])?$'; }

# @description Return 0 if the string characters is an integer
# @arg $1 string to check
L_is_integer() { L_regex_match "$1" '^[-+]?[0-9]+$'; }
# L_is_integer() { [[ $1 != *[^0-9]* || ( ${#1} -gt 1 && ${1:0:1} == [-+] && ${1:1} != *[^0-9]* ) ]]; }
# L_is_integer() { [[ $1 == ?([+-])+([0-9]) ]]; }

# @description Return 0 if the string characters is a float
# @arg $1 string to check
L_is_float() { L_regex_match "$1" '^[+-]?([0-9]*[.]?[0-9]+|[0-9]+[.])$'; }
# L_is_float() { [[ "$*" == ?([+-])@(+([0-9])?(.)|*([0-9]).+([0-9])) ]]; }

# @description Send signal to itself
# @arg $1 signal to send, see kill -l
L_raise() { kill -s "$1" "${BASHPID:-$$}"; }

_L_test_basic() {
	{
		L_unittest_checkexit 0 L_isdigit 5
		L_unittest_checkexit 0 L_isdigit 1235567890
		L_unittest_checkexit 1 L_isdigit 1235567890a
		L_unittest_checkexit 1 L_isdigit x
	}
	{
		L_unittest_checkexit 0 L_is_float -1
		L_unittest_checkexit 0 L_is_float -1.
		L_unittest_checkexit 0 L_is_float -1.2
		L_unittest_checkexit 0 L_is_float -.2
		L_unittest_checkexit 0 L_is_float +1
		L_unittest_checkexit 0 L_is_float +1.
		L_unittest_checkexit 0 L_is_float +1.2
		L_unittest_checkexit 0 L_is_float +.2
		L_unittest_checkexit 0 L_is_float 1
		L_unittest_checkexit 0 L_is_float 1.
		L_unittest_checkexit 0 L_is_float 1.2
		L_unittest_checkexit 0 L_is_float .2
		L_unittest_checkexit 1 L_is_float -.
		L_unittest_checkexit 1 L_is_float abc
	}
	{
		local a=
		L_unittest_checkexit 1 L_var_is_readonly a
		local -r b=
		L_unittest_checkexit 0 L_var_is_readonly b
	}
	if ((L_HAS_ASSOCIATIVE_ARRAY)); then
		L_unittest_checkexit 1 L_var_is_associative a
		local -A c=()
		L_unittest_checkexit 0 L_var_is_associative c
	fi
	{
		L_unittest_checkexit 1 L_var_is_array a
		local -a d=()
		L_unittest_checkexit 0 L_var_is_array d
	}
	{
		L_unittest_checkexit 1 L_var_is_set _L_variable
		local _L_variable
		if ((L_HAS_BASH4)); then
			# In bash 3.2 local sets the variable to empty. On newers it doesn't set.
			L_unittest_checkexit 1 L_var_is_set _L_variable
		fi
		_L_variable=
		L_unittest_checkexit 0 L_var_is_set _L_variable
		_L_variable=""
		L_unittest_checkexit 0 L_var_is_set _L_variable
		_L_variable="a"
		L_unittest_checkexit 0 L_var_is_set _L_variable
	}
	{
		L_unittest_checkexit 0 L_is_integer 1
		L_unittest_checkexit 0 L_is_integer 0
		L_unittest_checkexit 0 L_is_integer -1
		L_unittest_checkexit 0 L_is_integer +1
		L_unittest_checkexit 1 L_is_integer 1-
		L_unittest_checkexit 1 L_is_integer 1+
		L_unittest_checkexit 1 L_is_integer 1-2
		L_unittest_checkexit 1 L_is_integer 1+2
		L_unittest_checkexit 1 L_is_integer a
	}
	{
		L_unittest_checkexit 0 L_is_valid_variable_name a
		L_unittest_checkexit 0 L_is_valid_variable_name ab
		L_unittest_checkexit 0 L_is_valid_variable_name _ac
		L_unittest_checkexit 0 L_is_valid_variable_name _a9
		L_unittest_checkexit 1 L_is_valid_variable_name 9
		L_unittest_checkexit 1 L_is_valid_variable_name 9a
		L_unittest_checkexit 1 L_is_valid_variable_name a-
		L_unittest_checkexit 1 L_is_valid_variable_name -a
	}
	{
		L_unittest_checkexit 0 L_is_valid_variable_or_array_element aa
		L_unittest_checkexit 0 L_is_valid_variable_or_array_element 'arr[elem]'
		L_unittest_checkexit 1 L_is_valid_variable_or_array_element 'arr[elem'
		L_unittest_checkexit 0 L_is_valid_variable_or_array_element 'arr[@#!@#[][32]13]'
		L_unittest_checkexit 1 L_is_valid_variable_or_array_element '1'
		L_unittest_checkexit 1 L_is_valid_variable_or_array_element 'arr[]'
	}
}

# ]]]
# uncategorized [[[
# @section uncategorized
# @description many functions without any particular grouping

# @description newline
L_NL=$'\n'
# @description tab
L_TAB=$'\t'
# @description carriage return
L_CR=$'\r'
# @description Start of heading
L_ASCII_SOH=$'\001'
# @description Start of text
L_ASCII_STX=$'\002'
# @description End of Text
L_ASCII_EOT=$'\003'
# @description End of transmission
L_ASCII_EOF=$'\004'
# @description 255 bytes with all possible 255 values
L_ALLCHARS=$'\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\060\061\062\063\064\065\066\067\070\071\072\073\074\075\076\077\100\101\102\103\104\105\106\107\110\111\112\113\114\115\116\117\120\121\122\123\124\125\126\127\130\131\132\133\134\135\136\137\140\141\142\143\144\145\146\147\150\151\152\153\154\155\156\157\160\161\162\163\164\165\166\167\170\171\172\173\174\175\176\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'
# @description
L_LBRACE='{'
# @description
L_RBRACE='}'
# @description Looks random.
L_UUID=921c7f46-e0d8-4170-91e9-7055ee30d1e2

L_ASCII_LOWERCASE="abcdefghijklmnopqrstuvwxyz"
L_ASCII_UPPERCASE="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# @description wrapper function for handling -v arguments to other functions
# It calls a function called `<caller>_v` with arguments without `-v <var>`
# The function `<caller>_v` should set the variable nameref L_v to the returned value
#   just: L_v=$value
#   or: L_v=(a b c)
# When the caller function is called without -v, the values of L_v is printed to stdout with a newline.
# Otherwise, the value is a nameref to user requested variable and nothing is printed.
# @arg $@ arbitrary function arguments
# @exitcode Whatever exitcode does the `<caller>_v` funtion exits with.
# @example:
#    L_add() { L_handle_v "$@"; }
#    L_add_v() { L_v="$(($1 + $2))"; }
L_handle_v() {
	local L_v=() _L_r=0
	case "${1:-}" in
	-v?*)
		if [[ "$2" == -- ]]; then
			"${FUNCNAME[1]}"_v "${@:3}" || _L_r=$?
		else
			"${FUNCNAME[1]}"_v "${@:2}" || _L_r=$?
		fi
		case ${#L_v[@]} in
		0) if L_var_is_array "${1##-v}"; then eval "${1##-v}=()"; fi ;;
		1) printf -v "${1##-v}" "%s" "${L_v:-}" ;;
		*)
			if ! L_is_valid_variable_name "${1##-v}"; then
				L_assert_fail "not a valid identifier: ${1##-v}"
			fi
			eval "${1##-v}"'=("${L_v[@]}")'
		esac
		;;
	-v)
		if [[ "$3" == -- ]]; then
			"${FUNCNAME[1]}"_v "${@:4}" || _L_r=$?
		else
			"${FUNCNAME[1]}"_v "${@:3}" || _L_r=$?
		fi
		case ${#L_v[@]} in
		0) if L_var_is_array "$2"; then eval "$2=()"; fi ;;
		1) printf -v "$2" "%s" "${L_v:-}" ;;
		*)
			if ! L_is_valid_variable_name "$2"; then
				L_assert_fail "not a valid identifier: $2"
			fi
			eval "$2"'=("${L_v[@]}")'
		esac
		;;
	--)
		"${FUNCNAME[1]}"_v "${@:2}" || _L_r=$?
		${L_v[@]+printf} ${L_v[@]+"%s\n"} ${L_v[@]+"${L_v[@]}"}
		;;
	*)
		"${FUNCNAME[1]}"_v "$@" || _L_r=$?
		${L_v[@]+printf} ${L_v[@]+"%s\n"} ${L_v[@]+"${L_v[@]}"}
	esac &&
	return "$_L_r"
}

L_handle_v_getopts() {
	local OPTARG OPTIND OPTERR L_v=() _L_r=0 _L_v=""
	while getopts v: _L_r; do
		case $_L_r in
		v) _L_v="$OPTARG" ;;
		?) printf "Usage: %s [-v var] args ...\n" "${FUNCNAME[1]}" >&2; exit 2 ;;
		esac
	done
	shift "$((OPTIND-1))"
	"${FUNCNAME[1]}"_v "$@" || _L_r=$?
	case "${#L_v[@]}/$_L_v" in
	*/)
		${L_v[@]+printf} ${L_v[@]+"%s\n"} ${L_v[@]+"${L_v[@]}"} ;;
	0/*)
		if L_var_is_array "$_L_v"; then eval "$_L_v=()"; fi ;;
	1/*)
		printf -v "$_L_v" "%s" "${L_v:-}" ;;
	*/*)
		if ! L_is_valid_variable_name "$2"; then
			L_assert_fail "not a valid identifier: $2"
		fi
		eval "$2"'=("${L_v[@]}")'
	esac &&
	return "$_L_r"
}

# shellcheck disable=SC2329
_L_test_a_handle_v() {
	{
		return_123() { L_handle_v "$@"; }
		return_123_v() { return 123; }
		L_unittest_cmd -ce 123 return_123
		L_unittest_cmd -ce 123 return_123 --
		L_unittest_cmd -ce 123 return_123 a
		L_unittest_cmd -ce 123 return_123 -- a
		L_unittest_cmd -ce 123 return_123 -va a
		L_unittest_cmd -ce 123 return_123 -va -- a
		L_unittest_cmd -ce 123 return_123 -v a a
		L_unittest_cmd -ce 123 return_123 -v a -- a
	}
	{
		set_one() { L_handle_v "$@"; }
		set_one_v() { L_v=123; }
		L_unittest_cmd -co 123 set_one
		L_unittest_cmd -co 123 set_one --
		L_unittest_cmd -co 123 set_one a
		L_unittest_cmd -co 123 set_one -- a
		local a=""
		L_unittest_cmd -c set_one -va a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_one -v a a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_one -va -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_one -v a -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
	}
	{
		set_arr() { L_handle_v "$@"; }
		set_arr_v() { L_v=(456 789); }
		L_unittest_cmd -co $'456\n789' set_arr
		L_unittest_cmd -co $'456\n789' set_arr --
		L_unittest_cmd -co $'456\n789' set_arr a
		L_unittest_cmd -co $'456\n789' set_arr -- a
		local a=""
		L_unittest_cmd -c set_arr -va a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -v a a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -va -- a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -v a -- a
		L_unittest_arreq a 456 789
	}
}

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
#
#    func() {
#       if [[ "$1" == -v ]]; then
#          var=$2
#          shift 2
#		fi
#		L_printf_append "$var" "Hello "
#		L_printf_append "$var" "world\n"
#	 }
#	 func
#	 func -v var
L_printf_append() {
	printf ${1:+"-v$1"} "%s$2" "${1:+${!1}}" "${@:3}"
}

L_copyright_gpl30orlater() {
	cat <<EOF
$L_NAME Copyright (C) $*

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
EOF
}

# @description notice that the software is a free software.
L_FREE_SOFTWARE_NOTICE="\
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE."

L_free_software_copyright() {
	cat <<EOF
$L_NAME Copyright (C) $*
$L_FREE_SOFTWARE_NOTICE
EOF
}

# @description Output a string with the same quotating style as does bash in set -x
# @option -v <var> variable to set
# @arg $@ arguments to quote
L_quote_setx() { L_handle_v "$@"; }
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
# @option -v <var> variable to set
# @arg $@ arguments to quote
L_quote_printf() { L_handle_v "$@"; }
L_quote_printf_v() { printf -v L_v " %q" "$@"; L_v=${L_v:1}; }

# @description Output a string with the same quotating style as does /bin/printf
# @option -v <var> variable to set
# @arg $@ arguments to quote
L_quote_bin_printf() { L_handle_v "$@"; }
L_quote_bin_printf_v() { L_v=$(exec printf " %q" "$@"); L_v=${L_v:1}; }

# @description Convert a string to a number.
L_strhash() { L_handle_v "$@"; }
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
L_strhash_bash() { L_handle_v "$@"; }
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
# @option -v <var> variable to set
# @arg $1 String to operate on.
L_strupper() { L_handle_v "$@"; }

# @description
# @option -v <var> variable to set
# @arg $1 String to operate on.
L_strlower() { L_handle_v "$@"; }

# @description Capitalize first character of a string.
# @option -v <var> variable to set
# @arg $1 String to operate on
L_capitalize() { L_handle_v "$@"; }

# @description Lowercase first character of a string.
# @option -v <var> variable to set
# @arg $1 String to operate on
L_uncapitalize() { L_handle_v "$@"; }

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
# @option -v <var> variable to set
# @arg $1 String to operate on.
L_strip() { L_handle_v "$@"; }
L_strip_v() {
	if [[ "$1" == *[^"$IFS"]* ]]; then
		local pre=${1%[^"$IFS"]*} post=${1#*[^"$IFS"]}
		L_v=${1:${#1}-${#post}-1:${#pre}+1-(${#1}-${#post}-1)}
	else
		L_v=""
	fi
}

# @description Remove characters from IFS from begining of string
# @option -v <var> variable to set
# @arg $1 String to operate on.
L_lstrip() { L_handle_v "$@"; }
L_lstrip_v() {
	if [[ "$1" == *[^"$IFS"]* ]]; then
		local post=${1#*[^"$IFS"]}
		L_v=${1:${#1}-${#post}-1}
	else
		L_v=""
	fi
}

# @description Remove characters from IFS from begining of string
# @option -v <var> variable to set
# @arg $1 String to operate on.
L_rstrip() { L_handle_v "$@"; }
L_rstrip_v() {
	if [[ "$1" == *[^"$IFS"]* ]]; then
		local pre=${1%[^"$IFS"]*}
		L_v=${1::${#pre}+1}
	else
		L_v=""
	fi
}

_L_test_str() {
	local tmp IFS=$' \t\n'
	L_rstrip -v tmp " a b  "
	L_unittest_eq "$tmp" " a b"
	L_rstrip -v tmp " a b"
	L_unittest_eq "$tmp" " a b"
	L_lstrip -v tmp " a b  "
	L_unittest_eq "$tmp" "a b  "
	L_lstrip -v tmp "a b  "
	L_unittest_eq "$tmp" "a b  "
	L_strip -v tmp " a b  "
	L_unittest_eq "$tmp" "a b"
	L_strip -v tmp "a b"
	L_unittest_eq "$tmp" "a b"
	L_strupper -v tmp " a b  "
	L_unittest_eq "$tmp" " A B  "
	L_strlower -v tmp " A B  "
	L_unittest_eq "$tmp" " a b  "
	L_unittest_cmd -c L_strstr " a b  " "a b"
	L_unittest_cmd -c ! L_strstr " a b  " "a X"
	L_unittest_cmd -c L_strhash -v tmp "  a b "
	L_unittest_cmd -c L_is_integer "$tmp"
	L_unittest_cmd -c L_strhash_bash -v tmp "  a b "
	L_unittest_cmd -c L_is_integer "$tmp"
	L_capitalize -v tmp "abc"
	L_unittest_eq "$tmp" "Abc"
	L_capitalize -v tmp "ABC"
	L_unittest_eq "$tmp" "ABC"
	L_capitalize -v tmp ""
	L_unittest_eq "$tmp" ""
	L_uncapitalize -v tmp "abc"
	L_unittest_eq "$tmp" "abc"
	L_uncapitalize -v tmp "ABC"
	L_unittest_eq "$tmp" "aBC"
	L_uncapitalize -v tmp ""
	L_unittest_eq "$tmp" ""
}

# @description list functions with prefix
# @option -v <var> var
# @arg $1 prefix
L_list_functions_with_prefix() { L_handle_v "$@"; }
# shellcheck disable=SC2207
L_list_functions_with_prefix_v() {
	local IFS=$'\n'
	L_v=($(compgen -A function -- "$1" || :))
}

# @description list functions with prefix and remove the prefix
# @option -v <var> var
# @arg $1 prefix
# @see L_list_functions_with_prefix
L_list_functions_with_prefix_removed() { L_handle_v "$@"; }
L_list_functions_with_prefix_removed_v() {
	L_list_functions_with_prefix_v "$@"
	L_v=("${L_v[@]/#"$1"}")
}


L_kill_all_jobs() {
	local IFS='[]' j _
	while read -r _ j _; do
		kill "%$j"
	done <<<"$(jobs)"
}

L_wait_all_jobs() {
	local IFS='[]' j _
	while read -r _ j _; do
		wait "%$j"
	done <<<"$(jobs)"
}

# @description An array to execute a command nicest way possible.
# @example "${L_NICE[@]}" make -j $(nproc)
L_NICE=(nice -n 40 ionice -c 3)
if L_hash ,nice; then
	L_NICE=(",nice")
elif L_hash chrt; then
	L_NICE+=(chrt -i 0)
fi

# @description execute a command in nicest possible way
# @arg $@ command to execute
L_nice() {
	"${L_NICE[@]}" "$@"
}

_L_sudo_args_get_v() {
	local envs=""
	for i in no_proxy http_proxy https_proxy ftp_proxy rsync_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY; do
		if [[ -n "${!i:-}" ]]; then
			envs="${envs:---preserve-env=}${envs:+,}$i"
		fi
	done
	if ((${#envs})); then
		L_v=("$envs")
	else
		L_v=()
	fi
}

# @description Execute a command with sudo if not root, otherwise just execute the command.
# Preserves all proxy environment variables.
L_sudo() {
	local sudo=()
	if ((UID != 0)) && hash sudo 2>/dev/null; then
		local -a L_v=()
		_L_sudo_args_get
		sudo=(sudo -n "${L_v[@]}")
	fi
	L_run "${sudo[@]}" "$@"
}

# @description capture exit code of a command to a variable
# @option -v <var> var
# @arg $@ command to execute
L_capture_exit() { L_handle_v "$@"; }
L_capture_exit_v() { if "$@"; then L_v=$?; else L_v=$?; fi; }

# @option -v <var> var
# @arg $1 path
L_basename() { L_handle_v "$@"; }
L_basename_v() { L_v=${*##*/}; }

# @option -v <var> var
# @arg $1 path
L_dirname() { L_handle_v "$@"; }
L_dirname_v() { L_v=${*%/*}; }

# @description Produces a string properly quoted for JSON inclusion
# Poor man's jq
# @see https://ecma-international.org/wp-content/uploads/ECMA-404.pdf figure 5
# @see https://stackoverflow.com/a/27516892/9072753
# @example
#    L_json_escape -v tmp "some string"
#    echo "{\"key\":$tmp}" | jq .
L_json_escape() { L_handle_v "$@"; }
L_json_escape_v() {
	L_v=$*
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
	L_v=${L_v//$'\x0B'/\\u000B}
	L_v=${L_v//$'\f'/\\f}
	L_v=${L_v//$'\r'/\\r}
	L_v=${L_v//$'\x0E'/\\u000E}
	L_v=${L_v//$'\x0F'/\\u000F}
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
	L_v=${L_v//$'\x1A'/\\u001A}
	L_v=${L_v//$'\x1B'/\\u001B}
	L_v=${L_v//$'\x1C'/\\u001C}
	L_v=${L_v//$'\x1D'/\\u001D}
	L_v=${L_v//$'\x1E'/\\u001E}
	L_v=${L_v//$'\x1F'/\\u001F}
	L_v=${L_v//$'\x7F'/\\u007F}
	L_v=\"$L_v\"
}

# @description Choose elements matching prefix.
# @option -v <var> Store the result in the array var.
# @arg $1 prefix
# @arg $@ elements
# @see L_abbreviation_nonewline
L_abbreviation() { L_handle_v "$@"; }
# @set L_v
L_abbreviation_v() {
	local cur=$1 IFS=$'\n'
	shift
	if [[ "${*//"$IFS"}" == "$*" ]]; then
		if ! cur=$(trap - ERR; compgen -W "$*" -- "$cur"); then
			L_v=()
			return
		fi
		# shellcheck disable=SC2329,SC2064,SC2251
		! read -d '' -r -a L_v <<<"$cur"
		L_v[${#L_v[@]}-1]=${L_v[${#L_v[@]}-1]%$'\n'}
	else
		L_v=()
		while (($#)); do
			if [[ "$1" == "$cur"* ]]; then
				L_v+=("$1")
			fi
			shift
		done
		declare -p L_v
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

_L_test_exit_to_1null() {
	{
		local var='blabla'
		L_unittest_success L_exit_to_1null var true
		L_unittest_eq "$var" 1
		L_unittest_eq "${var:+SUCCESS}" "SUCCESS"
		L_unittest_eq "${var:-0}" "1"
		L_unittest_eq "$((var))" "1"
		local var='blabla'
		L_unittest_success L_exit_to_1null var false
		L_unittest_eq "$var" ""
		L_unittest_eq "${var:+SUCCESS}" ""
		L_unittest_eq "${var:-0}" "0"
		L_unittest_eq "$((var))" "0"
	}
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
		unset "$1"
	fi
}

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
	local r=$(( a1 < b1 ? -1 : a1 > b1 ? 1 : a2 < b2 ? -1 : a2 > b2 ? 1 : 0 ))
	# echo "$a1.$a2 $2 $b1.$b2 = $r"
	case "$2" in
	-lt|'<')  ((r == -1));;
	-le|'<=') ((r <= 0));;
	-eq|'==') ((r == 0));;
	-ne|'!=') ((r));;
	-ge|'>=') ((r >= 0));;
	-gt|'>') ((r > 0));;
	'<=>') return $((r + 10));;
	*) return 255;;
	esac
}

# shellcheck disable=SC2059
# @descripriont print a string with percent format
# A simple implementation of percent formatting in bash using regex and printf.
# @arg $1 format string
# @arg $@ arguments
# @example
#   name=John
#   declare -A age=([John]=42)
#   L_percent_format "Hello, %(name)s! You are %(age[John])10s years old.\n"
L_percent_format() {
	local _L_fmt=$1 _L_args=()
	while [[ "$_L_fmt" =~ ^(.*[^%](%%)*)?%\(([^\)]+)\)(.*)$ ]]; do
		# declare -p BASH_REMATCH >&2
		_L_fmt="${BASH_REMATCH[1]}%${BASH_REMATCH[4]}"
		if [[ -z "${BASH_REMATCH[3]+var}" ]]; then
			printf "${FUNCNAME[0]}: Variable %s is not set.\n" "${BASH_REMATCH[2]}" >&2
		fi
		_L_args=("${!BASH_REMATCH[3]:-}" ${_L_args[@]+"${_L_args[@]}"})
	done
	printf "$_L_fmt" ${_L_args[@]+"${_L_args[@]}"}
}

# shellcheck disable=SC2059
# @description print a string with f-string format
# A simple implementation of f-strings in bash using regex and printf.
# @arg $1 format string
# @example
#  name=John
#  age=21
#  fstring 'Hello, {$name}! You are {$age:10s} years old.\n'
L_fstring() {
	local _L_fmt=$1 _L_args=() _L_tmp
	_L_fmt="${_L_fmt//'{{'/$'\x01'}"
	while [[ "$_L_fmt" =~ ^(.*[^\{])?\{([^:\}]+)(:([^\}]*))?\}(.*)$ ]]; do
		# declare -p BASH_REMATCH
		_L_fmt="${BASH_REMATCH[1]}%${BASH_REMATCH[4]:-s}${BASH_REMATCH[5]}"
		eval "_L_tmp=${BASH_REMATCH[2]}"
		_L_args=("$_L_tmp" ${_L_args[@]+"${_L_args[@]}"})
	done
	_L_fmt="${_L_fmt//$'\x01'/$L_LBRACE}"
	_L_fmt="${_L_fmt//'}}'/$L_RBRACE}"
	printf "$_L_fmt" ${_L_args[@]+"${_L_args[@]}"}
}

_L_test_other() {
	{
		local arr=(1 2 3)
		L_array_pop arr
		L_unittest_arreq arr 1 2
	}
	{
		local name=John
		local age=21
		L_unittest_cmd -o "Hello, John! You are         21 years old." \
			L_percent_format "Hello, %(name)s! You are %(age)10s years old.\n"
		L_unittest_cmd -o "Hello, %John! You are %%        21 years old." \
			L_percent_format "Hello, %%%(name)s! You are %%%%%(age)10s years old.\n"
		L_unittest_cmd -o "Hello, John! You are         21 years old." \
			L_fstring 'Hello, {$name}! You are {$age:10s} years old.\n'
		L_unittest_cmd -o "Hello, {John}! You are {{        21}} years old." \
			L_fstring 'Hello, {{{$name}}}! You are {{{{{$age:10s}}}}} years old.\n'
	}
	{
		local max=-1
		L_max -v max 1 2 3 4
		L_unittest_eq "$max" 4
	}
	{
		local -a a
		L_abbreviation -va ev eval shooter
		L_unittest_arreq a eval
		L_abbreviation_v e eval eshooter
		L_unittest_arreq L_v eval eshooter
		L_abbreviation -v a none eval eshooter
		L_unittest_arreq a
	}
	{
		local -a a
		L_abbreviation -v a $'\x01' "$L_ALLCHARS" var
		L_unittest_arreq a "$L_ALLCHARS"
		L_abbreviation -v a $'nl\nno' $'nothing' $'nl\nnot here' $'nl\n ok' $'nl\nno'
		L_unittest_arreq a $'nl\nnot here' $'nl\nno'
	}
	{
		L_unittest_checkexit 0 L_is_true true
		L_unittest_checkexit 1 L_is_true false
		L_unittest_checkexit 0 L_is_true yes
		L_unittest_checkexit 0 L_is_true 1
		L_unittest_checkexit 0 L_is_true 123
		L_unittest_checkexit 1 L_is_true 0
		L_unittest_checkexit 1 L_is_true 00
		L_unittest_checkexit 1 L_is_true 010
		L_unittest_checkexit 1 L_is_true atruea
		#
		L_unittest_checkexit 1 L_is_false true
		L_unittest_checkexit 0 L_is_false false
		L_unittest_checkexit 0 L_is_false no
		L_unittest_checkexit 1 L_is_false 1
		L_unittest_checkexit 1 L_is_false 123
		L_unittest_checkexit 0 L_is_false 0
		L_unittest_checkexit 0 L_is_false 00
		L_unittest_checkexit 1 L_is_false 101
		L_unittest_checkexit 1 L_is_false afalsea
	}
	{
		local min=-1
		L_min -v min 1 2 3 4
		L_unittest_eq "$min" 1
	}
	{
		L_unittest_checkexit 0 L_args_contain 1 0 1 2
		L_unittest_checkexit 0 L_args_contain 1 2 1
		L_unittest_checkexit 0 L_args_contain 1 1 0
		L_unittest_checkexit 0 L_args_contain 1 1
		L_unittest_checkexit 1 L_args_contain 0 1
		L_unittest_checkexit 1 L_args_contain 0
	}
	{
		local arr=(1 2 3 4 5)
		L_array_filter_eval arr '[[ $1 -ge 3 ]]'
		L_unittest_arreq arr 3 4 5
	}
	{
		local tmp
		L_basename -v tmp a/b/c
		L_unittest_eq "$tmp" c
		L_dirname -v tmp a/b/c
		L_unittest_eq "$tmp" a/b
	}
	{
		if L_hash jq; then
			local tmp
			t() {
				local tmp
				L_json_escape -v tmp "$1"
				# L_log "JSON ${tmp@Q}"
				out=$(echo "{\"v\":$tmp}" | jq -r .v)
				L_unittest_eq "$1" "$out"
			}
			t $'1 hello\n\t\bworld'
			t $'2 \x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f'
			t $'3 \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f'
			t $'4 \x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f'
			t $'5 \x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f'
			t "! ${L_ALLCHARS::127}"
		fi
	}
	{
		local name=1 tmp
		L_pretty_print -v tmp name 2
		L_unittest_eq "$tmp" $'declare -- name="1"\n2\n'
		local name=(1 2)
		L_pretty_print -v tmp name 2
		if ((L_HAS_DECLARE_WITH_NO_QUOTES)); then
			L_unittest_eq "$tmp" $'declare -a name=([0]="1" [1]="2")\n2\n'
		else
			L_unittest_eq "$tmp" $'declare -a name=\'([0]="1" [1]="2")\'\n2\n'
		fi
	}
	{
		L_unittest_cmd -e 0 L_float_cmp 1.1 -eq 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.1 -le 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.1 -ge 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.1 -gt 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.1 -lt 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.1 -ne 1.1
		L_unittest_cmd -e 10 L_float_cmp 1.1 '<=>' 1.1
		#
		L_unittest_cmd -e 0 L_float_cmp 1.02 -lt 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -le 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -eq 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ne 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -gt 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -ge 1.1
		L_unittest_cmd -e 9 L_float_cmp 1.02 '<=>' 1.1
		#
		L_unittest_cmd -e 1 L_float_cmp 1.02 -lt 1.0000
		L_unittest_cmd -e 1 L_float_cmp 1.02 -le 1.0000
		L_unittest_cmd -e 1 L_float_cmp 1.02 -eq 1.0000
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ne 1.0000
		L_unittest_cmd -e 0 L_float_cmp 1.02 -gt 1.0000
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ge 1.0000
		L_unittest_cmd -e 11 L_float_cmp 1.02 '<=>' 1.0000
		#
		L_unittest_cmd -e 1 L_float_cmp 1.02 -lt 1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -le 1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -eq 1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ne 1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -gt 1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ge 1
		L_unittest_cmd -e 11 L_float_cmp 1.02 '<=>' 1
		#
		L_unittest_cmd -e 1 L_float_cmp 1 -lt 1
		L_unittest_cmd -e 0 L_float_cmp 1 -le 1
		L_unittest_cmd -e 0 L_float_cmp 1 -eq 1
		L_unittest_cmd -e 1 L_float_cmp 1 -ne 1
		L_unittest_cmd -e 1 L_float_cmp 1 -gt 1
		L_unittest_cmd -e 0 L_float_cmp 1 -ge 1
		L_unittest_cmd -e 10 L_float_cmp 1 '<=>' 1
	}
	{
		L_unittest_cmd -o 'echo echo' L_quote_setx 'echo' 'echo'
		L_unittest_cmd -o $'one \'a\nb\' two' L_quote_setx 'one' $'a\nb' 'two'
	}
}

# ]]]
# Lists [[[
# @section Lists
# @description Operations on various lists, arrays and arguments. L_array_* L_args_* and others.

if ((L_HAS_NAMEREF)); then

# @description Clear an array.
# @arg $1 <var> array nameref
L_array_clear() { local -n _L_arr=$1; _L_arr=(); }

# @description Append elements to array.
# @arg $1 <var> array nameref
# @arg $@ elements to set
L_array_set() { local -n _L_arr=$1; _L_arr=("${@:2}"); }

# @description Append elements to array.
# @arg $1 <var> array nameref
# @arg $@ elements to append
L_array_append() { local -n _L_arr=$1; _L_arr+=("${@:2}"); }

# @description Append elements to the front of the array.
# @arg $1 <var> array nameref
# @arg $@ elements to append
L_array_prepend() { local -n _L_arr=$1; _L_arr=("${@:2}" ${_L_arr[@]+"${_L_arr[@]}"}); }

# @description Remove first array element.
# @arg $1 <var> array nameref
L_array_pop_front() { local -n _L_arr=$1; _L_arr=(${_L_arr[@]+"${_L_arr[@]:1}"}); }

# @description Remove last array element.
# @arg $1 <var> array nameref
L_array_pop() { local -n _L_arr=$1; unset "_L_arr[${#_L_arr[@]}-1]"; }

else  # L_HAS_NAMEREF
	L_array_clear() { eval "$1=()"; }
	L_array_set() { eval "$1=(\"\${@:2}\")"; }
	L_array_append() { eval "$1+=(\"\${@:2}\")"; }
	L_array_prepend() { eval "$1=(\"\${@:2}\" \"\${$1[@]}\")"; }
	L_array_pop_front() { eval "$1=(\"\${$1[@]:1}\")"; }
	L_array_pop() { eval "unset \"$1[\${#$1[@]}-1]\""; }
fi  # L_HAS_NAMEREF

# @description check if array variable contains value
# @arg $1 array nameref
# @arg $2 needle
L_array_contains() {
	local _L_arr="$1[@]"
	L_args_contain "$2" ${!_L_arr:+"${!_L_arr}"}
}

# @description Remove elements from array for which expression evaluates to failure.
# @arg $1 array nameref
# @arg $2 expression to `eval`uate with array element of index L_i and value $1
L_array_filter_eval() {
	local L_i _L_array _L_expr _L_v
	_L_v="$1[@]"
	_L_array=(${!_L_v+"${!_L_v}"})
	_L_expr=${*:2}
	for ((L_i = ${#_L_array[@]} - 1; L_i >= 0; --L_i )); do
		set -- "${_L_array[L_i]}"
		if ! eval "$_L_expr"; then
			unset "_L_array[$L_i]"
		fi
	done
	eval "${_L_v%[*}=(\${_L_array[@]+\"\${_L_array[@]}\"})"
}

# @description Join array elements separated with the second argument.
# @option -v <var> Output variable
# @arg $1 <var> array nameref
# @arg $2 <str> string to join elements with
# @see L_args_join
L_array_join() { L_handle_v "$@"; }
L_array_join_v() {
	local _L_arr="$1[@]"
	L_args_join_v "$2" ${!_L_arr:+"${!_L_arr}"}
}

# @description Join arguments with separator
# @option -v <var> Output variable
# @arg $1 <str> separator
# @arg $@ arguments to join
L_args_join() { L_handle_v "$@"; }
L_args_join_v() {
	printf -v L_v "${1//%/%%}%s" "${@:2}"
	L_v=${L_v:${#1}}
}

# @description
# @option -v <var> Output variable
# @arg $1 <var> array nameref
# @see L_args_andjoin
L_array_andjoin() { L_handle_v "$@"; }
L_array_andjoin_v() {
	local _L_arr="$1[@]"
	L_args_andjoin_v ${!_L_arr+"${!_L_arr}"}
}

# @description Join arguments with ", " and last with " and "
# @option -v <var> Output variable
# @arg $@ arguments to join
L_args_andjoin() { L_handle_v "$@"; }
L_args_andjoin_v() {
	case "$#" in
	0) L_v="" ;;
	1) L_v=$1 ;;
	*)
		printf -v L_v ", %s" "${@:1:$#-1}"
		L_v="${L_v#, } and ${*:$#}"
		;;
	esac
}

# @description check if arguments starting from second contain the first argument
# @arg $1 needle
# @arg $@ heystack
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

# @description get index number of argument equal to the first argument
# @option -v <var>
# @arg $1 needle
# @arg $@ heystack
L_args_index() { L_handle_v "$@"; }
L_args_index_v() {
	local _L_needle=$1 _L_start=$#
	shift
	while (($#)); do
		if [[ "$1" == "$_L_needle" ]]; then
			L_v=$((_L_start-1-$#))
			return 0
		fi
		shift
	done
	return 1
}

# @description return max of arguments
# @option -v <var> var
# @arg $@ int arguments
# @example L_max -v max 1 2 3 4
L_max() { L_handle_v "$@"; }
# shellcheck disable=1105,2094,2035
# @set L_v
L_max_v() {
	L_v=$1
	shift
	while (($#)); do
		(("$1" > L_v ? L_v = "$1" : 0, 1))
		shift
	done
}

# @description return max of arguments
# @option -v <var> var
# @arg $@ int arguments
# @example L_min -v min 1 2 3 4
L_min() { L_handle_v "$@"; }
# shellcheck disable=1105,2094,2035
# @set L_v
L_min_v() {
	L_v=$1
	shift
	while (($#)); do
		(("$1" < L_v ? L_v = "$1" : 0, 1))
		shift
	done
}

# ]]]
# Utilities [[[
# @section Utilities
# @description Various self contained functions that could be separate programs.

# shellcheck disable=SC1105,SC2201,SC2102,SC2035,SC2211,SC2283,SC2094
# @description Make a table
# @option -v <var> variable to set
# @option -s <separator> IFS column separator to use
# @option -o <str> Output separator to use
# @option -R <list[int]> Right align columns with these indexes
# @arg $@ Lines to print, joined and separated by newline.
# @example
#     L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
#     name1 name2 name3
#         a     b c
#         d     e f
L_table() {
	local OPTARG OPTIND IFS=$'\n ' _L_i _L_s=$' \t' _L_v="" _L_arr=() _L_tmp="" _L_column=0 _L_columns=0 _L_rows=0 _L_row=0 _L_widths=() _L_o=" " _L_R="" _L_last
	while getopts v:s:o:R: _L_i; do
		case $_L_i in
		v) _L_v=$OPTARG; printf -v "$_L_v" "%s" "" ;;
		s) _L_s=$OPTARG ;;
		o) _L_o=$OPTARG ;;
		R) _L_R=$OPTARG ;;
		*) echo "${FUNCNAME[0]}: invalid flag: $OPTARG" >&2; return 2 ;;
		esac
	done
	shift $((OPTIND-1))
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

_L_test_table() {
	{
		local tmp out="\
name1 name2 name3
a     b     c
d     e     f"
		L_unittest_cmd -c -o "$out" -- L_table "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b c
    d     e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b
    d"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b" "d"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b" "d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1   name3
    a b
    d e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_table -v tmp -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
}

# @description Parse cut range list into an array.
# Each LIST is made up of one range, or many ranges separated by commas.
# Selected input is written in the same order that it is read, and is written exactly once.
# Each range is one of:
#     N      N'th byte, character or field, counted from 1
#     N-     from N'th byte, character or field, to end of line
#     N-M    from N'th to M'th (included) byte, character or field
#     -M     from first to M'th (included) byte, character or field
# @option -v <var> variable to set
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
L_parse_range_list() { L_handle_v "$@"; }
L_parse_range_list_v() {
	local _L_max=$1 _L_list _L_i _L_j _L_k _L_t
	shift
	L_assert 'not enough argumenst' test $# -gt 0
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

# @description extglob that matches declare -p output from array or associative array
if ((L_HAS_DECLARE_WITH_NO_QUOTES)); then
_L_DECLARE_P_ARRAY_EXTGLOB="declare -[aA]*([a-zA-Z]) [a-zA-Z_]*([a-zA-Z_0-9-])=(\[?*\]=*)"
_L_DECLARE_P_EMPTY_ARRAY_EXTGLOB="declare -[aA]*([a-zA-Z]) [a-zA-Z_]*([a-zA-Z_0-9-])=(*)"
else
_L_DECLARE_P_ARRAY_EXTGLOB="declare -[aA]*([a-zA-Z]) [a-zA-Z_]*([a-zA-Z_0-9-])='(\[?*\]=*)'"
_L_DECLARE_P_EMPTY_ARRAY_EXTGLOB="declare -[aA]*([a-zA-Z]) [a-zA-Z_]*([a-zA-Z_0-9-])='(*)'"
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
	local -A _L_pp_array="$2"
	if ((${#_L_pp_array[@]} == 0)); then
		_L_pretty_print_output "%s=()" "$1"
	else
		local _L_pp_key _L_pp_keys=("${!_L_pp_array[@]}") L_v
		# Associative array indexes are not sorted.
		LC_ALL=C L_sort_bash _L_pp_keys
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
# @option -v <var> Assign output to the variable.
# @option -w <int> Set terminal width. This modifies compact output line wrapping.
# @option -n Enable pretty printing nested arrays
# @option -C Disable compact output for arrays, i.e. each key is on separate line.
# @arg $@ variable names to pretty print
L_pretty_print() {
	local OPTARG OPTIND OPTERR _L_pp_opt _L_pp_declare _L_pp_prefix="" _L_pp_v="" _L_pp_width=${COLUMNS:-80} _L_pp_nested=0 _L_pp_line="" _L_pp_compact=0 _L_pp_prefix_sav=""
	while getopts :p:v:w:nc _L_pp_opt; do
		case $_L_pp_opt in
		p) _L_pp_prefix="$OPTARG " ;;
		v) _L_pp_v=$OPTARG; printf -v "$_L_pp_v" "%s" "" ;;
		w) _L_pp_width=$OPTARG ;;
		n) _L_pp_nested=1 ;;
		c) _L_pp_compact=1 ;;
		*) echo "${FUNCNAME[0]}: invalid option: $OPTARG" >&2; return 2; ;;
		esac
	done
	shift "$((OPTIND-1))"
	while (($#)); do
		if ! L_is_valid_variable_name "$1" || ! _L_pp_declare=$(declare -p "$1" 2>/dev/null); then
			_L_pretty_print_output "%s" "$1"
		elif ((${#_L_pp_declare} <= _L_pp_width)) || [[ "$_L_pp_declare" != "declare -"[aA]* ]]; then
			_L_pretty_print_output "%s" "$_L_pp_declare"
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
# @option -A <var> Instead of storing in variables, store values in specified associative array with varaibles as key.
# @option -M Use L_map instead of associative array, for @@kwargs and -A option. Usefull for older Bash.
# @option -E Exit on error
# @option -e <str> Prefix error messages with this prefix. Default: "${FUNCNAME[1]}:L_argskeywords:"
# @arg $@ Python arguments format specification
# @arg $2 <str> --
# @arg $@ Arguments to parse
# @example
#   range() {
#		local start stop step
#       L_argskeywords start stop step=1 -- "$@" || return 2
#       for ((; start < stop; start += stop)); do echo "$start"; done
#   }
#   range start=1 stop=6 step=2
#   range 1 6
#
#   max() {
#		local arg1 arg2 args key
#		L_argskeywords arg1 arg2 @args key='' -- "$@" || return 2
#		...
#	}
#	max 1 2 3 4
#
#	int() {
#		local string base
#		L_argskeywords string / base=10 -- "$@" || return 2
#		...
#	}
#	int 10 7 # error
#	int 10 base=7
L_argskeywords() {
	{
		# parse arguments
		local OPTARG OPTIND OPTERR _L_i _L_errorexit=0 _L_errorprefix="${FUNCNAME[1]}:${FUNCNAME[0]}:" _L_asa="" _L_use_map=0
		while getopts A:MEe: _L_i; do
			case $_L_i in
			A) _L_asa=$OPTARG ;;
			M) _L_use_map=1 ;;
			E) _L_errorexit=1 ;;
			e) _L_errorprefix=$OPTARG ;;
			*) _L_argskeywords_assert "Invalid option: -$_L_opt" false || return 2 ;;
			esac
		done
		shift $((OPTIND-1))
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
					L_map_init "$_L_excess_keyword"
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

_L_test_argskeywords() {
	{
		local a b
		L_unittest_cmd -r "missing 2 required positional arguments: a b" ! L_argskeywords a b --
		L_unittest_cmd -r "missing 1 required positional arguments: b" ! L_argskeywords a b -- 1
		L_unittest_cmd -c L_argskeywords a=1 b=2 --
		L_unittest_eq "$a $b" "1 2"
		L_unittest_cmd -c L_argskeywords a b=4 -- 3
		L_unittest_eq "$a $b" "3 4"
		L_unittest_cmd -r "missing 1 required positional arguments: a" ! L_argskeywords a b=2 --
		L_unittest_cmd -r "parameter without a default follows parameter with a default" ! L_argskeywords b=2 c --
		L_unittest_cmd -r "separator argument is missing" ! L_argskeywords a b
		L_unittest_cmd -r "parameter without a default follows parameter with a default" ! L_argskeywords a=1 b --
	}
	{
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either @ keyword_only -- either=Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either @ keyword_only -- Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		#
		L_unittest_cmd -c ! L_argskeywords either @ keyword_only -- Frank Dean
		L_unittest_cmd -c ! L_argskeywords either @ keyword_only -- Frank
	}
	{
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- either=Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- Frank
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "def2"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 --
		L_unittest_eq "$either" "def1"
		L_unittest_eq "$keyword_only" "def2"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- either=Frank
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "def2"
	}
	{
		local positional_only="" either=""
		L_unittest_cmd -c L_argskeywords positional_only / either -- Frank either=Dean
		L_unittest_eq "$positional_only" "Frank"
		L_unittest_eq "$either" "Dean"
		local positional_only="" either=""
		L_unittest_cmd -c L_argskeywords positional_only / either -- Frank Dean
		L_unittest_eq "$positional_only" "Frank"
		L_unittest_eq "$either" "Dean"
		#
		L_unittest_cmd -c ! L_argskeywords positional_only / either -- positional_only=Frank either=Dean
	}
	{
		local member1="" member2="" member3=""
		L_unittest_cmd -c L_argskeywords @ member1 member2 member3 -- member1=Frank member2=Dean member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		local member1="" member2="" member3=""
		L_unittest_cmd -c L_argskeywords @ member1 member2 member3 -- member1=Frank member3=Dean member2=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Sammy"
		L_unittest_eq "$member3" "Dean"
		#
		L_unittest_cmd -c ! L_argskeywords @ member1 member2 member3 -- Frank Dean Sammy
		L_unittest_cmd -c ! L_argskeywords @ member1 member2 member3 -- member1=Frank member2=Dean member3=Sammy member4=John
		L_unittest_cmd -c ! L_argskeywords @ member1 member2 member3 -- Frank member3=Dean member2=Sammy
	}
	{
		local member1="" member2="" member3=""
		L_unittest_cmd -c L_argskeywords member1 member2 member3 / -- Frank Dean Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		#
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- member1=Frank member2=Dean member3=Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- Frank Dean Sammy John
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- member1=Frank member2=Dean member3=Sammy member4=John
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- Frank member3=Dean member2=Sammy
	}
	{
		local member1="" member2="" member3="" args=()
		L_unittest_cmd -c L_argskeywords member1 member2 @args member3 -- Frank member2=Dean member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		L_unittest_arreq args
		local member1="" member2="" member3="" args=()
		L_unittest_cmd -c L_argskeywords member1 member2 @args member3 -- member1=Frank member2=Dean member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		L_unittest_arreq args
		#
		L_unittest_cmd -c ! L_argskeywords member1 member2 @args member3 -- member1=Frank Dean member3=Sammy
		#
		local member1="" member2="" member3="" args=()
		L_unittest_cmd -c L_argskeywords member1 member2 @args member3 -- Frank Dean Peter Joey member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		L_unittest_arreq args Peter Joey
	}
	L_unittest_cmd -c ! L_argskeywords @ --
	{
		local member1="" member2="" member3="" member4=""
		L_unittest_cmd -c L_argskeywords member1 member2 / member3 @ member4 -- Frank Dean member3=Sammy member4=Joey
		L_unittest_eq "$member1 $member2 $member3 $member4" "Frank Dean Sammy Joey"
		L_unittest_cmd -c ! L_argskeywords member1 member2 @ member3 / member4 -- Frank Dean member3=Sammy member4=Joey
	}
	{
		L_unittest_cmd -c ! L_argskeywords member1 member2 @ / member3 -- Frank Dean member3=Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 / @ member3 -- Frank Dean Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 / @ member3 -- Frank member2=Dean member3=Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 / @ member3 --
	}
	L_unittest_cmd -c ! L_argskeywords member1 member2 @args @ --
	L_unittest_cmd -c ! L_argskeywords member1 member2 @ @args --
	{
		local fn ln
		L_unittest_cmd -c L_argskeywords fn ln / -- Frank Sinatra
		L_unittest_eq "$fn $ln" "Frank Sinatra"
		L_unittest_cmd -c ! L_argskeywords fn ln / -- fn=Frank ln=Sinatra
	}
	{
		local args
		L_unittest_cmd -c L_argskeywords @args -- 1 2 3
		L_unittest_arreq args 1 2 3
		local integers
		L_unittest_cmd -c L_argskeywords @integers -- 1  2 3
		L_unittest_arreq integers 1 2 3
	}
	if ((L_HAS_ASSOCIATIVE_ARRAY)); then
		{
			local -A kwargs=()
			L_unittest_cmd -c L_argskeywords @@kwargs -- a=Real b=Python c=Is d=Great e="!"
			L_unittest_eq "${kwargs[a]}" "Real"
			L_unittest_eq "${kwargs[b]}" "Python"
			L_unittest_eq "${kwargs[c]}" "Is"
			L_unittest_eq "${kwargs[d]}" "Great"
			L_unittest_eq "${kwargs[e]}" "!"
		}
		{
			local a b args IFS=" "
			local -A kwargs=()
			L_unittest_cmd -c L_argskeywords a b @args @@kwargs -- 1 2 a b c c=3 d=4
			L_unittest_eq "$a $b" "1 2"
			L_unittest_arreq args a b c
			L_unittest_eq "${kwargs[c]}" "3"
			L_unittest_eq "${kwargs[d]}" "4"
			L_unittest_cmd -c ! L_argskeywords a b @@kwargs @args --
		}
	fi
	{
		local map tmp
		L_unittest_cmd -c L_argskeywords -M @@map -- a=Real b=Python c=Is d=Great e="!"
		L_map_get -v tmp map a
		L_unittest_eq "$tmp" "Real"
		L_map_get -v tmp map b
		L_unittest_eq "$tmp" "Python"
		L_map_get -v tmp map c
		L_unittest_eq "$tmp" "Is"
		L_map_get -v tmp map d
		L_unittest_eq "$tmp" "Great"
		L_map_get -v tmp map e
		L_unittest_eq "$tmp" "!"
	}
	{
		local a b args map tmp
		L_unittest_cmd -c L_argskeywords -M a b @args @@map -- 1 2 a b c c=3 d=4
		L_unittest_eq "$a $b" "1 2"
		L_unittest_arreq args a b c
		L_map_items -v tmp map
		L_unittest_arreq tmp c 3 d 4
		L_unittest_cmd -c ! L_argskeywords a b @@map @args --
	}
}

# shellcheckparser=off
# @description compare version numbers
# This function is used to detect bash features. It should handle any bash version.
# @see https://peps.python.org/pep-0440/
# @arg $1 str one version
# @arg $2 str one of: -lt -le -eq -ne -gt -ge '<' '<=' '==' '!=' '>' '>=' '~='
# @arg $3 str second version
# @arg [$4] int accuracy, how many at max elements to compare? By default up to 3.
L_version_cmp() {
	case "$2" in
	'~=')
		L_version_cmp "$1" '>=' "$3" && L_version_cmp "$1" "==" "${3%.*}.*"
		;;
	'=='|'-eq')
		[[ $1 == $3 ]]
		;;
	'!='|'-ne')
		[[ $1 != $3 ]]
		;;
	*)
		case "$2" in
		'-le') op='<=' ;;
		'-lt') op='<' ;;
		'-gt') op='>' ;;
		'-ge') op='>=' ;;
		'<='|'<'|'>'|'>=') op=$2 ;;
		*)
			L_error "L_version_cmp: invalid second argument: $op"
			return 2
		esac
		local res='=' i max a=() b=()
		IFS=' .-()' read -r -a a <<<$1
		IFS=' .-()' read -r -a b <<<$3
		for (( i = 0, max = ${#a[@]} > ${#b[@]} ? ${#a[@]} : ${#b[@]}, max > ${4:-3} ? max = ${4:-3} : 0; i < max; ++i )); do
			if ((a[i] > b[i])); then
				res='>'
				break
			elif ((a[i] < b[i])); then
				res='<'
				break
			fi
		done
		[[ $op == *"$res"* ]]
		;;
	esac
}

_L_test_version() {
	L_unittest_checkexit 0 L_version_cmp "0" -eq "0"
	L_unittest_checkexit 0 L_version_cmp "0" '==' "0"
	L_unittest_checkexit 1 L_version_cmp "0" '!=' "0"
	L_unittest_checkexit 0 L_version_cmp "0" '<' "1"
	L_unittest_checkexit 0 L_version_cmp "0" '<=' "1"
	L_unittest_checkexit 0 L_version_cmp "0.1" '<' "0.2"
	L_unittest_checkexit 0 L_version_cmp "2.3.1" '<' "10.1.2"
	L_unittest_checkexit 0 L_version_cmp "1.3.a4" '<' "10.1.2"
	L_unittest_checkexit 0 L_version_cmp "0.0.1" '<' "0.0.2"
	L_unittest_checkexit 0 L_version_cmp "0.1.0" -gt "0.0.2"
	L_unittest_checkexit 0 L_version_cmp "$BASH_VERSION" -gt "0.1.0"
	L_unittest_checkexit 0 L_version_cmp "1.0.3" "<" "1.0.7"
	L_unittest_checkexit 1 L_version_cmp "1.0.3" ">" "1.0.7"
	L_unittest_checkexit 0 L_version_cmp "2.0.1" ">=" "2"
	L_unittest_checkexit 0 L_version_cmp "2.1" ">=" "2"
	L_unittest_checkexit 0 L_version_cmp "2.0.0" ">=" "2"
	L_unittest_checkexit 0 L_version_cmp "1.4.5" "~=" "1.4.5"
	L_unittest_checkexit 0 L_version_cmp "1.4.6" "~=" "1.4.5"
	L_unittest_checkexit 1 L_version_cmp "1.5.0" "~=" "1.4.5"
	L_unittest_checkexit 1 L_version_cmp "1.3.0" "~=" "1.4.5"
}


# ]]]
# Log [[[
# @section log
# @description logging library
# This library is meant to be similar to python logging library.
# @example
#     L_log_set_level ERROR
#     L_error "this is an error"
#     L_info "this is information"
#     L_debug "This is debug"

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
L_LOGLEVEL_COLORS=(
	[L_LOGLEVEL_CRITICAL]="${L_STANDOUT}${L_BOLD}${L_RED}"
	[L_LOGLEVEL_ERROR]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_WARNING]="${L_BOLD}${L_YELLOW}"
	[L_LOGLEVEL_NOTICE]="${L_BOLD}${L_CYAN}"
	[L_LOGLEVEL_INFO]="$L_BOLD"
	[L_LOGLEVEL_DEBUG]=""
	[L_LOGLEVEL_TRACE]="$L_LIGHT_GRAY"
)

# @description was log system configured?
_L_logconf_configured=0
# @description int current global log level
_L_logconf_level=$L_LOGLEVEL_INFO
# @description should we use the color for logging output
L_logconf_color=1
# @description if this regex is set, allow elements
_L_logconf_selecteval=true
# @description default formatting function
_L_logconf_formateval='L_log_format_default "$@"'
# @description default outputting function
_L_logconf_outputeval='L_log_output_to_stderr "$@"'

# @description configure L_log system
# @option -r               Allow for reconfiguring L_log system. Otherwise second call of this function is ignored.
# @option -l <LOGLEVEL>    Set loglevel. Can be \$L_LOGLEVEL_INFO INFO or 30. Default: $_L_logconf_level
# @option -c <BOOL>        Enable/disable the use of color. Default: $L_logconf_color
# @option -f <FORMATEVAL>  Evaluate expression for formatting. Default: $_L_logconf_formateval
# @option -s <SELECTEVAL>  If eval "SELECTEVAL" exits with nonzero, do not print the line. Default: $_L_logconf_selecteval
# @option -o <OUTPUTEVAL>  Evaluate expression for outputting. Default: $_L_logconf_outputeval
# @noargs
# @example
# 	L_log_configure \
# 		-l debug \
# 		-c 0 \
# 		-f 'printf -v L_logrecord_msg "%s" "${@:2}"' \
# 		-o 'printf "%s\n" "$@" >&2' \
# 		-s 'L_log_select_source_regex ".*/script.sh"'
L_log_configure() {
	local OPTARG OPTIND OPTERR _L_opt
	while getopts rl:c:f:s:o: _L_opt; do
		if ((_L_logconf_configured)); then
			case $_L_opt in
				r) _L_logconf_configured=0 ;;
				[lcfso]) ;;
				*) L_fatal "invalid arguments: $_L_opt $OPTARG" ;;
			esac
		else
			case $_L_opt in
				r) _L_logconf_configured=0 ;;
				l) L_log_level_to_int _L_logconf_level "$OPTARG" ;;
				c) L_exit_to_1null L_logconf_color L_is_true "$OPTARG" ;;
				f) _L_logconf_formateval=$OPTARG ;;
				s) _L_logconf_selecteval=$OPTARG ;;
				o) _L_logconf_outputeval=$OPTARG ;;
				*) L_fatal "invalid arguments: opt=$_L_opt OPTARG=$OPTARG" ;;
			esac
		fi
	done
	shift $((OPTIND-1))
	L_assert "invalid arguments: $*" test $# -eq 0
	_L_logconf_configured=1
}

# @description int positive stack level to omit when printing caller information
# @example
# 	echo \
#      "${BASH_SOURCE[L_logrecord_stacklevel]}" \
#      "${FUNCNAME[L_logrecord_stacklevel]}" \
#      "${BASH_LINENO[L_logrecord_stacklevel]}"
L_logrecord_stacklevel=2
# @description int current log line log level
# @example
#     printf "%sHello%s\n" \
#       "${L_logconf_color:+${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}}" \
#       "${L_logconf_color:+$L_COLORRESET}"
L_logrecord_loglevel=0

# @description increase stacklevel of logging information
# @noargs
# @see L_fatal implementation
L_log_stack_inc() { ((++L_logrecord_stacklevel)); }
# @description decrease stacklevel of logging information
# @noargs
# @example
#   func() {
#       L_log_stack_inc
#       trap L_log_stack_dec RETURN
#       L_info hello world
#   }
L_log_stack_dec() { ((--L_logrecord_stacklevel)); }

# @description Convert log string to number
# @arg $1 str variable name
# @arg $2 int|str loglevel like `INFO` `info` or `30`
L_log_level_to_int() {
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

# @description Check if loggin is enabled for specified level
# @env _L_logconf_level
# @set L_logrecord_loglevel
# @arg $1 str|int loglevel or log string
L_log_is_enabled_for() {
	L_log_level_to_int L_logrecord_loglevel "$1"
	# echo "$L_logrecord_loglevel $L_log_level"
	((_L_logconf_level <= L_logrecord_loglevel))
}

# @description Finction that can be passed to filtereval to filter specific bash source name.
# @arg $1 Regex to match against BASH_SOURCE
# @see L_log_configure
L_log_select_source_regex() {
	[[ "${BASH_SOURCE[L_logrecord_stacklevel]}" =~ $* ]]
}

# @description Default logging formatting
# @arg $1 str log line printf format string
# @arg $@ any log line printf arguments
# @env L_logrecord_stacklevel
# @env L_logrecord_loglevel
# @set L_logrecord_msg
# @env L_LOGLEVEL_NAMES
# @env L_LOGLEVEL_COLORS
# @env BASH_LINENO
# @env FUNCNAME
# @env L_NAME
# @see L_log_configure
L_log_format_default() {
	printf -v L_logrecord_msg "%s""%s:%s:%d:$1""%s" \
		"${L_logconf_color:+${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}}" \
		"$L_NAME" \
		"${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-}" \
		"${BASH_LINENO[L_logrecord_stacklevel]}" \
		"${@:2}" \
		"${L_logconf_color:+$L_COLORRESET}"
}

# @description Format logrecord with timestamp information.
# @arg $1 str log line printf format string
# @arg $@ any log line printf arguments
# @env L_logrecord_stacklevel
# @env L_logrecord_loglevel
# @set L_logrecord_msg
# @env L_LOGLEVEL_NAMES
# @env L_LOGLEVEL_COLORS
# @env BASH_LINENO
# @env FUNCNAME
# @env L_NAME
# @see L_log_configure
L_log_format_long() {
	printf -v L_logrecord_msg "%s""%(%Y%m%dT%H%M%S)s: %s:%s:%d: %s $1""%s" \
		"${L_logconf_color:+${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}}" \
		-1 \
		"$L_NAME" \
		"${FUNCNAME[L_logrecord_stacklevel]}" \
		"${BASH_LINENO[L_logrecord_stacklevel]}" \
		"${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-}" \
		"${@:2}" \
		"${L_logconf_color:+$L_COLORRESET}"
}

# @description Output formatted line to stderr
# @arg $@ message to output
# @see L_log_configure
L_log_output_to_stderr() {
	printf "%s\n" "$@" >&2
}

# @description Output formatted line with logger
# @arg $@ message to output
# @env L_NAME
# @env L_logrecord_loglevel
# @env L_LOGLEVEL_NAMES
# @see L_log_configure
L_log_output_to_logger() {
	logger \
		--tag "$L_NAME" \
		--priority "local3.${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-notice}" \
		--skip-empty \
		-- "$@"
}

# @description Handle log message to output
# @arg $@ Log message
# @env L_logrecord_loglevel
# @env L_logrecord_stacklevel
# @warning Users could overwrite this function.
L_log_handle() {
	if L_log_is_enabled_for "$L_logrecord_loglevel" && eval "$_L_logconf_selecteval"; then
		local L_logrecord_msg=
		# Should set L_logrecord_msg from "$@"
		eval "$_L_logconf_formateval"
		set -- "$L_logrecord_msg"
		# Should output "$@"
		eval "$_L_logconf_outputeval"
	fi
}

# shellcheck disable=SC2140
# @description main logging entrypoint
# @option -s <int> Increment stacklevel by this much
# @option -l <int|string> loglevel to print log line as
# @arg $1 str log line printf format string
# @arg $@ any log line printf arguments
# @set L_logrecord_loglevel
# @set L_logrecord_stacklevel
L_log() {
	local OPTARG OPTIND _L_opt
	L_logrecord_loglevel=$L_LOGLEVEL_INFO
	while getopts :s:l: _L_opt; do
		case "$_L_opt" in
		s) ((L_logrecord_stacklevel += OPTARG, 1)) ;;
		l) L_log_level_to_int L_logrecord_loglevel "$OPTARG" ;;
		*) break ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_log_handle "$@"
	L_logrecord_stacklevel=2
}

# @description output a critical message
# @option -s <int> stacklevel increase
# @arg $1 message
L_critical() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_CRITICAL" "$@"
}

# @description output a error message
# @option -s <int> stacklevel increase
# @arg $1 message
L_error() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_ERROR" "$@"
}

# @description output a warning message
# @option -s <int> stacklevel increase
# @arg $1 message
L_warning() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_WARNING" "$@"
}

# @description output a notice
# @option -s <int> stacklevel increase
# @arg $1 message
L_notice() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_NOTICE" "$@"
}

# @description output a information message
# @option -s <int> stacklevel increase
# @arg $1 message
L_info() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_INFO" "$@"
}

# @description output a debugging message
# @option -s <int> stacklevel increase
# @arg $1 message
L_debug() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_DEBUG" "$@"
}

# @description output a tracing message
# @option -s <int> stacklevel increase
# @arg $1 message
L_trace() {
	L_log_stack_inc
	L_log -l "$L_LOGLEVEL_TRACE" "$@"
}

# @description Output a critical message and exit the script with 2.
# @arg $@ L_critical arguments
L_fatal() {
	L_log_stack_inc
	L_critical "$@"
	exit 2
}

# @description log a command and then execute it
# Is not affected by L_dryrun variable.
# @arg $@ command to execute
L_logrun() {
	L_log "+ $*"
	"$@"
}

# @description set to 1 if L_run should not execute the function.
: "${L_dryrun:=0}"

# @description
# Logs the quoted argument with a leading +.
# if L_dryrun is nonzero, executes the arguments.
# @option -l <loglevel> Set loglevel
# @option -s <stacklevel> Increment stacklevel by this number
# @arg $@ command to execute
# @env L_dryrun
L_run() {
	local OPTARG OPTIND _L_opt _L_logargs=()
	while getopts l:s: _L_opt; do
		case $_L_opt in
			l) _L_logargs+=(-l "$OPTARG") ;;
			s) _L_logargs+=(-s "$OPTARG") ;;
			*) break ;;
		esac
	done
	shift "$((OPTIND-1))"
	printf -v _L_opt " %q" "$@"
	if ((L_dryrun)); then
		_L_logargs+=("DRYRUN: +$_L_opt")
	else
		_L_logargs+=("+$_L_opt")
	fi
	L_log_stack_inc
	L_log "${_L_logargs[@]}"
	if ((!L_dryrun)); then
		"$@"
	fi
}

_L_test_log() {
	{
		local i
		L_log_level_to_int i INFO
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
		L_log_level_to_int i L_LOGLEVEL_INFO
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
		L_log_level_to_int i info
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
		L_log_level_to_int i "$L_LOGLEVEL_INFO"
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
	}
}

# ]]]
# Sort [[[
# @section Sort
# @description sorting function

if ((L_HAS_BASH4_2)); then
# shellcheckparser=off
# @see L_sort_bash
# @description quicksort an array in numeric order
_L_sort_bash_in_numeric() {
	local _L_start=$1 _L_end=$2 _L_left _L_right _L_pivot _L_tmp
	if (( _L_start < _L_end ? (_L_left=_L_start+1, _L_right=_L_end, _L_pivot=_L_array[_L_start], 1) : 0)); then
		while (( _L_left < _L_right )); do
			((
				(
					$_L_sort_reverse( _L_pivot > _L_array[_L_left] ) ?
						++_L_left :
					$_L_sort_reverse( _L_pivot < _L_array[_L_right] ) ?
						--_L_right : (
							_L_tmp=_L_array[_L_left],
							_L_array[_L_left]=_L_array[_L_right],
							_L_array[_L_right]=_L_tmp
						)
				), 1
			))
		done
		((
			$_L_sort_reverse( _L_array[_L_left] < _L_pivot ) ? (
				(_L_tmp = _L_array[_L_left]),
				(_L_array[_L_left] = _L_array[_L_start]),
				(_L_array[_L_start] = _L_tmp),
				(_L_left--)
			) : (
				(--_L_left),
				(_L_tmp=_L_array[_L_left]),
				(_L_array[_L_left]=_L_array[_L_start]),
				(_L_array[_L_start]=_L_tmp),
				1
			)
		))
		_L_sort_bash_in_numeric "$_L_start" "$_L_left"
		_L_sort_bash_in_numeric "$_L_right" "$_L_end"
	fi
}
else
# shellcheckparser=off
# There is some bug in bash before 4.2 that makes the expression (( ?: with ternary take __both__ branches.
# Fix that.
_L_sort_bash_in_numeric() {
	local _L_start=$1 _L_end=$2 _L_left _L_right _L_pivot _L_tmp
	if (( _L_start < _L_end ? (_L_left=_L_start+1, _L_right=_L_end, _L_pivot=_L_array[_L_start], 1) : 0)); then
		while (( _L_left < _L_right )); do
			((
				(
					$_L_sort_reverse( _L_pivot > _L_array[_L_left] ) ?
						++_L_left :
					$_L_sort_reverse( _L_array[_L_right] > _L_pivot ) ?
						--_L_right : (
							_L_tmp=_L_array[_L_left],
							_L_array[_L_left]=_L_array[_L_right],
							_L_array[_L_right]=_L_tmp
						)
				), 1
			))
		done
		if (( $_L_sort_reverse( _L_pivot > _L_array[_L_left] ) )); then
			((
				(_L_tmp = _L_array[_L_left]),
				(_L_array[_L_left] = _L_array[_L_start]),
				(_L_array[_L_start] = _L_tmp),
				(_L_left--)
			))
		else
			((
				(--_L_left),
				(_L_tmp=_L_array[_L_left]),
				(_L_array[_L_left]=_L_array[_L_start]),
				(_L_array[_L_start]=_L_tmp),
				1
			))
		fi
		_L_sort_bash_in_numeric "$_L_start" "$_L_left"
		_L_sort_bash_in_numeric "$_L_right" "$_L_end"
	fi
}
fi

# shellcheck disable=SC2030,SC2031,SC2035
# @see L_sort_bash
_L_sort_bash_in_nonnumeric() {
	local _L_start _L_end _L_left _L_right _L_pivot _L_tmp
	if ((
			_L_start=$1, _L_end=$2,
			_L_start < _L_end ? _L_left=_L_start+1, _L_right=_L_end, 1 : 0
	)); then
		_L_pivot=${_L_array[_L_start]}
		while (( _L_left < _L_right )); do
			if $_L_sort_reverse "$_L_sort_compare" "$_L_pivot" "${_L_array[_L_left]}"; then
				(( ++_L_left, 1 ))
			elif $_L_sort_reverse "$_L_sort_compare" "${_L_array[_L_right]}" "$_L_pivot"; then
				(( --_L_right, 1 ))
			else
				_L_tmp=${_L_array[_L_left]}
				_L_array[_L_left]=${_L_array[_L_right]}
				_L_array[_L_right]=$_L_tmp
			fi
		done
		if $_L_sort_reverse "$_L_sort_compare" "$_L_pivot" "${_L_array[_L_left]}"; then
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
		_L_sort_bash_in_nonnumeric "$_L_start" "$_L_left"
		_L_sort_bash_in_nonnumeric "$_L_right" "$_L_end"
	fi
}

# @description default nonnumeric compare function
_L_sort_compare() { [[ "$1" > "$2" ]]; }

# @description quicksort an array in place in pure bash
# Is faster then sort and redirection.
# @see L_sort
# @option -z ignored. Always zero sorting
# @option -n optimized sort for numeric array values, otherwise lexical
# @option -r reverse sort
# @option -a the argument is not an array, but the arguments themselves will be sorted and printed to stdout or assigned to variable
# @option -c <compare> custom compare function that returns 0 when $1 > $2 and 1 otherwise
# @option -v <var> store sorted array in var instead of modyfing the original array
# @arg $1 array nameref or arguments to sort depending on `-a` flag
L_sort_bash() {
	local _L_sort_numeric=0 OPTARG OPTIND _L_c _L_array _L_sort_compare=_L_sort_compare _L_sort_reverse=0 _L_sort_v='' _L_sort_arguments=0 _L_sort_zero=0
	while getopts znrac:v: _L_c; do
		case $_L_c in
			z) _L_sort_zero=1 ;;
			n) _L_sort_numeric=1 ;;
			r) _L_sort_reverse=1 ;;
			a) _L_sort_arguments=1 ;;
			c) _L_sort_numeric=0 _L_sort_compare=$OPTARG ;;
			v)
				_L_sort_v=$OPTARG
				L_assert "invalid argument: $_L_sort_v" L_is_valid_variable_name "$_L_sort_v"
				;;
			*) L_fatal "invalid argument" ;;
		esac
	done
	shift $((OPTIND-1))
	if ((_L_sort_arguments)); then
		_L_array=("$@")
	else
		L_assert "wrong number of arguments" test "$#" = 1
		_L_array="${_L_sort_v:=$1}[@]"
		_L_array=(${!_L_array+"${!_L_array}"})
	fi
	#
	# Initialize _L_sort_reverse
	if ((_L_sort_reverse)); then
		if ((_L_sort_numeric)); then
			_L_sort_reverse="!"
		else
			_L_sort_reverse="L_not"
		fi
	else
		_L_sort_reverse=""
	fi
	#
	if ((_L_sort_numeric)); then
		_L_sort_bash_in_numeric 0 $((${#_L_array[@]} - 1))
	else
		_L_sort_bash_in_nonnumeric 0 $((${#_L_array[@]} - 1))
	fi
	#
	if [[ -z "$_L_sort_v" ]]; then
		if ((_L_sort_zero)); then
			printf "%s\0" "${_L_array[@]}"
		else
			printf "%s\n" "${_L_array[@]}"
		fi
	else
		eval "$_L_sort_v=(\"\${_L_array[@]}\")"
	fi
}

# @description like L_sort but without mapfile.
# @see L_sort
_L_sort_cmd_no_mapfile() {
	local _L_array="${*: -1}[@]"
	IFS=$'\n' read -d '' -r -a "${*: -1}" < <(
		printf "%s\n" "${!_L_array}" | sort "${@:1:$#-1}"
		printf "\0"
	)
}

_L_sort_cmd_no_mapfile_d() {
	local _L_array="${*: -1}[@]" _L_i=0
	while IFS= read -d '' -r "${*: -1}[$((_L_i++))]"; do
		:
	done < <(
		printf "%s\0" "${!_L_array}" | sort "${@:1:$#-1}"
	)
	unset "${*: -1}[$((_L_i-1))]"
}

# @description sort an array using sort command
# @option -z --zero-terminated use zero separated stream with sort -z
# @arg $* any options are forwarded to sort command
# @arg $-1 last argument is the array nameref
# @example
#    arr=(5 2 5 1)
#    L_sort -n arr
#    echo "${arr[@]}"  # 1 2 5 5
L_sort_cmd() {
	local _L_array="${*: -1}[@]"
	if L_args_contain -z "${@:1:$#-1}" || L_args_contain --zero-terminated "${@:1:$#-1}"; then
		if ((L_HAS_MAPFILE_D)); then
			mapfile -d '' -t "${@: -1}" < <(printf "%s\0" "${!_L_array}" | sort "${@:1:$#-1}")
		else
			_L_sort_cmd_no_mapfile_d "$@"
		fi
	else
		if ((L_HAS_MAPFILE)); then
			mapfile -t "${@: -1}" < <(printf "%s\n" "${!_L_array}" | sort "${@:1:$#-1}")
		else
			_L_sort_cmd_no_mapfile "$@"
		fi
	fi
}

# @description sort an array
# @see L_sort_bash
L_sort() {
	L_sort_bash "$@"
}

# shellcheck disable=SC2086
_L_test_sort() {
	export LC_ALL=C IFS=' '
	timeit() {
		# shellcheck disable=SC2155
		local TIMEFORMAT="TIME: $(printf "%-40s" "$*")   real=%lR user=%lU sys=%lS"
		echo "+ $*" >&2
		time "$@"
	}
	{
		var=(1 2 3)
		L_sort_bash -n var
		L_unittest_eq "${var[*]}" "1 2 3"
	}
	{
		for opt in "-n" "" "-z" "-n -z"; do
			for data in "1 2 3" "3 2 1" "1 3 2" "2 3 1" "6 5 4 3 2 1" "6 1 5 2 4 3" "-1 -2 4 6 -4"; do
				local -a sort_bash="($data)" sort="($data)"
				timeit L_sort_cmd $opt sort
				timeit L_sort_bash $opt sort_bash
				L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			done
		done
		for opt in "" "-z"; do
			for data in "a b" "b a" "a b c" "c b a" "a c b" "b c a" "f d s a we r t gf d fg vc s"; do
				local -a sort_bash="($data)" sort="($data)"
				timeit L_sort_cmd $opt sort
				timeit L_sort_bash $opt sort_bash
				L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			done
		done
	}
	{
		L_log "test bash sorting of an array"
		local arr=(9 4 1 3 4 5)
		L_sort_bash -n arr
		L_unittest_eq "${arr[*]}" "1 3 4 4 5 9"
		local arr=(g s b a c o)
		L_sort_bash arr
		L_unittest_eq "${arr[*]}" "a b c g o s"
	}
	{
		L_log "test sorting of an array"
		local arr=(9 4 1 3 4 5)
		L_sort_cmd -n arr
		L_unittest_eq "${arr[*]}" "1 3 4 4 5 9"
		local arr=(g s b a c o)
		L_sort_cmd arr
		L_unittest_eq "${arr[*]}" "a b c g o s"
	}
	{
		L_log "test sorting of an array with zero separated stream"
		local arr=(9 4 1 3 4 5)
		L_sort_cmd -z -n arr
		L_unittest_eq "${arr[*]}" "1 3 4 4 5 9"
		local arr=(g s b a c o)
		L_sort_cmd -z arr
		L_unittest_eq "${arr[*]}" "a b c g o s"
	}
	{
		local -a nums=(
			10 99 7 33 97 68 100 83 80 51 74 24 85 71 64 36 72 67 60 73 54 5 63
			50 40 27 30 44 1 37 86 14 52 15 81 78 46 90 39 79 65 47 28 77 62 22
			98 76 41 49 89 48 32 21 92 70 11 96 58 55 56 45 17 66 57 42 31 23 26
			35 3 6 13 25 8 82 84 61 75 12 2 9 53 94 69 93 38 87 59 16 20 95 43 34
			91 88 4 18 19 29 -52444  46793   63644   23950   -24008  -8219 -34362
			59930 -13817 -30880 59270 43982 -1901 53069 -24481 -21592 811 -4132
			65052 -5629 19149 17827 17051 -22462 8842 53592 -49750 -18064 -8324
			-23371 42055 -24291 -54302 3207 4580 -10132 -33922 -14613 41633 36787
		)
		for opt in "" "-n" "-z" "-n -z"; do
			local sort_bash=("${nums[@]}") sort=("${nums[@]}")
			timeit L_sort_bash $opt sort_bash
			timeit L_sort_cmd $opt sort
			L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
		done
	}
	{
		local -a words=(
			"curl moor" "knowing glossy" $'lick\npen' "hammer languid"
			pigs available gainful black-and-white grateful
			fetch screw sail marked seed delicious tenuous bow
			plants loaf handsome page ice misty innate slip
		)
		local sort_bash=("${words[@]}") sort=("${words[@]}")
		timeit L_sort_bash -z sort_bash
		timeit L_sort_cmd -z sort
		L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
	}
	{
		L_unittest_cmd -o $'1\n2\n3\n4\n5' L_sort_bash -a -n 3 2 1 4 5
		L_sort_bash -a -n -v var 3 2 1 4 5
		L_unittest_arreq var 1 2 3 4 5
		L_sort_bash -a -r -n -v var 3 2 1 4 5
		L_unittest_arreq var 5 4 3 2 1
		L_sort_bash -a -v var c b a e d
		L_unittest_arreq var a b c d e
		L_sort_bash -a -r -v var c b a e d
		L_unittest_arreq var e d c b a
	}
}

# ]]]
# trap [[[
# @section trap

# @description Prints traceback
# @arg [$1] int stack offset to start from (default: 0)
# @arg [$2] int number of lines to show around the line (default: 0)
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
	local i s l tmp offset=${1:-0} around=${2:-0}
	L_color_detect
	echo "${L_CYAN}Traceback from pid ${BASHPID:-$$} (most recent call last):${L_RESET}"
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
					for ((j= 0 ; j < cnt; ++j)); do
						cur=
						if ((min+j+1==l)); then
							cur=yes
						fi
						printf "%s%-5d%s%3s%s%s\n" \
							"$L_BLUE$L_BOLD" \
							"$((min+j))" \
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
					-v RESET="$L_RESET" \
					-v RED="$L_RED" \
					-v COLORLINE="${L_BLUE}${L_BOLD}" \
					'NR > line - around && NR < line + around {
						printf "%s%-5d%s%3s%s%s%s\n", \
							COLORLINE, NR, RESET, \
							(NR == line ? ">> " RED : ""), \
							$0, \
							(NR == line ? RESET : "")
					}' "$s" 2>/dev/null
			fi
		fi
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
# @example
#  L_trap_err_enable
L_trap_err_enable() {
	set -eEo functrace
	trap 'L_trap_err $?' ERR
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
	if [[ $- == *e* ]] && [[ -z "$(trap -p ERR)" ]]; then
		L_trap_err_enable
	fi
}

# @description Create a return trap that restores all shopt options.
# @example
#   func() {
#      eval "$L_TRAP_RETURN_RESTORE_SHOPT"
#      shopt -s extglob
#      # stuff with extglob
#   }
L_TRAP_RETURN_RESTORE_SHOPT='trap "$(shopt -p)" RETURN'
if ((L_HAS_LOCAL_DASH)); then
	# @description Create a return trap that restores all set options.
	# @see L_TRAP_RETURN_RESTORE_SHOPT
	L_TRAP_RETURN_RESTORE_SET='local -'
	# @description Create a return trap that restores all set and all shopt options.
	# @see L_TRAP_RETURN_RESTORE_SHOPT
	# @see L_TRAP_RETURN_RESTORE_set
	L_TRAP_RETURN_RESTORE_SET_AND_SHOPT='local -; trap "$(shopt -p)" RETURN'
else
	L_TRAP_RETURN_RESTORE_SET='trap "$(set +o)" RETURN'
	L_TRAP_RETURN_RESTORE_SET_AND_SHOPT='trap "$(set +o); $(shopt -p)" RETURN'
fi

# @description String of trap number and name separated by spaces
# extracted from trap -l output.
# @see _L_TRAP_L_init
_L_TRAP_L=

# shellcheck disable=SC2329
# @description initialize _L_TRAP_L variable
# @set _L_TRAP_L
_L_TRAP_L_init() {
	# Convert the output of trap -l into list of trap names.
	_L_TRAP_L=$(trap -l)
	_L_TRAP_L=${_L_TRAP_L//)}
	# _L_TRAP_L=${_L_TRAP_L// }
	_L_TRAP_L=" 0 EXIT ${_L_TRAP_L//[$'\t\n']/ } "
	_L_TRAP_L_init() { :; }
}

# @description Convert trap name to number
# @option -v <var> var
# @arg $1 trap name or trap number
L_trap_to_number() { L_handle_v "$@"; }
L_trap_to_number_v() {
	case "$1" in
	[0-9]*) L_v=$1 ;;
	*)
		_L_TRAP_L_init
		L_v=${_L_TRAP_L%%" $1 "*}
		L_v=${L_v##* }
		;;
	esac
}


# @description convert trap number to trap name
# @option -v <var> var
# @arg $1 signal name or signal number
# @example L_trap_to_name -v var 0 && L_assert '' test "$var" = EXIT
L_trap_to_name() { L_handle_v "$@"; }
L_trap_to_name_v() {
	case "$1" in
	[0-9]*)
		_L_TRAP_L_init
		L_v=${_L_TRAP_L##*" $1 "}
		L_v=${L_v%% *}
		;;
	*) L_v="$1" ;;
	esac
}

# @description Get the current value of trap
# @option -v <var> var
# @arg $1 <str|int> signal name or number
# @example
#   trap 'echo hi' EXIT
#   L_trap_get -v var EXIT
#   L_assert '' test "$var" = 'echo hi'
L_trap_get() { L_handle_v "$@"; }
L_trap_get_v() {
	L_v=$(trap -p "$1") &&
		local -a _L_tmp="($L_v)" &&
		L_v=${_L_tmp[2]:-}
}

# @description Suffix a newline and the command to the trap value
# @arg $1 str command to execute
# @arg $2 str signal to handle
L_trap_push() {
	local L_v &&
	L_trap_get_v "$2" &&
		trap "$L_v"$'\n'"$1" "$2"
}

# shellcheck disable=SC2064
# @description remove a command from trap up until the last newline
# @arg $1 str signal to handle
L_trap_pop() {
	local L_v &&
	L_trap_get_v "$1" &&
		if [[ "$L_v" == *$'\n'* ]]; then
			trap "${L_v%$'\n'*}" "$1"
		else
			trap - "$1"
		fi
}

# shellcheck disable=SC2064,SC2016
_L_test_trapchain() {
	{
		L_log "test converting int to signal name"
		local tmp
		L_trap_to_name -v tmp EXIT
		L_unittest_eq "$tmp" EXIT
		L_trap_to_name -v tmp 0
		L_unittest_eq "$tmp" EXIT
		L_trap_to_name -v tmp 1
		L_unittest_eq "$tmp" SIGHUP
		L_trap_to_name -v tmp DEBUG
		L_unittest_eq "$tmp" DEBUG
		L_trap_to_name -v tmp SIGRTMIN+5
		L_unittest_eq "$tmp" SIGRTMIN+5
		L_trap_to_number -v tmp SIGRTMAX-5
		L_unittest_eq "$tmp" 59
	}
	{
		L_log "test L_trapchain"
		local tmp
		local allchars
		tmp=$(
			L_trap_push 'echo -n hello' EXIT
			L_trap_push 'echo -n " "' EXIT
			L_trap_push 'echo -n world' EXIT
			L_trap_push 'echo -n "!"' EXIT
		)
		L_unittest_eq "$tmp" "hello world!"
	}
	if ((L_HAS_BASHPID)); then
		tmp=$(
			L_trap_push 'echo -n "4"' SIGUSR1
			L_trap_push 'echo -n " 3"' SIGUSR1
			L_trap_push 'echo -n " 2"' SIGUSR2
			L_trap_push 'echo -n " 1"' EXIT
			L_raise SIGUSR1
			L_raise SIGUSR2
		)
		L_unittest_eq "$tmp" "4 3 2 1"
	fi
}

# ]]]
# Unittest [[[
# @section Unittest
# @description testing library
# @example
#    L_unittest_eq 1 1

# @description accumulator for unittests failures
: "${L_unittest_fails:=0}"
# @description set to 1 to exit immediately when a test fails
: "${L_unittest_exit_on_error:=0}"
# @description set to 1 to disable set -x inside L_unittest functions, set to 0 to dont
: "${L_unittest_unset_x:=$L_HAS_LOCAL_DASH}"

# @description internal unittest function
# @env L_unittest_fails
# @set L_unittest_fails
# @arg $1 message to print what is testing
# @arg $2 message to print on failure
# @arg $@ command to execute, can start with '!' to invert exit status
_L_unittest_internal() {
	local _L_tmp=0 _L_invert=0 IFS=' '
	if [[ "$3" == "!" ]]; then
		_L_invert=1
		shift
	fi
	"${@:3}" || _L_tmp=$?
	((_L_invert ? (_L_tmp = !_L_tmp) : 1, 1))
	: "${L_unittest_fails:=0}"
	if ((_L_tmp)); then
		echo -n "${L_RED}${L_BRIGHT}"
	fi
	echo -n "${FUNCNAME[2]}:${BASH_LINENO[1]}: test: ${1:-}: "
	if ((_L_tmp == 0)); then
		echo "${L_GREEN}OK${L_COLORRESET}"
	else
		((++L_unittest_fails))
		_L_tmp=("${@:3}")
		echo "expression ${_L_tmp[*]} FAILED!${2:+ }${2:-}${L_COLORRESET}"
		if ((L_unittest_exit_on_error)); then
			exit 17
		else
			return 17
		fi
	fi
} >&2

# @description execute all functions starting with prefix
# @option -h help
# @option -P <prefix> Get functions with this prefix to test
# @option -r <regex> filter tests with regex
# @option -E exit on error
L_unittest_main() {
	set -euo pipefail
	local OPTIND OPTARG _L_opt _L_tests=()
	while getopts hr:EP: _L_opt; do
		case $_L_opt in
		h)
			cat <<EOF
Options:
  -h         Print this help and exit
  -P PREFIX  Execute all function with this prefix
  -r REGEX   Filter tests with regex
  -E         Exit on error
EOF
			exit
			;;
		P)
			L_log "Getting function with prefix %q" "${OPTARG}"
			L_list_functions_with_prefix -v _L_tests "$OPTARG"
			;;
		r)
			L_log "filtering tests with %q" "${OPTARG}"
			L_array_filter_eval _L_tests '[[ $1 =~ $OPTARG ]]'
			;;
		E)
			L_unittest_exit_on_error=1
			;;
		*) L_fatal "invalid argument: $_L_opt" ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_assert 'too many arguments' test "$#" = 0
	L_assert 'no tests matched' test "${#_L_tests[@]}" '!=' 0
	local _L_test
	for _L_test in "${_L_tests[@]}"; do
		L_log "executing $_L_test"
		"$_L_test"
	done
	L_log "done testing: ${_L_tests[*]}"
	if ((L_unittest_fails)); then
		L_error "${L_RED}testing failed"
	else
		L_log "${L_GREEN}testing success"
	fi
	if ((L_unittest_fails)); then
		exit "$L_unittest_fails"
	fi
}

# @description Test is eval of a string return success.
# @arg $1 string to eval-ulate
# @arg $@ error message
L_unittest_eval() {
	_L_unittest_internal "test eval ${1}" "${*:2}" eval "$1" || :
}

# shellcheck disable=SC2035
# @description Check if command exits with specified exitcode
# @arg $1 exit code
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
	printf "${L_RED}${L_BOLD}unittested command running in current shell %q exited with $1. It should not exit${L_COLORRESET}\n" "$BASH_COMMAND" >&2
	exit 1
}

_L_unittest_cmd_coproc() {
	mapfile -t -d '' _L_very_unique_name
	printf "%s" "${_L_very_unique_name[@]}"
}

# @description Test execution of a command and its output.
# Local variables start with _L_u*. Options with _L_uopt_*.
# @option -c Run in current execution environment shell using coproc, instead of subshell
# @option -i Invert exit status. You can also use `!` in front of the command.
# @option -I Redirect stdout and stderr of the command to /dev/null
# @option -j Redirect stderr to stdout of the command.
# @option -x Run the command inside set -x
# @option -X Do not modify set -x
# @option -v <str> Capture stdout and stderr into this variable.
# @option -r <regex> Compare output with this regex
# @option -o <str> Compare output with this string
# @option -e <int> Command should exit with this exit status (default: 0)
# @arg $@ command to execute. Can start with `!`.
L_unittest_cmd() {
	if ((L_unittest_unset_x)) && [[ $- = *x* ]]; then
		local -
		set +x
		local _L_uopt_setx=1
	else
		local _L_uopt_setx=0
	fi
	local OPTARG OPTIND _L_uc _L_uopt_invert=0 _L_uopt_capture=0 _L_uopt_regex='' _L_uopt_output='' _L_uopt_exitcode=0 _L_uopt_invert=0 _L_uret=0 _L_uout _L_uopt_curenv=0 _L_utrap=0 _L_uopt_v='' _L_uopt_stdjoin=0
	while getopts ciIjxXv:r:o:e: _L_uc; do
		case $_L_uc in
		c) _L_uopt_curenv=1 ;;
		i) _L_uopt_invert=1 ;;
		I) _L_uopt_capture=1 ;;
		j) _L_uopt_capture=1 _L_uopt_stdjoin=1 ;;
		x) _L_uopt_setx=1 ;;
		X) _L_uopt_setx=0 ;;
		v) _L_uopt_capture=1 _L_uopt_v=$OPTARG ;;
		r) _L_uopt_capture=1 _L_uopt_regex=$OPTARG ;;
		o) _L_uopt_capture=1 _L_uopt_output=$OPTARG ;;
		e) _L_uopt_exitcode=$OPTARG ;;
		*) L_fatal "invalid argument: $_L_uc ${OPTARG:-} ${OPTIND:-}" ;;
		esac
	done
	shift $((OPTIND-1))
	if [[ "$1" == "!" ]]; then
		shift
		_L_uopt_invert=1
		if ((_L_uopt_capture)); then
			_L_uopt_stdjoin=1
		fi
	fi
	_L_unittest_internal "command found: [$(L_quote_printf "$@")]" "" L_hash "$1"
	if ((_L_uopt_setx)); then
		set -- L_setx "$@"
	fi
	#
	if ((_L_uopt_curenv)); then
		L_trap_push '_L_unittest_cmd_exit_trap $?' EXIT
		# shellcheck disable=2030,2093,1083
		if ((_L_uopt_capture)); then
			if ((0)); then
				# Use coproc
				coproc _L_unittest_cmd_coproc
				if ((_L_uopt_stdjoin)); then
					"$@" >&"${COPROC[1]}" 2>&1 || _L_uret=$?
				else
					"$@" >&"${COPROC[1]}" || _L_uret=$?
				fi
				exec {COPROC[1]}>&-
				_L_out=$(cat <&"${COPROC[0]}")
				exec {COPROC[0]}>&-
				wait "$COPROC_PID"
			else
				# Use temporary file
				local _L_utmpf
				_L_utmpf=$(mktemp)
				# shellcheck disable=SC2094
				{
					{
						rm "$_L_utmpf"
						if ((_L_uopt_stdjoin)); then
							"$@" 2>&1 || _L_uret=$?
						else
							"$@" || _L_uret=$?
						fi
					} >"$_L_utmpf" 111<&-
					_L_uout=$(cat <&111)
				} 111<"$_L_utmpf"
			fi
		else
			"$@" || _L_uret=$?
		fi
		L_trap_pop EXIT
	else
		if ((_L_uopt_capture)); then
			if ((_L_uopt_stdjoin)); then
				_L_uout=$(trap - ERR; "$@" 2>&1) || _L_uret=$?
			else
				_L_uout=$(trap - ERR; "$@") || _L_uret=$?
			fi
		else
			( trap - ERR; "$@" ) || _L_uret=$?
		fi
	fi
	#
	# shellcheck disable=2035
	# Invert exit code if !
	if ((_L_uopt_invert ? _L_uret = !_L_uret, 1 : 0)); then
		# For nice output
		set -- "!" "$@"
	fi
	_L_unittest_internal "[$(L_quote_printf "$@")] exited with $_L_uret =? $_L_uopt_exitcode" "${_L_uout+output $(printf %q "$_L_uout")}" [ "$_L_uret" -eq "$_L_uopt_exitcode" ]
	if [[ -n $_L_uopt_regex ]]; then
		if ! _L_unittest_internal "[$(L_quote_printf "$@")] output $(printf %q "$_L_uout") matches $(printf %q "$_L_uopt_regex")" "" L_regex_match "$_L_uout" "$_L_uopt_regex"; then
			_L_unittest_showdiff "$_L_uout" "$_L_uopt_regex"
			return 1
		fi
	fi
	if [[ -n $_L_uopt_output ]]; then
		if ! _L_unittest_internal "[$(L_quote_printf "$@")] output $(printf %q "$_L_uout") equal $(printf %q "$_L_uopt_output")" "" [ "$_L_uout" = "$_L_uopt_output" ]; then
			_L_unittest_showdiff "$_L_uout" "$_L_uopt_output"
			return 1
		fi
	fi
	if [[ -n "$_L_uopt_v" ]]; then
		eval "$_L_uopt_v=\$_L_uout"
	fi
} <&-

# @description Check if the content of files is equal
# @arg $1 first file
# @arg $2 second file
# @example L_unittest_cmpfiles <(testfunc $1) <(echo shluldbethis)
L_unittest_cmpfiles() {
	local op='='
	if [[ "$1" = "!" ]]; then
		op='!='
		shift
	fi
	local a b
	a=$(<"$1")
	b=$(<"$2")
	if ! _L_unittest_internal "test pipes${3:+ $3}" "${4:-}" [ "$a" "$op" "$b" ]; then
		_L_unittest_showdiff "$a" "$b"
		return 1
	fi
}

_L_unittest_showdiff() {
	L_assert "" test $# = 2
	if L_hash diff; then
		if [[ "$1" =~ ^[[:print:][:space:]]*$ && "$2" =~ ^[[:print:][:space:]]*$ ]]; then
			diff <(cat <<<"$1") - <<<"$2" | cat -vet
		else
			diff <(xxd -p <<<"$1") <(xxd -p <<<"$2")
		fi
	else
		printf -- "--- diff ---\nL: %q\nR: %q\n\n" "$1" "$2"
	fi
}

# @description test if varaible has value
# @arg $1 variable nameref
# @arg $2 value
L_unittest_vareq() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test $# = 2
	if ! _L_unittest_internal "\$$1=${!1:+$(printf %q "${!1}")} == $(printf %q "$2")" "" [ "${!1:-}" == "$2" ]; then
		_L_unittest_showdiff "${!1:-}" "$2"
		return 1
	fi
}

# @description test if two strings are equal
# @arg $1 one string
# @arg $2 second string
L_unittest_eq() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "${FUNCNAME[0]} received invalid number of arguments" test $# = 2
	if ! _L_unittest_internal "$(printf "%q == %q" "$1" "$2")" "" [ "$1" == "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if array is equal to elements
# @arg $1 array variable
# @arg $@ values
L_unittest_arreq() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test $# -ge 1
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
			_L_unittest_showdiff "$1" "$2"
			return 1
		fi
		((++_L_i))
		shift
	done
}

# @description test two strings are not equal
# @arg $1 one string
# @arg $2 second string
L_unittest_ne() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test $# = 2
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
	L_assert "" test $# = 2
	if ! _L_unittest_internal "$(printf %q "$1") =~ $(printf %q "$2")" "" L_regex_match "$1" "$2"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if a string contains other string
# @arg $1 string
# @arg $2 needle
L_unittest_contains() {
	if ((L_unittest_unset_x)); then local -; set +x; fi
	L_assert "" test $# = 2
	if ! _L_unittest_internal "$(printf %q "$1") == *$(printf %q "$2")*" "" L_strstr "$1" "$2"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# ]]]
# Map [[[
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
# @example
#    local var
#    L_map_init var
L_map_init() {
	printf -v "$1" "%s" ""
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
#     L_map_init var
#     L_map_set var a 1
#     L_map_remove var a
#     if L_map_has var a; then
#       echo "a is set"
#     else
#       echo "a is not set"
#     fi
L_map_remove() {
	if L_map_has "$@"; then
		local _L_map _L_key
		_L_map=${!1}$'\n'
		printf -v _L_key "%q" "$2"
		printf -v "$1" "\n%s%s" "${_L_map#*$'\n'"$_L_key"$'\t'*$'\n'}" "${_L_map%%$'\n'"$_L_key"$'\t'*}"
	fi
}

# @description Set a key in a map to value
# @arg $1 var map
# @arg $2 str key
# @arg $3 str value
# @example
#   L_map_init var
#   L_map_set var a 1
#   L_map_set var b 2
L_map_set() {
	L_map_remove "$1" "$2"
	# This code depends on that `printf %q` _never_ prints a newline, instead it does $'\n'.
	# I add key-value pairs in chunks with preeceeding newline.
	printf -v "$1" "%s\n%q\t%q" "${!1}" "$2" "${*:3}"
}

# @description Assigns the value of key in map.
# If the key is not set, then assigns default if given and returns with 1.
# You want to prefer this version of L_map_get
# @option -v <var> var
# @arg $1 var map
# @arg $2 str key
# @arg [$3] str default
# @example
#    L_map_init var
#    L_map_set var a 1
#    L_map_get -v tmp var a
#    echo "$tmp"  # outputs: 1
L_map_get() { L_handle_v "$@"; }
L_map_get_v() {
	local _L_map _L_key _L_map2
	_L_map=${!1}
	printf -v _L_key "%q" "$2"
	# Remove anything in front of the newline followed by key followed by space.
	# Because the key can't have newline not space, it's fine.
	_L_map=${_L_map##*$'\n'"$_L_key"$'\t'}
	# If nothing was removed, then the key does not exists.
	if [[ "$_L_map" == "${!1}" ]]; then
		if (($# >= 3)); then
			L_v="${*:3}"
			return 0
		else
			return 1
		fi
	fi
	# Remove from the newline until the end and print with eval.
	# The key was inserted with printf %q, so it has to go through eval now.
	_L_map=${_L_map%%$'\n'*}
	eval "L_v=$_L_map"
}

# @description
# @arg $1 var map
# @arg $2 str key
# @exitcode 0 if map contains key, nonzero otherwise
# @example
#     L_map_init var
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
# @option -v <var> variable to set
# @arg $1 var map
# @example
#   L_map_init var
#   L_map_set var a 1
#   L_map_set var b 2
#   L_map_keys -v tmp var
#   echo "${tmp[@]}"  # outputs: 'a b'
L_map_keys() { L_handle_v "$@"; }
L_map_keys_v() {
	local _L_map
	_L_map=${!1}
	_L_map=${_L_map//$'\t'/ # }$'\n'
	local -a _L_tmp="($_L_map)"
	L_v=("${_L_tmp[@]}")
}

# @description List all values in the map.
# @option -v <var> variable to set
# @arg $1 var map
# @example
#    L_map_init var
#    L_map_set var a 1
#    L_map_set var b 2
#    L_map_values -v tmp var
#    echo "${tmp[@]}"  # outputs: '1 2'
L_map_values() { L_handle_v "$@"; }
L_map_values_v() {
	local _L_map
	_L_map=${!1}
	_L_map=${_L_map//$'\n'/ # }
	_L_map=${_L_map//$'\t'/$'\n'}
	local -a _L_tmp="($_L_map)"
	L_v=("${_L_tmp[@]}")
}

# @description List items on newline separated key value pairs.
# @option -v <var> variable to set
# @arg $1 var map
# @example
#   L_map_init var
#   L_map_set var a 1
#   L_map_set var b 2
#   L_map_items -v tmp var
#   echo "${tmp[@]}"  # outputs: 'a 1 b 2'
L_map_items() { L_handle_v "$@"; }
L_map_items_v() {
	local -a _L_tmp="(${!1})"
	L_v=("${_L_tmp[@]}")
}

# @description Load all keys to variables with the name of $prefix$key.
# @arg $1 map variable
# @arg $2 prefix
# @arg $@ Optional list of keys to load. If not set, all are loaded.
# @example
#     L_map_init var
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
#    L_map_init var
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

# shellcheck disable=2018
_L_test_map() {
	local IFS=" "
	{
		local map map2 tmp
		{
			L_map_init map
			L_map_set map a 1
			L_map_has map a
			L_map_set map b 2
			L_map_has map b
			L_map_set map c 3
			L_map_has map c
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 1
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 2
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 3
			L_map_items -v tmp map
			L_unittest_eq "${tmp[*]}" "a 1 b 2 c 3"
			L_map_keys -v tmp map
			L_unittest_eq "${tmp[*]}" "a b c"
			L_map_values -v tmp map
			L_unittest_eq "${tmp[*]}" "1 2 3"
		}
		{
			L_map_set map a 4
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 2
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 3
		}
		{
			L_map_set map b 5
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 3
		}
		{
			L_map_set map c 6
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 6
		}
		{
			map2="$map"
			L_map_remove map a
			L_unittest_failure L_map_get map a
			L_unittest_failure L_map_has map a
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 6
			map="$map2"
		}
		{
			map2="$map"
			L_map_remove map b
			L_unittest_failure L_map_get map b
			L_unittest_failure L_map_has map b
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 6
			map="$map2"
		}
		{
			map2="$map"
			L_map_remove map c
			L_unittest_failure L_map_get map c
			L_unittest_failure L_map_has map c
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			map="$map2"
		}
	}
	{
		if ((L_HAS_BASH4)); then local IFS=bc; fi
		local map tmp
		L_map_init map
		L_map_set map "/bin/ba*" "/dev/*"
		L_map_set map "b " "2 "
		L_map_set map " c" " 3"
		L_map_get -v tmp map "/bin/ba*"
		L_unittest_eq "$tmp" "/dev/*"
		L_map_get -v tmp map "b "
		L_unittest_eq "$tmp" "2 "
		L_map_get -v tmp map " c"
		L_unittest_eq "$tmp" " 3"
		tmp=()
		L_map_keys -v tmp map
		L_unittest_arreq tmp "/bin/ba*" "b " " c"
		L_map_items -v tmp map
		L_unittest_arreq tmp "/bin/ba*" "/dev/*" "b " "2 " " c" " 3"
		L_map_values -v tmp map
		L_unittest_arreq tmp "/dev/*" "2 " " 3"
	}
	{
		local map tmp
		L_unittest_success L_map_init map
		L_unittest_success L_map_set map '${var:?error}$(echo hello)' '${var:?error}$(echo hello)value'
		L_unittest_success L_map_has map '${var:?error}$(echo hello)'
		L_unittest_success L_map_get -v tmp map '${var:?error}$(echo hello)'
		L_unittest_eq "$tmp" '${var:?error}$(echo hello)value'
		L_unittest_success L_map_items -v tmp map
		L_unittest_arreq tmp '${var:?error}$(echo hello)' '${var:?error}$(echo hello)value'
	}
	{
		local PREFIX_a PREFIX_b var tmp
		L_map_init var
		PREFIX_a=1
		PREFIX_b=2
		L_map_save var PREFIX_
		L_map_items -v tmp var
		L_unittest_arreq tmp a 1 b 2
	}
	{
		local var tmp
		var=123
		tmp=123
		L_map_init var
		L_map_set var a 1
		# L_unittest_cmpfiles <(L_map_get var a) <(echo -n 1)
		L_unittest_eq "$(L_map_get var b "")" ""
		L_map_set var b 2
		L_unittest_eq "$(L_map_get var a)" "1"
		L_unittest_eq "$(L_map_get var b)" "2"
		L_map_set var a 3
		L_unittest_eq "$(L_map_get var a)" "3"
		L_unittest_eq "$(L_map_get var b)" "2"
		L_unittest_checkexit 1 L_map_get var c
		L_unittest_checkexit 1 L_map_has var c
		L_unittest_checkexit 0 L_map_has var a
		L_map_set var allchars "$L_ALLCHARS"
		L_unittest_eq "$(L_map_get var allchars)" "$(printf %s "$L_ALLCHARS")"
		L_map_remove var allchars
		L_unittest_checkexit 1 L_map_get var allchars
		L_map_set var allchars "$L_ALLCHARS"
		local s_a s_b s_allchars
		L_unittest_eq "$(L_map_keys var | sort)" "$(printf "%s\n" b a allchars | sort)"
		L_map_load var s_
		L_unittest_eq "$s_a" 3
		L_unittest_eq "$s_b" 2
		L_unittest_eq "$s_allchars" "$L_ALLCHARS"
		#
		local tmp=()
		L_map_keys -v tmp var
		L_unittest_arreq tmp b a allchars
		local tmp=()
		L_map_values -v tmp var
		L_unittest_eq "${#tmp[@]}" 3
		L_unittest_eq "${tmp[0]}" 2
		L_unittest_eq "${tmp[1]}" 3
		if (( BASH_VERSINFO[0] >= 4 )); then
			# There is a bug that declare prints erroneous 0x01 in bash 3.2
			L_unittest_eq "${tmp[2]}" "$L_ALLCHARS"
			local tmp=() IFS=' '
			L_map_items -vtmp var
			L_unittest_eq "${tmp[*]}" "b 2 a 3 allchars $L_ALLCHARS"
		fi
	}
}

# ]]]
if ((L_HAS_ASSOCIATIVE_ARRAY)); then
# asa - Associative Array [[[
# @section asa
# @description collection of function to work on associative array

# @description Copy associative dictionary.
# Notice: the destination array is _not_ cleared.
# Slowish, O(N). Iterates of keys one by one
# @see L_asa_copy
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
# @option -v <var> var
# @arg $1 associative array nameref
# @arg $2 key
# @arg [$3] optional default value
# @exitcode 1 if no key found and no default value
L_asa_get() { L_handle_v "$@"; }
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
# @option -v <var> var
# @arg $1 associative array nameref
L_asa_len() { L_handle_v "$@"; }
L_asa_len_v() {
	L_assert "" L_var_is_associative "$1"
	eval "L_v=(\"\${#$1[@]}\")"
}

# @description get keys of an associative array in a sorted
# @option -v <var> var
# @arg $1 associative array nameref
L_asa_keys_sorted() { L_handle_v "$@"; }
L_asa_keys_sorted_v() {
	L_assert "" test "$#" = 1
	L_assert "" L_var_is_associative "$1"
	eval "L_v=(\"\${!$1[@]}\")"
	L_sort L_v
}

# @description Move the 3rd argument to the first and call
# The `L_asa $1 $2 $3 $4 $5` becomes `L_asa_$3 $1 $2 $4 $5`
# @option -v <var> var
# @arg $1 function name
# @arg $2 associative array nameref
# @arg $@ arguments
# @example L_asa -v v get map a
L_asa() {
	case $1 in
	-v?*) "L_asa_$2" "$1" "${@:3}" ;;
	-v) "L_asa_$3" "${@:1:2}" "${@:4}" ;;
	*) "L_asa_$1" "${@:2}" ;;
	esac
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
	printf -v "${1}[$2]" "%s" "$3"
}

# @description Serialize an associative array to string.
# @arg $1 var destination variable nameref
# @arg $2 =
# @arg $3 var associative array nameref to serialize
# @see L_asa_load
# @see L_asa_assign
# @example
#    declare -A map=([a]=b [c]=d)
#    L_asa_dump string = map
#    declare -A mapcopy=()
#    L_asa_load mapcopy = string
L_asa_dump() {
	printf -v "$1" "%s" "$(declare -p "$3")"
	L_assert "not an associative array: $3" L_glob_match "${!1}" "declare -A*"
}
else
	L_asa_set() {
		L_assert "not a valid variable name: $1" L_is_valid_variable_name "$1"
		eval "${1}[\$2]=\"\$3\""
	}
	L_asa_dump() {
		L_assert "not a valid variable name: $1" L_is_valid_variable_or_array_element "$1"
		eval "$1=\$(declare -p \"\$3\")"
		L_assert "not an associative array: $3" L_glob_match "${!1}" "declare -A*"
	}
fi

if ((L_HAS_DECLARE_WITH_NO_QUOTES)); then
# @description Extract associative array from string
# @arg $1 var associative array nameref to store
# @arg $2 =
# @arg $3 var source variable nameref
# @see L_asa_dump
# @see L_asa_copy
# @example
#    declare -A map=([a]=b [c]=d)
#    declare string=""
#    L_asa_dump string = map
#    declare -A mapcopy=()
#    L_asa_load mapcopy = string
L_asa_load() {
	L_assert "not an associative array: $1" L_var_is_associative "$1"
	# L_assert '' L_regex_match "${!3}" "^[^=]*=[(].*[)]$"
	L_assert "source nameref does not match $_L_DECLARE_P_EMPTY_ARRAY_EXTGLOB: $3=${!3:-}" \
		L_glob_match "${!3:-}" "$_L_DECLARE_P_EMPTY_ARRAY_EXTGLOB"
	# This has to be eval - it expands to `var=([a]=b [c]=d)`
	eval "$1=${!3#*=}"
	# Is 1000 times faster, then the below, because L_asa_copy is slow.
	# if [[ $3 != _L_asa ]]; then declare -n _L_asa="$3"; fi
	# if [[ $1 != _L_asa_to ]]; then declare -n _L_asa_to="$1"; fi
	# declare -A _L_tmpa="$_L_asa"
	# _L_asa_to=()
	# L_asa_copy _L_tmpa "$1"
}
else
	L_asa_load() {
		L_assert "not an associative array: $1" L_var_is_associative "$1"
		L_assert "source nameref does not match \"declare -A* [a-zA-Z_]*='(*)'\": $3=${!3:-}" \
			L_glob_match "${!3:-}" "declare -A* [a-zA-Z_]*='(*)'"
		# Godspeed.
		# First expansion un-quotes the output of declare -A.
		# Second assigns the associative array.
		eval "eval \$1=${!3#*=}"
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
# @see L_asa_load
# @example
#   local -A map=([a]=b [c]=d)
#   local -A mapcopy=()
#   L_asa_assign mapcopy = map
L_asa_assign() {
	local _L_tmp
	L_asa_dump _L_tmp = "$3"
	L_asa_load "$1" = _L_tmp
}

_L_test_asa() {
	declare -A map=()
	local v
	{
		L_info "_L_test_asa: check has"
		map[a]=1
		L_asa_has map a
		L_asa_has map b && exit 1
	}
	{
		L_info "_L_test_asa: check getting"
		L_asa -v v get map a
		L_unittest_eq "$v" 1
		v=
		L_asa -v v get map a 2
		L_unittest_eq "$v" 1
		v=
		L_asa -v v get map b 2
		L_unittest_eq "$v" 2
	}
	{
		L_info "_L_test_asa: check length"
		L_unittest_eq "$(L_asa_len map)" 1
		L_asa_len -v v map
		L_unittest_eq "$v" 1
		map[c]=2
		L_asa -v v len map
		L_unittest_eq "$v" 2
	}
	{
		L_info "_L_test_asa: copy"
		local -A map=([a]=1 [c]=$'\'"@ ') map2=()
		L_asa_assign map2 = map
		L_unittest_eq "${map[a]}" 1
		L_unittest_eq "${map[c]}" $'\'"@ '
		L_unittest_eq "${map2[a]}" 1
		L_unittest_eq "${map2[c]}" $'\'"@ '
	}
	{
		L_info "_L_test_asa: nested asa"
		local -A map2=([c]=d [e]=f)
		L_asa_dump "map[mapkey]" = map2
		L_asa_has map mapkey
		L_asa_get map mapkey
		local -A map3=()
		L_asa_load map3 = "map[mapkey]"
		L_asa_get -v v map3 c
		L_unittest_eq "$v" d
		L_asa_get -v v map3 e
		L_unittest_eq "$v" f
	}
	{
		L_asa_keys_sorted -v v map2
		L_unittest_eq "${v[*]}" "c e"
		L_unittest_eq "$(L_asa_keys_sorted map2)" "c"$'\n'"e"
	}
	{
		L_info "_L_test_asa: nested asa with quotes"
		local -A map3 map2=([a]="='='=")
		L_asa_dump "map[mapkey]" = map2
		L_asa_load map3 = "map[mapkey]"
		L_unittest_eq "${map2[a]}" "${map3[a]}"
	}
}

# ]]]
# argparse [[[
# @section argparse
# @description argument parsing in bash
# @env _L_parser The arguments passed to ArgumentParser() constructor
# @env _L_parser The current parser

# @description Print argument parsing error and exit.
# @env L_NAME
# @env _L_parser
# @exitcode 1
L_argparse_fatal() {
	if ((${_L_in_complete:-0})); then
		return
	fi
	L_argparse_print_usage >&2
	printf "%s: error: $1\n" "${_L_parser["prog"]:-${L_NAME:-$0}}" "${@:2}" >&2
	if L_is_true "${_L_parser["exit_on_error"]:-true}"; then
		exit 1
	else
		return "${2:-1}"
	fi
}

# @description given two lists indent them properly
# This is used internally by L_argparse_print_help to
# align help message of options and arguments for ouptut.
# @arg $1 <var> output destination variable nameref
# @arg $2 <str> header of the help section
# @arg $3 <var> array of metavars of options
# @arg $4 <var> array of help messages of options
_L_argparse_print_help_indenter() {
	local _L_left="$3[@]" _L_right="$4[@]" _L_i _L_len max_header_length=0 _L_line _L_tmp help_position a b c COLUMNS=${COLUMNS:-80} free_space diff
	_L_left=(${!_L_left+"${!_L_left}"})
	if ((${#_L_left[@]} == 0)); then return; fi
	_L_right=(${!_L_right+"${!_L_right}"})
	#
	L_printf_append "$1" "\n%s\n" "$2"
	for _L_i in "${_L_left[@]}"; do
		# shellcheck disable=SC2094,SC2035,SC2094
		(( max_header_length < ${#_L_i} ? max_header_length = ${#_L_i} : 1 ))
	done
	# <header>  <help>
	#           | - help_position
	# shellcheck disable=SC2094,SC2035,SC2283,SC2210,SC2094
	((
		COLUMNS -= 2,
		help_position = COLUMNS - 20,
		help_position < 24 ? help_position = 24 : 1,
		help_position > max_header_length + 4 ? help_position = max_header_length + 4 : 1,
		help_width = COLUMNS - help_position - 2,
		help_width < 11 ? help_width = 11 : 1
	))
	for _L_i in "${!_L_left[@]}"; do
		local header="  ${_L_left[_L_i]}"
		local opthelp=${_L_right[_L_i]%$'\n'}
		if ((${#opthelp} == 0)); then
			# no help
			L_printf_append "$1" "%s\n" "$header"
		else
			if ((diff = help_position - ${#header}, diff > 0 )); then
				# short header - start help on the same line with padding
				L_printf_append "$1" "%s" "$header"
				cur_indent=$diff
			else
				# longer header - start help on the next line
				L_printf_append "$1" "%s\n" "$header"
				cur_indent=$help_position
			fi
			if [[ "${opthelp//$'\n'}" != "$opthelp" ]]; then
				# If help message contains multiple lines.
				if L_hash fmt; then
					# Replace whitespaces by a single space.
					# shellcheck disable=SC2064
					trap "$(shopt -p extglob)" RETURN
					shopt -s extglob
					opthelp="${opthelp//+([$' \t\n'])/ }"
					# Use fmt for formatting if available.
					# shellcheck disable=SC2154
					opthelp=$(fmt -w "$help_width" <<<"$opthelp")
				fi
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

# @description Get help text.
# @arg $1 <var> variable to assign
# @env _L_parser
# @env _L_optspec
_L_argparse_optspec_get_help() {
	local L_v=${_L_optspec[help]:-}
	if [[ "$L_v" == "SUPPRESS" ]]; then
		return 1
	fi
	# L_v=${L_v//%(prog)s/$_L_prog}
	# L_v=${L_v//%(default)s/${_L_optspec[default]:-}}
	if L_is_true "${_L_optspec[show_default]:-${_L_parser[show_default]:-0}}" && L_var_is_set "_L_optspec[default]"; then
		printf -v "$1" "%s(default: %q)" "$L_v${L_v:+ }" "${_L_optspec[default]}"
	else
		printf -v "$1" "%s" "$L_v"
	fi
}

# @description Get metavar value or default.
# It is here as a function, for optimization.
# @arg $1 <var> variable to assign
# @env _L_parser
# @env _L_optspec
_L_argparse_optspec_get_metavar() {
	local L_v=${_L_optspec[metavar]:-}
	if [[ -z "$L_v" ]]; then
		local -a _L_choices="(${_L_optspec[choices]:-})"
		if ((${#_L_choices[@]})); then
			# infer metavar from choices
			local IFS=","
			L_v="{${_L_choices[*]}}"
		else
			L_v=${_L_optspec[dest]}
		fi
		if [[ -n "${_L_optspec[_options]:-}" ]]; then
			L_strupper_v "$L_v"
		fi
	fi
	printf -v "$1" "%s" "$L_v"
}

# @description Get description for error message for a particular _L_optspec
# @arg $1 <var> variable to assign
# @env _L_parser
# @env _L_optspec
_L_argparse_optspec_get_description() {
	local -a _L_options="(${_L_optspec[_options]:-})"
	if ((${#_L_options[@]})); then
		local IFS='/'
		printf -v "$1" "%s" "${_L_options[*]}"
	else
		_L_argparse_optspec_get_metavar "$1"
	fi
}

# @description Get the usage string in help usage message for a particular _L_optspec
# @arg $1 <var> variable to append
# @env _L_optspec
_L_argparse_optspec_get_usage() {
	local _L_nargs=${_L_optspec[nargs]} _L_metavar _L_ret
	_L_argparse_optspec_get_metavar _L_metavar
	case "$_L_nargs" in
	"?") _L_ret="[$_L_metavar]" ;;
	"*") _L_ret="[$_L_metavar ...]" ;;
	"+") _L_ret="$_L_metavar [${_L_metavar[1]:-$_L_metavar} ...]" ;;
	remainder) _L_ret="$_L_metavar ..." ;;
	0) _L_ret="" ;;
	[0-9]*)
		_L_ret="$_L_metavar"
		while ((--_L_nargs)); do
			_L_ret+=" ${_L_metavar[1]:-$_L_metavar}"
		done
		;;
	*) L_fatal "invalid nargs $(declare -p _L_optspec)" ;;
	esac
	L_printf_append "$1" "%s" "${_L_ret:+ }$_L_ret"
}

# shellcheck disable=2120
# @description Print help or only usage for given parser or global parser.
# @option -s --short print only usage, not full help
# @arg [$1] _L_parser
# @env _L_parser
L_argparse_print_help() {
	{
		# parse arguments
		local _L_short=0
		case "${1:-}" in
		-s | --short) _L_short=1; shift
		esac
		if [[ "$#" -gt 0 && "${1:-}" != "_L_parser" ]]; then local -n _L_parser="$1"; shift; fi
		L_assert "" test "$#" == 0
	}
	{
		# Find program name, also from chained subparsers.
		local _L_subparserstr _L_prog
		if ((${#_L_parserchain[@]} == 0)); then
			_L_prog=${_L_parser[prog]:-$0}
		else
			for _L_subparserstr in ${_L_parserchain[@]:+"${_L_parserchain[@]}"}; do
				local -A _L_subparser=()
				L_asa_load _L_subparser = _L_subparserstr
				if ! L_var_is_set _L_prog; then
					_L_prog=${_L_subparser[prog]:-$0}
				else
					_L_prog+=" "${_L_subparser[name]}
				fi
			done
			_L_prog+=" "${_L_parser[name]}
		fi
	}
	{
		# stores all the stuff after usage
		local _L_help_help="${_L_parser[description]+$'\n'${_L_parser[description]%%$'\n'}$'\n'}"
		local _L_opthelp _L_notrequired _L_metavar
	}
	{
		# Parse positional arguments
		local _L_args_usage=""
		local _L_usage_args_descs=()  # descriptions of positional arguments
		local _L_usage_args_helps=()  # help messages of positional arguments
		local _L_usage_cmds_descs=()  # descriptions of subparsers
		local _L_usage_cmds_helps=()  # help messages of subparsers
		local -A _L_optspec=()
		while _L_argparse_parser_next_argument _L_optspec; do
			if _L_argparse_optspec_get_help _L_opthelp; then
				_L_argparse_optspec_get_metavar _L_metavar
				if [[ "${_L_optspec[action]}" == _subparser ]]; then
					local _L_nargs=${_L_optspec[nargs]} _L_add
					case "$_L_nargs" in
					"+") _L_add+=" COMMAND [ARGS ...]" ;;
					"*") _L_add+=" [COMMAND [ARGS ...]]" ;;
					"?") _L_add+=" [COMMAND]" ;;
					[0-9]*) _L_add+=" COMMAND"; while ((--_L_nargs)); do _L_add+=" ARGS"; done ;;
					*) L_fatal "invalid nargs $(declare -p _L_optspec)" ;;
					esac
					_L_args_usage+="$_L_add"
					local _L_key
					for _L_key in "${!_L_parser[@]}"; do
						if [[ "$_L_key" == _subparser_* ]]; then
							local -A _L_subparser=()
							L_asa_load _L_subparser = "_L_parser[$_L_key]"
							_L_usage_cmds_descs+=("${_L_key#_subparser_}")
							_L_usage_cmds_helps+=("${_L_subparser[description]:-}")
						fi
					done
				else
					# argument
					local _L_metavar
					_L_argparse_optspec_get_metavar _L_metavar
					_L_argparse_optspec_get_usage _L_args_usage
					_L_usage_args_descs+=("$_L_metavar")
					_L_usage_args_helps+=("$_L_opthelp")
				fi
			fi
		done
		_L_argparse_print_help_indenter _L_help_help "Arguments:" _L_usage_args_descs _L_usage_args_helps
		_L_argparse_print_help_indenter _L_help_help "Available Commands:" _L_usage_cmds_descs _L_usage_cmds_helps
	}
	{
		# Parse options
		local _L_options_usage=""
		local _L_options_descs=()  # descriptions of options
		local _L_options_helps=()  # help messages of options
		local -A _L_optspec=()
		while _L_argparse_parser_next_option _L_optspec; do
			if _L_argparse_optspec_get_help _L_opthelp; then
				_L_argparse_optspec_get_metavar _L_metavar
				L_exit_to_1null _L_notrequired L_not L_is_true "${_L_optspec[required]:-0}"
				local -a _L_options="(${_L_optspec[_options]})"
				L_args_join -v _L_desc ", " "${_L_options[@]}"
				local _L_add=""
				_L_argparse_optspec_get_usage _L_add
				_L_options_usage+=" ${_L_notrequired:+[}${_L_options[0]}${_L_add}${_L_notrequired:+]}"
				_L_options_descs+=("$_L_desc$_L_add")
				_L_options_helps+=("$_L_opthelp")
			fi
		done
		_L_argparse_print_help_indenter _L_help_help "Options:" _L_options_descs _L_options_helps
	}
	{
		# output
		echo "Usage: ${_L_parser[usage]:-$_L_prog$_L_options_usage$_L_args_usage}"
		if ((!_L_short)); then
			_L_help_help+=${_L_parser[epilog]:+$'\n'${_L_parser[epilog]%%$'\n'}}
			echo "${_L_help_help%%$'\n'}"
		fi
	}
}

# shellcheck disable=2120
# @description Print usage.
L_argparse_print_usage() {
	L_argparse_print_help --short "$@"
}

_L_argparse_split_fatal() {
	cat <<EOF
L_argparse: When parsing arguments the following error occured: $1
L_argparse: The parsing state, usefull for debugging:
$(L_pretty_print _L_optspec _L_split_long_options _L_split_short_options _L_split_args class)
$(L_print_traceback)
L_argparse: The most probable cause is L_argparse arguments are invalid.
EOF
	exit 123
}

# @description assert there are no long and shost options
# This is used in class_* callbacks.
# @env _L_split_long_options
# @env _L_split_short_options
_L_argparse_split_check_nooptions() {
	local IFS=" "
	${_L_split_long_options[@]:+_L_argparse_split_fatal "long options not allowed"}
	${_L_split_short_options[@]:+_L_argparse_split_fatal "short options not allowed"}
}

# @description Check if keys in _L_optspec are in the list of allowed keywords.
# This is used in class_* callbacks.
# @env _L_optspec
# @arg $@ Allowed keywords.
_L_argparse_split_check_allowed() {
	local _L_opt IFS=' '
	for _L_opt in "${!_L_optspec[@]}"; do
		if [[ " $* " != *" $_L_opt "* ]]; then
			_L_argparse_split_fatal "invalid keyword option: $_L_opt. Allowed keywords: $*"
		fi
	done
	${_L_optspec[class]:+unset} ${_L_optspec[class]:+"_L_optspec[class]"}
}

# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @env _L_optspec
# @set _L_parser
_L_argparse_split_class_parsersetings() {
	_L_argparse_split_check_nooptions
	_L_argparse_split_check_allowed prog usage description epilog add_help allow_abbrev Adest show_default name aliases
	{
		case "${#_L_split_args[@]}" in
		0) ;;
		1)
			if L_var_is_set "_L_optspec[name]"; then
				_L_argparse_split_fatal "name supplied twice for parser settings: ${_L_split_args[0]}"
			fi
			_L_optspec[name]=${_L_split_args[0]}
			;;
		*) _L_argparse_split_fatal "L_argparse: unrecognized argument: ${_L_split_args[1]}" ;;
		esac
	}
	{
		# validate Adest
		if L_var_is_set "_L_optspec[Adest]"; then
			if ! L_is_valid_variable_name "${_L_optspec[Adest]}"; then
				_L_argparse_split_fatal "not a valid variable name: Adest=${_L_optspec[Adest]}"
			fi
		fi
	}
	{
		# Set _anything_ so that detection that has been set works.
		: "${_L_optspec[_arg_cnt]:=}"
	}
	L_asa_assign _L_parser = _L_optspec
	{
		if L_is_true "${_L_parser[add_help]:-true}"; then
			local _L_split_left_args=()
			_L_argparse_split \
				-h --help \
				help="show this help message and exit" \
				action=help
		fi
	}
}

# @description generate completion for subparsers names
# @arg $1 incomplete
# @env _L_optspec
_L_argparse_subparser_complete() {
	if ((${#_L_subargs[@]} == 0)); then
		local -A _L_subparser=()
		local _L_i _L_desc
		for _L_i in "${!_L_parser[@]}"; do
			if [[ "$_L_i" == "_subparser_$1"* ]]; then
				L_asa_load _L_subparser = "_L_parser[$_L_i]"
				_L_desc=${_L_subparser[description]:-}
				_L_desc=${_L_desc//[$'\n\t']/ }
				echo "plain$L_TAB${_L_i#_subparser_}$L_TAB$_L_desc"
			fi
		done
	else
		# find subparser
		if L_asa_has _L_parser "_subparser_${_L_subargs[0]}"; then
			L_asa_load _L_parser = "_L_parser[_subparser_${_L_subargs[0]}]"
			_L_argparse_parse_args --L_argparse_get_completion "${_L_subargs[@]:1}" "$1"
		fi
	fi
}

# @arg $1 <str> serialized subparser
# @arg $@ <str> subparser name
_L_argparse_parser_add_subparsers() {
	local i
	for i in "${@:2}"; do
		if L_asa_has _L_parser "_subparser_$i"; then L_fatal "conflicting subparser: $i"; fi
		_L_parser[_subparser_$i]=$1
	done
}

# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @env _L_optspec
# @set _L_parser
_L_argparse_split_class_subparser() {
	_L_argparse_split_check_allowed title description prog action dest required help metavar class
	_L_argparse_split_subparser_common
	#
	if [[ "${1:-}" != "{" ]]; then
		_L_argparse_split_fatal "Missing at least one subparser opening {"
	fi
	while [[ "${1:-}" == "{" ]]; do
		local _L_save_parser
		L_asa_dump _L_save_parser = _L_parser
		_L_parser=()
		{
			shift
			_L_argparse_split "$@"
			set -- ${_L_split_left_args[@]+"${_L_split_left_args[@]}"}
			if [[ "${1:-}" != "}" ]]; then
				_L_argparse_split_fatal "Missing closing }: $*"
			fi
			shift
		}
		if ! L_var_is_set '_L_parser[name]'; then
			_L_argparse_split_fatal 'Subparser does not have name property set'
		fi
		local -a _L_aliases="(${_L_parser[aliases]:-})"
		_L_aliases+=("${_L_parser[name]:?}")
		local _L_subparserstr
		L_asa_dump _L_subparserstr = _L_parser
		L_asa_load _L_parser = "_L_save_parser"
		_L_argparse_parser_add_subparsers "$_L_subparserstr" "${_L_aliases[@]}"
	done
	_L_split_left_args=("$@")
}

_L_argparse_split_subparser_common() {
	${_L_split_args[@]:+_L_argparse_split_fatal "positional arguments not allowed"}
	_L_argparse_split_check_nooptions
	if L_var_is_set '_L_parser[_has_subparsers]'; then
		_L_argparse_split_fatal "only one subparser option is possible"
	fi
	_L_parser[_has_subparsers]=1
	#
	if L_is_true "${_L_optspec[required]:-1}"; then
		_L_optspec[nargs]="+"
	else
		_L_optspec[nargs]="*"
	fi
	: "${_L_optspec[dest]:=_}"
	: "${_L_optspec[metavar]:=COMMAND}"
	: "${_L_optspec[complete]:=_L_argparse_subparser_complete \"\$1\"}"
	_L_optspec[action]=_subparser
	_L_argparse_split_argument_common
}

# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @env _L_optspec
# @set _L_parser
_L_argparse_split_class_func() {
	_L_argparse_split_check_allowed title description prog action dest required help metavar prefix class
	_L_argparse_split_subparser_common
	#
	# Get the sub-functions parsers definitions.
	# This is super unsafe and the data are later eval-ed.
	local L_v _L_subparserstr _L_prefix _L_func _L_func_declare
	local -A _L_subparser=()
	L_list_functions_with_prefix_v "${_L_optspec[prefix]}"
	for _L_func in "${L_v[@]}"; do
		if ! _L_func_declare="$(declare -f "$_L_func")"; then
			_L_argparse_split_fatal "internal error" || return 2
		fi
		if [[ "$_L_func_declare" != "$_L_func"*"()"*"{"*L_argparse*----*"\"\$@\""* ]]; then
			_L_argparse_split_fatal "Function $_L_func does not call L_argparse. Add a call to L_argparse into the function to use it as a subparser. declare -f $_L_func=%s" "$_L_func_declare" || return 2
		fi
		if _L_subparserstr=$("$_L_func" --L_argparse_dump_parser); then :; else
			_L_argparse_split_fatal "Calling [$_L_func --L_argparse_dump_parser] exited with $? nonzero. Does the function call L_argparse as the first command?" || return 2
		fi
		if [[ "$_L_subparserstr" != ${L_UUID}${_L_DECLARE_P_ARRAY_EXTGLOB}${L_UUID} ]]; then
			_L_argparse_split_fatal "Output of [$_L_func --L_argparse_dump_parser] doesn't match the proper regex. Does the function correctly calls L_argparse? The function output is: %s" "${_L_subparserstr}" || return 2
		fi
		# Remove UUIDs from the output.
		_L_subparserstr=${_L_subparserstr#"$L_UUID"}
		_L_subparserstr=${_L_subparserstr%"$L_UUID"}
		# Extract subparser aliases.
		L_asa_load _L_subparser = _L_subparserstr
		local -a _L_aliases="(${_L_subparser[aliases]:-})"
		_L_aliases+=("${_L_subparser[name]:=${_L_func#"${_L_optspec[prefix]}"}}")
		_L_subparser[_func]=$_L_func
		L_asa_dump _L_subparserstr = _L_subparser
		_L_argparse_parser_add_subparsers "$_L_subparserstr" "${_L_aliases[@]}"
	done
}

# @env _L_split_args
# @env _L_split_long_options
# @env _L_split_short_options
# @env _L_optspec
# @set _L_parser
_L_argparse_split_class_argument() {
	_L_argparse_split_check_allowed action nargs const default type choices required help metavar dest deprecated validate complete show_default
	{
		# apply defaults and everything else
		local IFS=' ' _L_options=(${_L_split_short_options[@]:+"${_L_split_short_options[@]}"} ${_L_split_long_options[@]:+"${_L_split_long_options[@]}"})
		: "${_L_options:+${_L_optspec[_options]:=" ${_L_options[*]} "}}"
		if ((${#_L_split_args[@]} && ${#_L_options[@]})); then
			_L_argparse_split_fatal "invalid option string %q: must start with a character '-'" "${_L_split_args[0]}" || return 2
		fi
	}
	{
		# Get dest from arguments.
		case "${#_L_split_args[@]}" in
		0) ;;
		1)
			if ! L_is_valid_variable_name "${_L_split_args[0]}"; then
				_L_argparse_split_fatal "unrecognized argument: ${_L_split_args[0]}"
			fi
			if L_asa_has "_L_optspec" "dest"; then
				_L_argparse_split_fatal "dest supplied twice for positional argument: ${_L_split_args[0]}"
			fi
			_L_optspec[dest]=${_L_split_args[0]}
			;;
		*) _L_argparse_split_fatal "L_argparse: unrecognized argument: ${_L_split_args[1]}" ;;
		esac
	}
	{
		# Infer dest
		# shellcheck disable=SC2180
		: "${_L_split_long_options[@]:+${_L_optspec[dest]:=${_L_split_long_options[0]##[-+][-+]}}}"
		: "${_L_split_short_options[@]:+${_L_optspec[dest]:=${_L_split_short_options[0]##[-+]}}}"
	}
	{
		# handle type
		local _L_type=${_L_optspec[type]:-}
		if [[ -n "$_L_type" ]]; then
			# set validate for type
			# shellcheck disable=2016
			local -A _L_ARGPARSE_VALIDATORS=(
				[int]='L_is_integer "$1"'
				[float]='L_is_float "$1"'
				[positive]='L_is_integer "$1" && [[ "$1" > 0 ]]'
				[nonnegative]='L_is_integer "$1" && [[ "$1" >= 0 ]]'
				[file]='[[ -f "$1" ]]'
				[file_r]='[[ -f "$1" && -r "$1" ]]'
				[file_w]='[[ -f "$1" && -w "$1" ]]'
				[dir]='[[ -d "$1" ]]'
				[dir_r]='[[ -d "$1" && -x "$1" && -r "$1" ]]'
				[dir_w]='[[ -d "$1" && -x "$1" && -w "$1" ]]'
			)
			local _L_type_validator=${_L_ARGPARSE_VALIDATORS[$_L_type]:-}
			if [[ -n "$_L_type_validator" ]]; then
				: "${_L_optspec[validate]:=$_L_type_validator}"
			else
				_L_argparse_split_fatal "L_argparse _L_optspec: invalid type=$_L_type for option: $(declare -p _L_optspec). Available types: ${!_L_ARGPARSE_VALIDATORS[*]}"
			fi
			# set completion for type
			local -A _L_ARGPARSE_COMPLETORS=(
				[file]=filenames
				[file_r]=filenames
				[file_w]=filenames
				[dir]=dirnames
				[dir_r]=dirnames
				[dir_w]=dirnames
			)
			: "${_L_optspec[complete]:=${_L_ARGPARSE_COMPLETORS["$_L_type"]:-}}"
		fi
	}
	{
		# set choices validate and complete
		if ((${#_L_optspec[choices]})); then
			if [[ -n "${_L_optspec[type]:-}" ]]; then
				_L_argparse_split_fatal "type= incompatible with choices="
			fi
			if ! ( declare -a _L_choices="(${_L_optspec[choices]})" ); then
				_L_argparse_split_fatal "choices= is invalid"
			fi
			: "${_L_optspec[validate]:=_L_argparse_choices_validate \"\$1\"}"
			: "${_L_optspec[complete]:=_L_argparse_choices_complete \"\$1\"}"
		fi
	}
	_L_argparse_split_argument_common
}

_L_argparse_split_argument_common() {
	{
		# apply defaults depending on action
		case "${_L_optspec[action]:=store}" in
		store)
			: "${_L_optspec[nargs]:=1}"
			;;
		store_const)
			if ! L_var_is_set "_L_optspec[const]"; then
				_L_argparse_split_fatal "const is not set for action=store_const"
			fi
			;;
		store_true)
			_L_optspec[action]=store_const
			: "${_L_optspec[default]:=false}" "${_L_optspec[const]:=true}"
			;;
		store_false)
			_L_optspec[action]=store_const
			: "${_L_optspec[default]:=true}" "${_L_optspec[const]:=false}"
			;;
		store_0)
			_L_optspec[action]=store_const
			: "${_L_optspec[default]:=1}" "${_L_optspec[const]:=0}"
			;;
		store_1)
			_L_optspec[action]=store_const
			: "${_L_optspec[default]:=0}" "${_L_optspec[const]:=1}"
			;;
		store_1null)
			_L_optspec[action]=store_const
			: "${_L_optspec[default]:=}" "${_L_optspec[const]:=1}"
			;;
		append)
			_L_optspec[_isarray]=1
			: "${_L_optspec[nargs]:=1}"
			;;
		append_const)
			if ! L_var_is_set "_L_optspec[const]"; then
				_L_argparse_split_fatal "const is not set but action=append_const"
			fi
			_L_optspec[_isarray]=1
			;;
		eval:*)
			if ! bash -nc "${_L_optspec[action]#eval:}"; then
				_L_argparse_split_fatal "action=${_L_optspec[action]} is invalid"
			fi
			;;
		remainder)
			if [[ -n "${_L_optspec[_options]:-}" ]]; then
				_L_argparse_split_fatal "action=${_L_optspec[action]} can be used with positional args only"
			fi
			: "${_L_optspec[nargs]=*}"
			;;
		_subparser|count|help) ;;
		*) _L_argparse_split_fatal "invalid action=${_L_optspec[action]:-}"
		esac
	}
	{
		# assert nargs value is valid, assign isarray
		case "${_L_optspec[nargs]:=0}" in
		'?'|0|1) ;;
		'*'|'+'|[2-9]|[1-9]*)
			_L_optspec[_isarray]=1
			: "${_L_optspec[action]:=append}"
			;;
		*)
			if [[ "${_L_optspec[nargs]}" -le 0 ]]; then
				_L_argparse_split_fatal "nargs=${_L_optspec[nargs]} is wrong"
			fi
			(( _L_optspec[_isarray] = _L_optspec[nargs] > 1 , 1))
		esac
	}
	{
		# validate dest
		if ! L_var_is_set _L_optspec[dest]; then
			_L_argparse_split_fatal "dest= is required for options"
		fi
		if [[ -n "${_L_parser[Adest]:-}" ]]; then
			# When Adest if given in parsersettings, the result is assigned to associative array.
			_L_optspec[dest]="${_L_parser[Adest]}[${_L_optspec[dest]}]"
		else
			# Convert - to _
			_L_optspec[dest]=${_L_optspec[dest]//[#@%!~^-]/_}
			if ! L_is_valid_variable_name "${_L_optspec[dest]}"; then
				_L_argparse_split_fatal "is not a valid variable name: dest=${_L_optspec[dest]}"
			fi
		fi
	}
	{
		# assign result
		if [[ -n "${_L_optspec[_options]:-}" ]]; then
			# option argument
			_L_parser[_option_cnt]=${_L_parser[_option_cnt]:-}X
			_L_optspec[_index]=_option_${#_L_parser[_option_cnt]}
			L_asa_dump "_L_parser[${_L_optspec[_index]}]" = _L_optspec
			#
			local _L_i
			for _L_i in "${_L_options[@]}"; do
				if L_asa_has _L_parser "$_L_i"; then
					_L_argparse_split_fatal "conflicting option: $_L_i"
				fi
				_L_parser[$_L_i]=${_L_parser[_option_${#_L_parser[_option_cnt]}]}
			done
		else
			# positional argument
			_L_parser[_arg_cnt]=${_L_parser[_arg_cnt]:-}X
			_L_optspec[_index]=_arg_${#_L_parser[_arg_cnt]}
			L_asa_dump "_L_parser[${_L_optspec[_index]}]" = _L_optspec
		fi
	}
}

# @description Split '-o --option k=v' options into an associative array.
# Additional used parameters in addition to
# @arg $@ arguments to parse
# @set _L_parser
# @env _L_parser
# @env _L_parser
# @env _L_split_left_args
# @set _L_split_left_args
_L_argparse_split() {
	if ((${#_L_parser[@]} == 0)); then
		local class=parsersetings
	else
		local class=""
	fi
	local nargs=$#
	while (($#)); do
		# L_log "${FUNCNAME[0]}: ${*@Q}" >&2
		local -A _L_optspec=()
		local _L_split_long_options=() _L_split_short_options=() _L_split_args=()
		while (($#)); do
			case "$1" in
			'--'|'----'|'{'|'}') break ;;
			*=*)
				if ! L_is_valid_variable_name "${1%%=*}"; then
					_L_argparse_split_fatal "invalid keyword option: $1"
				fi
				_L_optspec[${1%%=*}]=${1#*=}
				;;
			*[$' \t\n']*) _L_argparse_split_fatal "argument may not contain whitespace: $1" ;;
			[-+][-+]?*) _L_split_long_options+=("$1") ;;
			[-+]?*) _L_split_short_options+=("$1") ;;
			*) _L_split_args+=("$1") ;;
			esac
			shift
		done
		# L_pretty_print -np "A" _L_parser _L_optspec _L_split_long_options _L_split_short_options _L_split_args >/dev/tty
		_L_split_left_args=("$@")
		if ! _L_argparse_split_class_"${class:=${_L_optspec[class]:-argument}}" "$@"; then
			_L_argparse_split_fatal "error splitting args or invalid class=$class"
		fi
		set -- ${_L_split_left_args[@]+"${_L_split_left_args[@]}"}
		case "${1:-}" in
		'--') shift ;;
		''|'----'|'{'|'}') break ;;
		esac
		class=""
	done
	_L_split_left_args=("$@")
}

# @description
# @env _L_parser
# @arg $1 variable to set with optspec
# @arg $2 short option ex. -a
_L_argparse_parser_get_short_option() {
	L_asa_has _L_parser "$2" && L_asa_load "$1" = "_L_parser[$2]"
}

# @description
# @env _L_parser
# @arg $1 variable to set with optspec
# @arg $2 long option ex. --option
_L_argparse_parser_get_long_option() {
	if L_asa_has _L_parser "$2"; then
		L_asa_load "$1" = "_L_parser[$2]"
	elif L_is_true "${_L_parser[allow_abbrev]:-true}"; then
		local IFS=$'\n' _L_abbrev_matches
		_L_abbrev_matches=$(compgen -W "${!_L_parser[*]}" -- "$2")
		IFS=$'\n' read -r -d '' -a _L_abbrev_matches <<<"$_L_abbrev_matches"
		# L_abbreviation -v _L_abbrev_matches "$2" "${!_L_parser[@]}"
		if (( ${#_L_abbrev_matches[@]} == 1 )); then
			L_asa_load "$1" = "_L_parser[${_L_abbrev_matches[0]}]"
		elif (( ${#_L_abbrev_matches[@]} > 1 )); then
			local IFS=' '
			L_argparse_fatal "ambiguous option: $2 could match ${_L_abbrev_matches[*]}" || return 1
			return 1
		else
			L_argparse_fatal "unrecognized arguments: $2" || return 1
			return 1
		fi
	else
		L_argparse_fatal "unrecognized arguments: $2" || return 1
		return 1
	fi
}

# @description Iterate over stuff inside _L_parser.
# _L_optspec should be initiliazed to emptyh on first iteration.
# local -A _L_optspec=()
# @env _L_parser
# @set _L_optspec
# @arg $1 <str> Type, one of "option", "arg" or "subparser"
# @arg $2 <var> destination nameref, i.e. _L_optspec
# @example
#   local -A _L_optspec=()
#   while _L_argparse_parser_next_option _L_optspec; do
#		echo "This is option: $(declare -p _L_optspec)"
#	done
_L_argparse_parser_next() {
	[[ -n "${_L_parser[$1$((${_L_optspec[@]:+${_L_optspec[_index]#"$1"}}+1))]:-}" ]] &&
		L_asa_load "$2" = "_L_parser[$1$((${_L_optspec[@]:+${_L_optspec[_index]#"$1"}}+1))]"
}

_L_argparse_parser_next_argument() { _L_argparse_parser_next _arg_ "$@"; }
_L_argparse_parser_next_option() { _L_argparse_parser_next _option_ "$@"; }

# @description validate values
# @arg $@ value to assign to option
# @env _L_optspec
# @env _L_in_complete
_L_argparse_optspec_validate_values() {
	if ((${_L_in_complete:-0})); then
		return
	fi
	local _L_validate=${_L_optspec[validate]:-}
	if [[ -n "$_L_validate" ]]; then
		while (($#)); do
			if ! eval "$_L_validate"; then
				local _L_type=${_L_optspec[type]:-} _L_desc
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

if ((L_HAS_PRINTF_V_ARRAY)); then
# @description clear the dest variable
# @env _L_optspec
# @set ${_L_optspec[dest]}
_L_argparse_optspec_dest_clear() {
	if [[ "${_L_optspec[dest]}" == *"["*"]" ]]; then
		printf -v "${_L_optspec[dest]}" "%s" ""
	else
		eval "${_L_optspec[dest]}=()"
	fi
}
# @description store $1 in variable
# @arg $1 value to store
# @env _L_optspec
# @set ${_L_optspec[dest]}
_L_argparse_optspec_dest_store() {
	printf -v "${_L_optspec[dest]}" "%s" "$@"
}
# @description append $@ to the variable
# @arg $@ values to store
# @env _L_optspec
# @set ${_L_optspec[dest]}
_L_argparse_optspec_dest_append() {
	if [[ "${_L_optspec[dest]}" == *"["*"]" ]]; then
		local _L_tmp
		printf -v _L_tmp "%q " "$@"
		printf -v "${_L_optspec[dest]}" "%s%s" "${!_L_optspec[dest]:-}" "$_L_tmp"
	else
		eval "${_L_optspec[dest]}+=(\"\$@\")"
	fi
}
else
	_L_argparse_optspec_dest_clear() {
		if [[ "${_L_optspec[dest]}" == *"["*"]" ]]; then
			eval "${_L_optspec[dest]}="
		else
			eval "${_L_optspec[dest]}=()"
		fi
	}
	_L_argparse_optspec_dest_store() {
		eval "${_L_optspec[dest]}=\$1"
	}
	_L_argparse_optspec_dest_append() {
		if [[ "${_L_optspec[dest]}" == *"["*"]" ]]; then
			local _L_tmp
			printf -v _L_tmp "%q " "$@"
			eval "${_L_optspec[dest]}+=\$_L_tmp"
		else
			eval "${_L_optspec[dest]}+=(\"\$@\")"
		fi
	}
fi

# @description assign value to _L_optspec[dest] or execute the action specified by _L_optspec
# @env _L_optspec
# @env _L_assigned_options
# @set _L_assigned_options
# @env _L_in_complete
# @set _L_onlyargs
# @set _L_subargs
# @env _L_subargs
# @arg $@ arguments to store
_L_argparse_optspec_execute_action() {
	_L_assigned_options+=("${_L_optspec[_index]}")
	case ${_L_optspec[action]} in
	store|append|remainder|eval:*)
		_L_argparse_optspec_validate_values "$@" || return 1
	esac
	case ${_L_optspec[action]} in
	store)
		if ((_L_optspec[_isarray])); then
			if [[ -n "${_L_optspec[_options]:-}" ]]; then
				# positional arguments are cleared in the parsing loop
				_L_argparse_optspec_dest_clear
			fi
			_L_argparse_optspec_dest_append "$@"
		else
			_L_argparse_optspec_dest_store "$1"
		fi
		;;
	store_const) _L_argparse_optspec_dest_store "${_L_optspec[const]}" ;;
	append) _L_argparse_optspec_dest_append "$@" ;;
	append_const) _L_argparse_optspec_dest_append "${_L_optspec[const]}" ;;
	count)
		# shellcheck disable=2004
		((${_L_optspec[dest]}=${_L_optspec[dest]}+1, 1))
		;;
	remainder) _L_argparse_optspec_dest_append "$@" ;;
	help) L_argparse_print_help; exit 0 ;;
	eval:*) eval "${_L_optspec[action]#eval:}" ;;
	_subparser)
		_L_argparse_optspec_dest_append "$@"
		_L_subargs+=("$1")
		;;
	*)
		L_fatal "invalid action: $(declare -p _L_optspec)"
		;;
	esac
}

# @description Get description outputted for completion of an option.
# @arg $1 variable that will store the option help for completion
# @env _L_optspec
L_argparse_optspec_get_complete_description() {
	local _L_v="${_L_optspec[help]:-}"
	printf -v "$1" "%s" "${_L_v//[$'\t\n']/ }"
}

# @description Run compgen that outputs correctly formatted completion stream.
# With option description prefixed with the 'plain' prefix.
# Any compgen option is accepted, arguments are forwareded to compgen.
# @option -P <str> Prefix the options
# @arg $@ arguments to compgen
L_argparse_compgen() {
	local _L_desc _L_prefix="" _L_tmp
	if [[ "$1" == -P ]]; then
		_L_prefix="$2"
		shift 2
	fi
	L_argparse_optspec_get_complete_description _L_desc
	L_exit_to _L_tmp compgen -P "plain${L_TAB}${_L_prefix}" -S "${L_TAB}${_L_desc}" "$@"
	L_assert "compgen $* exited with error" test "$_L_tmp" -le 1
}


# @description validate argument with choices is correct
# @arg $1 incomplete
# @env _L_optspec
_L_argparse_choices_validate() {
	local -a _L_choices="(${_L_optspec[choices]:-})"
	if ! L_args_contain "$1" "${_L_choices[@]}"; then
		local _L_choicesstr _L_desc
		L_args_join -v _L_choicesstr ", " ${_L_choices[@]+"${_L_choices[@]}"}
		_L_argparse_optspec_get_description _L_desc
		L_argparse_fatal "argument %s: invalid choice: %q (choose from %s)" "$_L_desc" "$1" "$_L_choicesstr" || return 1
	fi
}

# @description generate completion for argument with choices
# @arg $1 incomplete
# @env _L_optspec
_L_argparse_choices_complete() {
	declare -a choices="(${_L_optspec[choices]})"
	local IFS=$'\n'
	compgen -P "plain$L_TAB" -W "${choices[*]}" -- "$1"
}

# @description Generate completions for given element.
# @stdout first line is the type
# if the type is plain, the second line contains the value to complete.
# @arg $1 <str> incomplete
# @arg $2 <str> additional prefix
# @env _L_optspec
# @env _L_parser
# @env _L_in_complete
_L_argparse_optspec_gen_completion() {
	if ((!_L_in_complete)); then
		return
	fi
	local _L_complete=${_L_optspec[complete]:-default} IFS=$'\n' _L_desc
	IFS=, read -ra _L_complete <<<"$_L_complete"
	for _L_complete in "${_L_complete[@]}"; do
		case "$_L_complete" in
		bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs)
			L_argparse_optspec_get_complete_description _L_desc
			printf "%s\t\t%s\n" "$_L_complete" "$_L_desc"
			;;
		alias|arrayvar|binding|builtin|command|directory|disabled|enabled|export|file|function|group|helptopic|hostname|job|keyword|running|service|setopt|shopt|signal|stopped|user|variable)
			compgen -P "plain$L_TAB${2:-}" -A "$_L_complete" -- "$1" || :
			# L_argparse_compgen -P "$L_TAB${2:-}" -A "$_L_complete" -- "$1"
			;;
		*" "*)
			eval "${_L_complete}"
			;;
		*)
			L_fatal "invalid $_L_complete part in complete of $(declare -p _L_optspec)"
		esac
	done
	exit
}

# @description Bash completion code.
# @see https://github.com/containers/podman/blob/main/completions/bash/podman
_L_argparse_complete_bash=$'
%(complete_func)s() {
	local response value desc cword words _
	# __reassemble_comp_words_by_ref renamed to _comp__reassemble_words in newer bash-completion
	if [[ $(type -t __reassemble_comp_words_by_ref) == function ]]; then
		__reassemble_comp_words_by_ref "=:" words cword
	elif [[ $(type -t _comp__reassemble_words) == function ]]; then
		_comp__reassemble_words "=:" words cword
	else
		words=("${COMP_WORDS[@]}")
		cword=${COMP_CWORD}
	fi
	${L_ARGPARSE_DEBUG:+set} ${L_ARGPARSE_DEBUG:+-x}
	response="$( %(prog_name)s --L_argparse_get_completion "${words[@]:1:cword}" )"
	while IFS="\t" read -r what key desc; do
		case "$what" in
		bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs)
			compopt -o "$what"
			;;
		plain) COMPREPLY+=("$key${desc:+\t$desc}")
		esac
	done <<<"$response"
	# If there is a single completion left, remove the description text
	if ((${#COMPREPLY[@]} == 1)); then
		COMPREPLY[0]=${COMPREPLY[0]%%\t*}
	else
		# Format the descriptions
		local longest=0 i
		for i in "${COMPREPLY[@]}"; do
			i=${i%%\t*}
			((longest = ${#i} > longest ? ${#i} : longest))
		done
		if ((longest)); then
			for i in "${!COMPREPLY[@]}"; do
				if [[ "${COMPREPLY[i]}" == *"\t"* ]]; then
					printf -v "COMPREPLY[$i]" "%-*s (%s)" "$longest" "${COMPREPLY[i]%%\t*}" "${COMPREPLY[i]#*\t}"
					printf -v "COMPREPLY[$i]" "%s%*s" "${COMPREPLY[i]}" "$((COLUMNS - ${#COMPREPLY[i]}))" ""
				fi
			done
		fi
	fi
	${L_ARGPARSE_DEBUG:+set} ${L_ARGPARSE_DEBUG:++x}
}
complete -F %(complete_func)s %(prog_name)s
'

# @description ZSH completion code.
_L_argparse_complete_zsh=$'#compdef %(prog_name)s
%(complete_func)s() {
	local -a response completions completions_with_descriptions
	# (( ! $+commands[%(prog_name)s] )) && return 1
	response="$( %(prog_name)s --L_argparse_get_completion "${words[@]:1:$((CURRENT-1))}" )"
	while IFS="\t" read -r what key desc; do
		case "$what" in
		filenames) _path_files -f ;;
		dirnames) _path_files -/ ;;
		bashdefault|default) _default ;;
		plain)
			if [[ -z "$desc" ]]; then
				completions+=("$key")
			else
				completions_with_descriptions+=("$key:$desc")
			fi
		esac
	done <<<"$response"
	if [ -n "$completions_with_descriptions" ]; then
		_describe -V unsorted completions_with_descriptions -U
	fi
	if [ -n "$completions" ]; then
		compadd -U -V unsorted -a completions
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
_L_argparse_complete_fish='
function %(complete_func)s;
	set -l args (commandline -pco) (commandline -pct);
	set -e args[1];
	%(prog_name)s --L_argparse_get_completion $args | while read -l -d \t what key desc;
		switch "$what";
		case dirnames; __fish_complete_directories "$key";
		case bashdefault default filenames; __fish_complete_path "$key";
		case plain; printf "%s\t%s\n" "$key" "$desc";
		end;
	end;
end;
complete --no-files --command %(prog_name)s --arguments "(%(complete_func)s)";
'

# @description Handle completion arguments
# @arg $1 Argument as passed to parse_args
# @set _L_in_complete
_L_argparse_parse_internal_args() {
	case "${1:-}" in
	--L_argparse_dump_parser)
		local _L_tmp
		L_asa_dump _L_tmp = _L_parser
		echo "$L_UUID$_L_tmp$L_UUID"
		exit
		;;
	--L_argparse_print_usage) L_argparse_print_usage; exit; ;;
	--L_argparse_print_help) L_argparse_print_help; exit; ;;
	--L_argparse_get_completion) _L_in_complete=1 ;;
	--L_argparse_complete_bash|--L_argparse_complete_zsh|--L_argparse_complete_fish)
		local i name
		i=_${1##--}
		i=${!i}
		printf -v name "%q" "$L_NAME"
		i=${i//%(prog_name)s/$name}
		i=${i//%(complete_func)s/_L_argparse_complete_${L_NAME//[^a-zA-Z0-9_]/_}}
		printf "%s" "$i"
		exit
		;;
	--L_argparse_print_completion)
		local bash_dst=${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion
		local fish_dst=${XDG_CONFIG_HOME:-~/.config}/fish/completions/
		local name
		printf -v name "%q" "$L_NAME"
		cat <<EOF
# Bash: To install completion, add the following to .bashrc
	eval "\$($name --L_argparse_complete_bash)"
# Bash: Or create completion file:
	mdir -vp $bash_dst
	$name --L_argparse_complete_bash > $bash_dst/$name
# Zsh: To install Zsh completion, add the following to .zshrc
	eval "\$($name --L_argparse_complete_zsh)"
# Fish: To install Fish completion, add the following to 
	eval "\$($name --L_argparse_complete_fish)"
# Fish: Or create completion file:
	mkdir -vp $fish_dst
	$name --L_argparse_complete_fish > $fish_dst/$name.fish
EOF
		exit
		;;
	esac
}

# @description assign defaults to all options
_L_argparse_parse_args_set_defaults() {
	local -A _L_optspec=()
	while _L_argparse_parser_next_option _L_optspec; do
		if L_var_is_set "_L_optspec[default]"; then
			if ((${_L_optspec[_isarray]:-0})); then
				declare -a _L_tmp="(${_L_optspec[default]})"
				_L_argparse_optspec_assign_array "${_L_tmp[@]}"
			else
				printf -v "${_L_optspec[dest]}" "%s" "${_L_optspec[default]}"
			fi
		fi
	done
	local -A _L_optspec=()
	while _L_argparse_parser_next_argument _L_optspec; do
		if L_var_is_set "_L_optspec[default]"; then
			if ((${_L_optspec[_isarray]:-0})); then
				declare -a _L_tmp="(${_L_optspec[default]})"
				_L_argparse_optspec_assign_array "${_L_tmp[@]}"
			else
				printf -v "${_L_optspec[dest]}" "%s" "${_L_optspec[default]}"
			fi
		fi
	done
}

# @description complete option names
# @arg $1 partial --option like `--op`
_L_argparse_gen_option_names_completion() {
	if ((_L_in_complete)); then
		local i _L_desc
		for i in "${!_L_parser[@]}"; do
			if [[ "$i" == -* && "$i" == "$1"* ]]; then
				local -A _L_optspec="${_L_parser[$i]}"
				L_argparse_optspec_get_complete_description _L_desc
				printf "plain\t%s\t%s\n" "$i" "$_L_desc"
			fi
		done
		exit
	fi
}

# @description parse long option
# @set _L_used_args
# @arg $1 long option to parse
# @arg $@ further arguments on command line
_L_argparse_parse_args_long_option() {
	# Parse long option `--rcfile file --help`
	local _L_opt=$1 _L_values=() _L_complete_prefix=0
	if [[ "$_L_opt" == *=* ]]; then
		_L_values+=("${_L_opt#*=}")
		_L_opt=${_L_opt%%=*}
		_L_complete_prefix=1
	else
		if (($# == 1)); then
			_L_argparse_gen_option_names_completion "$1"
		fi
	fi
	local -A _L_optspec=()
	if ! _L_argparse_parser_get_long_option _L_optspec "$_L_opt"; then
		if (($# == 1)); then _L_argparse_gen_option_names_completion "$1"; fi
		L_argparse_fatal "unrecognized argument: $1" || return 1
		# This is special - if _L_in_complete, then we should ignore invalid options and carry on
		return 0
	fi
	shift
	local _L_nargs
	_L_nargs=${_L_optspec[nargs]}
	case "$_L_nargs" in
	"?")
		if ((${#_L_values[@]} == 0 && $# > 0)); then
			_L_values=("$1")
			((_L_used_args += 1))
		elif L_var_is_set "_L_optspec[const]"; then
			_L_values=("${_L_optspec[const]}")
		fi
		;;
	0)
		if [[ "$_L_opt" == *=* ]]; then
			L_argparse_fatal "argument $_L_opt: ignored explicit argument ${_L_values[*]}" || return 1
		fi
		;;
	[0-9]*)
		(( _L_used_args += _L_nargs - ${#_L_values[@]} ))
		if (($# == 0 && _L_complete_prefix)); then
			_L_argparse_optspec_gen_completion "${_L_values[0]}"
		fi
		while ((${#_L_values[@]} < _L_nargs)); do
			case "$#" in
			0) L_argparse_fatal "argument $_L_opt: expected ${_L_optspec[nargs]} arguments" || return 1 ;;
			1) _L_argparse_optspec_gen_completion "$1" ;;
			esac
			_L_values+=("$1")
			shift
		done
		;;
	*) L_argparse_fatal "invalid nargs specification of $(declare -p _L_optspec)" || return 1 ;;
	esac
	_L_argparse_optspec_execute_action ${_L_values[@]+"${_L_values[@]}"} || return 1
}

# @description parse short option
# @set _L_used_args
# @arg $1 long option to parse
# @arg $@ further arguments on command line
_L_argparse_parse_args_short_option() {
	# Parse short option -euopipefail
	local _L_i _L_prefix=${1:0:1} _L_opt=${1#[-+]}
	for ((_L_i = 0; _L_i < ${#_L_opt}; ++_L_i)); do
		local _L_c
		_L_c=${_L_opt:_L_i:1}
		local -A _L_optspec=()
		if ! _L_argparse_parser_get_short_option _L_optspec "-$_L_c"; then
			if (($# == 0)); then _L_argparse_gen_option_names_completion "$_L_opt" "${_L_prefix}${_L_opt::_L_i-1}"; fi
			L_argparse_fatal "unrecognized arguments: -$_L_c" || return 1
			# This is special - if _L_in_complete, then we should ignore invalid options and carry on
			return 0
		fi
		local _L_values=() _L_nargs=${_L_optspec[nargs]:-}
		case "$_L_nargs" in
		0) ;;
		[0-9]*)
			local _L_tmp
			_L_tmp=${_L_opt:_L_i+1}
			if [[ -n "$_L_tmp" ]]; then
				_L_values+=("$_L_tmp")
			fi
			shift
			if (($# == 0)); then
				_L_argparse_optspec_gen_completion "${_L_values[0]:-}" "${_L_prefix}${_L_opt::_L_i-1}"
			fi
			(( _L_used_args += _L_nargs - ${#_L_values[@]} ))
			while ((${#_L_values[@]} < _L_nargs)); do
				case "$#" in
				0) L_argparse_fatal "argument -$_L_c: expected ${_L_optspec[nargs]} arguments" || return 1 ;;
				1) _L_argparse_optspec_gen_completion "${1:-}" ;;
				esac
				_L_values+=("$1")
				shift
			done
			;;
		*) L_argparse_fatal "invalid nargs specification of $(declare -p _L_optspec)" || return 1 ;;
		esac
		_L_argparse_optspec_execute_action ${_L_values[@]+"${_L_values[@]}"} || return 1
		if ((_L_nargs)); then
			break
		fi
	done
}

# shellcheck disable=SC2309
# @description Parse the arguments with the given parser.
# @arg $@ arguments
# @env _L_parser
# @env _L_parser
_L_argparse_parse_args() {
	# L_pretty_print -n _L_parser
	{
		# Handle internal arguments, ex. bash completion
		local _L_in_complete=0
		_L_argparse_parse_internal_args "$@"
		if ((_L_in_complete)); then shift; fi
	}
	_L_argparse_parse_args_set_defaults
	{
		# Parse options on command line.
		local _L_onlyargs=0  # When set, only positional arguments are parsed
		local _L_subargs=()  # an array that stores arguments that will be parsed by a subparser
		local _L_arg_assigned=()  # arguments assigned currently to _L_optspec
		local _L_assigned_options=()  # List of assigned _L_optspec[_index], used for checking required ones.
		local -A _L_optspec=()  # Last evaluated positional argument.
		while (($#)); do
			if ((!_L_onlyargs)); then
				# parse short and long options
				local _L_used_args=1
				case "$1" in
				--)
					if (($# == 1)); then _L_argparse_gen_option_names_completion "$1"; fi
					_L_onlyargs=1
					;;
				--?*) _L_argparse_parse_args_long_option "$@" || return 1 ;;
				-?*) _L_argparse_parse_args_short_option "$@" || return 1 ;;
				-) if (($# == 1)); then _L_argparse_gen_option_names_completion "$1"; fi; ;;
				*) _L_used_args=0 ;;
				esac
				if ((_L_used_args)); then
					shift "$_L_used_args"
					continue
				fi
			fi
			{
				# Parse positional arguments.
				if ((${#_L_arg_assigned[@]} == 0)); then
					# When _L_optspec is empty, get the next positional argument.
					if ! _L_argparse_parser_next_argument _L_optspec; then
						L_argparse_fatal "unrecognized argument: $1" || return 1
					else
						case "${_L_optspec[action]}" in
						store) if ((_L_optspec[_isarray])); then _L_argparse_optspec_dest_clear; fi ;;
						remainder|_subparser) _L_argparse_optspec_dest_clear; _L_onlyargs=1 ;;
						esac
					fi
				fi
				if L_var_is_set '_L_optspec[nargs]'; then
					_L_arg_assigned+=("$1")
					case "${_L_optspec[nargs]}" in
					"+"|"*")
						if (($# == 1)); then _L_argparse_optspec_gen_completion "$1"; fi
						_L_argparse_optspec_execute_action "$1" || return 1
						;;
					"?")
						if (($# == 1)); then _L_argparse_optspec_gen_completion "$1"; fi
						_L_argparse_optspec_execute_action "$1" || return 1
						_L_arg_assigned=()
						;;
					[0-9]*)
						if (($# == 1)); then _L_argparse_optspec_gen_completion "${_L_arg_assigned[@]}"; fi
						if ((${#_L_arg_assigned[@]} == _L_optspec[nargs])); then
							_L_argparse_optspec_execute_action "${_L_arg_assigned[@]}" || return 1
							_L_arg_assigned=()
						fi
						;;
					*) L_fatal "invalid nargs specification of $(declare -p _L_optspec)" ;;
					esac
				fi
			}
			shift
		done
	}
	{
		# Check if all required arguments have value.
		local _L_required_arguments=()  # List of _L_optspec[_index] of required arguments.
		while
			if ((${#_L_arg_assigned[@]} == 0)); then
				_L_argparse_parser_next_argument _L_optspec
			fi
		do
			_L_argparse_optspec_gen_completion ""
			case "${_L_optspec[nargs]}" in
			"+")
				if ((${#_L_arg_assigned[@]} == 0)); then
					_L_required_arguments+=("${_L_optspec[_index]}")
				fi
				;;
			[0-9]*)
				if ((${#_L_arg_assigned[@]} != _L_optspec[nargs])); then
					_L_required_arguments+=("${_L_optspec[_index]}")
				fi
				;;
			esac
			_L_arg_assigned=()
		done
		_L_argparse_gen_option_names_completion "-"
	}
	{
		# Check if all required options have value
		local _L_required_options=()
		local -A _L_optspec=()
		while _L_argparse_parser_next_option _L_optspec; do
			if L_is_true "${_L_optspec[required]:-}"; then
				if ! L_args_contain "${_L_optspec[_index]}" ${_L_assigned_options[@]+"${_L_assigned_options[@]}"}; then
					_L_required_options+=("${_L_optspec[_index]}")
				fi
			fi
		done
		_L_required_options+=(${_L_required_arguments[@]+"${_L_required_arguments[@]}"})
		# Check if required options are set
		if ((${#_L_required_options[@]})); then
			local _L_required_options_str="" _L_i
			for _L_i in "${_L_required_options[@]}"; do
				local -A _L_optspec=()
				L_asa_load _L_optspec = "_L_parser[$_L_i]"
				local _L_desc
				_L_argparse_optspec_get_description _L_desc
				_L_required_options_str+="${_L_required_options_str:+, }${_L_desc}"
			done
			L_argparse_fatal "the following arguments are required: ${_L_required_options_str}" || return 1
		fi
	}
	# L_pretty_print -n _L_parser _L_subargs
	if ((${#_L_subargs[@]})); then
		# evaluate subparsers
		if ! L_asa_has _L_parser "_subparser_${_L_subargs[0]}"; then
			L_argparse_fatal "unrecognized command: ${_L_subargs[0]}" || return 1
			return 1
		fi
		L_asa_dump "_L_parserchain[${#_L_parserchain[@]}]" = _L_parser
		L_asa_load _L_parser = "_L_parser[_subparser_${_L_subargs[0]}]"
		unset "_L_subargs[0]"
		declare -p _L_subargs >/dev/tty
		# Note - this is the last function, to propagate exit code.
		if ((_L_in_complete)); then
			_L_argparse_parse_args --L_argparse_get_completion ${_L_subargs[@]+"${_L_subargs[@]}"}
		else
			"${_L_parser[_func]:-_L_argparse_parse_args}" ${_L_subargs[@]+"${_L_subargs[@]}"}
		fi
	fi
}

# @description Parse command line aruments according to specification.
# This command takes groups of command line arguments separated by `--`  with sentinel `----` .
# The first group of arguments are arguments _L_parser.
# The next group of arguments are arguments _L_optspec.
# The last group of arguments are command line arguments passed to `_L_argparse_parse_args`.
# Note: the last separator `----` is different to make it more clear and restrict parsing better.
# @require associative arrays, i.e. Bash4.0. I could make it work with Bash3.2.
L_argparse() {
	local -A _L_parser=()  # the main parser object holding everything
	local _L_split_left_args=()  # stores the leftover arguments from _L_argparse_split
	_L_argparse_split "$@"
	set -- ${_L_split_left_args[@]+"${_L_split_left_args[@]}"}
	unset _L_split_left_args
	if [[ "${1:-}" != "----" ]]; then
		_L_argparse_split_fatal "'----' argument missing to ${FUNCNAME[0]}: $*"
	fi
	shift
	local _L_parserchain=()  # holds the callstack of parsers, added when calling subparser
	_L_argparse_parse_args "$@"
}

_L_test_z_argparse1() {
	local ret tmp option storetrue storefalse store0 store1 storeconst append
	{
		L_log "define parser"
		declare -a parser=()
		parser=(
			prog=prog
			-- -t --storetrue action=store_true
			-- -f --storefalse action=store_false
			-- -0 --store0 action=store_0
			-- -1 --store1 action=store_1
			-- -c --storeconst action=store_const const=yes default=no
			-- -a --append action=append
			----
		)
	}
	{
		L_unittest_cmd ! L_argparse "${parser[@]}" ----
		L_unittest_cmd ! L_argparse "${parser[@]}" --- -h
		L_unittest_cmd L_argparse "${parser[@]}" --
	}
	{
		local append=()
		L_log "check defaults"
		L_unittest_cmd -c L_argparse "${parser[@]}"
		L_unittest_vareq storetrue false
		L_unittest_vareq storefalse true
		L_unittest_vareq store0 1
		L_unittest_vareq store1 0
		L_unittest_vareq storeconst no
		L_unittest_arreq append
	}
	{
		append=()
		L_log "check single"
		L_unittest_cmd -c L_argparse "${parser[@]}" -tf01ca1 -a2 -a 3
		L_unittest_vareq storetrue true
		L_unittest_vareq storefalse false
		L_unittest_vareq store0 0
		L_unittest_vareq store1 1
		L_unittest_vareq storeconst yes
		L_unittest_eq "${append[*]}" '1 2 3'
	}
	{
		append=()
		L_log "check long"
		L_unittest_cmd -c L_argparse "${parser[@]}" --storetrue --storefalse --store0 --store1 --storeconst \
			--append=1 --append $'2\n3' --append $'4" \'5'
		L_unittest_vareq storetrue true
		L_unittest_vareq storefalse false
		L_unittest_vareq store0 0
		L_unittest_vareq store1 1
		L_unittest_vareq storeconst yes
		L_unittest_eq "${append[*]}" $'1 2\n3 4" \'5'
	}
	{
		L_log "args"
		local arg=() ret=0
		L_unittest_failure_capture tmp -- L_argparse prog=prog -- arg nargs="+" ----
		L_unittest_contains "$tmp" "required"
		#
		local arg=()
		L_argparse prog=prog -- arg nargs="+" ---- 1
		L_unittest_arreq arg 1
		#
		local arg=()
		L_argparse prog=prog -- arg nargs="+" ---- 1 $'2\n3' $'4"\'5'
		L_unittest_arreq arg 1 $'2\n3' $'4"\'5'
	}
	{
		L_log "check help"
		L_unittest_failure_capture tmp -- L_argparse prog="ProgramName" -- arg nargs=2 ----
		L_unittest_contains "$tmp" "Usage: ProgramName"
		L_unittest_contains "$tmp" "arg arg"
	}
	{
		L_log "only short opt"
		local o=
		L_argparse prog="ProgramName" -- -o ---- -o val
		L_unittest_eq "$o" val
	}
	{
		L_log "abbrev"
		local option verbose
		L_argparse -- --option action=store_1 -- --verbose action=store_1 ---- --o --v --opt
		L_unittest_eq "$option" 1
		L_unittest_eq "$verbose" 1
		#
		L_unittest_cmd -r "ambiguous option: --op" -- ! \
			L_argparse -- --option action=store_1 -- --opverbose action=store_1 ---- --op
	}
	{
		L_log "count"
		local verbose=
		L_argparse -- -v --verbose action=count ---- -v -v -v -v
		L_unittest_eq "$verbose" 4
		local verbose=
		L_argparse -- -v --verbose action=count ---- -v -v
		L_unittest_eq "$verbose" 2
		local verbose=
		L_argparse -- -v --verbose action=count ----
		L_unittest_eq "$verbose" ""
		local verbose=
		L_argparse -- -v --verbose action=count default=0 ----
		L_unittest_eq "$verbose" "0"
	}
	{
		L_log "type"
		local tmp arg
		L_unittest_failure_capture tmp L_argparse -- arg type=int ---- a
		L_unittest_contains "$tmp" "invalid"
	}
	{
		L_log "usage"
		L_unittest_cmd -I -- L_argparse prog=prog -- bar nargs=3 help="This is a bar argument" ---- --help
	}
	{
		L_log "required"
		L_unittest_failure_capture tmp L_argparse prog=prog -- --option required=true ----
		L_unittest_contains "$tmp" "the following arguments are required: --option"
		L_unittest_failure_capture tmp L_argparse prog=prog -- --option required=true -- --other required=true -- bar ----
		L_unittest_contains "$tmp" "the following arguments are required: --option, --other, bar"
	}
}

_L_test_z_argparse2() {
	{
		L_log "two args"
		local ret out arg1 arg2
		L_argparse -- arg1 -- arg2 ---- a1 b1
		L_unittest_eq "$arg1" a1
		L_unittest_eq "$arg2" b1
		L_argparse -- arg1 nargs=1 -- arg2 nargs='?' default=def ---- a2
		L_unittest_eq "$arg1" a2
		L_unittest_eq "$arg2" "def"
		L_argparse -- arg1 nargs=1 -- arg2 nargs='*' ---- a3
		L_unittest_eq "$arg1" a3
		L_unittest_eq "$arg2" "def"
		#
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 nargs='+' ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 nargs=1 -- arg2 nargs='*' ----
		L_unittest_contains "$out" "are required: arg1"
		L_unittest_failure_capture out -- L_argparse -- arg1 nargs=1 -- arg2 nargs='+' ----
		L_unittest_contains "$out" "are required: arg1, arg2"
	}
}

_L_test_z_argparse3() {
	{
		local count verbose filename
		L_argparse \
  		prog=ProgramName \
  		description="What the program does" \
  		epilog="Text at the bottom of help" \
  		-- filename \
  		-- -c --count \
  		-- -v --verbose action=store_1 \
  		---- -c 5 -v ./file1
  		L_unittest_eq "$count" 5
  		L_unittest_eq "$verbose" 1
  		L_unittest_eq "$filename" ./file1
	}
	{
		local tmp
		L_unittest_cmd -o "\
Usage: myprogram [-h]

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog="myprogram" ---- -h
	}
	{
		tmp=$(L_argparse prog="myprogram" -- --foo help="foo of the myprogram program" ---- -h)
		L_unittest_eq "$tmp" "\
Usage: myprogram [-h] [--foo FOO]

Options:
  -h, --help  show this help message and exit
  --foo FOO   foo of the myprogram program"
	}
	{
		L_unittest_cmd -o "\
Usage: PROG [options]

Arguments:
  bar  bar help

Options:
  -h, --help   show this help message and exit
  --foo [FOO]  foo help" \
			-- L_argparse prog=PROG usage="PROG [options]" \
			-- --foo nargs="?" help="foo help" \
			-- bar nargs="+" help="bar help" \
			---- -h
	}
	{
		L_unittest_cmd -o "\
Usage: argparse.py [-h]

A foo that bars

Options:
  -h, --help  show this help message and exit

And that's how you'd foo a bar" \
			-- L_argparse prog=argparse.py \
				description='A foo that bars' \
				epilog="And that's how you'd foo a bar" \
				---- -h
	}
	{
		local out
		L_unittest_failure_capture out \
			-- L_argparse prog=PROG allow_abbrev=False \
			-- --foobar action=store_true \
			-- --foonley action=store_false \
			---- --foon
		L_unittest_eq "$out" "\
Usage: PROG [-h] [--foobar] [--foonley]
PROG: error: unrecognized arguments: --foon"
	}
	{
		local foo='' bar=''
		L_argparse prog=PROG -- -f --foo -- bar ---- BAR
		L_unittest_eq "$bar" BAR
		L_unittest_eq "$foo" ""
		local foo='' bar=''
		L_argparse prog=PROG -- -f --foo -- bar ---- BAR --foo FOO
		L_unittest_eq "$bar" BAR
		L_unittest_eq "$foo" "FOO"
		local foo='' bar='' out=''
		L_unittest_failure_capture out -- L_argparse prog=PROG -- -f --foo -- bar ---- --foo FOO
		L_unittest_eq "$out" "\
Usage: PROG [-h] [-f FOO] bar
PROG: error: the following arguments are required: bar"
	}
	{
		local foo=''
		L_argparse -- --foo action=store_const const=42 ---- --foo
		L_unittest_eq "$foo" 42
		local foo='' bar='' baz=''
		L_argparse -- --foo action=store_true -- --bar action=store_false -- --baz action=store_false ---- --foo --bar
		L_unittest_eq "$foo" true
		L_unittest_eq "$bar" false
		L_unittest_eq "$baz" true
		local foo=()
		L_argparse -- --foo action=append ---- --foo 1 --foo 2
		L_unittest_eq "${foo[*]}" "1 2"
		local types=()
		L_argparse -- --str dest=types action=append_const const=str -- --int dest=types action=append_const const=int ---- --str --int
		L_unittest_eq "${types[*]}" "str int"
		local foo=
		# bop
		local verbose=
		L_argparse -- --verbose -v action=count default=0 ---- -vvv
		L_unittest_eq "$verbose" 3
	}
	{
		local foo=() bar=''
		L_argparse -- --foo nargs=2 -- bar nargs=1 ---- c --foo a b
		L_unittest_eq "$bar" "c"
		L_unittest_eq "${foo[*]}" "a b"
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX --foo YY
		L_unittest_eq "$foo" YY
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX --foo
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ----
		L_unittest_eq "$foo" d
		L_unittest_eq "$bar" d
		(
			tmpf1=$(mktemp)
			tmpf2=$(mktemp)
			trap 'rm "$tmpf1" "$tmpf2"' EXIT
			local outfile='' infile=''
			L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ---- "$tmpf1" "$tmpf2"
			L_unittest_eq "$infile" "$tmpf1"
			L_unittest_eq "$outfile" "$tmpf2"
			local outfile='' infile=''
			L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ---- "$tmpf1"
			L_unittest_eq "$infile" "$tmpf1"
			L_unittest_eq "$outfile" "/dev/stdout"
		)
		local outfile='' infile=''
		L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ----
		L_unittest_eq "$infile" "/dev/stdin"
		L_unittest_eq "$outfile" "/dev/stdout"
		# bop nargs="*"
		local foo=()
		L_argparse prog=PROG -- foo nargs="+" ---- a b
		L_unittest_eq "${foo[*]}" "a b"
		local out=''
		L_unittest_failure_capture out -- L_argparse prog=PROG -- foo nargs="+" ----
		L_unittest_eq "$out" "\
Usage: PROG [-h] foo [foo ...]
PROG: error: the following arguments are required: foo"
	}
	{
		local foo=''
		L_argparse -- --foo default=42 ---- --foo 2
		L_unittest_eq "$foo" 2
		L_argparse -- --foo default=42 ----
		L_unittest_eq "$foo" 42
		local length width
		L_unittest_cmd -c L_argparse -- --length default=10 type=int -- --width default=10.5 type=int ----
		L_unittest_eq "$length" 10
		L_unittest_eq "$width" 10.5
		local foo=''
		L_unittest_cmd -c L_argparse -- foo nargs="?" default=42 ---- a
		L_unittest_eq "$foo" a
		local foo=''
		L_unittest_cmd -c L_argparse -- foo nargs="?" default=42 ----
		L_unittest_eq "$foo" 42
		local foo=321
		L_unittest_cmd -c L_argparse -- foo nargs="?" default= ----
		L_unittest_eq "$foo" ""
	}
	{
		local move=''
		L_unittest_cmd -c L_argparse prog=game.py -- move choices="rock paper scissors" ---- rock
		L_unittest_vareq move rock
		L_unittest_cmd -o "\
Usage: game.py [-h] {rock,paper,scissors}
game.py: error: argument {rock,paper,scissors}: invalid choice: fire (choose from rock, paper, scissors)" \
			-- ! L_argparse prog=game.py -- move choices="rock paper scissors" ---- fire
	}
	{
		local foo=''
		L_unittest_cmd -c L_argparse prog=PROG -- --foo required=1 ---- --foo BAR
		L_unittest_vareq foo BAR
		L_unittest_cmd -o "\
Usage: PROG [-h] --foo FOO
PROG: error: the following arguments are required: --foo" \
			-- ! L_argparse prog=PROG -- --foo required=1 ----
	}
	{
		L_unittest_cmd -o "\
Usage: frobble [-h] [bar]

Arguments:
  bar  the bar to frobble (default: 42)

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog=frobble -- bar nargs="?" type=int default=42 \
				help="the bar to frobble (default: 42)" ---- -h
		L_unittest_cmd -o "\
Usage: frobble [-h]

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog=frobble -- --foo help=SUPPRESS ---- -h
	}
	{
		L_unittest_cmd -c L_argparse -- --foo -- bar ---- X --foo Y
		L_unittest_vareq foo Y
		L_unittest_vareq bar X
		L_unittest_cmd -o "\
Usage: prog [-h] [--foo FOO] bar

Arguments:
  bar

Options:
  -h, --help  show this help message and exit
  --foo FOO" \
			-- L_argparse prog=prog -- --foo -- bar ---- -h
  	}
}

_L_test_z_argparse4() {
	{
		declare -A Adest=()
		L_unittest_cmd -c \
				L_argparse prog=python.py Adest=Adest \
				-- --asome \
				-- -a action=append \
				-- dest nargs=3 \
				---- 1 1 123 --asome 1123 -a 1 -a 2 -a 3
		local -a arr="(${Adest[dest]})"
		L_unittest_arreq arr 1 1 123
		local -a arr="(${Adest[a]})"
		L_unittest_arreq arr 1 2 3
		L_unittest_eq "${Adest[asome]}" 1123
	}
	{
		local a='' dest=()
		L_argparse prog=prog -- -a -- dest nargs="*" ---- -a 1 2 3 -a 2
		L_unittest_arreq dest 2 3
		L_unittest_eq "$a" 2
		local a='' dest=()
		L_argparse prog=prog -- -a -- dest action=remainder ---- -a 1 2 3 -a
		L_unittest_arreq dest 2 3 -a
		L_unittest_eq "$a" 1
	}
	{
		local tmp
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- -a action=append complete=filenames -- dest nargs=3 ---- --L_argparse_get_completion -a ''
		L_unittest_cmd -r dirnames -- L_argparse -- --asome -- -a action=append complete=dirnames -- dest nargs=3 ---- --L_argparse_get_completion -a ''
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs=3 ---- --L_argparse_get_completion -a b
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs=3 ---- --L_argparse_get_completion -a b c
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs="?" ---- --L_argparse_get_completion -a b
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs="?" ---- --L_argparse_get_completion --ignoreme b
		L_unittest_cmd -I ! L_argparse -- --asome nargs="**"
	}
	{
		L_argparse -- --foo action=store_true -- arg nargs="*" ---- a b c
		L_unittest_eq "$foo" false
		L_unittest_arreq arg a b c
		L_argparse -- --foo action=store_true -- arg nargs="*" ---- --foo a b c
		L_unittest_eq "$foo" true
		L_unittest_arreq arg a b c
	}
}

_L_test_z_argparse5() {
	{
		local foo bar baz cmd sub
		cmd=(
			L_argparse \
			-- --foo action=store_true help='foo help' \
			-- dest=sub class=subparser \
			'{' \
				name=aa description='a help' \
				-- bar type=int help='bar help' \
			'}' \
			'{' \
				bb description='b help' \
				-- --baz choices='X Y Z' help='baz help' \
			'}' \
			----
		)
		L_unittest_cmd -c "${cmd[@]}" --foo aa 1
		L_unittest_eq "$foo" true
		L_unittest_eq "$bar" 1
		L_unittest_arreq sub aa 1
		L_unittest_cmd -c "${cmd[@]}" bb --baz X
		L_unittest_arreq sub bb --baz X
		L_unittest_eq "$baz" X
		#
		L_unittest_cmd -r "plain${L_TAB}aa${L_TAB}a help" \
			"${cmd[@]}" --L_argparse_get_completion --foo a
		L_unittest_cmd -r \
			"plain${L_TAB}X.*plain${L_TAB}Y.*plain${L_TAB}Z" \
			"${cmd[@]}" --L_argparse_get_completion bb --baz ''
	}
	{
		L_unittest_cmd -r 'missing.*\{' ! L_argparse -- dest=sub class=subparser ----
		L_unittest_cmd -r 'missing.*\}' ! L_argparse -- dest=sub class=subparser { ----
		L_unittest_cmd -r 'missing.*\}' ! L_argparse -- dest=sub class=subparser } ----
		L_unittest_cmd -r 'name' ! L_argparse -- dest=sub class=subparser { } ----
		L_unittest_cmd -r 'quoting' ! L_argparse -- dest=sub class=subparser { aliases="a'" } ----
		L_unittest_cmd -r 'name' ! L_argparse -- dest=sub class=subparser { a name=b } ----
	}
}

# shellcheck disable=SC2329
_L_test_z_argparse6() {
	# "'
	{
		CMD_1() { L_argparse -- --one ---- "$@"; echo "1 one=$one three=$three"; return 100; }
		CMD_2() { L_argparse -- --two choices='AA AB CC' ---- "$@"; echo "2 two=$two three=$three"; }
		cmd=(L_argparse -- --three default= -- class=func prefix=CMD_ ----)
		local one two three
		L_unittest_cmd -e 100 -r "1 one=one three=" "${cmd[@]}" 1 --one one
		L_unittest_cmd -r "2 two=AA three=" "${cmd[@]}" 2 --two AA
		L_unittest_cmd -r "2 two=AB three=" "${cmd[@]}" 2 --two AB
		L_unittest_cmd -r "2 two=CC three=a" "${cmd[@]}" --three a 2 --two CC
		L_unittest_cmd -r "invalid" ! "${cmd[@]}" 2 --two DD
		L_unittest_cmd -r "plain${L_TAB}AA.*plain${L_TAB}AB" \
			-- "${cmd[@]}" --L_argparse_get_completion 2 --two A
	}
}

# ]]]
fi
# private lib functions [[[
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

if ! L_function_exists L_cb_usage_usage; then L_cb_usage_usage() {
	echo "usage: $L_NAME <COMMAND> [OPTIONS]"
}; fi

if ! L_function_exists L_cb_usage_desc; then L_cb_usage_desc() {
	:
}; fi

if ! L_function_exists L_cb_usage_footer; then L_cb_usage_footer() {
	:
}; fi

# shellcheck disable=2046
_L_lib_their_usage() {
	if L_function_exists L_cb_usage; then
		L_cb_usage "$(_L_lib_list_prefix_functions)"
		return
	fi
	local a_usage a_desc a_cmds a_footer
	a_usage=$(L_cb_usage_usage)
	a_desc=$(L_cb_usage_desc)
	a_cmds=$(
		{
			for f in $(_L_lib_list_prefix_functions); do
				desc=""
				if L_function_exists L_cb_"$L_prefix$f"; then
					L_cb_"$L_prefix$f" "$f" "$L_prefix"
				fi
				echo "$f${desc:+$'\01'}$desc"
			done
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
	a_footer=$(L_cb_usage_footer)
	cat <<EOF
${a_usage}

${a_desc:-}${a_desc:+

}Commands:
$a_cmds${a_footer:+

}${a_footer:-}
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
		COMPREPLY=($(compgen -W "${cmds[*]}" -- "${COMP_WORDS[1]}"))
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

  eval "\$(script.sh cmd --bash-completion)"

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
		unset L_cb_args
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
	local _L_mode="" _L_sourced=0 OPTARG OPTING _L_opt _L_init=1
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
	--help | help)
		if L_is_main; then
			set -euo pipefail
			L_trap_err_enable
			trap 'L_trap_err $?' EXIT
		fi
		_L_lib_usage
		exit 0
		;;
	test)
		set -euo pipefail
		_L_pre=""
		printf -v _L_pre "%s\n" "${!_L_@}"
		L_trap_err_enable
		trap 'L_trap_err $?' EXIT
		_L_lib_run_tests "$@"
		printf "%s\n" "${!_L_@}" | diff <(printf "%s" "$_L_pre") -
		;;
	cmd) _L_lib_main_cmd "$@" ;;
	nop) ;;
	*) _L_lib_fatal "unknown command: $_L_mode" ;;
	esac
}

# ]]]
# main [[[

# https://stackoverflow.com/a/79201438/9072753
# https://stackoverflow.com/questions/61103034/avoid-command-line-arguments-propagation-when-sourcing-bash-script/73791073#73791073
if [[ "${BASH_ARGV[0]}" == "${BASH_SOURCE[0]}" ]]; then
	_L_lib_main -s
else
	_L_lib_main "$@"
fi

# ]]]
