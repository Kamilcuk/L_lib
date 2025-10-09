#!/bin/bash


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

L_args_index_2() {
	local _L_needle="$1" _L_start="$#" IFS=$'\x1D'
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

args="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 a"
n=a
DIR=$(dirname "$0")
$DIR/perfbash -C '' -r 40 \
  "$(declare -f L_args_index_v); L_args_index_v $n $args" \
  "$(declare -f L_args_index_2); L_args_index_2 $n $args" \
  "$(declare -f L_array_index_v); arr=($args); L_array_index_v arr $n" \
  "$(declare -f L_args_index_2); arr=($args); L_args_index_2 $n \"\${arr[@]}\"" \

