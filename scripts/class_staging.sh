#!/bin/bash
set -euo pipefail

. "$(dirname "$0")"/../bin/L_lib.sh -s

# class [[[
# @section class
# @example
#   local a
#   # a = { value = { [2] = { 1 2 3 } } }
#   L_class_set a/value/1 = { a 1 b 2 c 3 }
#   L_class_set a/value/2 = [ 1 2 3 ]
#   L_class_set a/value/3 = 1
#   L_class_get -v v a/value/2/1
#   L_class_len -v v a/value
#   L_class_keys -v v a/value
#   for key in "${v[@]}"; do
#      L_class_get -v v a/value/"$key"
#      echo "$v"
#   done

_L_class_clear_nested() {
	local _L_v="$1" _L_k="$2" _L_items _L_i _L_type
	L_map_items -v _L_items "$_L_v"
	for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
		if [[ "${_L_items[_L_i]}" == "${_L_k:+$_L_k/}"* ]]; then
			L_map_remove "$_L_v" "${_L_items[_L_i]}"
		fi
	done
}

# @description clear all class attributes
# @arg $1 class namereference
# @arg [$2] key
L_class_clear() {
	if [[ -z "$1" ]]; then
		printf -v "$1" "%s" ""
	else
		_L_class_clear_nested "$@"
		L_map_remove "$_L_v" "$_L_k"
	fi
}

# @description Set key to string.
# @arg $1 class namereference
# @arg $2 key
# @arg $3 string
L_class_set_string() {
	local _L_v="$1" _L_k="$2"
	_L_class_clear_nested "$@"
	L_map_set "$_L_v" "$_L_k" "$3"
}

# @description Set key to dictionary.
# @arg $1 class namereference
# @arg $2 key
# @arg $@ Repeated key value pairs.
L_class_set_dict() {
	local _L_v="$1" _L_k="$2"
	L_class_clear "$_L_v" "$_L_k"
	shift 2
	while (($#)); do
		local _L_vk="$1" _L_vv="$2"
		L_map_set "$_L_v" "${_L_k:+$_L_k/}$_L_vk" "$_L_vv"
		shift 2 || return 2
	done
}

# @description Set key to array.
# @arg $1 class namereference
# @arg $2 key
# @arg $@ values
L_class_set_array() {
	local _L_v="$1" _L_k="$2"
	L_class_clear "$_L_v" "$_L_k"
	local _L_i=-1
	shift 2
	while ((++_L_i, $#)); do
		L_map_set "$_L_v" "${_L_k:+$_L_k/}$_L_i" "$1"
		shift
	done
}


# @description Copy class into class.
# @arg $1 class namereference
# @arg $2 key
# @arg $3 class value
L_class_set_copy() {
	local _L_v="$1" _L_k="$2"
	L_class_clear "$_L_v" "$_L_k"
	_L_i=$3
	L_map_items -v _L_items _L_i
	for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
		L_map_set "$_L_v" "${_L_k:+$_L_k/}${_L_items[_L_i]}" "${_L_items[_L_i+1]}"
	done
}

# @description Get key from class.
# If key is a string, it is assigned.
# If key is an array or a dict, it is serialized into a class.
# @option -v <var> variable to set
# @arg $1 class namereference
# @arg $2 key
L_class_get() { L_handle_v_scalar "$@"; }
L_class_get_v() {
	local _L_v="$1" _L_k="${2:-}" _L_items _L_i
	if [[ -z "$_L_k" ]]; then
		L_v="${!_L_v}"
	elif L_map_get_v "$_L_v" "$_L_k"; then
		:
	elif (($? == 1)); then
		L_v=""
		L_map_items -v _L_items "$_L_v"
		for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
			if [[ "${_L_items[_L_i]}" == "${_L_k:+$_L_k/}"* ]]; then
				L_map_set L_v "${_L_items[_L_i]#"${_L_k:+$_L_k/}"}" "${_L_items[_L_i+1]}"
			fi
		done
	else
		return 2
	fi
}

# @description Get array as array from class.
# @option -v <var> variable to set
# @arg $1 class namereference
# @arg $2 key
L_class_get_array() { L_handle_v_array "$@"; }
L_class_get_array_v() {
	local _L_v="$1" _L_k="${2:-}" _L_items _L_i
	L_v=()
	L_map_items -v _L_items "$_L_v"
	for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
		if [[ "${_L_items[_L_i]}" == "${_L_k:+$_L_k/}"* ]]; then
			L_v["${_L_items[_L_i]#"${_L_k:+$_L_k/}"}"]="${_L_items[_L_i+1]}"
		fi
	done
}

# @description Get class keys
# @option -v <var> variable to set
# @arg $1 class namereference
# @arg $2 key prefix
L_class_keys() { L_handle_v_array "$@"; }
L_class_keys_v() {
	local _L_v="$1" _L_k="${2:-}" _L_items _L_i _L_skey
	L_assert '' L_not L_map_has "$_L_v" "$_L_k"
	L_v=()
	L_map_items -v _L_items "$_L_v"
	for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
		if [[ "${_L_items[_L_i]}" == "${_L_k:+$_L_k/}"* ]]; then
			_L_skey="${_L_items[_L_i]#"${_L_k:+$_L_k/}"}"
			_L_skey="${_L_skey%%/*}"
			if [[ " ${L_v[@]} " != *" $_L_skey "* ]]; then
				L_v+=("$_L_skey")
			fi
		fi
	done
}

# @description Get class items.
# Prefer to use L_class_keys when iterating over nested dictionary for safety.
# @option -v <var> variable to set
# @arg $1 class namereference
# @arg $2 key prefix
L_class_items() { L_handle_v_array "$@"; }
L_class_items_v() {
	local _L_v="$1" _L_k="${2:-}" _L_keys _L_tmp
	L_assert '' L_not L_map_has "$_L_v" "$_L_k"
	L_v=()
	L_class_keys -v _L_keys "$_L_v" "$_L_k"
	L_map_items -v _L_items "$_L_v" "$_L_k"
	for _L_k in "${_L_keys[@]}"; do
		L_v+=("$_L_k")
		_L_k=${2:+$2/}$_L_k
		if L_map_get -v _L_tmp "$_L_v" "$_L_k"; then
			L_v+=("$_L_tmp")
		elif (($? == 1)); then
			_L_tmp=""
			for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
				if [[ "${_L_items[_L_i]}" == "$_L_k/"* ]]; then
					L_map_set _L_tmp "${_L_items[_L_i]#"$_L_k/"}" "${_L_items[_L_i+1]}"
				fi
			done
			L_v+=("$_L_tmp")
		else
			return 2
		fi
	done
}

# @description Get number of elements in a key.
# @option -v <var> variable to set
# @arg $1 class namereference
# @arg $2 key prefix
L_class_len() { L_handle_v_scalar "$@"; }
L_class_len_v() {
	L_class_keys_v "$@"
	L_v=${#L_v[@]}
}

# @description Get key type.
# @option -v <var> variable to set
# @arg $1 class namereference
# @arg $2 key prefix
L_class_type() { L_handle_v_scalar "$@"; }
L_class_type_v() {
	local _L_v="$1" _L_k="${2:-}" _L_items _L_i
	if [[ -z "$_L_k" ]]; then
		if [[ -n "${!_L_v}" ]]; then
			L_v=class
		fi
	elif L_map_has "$_L_v" "$_L_k"; then
		L_v=string
	else
		L_map_items -v _L_items "$_L_v"
		for ((_L_i=0; _L_i<${#_L_items[@]}; _L_i+=2)); do
			if [[ "${_L_items[_L_i]}" == "${_L_k:+$_L_k/}"* ]]; then
				L_v=dict
				return
			fi
		done
	fi
	L_v=empty
}

# ]]]

declare class="" v=""
L_class_set_dict class dict a 1 b 2
L_class_set_array class array c d e f
L_class_set_string class string "abc"
L_class_set_array class nested/array g h i
L_class_set_dict class nested/dict j 4 i 5 k 6 l 7 m 8
#
L_class_keys -v v class
L_unittest_arreq v dict array string nested
L_class_keys -v v class dict
L_unittest_arreq v a b
L_class_keys -v v class array
L_unittest_arreq v 0 1 2 3
L_class_keys -v v class nested
L_unittest_arreq v array dict
#
L_class_len -v v class array
L_unittest_vareq v 4
L_class_len -v v class dict
L_unittest_vareq v 2
L_class_len -v v class nested
L_unittest_vareq v 2
#
L_class_get -v v class string
L_unittest_vareq v "abc"
L_class_get -v v class dict/a
L_unittest_vareq v 1
L_class_get -v v class dict/b
L_unittest_vareq v 2
L_class_get -v nested class dict
L_class_get -v v nested a
L_unittest_vareq v 1
L_class_get -v v nested b
L_unittest_vareq v 2
L_class_get_array -v v class array
L_unittest_arreq v c d e f
L_class_get_array -v v class nested/array
L_unittest_arreq v g h i
#
L_class_get -v nested class nested
L_class_keys -v v nested
L_unittest_arreq v array dict
#
L_class_items -v v class nested
#
L_class_set_array nested array a
L_class_set_copy class nested "$nested"
L_class_get -v v class nested/array/0
L_unittest_vareq v a
L_class_len -v v class nested/array
L_unittest_vareq v 1
#
L_class_set_dict class nested new dict
L_class_keys -v v class nested
L_unittest_arreq v new
