#!/usr/bin/env bash

_L_arrmap_find() {
  local _L_ref="$1[_L_i]" _L_i=0 _L_max
  for (( _L_i = 2, _L_max = ${!_L_ref} * 2 + 2; _L_i < _L_max; _L_i += 2 )); do
    if [[ "${!_L_ref}" == "$2" ]]; then
      (( L_RET = (_L_i - 2) / 2 ))
	    return 0
    fi
  done
  return 1
}

L_arrmap_assign() {
	L_arrmap_clear "$1"
	local _L_arr="$1"
	shift
	while (($#)); do
		L_arrmap_set_noremove "$_L_arr" "$1" "$2"
		shift 2 || return "${L_EX_USAGE:-64}"
	done
}

L_arrmap_clear() { eval "$1=(0 '')"; }

L_arrmap_remove() {
	local L_RET _L_ref="$1[0]"
	if _L_arrmap_find "$1" "$2"; then
		unset "$1[2 + 2 * L_RET]" "$1[3 + 2 * L_RET]"
		(( $1[0]-- ))
		eval "$1=(\"\${$1[@]}\")"
		return 0
	fi
}

L_arrmap_set() {
	local L_RET
	if _L_arrmap_find "$1" "$2"; then
		eval "$1[3 + 2*L_RET]=\${*:3}"
	else
		L_arrmap_set_noremove "$@"
	fi
}

L_arrmap_set_noremove() {
	local _L_ref="$1[0]" _L_n
	printf -v "$1[2 + 2 * ${!_L_ref}]" "%s" "$2"
	printf -v "$1[3 + 2 * ${!_L_ref}]" "%s" "${*:3}"
	(( ++$1[0] ))
}

L_arrmap_get() { L_handle_v_scalar "$@"; }
L_arrmap_get_vL_RET() {
	local _L_ref="$1[3 + 2 * L_RET]"
	if _L_arrmap_find "$1" "$2"; then
		L_RET=${!_L_ref}
	elif (($# >= 3)); then
		L_RET=${*:3}
	else
		L_RET=""
		return 1
	fi
}

L_arrmap_has() { local L_RET; _L_arrmap_find "$1" "$2"; }

L_arrmap_setdefault() {
	if ! L_arrmap_has "$1" "$2"; then
		L_arrmap_set "$1" "$2" "${*:3}"
	fi
}

L_arrmap_append() {
	local L_RET _L_ref="$1[3 + 2 * L_RET]" _L_cur
	if _L_arrmap_find "$1" "$2"; then
		printf -v "$1[$((3 + 2*L_RET))]" "%s" "${!_L_ref}${*:3}"
	else
		L_arrmap_set "$1" "$2" "${*:3}"
	fi
}

L_arrmap_keys() { L_handle_v_array "$@"; }
L_arrmap_keys_vL_RET() {
	eval eval "'L_RET=(' '\"\${$1['{2..$(($1[0] * 2))..2}']}\"' ')'";
}

L_arrmap_values() { L_handle_v_array "$@"; }
L_arrmap_values_vL_RET() {
	eval eval "'L_RET=(' '\"\${$1['{3..$(($1[0] * 2 + 1))..2}']}\"' ')'";
}

L_arrmap_items() { L_handle_v_array "$@"; }
L_arrmap_items_vL_RET() {
	local _L_ref="$1[0]"
	_L_n=${!_L_ref} || return
	eval "L_RET=(\"\${$1[@]:2}\")"
}

. "${BASH_SOURCE[0]%/*}"/../bin/L_lib.sh
if L_is_main; then
	L_arrmap_clear arr
	declare -p arr
	L_arrmap_append arr a 1
	L_arrmap_append arr b 2
	declare -p arr
	L_arrmap_keys -v keys arr
	declare -p keys
	L_arrmap_values -v values arr
	declare -p values
	L_arrmap_items -v items arr
	declare -p items
	L_arrmap_has arr a; echo a $?
	L_arrmap_has arr b; echo b $?
	L_arrmap_has arr c; echo c $?
fi

