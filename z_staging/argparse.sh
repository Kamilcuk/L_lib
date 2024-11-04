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

###############################################################################

# @description Print argument parsing error.
# @env L_NAME
# @env _L_mainsettings
# @exitcode 2 if exit_on_error
L_argparse_error() {
	L_argparse_print_usage >&2
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
		local -A _L_settings
		local _L_usage _L_dest _L_shortopt _L_options _L_arguments _L_tmp
		local _L_usage_posargs _L_usage_options="" _L_usage_options_desc=() _L_usage_options_help=()
		local -A _L_mainsettings=${_L_parser[0]}
		_L_usage="usage: ${_L_mainsettings[prog]:-${_L_name:-$0}}"
	}
	{
		# Parse short options
		local _L_usage_options_desc=() _L_usage_options_help=()
		local _L_metavar _L_nargs _L_shortopt _L_longopt
		while _L_argparse_parser_next_settings _L_i _L_settings; do
			_L_metavar=${_L_settings[metavar]}
			_L_nargs=${_L_settings[nargs]}
			local -a _L_options="(${_L_settings[options]:-})"
			_L_required=${_L_settings[required]:-0}
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
				_L_help=${_L_settings[help]:-}
				_L_usage_options+="  ${_L_desc}${_L_help:+   ${_L_help}}"$'\n'
			fi
		done
	}
	{
		# Parse positional arguments
		local _L_usage_posargs="" _L_i=1
		local -A _L_settings
		while _L_argparse_parser_next_settings _L_i _L_settings; do
			if _L_argparse_settings_is_argument; then
				local _L_metavar _L_nargs
				_L_metavar=${_L_settings[metavar]}
				_L_nargs=${_L_settings[nargs]}
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
				_L_help=${_L_settings[help]:-}
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
			_L_allowed=(action nargs const default type choices required help metavar dest deprecated validator completion)
		fi
	}
	{
		# parse args
		declare -A _L_settings=()
		while (($#)); do
			case "$1" in
			*=*)
				local _L_opt
				_L_opt=${1%%=*}
				L_assert2 "kv option may not contain space: $_L_opt" eval "[[ ! ${_L_opt@Q} == *' '* ]]"
				L_assert2 "invalid kv option: $_L_opt" L_array_contains "${_L_allowed[@]}" "$_L_opt"
				_L_settings["$_L_opt"]=${1#*=}
				;;
			--)
				L_fatal "error"
				;;
			*' '*)
				L_fatal "argument may not contain space: $1"
				;;
			[-+]?)
				_L_settings["options"]+=" $1 "
				: "${_L_settings["dest"]:=${1#[-+]}}"
				: "${_L_settings["mainoption"]:=$1}"
				;;
			[-+][-+]?*)
				_L_settings["options"]+=" $1 "
				: "${_L_settings["dest"]:=${1##[-+][-+]}}"
				: "${_L_settings["mainoption"]:=$1}"
				if ((${#_L_settings["dest"]} <= 1)); then
					_L_settings["dest"]=${1##[-+][-+]}
					_L_settings["mainoption"]=$1
				fi
				;;
			*)
				_L_settings["dest"]=$1
				;;
			esac
			shift
		done
	}
	{
		# apply default dest
		: "${_L_settings["dest"]:=${_L_settings["argument"]:-${_L_settings["longopt"]:-${_L_settings["shortopt"]:-}}}}"
		# Convert - to _
		_L_settings["dest"]=${_L_settings["dest"]//[#@%-!~^]/_}
		# infer metavar from description
		: "${_L_settings["metavar"]:=${_L_settings["dest"]}}"
	}
	{
		local _L_type=${_L_settings["type"]:-}
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
				_L_settings["validator"]=$_L_type_validator
			else
				L_fatal "invalid type for option: $(declare -p _L_settings)"
			fi
		fi
	}
	{
		# apply defaults depending on action
		case "${_L_settings["action"]:=store}" in
		store)
			: "${_L_settings["nargs"]:=1}"
			;;
		store_const)
			_L_argparse_settings_validate_value "${_L_settings["const"]}"
			;;
		store_true)
			_L_settings["default"]=false
			_L_settings["const"]=true
			;;
		store_false)
			_L_settings["default"]=true
			_L_settings["const"]=false
			;;
		store_0)
			_L_settings["default"]=1
			_L_settings["const"]=0
			;;
		store_1)
			_L_settings["default"]=0
			_L_settings["const"]=1
			;;
		append)
			_L_settings["isarray"]=1
			: "${_L_settings["nargs"]:=1}"
			;;
		append_const)
			_L_argparse_settings_validate_value "${_L_settings["const"]}"
			_L_settings["isarray"]=1
			;;
		count) ;;
		call:*) ;;
		*)
			L_fatal "invalid action: $(declare -p _L_settings)"
			;;
		esac
		: "${_L_settings["nargs"]:=0}"
	}
	{
		# assign result
		_L_parser[_L_index]=$(declare -p _L_settings)
		_L_parser[_L_index]=${_L_parser[_L_index]#*=}
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
		declare -A _L_settings=${_L_parser[0]}
		if L_is_true "${_L_settings[add_help]:-true}"; then
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
# - completion - A Bash script that generates completion.
#
# @arg $1 parser
# @arg $2 --
# @arg * parameters
L_argparse_add_argument() {
	if [[ $1 != _L_parser ]]; then
		declare -n _L_parser="$1"
	fi
	L_assert2 "" test "$2" = --
	_L_argparse_split "$1" "${#_L_parser[@]}" -- "${@:3}"
}

# @description Copy associative dictionary
# @arg $1 The name of one dictionary variable
# @arg $2 The name of the other dictionary variable
_L_argparse_kvcopy() {
	local _L_key
	declare -n _L_nameref_from=$1
	declare -n _L_nameref_to=$2
	L_assert2 "" test "$#" = 2
	for _L_key in "${!_L_nameref_from[@]}"; do
		_L_nameref_to["$_L_key"]=${_L_nameref_from["$_L_key"]}
	done
}

# @description Iterate over all option settings.
# @env _L_parser
# @arg $1 index nameref, should be initialized at 1
# @arg $2 settings nameref
_L_argparse_parser_next_settings() {
	declare -n _L_nameref_idx=$1
	declare -n _L_nameref_data=$2
	L_assert "" test "$#" = 2
	#
	: "${_L_nameref_idx:=1}"
	if ((_L_nameref_idx >= ${#_L_parser[@]})); then
		return 1
	fi
	declare -A _L_tmp="${_L_parser[$_L_nameref_idx]}"
	_L_nameref_data=()
	_L_argparse_kvcopy _L_tmp _L_nameref_data
	_L_nameref_idx=$((_L_nameref_idx + 1))
}

# @description Find option settings.
# @arg $1 What to search for: -o --option
# @arg $2 option settings nameref
# @env _L_mainsettings
# @env _L_parser
_L_argparse_parser_find_settings() {
	local _L_what=$1
	declare -n _L_settings_pnt=$2
	L_assert2 "" test $# = 2
	#
	local _L_i=1
	local _L_abbrev_matches=()
	while _L_argparse_parser_next_settings _L_i _L_settings_pnt; do
		# declare -p _L_settings _L_what
		if [[ "${_L_settings_pnt["options"]:-}" == *" $_L_what "* ]]; then
			return 0
		fi
		if [[ "$_L_what" == --* ]] && L_is_true "${_L_mainsettings["allow_abbrev"]:-true}"; then
			declare -a _L_tmp="(${_L_settings_pnt["options"]:-})"
			for _L_tmp in "${_L_tmp[@]}"; do
				if [[ "$_L_tmp" == "$_L_what"* ]]; then
					_L_abbrev_matches+=("$_L_tmp")
					break
				fi
			done
		fi
	done
	case ${#_L_abbrev_matches[@]} in
	1) _L_argparse_parser_find_settings "${_L_abbrev_matches[0]}" "$2" && return $? || return $? ;;
	0) ;;
	*) L_argparse_error "ambiguous option: $_L_what could match ${_L_abbrev_matches[*]}" ;;
	esac
	L_argparse_error "unrecognized arguments: $_L_what"
	return 1
}

# @env _L_settings
_L_argparse_settings_is_option() {
	[[ -n "${_L_settings["options"]:-}" ]]
}

# @env _L_settings
_L_argparse_settings_is_argument() {
	[[ -z "${_L_settings["options"]:-}" ]]
}

# @env _L_settings
# @arg $1 value to assign to option
_L_argparse_settings_validate_value() {
	local _L_validator=${_L_settings["validator"]:-}
	if [[ -n "$_L_validator" ]]; then
		local arg="$1"
		if ! eval "$_L_validator"; then
			local _L_type=${_L_settings["type"]:-}
			if [[ -n "$_L_type" ]]; then
				L_argparse_error "argument ${_L_settings["metavar"]}: invalid ${_L_type} value: ${1@Q}"
			else
				L_argparse_error "argument ${_L_settings["metavar"]}: invalid value: ${1@Q}, validator: ${_L_validator@Q}"
			fi
		fi
	fi
}

# @env _L_settings
_L_argparse_settings_assign_array() {
	{
		# validate
		local _L_i
		for _L_i in "$@"; do
			_L_argparse_settings_validate_value "$_L_i"
		done
	}
	{
		# assign
		local _L_dest=${_L_settings["dest"]}
		if [[ $_L_dest == *[* ]]; then
			printf -v "$_L_dest" "%q " "$@"
		else
			declare -n _L_nameref_tmp=$_L_dest
			_L_nameref_tmp+=("$@")
		fi
	}
}

# @env _L_settings
# @env _L_value
# @env _L_used_value
# @env _L_assigned_options
_L_argparse_settings_execute_action() {
	local _L_dest=${_L_settings["dest"]}
	local _L_const="${_L_settings["const"]:-}"
	declare -p _L_settings
	_L_assigned_options+=("${_L_settings["mainoption"]}")
	case ${_L_settings["action"]:-} in
	"" | store)
		_L_argparse_settings_validate_value "$_L_value"
		printf -v "$_L_dest" "%s" "$_L_value"
		_L_used_value=1
		;;
	store_const | store_true | store_false | store_1 | store_0)
		printf -v "$_L_dest" "%s" "$_L_const"
		;;
	append)
		_L_argparse_settings_validate_value "$_L_value"
		_L_argparse_settings_assign_array "$_L_value"
		_L_used_value=1
		;;
	append_const)
		_L_argparse_settings_assign_array "${_L_settings["const"]}"
		;;
	count)
		declare -n _L_nameref_tmp=$_L_dest
		((++_L_nameref_tmp, 1))
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

# @description Parse the arguments with the given parser.
# @env _L_parser
# @arg $1 argparser nameref
# @arg $2 --
# @arg * arguments
L_argparse_parse_args() {
	if [[ "$1" != "_L_parser" ]]; then
		declare -n _L_parser=$1
	fi
	L_assert2 "" test "$2" = --
	shift 2
	#
	{
		# Extract mainsettings
		local -A _L_mainsettings="${_L_parser[0]}"
		# List of assigned metavars, used for checking required ones.
		local _L_assigned_options=()
	}
	{
		# set defaults
		local _L_i=1
		local -A _L_settings
		while _L_argparse_parser_next_settings _L_i _L_settings; do
			if L_var_is_set _L_settings["default"]; then
				if ((${_L_settings["isarray"]:-0})); then
					declare -a _L_tmp="(${_L_settings["default"]})"
					_L_argparse_settings_assign_array "${_L_tmp[@]}"
				else
					printf -v "${_L_settings["dest"]}" "%s" "${_L_settings["default"]}"
				fi
			fi
		done
	}
	{
		# Parse options on command line.
		local _L_opt _L_value _L_dest _L_c
		local -A _L_settings
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
					case "$_L_opt" in
					*=*)
						_L_value=${_L_opt#*=}
						_L_opt=${_L_opt%%=*}
						;;
					esac
					local _L_settings
					_L_argparse_parser_find_settings "$_L_opt" _L_settings
					case "${_L_settings["nargs"]}" in
					0)
						if [[ -n "$_L_value" ]]; then
							L_argparse_error "argument $_L_opt: ignored explicit argument ${_L_value@Q}" >&2
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
					local _L_used_value=0
					_L_argparse_settings_execute_action
				}
				;;
			[-+]?*)
				{
					# Parse short option -euopipefail
					local _L_opt _L_c _L_i _L_value
					_L_opt=${1#[-+]}
					for ((_L_i = 0; _L_i < ${#_L_opt}; ++_L_i)); do
						_L_c=${_L_opt:_L_i:1}
						local -A _L_settings
						if ! _L_argparse_parser_find_settings "-$_L_c" _L_settings; then
							L_argparse_error "unrecognized arguments: $1"
						fi
						local _L_value
						_L_value=${_L_opt:_L_i+1}
						case "${_L_settings[nargs]}" in
						0) ;;
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
						local _L_used_value=0
						_L_argparse_settings_execute_action
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
		# Parse positional arguments.
		# Check if all required options have value
		local _L_required_options=()
		local _L_i=1 _L_settings
		while _L_argparse_parser_next_settings _L_i _L_settings; do
			if _L_argparse_settings_is_option; then
				if L_is_true "${_L_settings["required"]:-}"; then
					if ! L_array_contains "${_L_assigned_options[@]}" "${_L_settings["mainoption"]}"; then
						_L_required_options+=("${_L_settings["mainoption"]}")
					fi
				fi
			elif _L_argparse_settings_is_argument; then
				local _L_dest _L_nargs
				_L_dest=${_L_settings["dest"]}
				_L_nargs=${_L_settings["nargs"]:-1}
				case "$_L_nargs" in
				"*")
					_L_argparse_settings_assign_array "$@"
					shift "$#"
					;;
				"+")
					:
					if (($# == 0)); then
						_L_required_options+=("${_L_settings["metavar"]}")
					else
						_L_argparse_settings_assign_array "$@"
					fi
					shift "$#"
					;;
				[0-9]*)
					if (($# < _L_nargs)); then
						_L_required_options+=("${_L_settings["metavar"]}")
					else
						if ((_L_nargs == 1)); then
							_L_argparse_settings_validate_value "$1"
							printf -v "$_L_dest" "%s" "$1"
						else
							_L_argparse_settings_assign_array "${@:1:$_L_nargs}"
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
		fi
	}
}

L_argparse_bash_completion() {
	if [[ $1 != _L_parser ]]; then
		declare -n _L_parser=$1
	fi
	L_assert "" test "$2" = --
	L_assert "" test "$#" = 2
	#
	if ! [[ -v COMP_CWORD && -v COMP_LINE && -v COMP_POINT && -v COMP_WORDBREAKS && -v COMP_WORDS ]]; then
		return
	fi
	local cur prev opts
	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD - 1]}
	opts=""
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
