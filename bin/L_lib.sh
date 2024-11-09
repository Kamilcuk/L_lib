#!/bin/bash
# This is a collection of libraries that I seem to use over and over
# again and again inm every script I write.
# It's here to simplify my use of it.
# Written by Kamil Cukrowski
# Licensed jointly under MIT License and Beerware License
# SPDX-License-Identifier: MIT + Beerware

# shellcheck disable=SC2034

# Library start [[[

shopt -s extglob

# Source only once, to speed up
if [[ -z "${L_LIB_LIB_SOURCED:-}" ]]; then
L_LIB_LIB_SOURCED=true
readonly L_LIB_LIB_SOURCED

# ]]]
# Globals [[[

L_name=${0##*/}
L_dir=${0%/*}
L_NAME="$L_name"
L_DIR="$L_dir"
readonly L_NAME L_DIR

# ]]]
# Colors [[[

{
	readonly L_COLOR_BOLD=$'\E[1m'
	readonly L_COLOR_BRIGHT=$'\E[1m'
	readonly L_COLOR_DIM=$'\E[2m'
	readonly L_COLOR_FAINT=$'\E[2m'
	readonly L_COLOR_STANDOUT=$'\E[3m'
	readonly L_COLOR_UNDERLINE=$'\E[4m'
	readonly L_COLOR_BLINK=$'\E[5m'
	readonly L_COLOR_REVERSE=$'\E[7m'
	readonly L_COLOR_CONCEAL=$'\E[8m'
	readonly L_COLOR_HIDDEN=$'\E[8m'
	readonly L_COLOR_CROSSEDOUT=$'\E[9m'

	readonly L_COLOR_FONT0=$'\E[10m'
	readonly L_COLOR_FONT1=$'\E[11m'
	readonly L_COLOR_FONT2=$'\E[12m'
	readonly L_COLOR_FONT3=$'\E[13m'
	readonly L_COLOR_FONT4=$'\E[14m'
	readonly L_COLOR_FONT5=$'\E[15m'
	readonly L_COLOR_FONT6=$'\E[16m'
	readonly L_COLOR_FONT7=$'\E[17m'
	readonly L_COLOR_FONT8=$'\E[18m'
	readonly L_COLOR_FONT9=$'\E[19m'

	readonly L_COLOR_FRAKTUR=$'\E[20m'
	readonly L_COLOR_DOUBLE_UNDERLINE=$'\E[21m'
	readonly L_COLOR_NODIM=$'\E[22m'
	readonly L_COLOR_NOSTANDOUT=$'\E[23m'
	readonly L_COLOR_NOUNDERLINE=$'\E[24m'
	readonly L_COLOR_NOBLINK=$'\E[25m'
	readonly L_COLOR_NOREVERSE=$'\E[27m'
	readonly L_COLOR_NOHIDDEN=$'\E[28m'
	readonly L_COLOR_REVEAL=$'\E[28m'
	readonly L_COLOR_NOCROSSEDOUT=$'\E[29m'

	readonly L_COLOR_BLACK=$'\E[30m'
	readonly L_COLOR_RED=$'\E[31m'
	readonly L_COLOR_GREEN=$'\E[32m'
	readonly L_COLOR_YELLOW=$'\E[33m'
	readonly L_COLOR_BLUE=$'\E[34m'
	readonly L_COLOR_MAGENTA=$'\E[35m'
	readonly L_COLOR_CYAN=$'\E[36m'
	readonly L_COLOR_LIGHT_GRAY=$'\E[37m'
	readonly L_COLOR_DEFAULT=$'\E[39m'
	readonly L_COLOR_FOREGROUND_DEFAULT=$'\E[39m'

	readonly L_COLOR_BG_BLACK=$'\E[40m'
	readonly L_COLOR_BG_BLUE=$'\E[44m'
	readonly L_COLOR_BG_CYAN=$'\E[46m'
	readonly L_COLOR_BG_GREEN=$'\E[42m'
	readonly L_COLOR_BG_LIGHT_GRAY=$'\E[47m'
	readonly L_COLOR_BG_MAGENTA=$'\E[45m'
	readonly L_COLOR_BG_RED=$'\E[41m'
	readonly L_COLOR_BG_YELLOW=$'\E[43m'

	readonly L_COLOR_FRAMED=$'\E[51m'
	readonly L_COLOR_ENCIRCLED=$'\E[52m'
	readonly L_COLOR_OVERLINED=$'\E[53m'
	readonly L_COLOR_NOENCIRCLED=$'\E[54m'
	readonly L_COLOR_NOFRAMED=$'\E[54m'
	readonly L_COLOR_NOOVERLINED=$'\E[55m'

	readonly L_COLOR_DARK_GRAY=$'\E[90m'
	readonly L_COLOR_LIGHT_RED=$'\E[91m'
	readonly L_COLOR_LIGHT_GREEN=$'\E[92m'
	readonly L_COLOR_LIGHT_YELLOW=$'\E[93m'
	readonly L_COLOR_LIGHT_BLUE=$'\E[94m'
	readonly L_COLOR_LIGHT_MAGENTA=$'\E[95m'
	readonly L_COLOR_LIGHT_CYAN=$'\E[96m'
	readonly L_COLOR_WHITE=$'\E[97m'

	readonly L_COLOR_BG_DARK_GRAY=$'\E[100m'
	readonly L_COLOR_BG_LIGHT_BLUE=$'\E[104m'
	readonly L_COLOR_BG_LIGHT_CYAN=$'\E[106m'
	readonly L_COLOR_BG_LIGHT_GREEN=$'\E[102m'
	readonly L_COLOR_BG_LIGHT_MAGENTA=$'\E[105m'
	readonly L_COLOR_BG_LIGHT_RED=$'\E[101m'
	readonly L_COLOR_BG_LIGHT_YELLOW=$'\E[103m'
	readonly L_COLOR_BG_WHITE=$'\E[107m'

	# It resets color and font.
	readonly L_COLOR_COLORRESET=$'\E[m'
	readonly L_COLOR_RESET=$'\E[m'
}

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

# @description
L_setcolor() {
	if [[ ! -v NO_COLOR && "${TERM:-dumb}" != "dumb" && -t 1 ]]; then
		L_color_on
	else
		L_color_off
	fi
}

L_setcolor

# ]]]
# Ansi [[[

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

# ]]]
# Loglevel library [[[

readonly L_LOGLEVEL_CRITICAL=60
readonly L_LOGLEVEL_ERROR=50
readonly L_LOGLEVEL_WARNING=40
readonly L_LOGLEVEL_NOTICE=30
readonly L_LOGLEVEL_INFO=20
readonly L_LOGLEVEL_DEBUG=10

declare -a L_LOGLEVEL_NAMES=(
	[L_LOGLEVEL_CRITICAL]="critical"
	[L_LOGLEVEL_ERROR]="error"
	[L_LOGLEVEL_WARNING]="warning"
	[L_LOGLEVEL_NOTICE]="notice"
	[L_LOGLEVEL_INFO]="info"
	[L_LOGLEVEL_DEBUG]="debug"
)
declare -a L_LOGLEVEL_COLORS=(
	[L_LOGLEVEL_CRITICAL]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_ERROR]="${L_BOLD}${L_RED}"
	[L_LOGLEVEL_WARNING]="${L_BOLD}${L_YELLOW}"
	[L_LOGLEVEL_NOTICE]="${L_BOLD}${L_CYAN}"
	[L_LOGLEVEL_INFO]="${L_BOLD}"
	[L_LOGLEVEL_DEBUG]="${L_LIGHT_GRAY}"
)

L_log_level=$L_LOGLEVEL_INFO

L_logrecord_stacklevel=1
L_logrecord_loglevel=0
L_logrecord_line=""

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

L_log_setLevel() {
	L_log_level=$1
}

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
# @arg $1 int loglevel
# @arg $2 str logline
L_logl() {
	((++L_logrecord_stacklevel))
	if L_log_is_enabled_for "$1"; then
		shift
		L_log_format "$@"
		L_log_output
	fi
	L_logrecord_stacklevel=1
}


L_critical() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_CRITICAL" "$@"; }
L_error() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_ERROR" "$@"; }
L_warn() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_WARNING" "$@"; }
L_warning() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_WARNING" "$@"; }
L_notice() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_NOTICE" "$@"; }
L_log() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_INFO" "$@"; }
L_info() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_INFO" "$@"; }
L_debug() { ((++L_logrecord_stacklevel)); L_logl "$L_LOGLEVEL_DEBUG" "$@"; }

# ]]]
# Additional functions [[[

# @description Output a string with the same quotating style as does bash in set -x
L_quote_setx() { local tmp; tmp=$({ set -x; : "$@"; } 2>&1); printf "%s\n" "${tmp:5}"; }

# @description Output a critical message and exit the script.
L_fatal() { L_critical "$*"; exit 2; }

# @description Eval the first argument - if it returns failure, then fatal.
L_assert() { if eval '!' "$1"; then L_print_traceback2; L_fatal "assertion $1 failed: ${*:2}"; fi }

# @description Return 0 if function exists.
L_function_exists() { [[ "$(LC_ALL=C type -t -- "$1" 2>/dev/null)" = function ]]; }
# @description Return 0 if function exists.
L_fn_exists()       { [[ "$(LC_ALL=C type -t -- "$1" 2>/dev/null)" = function ]]; }

# @description Return 0 if command exists.
L_command_exists() { command -v "$@" >/dev/null 2>&1; }
# @description Return 0 if command exists.
L_cmd_exists() { command -v "$@" >/dev/null 2>&1; }

# @description like hash, but silenced output, to check if command exists.
L_hash() { hash "$@" >/dev/null 2>&1; }
# @description return true if sourced
L_am_I_sourced() { [[ "${BASH_SOURCE[0]}" != "${0}" ]]; }
# @description return true if not sourced
L_is_main() { [[ "${BASH_SOURCE[0]}" == "$0" ]]; }

# @description
# @see L_var_is_set
L_isset() { L_var_is_set "$@"; }
# @description
# @see L_var_is_set
L_var_isset() { L_var_is_set "$@"; }
# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is set, nonzero otherwise
L_var_is_set() {
	declare -n _L_nameref_var_is_set
	_L_nameref_var_is_set=$1
	[[ -n ${_L_nameref_var_is_set+x} ]]
}

# @description
# @arg $1 variable nameref
# @exitcode 0 if variable is an array, nonzero otherwise
L_var_is_array() {
	[[ "$(declare -p "$1" 2> /dev/null)" == "declare -a"* ]]
}

# @description Return 0 if the string happend to be something like false.
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

# @descrpition log a command and then execute it
L_logrun() {
	L_log "+ $*"
	"$@"
}

: "${L_dryrun:=0}"

# @description Executes a command by printing it first with a + on stderr
# @env L_dryrun
L_run_log() {
	local _L_tmp
	_L_tmp="$1" # loglevel
	shift
	local log="+"
	if L_is_true "${L_dryrun:-}"; then
		log="DRYRUN: +"
	fi
	log="$log$(printf " %q" "$@")"
	L_logl "$_L_tmp" "$log"
	if ! L_is_true "${L_dryrun:-}"; then
		"$@"
	fi
}

L_run() {
	L_run_log L_LOG_INFO "$@"
}

# @description
L_list_functions_with_prefix() {
	compgen -A function | LC_ALL=C sed -n "s/^$*//p" | LC_ALL=C sort
}

# @description
L_time_all() {
	command time -f "\
	Elapsed real time (in [hours:]minutes:seconds):	%E
	Elapsed real time (in seconds):	%e
	Total number of CPU-seconds that the process spent in kernel mode:	%S
	Total number of CPU-seconds that the process spent in user mode:	%U
	Percentage of the CPU that this job got, computed as (%U + %S) / %E:	%P
	Maximum resident set size of the process during its lifetime, in Kbytes:	%M
	Average resident set size of the process, in Kbytes:	%t
	Average total (data+stack+text) memory use of the process, in Kbytes:	%K
	Average size of the process's unshared data area, in Kbytes:	%D
	Average size of the process's unshared stack space, in Kbytes:	%p
	Average size of the process's shared text space, in Kbytes:	%X
	System's page size, in bytes.  This is a per-system constant, but varies between systems:	%Z
	Number of major page faults that occurred while the process was running:	%F
	Number of minor, or recoverable, page faults:	%R
	Number of times the process was swapped out of main memory:	%W
	Number of times the process was context-switched involuntarily (because the time slice expired):	%c
	Number of waits: times that the program was context-switched voluntarily, for instance while waiting for an I/O operation to complete:	%w
	Number of filesystem inputs by the process:	%I
	Number of filesystem outputs by the process:	%O
	Number of socket messages received by the process:	%r
	Number of socket messages sent by the process:	%s
	Number of signals delivered to the process:	%k
	Name and command-line arguments of the command being timed:	%C
	Exit status of the command:	%x" "$@"
	# "
}

###############################################################################

# https://unix.stackexchange.com/questions/39623/trap-err-and-echoing-the-error-line
## Outputs Front-Mater formatted failures for functions not returning 0
## Use the following line after sourcing this file to set failure trap
##    trap 'failure "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR
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

L_print_traceback2() {
	local i s l tmp offset
	L_setcolor
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
				-v around=2 \
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
	L_critical "Command returned with non-zero exit status: ${1:-0}"
}

L_trap_err_show_source() {
	local idx=${1:-0}
    echo "Traceback:"
    awk -v L="${BASH_LINENO[idx]}" -v M=3 'NR>L-M && NR<L+M { printf "%-5d%3s%s\n",NR,(NR==L?">> ":""),$0 }' "${BASH_SOURCE[idx+1]}"
	L_critical "command returned with non-zero exit status"
}

L_trap_err_small() {
	L_error "fatal error on $(caller)"
}

L_trap_err_enable() {
	L_trap_err() {
		local _code="${1:-0}"
		## Workaround for read EOF combo tripping traps
		if ! ((_code)); then
			return "${_code}"
		fi
		(
			set +x
			# L_trap_err_show_source 1 "$@"
			L_print_traceback2 1 "$@"
		) >&2 ||:
		exit "$_code"
	}
}

L_trap_err_disable() {
	# shellcheck disable=2317
	L_trap_err() { :; }
}

if ! L_fn_exists L_trap_err; then
	L_trap_err_enable
fi


if [[ "$-" =~ e ]]; then
	set -E -o functrace
	trap 'L_trap_err "$?" "$BASH_COMMAND" -- "${BASH_SOURCE[@]}" -- "${BASH_LINENO[@]}" -- "${FUNCNAME[@]}"' ERR
fi

###############################################################################

L_kill_all_jobs() {
	local IFS='[]' j _
	while read -r _ j _; do
		kill "%$j"
	done <<<"$(jobs)"
}

_L_lib_drop_L_prefix() {
	for i in run fatal logl log emerg alert crit err warning notice info debug panic error warn; do
		eval "$i() { L_$i \"\$@\"; }"
	done
}

L_sed_show_diff() {
	(
		file="${*: -1}"
		tmpf=$(mktemp)
		trap 'rm -f "$tmpf"' EXIT
		sed "$@" > "$tmpf"
		diff "$file" "$tmpf" ||:
		if [[ "${L_LIB_LIB_SED_INPLACE:-}" = 'true' ]]; then
			mv "$tmpf" "$file"
		fi
	)
}

L_sed_inplace_show_diff() {
	(
		L_LIB_LIB_SED_INPLACE=true
		L_sed_show_diff "$@"
	)
}

L_is_valid_variable_name() {
	[[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

L_str_is_print() {
	[[ "$*" =~ ^[[:print:]]*$ ]]
}

# ]]]
# L_unittest [[[

_L_unittest_internal() {
	local _L_tmp=0 _L_invert=0
	if [[ "$3" == "!" ]]; then
		_L_invert=1
		shift
	fi
	"${@:3}" || _L_tmp=$?
	(( _L_invert ? (_L_tmp = !_L_tmp) : 1 , 1 ))
	: "${_L_unittest_result:=0}"
	if ((_L_tmp)); then
		echo -n "${L_RED}${L_BRIGHT}"
	fi
	echo -n "${FUNCNAME[2]}:${BASH_LINENO[1]}${1:+: }${1:-}: "
	if ((_L_tmp == 0)); then
		echo "${L_GREEN}OK${L_COLORRESET}"
	else
		(( _L_unittest_result |= 1 ))
		_L_tmp=("${@:3}")
		echo "expression ${_L_tmp[*]} FAILED!${2:+ }${2:-}${L_COLORRESET}"
		return 1
	fi
} >&2

L_unittest_assert() {
	_L_unittest_internal "test eval ${1}" "${*:2}" eval "$1" ||:
}

L_unittest_checkexit() {
	local _L_ret
	_L_ret=0
	"${@:2}" || _L_ret=$?
	_L_unittest_internal "test exit of ${*:2} is $1" "$_L_ret != $1" [ "$_L_ret" -eq "$1" ] ||:
}

L_unittest_evalcheckexit() {
	local _L_ret
	_L_ret=0
	"${@:2}" || _L_ret=$?
	_L_unittest_internal "test exit of ${*:2} is $1" "$_L_ret != $1" [ "$_L_ret" -eq "$1" ] ||:
}

L_unittest_cmd() {
	_L_unittest_internal "test ${*:2}" "" "${@:2}" ||:
}

L_unittest_pipes() {
	local op='='
	if [[ "$1" = "!" ]]; then
		op='!='
		shift
	fi
	local a b
	a=$(< "$1")
	b=$(< "$2")
	if ! _L_unittest_internal "test pipes${3:+ $3}" "$4" [ "$a" "$op" "$b" ]; then
		_L_unittest_showdiff "$a" "$b"
		return 1
	fi
}

_L_unittest_showdiff() {
	if [[ "$1" =~ ^[[:print:][:space:]]*$ && "$2" =~ ^[[:print:][:space:]]*$ ]]; then
		sdiff <(cat <<<"$1") - <<<"$2"
	else
		sdiff <(xxd -p <<<"$1") <(xxd -p <<<"$2")
	fi
}

L_unittest_vareq() {
	if ! _L_unittest_internal "test: \$$1=${!1:-} == $2" "" [ "${!1:-}" == "$2" ]; then
		_L_unittest_showdiff "${!1:-}" "$2"
		return 1
	fi
}

L_unittest_eq() {
	if ! _L_unittest_internal "test: ${1@Q} == ${2@Q}" "" [ "$1" == "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# ]]]
# trapchain library[[[

# printf "%q" "$(seq 255 | xargs printf "%02x\n" | xxd -r -p)"
_L_allchars=$'\001\002\003\004\005\006\a\b\t\n\v\f\r\016\017\020\021\022\023\024\025\026\027\030\031\032\E\034\035\036\037 !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\177\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377'

L_get_trap_number_from_name() {
	local line
	line=$(trap -l)
	while IFS= read -r line; do
		while [[ "$line" =~ ^[$'\t ']*([0-9]+)\)[$'\t ']*([^$'\t ']+)(.*) ]]; do
			if [[ "$1" == "${BASH_REMATCH[2]}" ]]; then
				echo "${BASH_REMATCH[1]}"
				break 2
			fi
			line=${BASH_REMATCH[3]}
		done
	done <<<"$line"
}

L_get_trap_name() {
	(
		trap ': 0738dc3c-6716-44a1-960a-991b0ec4abaa' "$1"
		trap -p
	) | while IFS= read -r line; do
		if
			[[ "$line" == *'0738dc3c-6716-44a1-960a-991b0ec4abaa'* ]] &&
			[[ "$line" =~ [^\ ]*$ ]]
		then
				printf %s "${BASH_REMATCH[0]}"
		fi
	done
}

L_extract_trap() {
	local tmp
	tmp=$(L_get_trap_name "$@")
	trap -p "$tmp" |
		sed '1s/^trap -- //; $s/ [^ ]\+$//' |
		sed "1s/^'//; s/'\\\\''/'/g; \$s/'$//"
}

_L_trapchain_callback() {
	# This is what it takes.
	local _L_tmp
	_L_tmp=_L_trapchain_data_$1
	eval "${!_L_tmp}"
}

# shellcheck disable=2064
L_trapchain() {
	local name
	name=$(L_get_trap_name "$2") &&
	trap "_L_trapchain_callback $name" "$name" &&
	eval "_L_trapchain_data_$2=\"\$1\"\$'\\n'\"\${_L_trapchain_data_$2:-}\""
}


# shellcheck disable=2064
# shellcheck disable=2016
_L_trapchain_test() {
	local tmp
	local allchars
	tmp=$(
		L_trapchain 'echo -n "!"' EXIT
		L_trapchain 'echo -n world' EXIT
		L_trapchain 'echo -n " "' EXIT
		L_trapchain 'echo -n hello' EXIT
	)
	L_unittest_assert '[[ "$tmp" == "hello world!" ]]' "tmp=$tmp"
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
	L_unittest_assert '[[ "$tmp" == "$res" ]]' $'\n'"tmp=${tmp}"$'\n'"res=${res}"
	(
		trap "$_L_allchars" "$(L_get_trap_number_from_name SIGUSR1)"
		tmp=$(L_extract_trap SIGUSR1)
		L_unittest_vareq tmp "$_L_allchars"
	)
}

L_raise() {
	kill -s "$1" "$BASHPID"
}

if hash ,nice 2>/dev/null; then
	L_nicecmd=(",nice")
else
	L_nicecmd=(nice -n 20 ionice -c 3)
fi

L_sudo_args_get() {
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

L_sudo() {
	local sudo
	sudo=()
	if ((UID != 0)) && hash sudo 2>/dev/null; then
		local sudo_args
		L_sudo_args_get sudo_args
		sudo=(sudo -n "${sudo_args[@]}")
	fi
	L_run "${sudo[@]}" "$@"
}

# ]]]
# Map [[[
# L_map consist of an empty initial newline.
# Then follows map name, follows a spce, and then printf %q of the value.
#
#                     # empty initial newline
#     key $'value'
#     key2 $'value2'
#
# This format matches the regexes used in L_map_get for easy extraction using bash
# Variable substituation.

# @func
# @brief Initializes a map
# @param variable name holding the map
L_map_init() {
	printf -v "$1" "%s" ""
}

# @brief Clear a key of a map
# @param map
# @param key
L_map_clear() {
	if ! _L_map_check "$1" "$2"; then return 2; fi
	local _L_map_name
	_L_map_name=${!1}
	_L_map_name="${_L_map_name/$'\n'"$2 "+([!$'\n'])/}"
	printf -v "$1" %s "$_L_map_name"
}

# @brief set value of a map if not set
# @param map
# @param key
# @param default value
L_map_setdefault() {
	if ! L_map_has "$@"; then
		L_map_set "$@"
	fi
}

# @brief Set a key in a map to value
# @param map
# @param key
# @param value
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

L_map_append() {
	local _L_map_name
	if L_map_getv _L_map_name "$1" "$2";then
		L_map_set "$1" "$2" "$_L_map_name${4:-}$3"
	else
		L_map_set "$1" "$2" "$3"
	fi
}

# @brief Assigns the value of key in map.
# If the key is not set, then assigns default if given and returns with 1.
# You want to prefer this version of L_map_get
# @param var
# @param map
# @param attribute
# @param optional default
L_map_getv() {
	if ! _L_map_check "$1" "$2" "$3"; then return 2; fi
	local _L_map_name
	_L_map_name=${!2}
	local _L_map_name2
	_L_map_name2="$_L_map_name"
	# Remove anything in front of the newline followed by key followed by space.
	# Because the key can't have newline not space, it's fine.
	_L_map_name2=${_L_map_name2##*$'\n'"$3 "}
	# If nothing was removed, then the key does not exists.
	if [[ "$_L_map_name2" == "$_L_map_name" ]]; then
		if (($# >= 4)); then
			printf -v "$1" %s "${*:4}"
		fi
		return 1
	fi
	# Remove from the newline until the end and print with eval.
	# The key was inserted with printf %q, so it has to go through eval now.
	_L_map_name2=${_L_map_name2%%$'\n'*}
	eval "printf -v \"\$1\" %s $_L_map_name2"
}

L_map_get() {
	local tmp="" ret=0
	L_map_getv tmp "$@" || ret=$?
	printf "%s\n" "$tmp"
	return "$ret"
}

L_map_has() {
	if ! _L_map_check "$1" "$2"; then return 2; fi
	local _L_map_name
	_L_map_name=${!1}
	[[ "$_L_map_name" == *$'\n'"$2 "* ]]
}

# List all keys in the map.
L_map_keys() {
	local _L_map_name
	_L_map_name=${!1}
	local oldIFS key val
	oldIFS=$IFS
	IFS=' '
	while read -r key val; do
		if [[ -z "$key" ]]; then continue; fi
		printf "%s\n" "$key"
	done <<<"$_L_map_name"
}

# List items with tab separated key and value.
# Note: value is the output from printf %q - it needs to be eval-ed.
L_map_items() {
	local _L_map_name
	_L_map_name=${!1}
	local key val
	while read -r key val; do
		if [[ -z "$key" ]]; then continue; fi
		printf "%s\t%s\n" "$key" "$val"
	done <<<"$_L_map_name"
}

# Load all keys to variables with the name of $prefix$key.
# @param $1 map variable
# @param $2 prefix
# @param [$3...] Optional list of keys to load. If not set, all are loaded.
L_map_load() {
	if ! _L_map_check "$@"; then return 2; fi
	local _L_map_name
	_L_map_name=${!1}
	local _L_oldIFS _L_key _L_val
	_L_oldIFS="$IFS"
	IFS=' '
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
	IFS="$_L_oldIFS"
}

_L_map_check() {
	local i
	for i in "$@"; do
		if ! L_is_valid_variable_name "$i"; then
			L_error "L_map: ${FUNCNAME[1]}: is not valid variable name: $i";
			return 1
		fi
	done
}

# shellcheck disable=2018
_L_map_test() {
	local var tmp
	var=123
	tmp=123
	L_map_init var
	L_map_set var a 1
	L_unittest_pipes <(L_map_get var a) <(echo -n 1)
	L_unittest_pipes <(L_map_get var b) <(:)
	L_map_set var b 2
	L_unittest_pipes <(L_map_get var a) <(echo -n 1)
	L_unittest_pipes <(L_map_get var b) <(echo -n 2)
	L_map_set var a 3
	L_unittest_pipes <(L_map_get var a) <(echo -n 3)
	L_unittest_pipes <(L_map_get var b) <(echo -n 2)
	L_unittest_checkexit 1 L_map_get var c
	L_unittest_checkexit 1 L_map_has var c
	L_unittest_checkexit 0 L_map_has var a
	L_map_set var allchars "$_L_allchars"
	L_unittest_pipes <(L_map_get var allchars) <(printf %s "$_L_allchars") "L_map_get var allchars"
	L_map_clear var allchars
	L_unittest_checkexit 1 L_map_get var allchars
	L_map_set var allchars "$_L_allchars"
	local s_a s_b s_allchars
	L_unittest_pipes <(L_map_keys var | sort) <(printf "%s\n" b a allchars | sort) "L_map_keys check"
	L_map_load var s_
	L_unittest_vareq s_a 3
	L_unittest_vareq s_b 2
	# shellcheck disable=2016
	L_unittest_assert '[[ "$s_allchars" == "$_L_allchars" ]]'
}

# ]]]
# lib_lib functions [[[

_L_lib_name=${BASH_SOURCE##*/}

_L_lib_lib_error() {
	echo "$_L_lib_name: ERROR: $*" >&2
}

_L_lib_lib_fatal() {
	_L_lib_lib_error "$@"
	exit 3
}

_L_lib_lib_list_prefix_functions() {
	L_list_functions_with_prefix "$L_prefix"
}

if ! L_fn_exists L_cb_usage_usage; then L_cb_usage_usage() {
	echo "Usage:  $L_name <COMMAND> [OPTIONS]"
}; fi

if ! L_fn_exists L_cb_usage_desc; then L_cb_usage_desc() {
	:;
}; fi

if ! L_fn_exists L_cb_usage_footer; then L_cb_usage_footer() {
	echo 'Written by Kamil Cukrowski. Licensed jointly under MIT License and Beeware License'
}; fi

# shellcheck disable=2046
_L_lib_lib_their_usage() {
	if L_function_exists L_cb_usage; then
		L_cb_usage $(_L_lib_lib_list_prefix_functions)
		return
	fi
	local a_usage a_desc a_cmds a_footer
	a_usage=$(L_cb_usage_usage)
	a_desc=$(L_cb_usage_desc)
	a_cmds=$(
		{
			for f in $(_L_lib_lib_list_prefix_functions); do
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

_L_lib_lib_show_best_match() {
	local tmp
	if tmp=$(
		_L_lib_lib_list_prefix_functions |
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
_L_lib_lib_bash_completion() {
	local tmp cmds
	tmp=$(_L_lib_lib_list_prefix_functions)
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

_L_lib_lib_unittests_run() {
	if (($# < 2)); then return; fi
	if [[ "$1" != "--test" ]]; then return; fi
	L_assert "(($# <= 3))" "too many arguments for --test"
	local mode repeat=0
	mode=${2:-}
	case "$mode" in +([0-9])-*)
		repeat=${mode%%-*}
		mode=${mode#+([0-9])-}
	esac
	if [[ "$mode" == time_all-* ]]; then
		L_time_all "$0" --test="50-${mode#time_all-}"
		exit
	fi
	tests=$(
		compgen -A function |
		grep -x '_L_.*_test' |
		grep "${mode:-.*}" ||:
	)
	if [[ -z "$tests" ]]; then
		L_fatal "No tests matched with $mode"
	fi
	local test i
	if ((repeat == 0)); then
		for test in $tests; do "$test"; done
	else
		for test in $tests; do
			for ((i = 0; i < repeat; ++i)); do
				"$test"
			done
		done >/dev/null 2>/dev/null
	fi
	exit "${_L_unittest_result:-5}"
}

_L_lib_lib_usage() {
	cat <<EOF
Usage:
      . $_L_lib_name [options] -q
      . $_L_lib_name [options] <prefix> "\$@"
	  $_L_lib_name --test

A library to be called from other libraries. This is a simple script to
allow me to write simple reusable programs with bash completion and much
more TODO!

Usage example:

	# script.sh
	LIB_prefix_some_func() {
		desc="this func does that"
	}
    prefix_some_func() {
		echo 'yay!'
	}
    prefix_some_other_func() {
		echo 'not yay!'
	}
	source $_L_lib_name 'prefix_' "\$@"

Then you can enter from command line:

	script.sh some_func

You can import bash completion for the script with:

	eval "\$(script.sh --bash-completion)"

Options:
	-L   Drop L_ prefix on some functions
	-q   Only import library - do not parse arguments
	-l   Both -L and -q

Written by Kamil Cukrowski 2020.
Licensed jointly under Beerware License and MIT License.
EOF
}

# ]]]
# Library end [[[
fi
# ]]]
# lib_lib main [[[

# Easier to use library - drop L_ prefix on some functions if -L argument is passed
_L_lib_lib_args=$(getopt -n "$L_NAME:$_L_lib_name" -o +Llqha -l help,test::,bash-completion-gen-symlinks -- "$@") || return 1
eval "set -- $_L_lib_lib_args"
unset _L_lib_lib_args
_L_lib_loadonly=0
_L_lib_help=0
_L_argparse=0
while (($#)); do
	case "$1" in
	-L) _L_lib_drop_L_prefix; ;;
	-q) _L_lib_loadonly=1; ;;
	-l) _L_lib_drop_L_prefix; _L_lib_loadonly=1; ;;
	-a) _L_argparse=1; ;;
	-h|--help) _L_lib_help=1; ;;
	(--bash-completion-gen-symlinks)
		set -x
		( cd ~/.kamilscripts/bin/ && ag -l '(\.|source)\s+,lib_lib\s+.*"\$@"' . ) |
		( cd ~/.kamilscripts/bash-completions && xargs -i ln -vs ,lib_lib {} )
		exit
		;;
	--test) break; ;;
	--) shift; break; ;;
	*) L_fatal "$_L_lib_name: Internal error when parsing arguments"; ;;
	esac
	shift
done

if ! L_am_I_sourced; then
	_L_lib_lib_unittests_run "$@"
	_L_lib_lib_usage
	if ((_L_lib_help)); then exit 0; fi
	_L_lib_lib_fatal "Script $_L_lib_name has to be sourced!"
	exit 1
fi

if ((_L_lib_loadonly)); then
	if (($#)); then L_warning "Do not pass arguments with -q option"; fi
	unset _L_lib_loadonly
	return
fi
unset _L_lib_loadonly

if (($# == 0)); then _L_lib_lib_fatal "prefix argument missing"; fi
L_prefix=$1
case "$L_prefix" in
(-*) _L_lib_lib_fatal "prefix argument cannot start with -"; ;;
("") _L_lib_lib_fatal "prefix argument is empty"; ;;
esac
shift

if L_fn_exists "L_cb_parse_args"; then
	unset L_cb_args
	L_cb_parse_args "$@"
	if ! L_var_isset L_cb_args; then L_error "L_cb_parse_args did not return L_cb_args array"; fi
	# shellcheck disable=2154
	set -- "${L_cb_args[@]}"
elif ((_L_argparse)); then
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
		_L_lib_lib_bash_completion
		return
		exit
		;;
	(-h|--help)
		_L_lib_lib_their_usage "$@"
		return
		exit
		;;
	esac
fi

if (($# == 0)); then
	if ! L_fn_exists "${L_prefix}DEFAULT"; then
		_L_lib_lib_their_usage "$@"
		L_error "Command argument missing."
		exit 1
	fi
fi
L_CMD="${1:-DEFAULT}"
shift
if ! L_function_exists "$L_prefix$L_CMD"; then
	L_error "Unknown command: '$L_CMD'. See '$L_NAME --help'."
	_L_lib_lib_show_best_match "$L_CMD"
	exit 1
fi
"$L_prefix$L_CMD" "$@"

# ]]]

# vim: foldmethod=marker foldmarker=[[[,]]]

#!/bin/bash
# shellcheck disable=2317,2178
set -euo pipefail

. lib_lib.sh -l

L_arrayvar_contains() {
	if [[ $1 != _L_array ]]; then
		declare -n _L_array=$1
	fi
	L_assert2 "" test "$#" = 2
	L_arrayvar_contains "${_L_array[@]}" "$2"
}

L_array_contains() {
	L_assert2 "" test "$#" -ge 1
	local last i
	last="${*: -1}"
	for i in "${@:1:$#-1}"; do
		if [[ "$last" == "$i" ]]; then
			return 0
		fi
	done
	return 1
}

L_assert2() {
	if "${@:2}"; then
		:
	else
		L_print_traceback2
		L_fatal "assertion ${*:2} failed${1:+: $1}"
	fi
}

L_unittest_ne() {
	if ! _L_unittest_internal "test: $1 != $2" "" [ "$1" != "$2" ]; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

L_unittest_regex() {
	if ! _L_unittest_internal "test: ${1@Q} =~ ${2@Q}" "" eval "[[ ${1@Q} =~ $2 ]]"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

L_unittest_pattern() {
	if ! _L_unittest_internal "test: ${1@Q} pattern ${2@Q}" "" eval "set -- ${2@Q}; [[ ${1@Q} == \$1 ]]"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

L_unittest_contains() {
	if ! _L_unittest_internal "test: ${1@Q} == *${2@Q}*" "" eval "[[ ${1@Q} == *${2@Q}* ]]"; then
		_L_unittest_showdiff "$1" "$2"
		return 1
	fi
}

# @section L_asa
# @description check if variable is an associative array
# @arg $1 variable nameref
L_var_is_associative() {
	[[ $(declare -p "$1") == "declare -A"* ]]
}

###############################################################################

# @section L_sort
# @description internal function for sorting
# @internal
# @see L_sort
# @env _L_array
# @env _L_sort_numeric
# @env _L_i
_L_sort_partition() {
	local _L_j _L_temp _L_pivot
	_L_pivot=${_L_array[$2]}
	for ((_L_i = $1 - 1, _L_j = $1; _L_j < $2; _L_j++)); do
		if
			if ((_L_sort_numeric)); then
				((_L_array[_L_j] < _L_pivot))
			else
				[[ "${_L_array[_L_j]}" < "$_L_pivot" ]]
			fi
		then
			_L_temp=${_L_array[++_L_i]}
			_L_array[_L_i]=${_L_array[_L_j]}
			_L_array[_L_j]=$_L_temp
		fi
	done
	_L_temp=${_L_array[++_L_i]}
	_L_array[_L_i]=${_L_array[$2]}
	_L_array[$2]=$_L_temp
}

# @section L_sort
# @description
# @internal
# @env _L_array
# @env _L_i
# @arg $1 starting index
# @arg $2 ending index
_L_sort_in() {
	local _L_i
	if (($1 < $2)); then
		_L_sort_partition "$1" "$2"
		_L_sort_in "$1" "$((_L_i - 1))"
		_L_sort_in "$((_L_i + 1))" "$2"
	fi
}

# @section L_sort
# @description quicksort an array in place in pure bash
# @option -n --numeric-sort numeric sort, otherwise lexical
# @arg $1 array
# @arg [$2] starting index
# @arg [$3] ending index
L_sort() {
	local _L_sort_numeric=0
	if [[ "$1" == -n || "$1" == --numeric-sort ]]; then
		_L_sort_numeric=1
		shift
	fi
	#
	L_var_is_array "$1"
	L_assert2 '' L_var_is_array "$1"
	if [[ "$1" != _L_array ]]; then declare -n _L_array=$1; fi
	# second argument default to 0
	if (($# == 1)); then set -- "$@" 0; fi
	# third argument default to array length
	if (($# == 2)); then set -- "$@" "$((${#_L_array[@]} - 1))"; fi
	_L_sort_in "$2" "$3"
}

# @section L_sort
_L_test_sort() {
	local arr=(9 4 1 3 4 5)
	L_sort -n arr
	L_unittest_eq "${arr[*]}" "1 3 4 4 5 9"
	local arr=(g s b a c o)
	L_sort arr
	L_unittest_eq "${arr[*]}" "a b c g o s"
}
_L_test_sort

###############################################################################
# asa - ASsociative Array

# @section L_asa
# @description Copy associative dictionary
# @arg $1 The name of one dictionary variable
# @arg $2 The name of the other dictionary variable
# @arg [$3] Filter only keys with this prefix
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

# @section L_asa
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
		"${FUNCNAME[1]}"_v "${@:2}"
	else
		local _L_res
		if "${FUNCNAME[1]}"_v _L_res "$@"; then
			printf "%s\n" "${_L_res[@]}"
		else
			return $?
		fi
	fi
}

# @section L_asa
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

# @section L_asa
# @description Get value from associative array
# @option -v var
# @arg $1 associative array nameref
# @arg $2 key
# @arg [$3] optional default value
# @exitcode 1 if no key found and no default value
L_asa_get() {
	_L_asa_handle_v "$@"
}

# @section L_asa
# @description get the length of associative array
# @arg $1 destination variable nameref
# @arg $2 associative array nameref
L_asa_len_v() {
	if [[ $2 != _L_asa ]]; then declare -n _L_asa=$2; fi
	local _L_keys=("${!_L_asa[@]}")
	printf -v "$1" "%s" "${#_L_keys[@]}"
}

# @section L_asa
# @description get the length of associative array
# @option -v var
# @arg $1 associative array nameref
L_asa_len() {
	_L_asa_handle_v "$@"
}

# @section L_asa
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

# @section L_asa
# @description get keys of an associative array in a sorted
# @option -v var
# @arg $1 associative array nameref
L_asa_keys_sorted() {
	_L_asa_handle_v "$@"
}

# @section L_asa
# @description Move the 3rd argument to the first and call
# The `L_asa $1 $2 $3 $4 $5` becomes `L_asa_$3 $1 $2 $4 $5`
# @example L_asa -v v get map a
# @option -v var
# @arg $1 function name
# @arg $2 associative array nameref
# @arg * arguments
L_asa() {
	if [[ $1 == -v?* ]]; then
		"L_asa_$2" "$1" "${@:3}"
	elif [[ $1 == -v ]]; then
		"L_asa_$3" "${@:1:2}" "${@:4}"
	else
		"L_asa_$1" "${@:2}"
	fi
}

# @section L_asa
# @description store an associative array inside an associative array
# @arg $1 destination nameref
# @arg $2 =
# @arg $3 associative array nameref to store
# @see L_nested_asa_get
L_nested_asa_set() {
	if [[ $1 != _L_dest ]]; then declare -n _L_dest=$1; fi
	local _L_tmp
	_L_tmp=$(declare -p "$3")
	_L_dest=${_L_tmp#*=}
}

# @section L_asa
# @description extract an associative array inside an associative array
# @arg $1 associative array nameref to store
# @arg $2 =
# @arg $3 source nameref
# @see L_nested_asa_set
L_nested_asa_get() {
	if [[ $3 != _L_asa ]]; then declare -n _L_asa=$3; fi
	if [[ $1 != _L_asa_to ]]; then declare -n _L_asa_to=$1; fi
	declare -A _L_tmp="$_L_asa"
	_L_asa_to=()
	L_asa_copy _L_tmp "$1"
}

# @section L_asa
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
_L_test_asa

###############################################################################

###############################################################################

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
# @arg * arguments to parse
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
				L_assert2 "invalid kv option: $_L_opt" L_array_contains "${_L_allowed[@]}" "$_L_opt"
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
# @arg * Parameters
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
# @arg * parameters
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
# @arg * arguments
L_argparse_parse_args() {
	if [[ "$1" != "_L_parser" ]]; then declare -n _L_parser=$1; fi
	L_assert2 "" test "$2" = --
	shift 2
	#
	{
		local _L_in_complete=0
		if [[ "$1" == --bash-complete ]]; then
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
					if ! L_array_contains "${_L_assigned_options[@]}" "${_L_optspec["mainoption"]}"; then
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

###############################################################################

L_argparse_unittest() {
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

L_argparse_unittest
exit

test1() {
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

(test1 -h) || :
test1 a b 1 2 3
test1 a b 1 2
exit

test2() {
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

test2 --foo 123 234

test3() {
	local -A args
	L_argparse \
		prog="PROG" \
		-- -e action=store_1 \
		-- -u action=store_1 \
		-- -o \
		-- -- "$@"
	declare -p args
}

test3 -e -u -o pipefail
test3 -euo pipefail
test3 -euopipefail

cmd_a() {
	local option arg1 arg2
	L_argparse opt \
		-- -o --option \
		-- arg1 -- arg2 \
		-- -- "$@"
	echo "$option $arg1 $arg2"
}

exit
