#!/usr/bin/env bash
# vim: foldmethod=marker foldmarker=[[[,]]]
# shellcheck disable=2034,2178,2016,2128,2329
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

# TODO: how to ignore this for shfmt?
if test -z "${L_LIB_VERSION:-}"; then

shopt -s extglob
# @description version of the library
L_LIB_VERSION=1.1
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

L_BOLD=$'\E[1m'
L_BRIGHT=$'\E[1m'
L_DIM=$'\E[2m'
L_FAINT=$'\E[2m'
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

# @description keeps track if the colors are enabled or not.
_L_color_enabled=1

# @description
# @noargs
L_color_enable() {
	if ((!_L_color_enabled)); then
		_L_color_enabled=1
		set -- "${!L_COLOR_@}"
		while (($#)); do
			eval "L_${1#L_COLOR_}=\$$1"
			shift
		done
	fi
}

# @description
# @noargs
L_color_disable() {
	if ((_L_color_enabled)); then
		_L_color_enabled=0
		set -- "${!L_COLOR_@}"
		while (($#)); do
			eval "L_${1#L_COLOR_}="
			shift
		done
	fi
}

# @description Detect if colors should be used on the terminal.
# @see https://no-color.org/
# @see https://en.wikipedia.org/wiki/ANSI_escape_code#Unix_environment_variables_relating_to_color_support
# @noargs
L_color_detect() {
	if [[ -n "${NO_COLOR+x}" || "${TERM:-dumb}" == "dumb" || ! -t 1 ]]; then
		L_color_disable
	else
		L_color_enable
	fi
}

# ]]]
# Color constants [[[
# @section color constants
# @description color constants. Prefer to use colors above with color usage detection.

L_COLOR_BOLD=$'\E[1m'
L_COLOR_BRIGHT=$'\E[1m'
L_COLOR_DIM=$'\E[2m'
L_COLOR_FAINT=$'\E[2m'
L_COLOR_STANDOUT=$'\E[3m'
L_COLOR_UNDERLINE=$'\E[4m'
L_COLOR_BLINK=$'\E[5m'
L_COLOR_REVERSE=$'\E[7m'
L_COLOR_CONCEAL=$'\E[8m'
L_COLOR_HIDDEN=$'\E[8m'
L_COLOR_CROSSEDOUT=$'\E[9m'

L_COLOR_FONT0=$'\E[10m'
L_COLOR_FONT1=$'\E[11m'
L_COLOR_FONT2=$'\E[12m'
L_COLOR_FONT3=$'\E[13m'
L_COLOR_FONT4=$'\E[14m'
L_COLOR_FONT5=$'\E[15m'
L_COLOR_FONT6=$'\E[16m'
L_COLOR_FONT7=$'\E[17m'
L_COLOR_FONT8=$'\E[18m'
L_COLOR_FONT9=$'\E[19m'

L_COLOR_FRAKTUR=$'\E[20m'
L_COLOR_DOUBLE_UNDERLINE=$'\E[21m'
L_COLOR_NODIM=$'\E[22m'
L_COLOR_NOSTANDOUT=$'\E[23m'
L_COLOR_NOUNDERLINE=$'\E[24m'
L_COLOR_NOBLINK=$'\E[25m'
L_COLOR_NOREVERSE=$'\E[27m'
L_COLOR_NOHIDDEN=$'\E[28m'
L_COLOR_REVEAL=$'\E[28m'
L_COLOR_NOCROSSEDOUT=$'\E[29m'

L_COLOR_BLACK=$'\E[30m'
L_COLOR_RED=$'\E[31m'
L_COLOR_GREEN=$'\E[32m'
L_COLOR_YELLOW=$'\E[33m'
L_COLOR_BLUE=$'\E[34m'
L_COLOR_MAGENTA=$'\E[35m'
L_COLOR_CYAN=$'\E[36m'
L_COLOR_LIGHT_GRAY=$'\E[37m'
L_COLOR_DEFAULT=$'\E[39m'
L_COLOR_FOREGROUND_DEFAULT=$'\E[39m'

L_COLOR_BG_BLACK=$'\E[40m'
L_COLOR_BG_BLUE=$'\E[44m'
L_COLOR_BG_CYAN=$'\E[46m'
L_COLOR_BG_GREEN=$'\E[42m'
L_COLOR_BG_LIGHT_GRAY=$'\E[47m'
L_COLOR_BG_MAGENTA=$'\E[45m'
L_COLOR_BG_RED=$'\E[41m'
L_COLOR_BG_YELLOW=$'\E[43m'

L_COLOR_FRAMED=$'\E[51m'
L_COLOR_ENCIRCLED=$'\E[52m'
L_COLOR_OVERLINED=$'\E[53m'
L_COLOR_NOENCIRCLED=$'\E[54m'
L_COLOR_NOFRAMED=$'\E[54m'
L_COLOR_NOOVERLINED=$'\E[55m'

L_COLOR_DARK_GRAY=$'\E[90m'
L_COLOR_LIGHT_RED=$'\E[91m'
L_COLOR_LIGHT_GREEN=$'\E[92m'
L_COLOR_LIGHT_YELLOW=$'\E[93m'
L_COLOR_LIGHT_BLUE=$'\E[94m'
L_COLOR_LIGHT_MAGENTA=$'\E[95m'
L_COLOR_LIGHT_CYAN=$'\E[96m'
L_COLOR_WHITE=$'\E[97m'

L_COLOR_BG_DARK_GRAY=$'\E[100m'
L_COLOR_BG_LIGHT_BLUE=$'\E[104m'
L_COLOR_BG_LIGHT_CYAN=$'\E[106m'
L_COLOR_BG_LIGHT_GREEN=$'\E[102m'
L_COLOR_BG_LIGHT_MAGENTA=$'\E[105m'
L_COLOR_BG_LIGHT_RED=$'\E[101m'
L_COLOR_BG_LIGHT_YELLOW=$'\E[103m'
L_COLOR_BG_WHITE=$'\E[107m'

# It resets color and font.
L_COLOR_COLORRESET=$'\E[m'
L_COLOR_RESET=$'\E[m'

# Detect colors here.
L_color_detect

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
L_ansi_set_title() { printf '\E]0;%s' "$*"; }
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
L_ansi_8bit_fg_rgb() { printf '\E[37;5;%dm' "$((16 + 36 * $1 + 6 * $2 + $3))"; }
L_ansi_8bit_bg_rgb() { printf '\E[47;5;%dm' "$((16 + 36 * $1 + 6 * $2 + $3))"; }
L_ansi_24bit_fg() { printf '\E[38;2;%d;%d;%dm' "$@"; }
L_ansi_24bit_bg() { printf '\E[48;2;%d;%d;%dm' "$@"; }

# ]]]
# uncategorized [[[
# @section uncategorized
# @description many functions without any particular grouping

# @description wrapper function for handling -v argumnets to other functions
# It calls a function called `_<caller>_v` with argumenst without `-v <var>`
# The function `_<caller>_v` should set the variable nameref _L_v to the returned value
#   just: _L_v=$value
#   or: _L_v=(a b c)
# When the caller function is called without -v, the value of _L_v is printed to stdout with a newline..
# Otherwise, the value is a nameref to user requested variable and nothing is printed.
# @arg $@ arbitrary function arguments
# @exitcode Whatever exitcode does the `_<caller>_v` funtion exits with.
# @see L_basename
# @see L_dirname
# @example:
#    L_add() { _L_handle_v "$@"; }
#    _L_add_v() { _L_v="$(($1 + $2))"; }
_L_handle_v() {
	if [[ $1 == -v?* ]]; then
		set -- -v "${1#-v}" "${@:2}"
	fi
	if [[ $1 == -v ]]; then
		if [[ $2 != _L_v ]]; then local -n _L_v="$2"; fi
		_"${FUNCNAME[1]}"_v "${@:3}"
	else
		local _L_v
		if _"${FUNCNAME[1]}"_v "$@"; then
			printf "%s\n" "${_L_v[@]}"
		else
			return $?
		fi
	fi
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
# @arg $@ arguments to quote
L_quote_setx() { local tmp; tmp=$({ set -x; : "$@"; } 2>&1); printf "%s\n" "${tmp:5}"; }

# @description Eval the first argument - if it returns failure, then fatal.
# @arg $1 string to evaluate
# @arg $@ assertion message
# @example '[[ $var = 0 ]]' "Value of var is invalid"
L_assert() {
	if eval '!' "$1"; then
		L_print_traceback
		local msg=$1
		shift
		msg="assertion $msg failed${1:+: ${*@Q}}"
		echo "$L_NAME: $msg" >&2
	fi
}

# @description Assert the command starting from second arguments returns success.
# @arg $1 str assertiong string description
# @arg $@ command to test
# @example L_assert2 'wrong number of arguments' test "$#" = 0
L_assert2() {
	if ! "${@:2}"; then
		L_print_traceback
		local msg=$1
		shift
		msg="assertion ${*@Q} failed${msg:+: $msg}"
		echo "$L_NAME: $msg" >&2
	fi
}

# @description Return 0 if function exists.
# @arg $1 function name
L_function_exists() { [[ "$(LC_ALL=C type -t -- "$1" 2>/dev/null)" = function ]]; }

# @description Return 0 if command exists.
# @arg $1 command name
L_command_exists() { command -v "$@" >/dev/null 2>&1; }

# @description like hash, but silenced output, to check if command exists.
# @arg $@ commands to check
L_hash() { hash "$@" >/dev/null 2>&1; }

# @description Convert a string to a number.
L_strhash() { _L_handle_v "$*"; }
_L_strhash_v() {
	if L_hash cksum; then
		_L_v=$(cksum <<<"$*")
		_L_v=${_L_v%% *}
	elif L_hash sum; then
		_L_v=$(sum <<<"$*")
		_L_v=${_L_v%% *}
	elif L_hash shasum; then
		_L_v=$(shasum <<<"$*")
		_L_v=${_L_v::15}
		_L_v=$((0x1$_L_v))
	else
		L_strhash_bash -v _L_v "$*"
	fi
}

# @description Convert a string to a number in pure bash.
L_strhash_bash() { _L_handle_v "$*"; }
_L_strhash_bash_v() {
	local _L_i
	_L_v=0
	for ((_L_i=${#1};_L_i;--_L_i)); do
		printf -v _L_a %d "'${1:_L_i-1:1}"
		((_L_v += _L_a, 1))
	done
}

# @description return true if current script sourced
L_is_sourced() { [[ "${BASH_SOURCE[0]}" != "$0" ]]; }

# @description return true if current script is not sourced
L_is_main() { [[ "${BASH_SOURCE[0]}" == "$0" ]]; }

# @description return true if running in bash shell
# Portable with POSIX shell.
L_is_in_bash() { [ -n "${BASH_VERSION:-}" ]; }

# @description return true if running in posix mode
L_in_posix_mode() { [[ :$SHELLOPTS: == *:posix:* ]]; }

# @description Bash has declare -n var=$1 ?
L_has_nameref() { L_version_cmp "$BASH_VERSION" -ge 4.2.46; }

# @description Bash has declare -A var=[a]=b) ?
L_has_associative_array() { L_version_cmp "$BASH_VERSION" -ge 4; }

# @description Bash has ${!prefix*} expansion ?
L_has_prefix_expansion() { L_version_cmp "$BASH_VERSION" -ge 2.4; }

# @description Bash has ${!var} expansion ?
L_has_indirect_expansion() { L_version_cmp "$BASH_VERSION" -ge 2.0; }

# @description Bash has mapfile ?
L_has_mapfile() { L_version_cmp "$BASH_VERSION" -ge 4; }

# @description Bash has readarray ?
L_has_readarray() { L_version_cmp "$BASH_VERSION" -ge 4; }

# @description Has here string <<<"string" ?
L_has_here_string() { L_version_cmp "$BASH_VERSION" -ge 2.05; }

# @description does bash has arrays local -a arr=() ?
L_has_array() { L_version_cmp "$BASH_VERSION" -ge 1.14.7; }

# @description does bash has case a in a) ;& v) ;;& esac ?
L_has_case_fallthrough() { L_version_cmp "$BASH_VERSION" -ge 4; }

# @description test/[/[[ have a -v variable unary operator, which returns uccess if 'variable' has been set ?
L_has_test_v() { L_version_cmp "$BASH_VERSION" -ge 4.1; }

# @description bash has ${var@Q} ?
L_has_at_Q() { L_version_cmp "$BASH_VERSION" -ge 4.4; }

# @description
L_has_coproc() { L_version_cmp "$BASH_VERSION" -ge 3.2; }

# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_set() { eval "[[ -n \${$1+x} ]]"; }

# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is an array, nonzero otherwise
L_var_is_array() { [[ "$(declare -p "$1" 2>/dev/null)" == "declare -a"* ]]; }

# @description check if variable is an associative array
# @arg $1 variable nameref
L_var_is_associative() { [[ "$(declare -p "$1" 2>/dev/null)" == "declare -A"* ]]; }

# @description check if variable is readonly
# @arg $1 variable nameref
L_var_is_readonly() { (eval "$1=") 2>/dev/null; }

# @description Return 0 if the string happend to be something like true.
# @arg $1 str
L_is_true() { [[ "${1,,}" =~ ^([+]|0*[1-9][0-9]*|t|true|y|yes)$ ]]; }

# @description Return 0 if the string happend to be something like false.
# @arg $1 str
L_is_false() { [[ "${1,,}" =~ ^(-|0+|f|false|n|no)$ ]]; }

# @description Return 0 if the string happend to be something like true in locale.
# @arg $1 str
L_is_true_locale() {
	local i
	i=$(locale LC_MESSAGES)
	# extract first line
	i=${i%%$'\n'*}
	[[ "$1" =~ $i ]]
}

# @description Return 0 if the string happend to be something like false in locale.
# @arg $1 str
L_is_false_locale() {
	local i
	i=$(locale LC_MESSAGES)
	# extract second line
	i=${i#*$'\n'}
	i=${i%%$'\n'*}
	[[ "$1" =~ $i ]]
}

# @description list functions with prefix
# @option -v <var> var
# @arg $1 prefix
L_list_functions_with_prefix() {
	_L_handle_v "$@"
}
_L_list_functions_with_prefix_v() {
	_L_v=()
	for _L_i in $(compgen -A function); do
		if [[ $_L_i == "$1"* ]]; then
			_L_v+=("$_L_i")
		fi
	done
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

# @description exit with success if argument could be a variable name
# @arg $1 string to check
L_is_valid_variable_name() { [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; }

# @description exits with success if all characters in string are printable
# @arg $1 string to check
L_isprint() { [[ "$*" =~ ^[[:print:]]*$ ]]; }

# @description exits with success if all string characters are digits
# @arg $1 string to check
L_isdigit() { [[ "$*" =~ ^[0-9]+$ ]]; }

# @description exits with success if the string characters is an integer
# @arg $1 string to check
L_isinteger() { [[ "$*" =~ ^[+-]?[0-9]+$ ]]; }

# @description exits with success if the string characters is a float
# @arg $1 string to check
L_isfloat() { [[ "$*" =~ ^[+-]?([0-9]*[.]?[0-9]+|[0-9]+[.])$ ]]; }

# @description send signal to itself
# @arg $1 signal to send, see kill -l
L_raise() { kill -s "$1" "${BASHPID:-$$}"; }

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

_L_sudo_args_get() {
	declare -n ret="$1"
	ret=()
	local envs
	envs=
	for i in no_proxy http_proxy https_proxy ftp_proxy rsync_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY; do
		if [[ -n "${!i:-}" ]]; then
			envs="${envs:---preserve-env=}${envs:+,}$i"
		fi
	done
	if ((${#envs})); then
		ret=("$envs")
	fi
}

# @description Execute a command with sudo if not root, otherwise just execute the command.
# Preserves all proxy environment variables.
L_sudo() {
	local sudo=()
	if ((UID != 0)) && hash sudo 2>/dev/null; then
		local sudo_args
		_L_sudo_args_get sudo_args
		sudo=(sudo -n "${sudo_args[@]}")
	fi
	L_run "${sudo[@]}" "$@"
}

# @description check if array variable contains value
# @arg $1 array nameref
# @arg $2 needle
L_arrayvar_contains() {
	# shellcheck disable=2178
	if [[ $1 != _L_array ]]; then declare -n _L_array="$1"; fi
	L_assert2 "" test "$#" = 2
	L_args_contain "$2" "${_L_array[@]}"
}

# @description check if arguments starting from second contain the first argument
# @arg $1 needle
# @arg $@ heystack
L_args_contain() {
	local needle=$1
	shift
	while (($#)); do
		if [[ "$1" = "$needle" ]]; then
			return
		fi
		shift
	done
	return 1
}

# @description Remove elements from array for which expression evaluates to failure.
# @arg $1 array nameref
# @arg $2 expression to `eval`uate with array element of index L_i and value $1
L_arrayvar_filter_eval() {
	local -n _L_array="$1"
	shift
	local L_i _L_cmd
	_L_cmd="$*"
	for ((L_i = ${#_L_array[@]}; L_i; --L_i)); do
		set -- "${_L_array[L_i - 1]}"
		if ! eval "$_L_cmd"; then
			unset '_L_array[L_i-1]'
		fi
	done
}

# @description return max of arguments
# @option -v <var> var
# @arg $@ int arguments
# @example L_max -v max 1 2 3 4
L_max() { _L_handle_v "$@"; }
# shellcheck disable=1105,2094,2035
_L_max_v() {
	_L_v=$1
	shift
	while (($#)); do
		(("$1" > _L_v ? _L_v = "$1" : 0, 1))
		shift
	done
}


# @description return max of arguments
# @option -v <var> var
# @arg $@ int arguments
# @example L_min -v min 1 2 3 4
L_min() { _L_handle_v "$@"; }
# shellcheck disable=1105,2094,2035
_L_min_v() {
	_L_v=$1
	shift
	while (($#)); do
		(("$1" < _L_v ? _L_v = "$1" : 0, 1))
		shift
	done
}

# @description capture exit code of a command to a variable
# @option -v <var> var
# @arg $@ command to execute
L_capture_exit() { _L_handle_v "$@"; }
_L_capture_exit_v() { "$@" && _L_v=$? || _L_v=$?; }


# @option -v <var> var
# @arg $1 path
L_basename() { _L_handle_v "$@"; }
_L_basename_v() { _L_v=${*##*/}; }

# @option -v <var> var
# @arg $1 path
L_dirname() { _L_handle_v "$@"; }
_L_dirname_v() { _L_v=${*%/*}; }

# @description Produces a string properly quoted for JSON inclusion
# Poor man's jq
# @see https://ecma-international.org/wp-content/uploads/ECMA-404.pdf figure 5
# @see https://stackoverflow.com/a/27516892/9072753
# @example
#    L_json_escape -v tmp "some string"
#    echo "{\"key\":$tmp}" | jq .
L_json_escape() { _L_handle_v "$@"; }
_L_json_escape_v() {
	_L_v=$*
	_L_v=${_L_v//\\/\\\\}
	_L_v=${_L_v//\"/\\\"}
	# _L_v=${_L_v//\//\\\/}
	_L_v=${_L_v//$'\x01'/\\u0001}
	_L_v=${_L_v//$'\x02'/\\u0002}
	_L_v=${_L_v//$'\x03'/\\u0003}
	_L_v=${_L_v//$'\x04'/\\u0004}
	_L_v=${_L_v//$'\x05'/\\u0005}
	_L_v=${_L_v//$'\x06'/\\u0006}
	_L_v=${_L_v//$'\x07'/\\u0007}
	_L_v=${_L_v//$'\b'/\\b}
	_L_v=${_L_v//$'\t'/\\t}
	_L_v=${_L_v//$'\n'/\\n}
	_L_v=${_L_v//$'\x0B'/\\u000B}
	_L_v=${_L_v//$'\f'/\\f}
	_L_v=${_L_v//$'\r'/\\r}
	_L_v=${_L_v//$'\x0E'/\\u000E}
	_L_v=${_L_v//$'\x0F'/\\u000F}
	_L_v=${_L_v//$'\x10'/\\u0010}
	_L_v=${_L_v//$'\x11'/\\u0011}
	_L_v=${_L_v//$'\x12'/\\u0012}
	_L_v=${_L_v//$'\x13'/\\u0013}
	_L_v=${_L_v//$'\x14'/\\u0014}
	_L_v=${_L_v//$'\x15'/\\u0015}
	_L_v=${_L_v//$'\x16'/\\u0016}
	_L_v=${_L_v//$'\x17'/\\u0017}
	_L_v=${_L_v//$'\x18'/\\u0018}
	_L_v=${_L_v//$'\x19'/\\u0019}
	_L_v=${_L_v//$'\x1A'/\\u001A}
	_L_v=${_L_v//$'\x1B'/\\u001B}
	_L_v=${_L_v//$'\x1C'/\\u001C}
	_L_v=${_L_v//$'\x1D'/\\u001D}
	_L_v=${_L_v//$'\x1E'/\\u001E}
	_L_v=${_L_v//$'\x1F'/\\u001F}
	_L_v=${_L_v//$'\x7F'/\\u007F}
	_L_v=\"$_L_v\"
}

# @description WIP
# @option -A <allowed> list of allowed keywords
# @arg $1 args destination
# @arg $2 kwargs destination
# @arg $3 -- separator
# @arg $@ arguments
_L_kwargs_split() {
	{
		# parse args
		local OPTIND OPTARG _L_opt _L_opt_allowed=()
		while getopts A: _L_opt; do
			case $_L_opt in
				A) declare -a _L_opt_allowed=("$OPTARG"); ;;
				*) L_fatal "unhandled argument: $_L_opt"; ;;
			esac
		done
		shift "$((OPTIND-1))"
		if [[ $1 != _L_args ]]; then declare -n _L_args=$1; else declare -a _Largs=(); fi
		if [[ $2 != _L_kwargs ]]; then declare -n _L_kwargs=$2; else declare -A _L_kwargs=(); fi
		L_assert2 '3rd argument has to be --' test "$3" = '--'
		shift 3
	}
	{
		# parse args
		while (($#)); do
			case "$1" in
			-*) _L_args+=("$1") ;;
			*' '*=*) L_fatal "kw option may not contain a space" ;;
			*=*)
				local _L_opt
				_L_opt=${1%%=*}
				if [[ $_L_opt_allowed ]]; then
					L_assert2 "invalid kw option: $_L_opt" L_args_contain "$_L_opt" "${_L_opt_allowed[@]}"
				fi
				_L_kwargs["$_L_opt"]=${1#*=}
				;;
			*) _L_args+=("$1") ;;
			esac
			shift
		done
	}
}

# @description Choose elements matching prefix.
# @option -v <var> Store the result in the array var.
# @arg $1 prefix
# @arg $@ elements
L_abbreviation() { _L_handle_v "$@"; }
_L_abbreviation_v() {
	local cur
	cur=$1
	shift
	_L_v=()
	while (($#)); do
		if [[ "$1" == "$cur"* ]]; then
			_L_v+=("$1")
		fi
		shift
	done
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
		printf -v "$1" ""
	fi
}

_L_test_exit_to_1null() {
	{
		local var
		L_unittest_success L_exit_to_1null var true
		L_unittest_eq "${var:+SUCCESS}" "SUCCESS"
		L_unittest_eq "${var:-0}" "1"
		L_unittest_eq "$((var))" "1"
		L_unittest_success L_exit_to_1null var false
		L_unittest_eq "${var:+SUCCESS}" ""
		L_unittest_eq "${var:-0}" "0"
		L_unittest_eq "$((var))" "0"
	}
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

_L_test_other() {
	{
		local max=-1
		L_max -v max 1 2 3 4
		L_unittest_eq "$max" 4
	}
	{
		local a
		L_abbreviation -v a ev eval shooter
		L_unittest_eq "${a[*]}" "eval"
		L_abbreviation -v a e eval eshooter
		L_unittest_eq "${a[*]}" "eval eshooter"
		L_abbreviation -v a none eval eshooter
		L_unittest_eq "${a[*]}" ""
	}
	{
		L_unittest_checkexit 0 L_is_true true
		L_unittest_checkexit 1 L_is_true false
		L_unittest_checkexit 0 L_is_true yes
		L_unittest_checkexit 0 L_is_true 1
		L_unittest_checkexit 0 L_is_true 123
		L_unittest_checkexit 1 L_is_true 0
		L_unittest_checkexit 1 L_is_true 00
		#
		L_unittest_checkexit 1 L_is_false true
		L_unittest_checkexit 0 L_is_false false
		L_unittest_checkexit 0 L_is_false no
		L_unittest_checkexit 1 L_is_false 1
		L_unittest_checkexit 1 L_is_false 123
		L_unittest_checkexit 0 L_is_false 0
		L_unittest_checkexit 0 L_is_false 00
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
		L_arrayvar_filter_eval arr '[[ $1 -ge 3 ]]'
		L_unittest_eq "${arr[*]}" "3 4 5"
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
			t "! ${_L_allchars::127}"
		fi
	}
	{
		L_unittest_checkexit 0 L_isfloat -1
		L_unittest_checkexit 0 L_isfloat -1.
		L_unittest_checkexit 0 L_isfloat -1.2
		L_unittest_checkexit 0 L_isfloat -.2
		L_unittest_checkexit 0 L_isfloat +1
		L_unittest_checkexit 0 L_isfloat +1.
		L_unittest_checkexit 0 L_isfloat +1.2
		L_unittest_checkexit 0 L_isfloat +.2
		L_unittest_checkexit 0 L_isfloat 1
		L_unittest_checkexit 0 L_isfloat 1.
		L_unittest_checkexit 0 L_isfloat 1.2
		L_unittest_checkexit 0 L_isfloat .2
		L_unittest_checkexit 1 L_isfloat -.
		L_unittest_checkexit 1 L_isfloat abc
	}
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
	[L_LOGLEVEL_CRITICAL]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_ERROR]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_WARNING]="${L_BOLD}${L_YELLOW}"
	[L_LOGLEVEL_NOTICE]="${L_BOLD}${L_CYAN}"
	[L_LOGLEVEL_INFO]="$L_BOLD"
	[L_LOGLEVEL_DEBUG]=""
	[L_LOGLEVEL_TRACE]="$L_LIGHT_GRAY"
)

# @description was log system configured?
_L_log_conf_configured=0
# @description int current global log level
_L_log_conf_level=$L_LOGLEVEL_INFO
# @description should we use the color for logging output
_L_log_conf_color=1
# @description if this regex is set, allow elements
_L_log_conf_selecteval=true
# @description default formatting function
_L_log_conf_formateval='L_log_format_default "$@"'
# @description default outputting function
_L_log_conf_outputeval='L_log_output_to_stderr "$@"'

# @description configure L_log system
# @option	-r               Allow for reconfiguring L_log system. Otherwise second call of this function is ignored.
# @option -l <LOGLEVEL>    Set loglevel. Can be \$L_LOGLEVEL_INFO INFO or 30. Default: $_L_log_conf_level
# @option	-c <BOOL>        Enable/disable the use of color. Default: $_L_log_conf_color
# @option	-f <FORMATEVAL>  Evaluate expression for formatting. Default: $_L_log_conf_formateval
# @option	-s <SELECTEVAL>  If eval "SELECTEVAL" exits with nonzero, do not print the line. Default: $_L_log_conf_selecteval
# @noargs
# @example
# 	L_log_configure \
# 		-l debug \
# 		-c 0 \
# 		-f 'printf -v L_logrecord_msg "%s" "${@:2}"' \
# 		-o 'printf "%s\n" "$@" >&2' \
# 		-s 'L_log_select_source_regex ".*/script.sh"'
L_log_configure() {
	local OPTARG OPTIND _L_opt
	while getopt hrl:c:f:s: _L_opt; do
		case $_L_opt in
			r) _L_log_conf_configured=0 ;;
			l) if ((!_L_log_conf_configured)); then L_log_level_to_int _L_log_conf_level "$OPTARG"; fi ;;
			c) if ((!_L_log_conf_configured)); then L_exit_to_1null _L_log_conf_color L_is_true "$OPTARG"; fi ;;
			f) if ((!_L_log_conf_configured)); then _L_log_conf_formateval=$OPTARG; fi ;;
			s) if ((!_L_log_conf_configured)); then _L_log_conf_selecteval=$OPTARG; fi ;;
			*) L_fatal "invalid arguments" ;;
		esac
	done
	shift $((OPTIND-1))
	L_assert2 "invalid arguments" test $# -ne 0
	_L_log_conf_configured=1
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
#       "${_L_log_conf_color:+${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}}" \
#       "${_L_log_conf_color:+$L_COLORRESET}"
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
	if L_isdigit "$2"; then
		printf -v "$1" "%d" "$2"
	else
		local _L_i
		_L_i=${2##*_}
		_L_i=L_LOGLEVEL_${_L_i^^}
		printf -v "$1" "%d" "${!_L_i:-$L_LOGLEVEL_INFO}"
	fi
}

# @description Check if loggin is enabled for specified level
# @env _L_log_conf_level
# @set L_logrecord_loglevel
# @arg $1 str|int loglevel or log string
L_log_is_enabled_for() {
	L_log_level_to_int L_logrecord_loglevel "$1"
	# echo "$L_logrecord_loglevel $L_log_level"
	((_L_log_conf_level <= L_logrecord_loglevel))
}

# @description Finction that can be passed to filtereval to filter specific bash source name.
# @arg $1 Regex to match against BASH_SOURCE
# @see L_log_configure
L_log_select_source_regex() {
	[[ "${BASH_SOURCE[L_logrecord_stacklevel]}" =~ $* ]]
}

# @description Default logging formatting
# @arg $1 var to set
# @arg $@ log message
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
	printf -v L_logrecord_msg "%s%s:%s:%d:%s%s" \
		"${_L_log_conf_color:+${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}}" \
		"$L_NAME" \
		"${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-}" \
		"${BASH_LINENO[L_logrecord_stacklevel]}" \
		"$*" \
		"${_L_log_conf_color:+$L_COLORRESET}"
}

# @description Format logrecord with timestamp information.
# @env L_logrecord_stacklevel
# @env L_logrecord_loglevel
# @set L_logrecord_msg
# @env L_LOGLEVEL_NAMES
# @env L_LOGLEVEL_COLORS
# @env BASH_LINENO
# @env FUNCNAME
# @env L_NAME
# @arg $1 var to set
# @arg $@ log message
# @see L_log_configure
L_log_format_long() {
	printf -v L_logrecord_msg "%s""%(%Y%m%dT%H%M%S)s: %s:%s:%d: %s %s""%s" \
		"${_L_log_conf_color:+${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}}" \
		-1 \
		"$L_NAME" \
		"${FUNCNAME[L_logrecord_stacklevel]}" \
		"${BASH_LINENO[L_logrecord_stacklevel]}" \
		"${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-}" \
		"$*" \
		"${_L_log_conf_color:+$L_COLORRESET}"
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
	if L_log_is_enabled_for "$L_logrecord_loglevel" && eval "$_L_log_conf_selecteval"; then
		local L_logrecord_msg=
		# Should set L_logrecord_msg from "$@"
		eval "$_L_log_conf_formateval"
		set -- "$L_logrecord_msg"
		# Should output "$@"
		eval "$_L_log_conf_outputeval"
	fi
}

# shellcheck disable=SC2140
# @description main logging entrypoint
# @option -s <int> Increment stacklevel by this much
# @option -l <int|string> loglevel to print log line as
# @arg $1 str logline
# @set L_logrecord_loglevel
# @set L_logrecord_stacklevel
L_log() {
	local OPTARG OPTIND _L_opt
	L_logrecord_loglevel=$L_LOGLEVEL_INFO
	while getopts s:l: _L_opt; do
		case "$_L_opt" in
		s) ((L_logrecord_stacklevel += OPTARG, 1)) ;;
		l) L_log_level_to_int L_logrecord_loglevel "$OPTARG" ;;
		*) L_fatal "invalid argument $_L_opt" ;;
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
	if ((L_dryrun)); then
		_L_logargs+=("DRYRUN: +${*@Q}")
	else
		_L_logargs+=("+${*@Q}")
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
# sort [[[
# @section sort
# @description sorting function

_L_sort_bash_in() {
	local _L_start=$1 _L_end=$2
	if ((_L_start < _L_end)); then
		local _L_left=$((_L_start + 1)) _L_right=$_L_end _L_pivot=${_L_array[_L_start]}
		while ((_L_left < _L_right)); do
			if
				if ((_L_sort_numeric)); then
					((_L_pivot > _L_array[_L_left]))
				else
					[[ "$_L_pivot" > "${_L_array[_L_left]}" ]]
				fi
			then
				((_L_left++))
			elif
				if ((_L_sort_numeric)); then
					((_L_pivot < _L_array[_L_right]))
				else
					[[ "$_L_pivot" < "${_L_array[_L_right]}" ]]
				fi
			then
				((_L_right--, 1))
			else
				local _L_tmp=${_L_array[_L_left]}
				_L_array[_L_left]=${_L_array[_L_right]}
				_L_array[_L_right]=$_L_tmp
			fi
		done
		if
			if ((_L_sort_numeric)); then
				((_L_array[_L_left] < _L_pivot))
			else
				[[ "${_L_array[_L_left]}" < "$_L_pivot" ]]
			fi
		then
			local _L_tmp=${_L_array[_L_left]}
			_L_array[_L_left]=${_L_array[_L_start]}
			_L_array[_L_start]=$_L_tmp
			((_L_left--, 1))
		else
			((_L_left--, 1))
			local _L_tmp=${_L_array[_L_left]}
			_L_array[_L_left]=${_L_array[_L_start]}
			_L_array[_L_start]=$_L_tmp
		fi
		_L_sort_bash_in "$_L_start" "$_L_left"
		_L_sort_bash_in "$_L_right" "$_L_end"
	fi
}

# @description quicksort an array in place in pure bash
# Sorting using sort program is faster. Prefer L_sort
# @see L_sort
# @option -n --numeric-sort numeric sort, otherwise lexical
# @arg $1 array
# @arg [$2] starting index
# @arg [$3] ending index
L_sort_bash() {
	local _L_sort_numeric=0
	if [[ $1 = -n || $1 = --numeric-sort ]]; then
		_L_sort_numeric=1
		shift
	fi
	if [[ $1 = -- ]]; then
		shift
	fi
	#
	if [[ $1 != _L_array ]]; then declare -n _L_array="$1"; fi
	_L_sort_bash_in 0 $((${#_L_array[@]} - 1))
}

# @description sort an array using sort command
# @option -z --zero-terminated use zero separated stream with sort -z
# @option * any options are forwarded to sort command
# @arg $-1 last argument is the array nameref
# @example
#    arr=(5 2 5 1)
#    L_sort -n arr
#    echo "${arr[@]}"  # 1 2 5 5
L_sort() {
	if [[ "${*: -1}" != _L_array ]]; then declare -n _L_array="${*: -1}"; fi
	if L_args_contain -z "${@:1:$#-1}" || L_args_contain --zero-terminated "${@:1:$#-1}"; then
		mapfile -d '' -t "${@: -1}" < <(printf "%s\0" "${_L_array[@]}" | sort "${@:1:$#-1}")
	else
		mapfile -t "${@: -1}" < <(printf "%s\n" "${_L_array[@]}" | sort "${@:1:$#-1}")
	fi
}

_L_test_sort() {
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
		L_sort -n arr
		L_unittest_eq "${arr[*]}" "1 3 4 4 5 9"
		local arr=(g s b a c o)
		L_sort arr
		L_unittest_eq "${arr[*]}" "a b c g o s"
	}
	{
		L_log "test sorting of an array with zero separated stream"
		local arr=(9 4 1 3 4 5)
		L_sort -z -n arr
		L_unittest_eq "${arr[*]}" "1 3 4 4 5 9"
		local arr=(g s b a c o)
		L_sort -z arr
		L_unittest_eq "${arr[*]}" "a b c g o s"
	}
	if ((0)); then
		L_log "Compare times of bash sort vs command sort"
		local arr=() i TIMEFORMAT
		for ((i = 500; i; --i)); do arr[i]=$RANDOM; done
		local arr2=("${arr[@]}")
		TIMEFORMAT='L_sort   real=%lR user=%lU sys=%lS'
		time L_sort_bash -n arr2
		local arr3=("${arr[@]}")
		TIMEFORMAT='GNU sort real=%lR user=%lU sys=%lS'
		time L_sort -n arr3
		[[ "${arr2[*]}" == "${arr3[*]}" ]]
	fi
}

# ]]]
# trap [[[
# @section trap

# @description prints traceback
# @arg [$1] stack offset to start from
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
	local i s l tmp offset around=0
	L_color_detect
	echo
	echo "${L_CYAN}Traceback from pid $BASHPID (most recent call last):${L_RESET}"
	offset=${1:-0}
	for ((i = ${#BASH_SOURCE[@]} - 1; i > offset; --i)); do
		s=${BASH_SOURCE[i]}
		l=${BASH_LINENO[i - 1]}
		printf "  File %s%q%s, line %s%d%s, in %s()\n" \
			"$L_CYAN" "$s" "$L_RESET" \
			"${L_BLUE}${L_BOLD}" "$l" "$L_RESET" \
			"${FUNCNAME[i]}"
		if ((around >= 0)) && [[ -r "$s" ]]; then
			if false; then
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
			else
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
							"$((min+j+1))" \
							"$L_COLORRESET" \
							"${cur:+">> $L_RED"}" \
							"${lines[j]}" \
							"${cur:+"$L_COLORRESET"}"
					done
				fi
			fi
		fi
	done
} >&2

# @description Outputs Front-Mater formatted failures for functions not returning 0
# Use the following line after sourcing this file to set failure trap
#    `trap 'failure "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR`
# @see https://unix.stackexchange.com/questions/39623/trap-err-and-echoing-the-error-line
L_trap_err_failure() {
	local -n _lineno="LINENO"
	local -n _bash_lineno="BASH_LINENO"
	local _last_command="${2:-$BASH_COMMAND}"
	local _code="${1:-0}"

	## Workaround for read EOF combo tripping traps
	if ! ((_code)); then
		return "$_code"
	fi

	local _last_command_height
	_last_command_height="$(wc -l <<<"$_last_command")"

	local -a _output_array=()
	_output_array+=(
		'---'
		"lines_history: [${_lineno} ${_bash_lineno[*]}]"
		"function_trace: [${FUNCNAME[*]}]"
		"exit_code: ${_code}"
	)

	if [[ "${#BASH_SOURCE[@]}" -gt '1' ]]; then
		_output_array+=('source_trace:')
		for _item in "${BASH_SOURCE[@]}"; do
			_output_array+=("  - ${_item}")
		done
	else
		_output_array+=("source_trace: [${BASH_SOURCE[*]}]")
	fi

	if [[ "$_last_command_height" -gt '1' ]]; then
		_output_array+=(
			'last_command: ->'
			"$_last_command"
		)
	else
		_output_array+=("last_command: ${_last_command}")
	fi

	_output_array+=('---')
	printf '%s\n' "${_output_array[@]}" >&2
	exit "$_code"
}

L_trap_err_show_source() {
	local idx=${1:-0}
	echo "Traceback:"
	awk -v L="${BASH_LINENO[idx]}" -v M=3 \
		'NR>L-M && NR<L+M { printf "%-5d%3s%s\n",NR,(NR==L?">> ":""),$0 }' "${BASH_SOURCE[idx + 1]}"
	L_critical "command returned with non-zero exit status"
}

L_trap_err_small() {
	L_error "fatal error on $(caller)"
}

L_trap_err() {
	## Workaround for read EOF combo tripping traps
	if ((!$1)); then
		return "$1"
	fi
	{
		L_print_traceback 1
		L_critical "Command returned with non-zero exit status: $1"
	} >&2 || :
	exit "$1"
}

L_trap_err_enable() {
	set -eEo functrace
	trap 'L_trap_err $?' ERR
}

L_trap_err_disable() {
	trap '' ERR
}

L_trap_init() {
	L_trap_err_enable
}

L_trap_init

###############################################################################
# ]]]
# version [[[
# @section version

# shellcheck disable=1105,2053
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
		IFS='.-()' read -ra a <<EOF
$1
EOF
		IFS='.-()' read -ra b <<EOF
$3
EOF
		L_max -v max "${#a[@]}" "${#b[@]}"
		L_min -v max "${4:-3}" "$max"
		for ((i = 0; i < max; ++i)); do
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
# asa - Associative Array [[[
# @section asa
# @description collection of function to work on associative array

# @description Copy associative dictionary
# Notice: the destination array is _not_ cleared.
# @arg $1 var Source associative array
# @arg $2 var Destination associative array
# @arg [$3] str Filter only keys with this regex
L_asa_copy() {
	if [[ $1 != _L_nameref_from ]]; then declare -n _L_nameref_from="$1"; fi
	if [[ $1 != _L_nameref_to ]]; then declare -n _L_nameref_to="$2"; fi
	L_assert2 "" test "$#" = 2 -o "$#" = 3
	local _L_key
	for _L_key in "${!_L_nameref_from[@]}"; do
		if (($# == 2)) || [[ "$_L_key" =~ $3 ]]; then
			_L_nameref_to["$_L_key"]=${_L_nameref_from["$_L_key"]}
		fi
	done
}

# @description check if associative array has key
# @arg $1 associative array nameref
# @arg $2 key
L_asa_has() {
	if [[ $1 != _L_asa ]]; then declare -n _L_asa="$1"; fi
	[[ "${_L_asa["$2"]+yes}" ]]
}

# @description check if associative array is empty
# @arg $1 associative array nameref
L_asa_is_empty() {
	if [[ $1 != _L_asa ]]; then declare -n _L_asa="$1"; fi
	(( ${#_L_asa[@]} == 0 ))
}

# @description Get value from associative array
# @option -v <var> var
# @arg $1 associative array nameref
# @arg $2 key
# @arg [$3] optional default value
# @exitcode 1 if no key found and no default value
L_asa_get() { _L_handle_v "$@"; }
_L_asa_get_v() {
	L_assert2 '' test "$#" = 2 -o "$#" = 3
	if L_asa_has "$1" "$2"; then
		if [[ $1 != _L_asa ]]; then declare -n _L_asa="$1"; fi
		_L_v=${_L_asa["$2"]}
	else
		if (($# == 3)); then
			_L_v=$3
		else
			_L_v=
			return 1
		fi
	fi
}

# @description get the length of associative array
# @option -v <var> var
# @arg $1 associative array nameref
L_asa_len() {
	_L_handle_v "$@"
}
_L_asa_len_v() {
	if [[ $1 != _L_asa ]]; then declare -n _L_asa="$1"; fi
	local _L_keys=("${!_L_asa[@]}")
	_L_v=${#_L_keys[@]}
}

# @description get keys of an associative array in a sorted
# @option -v <var> var
# @arg $1 associative array nameref
L_asa_keys_sorted() {
	_L_handle_v "$@"
}
_L_asa_keys_sorted_v() {
	if [[ $1 != _L_asa ]]; then declare -n _L_asa="$1"; fi
	L_assert2 '' test "$#" = 1
	_L_v=("${!_L_asa[@]}")
	L_sort _L_v
}

# @description Move the 3rd argument to the first and call
# The `L_asa $1 $2 $3 $4 $5` becomes `L_asa_$3 $1 $2 $4 $5`
# @option -v <var> var
# @arg $1 function name
# @arg $2 associative array nameref
# @arg $@ arguments
# @example L_asa -v v get map a
L_asa() {
	if [[ $1 == -v?* ]]; then
		"L_asa_$2" "$1" "${@:3}"
	elif [[ $1 == -v ]]; then
		"L_asa_$3" "${@:1:2}" "${@:4}"
	else
		"L_asa_$1" "${@:2}"
	fi
}

# @description store an associative array inside an associative array
# @arg $1 var destination nameref
# @arg $2 =
# @arg $3 var associative array nameref to store
# @see L_nestedasa_get
L_nestedasa_set() {
	if [[ $1 != _L_dest ]]; then declare -n _L_dest="$1"; fi
	_L_dest=$(declare -p "$3")
	# _L_dest=${!3@A} # does not work
	_L_dest=${_L_dest#*=}
}

# @description extract an associative array inside an associative array
# @arg $1 var associative array nameref to store
# @arg $2 =
# @arg $3 var source nameref
# @see L_nestedasa_set
L_nestedasa_get() {
	if [[ $3 != _L_asa ]]; then declare -n _L_asa="$3"; fi
	if [[ $1 != _L_asa_to ]]; then declare -n _L_asa_to="$1"; fi
	declare -A _L_tmpa="$_L_asa"
	_L_asa_to=()
	L_asa_copy _L_tmpa "$1"
}

_L_test_asa() {
	declare -A map
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
		local -A map2
		L_asa_copy map map2
	}
	{
		L_info "_L_test_asa: nested asa"
		local -A map2=([c]=d [e]=f)
		L_nestedasa_set map[mapkey] = map2
		L_asa_has map mapkey
		L_asa_get map mapkey
		local -A map3
		L_nestedasa_get map3 = map[mapkey]
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
}

# ]]]
# unittest [[[
# @section unittest
# @description testing library
# @example
#    L_unittest_eq 1 1

# @description accumulator for unittests failures
L_unittest_fails=0
# @description set to 1 to exit immediately when a test fails
L_unittest_exit_on_error=0

# @description internal unittest function
# @env L_unittest_fails
# @set L_unittest_fails
# @arg $1 message to print what is testing
# @arg $2 message to print on failure
# @arg $@ command to execute, can start with '!' to invert exit status
_L_unittest_internal() {
	local _L_tmp=0 _L_invert=0
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
	echo -n "${FUNCNAME[2]}:${BASH_LINENO[1]}${1:+: }${1:-}: "
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

L_unittest_run() {
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
			L_log "Getting function with prefix ${OPTARG@Q}"
			L_list_functions_with_prefix -v _L_tests "$OPTARG"
			;;
		r)
			L_log "filtering tests with ${OPTARG@Q}"
			L_arrayvar_filter_eval _L_tests '[[ $1 =~ $OPTARG ]]'
			;;
		E)
			L_unittest_exit_on_error=1
			;;
		*) L_fatal "invalid argument: $_L_opt" ;;
		esac
	done
	shift "$((OPTIND-1))"
	L_assert2 'too many arguments' test "$#" = 0
	L_assert2 'no tests matched' test "${#_L_tests[@]}" '!=' 0
	local _L_test
	for _L_test in "${_L_tests[@]}"; do
		L_log "executing $_L_test"
		"$_L_test"
	done
	L_log "done testing: ${_L_tests[*]}"
	if ((L_unittest_fails)); then
		L_error "testing failed"
	else
		L_log "${L_GREEN}testing success"
	fi
	exit "$L_unittest_fails"
}

# @description Test is eval of a string return success.
# @arg $1 string to eval-ulate
# @arg $@ error message
L_unittest_eval() {
	_L_unittest_internal "test eval ${1}" "${*:2}" eval "$1" || :
}

# @description Check if command exits with specified exitcode
# @arg $1 exit code
# @arg $@ command to execute
L_unittest_checkexit() {
	local _L_ret _L_shouldbe
	_L_shouldbe=$1
	shift 1
	"${@}" && _L_ret=$? || _L_ret=$?
	_L_unittest_internal "test exit of ${*@Q} is $_L_ret" "$_L_ret != $_L_shouldbe" [ "$_L_ret" -eq "$_L_shouldbe" ]
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
	local _L_ret=0
	if [[ $1 != _L_tmp ]]; then local -n _L_tmp=$1; fi
	shift
	if [[ "$1" == -- ]]; then shift; fi
	if _L_tmp=$("$@" 2>&1); then
		_L_ret=0
	else
		_L_ret=$?
	fi
	_L_unittest_internal "test exit of ${*@Q} is $_L_ret i.e. nonzero" "$_L_ret = 0: $_L_tmp" [ "$_L_ret" -ne 0 ]
}

# @description capture exit code and stdout and stderr into variables without subshell
# @arg $1 var exit code
# @arg $2 var stdout and stderr output
# @arg $@ command to execute
L_unittest_capture_nofork() {
	coproc { mapfile -t -d '' "$2"; printf "%s" "$2"; }
	if "${@:3}" 2>&1 >"${COPROC[1]}"; then
		printf -v "$1" 0
	else
		printf -v "$1" "$?"
	fi
	exec {COPROC[1]}>&-
	mapfile -t -d '' -u "${COPROC[0]}" "$2"
	exec {COPROC[0]}>&-
	wait "$COPROC_PID"
}

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
	set -x
	if ! _L_unittest_internal "test pipes${3:+ $3}" "${4:-}" [ "$a" "$op" "$b" ]; then
		_L_unittest_showdiff "$a" "$b"
		return 1
	fi
}

_L_unittest_showdiff() {
	local -
	set +x
	if L_hash sdiff; then
		if [[ "$1" =~ ^[[:print:][:space:]]*$ && "$2" =~ ^[[:print:][:space:]]*$ ]]; then
			sdiff <(cat <<<"$1") - <<<"$2"
		else
			sdiff <(xxd -p <<<"$1") <(xxd -p <<<"$2")
		fi
	else
		printf -- "--- diff ---\nL: %q\nR: %q\n\n" "$1" "$2"
	fi
}

# @description test if varaible has value
# @arg $1 variable nameref
# @arg $2 value
L_unittest_vareq() {
	local -
	set +x
	if ! _L_unittest_internal "test: \$$1=${!1:+${!1@Q}} == ${2@Q}" "" [ "${!1:-}" == "$2" ]; then
		_L_unittest_showdiff "${!1:-}" "$2"
		return 1
	fi
}

# @description test if two strings are equal
# @arg $1 one string
# @arg $2 second string
L_unittest_eq() {
	local -
	set +x
	if ! _L_unittest_internal "test: ${1@Q} == ${2@Q}" "" [ "$1" == "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test two strings are not equal
# @arg $1 one string
# @arg $2 second string
L_unittest_ne() {
	local -
	set +x
	if ! _L_unittest_internal "test: ${1@Q} != ${2@Q}" "" [ "$1" != "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if a string matches regex
# @arg $1 string
# @arg $2 regex
L_unittest_regex() {
	local -
	set +x
	if ! _L_unittest_internal "test: ${1@Q} =~ ${2@Q}" "" eval "[[ ${1@Q} =~ $2 ]]"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if a string contains other string
# @arg $1 string
# @arg $2 needle
L_unittest_contains() {
	local -
	set +x
	if ! _L_unittest_internal "test: ${1@Q} == *${2@Q}*" "" eval "[[ ${1@Q} == *${2@Q}* ]]"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# ]]]
# trapchain [[[
# @section trapchain
# @description library for chaining traps

# @description 255 bytes with all possible 255 values
# Generated by: printf "%q" "$(seq 255 | xargs printf "%02x\n" | xxd -r -p)"
_L_allchars=$'\001\002\003\004\005\006\a\b\t\n\v\f\r\016\017\020\021\022\023\024\025\026\027\030\031\032\E\034\035\036\037 !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'

# @description Convert trap name to number
# @option -v <var> var
# @arg $1 trap name or trap number
L_trap_to_number() {
	_L_handle_v "$@"
}
_L_trap_to_number_v() {
	if [[ "$1" == EXIT ]]; then
		_L_v=0
	elif L_isdigit "$1"; then
		_L_v=$1
	else
		_L_v=$(trap -l) &&
			[[ "$_L_v" =~ [^0-9]([0-9]*)\)\ $1[[:space:]] ]] &&
			_L_v=${BASH_REMATCH[1]}
	fi
}

# @description convert trap number to trap name
# @option -v <var> var
# @arg $1 signal name or signal number
# @example L_trap_to_name -v var 0 && L_assert2 '' test "$var" = EXIT
L_trap_to_name() {
	_L_handle_v "$@"
}
_L_trap_to_name_v() {
	if [[ "$1" == 0 ]]; then
		_L_v=EXIT
	elif L_isdigit "$1"; then
		_L_v=$(trap -l) &&
			[[ "$_L_v" =~ [^0-9]$1\)\ ([^[:space:]]+) ]] &&
			_L_v=${BASH_REMATCH[1]}
	else
		_L_v="$1"
	fi
}

# @description Get the current value of trap
# @option -v <var> var
# @arg $1 str|int signal name or number
# @example
#   trap 'echo hi' EXIT
#   L_trap_get -v var EXIT
#   L_assert2 '' test "$var" = 'echo hi'
L_trap_get() {
	_L_handle_v "$@"
}
_L_trap_get_v() {
	L_trap_to_name -v _L_v "$@" &&
	_L_v=$(trap -p "$_L_v") &&
	if [[ -n "$_L_v" ]]; then
		local -a _L_tmp="($_L_v)" &&
		_L_v=${_L_tmp[2]}
	fi
}

# @description internal callback called when trap fires
# @arg $1 str trap name
_L_trapchain_callback() {
	# This is what it takes.
	local _L_tmp
	_L_tmp=_L_trapchain_data_$1
	eval "${!_L_tmp}"
}

# shellcheck disable=2064
# @description Chain a trap to execute in reverse order
# @arg $1 str Script to execute
# @arg $2 str signal to handle
# @example
#   L_trapchain 'echo' EXIT
#   L_trapchain 'echo -n world' EXIT
#   L_trapchain 'echo -n " "' EXIT
#   L_trapchain 'echo -n hello' EXIT
#   # will print 'hello world' on exit
L_trapchain() {
	local _L_name &&
		L_trap_to_name -v _L_name "$2" &&
		trap "_L_trapchain_callback $_L_name" "$_L_name" &&
		eval "_L_trapchain_data_$2=\"\$1\"\$'\\n'\"\${_L_trapchain_data_$2:-}\""
}

# shellcheck disable=2064
# shellcheck disable=2016
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
			L_trapchain 'echo -n "!"' EXIT
			L_trapchain 'echo -n world' EXIT
			L_trapchain 'echo -n " "' EXIT
			L_trapchain 'echo -n hello' EXIT
		)
		L_unittest_eq "$tmp" "hello world!"
		allchars="$_L_allchars"
		tmp=$(
			printf -v tmp %q "$allchars"
			L_trapchain 'echo -n "hello"' SIGUSR1
			L_trapchain "echo $tmp" SIGUSR1
			L_trapchain 'echo -n world' SIGUSR2
			L_trapchain 'echo -n " "' SIGUSR2
			L_trapchain 'echo -n "!"' EXIT
			L_raise SIGUSR1
			L_raise SIGUSR2
		)
		local res
		res="$allchars"$'\n'"hello world!"
		L_unittest_eq "$tmp" "$res"
	}
	(
		L_log "Check if extracting all charactesr from trap works"
		trap ": $_L_allchars" SIGUSR1
		L_trap_get -v tmp SIGUSR1
		L_unittest_eq "$tmp" ": $_L_allchars"
	)
}

# ]]]
# Map [[[
# @section map
# @description key value store without associative array implementation
# Deprecated, experimental, do not use.
#
# L_map consist of an empty initial newline.
# Then follows map name, follows a spce, and then printf %q of the value.
#
#                     # empty initial newline
#     key $'value'
#     key2 $'value2'
#
# This format matches the regexes used in L_map_get for easy extraction using bash
# Variable substituation.

# @description Initializes a map
# @arg $1 var variable name holding the map
L_map_init() {
	printf -v "$1" "%s" ""
}

# @description Clear a key of a map
# @arg $1 var map
# @arg $2 str key
L_map_clear() {
	if ! _L_map_check "$1" "$2"; then return 2; fi
	local _L_map_name
	_L_map_name=${!1}
	_L_map_name="${_L_map_name/$'\n'"$2 "+([!$'\n'])/}"
	printf -v "$1" %s "$_L_map_name"
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

# @description Set a key in a map to value
# @arg $1 var map
# @arg $2 str key
# @arg $3 str value
L_map_set() {
	L_map_clear "$1" "$2"
	local _L_map_name _L_map_name2
	_L_map_name=${!1}
	# This code depends on that `printf %q` _never_ prints a newline, instead it does $'\n'.
	# I add key-value pairs in chunks with preeceeding newline.
	printf -v _L_map_name2 %q "${*:3}"
	_L_map_name+=$'\n'"$2 $_L_map_name2"
	printf -v "$1" %s "$_L_map_name"
}

# @description Append value to an existing key in map
# @arg $1 var map
# @arg $2 str key
# @arg $3 str value to append
L_map_append() {
	local _L_map_name
	if L_map_get_v _L_map_name "$1" "$2"; then
		L_map_set "$1" "$2" "$_L_map_name${*:3}"
	else
		L_map_set "$1" "$2" "$3"
	fi
}

# @description Assigns the value of key in map.
# If the key is not set, then assigns default if given and returns with 1.
# You want to prefer this version of L_map_get
# @option -v <var> var
# @arg $1 var map
# @arg $2 str key
# @arg [$3] str default
L_map_get() {
	_L_handle_v "$@"
}
_L_map_get_v() {
	local _L_map_name
	_L_map_name=${!1}
	local _L_map_name2
	_L_map_name2="$_L_map_name"
	# Remove anything in front of the newline followed by key followed by space.
	# Because the key can't have newline not space, it's fine.
	_L_map_name2=${_L_map_name2##*$'\n'"$2 "}
	# If nothing was removed, then the key does not exists.
	if [[ "$_L_map_name2" == "$_L_map_name" ]]; then
		if (($# >= 3)); then
			_L_v="${*:3}"
			return 0
		else
			return 1
		fi
	fi
	# Remove from the newline until the end and print with eval.
	# The key was inserted with printf %q, so it has to go through eval now.
	_L_map_name2=${_L_map_name2%%$'\n'*}
	eval "_L_v=$_L_map_name2"
}


# @description
# @arg $1 var map
# @arg $2 str key
# @exitcode 0 if map contains key, nonzero otherwise
L_map_has() {
	if ! _L_map_check "$1" "$2"; then return 2; fi
	local _L_map_name
	_L_map_name=${!1}
	[[ "$_L_map_name" == *$'\n'"$2 "* ]]
}

# @description List all keys in the map.
L_map_keys() {
	local _L_map_name
	_L_map_name=${!1}
	local IFS=' ' key val
	while read -r key val; do
		if [[ -z "$key" ]]; then continue; fi
		printf "%s\n" "$key"
	done <<<"$_L_map_name"
}

# @description List items with tab separated key and value.
# Value is the output from printf %q - it needs to be eval-ed.
L_map_items() {
	local _L_map_name
	_L_map_name=${!1}
	local key val
	while read -r key val; do
		if [[ -z "$key" ]]; then continue; fi
		printf "%s\t%s\n" "$key" "$val"
	done <<<"$_L_map_name"
}

# @description Load all keys to variables with the name of $prefix$key.
# @arg $1 map variable
# @arg $2 prefix
# @arg $@ Optional list of keys to load. If not set, all are loaded.
L_map_load() {
	if ! _L_map_check "$@"; then return 2; fi
	local _L_map_name
	_L_map_name=${!1}
	local IFS=' ' _L_key _L_val
	while read -r _L_key _L_val; do
		if [[ -z "$_L_key" ]]; then continue; fi
		if (($# > 2)); then
			for _L_tmp in "${@:3}"; do
				if [[ "$_L_tmp" == "$_L_key" ]]; then
					eval "printf -v \"\$2\$_L_key\" %s $_L_val"
					break
				fi
			done
		else
			eval "printf -v \"\$2\$_L_key\" %s $_L_val"
		fi
	done <<<"$_L_map_name"
}

_L_map_check() {
	local i
	for i in "$@"; do
		if ! L_is_valid_variable_name "$i"; then
			L_error "L_map:${FUNCNAME[1]}:${BASH_LINENO[2]}: ${i@Q} is not valid variable name"
			return 1
		fi
	done
}

# shellcheck disable=2018
_L_test_map() {
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
	L_map_set var allchars "$_L_allchars"
	L_unittest_eq "$(L_map_get var allchars)" "$(printf %s "$_L_allchars")" "L_map_get var allchars"
	L_map_clear var allchars
	L_unittest_checkexit 1 L_map_get var allchars
	L_map_set var allchars "$_L_allchars"
	local s_a s_b s_allchars
	L_unittest_eq "$(L_map_keys var | sort)" "$(printf "%s\n" b a allchars | sort)" "L_map_keys check"
	L_map_load var s_
	L_unittest_vareq s_a 3
	L_unittest_vareq s_b 2
	L_unittest_eq "$s_allchars" "$_L_allchars"
}

# ]]]
# argparse [[[
# @section argparse
# @description argument parsing in bash
# @env _L_mainsettings The arguments passed to ArgumentParser() constructor
# @env _L_parser The current parser

# @description Print argument parsing error and exit.
# @env L_NAME
# @env _L_mainsettings
# @exitcode 1
L_argparse_fatal() {
	if ((${_L_in_complete:-0})); then
		return
	fi
	L_argparse_print_usage >&2
	echo "${_L_mainsettings["prog"]:-${L_NAME:-$0}}: error: $*" >&2
	exit 1
}

# @description given two lists indent them properly
# This is used internally by L_argparse_print_help to
# align help message of options and arguments for ouptut.
# @arg $1 -v
# @arg $2 destination variable
# @arg $3 metavars
# @arg $4 help messages variable
_L_argparse_print_help_indenter() {
	local -n _L_result=$2 _L_left=$3 _L_right=$4
	local _L_max=0 _L_len _L_i
	for _L_i in "${_L_left[@]}"; do
		_L_i=${#_L_i}
		((_L_max = _L_max < _L_i ? _L_i : _L_max))
	done
	((_L_max += 2))
	for _L_i in "${!_L_left[@]}"; do
		((_L_len = ${#_L_left[_L_i]} == 0 ? 0 : _L_max, 1))
		printf -v _L_result "%s""  %-*s%s\n" "$_L_result" "$_L_len" "${_L_left[_L_i]}" "${_L_right[_L_i]}"
	done
}

# shellcheck disable=2120
# @description Print help or only usage for given parser or global parser.
# @option -s --short print only usage, not full help
# @arg [$1] _L_parser
# @env _L_parser
L_argparse_print_help() {
	{
		# parse argument
		local _L_short=0
		case "${1:-}" in
		-s | --short)
			_L_short=1
			shift
			;;
		esac
		if (($# == 1)); then
			local -n _L_parser="$1"
			shift
		fi
		L_assert2 "" test "$#" == 0
	}
	{
		#
		local _L_usage _L_dest
		local -A _L_mainsettings="${_L_parser[0]}" _L_optspec=()
		_L_usage="usage: ${_L_mainsettings[prog]:-${_L_name:-$0}}"
	}
	{
		# Parse options
		local _L_i=0
		local _L_usage_options_list=()  # holds '-a VAR' descriptions of options
		local _L_usage_options_help=()  # holds help message of options
		local _L_longopt _L_options
		while _L_argparse_parser_next_option _L_i _L_optspec; do
			local -a _L_options="(${_L_optspec[options]:-})"
			_L_required=${_L_optspec[required]:-0}
			#
			if ((${#_L_options[@]})); then
				local _L_desc=""
				local _L_j
				for _L_j in "${_L_options[@]}"; do
					_L_desc+=${_L_desc:+, }${_L_j}
				done
				local _L_opt=${_L_options[0]} _L_metavar=${_L_optspec[metavar]} _L_nargs=${_L_optspec[nargs]}
				local _L_metavars=""
				for ((_L_j = _L_nargs; _L_j; --_L_j)); do
					_L_metavars+=" ${_L_metavar}"
				done
				if ((_L_nargs)); then
					_L_desc+=" $_L_metavar"
				fi
				local _L_notrequired=yes
				if L_is_true "$_L_required"; then
					_L_notrequired=
				fi
				_L_usage+=" ${_L_notrequired:+[}$_L_opt$_L_metavars${_L_notrequired:+]}"
				_L_usage_options_list+=("${_L_desc}")
				_L_usage_options_help+=("${_L_optspec[help]:-}")
			fi
		done
	}
	{
		# Indent _L_usage_options_list and _L_usage_options_help properly
		local _L_usage_options=""  # holds options usage string
		_L_argparse_print_help_indenter -v _L_usage_options _L_usage_options_list _L_usage_options_help
	}
	{
		# Parse positional arguments
		local _L_usage_args_list=() _L_usage_args_help=()
		local -A _L_optspec
		local _L_i=0
		while _L_argparse_parser_next_argument _L_i _L_optspec; do
			if _L_argparse_optspec_is_argument; then
				local _L_metavar _L_nargs
				_L_metavar=${_L_optspec[metavar]}
				_L_nargs=${_L_optspec[nargs]}
				case "$_L_nargs" in
				'+')
					_L_usage+=" ${_L_metavar} [${_L_metavar}...]"
					;;
				'*')
					_L_usage+=" [${_L_metavar}...]"
					;;
				[0-9]*)
					while ((_L_nargs--)); do
						_L_usage+=" $_L_metavar"
					done
					;;
				*)
					L_fatal "not implemented"
					;;
				esac
				_L_usage_args_list+=("$_L_metavar")
				_L_usage_args_help+=("${_L_optspec[help]:-}")
			fi
		done
	}
	{
		# Indent _L_usage_args_list and _L_uasge_args_help properly
		local _L_usage_args=""  # holds positional arguments usage string
		_L_argparse_print_help_indenter -v _L_usage_args _L_usage_args_list _L_usage_args_help
	}
	{
		# print usage
		if [[ -n "${_L_mainsettings["usage"]:-}" ]]; then
			_L_usage=${_L_mainsettings["usage"]}
		fi
		echo "$_L_usage"
		if ((!_L_short)); then
			local _L_help=""
			_L_help+="${_L_mainsettings[description]+$'\n'${_L_mainsettings[description]%%$'\n'}$'\n'}"
			_L_help+="${_L_usage_args:+$'\npositional arguments:\n'${_L_usage_args%%$'\n'}$'\n'}"
			_L_help+="${_L_usage_options:+$'\noptions:\n'${_L_usage_options%%$'\n'}$'\n'}"
			_L_help+="${_L_mainsettings[epilog]:+$'\n'${_L_mainsettings[epilog]%%$'\n'}}"
			echo "${_L_help%%$'\n'}"
		fi
	}
}

# shellcheck disable=2120
# @description Print usage.
L_argparse_print_usage() {
	L_argparse_print_help --short "$@"
}

# @description Split '-o --option k=v' options into an associative array.
# Additional used parameters in addition to
# @arg $1 argparser
# @arg $2 index into argparser. Index 0 is the ArgumentParser class definitions, rest are arguments.
# @arg $3 --
# @arg $@ arguments to parse
# @set argparser[index]
# @env _L_parser
# @see _L_argparse_init
# @see _L_argparse_add_argument
_L_argparse_split() {
	{
		if [[ $1 != _L_parser ]]; then declare -n _L_parser="$1"; fi
		local _L_index
		_L_index=$2
		L_assert2 "" test "$3" = --
		shift 3
	}
	{
		local _L_allowed
		if ((_L_index == 0)); then
			_L_allowed=(prog usage description epilog formatter add_help allow_abbrev)
		else
			_L_allowed=(action nargs const default type choices required help metavar dest deprecated validator completor)
		fi
	}
	{
		# parse args
		declare -A _L_optspec=()
		local _L_options=()
		while (($#)); do
			case "$1" in
			-- | ::)
				L_fatal "error: encountered: $1"
				;;
			*' '*=*)
				L_fatal "kv option may not contain a space: ${1@Q}"
				;;
			*=*)
				local _L_opt
				_L_opt=${1%%=*}
				L_assert2 "invalid kv option: $_L_opt" L_args_contain "$_L_opt" "${_L_allowed[@]}"
				_L_optspec["$_L_opt"]=${1#*=}
				;;
			*' '*)
				L_fatal "argument may not contain space: ${1@Q}"
				;;
			[-+]?)
				_L_options+=("$1")
				_L_optspec["options"]+=" $1 "
				: "${_L_optspec["dest"]:=${1#[-+]}}"
				: "${_L_optspec["mainoption"]:=$1}"
				;;
			[-+][-+]?*)
				_L_options+=("$1")
				_L_optspec["options"]+=" $1 "
				: "${_L_optspec["dest"]:=${1##[-+][-+]}}"
				: "${_L_optspec["mainoption"]:=$1}"
				# If dest is set to short option, prefer long option.
				if ((${#_L_optspec["dest"]} <= 1)); then
					_L_optspec["dest"]=${1##[-+][-+]}
					_L_optspec["mainoption"]=$1
				fi
				;;
			*)
				_L_optspec["dest"]=$1
				;;
			esac
			shift
		done
	}
	if ((_L_index)); then
		{
			L_assert2 "$(declare -p _L_optspec)" L_var_is_set _L_optspec[dest]
			# Convert - to _
			_L_optspec["dest"]=${_L_optspec["dest"]//[#@%!~^-]/_}
			# infer metavar from dest
			: "${_L_optspec["metavar"]:=${_L_optspec["dest"]}}"
		}
		{
			# set type
			local _L_type=${_L_optspec["type"]:-}
			if [[ -n "$_L_type" ]]; then
				# set validator for type
				# shellcheck disable=2016
				local -A _L_ARGPARSE_VALIDATORS=(
					["int"]='L_isinteger "$1"'
					["float"]='L_isfloat "$1"'
					["positive"]='L_isinteger "$1" && [[ "$1" > 0 ]]'
					["nonnegative"]='L_isinteger "$1" && [[ "$1" >= 0 ]]'
					["file"]='[[ -f "$1" ]]'
					["file_r"]='[[ -f "$1" && -r "$1" ]]'
					["file_w"]='[[ -f "$1" && -w "$1" ]]'
					["dir"]='[[ -d "$1" ]]'
					["dir_r"]='[[ -d "$1" && -x "$1" && -r "$1" ]]'
					["dir_w"]='[[ -d "$1" && -x "$1" && -w "$1" ]]'
				)
				local _L_type_validator=${_L_ARGPARSE_VALIDATORS["$_L_type"]:-}
				if [[ -n "$_L_type_validator" ]]; then
					_L_optspec["validator"]=$_L_type_validator
				else
					L_fatal "invalid type for option: $(declare -p _L_optspec)"
				fi
				# set completion for type
				local -A _L_ARGPARSE_COMPLETORS=(
					["file"]="filenames"
					["file_r"]="filenames"
					["file_w"]="filenames"
					["dir"]="dirnames"
					["dir_r"]="dirnames"
					["dir_w"]="dirnames"
				)
				: "${_L_optspec["completor"]:=${_L_ARGPARSE_COMPLETORS["$_L_type"]:-}}"
			fi
		}
		{
			# apply defaults depending on action
			case "${_L_optspec["action"]:=store}" in
			store)
				: "${_L_optspec["nargs"]:=1}"
				;;
			store_const)
				_L_argparse_optspec_validate_value "${_L_optspec["const"]}"
				;;
			store_true)
				_L_optspec["default"]=false
				_L_optspec["const"]=true
				;;
			store_false)
				_L_optspec["default"]=true
				_L_optspec["const"]=false
				;;
			store_0)
				_L_optspec["default"]=1
				_L_optspec["const"]=0
				;;
			store_1)
				_L_optspec["default"]=0
				_L_optspec["const"]=1
				;;
			store_1null)
				_L_optspec["default"]=
				_L_optspec["const"]=1
				;;
			append)
				_L_optspec["isarray"]=1
				: "${_L_optspec["nargs"]:=1}"
				;;
			append_const)
				_L_argparse_optspec_validate_value "${_L_optspec["const"]}"
				_L_optspec["isarray"]=1
				;;
			count) ;;
			eval:*) ;;
			*)
				L_fatal "invalid action: $(declare -p _L_optspec)"
				;;
			esac
			: "${_L_optspec["nargs"]:=0}"
		}
	fi
	{
		# assign result
		if ((_L_index == 0)); then
			L_nestedasa_set "_L_parser[0]" = _L_optspec
		else
			local -a _L_tmp=()
			if ((${#_L_options[@]} != 0)); then
				L_abbreviation -v _L_tmp "option" "${!_L_parser[@]}"
				_L_optspec["index"]="option${#_L_tmp[@]}"
				#
				local _L_i
				for _L_i in "${_L_options[@]}"; do
					L_nestedasa_set "_L_parser[$_L_i]" = _L_optspec
				done
			else
				L_abbreviation -v _L_tmp "arg" "${!_L_parser[@]}"
				_L_optspec["index"]="arg${#_L_tmp[@]}"
			fi
			L_nestedasa_set "_L_parser[${_L_optspec["index"]}]" = _L_optspec
		fi
	}
}

# @description Initialize a argparser
# @arg $1 The parser variable
# @arg $2 Must be set to '--'
# @arg $@ Parameters
_L_argparse_init() {
	if [[ $1 != _L_parser ]]; then declare -n _L_parser="$1"; fi
	_L_parser=()
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1" 0 -- "${@:3}"
	{
		# add -h --help
		declare -A _L_optspec
		L_nestedasa_get _L_optspec = "_L_parser[0]"
		if L_is_true "${_L_optspec[add_help]:-true}"; then
			_L_argparse_add_argument "$1" -- -h --help \
				help="show this help and exit" \
				action=eval:'L_argparse_print_help;exit 0'
		fi
	}
}

# @description Add an argument to parser
# @arg $1 parser
# @arg $2 --
# @arg $@ parameters
_L_argparse_add_argument() {
	if [[ $1 != _L_parser ]]; then declare -n _L_parser="$1"; fi
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1" "${#_L_parser[@]}" -- "${@:3}"
}

# @description
# @env _L_parser
# @arg $1 variable to set with optspec
# @arg $2 short option ex. -a
_L_argparse_parser_get_short_option() {
	L_asa_has _L_parser "$2" && L_nestedasa_get "$1" = "_L_parser[$2]"
}

# @description
# @env _L_parser
# @arg $1 variable to set with optspec
# @arg $2 long option ex. --option
_L_argparse_parser_get_long_option() {
	if L_asa_has _L_parser "$2"; then
		L_nestedasa_get "$1" = "_L_parser[$2]"
	elif L_is_true "${_L_mainsettings["allow_abbrev"]:-true}"; then
		local _L_abbrev_matches=()
		L_abbreviation -v _L_abbrev_matches "$2" "${!_L_parser[@]}"
		if (( ${#_L_abbrev_matches[@]} == 1 )); then
			L_nestedasa_get "$1" = "_L_parser[${_L_abbrev_matches[0]}]"
		elif (( ${#_L_abbrev_matches[@]} > 1 )); then
			L_argparse_fatal "ambiguous option: $2 could match ${_L_abbrev_matches[*]}"
		else
			L_argparse_fatal "unrecognized argument: $1"
		fi
	else
		L_argparse_fatal "unrecognized argument: $1"
	fi
}

# @description Iterate over all option optspec.
# @env _L_parser
# @arg $1 index nameref, should be initialized at 1
# @arg $2 settings nameref
_L_argparse_parser_next_option() {
	if [[ "$1" != _L_i ]]; then declare -n _L_i=$1; fi
	if ! L_asa_has _L_parser "option$_L_i"; then
		return 1
	fi
	L_nestedasa_get "$2" = "_L_parser[option$((_L_i++))]"
}

# @description Iterate over all arguments optspec.
# @env _L_parser
# @arg $1 index nameref, should be initialized at 1
# @arg $2 settings nameref
_L_argparse_parser_next_argument() {
	if [[ "$1" != _L_i ]]; then declare -n _L_i=$1; fi
	if ! L_asa_has _L_parser "arg$_L_i"; then
		return 1
	fi
	L_nestedasa_get "$2" = "_L_parser[arg$((_L_i++))]"
}

# @env _L_optspec
_L_argparse_optspec_is_option() {
	[[ -n "${_L_optspec["options"]:-}" ]]
}

# @env _L_optspec
_L_argparse_optspec_is_argument() {
	[[ -z "${_L_optspec["options"]:-}" ]]
}

# @env _L_optspec
# @arg $1 value to assign to option
# @env _L_in_complete
_L_argparse_optspec_validate_value() {
	if ((${_L_in_complete:-0})); then
		return
	fi
	local _L_validator=${_L_optspec["validator"]:-}
	if [[ -n "$_L_validator" ]]; then
		local arg="$1"
		if ! eval "$_L_validator"; then
			local _L_type=${_L_optspec["type"]:-}
			if [[ -n "$_L_type" ]]; then
				L_argparse_fatal "argument ${_L_optspec["metavar"]}: invalid ${_L_type} value: ${1@Q}"
			else
				L_argparse_fatal "argument ${_L_optspec["metavar"]}: invalid value: ${1@Q}, validator: ${_L_validator@Q}"
			fi
		fi
	fi
}

# @description append array value to _L_optspec[dest]
# @arg $@ arguments to append
# @env _L_optspec
_L_argparse_optspec_assign_array() {
	{
		# validate
		local _L_i
		for _L_i in "$@"; do
			_L_argparse_optspec_validate_value "$_L_i"
		done
	}
	{
		# assign
		local _L_dest=${_L_optspec["dest"]}
		if [[ $_L_dest == *[* ]]; then
			printf -v "$_L_dest" "%q " "$@"
		else
			declare -n _L_nameref_tmp=$_L_dest
			_L_nameref_tmp+=("$@")
		fi
	}
}

# @description assign value to _L_optspec[dest] or execute the action specified by _L_optspec
# @env _L_optspec
# @env _L_assigned_options
# @env _L_in_complete
# @arg $@ arguments to store
_L_argparse_optspec_execute_action() {
	_L_assigned_options+=("${_L_optspec["index"]}")
	local _L_dest=${_L_optspec["dest"]}
	case ${_L_optspec["action"]:-store} in
	store)
		if ((${_L_optspec[nargs]:-1} == 1)); then
			_L_argparse_optspec_validate_value "$1"
			printf -v "$_L_dest" "%s" "$1"
			# echo printf -v "$_L_dest" "%s" "$1" >/dev/tty
		else
			_L_argparse_optspec_assign_array "$@"
		fi
		;;
	store_const | store_true | store_false | store_1 | store_0)
		printf -v "$_L_dest" "%s" "${_L_optspec["const"]}"
		;;
	append)
		_L_argparse_optspec_assign_array "$@"
		;;
	append_const)
		_L_argparse_optspec_assign_array "${_L_optspec["const"]}"
		;;
	count)
		# shellcheck disable=2004
		printf -v "$_L_dest" "%d" "$(($_L_dest+1))"
		;;
	eval:*)
		eval "${_L_optspec["action"]#"eval:"}"
		;;
	*)
		L_fatal "invalid action: $(declare -p _L_optspec)"
		;;
	esac
}

# @description Generate completions for given element.
# @stdout first line is the type
# if the type is plain, the second line contains the value to complete.
# @arg $1 incomplete
# @env _L_optspec
# @env _L_parser
# @env _L_in_complete
_L_argparse_optspec_gen_completion() {
	if ((!_L_in_complete)); then
		return
	fi
	echo "# completion ${1@Q} for $(declare -p _L_optspec)"
	local _L_completor=${_L_optspec["completor"]:-}
	case "$_L_completor" in
	"")
		if L_asa_has _L_optspec choices; then
			declare -a choices="(${_L_optspec["choices"]})"
			printf "plain\n""%s\n" "${choices[@]}"
			exit
		fi
		;;
	bashdefault|default|dirnames|filenames|noquote|nosort|nospace|plusdirs)
		printf "%s\n" "$_L_completor"
		exit
		;;
	*)
		eval "${_L_completor}"
		exit
		;;
	esac
	printf "default\n"
	exit
}

# @description The bash completion function
# @example
#    complete -F _L_argparse_bash_completor command
_L_argparse_bash_completor() {
	local IFS= response line type value
	response=$("$1" --L_argparse_get_completion "${COMP_WORDS[@]::COMP_CWORD}")
	while IFS= read -r type; do
		case "$type" in
			bashdefault|default|dirname|filenames|noquote|nosort|nospace|plusdirs)
				compoopt -o "$type"
				;;
			plain)
				if IFS= read -r value; then
					COMPREPLY+=("$value")
				fi
				;;
		esac
	done <<<"$response"
}

# @description Handle completion arguments
# @set _L_in_complete
_L_argparse_parse_completion_args() {
	case "${1:-}" in
	--L_argparse_get_completion)
		_L_in_complete=1
		shift
		;;
	--L_argparse_bash_completor)
		declare -f _L_argparse_bash_completor
		echo "complete -F _L_argparse_bash_completor $L_NAME"
		exit
		;;
	--L_argparse_print_completion)
		cat <<EOF
To install bash completion, add the following to startup scripts:
    eval "\$($L_NAME --L_argparse_bash_completor)"
EOF
		exit
		;;
	esac
}

# @description assign defaults to all options
_L_argparse_parse_args_set_defaults() {
	local _L_i=0
	local _L_j=0
	local -A _L_optspec
	while
		_L_argparse_parser_next_option _L_i _L_optspec ||
		_L_argparse_parser_next_argument _L_j _L_optspec
	do
		if L_var_is_set _L_optspec["default"]; then
			if ((${_L_optspec["isarray"]:-0})); then
				declare -a _L_tmp="(${_L_optspec["default"]})"
				_L_argparse_optspec_assign_array "${_L_tmp[@]}"
			else
				printf -v "${_L_optspec["dest"]}" "%s" "${_L_optspec["default"]}"
			fi
		fi
	done
}

# @description parse long option
# @set _L_used_args
# @arg $1 long option to parse
# @arg $@ further arguments on command line
_L_argparse_parse_args_long_option() {
	# Parse long option `--rcfile file --help`
	local _L_opt=$1 _L_values=()
	shift
	if [[ "$_L_opt" == *=* ]]; then
		_L_values+=("${_L_opt#*=}")
		_L_opt=${_L_opt%%=*}
	fi
	local -A _L_optspec
	if ! _L_argparse_parser_get_long_option _L_optspec "$_L_opt"; then
		L_argparse_fatal "unrecognized argument: $1"
	fi
	local _L_nargs=${_L_optspec["nargs"]}
	case "$_L_nargs" in
	0)
		if [[ "$_L_opt" == *=* ]]; then
			L_argparse_fatal "argument $_L_opt: ignored explicit argument ${_L_value@Q}"
		fi
		;;
	[0-9]*)
		(( _L_used_args += _L_nargs - ${#_L_values[@]} ))
		while ((${#_L_values[@]} < _L_nargs)); do
			if (($# == 0)); then
				l_argparse_fatal "argument $_L_opt: expected ${_L_optspec["nargs"]} arguments"
			fi
			_L_values+=("$1")
			shift
		done
		;;
	*)
		L_argparse_fatal "invalid nargs specification of $(declare -p _L_optspec)"
		;;
	esac
	_L_argparse_optspec_execute_action "${_L_values[@]}"
}

# @description parse short option
# @set _L_used_args
# @arg $1 long option to parse
# @arg $@ further arguments on command line
_L_argparse_parse_args_short_option() {
	# Parse short option -euopipefail
	local _L_opt _L_i
	_L_opt=${1#[-+]}
	for ((_L_i = 0; _L_i < ${#_L_opt}; ++_L_i)); do
		local _L_c
		_L_c=${_L_opt:_L_i:1}
		local -A _L_optspec
		if ! _L_argparse_parser_get_short_option _L_optspec "-$_L_c"; then
			L_argparse_fatal "unrecognized arguments: -$_L_c"
		fi
		L_assert2 "-$_L_c $(declare -p _L_optspec)" L_var_is_set _L_optspec[nargs]
		local _L_values=() _L_nargs=${_L_optspec["nargs"]}
		case "$_L_nargs" in
		0) ;;
		[0-9]*)
			local _L_tmp
			_L_tmp=${_L_opt:_L_i+1}
			if [[ -n "$_L_tmp" ]]; then
				_L_values+=("$_L_tmp")
			fi
			shift
			(( _L_used_args += _L_nargs - ${#_L_values[@]} ))
			while ((${#_L_values[@]} < _L_nargs)); do
				if (($# == 0)); then
					l_argparse_fatal "argument -$_L_c: expected ${_L_optspec["nargs"]} arguments"
				fi
				_L_values+=("$1")
				shift
			done
			;;
		*)
			L_argparse_fatal "invalid nargs specification of $(declare -p _L_optspec)"
			;;
		esac
		_L_argparse_optspec_execute_action "${_L_values[@]}"
		if ((_L_nargs)); then
			break
		fi
	done
}

# @description Parse the arguments with the given parser.
# @env _L_parser
# @arg $1 argparser nameref
# @arg $2 --
# @arg $@ arguments
_L_argparse_parse_args() {
	if [[ "$1" != "_L_parser" ]]; then declare -n _L_parser=$1; fi
	L_assert2 "" test "$2" = --
	shift 2
	#
	{
		# handle bash completion
		local _L_in_complete=0
		_L_argparse_parse_completion_args "$@"
		if ((_L_in_complete)); then shift; fi
	}
	{
		# Extract mainsettings
		local -A _L_mainsettings="${_L_parser[0]}"
		# List of assigned metavars, used for checking required ones.
		local _L_assigned_options=()
	}
	{
		_L_argparse_parse_args_set_defaults
	}
	{
		# Parse options on command line.
		local _L_opt _L_value _L_dest _L_c _L_onlyargs=0
		local _L_arg_assigned=0  # the number of arguments assigned currently to _L_optspec
		local _L_arg_i=0  # position in _L_argparse_parser_next_optspec when itering over arguments
		local _L_assigned_options=()
		local -A _L_optspec=()
		while (($#)); do
			if ((!_L_onlyargs)); then
				case "$1" in
				--) shift; _L_onlyargs=1; continue; ;;
				--?*)
					local _L_used_args=1
					_L_argparse_parse_args_long_option "$@"
					shift "$_L_used_args"
					continue
					;;
				-?*)
					local _L_used_args=1
					_L_argparse_parse_args_short_option "$@"
					shift "$_L_used_args"
					continue
					;;
				esac
			fi
			{
				# Parse positional arguments.
				if L_asa_is_empty _L_optspec; then
					_L_arg_assigned=0
					if ! _L_argparse_parser_next_argument _L_arg_i _L_optspec; then
						L_argparse_fatal "unrecognized argument: $1"
					fi
				fi
				if (($# == 1)); then
					_L_argparse_optspec_gen_completion "$1"
				fi
				local _L_dest _L_nargs
				_L_dest=${_L_optspec["dest"]}
				_L_nargs=${_L_optspec["nargs"]:-1}
				case "$_L_nargs" in
				[0-9]*)
					_L_argparse_optspec_execute_action "$1"
					if ((_L_arg_assigned+1 == _L_nargs)); then
						_L_optspec=()
					fi
					;;
				"?")
					_L_argparse_optspec_validate_value "$1"
					printf -v "$_L_dest" "%s" "$1"
					_L_optspec=()
					;;
				"[rR]*")  # remainder
					_L_onlyargs=1
					_L_argparse_optspec_assign_array "$1"
					;;
				"*" | "+")
					_L_argparse_optspec_assign_array "$1"
					;;
				*)
					L_argparse_fatal "Invalid nargs: $(decalre -p _L_optspec)"
					;;
				esac
				((++_L_arg_assigned))
			}
			shift
		done
		# Check if all required arguments have value.
		local _L_required_arguments=()
		while
			if L_asa_is_empty _L_optspec; then
				_L_arg_assigned=0
				_L_argparse_parser_next_argument _L_arg_i _L_optspec
			fi
		do
			case "${_L_optspec["nargs"]:-1}" in
				[0-9]*)
					if ((_L_arg_assigned != _L_optspec["nargs"])); then
						_L_required_arguments+=("${_L_optspec["index"]}")
					fi
					;;
				"+")
					if ((_L_arg_assigned == 0)); then
						_L_required_arguments+=("${_L_optspec["index"]}")
					fi
			esac
			_L_optspec=()
			_L_arg_assigned=0
		done
	}
	{
		# Check if all required options have value
		local _L_required_options=()
		local _L_i=0
		local -A _L_optspec
		while _L_argparse_parser_next_option _L_i _L_optspec; do
			if L_is_true "${_L_optspec["required"]:-}"; then
				if ! L_args_contain "${_L_optspec["index"]}" "${_L_assigned_options[@]}"; then
					_L_required_options+=("${_L_optspec["index"]}")
				fi
			fi
		done
		_L_required_options+=("${_L_required_arguments[@]}")
		# Check if required options are set
		if ((!_L_in_complete && ${#_L_required_options[@]})); then
			local _L_required_options_str="" _L_i
			for _L_i in "${_L_required_options[@]}"; do
				local -A _L_optspec
				L_nestedasa_get _L_optspec = "_L_parser[$_L_i]"
				_L_required_options_str+=" ${_L_optspec[mainoption]:-${_L_optspec[metavar]}}"
			done
			L_argparse_fatal "the following arguments are required:${_L_required_options_str}"
		fi
	}
}

# @description Parse command line aruments according to specification.
# This command takes groups of command line arguments separated by `::`  with sentinel `::::` .
# The first group of arguments are arguments to `_L_argparse_init` .
# The next group of arguments are arguments to `_L_argparse_add_argument` .
# The last group of arguments are command line arguments passed to `_L_argparse_parse_args`.
# Note: the last separator `::::` is different to make it more clear and restrict parsing better.
L_argparse() {
	local -A _L_parser=()
	local -a _L_args=()
	while (($#)); do
		if [[ "$1" == "::" || "$1" == "::::" || "$1" == "--" || "$1" == "----" ]]; then
			# echo "AA ${_L_args[@]} ${_L_parser[@]}"
			if ((${#_L_parser[@]} == 0)); then
				_L_argparse_init _L_parser -- "${_L_args[@]}"
			else
				_L_argparse_add_argument _L_parser -- "${_L_args[@]}"
			fi
			_L_args=()
			if [[ "$1" == "::::" || "$1" == "----" ]]; then
				break
			fi
		else
			_L_args+=("$1")
		fi
		shift
	done
	L_assert2 "'::::' argument missing to ${FUNCNAME[0]}" test "$#" -ge 1
	shift 1
	_L_argparse_parse_args _L_parser -- "$@"
}

_L_test_z_argparse1() {
	local ret tmp option storetrue storefalse store0 store1 storeconst append
	{
		L_log "define parser"
		declare -A parser=()
		_L_argparse_init parser -- prog=prog
		_L_argparse_add_argument parser -- -t --storetrue action=store_true
		_L_argparse_add_argument parser -- -f --storefalse action=store_false
		_L_argparse_add_argument parser -- -0 --store0 action=store_0
		_L_argparse_add_argument parser -- -1 --store1 action=store_1
		_L_argparse_add_argument parser -- -c --storeconst action=store_const const=yes default=no
		_L_argparse_add_argument parser -- -a --append action=append
	}
	{
		L_log "check defaults"
		_L_argparse_parse_args parser --
		L_unittest_vareq storetrue false
		L_unittest_vareq storefalse true
		L_unittest_vareq store0 1
		L_unittest_vareq store1 0
		L_unittest_vareq storeconst no
		L_unittest_eq "${append[*]}" ''
	}
	{
		append=()
		L_log "check single"
		_L_argparse_parse_args parser -- -tf01ca1 -a2 -a 3
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
		_L_argparse_parse_args parser -- --storetrue --storefalse --store0 --store1 --storeconst \
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
		L_unittest_failure_capture tmp -- L_argparse prog=prog :: arg nargs="+" ::::
		L_unittest_contains "$tmp" "required"
		#
		local arg=()
		L_argparse prog=prog :: arg nargs="+" :::: 1
		L_unittest_eq "${arg[*]}" '1'
		#
		local arg=()
		L_argparse prog=prog :: arg nargs="+" :::: 1 $'2\n3' $'4"\'5'
		L_unittest_eq "${arg[*]}" $'1 2\n3 4"\'5'
	}
	{
		L_log "check help"
		L_unittest_failure_capture tmp -- L_argparse prog="ProgramName" :: arg nargs=2 ::::
		L_unittest_contains "$tmp" "usage: ProgramName"
		L_unittest_contains "$tmp" " arg arg"
	}
	{
		L_log "only short opt"
		local o=
		L_argparse prog="ProgramName" :: -o :::: -o val
		L_unittest_eq "$o" val
	}
	{
		L_log "abbrev"
		local option verbose
		L_argparse :: --option action=store_1 :: --verbose action=store_1 :::: --o --v --opt
		L_unittest_eq "$option" 1
		L_unittest_eq "$verbose" 1
		#
		L_unittest_failure_capture tmp L_argparse :: --option action=store_1 :: --opverbose action=store_1 :::: --op
		L_unittest_contains "$tmp" "ambiguous option: --op"
	}
	{
		L_log "count"
		local verbose=
		L_argparse :: -v --verbose action=count :::: -v -v -v -v
		L_unittest_eq "$verbose" 4
		local verbose=
		L_argparse :: -v --verbose action=count :::: -v -v
		L_unittest_eq "$verbose" 2
		local verbose=
		L_argparse :: -v --verbose action=count ::::
		L_unittest_eq "$verbose" ""
		local verbose=
		L_argparse :: -v --verbose action=count default=0 ::::
		L_unittest_eq "$verbose" "0"
	}
	{
		L_log "type"
		local tmp arg
		L_unittest_failure_capture tmp L_argparse :: arg type=int :::: a
		L_unittest_contains "$tmp" "invalid"
	}
	{
		L_log "usage"
		tmp=$(L_argparse prog=prog :: bar nargs=3 help="This is a bar argument" :::: --help 2>&1)
	}
	{
		L_log "required"
		L_unittest_failure_capture tmp L_argparse prog=prog :: --option required=true ::::
		L_unittest_contains "$tmp" "the following arguments are required: --option"
		L_unittest_failure_capture tmp L_argparse prog=prog :: --option required=true :: --other required=true :: bar ::::
		L_unittest_contains "$tmp" "the following arguments are required: --option --other bar"
	}
}

_L_test_z_argparse2() {
	{
		L_log "two args"
		local ret out arg1 arg2
		L_argparse :: arg1 :: arg2 :::: a1 b1
		L_unittest_eq "$arg1" a1
		L_unittest_eq "$arg2" b1
		L_argparse :: arg1 nargs=1 :: arg2 nargs='?' default=def :::: a2
		L_unittest_eq "$arg1" a2
		L_unittest_eq "$arg2" "def"
		L_argparse :: arg1 nargs=1 :: arg2 nargs='*' :::: a3
		L_unittest_eq "$arg1" a3
		L_unittest_eq "$arg2" "def"
		#
		L_unittest_failure_capture out -- L_argparse :: arg1 :: arg2 :::: a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse :: arg1 :: arg2 :::: a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse :: arg1 :: arg2 nargs='+' :::: a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse :: arg1 nargs=1 :: arg2 nargs='*' ::::
		L_unittest_contains "$out" "are required: arg1"
		L_unittest_failure_capture out -- L_argparse :: arg1 nargs=1 :: arg2 nargs='+' ::::
		L_unittest_contains "$out" "are required: arg1 arg2"
	}
	{
		scope() {
			L_log "completion"
			parser() { L_argparse prog=prog :: --option choices="aa ab ac ad" :::: "$@"; }
			local COMP_WORDS
			COMP_WORDS=(prog --option a)
			parser --option a
		}
		scope
	}
	{
		L_log "complete1"
		one() {
			L_argparse \
				:: option1 choices='AAAA BBBB CCCC' \
				:: option2 choices='DDDD EEEE FFFF' \
				:::: "$@"
		}
	}
}

# ]]]
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
	L_list_functions_with_prefix "$L_prefix"
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
			if L_cmd_exists column && column -V 2>/dev/null | grep -q util-linux; then
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
		COMPREPLY=("$(compgen -W "${cmds[*]}" -- "${COMP_WORDS[1]}")")
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
	L_unittest_run -P _L_test_ "$@"
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
				exit
			else
				return
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
	local _L_mode="" _L_sourced=0 OPTARG OPTING _L_opt
	while getopts sLh-: _L_opt; do
		case $_L_opt in
		s) _L_sourced=1 ;;
		L) _L_lib_drop_L_prefix ;;
		h) _L_mode=help ;;
		-) _L_mode=help; break ;;
		?) exit 1 ;;
		*) _L_lib_fatal "$_L_lib_name: Internal error when parsing arguments: $_L_opt" ;;
		esac
		shift
	done
	shift "$((OPTIND-1))"
	if (($#)); then
		: "${_L_mode:=$1}"
		shift 1
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
	--help | help) _L_lib_usage; exit 0; ;;
	test)
		set -euo pipefail
		L_trap_err_enable
		trap 'L_trap_err $?' EXIT
		_L_lib_run_tests "$@"
		;;
	cmd) _L_lib_main_cmd ;;
	*) _L_lib_fatal "unknown command: $_L_mode" ;;
	esac
}

# ]]]
# main [[[

fi  # L_LIB_VERSION

# https://stackoverflow.com/a/79201438/9072753
# https://stackoverflow.com/questions/61103034/avoid-command-line-arguments-propagation-when-sourcing-bash-script/73791073#73791073
if [[ "${BASH_ARGV[0]}" == "${BASH_SOURCE[0]}" ]]; then
	_L_lib_main -s
else
	_L_lib_main "$@"
fi

# ]]]