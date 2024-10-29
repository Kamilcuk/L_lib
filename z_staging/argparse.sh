#!/bin/bash
# shellcheck disable=2317,2178
set -euo pipefail

. lib_lib.sh -l

L_argparse_debug() {
	echo "L_argparse: DEBUG: ${FUNCNAME[1]:-main}:${BASH_LINENO[1]}: $*" >&2
}

L_argparse_declare() {
	echo "L_argparse: DEBUG: ${FUNCNAME[1]:-main}:${BASH_LINENO[1]}: $(declare -p "$@")" >&2
}

L_argparse_error() {
	echo "L_argparse: DEBUG: ${FUNCNAME[1]:-main}:${BASH_LINENO[2]}: $*" >&2
}

L_argparse_print_help_short() {
	if [[ -z "${_L_parser:-}" ]]; then
		local -n _L_parser=$1
		L_assert2 "" test "$#" = 1
	else
		L_assert2 "" test "$#" = 0
	fi
	#
	local _L_i=0
	local -A _L_settings
	local _L_usage _L_metavar _L_shortopt
	declare -A _L_setting=${_L_parser[0]}
	_L_usage="usage: ${_L_setting[prog]:-${_L_name}}"
	# Parse short options
	while _L_argparse_parser_next _L_i _L_settings; do
		_L_metavar=${_L_settings[metavar]}
		_L_nargs=${_L_settings[nargs]}
		_L_shortopt=${_L_settings[shortopt]:-}
		_L_longopt=${_L_settings[longopt]:-}
		if [[ $_L_shortopt || $_L_longopt ]]; then
			if [[ "$_L_nargs" == "0" ]]; then
				_L_usage+=" [-${_L_shortopt}]"
			fi
		fi
	done
	echo "$_L_usage"
}

L_argparse_print_help() {
	if [[ -z "${_L_parser:-}" ]]; then
		local -n _L_parser=$1
		L_assert2 "" test "$#" = 1
	else
		L_assert2 "" test "$#" = 0
	fi
	#
	local _L_i=0
	local -A _L_settings
	local _L_usage _L_metavar _L_shortopt _L_options _L_arguments _L_tmp
	local _L_usage_posargs _L_usage_options="" _L_usage_options_desc=() _L_usage_options_help=()
	declare -A _L_setting=${_L_parser[0]}
	_L_usage="usage: ${_L_setting[prog]:-${_L_name}}"
	#
	# Parse short options
	{
		local _L_usage_options_desc=() _L_usage_options_help=()
		while _L_argparse_parser_next _L_i _L_settings; do
			local _L_metavar _L_nargs _L_shortopt _L_longopt
			_L_metavar=${_L_settings[metavar]}
			_L_nargs=${_L_settings[nargs]}
			_L_shortopt=${_L_settings[shortopt]:-}
			_L_longopt=${_L_settings[longopt]:-}
			#
			local _L_opt=""
			if [[ -n "$_L_shortopt" ]]; then
				_L_opt=-$_L_shortopt
			elif [[ -n "$_L_longopt" ]]; then
				_L_opt=--$_L_longopt
			fi
			#
			if [[ -n "$_L_opt" ]]; then
				#
				local _L_desc=""
				if [[ -n "$_L_shortopt" ]]; then
					_L_desc+="${_L_desc:+, }-$_L_shortopt"
				fi
				if [[ -n "$_L_longopt" ]]; then
					_L_desc+="${_L_desc:+, }--$_L_longopt"
				fi
				#
				case "$_L_nargs" in
				0)
					_L_usage+=" [$_L_opt]"
					;;
				1)
					_L_usage+=" [$_L_opt $_L_metavar]"
					_L_desc+=" $_L_metavar"
					;;
				esac
				local _L_desc _L_help
				_L_help=${_L_settings[help]:-}
				_L_usage_options+="  ${_L_desc}${_L_help:+    ${_L_help}}"$'\n'
			fi
		done
	}
	# Parse positional arguments
	{
		local _L_usage_posargs="" _L_i=0
		while _L_argparse_parser_next _L_i _L_settings; do
			local _L_argument
			_L_argument=${_L_settings[argument]:-}
			if [[ -n "$_L_argument" ]]; then
				local _L_metavar _L_nargs
				_L_metavar=${_L_settings[metavar]}
				_L_nargs=${_L_settings[nargs]}
				case "$_L_nargs" in
				'+')
					L_usage+=" ${_L_metavar}..."
					;;
				'*')
					L_usage+=" [${_L_metavar}...]"
					;;
				[0-9]*)
					while ((_L_nargs--)); do
						L_usage+=" $_L_metavar"
					done
					;;
				esac
				local _L_help
				_L_help=${_L_settings[help]:-}
				_L_usage_posargs+="  $_L_metavar${_L_help:+    ${_L_help}}"$'\n'
			fi
		done
	}
	{
		# print usage
		echo "$_L_usage"
		if true; then
			if [[ -n "$_L_usage_posargs" ]]; then
				echo
				echo "positional arguments:"
				echo "${_L_usage_posargs%%$'\n'}"
			fi
			if [[ -n "$_L_usage_options" ]]; then
				echo
				echo "options:"
				echo "${_L_usage_options%%$'\n'}"
			fi
			local _L_epilog
			_L_epilog=${_L_mainsettings[epilog]:-}
			if [[ -n "$_L_epilog" ]]; then
				echo
				echo "${_L_epilog%%$'\n'}"
			fi
		fi
	}
}

L_assert2() {
	if "${@:2}"; then
		:
	else
		L_print_traceback2
		L_fatal "assertion ${*:2} failed${1:+: $1}"
	fi
}

_L_argparse_split() {
	declare -n _L_nameref=$1
	L_assert2 "" test "$2" = --
	shift 2
	{
		# parse args
		declare -A _L_data
		while (($#)); do
			case "$1" in
			*=*)
				_L_data["${1%%=*}"]=${1#*=}
				;;
			--)
				L_fatal "error"
				;;
			--?*)
				if [[ -z "${_L_data["longopt"]:-}" ]]; then
					_L_data["longopt"]=${1#--}
				fi
				;;
			-?)
				if [[ -z "${_L_data["shortopt"]:-}" ]]; then
					_L_data["shortopt"]=${1#-}
				fi
				;;
			*)
				if [[ -z "${_L_data["argument"]:-}" ]]; then
					_L_data["argument"]=$1
				fi
				;;
			esac
			shift
		done
	}
	{
		# apply defaults nargs
		local _L_action _L_nargs
		_L_action=${_L_data[action]:-}
		_L_nargs=${_L_data[nargs]:-}
		if [[ -z "$_L_nargs" ]]; then
			case $_L_action in
			"") _L_data[nargs]=1 ;;
			*) _L_data[nargs]=0 ;;
			esac
		fi
	}
	{
		# apply default metavar
		_L_data["metavar"]="${_L_data["metavar"]:-${_L_data["argument"]:-${_L_data["longopt"]:-${_L_data["shortopt"]:-}}}}"
	}
	{
		# assign result
		_L_nameref=$(declare -p _L_data)
		_L_nameref=${_L_nameref#*=}
	}
}

L_argparse_init() {
	declare -n _L_nameref="$1"
	_L_nameref=()
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1[0]" -- "${@:3}"
	{
		# add -h --help
		declare -A _L_settings=${_L_nameref[0]}
		local _L_add_help
		_L_add_help=${_L_settings[add_help]:-}
		_L_add_help=${_L_add_help,,}
		if [[ "$_L_add_help" != 'false' ]]; then
			L_argparse_add_argument "$1" -- -h --help action=call:'f() { L_argparse_print_help; exit 1; }; f'
		fi
	}
}

L_argparse_add_argument() {
	declare -n _L_nameref="$1"
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1[${#_L_nameref[@]}]" -- "${@:3}"
}

_L_argparse_kvcopy() {
	local _L_key
	declare -n _L_nameref_from=$1
	declare -n _L_nameref_to=$2
	L_assert2 "" test "$#" = 2
	for _L_key in "${!_L_nameref_from[@]}"; do
		_L_nameref_to["$_L_key"]=${_L_nameref_from["$_L_key"]}
	done
}

_L_argparse_parser_get() {
	local index=$1
	L_assert "" test "$#" = 2
	declare -A _L_data="${_L_parser[$index]}"
	_L_argparse_kvcopy _L_data "$2"
}

_L_argparse_parser_next() {
	declare -n _L_nameref_idx=$1
	declare -n _L_nameref_data=$2
	L_assert "" test "$#" = 2
	#
	if ((_L_nameref_idx >= ${#_L_parser[@]})); then
		return 1
	fi
	declare -A _L_tmp="${_L_parser[$_L_nameref_idx]}"
	_L_nameref_data=()
	_L_argparse_kvcopy _L_tmp _L_nameref_data
	_L_nameref_idx=$((_L_nameref_idx + 1))
}

_L_argparse_opt_is_argument() {
	declare -n _L_nameref=$1
	[[ -n "${_L_nameref["argument"]:-}" ]]
}

_L_argparse_parser_find() {
	local _L_what=$1
	local _L_opt=$2
	declare -n _L_nameref_find=$3
	L_assert2 "" test $# = 3
	#
	local _L_i=0
	while _L_argparse_parser_next _L_i _L_nameref_find; do
		case "$_L_what" in
		argument)
			if [[ -n "${_L_nameref_find["argument"]:-}" ]]; then
				reutrn
			fi
			;;
		shortopt | longopt)
			if [[ "${_L_nameref_find["$_L_what"]:-}" == "$_L_opt" ]]; then
				return
			fi
			;;
		*)
			L_fatal "bla"
			;;
		esac
	done
	return 1
}

_L_argparse_parse_args_execute_action() {
	declare -g _L_settings _L_value _L_nameref
	local _L_metavar
	_L_metavar=${_L_settings["metavar"]}
	case ${_L_settings["action"]:-} in
	"")
		_L_nameref["$_L_metavar"]=$_L_value
		;;
	store_true | store_false | store_1 | store_0)
		_L_nameref["$_L_metavar"]=${_L_settings["action"]#store_}
		;;
	count)
		_L_nameref["$_L_metavar"]=$((${_L_nameref["$_L_metavar"]:-0} + 1))
		;;
	call:*)
		local _L_action
		_L_action=${_L_settings["action"]#"call:"}
		eval "$_L_action"
		;;
	*)
		L_fatal "invalid action: $(declare -p _L_settings)"
		;;
	esac
}

L_argparse_parse_args() {
	declare _L_parser
	_L_argparse_kvcopy "$1" _L_parser
	declare -n _L_nameref=$2
	L_assert2 "" test "$3" = --
	shift 3
	#
	_L_nameref=()
	local _L_i
	# Extract mainsettings
	local -A _L_mainsettings="${_L_parser[0]}"
	# Parse options on command line.
	{
		local _L_opt _L_value _L_metavar _L_c
		local -A _L_settings
		while (($#)); do
			case "$1" in
			--)
				shift
				break
				;;
			--?*)
				{
					# Parse long option `--rcfile file --help`
					local _L_opt=${1#--} _L_value=
					case "$_L_opt" in
					*=*)
						_L_opt=${_L_opt%%=*}
						_L_value=${_L_opt#*=}
						;;
					esac
					local _L_settings
					_L_argparse_parser_find longopt "$_L_opt" _L_settings
					case "${_L_settings[nargs]}" in
					0)
						if [[ -n "$_L_value" ]]; then
							_L_argparse_error "argument --$_L_opt: ignored explicit argument ${_L_value@Q}" >&2
						fi
						;;
					1)
						if [[ -z "$_L_value" ]]; then
							_L_value=$2
							shift
						fi
						;;
					*)
						L_fatal "not implemented"
						;;
					esac
					_L_argparse_parse_args_execute_action
				}
				;;
			-?*)
				# Parse short option -euopipefail
				_L_opt=${1#-}
				for ((_L_i = 0; _L_i < ${#_L_opt}; ++_L_i)); do
					_L_c=${_L_opt:_L_i:1}
					if ! _L_argparse_parser_find shortopt "$_L_c" _L_settings; then
						_L_argparse_error "unrecognized arguments: $1"
					fi
					_L_value=${_L_opt:_L_i+1}
					case "${_L_settings[nargs]}" in
					0)
						;;
					1)
						if [[ -z "$_L_value" ]]; then
							_L_value=$2
							shift
						fi
						;;
					*)
						L_fatal "not implemented"
						;;
					esac
					_L_argparse_parse_args_execute_action
				done
				;;
			*)
				break
				;;
			esac
			shift
		done
	}
	# Parse positional arguments.
	{
		local _L_i=0 _L_metavar _L_nargs
		while _L_argparse_parser_next _L_i _L_settings; do
			if [[ -z "${_L_settings[argument]:-}" ]]; then
				continue
			fi
			_L_metavar=${_L_settings["metavar"]}
			_L_nargs=${_L_settings["nargs"]:-1}
			case "$_L_nargs" in
			"*")
				printf -v _L_nameref["$_L_metavar"] "%q " "$@"
				break
				;;
			1)
				_L_nameref["$_L_metavar"]=$1
				;;
			[0-9]*)
				if (($# < _L_nargs)); then
					L_argparse_error "not enough arguments for: $_L_metavar"
					return 117
				fi
				printf -v _L_nameref["$_L_metavar"] "%q " "${@:1:$_L_nargs}"
				;;
			esac
			shift "$_L_nargs"
		done
	}
}

L_argparse() {
	local _L_destvar="$1"
	L_assert2 "" test "$2" = --
	shift 2
	#
	local _L_parservar
	local _L_args=()
	while (($#)) && ! [[ "$1" == -- && "$2" == -- ]]; do
		if [[ "$1" == -- ]]; then
			# echo "AA ${_L_args[@]} ${_L_parservar[@]}"
			if [[ -z ${_L_parservar:-} ]]; then
				L_argparse_init _L_parservar -- "${_L_args[@]}"
			else
				L_argparse_add_argument _L_parservar -- "${_L_args[@]}"
			fi
			_L_args=()
		else
			_L_args+=("$1")
		fi
		shift
	done
	shift 2
	L_argparse_parse_args _L_parservar "$_L_destvar" -- "$@"
}

###############################################################################

test1() {
	L_argparse_init parser -- \
		prog="ProgramName" \
		description="What the program does" \
		epilog="Text at the bottom of help"
	#
	L_argparse_add_argument parser -- -o --option action=store_true
	L_argparse_add_argument parser -- --bar
	L_argparse_add_argument parser -- -v --verbose action=store_true
	L_argparse_add_argument parser -- param nargs=2
	L_argparse_add_argument parser -- arg nargs=3
	local -A options
	L_argparse_parse_args parser options -- "$@"
	declare -p options
}

(test1 -h) || :

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
	L_argparse args \
		-- prog="PROG" \
		-- -e action=store_1 \
		-- -u action=store_1 \
		-- -o \
		-- -- "$@"
	declare -p args
}

test3 -e -u -o pipefail
test3 -euo pipefail
test3 -euopipefail

exit
