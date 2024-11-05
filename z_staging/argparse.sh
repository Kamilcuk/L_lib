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
