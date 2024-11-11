#!/usr/bin/env bash
# shellcheck disable=2034,2178,2016,2128,2329
# vim: foldmethod=marker foldmarker=[[[,]]]
# Globals [[[
# @section globals
# @description some global variables

shopt -s extglob
L_LIB_VERSION=1.0
# @description The basename part of $0
L_NAME=${0##*/}
# @description The directory part of $0
L_DIR=${0%/*}

# ]]]
# Colors [[[
# @section colors
# @description colors

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

# @description
L_color_on() {
	local i
	for i in ${!L_COLOR_@}; do
		eval "${i//COLOR_/}=\$$i"
	done
}

# @description
L_color_off() {
	local i
	for i in ${!L_COLOR_@}; do
		eval "${i//COLOR_/}="
	done
}

# @description Detect if colors should be used on the terminal.
L_color_use() {
	if [[ ! -v NO_COLOR && "${TERM:-dumb}" != "dumb" && -t 1 ]]; then
		L_color_on
	else
		L_color_off
	fi
}

L_color_use

# ]]]
# Color constants [[[
# @section color constants
# @description color constants. Prefer to use colors above for color usage detection.

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
readonly L_ANSI_CLEAR_SCREEN_UNTIL_END=$'\E[0J'
readonly L_ANSI_CLEAR_SCREEN_UNTIL_BEGINNING=$'\E[1J'
readonly L_ANSI_CLEAR_SCREEN=$'\E[2J'
readonly L_ANSI_CLEAR_LINE_UNTIL_END=$'\E[0K'
readonly L_ANSI_CLEAR_LINE_UNTIL_BEGINNING=$'\E[1K'
readonly L_ANSI_CLEAR_LINE=$'\E[2K'
readonly L_ANSI_SAVE_POSITION=$'\E7'
readonly L_ANSI_RESTORE_POSITION=$'\E8'

# @description Move cursor $1 lines above, output second argument, then move cursor $1 lines down.
L_ansi_print_on_line_above() {
	if ((!$1)); then
		printf "\r\E[2K%s" "${*:2}"
	else
		printf "\E[%dA\r\E[2K%s\E[%dB\r" "$1" "${*:2}" "$1"
	fi
}

L_ansi_8bit_fg() { printf '\E[37;5;%dm' "$@"; }
L_ansi_8bit_bg() { printf '\E[47;5;%dm' "$@"; }
L_ansi_8bit_fg_rgb() { printf '\E[37;5;%dm' "$((16+36*$1+6*$2+$3))"; }
L_ansi_8bit_bg_rgb() { printf '\E[47;5;%dm' "$((16+36*$1+6*$2+$3))"; }
L_ansi_24bit_fg() { printf '\E[38;2;%d;%d;%dm' "$@"; }
L_ansi_24bit_bg() { printf '\E[48;2;%d;%d;%dm' "$@"; }

# ]]]
# Log [[[
# @section log
# @description logging library

readonly L_LOGLEVEL_CRITICAL=60
readonly L_LOGLEVEL_ERROR=50
readonly L_LOGLEVEL_WARNING=40
readonly L_LOGLEVEL_NOTICE=30
readonly L_LOGLEVEL_INFO=20
readonly L_LOGLEVEL_DEBUG=10

L_LOGLEVEL_NAMES=(
	[L_LOGLEVEL_CRITICAL]="critical"
	[L_LOGLEVEL_ERROR]="error"
	[L_LOGLEVEL_WARNING]="warning"
	[L_LOGLEVEL_NOTICE]="notice"
	[L_LOGLEVEL_INFO]="info"
	[L_LOGLEVEL_DEBUG]="debug"
)
L_LOGLEVEL_COLORS=(
	[L_LOGLEVEL_CRITICAL]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_ERROR]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_WARNING]="${L_BOLD}${L_YELLOW}"
	[L_LOGLEVEL_NOTICE]="${L_BOLD}${L_CYAN}"
	[L_LOGLEVEL_INFO]="${L_BOLD}"
	[L_LOGLEVEL_DEBUG]="${L_LIGHT_GRAY}"
)

# @description (int) current log level
L_log_level=$L_LOGLEVEL_INFO

# @description used to track nesting when logging
L_logrecord_stacklevel=1
# @description current log line log level
L_logrecord_loglevel=0
# @description current log line to ouptut
L_logrecord_line=""

# @description increase stacklevel of logging information
L_log_stack_inc() { ((++L_logrecord_stacklevel)); }
# @description decrease stacklevel of logging information
L_log_stack_dec() { ((--L_logrecord_stacklevel)); }

# @description
# @arg $1 str variable name
# @arg $2 str loglevel
L_log_level_str_to_int() {
	local i
	if [[ ! "$2" == [0-9]* ]]; then
		for i in "${!L_LOGLEVEL_@}"; do
			if [[ "${2^^}" == "$i" || "${2^^}" == "${i//L_LOGLEVEL_}" ]]; then
				printf -v "$1" "%s" "${!i}"
				return
			fi
		done
	fi
	printf -v "$1" "%d" "$2"
}

# @description
L_log_setLevel() {
	L_log_level=$1
}

# @description
L_log_is_enabled_for() {
	L_log_level_str_to_int L_logrecord_loglevel "$1"
	# echo "$L_logrecord_loglevel $L_log_level"
	((L_log_level <= L_logrecord_loglevel))
}

L_log_format() {
	L_log_format_default "$@"
}

L_log_format_default() {
	printf -v L_logrecord_line "%s%s:%s:%d:%s%s" \
		"${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}" \
		"${L_NAME}" \
		"${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-}" \
		"${BASH_LINENO[L_logrecord_stacklevel]}" \
		"$*" \
		"${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:+$L_COLORRESET}"
}

L_log_format_long() {
	printf -v L_logrecord_line "%s""%(%Y%m%dT%H%M%S)s: %s:%s:%d: %s %s""%s" \
		"${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:-}" \
		-1 \
		"${L_NAME}" \
		"${FUNCNAME[L_logrecord_stacklevel]}" \
		"${BASH_LINENO[L_logrecord_stacklevel]}" \
		"${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-}" \
		"$*" \
		"${L_LOGLEVEL_COLORS[L_logrecord_loglevel]:+$L_COLORRESET}"
}

# Output formatted line
L_log_output() {
	L_log_output_to_stderr
}

L_log_output_to_stderr() {
	printf "%s\n" "$L_logrecord_line" >&2
}

L_log_output_to_logger() {
	logger \
		--tag "$L_NAME" \
		--priority "local3.${L_LOGLEVEL_NAMES[L_logrecord_loglevel]:-notice}" \
		--skip-empty \
		-- "$L_logrecord_line"
}

# shellcheck disable=SC2140
# @description main logging entrypoint
# @option -s int Increment stacklevel by this much
# @option -l int|string loglevel to print log line as
# @arg $1 str logline
L_log() {
	local OPTARG OPTIND _L_opt
	L_logrecord_loglevel=$L_LOGLEVEL_INFO
	while getopts ":s:l:" _L_opt; do
		case "$_L_opt" in
			s) ((L_logrecord_stacklevel+=OPTARG)); ;;
			l) L_logrecord_loglevel=$OPTARG; ;;
			*) L_fatal "$_L_opt"; ;;
		esac
	done
	shift "$((OPTIND-1))"
	((++L_logrecord_stacklevel))
	if L_log_is_enabled_for "$L_logrecord_loglevel"; then
		L_log_format "$@"
		L_log_output
	fi
	L_logrecord_stacklevel=1
}

L_critical() { L_log_stack_inc; L_log -l "$L_LOGLEVEL_CRITICAL" "$@"; }
L_error()    { L_log_stack_inc; L_log -l "$L_LOGLEVEL_ERROR"    "$@"; }
L_warn()     { L_log_stack_inc; L_log -l "$L_LOGLEVEL_WARNING"  "$@"; }
L_warning()  { L_log_stack_inc; L_log -l "$L_LOGLEVEL_WARNING"  "$@"; }
L_notice()   { L_log_stack_inc; L_log -l "$L_LOGLEVEL_NOTICE"   "$@"; }
L_info()     { L_log_stack_inc; L_log -l "$L_LOGLEVEL_INFO"     "$@"; }
L_debug()    { L_log_stack_inc; L_log -l "$L_LOGLEVEL_DEBUG"    "$@"; }

# ]]]
# sort [[[
# @section sort
# @description sorting function

_L_sort_bash_in() {
	local _L_start=$1 _L_end=$2
	if ((_L_start < _L_end))
	then
		local _L_left=$((_L_start+1)) _L_right=$_L_end _L_pivot=${_L_array[_L_start]}
		while ((_L_left < _L_right))
		do
			if
				if ((_L_sort_numeric))
				then
					((_L_pivot > _L_array[_L_left]))
				else
					[[ "$_L_pivot" > "${_L_array[_L_left]}" ]]
				fi
			then
				(( _L_left++ ))
			elif
				if ((_L_sort_numeric))
				then
					((_L_pivot < _L_array[_L_right]))
				else
					[[ "$_L_pivot" < "${_L_array[_L_right]}" ]]
				fi
			then
				(( _L_right--, 1 ))
			else
				local _L_tmp=${_L_array[_L_left]}
				_L_array[_L_left]=${_L_array[_L_right]}
				_L_array[_L_right]=$_L_tmp
			fi
		done
		if
			if ((_L_sort_numeric))
			then
				((_L_array[_L_left] < _L_pivot))
			else
				[[ "${_L_array[_L_left]}" < "$_L_pivot" ]]
			fi
		then
			local _L_tmp=${_L_array[_L_left]}
			_L_array[_L_left]=${_L_array[_L_start]}
			_L_array[_L_start]=$_L_tmp
			(( _L_left--, 1 ))
		else
			(( _L_left--, 1 ))
			local _L_tmp=${_L_array[_L_left]}
			_L_array[_L_left]=${_L_array[_L_start]}
			_L_array[_L_start]=$_L_tmp
		fi
		_L_sort_bash_in "$_L_start" "$_L_left"
		_L_sort_bash_in "$_L_right" "$_L_end"
	fi
}


# @description quicksort an array in place in pure bash
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
	if [[ $1 != _L_array ]]; then declare -n _L_array=$1; fi
	_L_sort_bash_in 0 $((${#_L_array[@]}-1))
}

# @description sort an array
# If -z or --zero-terminated optino is passed, try to use zero separated stream
# @option * any options taken by sort command
# @arg $1 array nameref
L_sort() {
	if [[ "${*: -1}" != _L_array ]]; then declare -n _L_array=${*: -1}; fi
	if L_args_contain -z "$@" || L_args_contain --zero-terminated "$@"; then
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
	{
		L_log "Compare times of bash sort vs command sort"
		local arr=() i TIMEFORMAT
		for ((i=500;i;--i)); do arr[i]=$RANDOM; done
		local arr2=("${arr[@]}")
		TIMEFORMAT='L_sort   real=%lR user=%lU sys=%lS';
		time L_sort_bash -n arr2
		local arr3=("${arr[@]}")
		TIMEFORMAT='GNU sort real=%lR user=%lU sys=%lS';
		time L_sort -n arr3
		[[ "${arr2[*]}" == "${arr3[*]}" ]]
	}
}

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
# @example:
#    L_add() { _L_handle_v "$@"; }
#    _L_add_v() { _L_v="$(($1 + $2))"; }
_L_handle_v() {
	if [[ $1 == -v?* ]]; then
		set -- -v "${1#-v}" "${@:2}"
	fi
	if [[ $1 == -v ]]; then
		if [[ $2 != _L_v ]]; then local -n _L_v=$2; fi
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

# @description Output a string with the same quotating style as does bash in set -x
# @arg $@ arguments to quote
L_quote_setx() { local tmp; tmp=$({ set -x; : "$@"; } 2>&1); printf "%s\n" "${tmp:5}"; }

# @description Output a critical message and exit the script.
# @arg $@ L_log arguments
L_fatal() { L_log_stack_inc; L_critical "$@"; exit 2; }

# @description Eval the first argument - if it returns failure, then fatal.
# @arg $1 string to evaluate
# @arg $@ assertion message
# @example '[[ $var = 0 ]]' "Value of var is invalid"
L_assert() { if eval '!' "$1"; then L_print_traceback; L_fatal "assertion $1 failed: ${*:2}"; fi }

# @description Assert the command starting from second arguments returns success.
# @arg $1 str assertiong string description
# @arg $@ command to test
# @example L_assert2 'wrong number of arguments' test "$#" = 0
L_assert2() {
	if "${@:2}"; then
		:
	else
		L_print_traceback
		L_fatal "assertion ${*:2} failed${1:+: $1}"
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

# @description return true if current script sourced
L_is_sourced() { [[ "${BASH_SOURCE[0]}" != "$0" ]]; }

# @description return true if current script is not sourced
L_is_main() { [[ "${BASH_SOURCE[0]}" == "$0" ]]; }

# @description return true if running in bash shell
# Portable with POSIX shell.
L_is_in_bash() { [ -n "${BASH_VERSION:-}" ]; }

# @description return true if running in posix mode
L_in_posix_mode() { [[ :$SHELLOPTS: == *:posix:* ]]; }

# @description has declare -n var=$1
L_has_nameref() { L_version_cmp "$BASH_VERSION" -ge "4.2.46"; }
# @description has declare -A var=[a]=b)
L_has_associative_array() { L_version_cmp "$BASH_VERSION" -ge "4"; }
# @description has ${!prefix*} expansion
L_has_prefix_expansion() { L_version_cmp "$BASH_VERSION" -ge "2.4"; }
# @description has ${!var} expansion
L_has_indirect_expansion() { L_version_cmp "$BASH_VERSION" -ge "2.0"; }

# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_set() {
	eval "[[ -n \${$1+x} ]]"
}

# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is an array, nonzero otherwise
L_var_is_array() {
	[[ "$(declare -p "$1" 2>/dev/null)" == "declare -a"* ]]
}

# @description check if variable is an associative array
# @arg $1 variable nameref
L_var_is_associative() {
	[[ "$(declare -p "$1" 2>/dev/null)" == "declare -A"* ]]
}

# @description check if variable is readonly
# @arg $1 variable nameref
L_var_is_readonly() {
	( eval "$1=" ) 2>/dev/null
}

# @description Return 0 if the string happend to be something like false.
# @arg $1 str
L_is_false() {
	case "$1" in
	0*(0)) return 0; ;;
	[fF]) return 0; ;;
	[fF][aA][lL][sS][eE]) return 0; ;;
	[nN]) return 0; ;;
	[nN][oO]) return 0; ;;
	esac
	return 1
}

# @description Return 0 if the string happend to be something like true.
# @arg $1 str
L_is_true() {
	case "$1" in
	0*(0)) return 1; ;;
	[0-9]*([0-9])) return 0; ;;
	[tT]) return 0; ;;
	[tT][rR][uU][eE]) return 0; ;;
	[yY]) return 0; ;;
	[yY][eE][sS]) return 0; ;;
	esac
	return 1
}

# @description log a command and then execute it
# Is not affected by L_DRYRUN variable.
# @arg $@ command to run
L_logrun() {
	L_log "+ $*"
	"$@"
}

# @description set to 1 if L_run should not execute the function.
: "${L_DRYRUN:=0}"

# @description Executes a command by printing it first with a + on stderr
# @env L_DRYRUN
L_run_log() {
	local _L_tmp
	_L_tmp="$1" # loglevel
	shift
	local log="+"
	if L_is_true "${L_DRYRUN:-}"; then
		log="DRYRUN: +"
	fi
	log="$log$(printf " %q" "$@")"
	L_log "$_L_tmp" "$log"
	if ! L_is_true "${L_DRYRUN:-}"; then
		"$@"
	fi
}

# @description Executes a command by printing it first with a + on stderr
# @env L_DRYRUN
L_run() {
	L_run_log L_LOG_INFO "$@"
}

_L_list_functions_with_prefix_v() {
	_L_v=()
	for _L_i in $(compgen -A function); do
		if [[ $_L_i == "$1"* ]]; then
			_L_v+=("$_L_i")
		fi
	done
}

# @description list functions with prefix
# @option -v<var>
# @arg $1 prefix
L_list_functions_with_prefix() {
	_L_handle_v "$@"
}

L_kill_all_jobs() {
	local IFS='[]' j _
	while read -r _ j _; do
		kill "%$j"
	done <<<"$(jobs)"
}

L_sed_show_diff() {
	(
		file="${*: -1}"
		tmpf=$(mktemp)
		trap 'rm -f "$tmpf"' EXIT
		sed "$@" > "$tmpf"
		diff "$file" "$tmpf" ||:
		if [[ "${L_lib_SED_INPLACE:-}" = 'true' ]]; then
			mv "$tmpf" "$file"
		fi
	)
}

L_sed_inplace_show_diff() {
	(
		L_lib_SED_INPLACE=true
		L_sed_show_diff "$@"
	)
}

L_is_valid_variable_name() {
	[[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

L_str_is_print() {
	[[ "$*" =~ ^[[:print:]]*$ ]]
}

L_str_is_digit() {
	[[ "$*" =~ ^[0-9]+$ ]]
}

L_raise() {
	kill -s "$1" "$BASHPID"
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

_L_sudo_args_get() {
	declare -n ret=$1
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
	if [[ $1 != _L_array ]]; then declare -n _L_array=$1; fi
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
	local -n _L_array=$1
	shift
	local L_i _L_cmd=$*
	for ((L_i=${#_L_array[@]}; L_i; --L_i)); do
		set -- "${_L_array[L_i-1]}"
		if ! eval "$_L_cmd"; then
			unset '_L_array[L_i-1]'
		fi
	done
}

# shellcheck disable=1105,2094,2035
_L_max_v() {
	_L_v=$1
	shift
	while (($#)); do
		(( "$1" > _L_v ? _L_v = "$1" : 0, 1 ))
		shift
	done
}

# @description return max of arguments
# @option -v<var>
# @arg $@ int arguments
# @example L_max -v max 1 2 3 4
L_max() {
	_L_handle_v "$@"
}

# shellcheck disable=1105,2094,2035
_L_min_v() {
	_L_v=$1
	shift
	while (($#)); do
		(( "$1" < _L_v ? _L_v = "$1" : 0, 1 ))
		shift
	done
}

# @description return max of arguments
# @option -v<var>
# @arg $@ int arguments
# @example L_min -v min 1 2 3 4
L_min() {
	_L_handle_v "$@"
}

_L_capture_exit_v() {
	"$@" && _L_v=$? || _L_v=$?
}

# @description capture exit code of a command to a variable
# @option -v<var>
# @arg $@ command to execute
L_capture_exit() {
	_L_handle_v "$@"
}

_L_test_other() {
	{
		local max=-1
		L_max -v max 1 2 3 4
		L_unittest_eq "$max" 4
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
	local i s l tmp offset around=1
	L_color_use
	echo
	echo "${L_CYAN}Traceback from pid $BASHPID (most recent call last):${L_RESET}"
	offset=${1:-0}
	for ((i = ${#BASH_SOURCE[@]} - 1; i > offset; --i)); do
		s=${BASH_SOURCE[i]}
		l=${BASH_LINENO[i - 1]}
		printf "  File %s%q%s, line %s%d%s, in %s()\n" \
			"${L_CYAN}" "$s" "${L_RESET}" \
			"${L_BLUE}${L_BOLD}" "$l" "${L_RESET}" \
			"${FUNCNAME[i]}"
		# shellcheck disable=1004
		if
			tmp=$(awk \
				-v line="$l" \
				-v around="$around" \
				-v RESET="${L_RESET}" \
				-v RED="${L_RED}" \
				-v COLORLINE="${L_BLUE}${L_BOLD}" \
				'NR > line - around && NR < line + around {
					printf "%s%-5d%s%3s%s%s%s\n", \
						COLORLINE, NR, RESET, \
						(NR == line ? ">> " : ""), \
						(NR == line ? RED : ""), \
						$0, \
						(NR == line ? RESET : "")
				}' "$s" 2>/dev/null) &&
				[[ -n "$tmp" ]]
		then
			printf "%s\n" "$tmp"
		fi
	done
}

# @description Outputs Front-Mater formatted failures for functions not returning 0
# Use the following line after sourcing this file to set failure trap
#    trap 'failure "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR
# @see https://unix.stackexchange.com/questions/39623/trap-err-and-echoing-the-error-line
L_trap_err_failure() {
    local -n _lineno="LINENO"
    local -n _bash_lineno="BASH_LINENO"
    local _last_command="${2:-$BASH_COMMAND}"
    local _code="${1:-0}"

    ## Workaround for read EOF combo tripping traps
    if ! ((_code)); then
        return "${_code}"
    fi

    local _last_command_height
	_last_command_height="$(wc -l <<<"${_last_command}")"

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

    if [[ "${_last_command_height}" -gt '1' ]]; then
        _output_array+=(
            'last_command: ->'
            "${_last_command}"
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
		'NR>L-M && NR<L+M { printf "%-5d%3s%s\n",NR,(NR==L?">> ":""),$0 }' "${BASH_SOURCE[idx+1]}"
	L_critical "command returned with non-zero exit status"
}

L_trap_err_small() {
	L_error "fatal error on $(caller)"
}

L_trap_err_enable() {
	L_trap_err() {
		local _code="${1:-0}"
		## Workaround for read EOF combo tripping traps
		if ((!_code)); then
			return "${_code}"
		fi
		(
			# set +x
			# L_trap_err_show_source 1 "$@"
			L_print_traceback 1 "$@"
			L_critical "Command returned with non-zero exit status: $_code"
		) >&2 ||:
		exit "$_code"
	}
}

L_trap_err_disable() {
	# shellcheck disable=2317
	L_trap_err() { :; }
}

L_trap_init() {
	if ! L_function_exists L_trap_err; then
		L_trap_err_enable
	fi

	if [[ "$-" == *e* ]] || L_is_main; then
		set -e -E -o functrace
		trap 'L_trap_err "$?" "$BASH_COMMAND" -- "${BASH_SOURCE[@]}" -- "${BASH_LINENO[@]}" -- "${FUNCNAME[@]}"' ERR
	fi
}

L_trap_init

###############################################################################
# ]]]
# version [[[
# @section version

# shellcheck disable=1105,2053
# @description compare version numbers
# @see https://peps.python.org/pep-0440/
# @arg $1 str one version
# @arg $2 str one of: -lt -le -eq -ne -gt -ge '<' '<=' '==' '!=' '>' '>=' '~='
# @arg $3 str second version
# @arg [$4] int accuracy, how many at max elements to compare? By default up to 3.
L_version_cmp() {
	local -A ops=(["-lt"]='<' ["-le"]='<=' ["-eq"]='==' ["-ne"]='!=' ["-gt"]='>' ["-ge"]='>=')
	local op=${ops["$2"]:-$2}
	case "$op" in
	'~=')
		L_version_cmp "$1" '>=' "$3" && L_version_cmp "$1" "==" "${3%.*}.*"
		;;
	'==')
		[[ $1 == $3 ]]
		;;
	'!=')
		[[ $1 != $3 ]]
		;;
	*)
		local res='=' i max a=() b=()
		IFS='.-()' read -ra a <<<"$1"
		IFS='.-()' read -ra b <<<"$3"
		L_max -v max "${#a[@]}" "${#b[@]}"
		L_min -v max "${4:-3}" "$max"
		for ((i=0;i<max;++i)); do
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
	L_unittest_checkexit 0 L_version_cmp "${BASH_VERSION}" -gt "0.1.0"
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
# asa - ASsociative Array [[[
# @section asa
# @description collection of function to work on associative arrays

# @description Copy associative dictionary
# @arg $1 var The name of one dictionary variable
# @arg $2 var The name of the other dictionary variable
# @arg [$3] str Filter only keys with this prefix
L_asa_copy() {
	if [[ $1 != _L_nameref_from ]]; then declare -n _L_nameref_from=$1; fi
	if [[ $1 != _L_nameref_to ]]; then declare -n _L_nameref_to=$2; fi
	L_assert2 "" test "$#" = 2 -o "$#" = 3
	local _L_key
	for _L_key in "${!_L_nameref_from[@]}"; do
		if (($# == 2)) || [[ "$_L_key" = "$3"* ]]; then
			_L_nameref_to["$_L_key"]=${_L_nameref_from["$_L_key"]}
		fi
	done
}

# @description check if associative array has key
# @arg $1 associative array nameref
# @arg $2 key
L_asa_has() {
	if [[ $1 != _L_asa ]]; then declare -n _L_asa=$1; fi
	[[ "${_L_asa["$2"]+yes}" ]]
}

_L_asa_handle_v() {
	if [[ $1 == -v?* ]]; then
		set -- -v "${1#-v}" "${@:2}"
	fi
	if [[ $1 == -v ]]; then
		# if [[ $2 != _L_v ]]; then local -n _L_v=$2; fi
		"${FUNCNAME[1]}"_v "${@:2}"
	else
		local _L_v
		if "${FUNCNAME[1]}"_v _L_v "$@"; then
			printf "%s\n" "${_L_v[@]}"
		else
			return $?
		fi
	fi
}

# @description Get value from associative array
# @arg $1 destination variable nameref
# @arg $2 associative array nameref
# @arg $3 key
# @arg [$4] optional default value
# @exitcode 1 if no key found and no default value
L_asa_get_v() {
	if [[ $2 != _L_asa ]]; then declare -n _L_asa=$2; fi
	L_assert2 '' test "$#" = 3 -o "$#" = 4
	if L_asa_has _L_asa "$3"; then
		printf -v "$1" "%s" "${_L_asa[$3]}"
	else
		if (($# == 4)); then
			printf -v "$1" "%s" "$4"
		else
			return 1
		fi
	fi
}

# @description Get value from associative array
# @option -v<var>
# @arg $1 associative array nameref
# @arg $2 key
# @arg [$3] optional default value
# @exitcode 1 if no key found and no default value
L_asa_get() {
	_L_asa_handle_v "$@"
}

# @description get the length of associative array
# @arg $1 destination variable nameref
# @arg $2 associative array nameref
L_asa_len_v() {
	if [[ $2 != _L_asa ]]; then declare -n _L_asa=$2; fi
	local _L_keys=("${!_L_asa[@]}")
	printf -v "$1" "%s" "${#_L_keys[@]}"
}

# @description get the length of associative array
# @option -v<var>
# @arg $1 associative array nameref
L_asa_len() {
	_L_asa_handle_v "$@"
}

# @description get keys of an associative array in a sorted
# @arg $1 destination array variable nameref
# @arg $2 associative array nameref
L_asa_keys_sorted_v() {
	if [[ $1 != _L_keys ]]; then declare -n _L_keys=$1; fi
	if [[ $2 != _L_asa ]]; then declare -n _L_asa=$2; fi
	L_assert2 '' test "$#" = 2
	_L_keys=("${!_L_asa[@]}")
	L_sort "$1"
}

# @description get keys of an associative array in a sorted
# @option -v<var>
# @arg $1 associative array nameref
L_asa_keys_sorted() {
	_L_asa_handle_v "$@"
}

# @description Move the 3rd argument to the first and call
# The `L_asa $1 $2 $3 $4 $5` becomes `L_asa_$3 $1 $2 $4 $5`
# @option -v<var>
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
# @see L_nested_asa_get
L_nested_asa_set() {
	if [[ $1 != _L_dest ]]; then declare -n _L_dest=$1; fi
	local _L_tmp
	_L_tmp=$(declare -p "$3")
	_L_dest=${_L_tmp#*=}
}

# @description extract an associative array inside an associative array
# @arg $1 var associative array nameref to store
# @arg $2 =
# @arg $3 var source nameref
# @see L_nested_asa_set
L_nested_asa_get() {
	if [[ $3 != _L_asa ]]; then declare -n _L_asa=$3; fi
	if [[ $1 != _L_asa_to ]]; then declare -n _L_asa_to=$1; fi
	declare -A _L_tmpa="$_L_asa"
	_L_asa_to=()
	L_asa_copy _L_tmpa "$1"
}

_L_test_asa() {
	declare -A map
	local v
	{
		L_info "check has"
		map[a]=1
		L_asa_has map a
		L_asa_has map b && exit 1
	}
	{
		L_info "check getting"
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
		L_info "check length"
		L_asa_len_v v map
		L_unittest_eq "$v" 1
		map[c]=2
		L_asa -v v len map
		L_unittest_eq "$v" 2
	}
	{
		L_info "copy"
		local -A map2
		L_asa_copy map map2
	}
	{
		L_info "nested asa"
		local -A map2=([c]=d [e]=f)
		L_nested_asa_set map[mapkey] = map2
		L_asa_has map mapkey
		L_asa_get map mapkey
		local -A map3
		L_nested_asa_get map3 = map[mapkey]
		L_asa_get -v v map3 c
		L_unittest_eq "$v" d
		L_asa_get -v v map3 e
		L_unittest_eq "$v" f
	}
	{
		L_asa_keys_sorted -v v map2
		L_unittest_eq "${v[*]}" "c e"
	}
}

# ]]]
# unittest [[[
# @section unittest
# @description unit testing library

# @description accumulator for unittest results
L_unittest_result=0
# @description set to 1 to exit immediately
L_unittest_exit_on_error=0

# @description internal unittest function
# @env L_unittest_result
# @set L_unittest_result
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
	(( _L_invert ? (_L_tmp = !_L_tmp) : 1 , 1 ))
	: "${L_unittest_result:=0}"
	if ((_L_tmp)); then
		echo -n "${L_RED}${L_BRIGHT}"
	fi
	echo -n "${FUNCNAME[2]}:${BASH_LINENO[1]}${1:+: }${1:-}: "
	if ((_L_tmp == 0)); then
		echo "${L_GREEN}OK${L_COLORRESET}"
	else
		(( ++L_unittest_result ))
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
	while getopts :hr:EP: _L_opt; do
		case $_L_opt in
		h) cat <<EOF
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
		*) L_fatal "invalid argument: $_L_opt"; ;;
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
	if ((L_unittest_result)); then
		L_error "testing failed"
	else
		L_log "${L_GREEN}testing success"
	fi
	exit "$L_unittest_result"
}

# @description Test is eval of a string return success.
# @arg $1 string to eval-ulate
# @arg $@ error message
L_unittest_eval() {
	_L_unittest_internal "test eval ${1}" "${*:2}" eval "$1" ||:
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
	a=$(< "$1")
	b=$(< "$2")
	set -x
	if ! _L_unittest_internal "test pipes${3:+ $3}" "${4:-}" [ "$a" "$op" "$b" ]; then
		_L_unittest_showdiff "$a" "$b"
		return 1
	fi
}

_L_unittest_showdiff() {
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
	if ! _L_unittest_internal "test: \$$1=${!1:+${!1@Q}} == ${2@Q}" "" [ "${!1:-}" == "$2" ]; then
		_L_unittest_showdiff "${!1:-}" "$2"
		return 1
	fi
}

# @description test if two strings are equal
# @arg $1 one string
# @arg $2 second string
L_unittest_eq() {
	if ! _L_unittest_internal "test: ${1@Q} == ${2@Q}" "" [ "$1" == "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test two strings are not equal
# @arg $1 one string
# @arg $2 second string
L_unittest_ne() {
	if ! _L_unittest_internal "test: ${1@Q} != ${2@Q}" "" [ "$1" != "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if a string matches regex
# @arg $1 string
# @arg $2 regex
L_unittest_regex() {
	if ! _L_unittest_internal "test: ${1@Q} =~ ${2@Q}" "" eval "[[ ${1@Q} =~ $2 ]]"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @description test if a string contains other string
# @arg $1 string
# @arg $2 needle
L_unittest_contains() {
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

_L_trap_to_number_v() {
	if [[ "$1" == EXIT ]]; then
		_L_v=0
	elif L_str_is_digit "$1"; then
		_L_v=$1
	else
		_L_v=$(trap -l) &&
		[[ "$_L_v" =~ [^0-9]([0-9]*)\)\ $1[[:space:]] ]] &&
		_L_v=${BASH_REMATCH[1]}
	fi
}

# @description Convert trap name to number
# @option -v<var>
# @arg $1 trap name or trap number
L_trap_to_number() {
	_L_handle_v "$@"
}

_L_trap_to_name_v() {
	if [[ "$1" == 0 ]]; then
		_L_v=EXIT
	elif L_str_is_digit "$1"; then
		_L_v=$(trap -l) &&
		[[ "$_L_v" =~ [^0-9]$1\)\ ([^[:space:]]+) ]] &&
		_L_v=${BASH_REMATCH[1]}
	else
		_L_v="$1"
	fi
}

# @description convert trap number to trap name
# @option -v<var>
# @arg $1 signal name or signal number
# @example L_trap_to_name -v var 0 && L_assert2 '' test "$var" = EXIT
L_trap_to_name() {
	_L_handle_v "$@"
}

_L_trap_get_v() {
	local _L_tmp &&
	L_trap_to_name -v _L_tmp "$@" &&
	_L_tmp=$(trap -p "$_L_tmp") &&
	if [[ $_L_tmp ]]; then
		local -a _L_tmp="($_L_tmp)" &&
		_L_v=${_L_tmp[2]}
	else
		_L_v=
	fi
}

# @description Get the current value of trap
# @option -v<var>
# @arg $1 str|int signal name or number
# @example
#   trap 'echo hi' EXIT
#   L_trap_get -v var EXIT
#   L_assert2 '' test "$var" = 'echo hi'
L_trap_get() {
	_L_handle_v "$@"
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
		L_trap_to_name -v tmp EXIT ; L_unittest_eq "$tmp" EXIT
		L_trap_to_name -v tmp 0 ; L_unittest_eq "$tmp" EXIT
		L_trap_to_name -v tmp 1 ; L_unittest_eq "$tmp" SIGHUP
		L_trap_to_name -v tmp DEBUG ; L_unittest_eq "$tmp" DEBUG
		L_trap_to_name -v tmp SIGRTMIN+5 ; L_unittest_eq "$tmp" SIGRTMIN+5
		L_trap_to_number -v tmp SIGRTMAX-5 ; L_unittest_eq "$tmp" 59
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
	if L_map_get_v _L_map_name "$1" "$2";then
		L_map_set "$1" "$2" "$_L_map_name${*:3}"
	else
		L_map_set "$1" "$2" "$3"
	fi
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

# @description Assigns the value of key in map.
# If the key is not set, then assigns default if given and returns with 1.
# You want to prefer this version of L_map_get
# @option -v<var>
# @arg $1 var map
# @arg $2 str key
# @arg [$3] str default
L_map_get() {
	_L_handle_v "$@"
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
			L_error "L_map:${FUNCNAME[1]}:${BASH_LINENO[2]}: ${i@Q} is not valid variable name";
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
# @decription argument parsing in bash

# @description Print argument parsing error.
# @env L_NAME
# @env _L_mainsettings
# @exitcode 2 if exit_on_error
# @set L_argparse_error
L_argparse_error() {
	L_argparse_print_usage >&2
	declare -g L_argparse_error
	L_argparse_error=$*
	echo "${_L_mainsettings["prog"]:-${L_NAME:-$0}}: error: $*" >&2
	if L_is_true "${_L_mainsettings["exit_on_error"]:-true}"; then
		exit 2
	fi
}

# shellcheck disable=2120
# @description Print help or only usage for given parser or global parser.
# @option -s --short print only usage, not full help
# @arg $1 _L_parser or
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
			local -n _L_parser=$1
			shift
		fi
		L_assert2 "" test "$#" == 0
	}
	{
		#
		local _L_i=0
		local -A _L_optspec
		local _L_usage _L_dest _L_shortopt _L_options _L_arguments _L_tmp
		local _L_usage_posargs _L_usage_options="" _L_usage_options_desc=() _L_usage_options_help=()
		local -A _L_mainsettings="${_L_parser[0]}"
		_L_usage="usage: ${_L_mainsettings[prog]:-${_L_name:-$0}}"
	}
	{
		# Parse short options
		local _L_usage_options_desc=() _L_usage_options_help=()
		local _L_metavar _L_nargs _L_shortopt _L_longopt
		while _L_argparse_parser_next_optspec _L_i _L_optspec; do
			_L_metavar=${_L_optspec[metavar]}
			_L_nargs=${_L_optspec[nargs]}
			local -a _L_options="(${_L_optspec[options]:-})"
			_L_required=${_L_optspec[required]:-0}
			#
			if ((${#_L_options[@]})); then
				local _L_desc=""
				local _L_j
				for _L_j in "${_L_options[@]}"; do
					_L_desc+=${_L_desc:+, }${_L_j}
				done
				local _L_opt=${_L_options[0]}
				local _L_metavars=""
				for ((_L_j = _L_nargs; _L_j; --_L_j)); do
					_L_metavars+=${_L_matavars:+ }${_L_metavar}
				done
				if ((_L_nargs)); then
					_L_desc+=" $_L_metavar"
				fi
				local _L_notrequired=yes
				if L_is_true "$_L_required"; then
					_L_notrequired=
				fi
				_L_usage+=" ${_L_notrequired:+[}$_L_opt$_L_metavars${_L_notrequired:+]}"
				local _L_desc _L_help
				_L_help=${_L_optspec[help]:-}
				_L_usage_options+="  ${_L_desc}${_L_help:+   ${_L_help}}"$'\n'
			fi
		done
	}
	{
		# Parse positional arguments
		local _L_usage_posargs="" _L_i=1
		local -A _L_optspec
		while _L_argparse_parser_next_optspec _L_i _L_optspec; do
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
				local _L_help
				_L_help=${_L_optspec[help]:-}
				_L_usage_posargs+="  $_L_metavar${_L_help:+   ${_L_help}}"$'\n'
			fi
		done
	}
	{
		# print usage
		if [[ -n "${_L_mainsettings["usage"]:-}" ]]; then
			_L_usage=${_L_mainsettings["usage"]}
		fi
		echo "$_L_usage"
		if ((!_L_short)); then
			local _L_help=""
			_L_help+="${_L_mainsettings[description]+${_L_mainsettings[description]##$'\n'}}"
			_L_help+="${_L_usage_posargs:+$'\npositional arguments:\n'${_L_usage_posargs##$'\n'}}"
			_L_help+="${_L_usage_options:+$'\noptions:\n'${_L_usage_options##$'\n'}}"
			_L_help+="${_L_mainsettings[epilog]:+$'\n'${_L_mainsettings[epilog]##$'\n'}}"
			echo "$_L_help"
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
# @see L_argparse_init
# @see L_argparse_add_argument
_L_argparse_split() {
	{
		if [[ $1 != _L_parser ]]; then
			declare -n _L_parser="$1"
		fi
		local _L_index
		_L_index=$2
		L_assert2 "" test "$3" = --
		shift 3
	}
	{
		local _L_allowed
		if ((_L_index == 0)); then
			_L_allowed=(prog usage description epilog formatter add_help allow_abbrev exit_on_error)
		else
			_L_allowed=(action nargs const default type choices required help metavar dest deprecated validator complete)
		fi
	}
	{
		# parse args
		declare -A _L_optspec=()
		while (($#)); do
			case "$1" in
			*=*)
				local _L_opt
				_L_opt=${1%%=*}
				L_assert2 "kv option may not contain space: $_L_opt" eval "[[ ! ${_L_opt@Q} == *' '* ]]"
				L_assert2 "invalid kv option: $_L_opt" L_args_contain "$_L_opt" "${_L_allowed[@]}"
				_L_optspec["$_L_opt"]=${1#*=}
				;;
			--)
				L_fatal "error"
				;;
			*' '*)
				L_fatal "argument may not contain space: $1"
				;;
			[-+]?)
				_L_optspec["options"]+=" $1 "
				: "${_L_optspec["dest"]:=${1#[-+]}}"
				: "${_L_optspec["mainoption"]:=$1}"
				;;
			[-+][-+]?*)
				_L_optspec["options"]+=" $1 "
				: "${_L_optspec["dest"]:=${1##[-+][-+]}}"
				: "${_L_optspec["mainoption"]:=$1}"
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
	{
		# apply default dest
		: "${_L_optspec["dest"]:=${_L_optspec["argument"]:-${_L_optspec["longopt"]:-${_L_optspec["shortopt"]:-}}}}"
		# Convert - to _
		_L_optspec["dest"]=${_L_optspec["dest"]//[#@%-!~^]/_}
		# infer metavar from description
		: "${_L_optspec["metavar"]:=${_L_optspec["dest"]}}"
	}
	{
		local _L_type=${_L_optspec["type"]:-}
		if [[ -n "$_L_type" ]]; then
			# shellcheck disable=2016
			local -A _L_ARGPARSE_VALIDATORS=(
				["int"]='[[ "$arg" =~ ^[+-]?[0-9]+$ ]]'
				["float"]='[[ "$arg" =~ ^[+-]?([0-9]*[.])?[0-9]+$ ]]'
				["positive"]='[[ "$arg" =~ ^[+]?[0-9]+$ && arg > 0 ]]'
				["nonnegative"]='[[ "$arg" =~ ^[+]?[0-9]+$ && arg >= 0 ]]'
			)
			local _L_type_validator=${_L_ARGPARSE_VALIDATORS["$_L_type"]:-}
			if [[ -n "$_L_type_validator" ]]; then
				_L_optspec["validator"]=$_L_type_validator
			else
				L_fatal "invalid type for option: $(declare -p _L_optspec)"
			fi
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
		append)
			_L_optspec["isarray"]=1
			: "${_L_optspec["nargs"]:=1}"
			;;
		append_const)
			_L_argparse_optspec_validate_value "${_L_optspec["const"]}"
			_L_optspec["isarray"]=1
			;;
		count) ;;
		call:*) ;;
		*)
			L_fatal "invalid action: $(declare -p _L_optspec)"
			;;
		esac
		: "${_L_optspec["nargs"]:=0}"
	}
	{
		# assign result
		L_nested_asa_set _L_parser["$_L_index"] = _L_optspec
	}
}

# @description Initialize a argparser
# Available parameters:
# - prog - The name of the program (default: ${0##*/})
# - usage - The string describing the program usage (default: generated from arguments added to parser)
# - description - Text to display before the argument help (by default, no text)
# - epilog - Text to display after the argument help (by default, no text)
# - add_help - Add a -h/--help option to the parser (default: True)
# - allow_abbrev - Allows long options to be abbreviated if the abbreviation is unambiguous. (default: True)
# - Adest - Store all values as keys into this associated dictionary
# @arg $1 The parser variable
# @arg $2 Must be set to '--'
# @arg $@ Parameters
L_argparse_init() {
	if [[ $1 != _L_parser ]]; then
		declare -n _L_parser="$1"
	fi
	_L_parser=()
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1" 0 -- "${@:3}"
	{
		# add -h --help
		declare -A _L_optspec
		L_nested_asa_get _L_optspec = _L_parser[0]
		if L_is_true "${_L_optspec[add_help]:-true}"; then
			L_argparse_add_argument "$1" -- -h --help \
				help="show this help and exit" \
				action=call:'L_argparse_print_help;exit 0'
		fi
	}
}

# @description Add an argument to parser
# Available parameters:
# - name or flags - Either a name or a list of option strings, e.g. 'foo' or '-f', '--foo'.
# - action - The basic type of action to be taken when this argument is encountered at the command line.
# - nargs - The number of command-line arguments that should be consumed.
# - const - A constant value required by some action and nargs selections.
# - default - The value produced if the argument is absent from the command line and if it is absent from the namespace object.
# - type - The type to which the command-line argument should be converted.
#   - Available types: float int positive nonnegative
# - choices - A sequence of the allowable values for the argument.
# - required - Whether or not the command-line option may be omitted (optionals only).
# - help - A brief description of what the argument does.
# - metavar - A name for the argument in usage messages.
# - dest - The name of the attribute to be added to the object returned by parse_args().
# - deprecated - Whether or not use of the argument is deprecated.
# - validator - A script that validates the 'arg' argument.
#   - For example: `validator='[[ $arg =~ ^[0-9]+$ ]]'`
# - complete - A Bash script that generates completion.
#
# @arg $1 parser
# @arg $2 --
# @arg $@ parameters
L_argparse_add_argument() {
	if [[ $1 != _L_parser ]]; then declare -n _L_parser="$1"; fi
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1" "${#_L_parser[@]}" -- "${@:3}"
}

# @description Iterate over all option settings.
# @env _L_parser
# @arg $1 index nameref, should be initialized at 1
# @arg $2 settings nameref
_L_argparse_parser_next_optspec() {
	declare -n _L_nameref_idx=$1
	declare -n _L_nameref_data=$2
	L_assert "" test "$#" = 2
	#
	if ((_L_nameref_idx++ >= ${#_L_parser[@]})); then
		return 1
	fi
	L_nested_asa_get _L_nameref_data = "_L_parser[_L_nameref_idx - 1]"
}

# @description Find option settings.
# @arg $1 What to search for: -o --option
# @arg $2 option settings nameref
# @env _L_mainsettings
# @env _L_parser
_L_argparse_parser_find_optspec() {
	local _L_what=$1
	if [[ $2 != _L_optspec ]]; then declare -n _L_optspec=$2; fi
	L_assert2 "" test "$#" = 2
	#
	local _L_i=1
	local _L_abbrev_matches=()
	while _L_argparse_parser_next_optspec _L_i _L_optspec; do
		# declare -p _L_optspec _L_what
		if [[ "${_L_optspec["options"]:-}" == *" $_L_what "* ]]; then
			return 0
		fi
		if [[ "$_L_what" == --* ]] && L_is_true "${_L_mainsettings["allow_abbrev"]:-true}"; then
			declare -a _L_tmp="(${_L_optspec["options"]:-})"
			for _L_tmp in "${_L_tmp[@]}"; do
				if [[ "$_L_tmp" == "$_L_what"* ]]; then
					_L_abbrev_matches+=("$_L_tmp")
					break
				fi
			done
		fi
	done
	case ${#_L_abbrev_matches[@]} in
	1) _L_argparse_parser_find_optspec "${_L_abbrev_matches[0]}" "$2" && return $? || return $? ;;
	0) ;;
	*) L_argparse_error "ambiguous option: $_L_what could match ${_L_abbrev_matches[*]}" ;;
	esac
	L_argparse_error "unrecognized arguments: $_L_what"
	return 1
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
# @env _L_argparse_ignore_validate
_L_argparse_optspec_validate_value() {
	if ((${_L_argparse_ignore_validate:-0})); then
		return 0
	fi
	local _L_validator=${_L_optspec["validator"]:-}
	if [[ -n "$_L_validator" ]]; then
		local arg="$1"
		if ! eval "$_L_validator"; then
			local _L_type=${_L_optspec["type"]:-}
			if [[ -n "$_L_type" ]]; then
				L_argparse_error "argument ${_L_optspec["metavar"]}: invalid ${_L_type} value: ${1@Q}"
				return 2
			else
				L_argparse_error "argument ${_L_optspec["metavar"]}: invalid value: ${1@Q}, validator: ${_L_validator@Q}"
				return 2
			fi
		fi
	fi
}

# @env _L_optspec
_L_argparse_optspec_assign_array() {
	{
		# validate
		local _L_i
		for _L_i in "$@"; do
			if ! _L_argparse_optspec_validate_value "$_L_i"; then
				return 2
			fi
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

# @env _L_optspec
# @env _L_value
# @env _L_used_value
# @env _L_assigned_options
_L_argparse_optspec_execute_action() {
	local _L_dest=${_L_optspec["dest"]}
	local _L_const="${_L_optspec["const"]:-}"
	_L_assigned_options+=("${_L_optspec["mainoption"]}")
	case ${_L_optspec["action"]:-} in
	"" | store)
		if ! _L_argparse_optspec_validate_value "$_L_value"; then return 2; fi
		printf -v "$_L_dest" "%s" "$_L_value"
		_L_used_value=1
		;;
	store_const | store_true | store_false | store_1 | store_0)
		printf -v "$_L_dest" "%s" "$_L_const"
		;;
	append)
		if ! _L_argparse_optspec_validate_value "$_L_value"; then return 2; fi
		_L_argparse_optspec_assign_array "$_L_value"
		_L_used_value=1
		;;
	append_const)
		_L_argparse_optspec_assign_array "${_L_optspec["const"]}"
		;;
	count)
		declare -n _L_nameref_tmp=$_L_dest
		((++_L_nameref_tmp, 1))
		;;
	call:*)
		local _L_action
		_L_action=${_L_optspec["action"]#"call:"}
		eval "$_L_action"
		;;
	*)
		L_fatal "invalid action: $(declare -p _L_optspec)"
		;;
	esac
}

# @description
# @arg $1 incomplete
# @env _L_optspec
# @env _L_parser
_L_argparse_optspec_complete() {
	local _L_complete=${_L_optspec["complete"]:-}
	if [[ -n "$_L_complete" ]]; then
		"$_L_complete" "$1" _L_parser _L_optspec
	else
		local _L_choices="(${_L_optspec["choices"]:-})"
		if [[ -n "$_L_choices" ]]; then
			for _L_i in "${_L_choices[@]}"; do
				if [[ "$_L_i" == "$1"* ]]; then
					printf "%s\n" "$_L_i"
				fi
			done
		fi
	fi
	exit 0
}

L_argparse_bash_complete() {
	if [[ $1 != _L_parser ]]; then declare -n _L_parser=$1; fi
	L_assert "" test "$2" = --
	L_assert "" test "$#" = 2
	#
	tmp=$(L_argparse_parse_args --complete _L_parser -- "${COMP_WORDS[@]}")
	echo "$tmp"
}

# @description Parse the arguments with the given parser.
# @env _L_parser
# @arg $1 argparser nameref
# @arg $2 --
# @arg $@ arguments
L_argparse_parse_args() {
	if [[ "$1" != "_L_parser" ]]; then declare -n _L_parser=$1; fi
	L_assert2 "" test "$2" = --
	shift 2
	#
	{
		local _L_in_complete=0
		if [[ "${1:-}" == --bash-complete ]]; then
			_L_in_complete=1
			shift
		fi
	}
	{
		# Extract mainsettings
		local -A _L_mainsettings="${_L_parser[0]}"
		# List of assigned metavars, used for checking required ones.
		local _L_assigned_options=()
	}
	{
		# set defaults
		local _L_i=1
		local -A _L_optspec
		while _L_argparse_parser_next_optspec _L_i _L_optspec; do
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
	{
		# Parse options on command line.
		local _L_opt _L_value _L_dest _L_c
		local -A _L_optspec
		while (($#)); do
			case "$1" in
			--)
				shift
				break
				;;
			[-+][-+]?*)
				{
					# Parse long option `--rcfile file --help`
					local _L_opt=$1 _L_value=
					if [[ "$_L_opt" == *=* ]]; then
						_L_value=${_L_opt#*=}
						_L_opt=${_L_opt%%=*}
					fi
					local _L_optspec
					_L_argparse_parser_find_optspec "$_L_opt" _L_optspec
					case "${_L_optspec["nargs"]}" in
					0)
						if [[ -n "$_L_value" ]]; then
							L_argparse_error "argument $_L_opt: ignored explicit argument ${_L_value@Q}" >&2
							return 2
						fi
						;;
					1)
						if [[ -z "$_L_value" ]]; then
							if ((_L_in_complete)); then
								_L_value=${2:-}
							else
								_L_value=$2
							fi
							shift
						fi
						;;
					*)
						L_fatal "not implemented"
						;;
					esac
					local _L_used_value=0
					_L_argparse_optspec_execute_action
				}
				;;
			[-+]?*)
				{
					# Parse short option -euopipefail
					local _L_opt _L_c _L_i _L_value
					_L_opt=${1#[-+]}
					for ((_L_i = 0; _L_i < ${#_L_opt}; ++_L_i)); do
						_L_c=${_L_opt:_L_i:1}
						local -A _L_optspec
						if ! _L_argparse_parser_find_optspec "-$_L_c" _L_optspec; then
							L_argparse_error "unrecognized arguments: $1"
							return 2
						fi
						local _L_value
						_L_value=${_L_opt:_L_i+1}
						case "${_L_optspec[nargs]}" in
						0) ;;
						1)
							if [[ -z "$_L_value" ]]; then
								if ((_L_in_complete)); then
									_L_value=${2:-}
								else
									_L_value=$2
								fi
								shift
							fi
							;;
						*)
							L_fatal "not implemented"
							;;
						esac
						local _L_used_value=0
						_L_argparse_optspec_execute_action
						if ((_L_used_value)); then
							break
						fi
					done
				}
				;;
			*)
				break
				;;
			esac
			shift
		done
	}
	{
		# generate completion if out of arguments for the last parsed option
		if ((_L_in_complete)); then
			_L_argparse_optspec_complete "$_L_value"
		fi
	}
	{
		# Parse positional arguments.
		# Check if all required options have value
		local _L_required_options=()
		local _L_i=1 _L_optspec
		while _L_argparse_parser_next_optspec _L_i _L_optspec; do
			if _L_argparse_optspec_is_option; then
				if L_is_true "${_L_optspec["required"]:-}"; then
					if ! L_args_contain "${_L_optspec["mainoption"]}" "${_L_assigned_options[@]}"; then
						_L_required_options+=("${_L_optspec["mainoption"]}")
					fi
				fi
			elif _L_argparse_optspec_is_argument; then
				local _L_dest _L_nargs
				_L_dest=${_L_optspec["dest"]}
				_L_nargs=${_L_optspec["nargs"]:-1}
				case "$_L_nargs" in
				"*")
					_L_argparse_optspec_assign_array "$@"
					shift "$#"
					;;
				"+")
					if (($# == 0)); then
						_L_required_options+=("${_L_optspec["metavar"]}")
					else
						_L_argparse_optspec_assign_array "$@"
					fi
					shift "$#"
					;;
				[0-9]*)
					if (($# < _L_nargs)); then
						_L_required_options+=("${_L_optspec["metavar"]}")
					else
						if ((_L_nargs == 1)); then
							_L_argparse_optspec_validate_value "$1"
							printf -v "$_L_dest" "%s" "$1"
						else
							_L_argparse_optspec_assign_array "${@:1:$_L_nargs}"
						fi
					fi
					shift "$_L_nargs"
					;;
				esac
			fi
		done
	}
	{
		if ((${#_L_required_options[@]})); then
			L_argparse_error "the following arguments are required: ${_L_required_options[*]}"
			return 2
		fi
	}
}

# Parse command line aruments according to specification.
# This command takes groups of command line arguments separated by `::`  with sentinel `::::` .
# The first group of arguments are arguments to `L_argparse_init` .
# The next group of arguments are arguments to `L_argparse_add_argument` .
# The last group of arguments are command line arguments passed to `L_argparse_parse_args`.
# Note: the last separator `::::` is different to make it more clear and restrict parsing better.
L_argparse() {
	local _L_parser=()
	local _L_args=()
	while (($#)); do
		if [[ "$1" == "::" || "$1" == "::::" ]]; then
			# echo "AA ${_L_args[@]} ${_L_parser[@]}"
			if ((${#_L_parser[@]} == 0)); then
				L_argparse_init _L_parser -- "${_L_args[@]}"
			else
				L_argparse_add_argument _L_parser -- "${_L_args[@]}"
			fi
			_L_args=()
			if [[ "$1" == "::::" ]]; then
				break
			fi
		else
			_L_args+=("$1")
		fi
		shift
	done
	L_assert2 "'::::' argument missing to ${FUNCNAME[0]}" test $# -ge 1
	shift 1
	L_argparse_parse_args _L_parser -- "$@"
}

_L_test_argparse() {
	local ret tmp option parser storetrue storefalse store0 store1 storeconst append
	{
		L_log "define parser"
		L_argparse_init parser -- prog=prog
		L_argparse_add_argument parser -- -t --storetrue action=store_true
		L_argparse_add_argument parser -- -f --storefalse action=store_false
		L_argparse_add_argument parser -- -0 --store0 action=store_0
		L_argparse_add_argument parser -- -1 --store1 action=store_1
		L_argparse_add_argument parser -- -c --storeconst action=store_const const=yes default=no
		L_argparse_add_argument parser -- -a --append action=append
	}
	{
		L_log "check defaults"
		L_argparse_parse_args parser --
		L_unittest_vareq storetrue false
		L_unittest_vareq storefalse true
		L_unittest_vareq store0 1
		L_unittest_vareq store1 0
		L_unittest_vareq storeconst no
		L_unittest_vareq append ''
	}
	{
		append=()
		L_log "check single"
		L_argparse_parse_args parser -- -tf01ca1 -a2 -a 3
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
		L_argparse_parse_args parser -- --storetrue --storefalse --store0 --store1 --storeconst \
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
		local nargs
		tmp=$(L_argparse prog=prog :: nargs nargs="+" :::: 2>&1) && ret=$? || ret=$?
		L_unittest_ne "$ret" 0
		L_unittest_contains "$tmp" "required"
		#
		L_argparse prog=prog :: nargs nargs="+" :::: 1 $'2\n3' $'4"\'5'
		L_unittest_eq "${nargs[*]}" $'1 2\n3 4"\'5'
	}
	{
		L_log "check help"
		tmp="$(L_argparse prog="ProgramName" :: arg nargs=2 :::: 2>&1)" && ret=$? || ret=$?
		L_unittest_ne "$ret" 0
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
		tmp=$(L_argparse :: --option action=store_1 :: --opverbose action=store_1 :::: --op 2>&1) && ret=$? || ret=$?
		L_unittest_ne "$ret" 0
		L_unittest_contains "$tmp" "ambiguous option: --op"
	}
	{
		L_log "count"
		local verbose=0
		L_argparse :: -v --verbose action=count :::: -v -v -v -v
		L_unittest_eq "$verbose" 4
		local verbose=0
		L_argparse :: -v --verbose action=count :::: -v -v
		L_unittest_eq "$verbose" 2
	}
	{
		L_log "type"
		local tmp arg
		tmp=$(L_argparse :: arg type=int :::: a 2>&1) && ret=0 || ret=$?
		L_unittest_ne "$ret" 0
		L_unittest_contains "$tmp" "invalid"
	}
	{
		L_log "usage"
		tmp=$(L_argparse prog=prog :: bar nargs=3 help="This is a bar argument" :::: --help 2>&1)
	}
	{
		L_log "required"
		tmp=$(L_argparse prog=prog :: --option required=true :::: 2>&1) && ret=$? || ret=$?
		L_unittest_ne "$ret" 0
		L_unittest_contains "$tmp" "the following arguments are required: --option"
		tmp=$(L_argparse prog=prog :: --option required=true :: --other required=true :: bar :::: 2>&1) && ret=$? || ret=$?
		L_unittest_ne "$ret" 0
		L_unittest_contains "$tmp" "the following arguments are required: --option --other bar"
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
}

_L_argparse_test1() {
	local option bar verbose param arg
	L_argparse \
		prog="ProgramName" \
		description="What the program does" \
		epilog="Text at the bottom of help" \
		-- -o --option action=store_true \
		-- --bar default= \
		-- -v --verbose action=store_1 \
		-- param nargs=2 \
		-- arg nargs=3 \
		---- "$@"
	declare -p option bar verbose param arg | tr '\n' ' '
	echo
}

_L_argparse_test2() {
	local parser
	L_argparse_init parser -- \
		prog="PROG"
	L_argparse_add_argument parser -- \
		--foo help="foo help"
	L_argparse_add_argument parser -- \
		bar help="bar help"
	local -A args
	L_argparse_parse_args parser args -- "$@"
	declare -p args
}

_L_argparse_test3() {
	local -A args
	L_argparse \
		prog="PROG" \
		-- -e action=store_1 \
		-- -u action=store_1 \
		-- -o \
		-- -- "$@"
	declare -p args
}

# ]]]
# private lib_lib functions [[[
# @section lib_lib
# @description internal functions and section

_L_lib_name=${BASH_SOURCE##*/}

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
	echo "Usage:  $L_NAME <COMMAND> [OPTIONS]"
}; fi

if ! L_function_exists L_cb_usage_desc; then L_cb_usage_desc() {
	:;
}; fi

if ! L_function_exists L_cb_usage_footer; then L_cb_usage_footer() {
	echo 'Written by Kamil Cukrowski. Licensed jointly under MIT License and Beeware License'
}; fi

# shellcheck disable=2046
_L_lib_their_usage() {
	if L_function_exists L_cb_usage; then
		L_cb_usage $(_L_lib_list_prefix_functions)
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
	L_unittest_run -P _L_test_ "$@"
}

_L_lib_usage() {
	cat <<EOF
Usage: . $_L_lib_name [OPTIONS] COMMAND [ARGS]...

Options:
  -h  Print this help and exit.
  -l  Drop the L_ prefix from some of the functions.
  -a

Commands:
  help                  Print this help and exit
  cmd PREFIX [ARGS]...  Run subcommands with specified prefix
  test                  Run internal unit tests
  eval                  Evaluate expression for testing

Usage example of 'cmd' command:

  # script.sh
  prefix_some_func() { echo 'yay!'; }
  prefix_some_other_func() { echo 'not yay!'; }
  .  $_L_lib_name cmd 'prefix_' "\$@"

Usage example of 'bash-completion' command:

  eval "\$(script.sh --bash-completion)"

Written by Kamil Cukrowski 2024. Licensed under LGPL.
EOF
}

_L_lib_main_cmd() {
			if (($# == 0)); then _L_lib_fatal "prefix argument missing"; fi
			L_prefix=$1
			case "$L_prefix" in
			(-*) _L_lib_fatal "prefix argument cannot start with -"; ;;
			("") _L_lib_fatal "prefix argument is empty"; ;;
			esac
			shift
			if L_function_exists "L_cb_parse_args"; then
				unset L_cb_args
				L_cb_parse_args "$@"
				if ! L_var_is_set L_cb_args; then L_error "L_cb_parse_args did not return L_cb_args array"; fi
				# shellcheck disable=2154
				set -- "${L_cb_args[@]}"
			elif ((_L_opt_argparse)); then
				_L_tmps=()
				while (($#)); do
					if [[ "$1" == '--' ]]; then
						shift
						break
					fi
					_L_tmps+=("$1")
					shift
				done
				L_argparse "${_L_tmps[@]}" \
					-q --quiet callback='L_logmask=61' -- \
					-v --verbose dest=L_logmask action=store_const const=255 --
					"$@"
			else
				case "${1:-}" in
				(--bash-completion)
					_L_lib_bash_completion
					if L_is_main; then
						exit
					else
						return
					fi
					;;
				(-h|--help)
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
	local _L_opt_argparse=0 _L_mode=""
	local OPTARG OPTING _L_opt
	while getopts :Lah _L_opt; do
		case $_L_opt in
		L) _L_lib_drop_L_prefix; ;;
		a) _L_opt_argparse=1; ;;
		h) _L_mode=help; ;;
		*) L_fatal "$_L_lib_name: Internal error when parsing arguments: $_L_opt"; ;;
		esac
		shift
	done
	shift "$((OPTIND-1))"
	if (($#)); then
		: "${_L_mode:=$1}"
		shift 1
	elif L_is_main; then
		: "${_L_mode:="help"}"
	fi
	case "$_L_mode" in
		"") ;;
		"eval") eval "$*"; ;;
		"exec") "$@"; ;;
		"help") _L_lib_usage; ;;
		"test") _L_lib_run_tests "$@"; ;;
		"cmd") _L_lib_main_cmd; ;;
		*) if (($# != 0)); then _L_lib_fatal "too many arguments: ${*@Q}"; fi; ;;
	esac
}

# ]]]
# main [[[

_L_lib_main "$@"

# ]]]
