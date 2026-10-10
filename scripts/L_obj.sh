#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh -s

###############################################################################

L_handle_v_asa() {
	case "${1:-}" in
	-vL_RET)
		if [[ "${2:-}" == -- ]]; then
			"${FUNCNAME[1]}"_vL_RET "${@:3}"
		else
			"${FUNCNAME[1]}"_vL_RET "${@:2}"
		fi
		;;
	-v?*)
		local -n L_RET="${1##-v}" || return "$L_EX_USAGE"
		if [[ "${2:-}" == -- ]]; then
			"${FUNCNAME[1]}"_vL_RET "${@:3}"
		else
			"${FUNCNAME[1]}"_vL_RET "${@:2}"
		fi
		;;
	-v)
		if [[ "$2" != L_RET ]]; then
			local -n L_RET="$2" || return "$L_EX_USAGE"
		fi
		if [[ "${3:-}" == -- ]]; then
			"${FUNCNAME[1]}"_vL_RET "${@:4}"
		else
			"${FUNCNAME[1]}"_vL_RET "${@:3}"
		fi
		;;
	--)
		local -A L_RET
		local _L_handle_v_i _L_r=0
		"${FUNCNAME[1]}"_vL_RET "${@:2}" || _L_r=$?
		for _L_handle_v_i in "${!L_RET[@]}"; do
			printf "%q=%s\n" "$_L_handle_v_i" "${L_RET[@]}" || return
		done
		return "$_L_r"
		;;
	-h) L_func_help 1; return 0 ;;
	*)
		local -A L_RET
		local _L_handle_v_i _L_r=0
		"${FUNCNAME[1]}"_vL_RET "$@" || _L_r=$?
		for _L_handle_v_i in "${!L_RET[@]}"; do
			printf "%q=%s\n" "$_L_handle_v_i" "${L_RET[@]}" || return
		done
		return "$_L_r"
	esac
}

L_is_natural_integer() {
  case "$1" in
    ''|*[!0-9]*|0?*) return 1 ;;
  esac
}

###############################################################################
# @section obj
# Implementation of a class that can hold arbitrary nested data of maps and arrays.

# .a -> .a
# .a. -> .a
# '' -> .
# a -> .a
_L_dotkey_normalize_vL_KEY() {
  case "${1//\\[.\\]/xx}" in
    *\\*) return 1 ;;
    .*[^.].) L_KEY=${1%.} ;;
    *[^.].) L_KEY=.${1%.} ;;
    .*) L_KEY=$1 ;;
    *) L_KEY=.$1 ;;
  esac
}

_L_dotkey_is_valid() { [[ "${1//\\[.\\]/}" != *\\* ]]; }
# a.b.c -> a
_L_dotkey_get_first_vL_RET() { L_RET=${1//\\[.\\]/XX} L_RET=${L_RET#.} L_RET=${L_RET%%.*} L_RET=${1::${#L_RET}}; }
_L_dotkey_remove_last_vL_RET() { L_RET=${1//\\[.\\]/XX} L_RET=${L_RET#.} L_RET=${L_RET%.*} L_RET=${1::${#L_RET}}; }

_L_dotkey_escape_vL_RET() { L_RET=("${@//\\/\\\\}") L_RET=("${L_RET[@]//./\\.}"); }
_L_dotkey_unescape_vL_RET() { L_RET=("${@/\\\\/\\}") L_RET=("${L_RET[@]//\\./.}"); }

L_dotkey_join() { L_handle_v_scalar "$@"; }
L_dotkey_join_vL_RET() { local IFS=.; L_RET=("${@//\\/\\\\}") L_RET="${L_RET[*]//./\\.}"; }

L_dotkey_split() { L_handle_v_scalar "$@"; }
L_dotkey_split_vL_RET() {
  _L_dotkey_is_valid "$1" || return
  L_RET=${1#.}
  if [[ $1 != *\\* ]]; then
    readarray -t -d . L_RET <<<"$L_RET."
    unset 'L_RET[-1]'
  else
    L_RET=${L_RET//$'\2'/$'\2\3'}
    L_RET=${L_RET//\\\\/$'\2\5'}
    L_RET=${L_RET//\\./$'\2\4'}
    readarray -t -d . L_RET <<<"$L_RET."
    unset 'L_RET[-1]'
    L_RET=("${L_RET[@]//$'\2\4'/.}")
    L_RET=("${L_RET[@]//$'\2\5'/\\}")
    L_RET=("${L_RET[@]//$'\2\3'/$'\2'}")
  fi
}

_L_obj_maybe_find_child_from_args_vL_RET() {
  local _L_i
  L_RET=0
  for _L_arg; do
    L_RET[1]=${L_RET[0]}
    case ${_L_obj[L_RET]} in
      MAP)
        L_RET=${_L_obj[L_RET+2]}
        if (( !L_RET )); then return; fi
        while [[ ${_L_obj[L_RET+1]} != "$_L_arg" ]]; do
          L_RET=${_L_obj[L_RET+3]}
          if (( !L_RET )); then return; fi
        done
        ;;
      ARRAY)
        if ! L_is_natural_integer "$_L_arg"; then
          L_func_error "Array index must be an integer"
          return "$L_EX_USAGE"
        fi
        L_RET=${_L_obj[L_RET+2]}
        if (( !L_RET )); then return; fi
        for (( _L_i = _L_arg; _L_i > 0; --_L_i )); do
          L_RET=${_L_obj[L_RET+3]}
          if (( !L_RET )); then return; fi
        done
        ;;
      *)
        L_func_error "Can't nest into non-container type"
        return "$L_EX_USAGE"
        ;;
    esac
  done
}

_L_obj_get_raw_idx_of_vL_RET() {
  _L_obj_maybe_find_child_from_args_vL_RET "$@" || return
  if [[ -z "$L_RET" ]]; then
    L_func_error "index not found: $*" 1
    return "$L_EX_USAGE"
  fi
}

L_obj_clear() { local -n _L_obj=$1 && _L_obj=(); }

# L_obj_get_vL_RET obj [part...]  -> L_RET = scalar value, return 1 if missing or not a scalar
L_obj_get() { L_handle_v_scalar "$@"; }
L_obj_get_vL_RET() {
  local -n _L_obj=$1
  _L_obj_get_raw_idx_of_vL_RET "${@:2}" || return
  case ${_L_obj[L_RET]} in
    MAP|ARRAY|"")
      L_func_error "cannot get value of a container"
      return 1
      ;;
  esac
  L_RET=${_L_obj[L_RET+2]}
}

# L_obj_get_vL_RET obj [part...] default -> L_RET = scalar value
L_obj_get_default_vL_RET() {
  local -n _L_obj=$1
  _L_obj_maybe_find_child_from_args_vL_RET "${@:2:$#-2}"
  if [[ -z $L_RET ]]; then
    L_RET=${!#}
  else
    case ${_L_obj[L_RET]} in MAP|ARRAY|"")
      L_func_error "cannot get value of a container"
      return 1
      ;;
    esac
    L_RET=${_L_obj[L_RET+2]-}
  fi
}

# Creates missing containers: a natural-integer part creates an ARRAY, anything else a MAP.
_L_obj_descend_vL_RET() {
  # local -n _L_obj has to be done by parent.
  local _L_cur=0 _L_arg _L_kind _L_child _L_last _L_i _L_new
  # init: node 0 is the root, its key field (offset 1) is the free-list head
  if (( ! ${_L_obj[@]:+1}0 )); then
    _L_obj=("" "" "" "" "")
  fi
  for _L_arg; do
    # If freshly created node, create it with ARRAY if index is 0.
    if [[ $_L_arg == 0 ]]; then
      _L_kind=${_L_obj[_L_cur]:=ARRAY}
    else
      _L_kind=${_L_obj[_L_cur]:=MAP}
    fi
    _L_child=${_L_obj[_L_cur+2]} _L_last=
    case $_L_kind in
      MAP)
        while [[ -n $_L_child && ${_L_obj[_L_child+1]} != "$_L_arg" ]]; do
          _L_last=$_L_child _L_child=${_L_obj[_L_child+3]}
        done
        ;;
      ARRAY)
        if ! L_is_natural_integer "$_L_arg"; then
          L_func_error "Array index has to be integer"; return 1
        fi
        for (( _L_i = _L_arg; _L_i > 0 && ${#_L_child}; --_L_i )); do
          _L_last=$_L_child _L_child=${_L_obj[_L_child+3]}
        done
        if ! [[ -n $_L_child || $_L_i == 0 ]]; then
          L_func_error "only index <= len allowed"; return 1
        fi
        ;;
      *) L_func_error "a scalar is in the way"; return 1 ;;
    esac
    if [[ -z $_L_child ]]; then
      # create and append at the tail
      _L_new=${_L_obj[1]:-${#_L_obj[@]}}
      [[ -n ${_L_obj[1]} ]] && _L_obj[1]=${_L_obj[_L_new+3]}
      _L_obj[_L_new]= _L_obj[_L_new+1]= _L_obj[_L_new+2]= _L_obj[_L_new+3]= _L_obj[_L_new+4]=$_L_last
      if [[ $_L_kind == MAP ]]; then
        _L_obj[_L_new+1]=$_L_arg
      fi
      if [[ -n $_L_last ]]; then
        _L_obj[_L_last+3]=$_L_new
      else
        _L_obj[_L_cur+2]=$_L_new
      fi
      _L_child=$_L_new
    fi
    _L_cur=$_L_child
  done
  L_RET=$_L_cur
}

# L_obj_set_type_value obj [part...] = type value
L_obj_set_type_value() {
  local -n _L_obj=$1
  local L_RET _L_type=${*:$#-1:1}
  if [[ "${*:$#-2:1}" != "=" ]]; then L_func_error "+= missing"; return "$L_EX_USAGE"; fi
  _L_obj_descend_vL_RET "${@:2:$#-4}" || return
  case "${_L_obj[L_RET]}" in
    MAP|ARRAY)
      L_func_error "Can't set container to scalar"
      return 1
  esac
  _L_obj[L_RET]=$_L_type
  case "$_L_type" in
    MAP|ARRAY) ;;
    *) _L_obj[L_RET+2]=${!#} ;;
  esac
}

# L_obj_set_type_value obj [part...] = type
L_obj_set_type() { L_obj_set_type_value "$@" ""; }

# L_obj_set_default_value obj [part...] = type default
L_obj_set_type_default_value() {
  local -n _L_obj=$1
  local L_RET _L_type=${*:$#-1:1}
  if [[ "${*:$#-2:1}" != "=" ]]; then L_func_error "+= missing"; return "$L_EX_USAGE"; fi
  _L_obj_descend_vL_RET "${@:2:$#-4}" || return
  case ${_L_obj[L_RET]} in MAP|ARRAY)
    L_func_error "Can't set container to scalar"
    return 1
  esac
  _L_obj[L_RET]=$_L_type
  case "$_L_type" in
    MAP|ARRAY) ;;
    *) _L_obj[L_RET+2]=${!#} ;;
  esac
}

_L_obj_infer_type_from_value_vL_RET() {
  if [[ $1 =~ ^[-+]?(0|[1-9][0-9]*)((\.[0-9]+)?([eE][+-]?[0-9]+)?)$ ]]; then
    if [[ -z "${BASH_REMATCH[2]}" ]]; then
      L_RET=INTEGER
    else
      L_RET=FLOAT
    fi
  else
    L_RET=STRING
  fi
}

# L_obj_set_type_value obj [part...] = value
L_obj_set_value() {
  local L_RET
  _L_obj_infer_type_from_value_vL_RET "${!#}"
  L_obj_set_type_value "${@:1:$#-1}" "$L_RET" "${!#}"
}

# L_obj_set_default_value obj [part...] = default
L_obj_set_default_value() {
  local L_RET
  _L_obj_infer_type_from_value_vL_RET "${!#}"
  L_obj_set_type_default_value "${@:1$#-1}" "$L_RET" "${!#}"
}

_L_obj_rm_fill_stack() {
  case ${_L_obj[$1]} in
    MAP|ARRAY)
      local _L_child=${_L_obj[$1+2]}
      while [[ -n $_L_child ]]; do
        _L_stack+=("$_L_child")
        _L_child=${_L_obj[_L_child+3]}
      done
      ;;
    STRING|INTEGER|FLOAT|BOOL|NULL) ;;       # leaf: nothing to push
    *) L_func_error "internal error: \$1=$1 \${_L_obj[\$1]}=${_L_obj[$1]}"; return 1 ;;
  esac
}

# L_obj_rm obj [part...]  -> remove the node at the path and free its subtree
# return 1 if the path doesn't exist. No parts = clear the whole object.
L_obj_rm() {
  local -n _L_obj=$1
  if (( ! ${#_L_obj[@]} )); then
    L_func_error "cannot remove from empty object"
    return 1
  fi
  if (( $# == 1 )); then
    _L_obj=()
    return
  fi
  local L_RET
  _L_obj_get_raw_idx_of_vL_RET "${@:2}" || return
  local _L_idx=$L_RET _L_par=${L_RET[1]:-} _L_arg _L_cur _L_child _L_prev _L_next _L_stack=()
  if (( _L_idx )); then
    # unlink from the sibling list, or from the parent's first-child field
    _L_prev=${_L_obj[_L_idx+4]} _L_next=${_L_obj[_L_idx+3]}
    if [[ -n $_L_prev ]]; then _L_obj[_L_prev+3]=$_L_next; else _L_obj[_L_par+2]=$_L_next; fi
    if [[ -n $_L_next ]]; then _L_obj[_L_next+4]=$_L_prev; fi
    _L_stack=("$_L_idx")
  else
    # root: free its children, keep node 0 and the free-list head in its key field
    _L_obj_rm_fill_stack 0
    _L_obj[0]="FREE" _L_obj[2]= _L_obj[3]= _L_obj[4]=
  fi
  # free the subtree iteratively, pushing children before freeing the node
  while (( ${#_L_stack[@]} )); do
    _L_cur=${_L_stack[-1]}
    unset '_L_stack[-1]'
    _L_obj_rm_fill_stack "$_L_cur"
    _L_obj[_L_cur]="FREE" _L_obj[_L_cur+1]= _L_obj[_L_cur+2]= _L_obj[_L_cur+3]=${_L_obj[1]} _L_obj[_L_cur+4]=
    _L_obj[1]=$_L_cur
  done
}

L_obj_print_table() {
  local -n _L_obj=$1
  local _L_idx=0 _L_buf="[idx]|kind|key|val|next|prev" _L_tmp
  for (( _L_idx = 0; _L_idx < ${#_L_obj[@]}; _L_idx += 5 )); do
    printf -v _L_tmp "[%d]" "$_L_idx"
    _L_buf+=$'\n'$_L_tmp
    printf -v _L_tmp "|%q" "${_L_obj[@]:_L_idx:5}"
    _L_buf+=$_L_tmp
  done
  L_table -t -s '|' "$_L_buf"
}

# L_obj_walk obj cb...
#   cb... START <type> <parts...>          type: MAP|ARRAY
#   cb... VALUE <type> <value> <parts...>  type: STRING|INTEGER|FLOAT|BOOL|NULL
#   cb... END   <type> <parts...>
# Parts exclude the root. A nonzero callback return aborts the walk and is returned.
L_obj_walk() {
  local -n _L_obj=$1
  shift
  (( ${#_L_obj[@]} )) || return 0
  local _L_cur=0 _L_parts=() _L_stack=() _L_kind _L_next _L_par
  while :; do
    _L_kind=${_L_obj[_L_cur]}
    case $_L_kind in
      MAP|ARRAY)
        "$@" START "$_L_kind" "${_L_parts[@]}" || return
        _L_next=${_L_obj[_L_cur+2]}
        if [[ -n $_L_next ]]; then
          # descend into the first child
          _L_stack+=("$_L_cur")
          if [[ $_L_kind == MAP ]]; then
            _L_parts+=("${_L_obj[_L_next+1]}")
          else
            _L_parts+=(0)
          fi
          _L_cur=$_L_next
          continue
        fi
        "$@" END "$_L_kind" "${_L_parts[@]}" || return   # empty container
        ;;
      # STRING|INTEGER|FLOAT|BOOL|NULL)
      *) "$@" VALUE "$_L_kind" "${_L_obj[_L_cur+2]}" "${_L_parts[@]}" || return ;;
    esac
    # advance to the next sibling, closing parents that are exhausted
    while :; do
      (( ${#_L_stack[@]} )) || return 0
      _L_par=${_L_stack[-1]}
      _L_next=${_L_obj[_L_cur+3]}
      if [[ -n $_L_next ]]; then
        if [[ ${_L_obj[_L_par]} == MAP ]]; then
          _L_parts[-1]=${_L_obj[_L_next+1]}
        else
          _L_parts[-1]=$(( _L_parts[-1] + 1 ))
        fi
        _L_cur=$_L_next
        break
      fi
      unset '_L_parts[-1]' '_L_stack[-1]'
      "$@" END "${_L_obj[_L_par]}" "${_L_parts[@]}" || return
      _L_cur=$_L_par
    done
  done
}

# L_obj_keys [-v var] obj [part...]
# Keys of the MAP at the path (insertion order), or indices 0..n-1 for an ARRAY.
# Returns 1 if the path is missing or the node is a scalar.
L_obj_keys() { L_handle_v_array "$@"; }
L_obj_keys_vL_RET() {
  local -n _L_obj=$1
  _L_obj_get_raw_idx_of_vL_RET "${@:2}" || return
  local _L_cur=$L_RET _L_i=0
  L_RET=()
  case ${_L_obj[_L_cur]} in
    MAP)
      for (( _L_cur = _L_obj[_L_cur+2]; _L_cur; _L_cur = _L_obj[_L_cur+3] )); do
        L_RET+=("${_L_obj[_L_cur+1]}")
      done
      ;;
    ARRAY)
      for (( _L_cur = _L_obj[_L_cur+2]; _L_cur; _L_cur = _L_obj[_L_cur+3] )); do
        L_RET+=("$((_L_i++))")
      done
      ;;
    STRING|INTEGER|FLOAT|BOOL|NULL) L_func_error "Scalar value does not have keys"; return "$L_EX_USAGE" ;;
    *) L_func_error "Internal error"; return "$L_EX_DATAERR" ;;
  esac
}

L_obj_len() { L_handle_v_scalar "$@"; }
L_obj_len_vL_RET() {
  local -n _L_obj=$1 || return
  _L_obj_get_raw_idx_of_vL_RET "${@:2}" || return
  local _L_cur=$L_RET _L_i=0
  L_RET=0
  case ${_L_obj[_L_cur]} in
    MAP|ARRAY)
      for (( _L_cur = _L_obj[_L_cur+2]; _L_cur; _L_cur = _L_obj[_L_cur+3] )); do
        L_RET=$((L_RET+1))
      done
      ;;
    STRING|INTEGER|FLOAT|BOOL|NULL) L_RET=${#_L_obj[_L_cur+2]} ;;
    *) L_func_error "Internal error"; return "$L_EX_DATAERR" ;;
  esac
}

L_obj_has() {
  local -n _L_obj=$1 || return
  local L_RET
  _L_obj_get_raw_idx_of_vL_RET "${@:2}" 2>/dev/null
}

L_obj_has_scalar() {
  local -n _L_obj=$1 || return
  local L_RET
  _L_obj_get_raw_idx_of_vL_RET "${@:2}" 2>/dev/null || return 1
  case "${_L_obj[L_RET]}" in MAP|ARRAY|FREE|"") return 1 ;; esac
}

L_obj_has_type() {
  local -n _L_obj=$1 || return
  local L_RET
  _L_obj_get_raw_idx_of_vL_RET "${@:2:$#-2}" 2>/dev/null || return 1
  [[ "${_L_obj[L_RET]}" == "${!#}" ]]
}

# L_obj_string_append obj [parts...] += value
L_obj_string_append() {
  local -n _L_obj=$1 || return
  local L_RET
  if [[ "${*:$#-1:1}" != "+=" ]]; then L_func_error "+= missing"; return "$L_EX_USAGE"; fi
  _L_obj_get_raw_idx_of_vL_RET "${@:2:$#-3}" || return 1
  case "${_L_obj[L_RET]}" in
    MAP|ARRAY)
      L_func_error "cannot append ${!#} in $1: it is type ${_L_obj[L_RET]}, expected string"
      return "$L_EX_USAGE"
      ;;
    STRING) ;;
    *) _L_obj[L_RET]=STRING ;;
  esac
  _L_obj[L_RET+2]+=${!#}
}

# L_obj_array_append_type_value obj [parts...] += type value
L_obj_array_append_type_value() {
  local -n _L_obj=$1
  local _L_type=${@:$#-1:1} _L_value=${!#} L_RET _L_cur _L_new _L_last=""
  if [[ "${*:$#-2:1}" != "+=" ]]; then L_func_error "+= missing"; return "$L_EX_USAGE"; fi
  if (( $# < 3 )); then
    L_func_usage_error "Not enough arguments"
    return "$L_EX_USAGE"
  fi
  _L_obj_descend_vL_RET "${@:2:$#-4}" || return
  _L_cur=$L_RET
  if [[ ${_L_obj[_L_cur]:=ARRAY} != "ARRAY" ]]; then
    L_func_error "cannot append to $1: node is ${_L_obj[_L_cur]}, expected ARRAY"
    return "$L_EX_DATAERR"
  fi
  # find the tail
  _L_new=${_L_obj[_L_cur+2]}
  while [[ -n $_L_new ]]; do
    _L_last=$_L_new
    _L_new=${_L_obj[_L_new+3]}
  done
  # allocate: free-list head is obj[1], otherwise grow the array
  _L_new=${_L_obj[1]:-${#_L_obj[@]}}
  if [[ -n ${_L_obj[1]} ]]; then _L_obj[1]=${_L_obj[_L_new+3]}; fi
  # fill and link at the tail
  _L_obj[_L_new]=$_L_type _L_obj[_L_new+1]= _L_obj[_L_new+2]=$_L_value _L_obj[_L_new+3]= _L_obj[_L_new+4]=$_L_last
  if [[ -n $_L_last ]]; then
    _L_obj[_L_last+3]=$_L_new
  else
    _L_obj[_L_cur+2]=$_L_new
  fi
}

# L_obj_array_append_value obj [parts...] += value
# Appends a scalar to the ARRAY at the path. Creates the array if the path is missing
# (or the node is untyped). Returns 1 if the node is not an array.
L_obj_array_append_value() {
  local L_RET
  _L_obj_infer_type_from_value_vL_RET "${!#}"
  L_obj_array_append_type_value "${@:1:$#-1}" "$L_RET" "${!#}"
}

L_obj_get_value_idx_of_vL_RET() {
  _L_obj_get_raw_idx_of_vL_RET "$@"
  L_RET=$((L_RET+2))
}

###############################################################################

_L_test_dotkey_1() {
  {
    L_dotkey_join_vL_RET word word 3
    L_dotkey_split_vL_RET "$L_RET"
    L_unittest_arreq L_RET word word 3
  }
  {
    L_dotkey_join_vL_RET word word 3 $'\t' $'\2' $'\2D' $'\2E' $'\3'
    L_dotkey_split_vL_RET "$L_RET"
    L_unittest_arreq L_RET word word 3 $'\t' $'\2' $'\2D' $'\2E' $'\3'
  }
}

_L_test_obj_1() {
  local L_RET
  local obj
  {
    # # {"a":{"b":[1,2,3]}}
    L_obj_set_value obj a b 0 = 1
    L_obj_set_value obj a b 1 = 2
    L_obj_set_value obj a b 2 = 3
    L_obj_set_value obj a c = dead1
    L_obj_set_value obj a d = dead2
    L_obj_set_value obj a f = dead3
    L_obj_get_vL_RET obj a b 0
    L_unittest_vareq L_RET 1
    L_obj_get_vL_RET obj a b 1
    L_unittest_vareq L_RET 2
    L_obj_get_vL_RET obj a b 2
    L_unittest_vareq L_RET 3
    L_obj_get_vL_RET obj a c
    L_unittest_vareq L_RET dead1
    L_obj_get_vL_RET obj a d
    L_unittest_vareq L_RET dead2
    L_obj_get_vL_RET obj a f
    L_unittest_vareq L_RET dead3
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 3
    L_obj_len_vL_RET obj a
    L_unittest_vareq L_RET 4
    L_obj_len_vL_RET obj a b 1
    L_unittest_vareq L_RET 1
    L_obj_len_vL_RET obj a c
    L_unittest_vareq L_RET 5
    #
    L_unittest_cmd -r '.*' ! L_obj_len_vL_RET obj a b c
  }
  {
    L_obj_array_append_value obj a b += 4
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 4
    L_obj_array_append_value obj a b += 5
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 5
  }
  {
    L_obj_string_append obj a f += dead
    L_obj_get_vL_RET obj a f
    L_unittest_vareq L_RET dead3dead
  }
  L_obj_print_table obj
  L_pp obj
}

_L_test_obj_2() {
  local L_RET
  local obj=()
  local stations=(warsaw "krakow.south" gdansk)
  local sensors=(temperature humidity pressure)
  local units=(C % hPa)
  local station base i s tick n

  # build the skeleton: stations.<station>.sensors.<0..2>.{name,unit}
  for station in "${stations[@]}"; do
    L_obj_set_value obj stations "$station" name = "$station"
    for i in "${!sensors[@]}"; do
      L_obj_set_value obj stations "$station" sensors "$i" name = "${sensors[i]}"
      L_obj_set_value obj stations "$station" sensors "$i" unit = "${units[i]}"
    done
  done

  # simulate 5 sampling ticks; the first tick seeds readings.1, the rest append
  for tick in 1 2 3 4 5; do
    for station in "${stations[@]}"; do
      base=(stations "$station")
      for s in 0 1 2; do
        L_obj_array_append_value obj "${base[@]}" sensors "$s" readings += "$(( RANDOM % 100 ))"
      done
    done
    L_obj_set_value obj last_update = "$EPOCHSECONDS"
  done

  L_obj_print_table obj

    # --- lookups and lengths
  base=(stations krakow.south)
  L_obj_get_vL_RET obj "${base[@]}" name
  L_unittest_vareq L_RET krakow.south
  L_obj_len_vL_RET obj "${base[@]}" sensors
  L_unittest_vareq L_RET 3
  L_obj_len_vL_RET obj "${base[@]}" sensors 1 readings
  L_unittest_vareq L_RET 5
  L_obj_get_vL_RET obj "${base[@]}" sensors 2 unit
  L_unittest_vareq L_RET hPa

  # --- iteration 1: by index (arrays), average each sensor of one station
  L_obj_len -v nsensors obj "${base[@]}" sensors
  for (( s = 0; s < nsensors; s++ )); do
    local sum=0 name unit
    L_obj_get -v name obj "${base[@]}" sensors "$s" name
    L_obj_get -v unit obj "${base[@]}" sensors "$s" unit
    L_obj_len -v n obj "${base[@]}" sensors "$s" readings
    for (( i = 0; i < n; i++ )); do
      L_obj_get -v L_RET obj "${base[@]}" sensors "$s" readings "$i"
      (( sum += L_RET ))
    done
    printf '%s avg=%d%s (n=%d)\n' "$name" $(( sum / n )) "$unit" "$n"
  done

  # --- iteration 2: walk everything
  # prints an indented tree; section parts arrive unescaped
  obj_walk_cb() {
    local event=$1
    shift
    case $event in
    START) printf '%*s%s:\n' $(( ($# - 2) * 2 )) '' "${!#}" ;;
    VALUE) printf '%*s%s = %s\n' $(( ($# - 3) * 2 )) '' "${!#}" "$2" ;;
    END|META) ;;
    esac
  }
  L_obj_walk obj obj_walk_cb

  # --- iteration 3: flat dump of the raw keys, to see the escaping
  L_obj_print_table obj
}

_L_test_obj_walk() {
  local obj out=""
  L_obj_set_value obj a b = 1
  L_obj_set_value obj c 0 = str
  L_obj_set_value obj c 1 = 1.2
  add_to_out(){
    local tmp
    printf -v tmp "%s " "$@"
    out+=${tmp%% }$'\n'
  }
  L_obj_walk obj add_to_out
  local exp="\
START MAP
START MAP a
VALUE INTEGER 1 a b
END MAP a
START ARRAY c
VALUE STRING str c 0
VALUE FLOAT 1.2 c 1
END ARRAY c
END MAP
"
  sdiff - <<<"$out" <(echo "$exp")
  L_unittest_vareq out "$exp"
}

_L_test_obj_3() {
  # obj=()
  L_obj_set_value obj a b 0 = string
  L_obj_set_value obj a b 1 = string
  L_obj_set_value obj a b 2 = string

  L_obj_array_append_value obj a b += string1
  L_obj_array_append_value obj a b += string2
  L_obj_array_append_value obj a b += string3
  L_obj_array_append_value obj a b += string4

  # L_obj_print_table obj
  L_obj_rm obj a
  # L_obj_rm obj
  # L_obj_set_value obj a b 2 string
  L_obj_set_type obj a b c = MAP
  L_obj_walk obj echo
  L_obj_print_table obj
}

_L_test_obj_rm_add() {
	local out=""
	add_to_out() { out+="$*"$'\n'; }
	_walk() { out=""; L_obj_walk obj add_to_out; }
	{
		# add
		local obj=()
		L_obj_set_value obj a b = x
		_walk
		L_unittest_vareq out "\
START MAP
START MAP a
VALUE STRING x a b
END MAP a
END MAP
"
	}
	{
		# remove leaf, parent stays
		L_obj_rm obj a b
		_walk
		L_unittest_vareq out "\
START MAP
START MAP a
END MAP a
END MAP
"
	}
	{
		# re-add after remove
		L_obj_set_value obj a b = y
		_walk
		L_unittest_vareq out "\
START MAP
START MAP a
VALUE STRING y a b
END MAP a
END MAP
"
	}
	{
		# remove subtree
		L_obj_rm obj a
		_walk
		L_unittest_vareq out "\
START MAP
END MAP
"
	}
	{
		# add array after remove
		L_obj_set_value obj c 0 = s1
		L_obj_array_append_value obj c += s2
		_walk
		L_unittest_vareq out "\
START MAP
START ARRAY c
VALUE STRING s1 c 0
VALUE STRING s2 c 1
END ARRAY c
END MAP
"
	}
	{
		# remove array, add map at the same key
		L_obj_rm obj c
		L_obj_set_type obj c d = MAP
		_walk
		L_unittest_vareq out "\
START MAP
START MAP c
START MAP c d
END MAP c d
END MAP c
END MAP
"
	}
	{
		# remove root content, then add again
		L_obj_rm obj
		L_obj_set_value obj k = v
		_walk
		L_unittest_vareq out "\
START MAP
VALUE STRING v k
END MAP
"
	}
}

###############################################################################
# @section ini .ini file parsers.

_L_strip_into() {
  eval "$1=\${2#\"\${2%%[![:space:]]*}\"}; $1=\${$1%\"\${$1##*[![:space:]]}\"}"
}

_L_ini_value_into() {
  local _L_v _L_q _L_r
  _L_strip_into _L_v "$2"
  if [[ $_L_v == [\"\']* ]]; then
    _L_q=${_L_v:0:1}
    _L_r=${_L_v:1}
    if [[ $_L_r == *"$_L_q"* ]]; then
      printf -v "$1" %s "${_L_r%%"$_L_q"*}"
      return
    fi
    # unterminated quote: fall through and treat as plain text
  fi
  if [[ $_L_v == [\;#]* ]]; then
    printf -v "$1" "%s" ""
  else
    _L_strip_into "$1" "${_L_v%%[[:space:]][;#]*}"
  fi
}

# L_ini_read callback [args...] <input
# Calls: callback... SECTION section
#        callback... KV section key value
#        callback... CONTINUATION section key value
L_ini_read() {
  local _L_line _L_key="" _L_val _L_section="" _L_indented
  while IFS= read -r _L_line || [[ -n $_L_line ]]; do
    _L_line=${_L_line%$'\r'}
    if [[ $_L_line == [[:space:]]* ]]; then
      _L_indented=1
    else
      _L_indented=0
    fi
    _L_strip_into _L_line "$_L_line"
    # blank line or full-line comment
    if [[ -z $_L_line || $_L_line == [\;#]* ]]; then
      continue
    fi
    if [[ "$_L_line" == \[* ]]; then
      # inline comment: whitespace followed by ; or #
      _L_tmp=${_L_line%%[[:space:]][;#]*}
      _L_strip_into _L_line "$_L_tmp"
      if [[ $_L_line == \[*\] ]]; then
        _L_strip_into _L_section "${_L_tmp:1:${#_L_tmp}-2}"
        _L_key=""
        "$@" SECTION "$_L_section" || return
        continue
      fi
    fi
    if (( _L_indented )) && [[ -n $_L_key ]]; then
      _L_ini_value_into _L_val "$_L_line"
      "$@" CONTINUATION "$_L_section" "$_L_key" "$_L_val" || return
    elif [[ $_L_line == [^=:]*[=:]* ]]; then
      _L_strip_into _L_key "${_L_line%%[=:]*}"
      _L_ini_value_into _L_val "${_L_line#*[=:]}"
      "$@" KV "$_L_section" "$_L_key" "$_L_val" || return
    elif [[ -n $_L_key ]]; then
      _L_ini_value_into _L_val "$_L_line"
      "$@" CONTINUATION "$_L_section" "$_L_key" "$_L_val" || return
    fi
  done
}

L_ini_read_into_obj() {
  local -n _L_dest=$1
  _L_ini_cb() {
    local L_RET
    case "$1" in
      KV) L_obj_set_value _L_dest "$2" "$3" = "$4" ;;
      CONTINUATION) L_obj_string_append _L_dest "$2" "$3" += $'\n'"$4" ;;
    esac
  }
  L_ini_read _L_ini_cb
}

# _L_ini_quote VAR LINE
# Quote LINE only when the parser would otherwise mangle it:
#  - contains ; or # (would start a comment)
#  - starts with a quote or [ (would be read as a quoted value / section)
#  - has leading or trailing whitespace (would be trimmed)
#  - is empty and is a continuation (a blank line would be skipped)
# Uses "..." unless the line contains ", then '...'. Fails if it has both.
_L_ini_quote() {
  local _s=$2 quote
  case "$_s" in
    "") if (( ${3:-0} )); then _s="''"; fi ;;
    *[\;#]*|[\"\'\[[:space:]]*|*[[:space:]])
      if [[ $_s == *\"* ]]; then
        quote=\'
      else
        quote=\"
      fi
      # contains both: can't quote
      if [[ $_s == *"$quote"* ]]; then
        return 1
      fi
      _s=$quote$_s$quote
  esac
  printf -v "$1" %s "$_s"
}

# L_ini_from_obj_vL_RET OBJ
# Serializes OBJ (via L_obj_walk_values) to INI text in L_RET.
L_ini_from_obj_vL_RET() {
  local _L_ini_ret="" _L_last_section="" _L_ini_rc=0
  _L_ini_cb() {
    #   cb... VALUE <type> <value> <parts...>  type: STRING|INTEGER|FLOAT|BOOL|NULL
    if [[ "$1" == VALUE ]]; then
      local line quotedline first=1 L_RET section=$4 key=$5 value=$3
      L_pp section key rest
      if [[ $section != "$_L_last_section" ]]; then
        _L_last_section=$section
        _L_ini_ret+="[$section]"$'\n'
      fi
      while :; do
        line=${value%%$'\n'*}
        if ! _L_ini_quote quotedline "$line" "$(( !first ))"; then
          _L_ini_rc=1
          return 1
        fi
        if (( first )); then
          _L_ini_ret+="$key =${quotedline:+ $quotedline}"$'\n'
          first=0
        else
          _L_ini_ret+="  $quotedline"$'\n'
        fi
        [[ $value == *$'\n'* ]] || break
        value=${value#*$'\n'}
      done
    fi
  }
  L_obj_walk "$1" _L_ini_cb || _L_ini_rc=1
  unset -f _L_ini_cb
  L_RET=$_L_ini_ret
  return "$_L_ini_rc"
}

_L_test_ini() {
  IFS= read -d '' -r var <<'EOF' || :
; full-line comment
# another comment

root1 = hello
root2 = "quoted ; not a comment"
root3 = 'single ; also not a comment'

[server]
host = localhost
port = 8080
long = first line
   second line
   third line

[  spaced section  ]
key = value
quoted = "with ; semicolon"
single = 'with # hash'
empty =
bare_no_eq
after = trailing ; comment

[section]
key = first line
    second line
    third line
EOF
  IFS= read -r -d '' expected <<'EOF' || :
root1 = hello
root2 = "quoted ; not a comment"
root3 = "single ; also not a comment"
[server]
host = localhost
port = 8080
long = first line
  second line
  third line
[spaced section]
key = value
quoted = "with ; semicolon"
single = "with # hash"
empty =
  bare_no_eq
after = trailing
[section]
key = first line
  second line
  third line
EOF
  declare out=()
  echo "$var"
  L_ini_read_into_obj out <<<"$var"
  L_obj_print_table out
  L_ini_from_obj_vL_RET out
  if [[ "$L_RET" != "$expected" ]]; then
    sdiff <(<<<"$L_RET" cat) - <<<"$expected" || :
    L_unittest_fail "ini obj roundtrip failure"
    exit 1
  fi
}

###############################################################################
# @section json

# Convert Bash string into Json string.
# @option -v <var>
# @arg <str>
L_json_quote() { L_handle_v_scalar "$@"; }
L_json_quote_vL_RET() {
  if [[ $1 == *[$'\"\\\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f']* ]]; then
		L_RET=${1//\\/\\\\}
		L_RET=${L_RET//\"/\\\"}
		L_RET=${L_RET//$'\b'/\\b}
		L_RET=${L_RET//$'\f'/\\f}
		L_RET=${L_RET//$'\n'/\\n}
		L_RET=${L_RET//$'\r'/\\r}
		L_RET=${L_RET//$'\t'/\\t}
		L_RET=${L_RET//$'\x01'/\\u0001}
		L_RET=${L_RET//$'\x02'/\\u0002}
		L_RET=${L_RET//$'\x03'/\\u0003}
		L_RET=${L_RET//$'\x04'/\\u0004}
		L_RET=${L_RET//$'\x05'/\\u0005}
		L_RET=${L_RET//$'\x06'/\\u0006}
		L_RET=${L_RET//$'\x07'/\\u0007}
		L_RET=${L_RET//$'\x0b'/\\u000b}
		L_RET=${L_RET//$'\x0e'/\\u000e}
		L_RET=${L_RET//$'\x0f'/\\u000f}
		L_RET=${L_RET//$'\x10'/\\u0010}
		L_RET=${L_RET//$'\x11'/\\u0011}
		L_RET=${L_RET//$'\x12'/\\u0012}
		L_RET=${L_RET//$'\x13'/\\u0013}
		L_RET=${L_RET//$'\x14'/\\u0014}
		L_RET=${L_RET//$'\x15'/\\u0015}
		L_RET=${L_RET//$'\x16'/\\u0016}
		L_RET=${L_RET//$'\x17'/\\u0017}
		L_RET=${L_RET//$'\x18'/\\u0018}
		L_RET=${L_RET//$'\x19'/\\u0019}
		L_RET=${L_RET//$'\x1a'/\\u001a}
		L_RET=${L_RET//$'\x1b'/\\u001b}
		L_RET=${L_RET//$'\x1c'/\\u001c}
		L_RET=${L_RET//$'\x1d'/\\u001d}
		L_RET=${L_RET//$'\x1e'/\\u001e}
		L_RET=\"${L_RET//$'\x1f'/\\u001f}\"
	else
		L_RET=\"$1\"
	fi
}

# Convert Bash string into Json string with only ASCII characters.
# @option -v <var>
# @arg <str>
L_json_quote_ascii() { L_handle_v_scalar "$@"; }
L_json_quote_ascii_vL_RET() {
	L_json_quote_vL_RET "$1"
	local _L_s=$L_RET _L_out= _L_pre _L_c _L_cp LC_ALL=C.UTF-8
	while [[ $_L_s == *[^$'\x01'-$'\x7f']* ]]; do
		_L_pre=${_L_s%%[^$'\x01'-$'\x7f']*}  # ASCII run before the first non-ASCII char
		printf -v _L_cp %d "'${_L_s:${#_L_pre}:1}"  # the non-ASCII char
		_L_s=${_L_s:${#_L_pre}+1}
		if ((_L_cp < 0x10000)); then
			printf -v _L_c '\\u%04x' "$_L_cp"
		else
			(( _L_cp -= 0x10000 ))
			printf -v _L_c '\\u%04x\\u%04x' "$((0xd800 + (_L_cp >> 10)))" "$((0xdc00 + (_L_cp & 0x3ff)))"
		fi
		_L_out+="$_L_pre$_L_c"
	done
	L_RET=$_L_out$_L_s
}

# Convert Json string into Bash string.
# @option -v <var>
# @arg <str>
L_json_unquote() { L_handle_v_scalar "$@"; }
_L_json_unquote_unicode_append_L_RET() {
	local _L_hex _L_cp _L_hi _L_lo
	_L_hex=${_L_s:1:4}
	_L_s=${_L_s:5}
	_L_cp=$((16#$_L_hex))
	if (( _L_cp >= 0xDC00 && _L_cp <= 0xDFFF )); then
		L_func_error "Low surrogate without a preceding high surrogate is invalid: $s"
		return "$L_EX_DATAERR"
	fi
	# High surrogate: must be followed immediately by \uXXXX low surrogate.
	if (( _L_cp >= 0xD800 && _L_cp <= 0xDBFF )); then
		case $s in
			\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*)
				_L_lo=${s:2:4}
				_L_lo=$((16#$_L_lo))
				if (( _L_lo < 0xDC00 || _L_lo > 0xDFFF )); then
			    L_func_error "Invalid json unicode sequence: $s"
					return "$L_EX_DATAERR"
				fi
				s=${s:6}
				_L_cp=$((0x10000 + ((_L_cp - 0xD800) << 10) + (_L_lo - 0xDC00)))
				;;
			*)
			  return "$L_EX_DATAERR"
			  ;;
		esac
	fi
	printf -v _L_char '%b' "\\U$(printf '%08x' "$_L_cp")"
	L_RET+=${_L_char}
}
L_json_unquote_vL_RET() {
	local _L_s=$1
	L_RET=
	[[ $_L_s == '"'*'"' ]] || return "$L_EX_DATAERR"
	_L_s=${_L_s:1:${#_L_s}-2}
	while [[ $_L_s == *\\* ]]; do
		L_RET+=${_L_s%%\\*}
		_L_s=${_L_s#*\\}
		case $_L_s in
			"\""*) L_RET+='"' _L_s=${_L_s:1} ;;
			'\'*) L_RET+='\' _L_s=${_L_s:1} ;;
			'/'*) L_RET+='/' _L_s=${_L_s:1} ;;
			b*) L_RET+=$'\b' _L_s=${_L_s:1} ;;
			f*) L_RET+=$'\f' _L_s=${_L_s:1} ;;
			n*) L_RET+=$'\n' _L_s=${_L_s:1} ;;
			r*) L_RET+=$'\r' _L_s=${_L_s:1} ;;
			t*) L_RET+=$'\t' _L_s=${_L_s:1} ;;
			u*)	_L_json_unquote_unicode_append_L_RET || return ;;
			*)
			  L_func_error "Invalid escaped character in a json string: $_L_s"
			  return "$L_EX_DATAERR"
			  ;;
		esac
	done
	L_RET+=$_L_s
}

# Convert json path into an array of elements with "strings" and digits.
# ["a"][0].b -> L_RET=('"a"' 0 '"b"')
# @option -v <var>
# @arg <path>
L_json_path_normalize() { L_handle_v_scalar "$@"; }
L_json_path_normalize_vL_RET() {
  local _L_input=$1 _L_dot='' _L_tmp _L_tok=()
  L_RET=()
  while (( 1 )); do
    case "$_L_input" in
      '["'*)
        if [[ ! "$_L_input" =~ ^\[(\"([^\"$'\x01-\x1f'\\]|\\[\"\\/bfnrt]|\\u[0-9a-fA-F]{4})*\")\] ]]; then
          L_func_error "Unclosed double quote string in bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        L_RET+=("${BASH_REMATCH[1]}")
        ;;
      "['"*)
        if [[ ! "$_L_input" =~ ^\[\'(([^\'$'\x01-\x1f'\\]|\\[\'\\/bfnrt]|\\u[0-9a-fA-F]{4})*)\'\] ]]; then
          L_func_error "Unclosed single quote string in bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        _L_tmp=${BASH_REMATCH[1]//\\\'/\'}   # \'  -> '   (undo single-quote escaping)
        L_RET+=("${_L_tmp//\"/\\\"}")   # "   -> \"  (escape bare " for double-quote context)
        ;;
      '['[0-9]*)
        if [[ ! "$_L_input" =~ ^'['(0|[1-9][0-9]*)']' ]]; then
          L_func_error "Invalid bracket notation: $1"; return "$L_EX_DATAERR"
        fi
        L_RET+=("${BASH_REMATCH[1]}")
        ;;
      $_L_dot[^$'\x01-\x1f'"\\.\[\]@#%^&*+=|/?!~\`'\";:,{}()<>-"]*)
        if [[ ! "$_L_input" =~ ^$_L_dot([^"]"$'\x01-\x1f'"\\.\[@#%^&*+=|/?!~\`'\";:,{}()<>-"]+) ]]; then
          L_func_error "Empty key in JSON path: $1"; return "$L_EX_DATAERR"
        fi
        L_RET+=("\"${BASH_REMATCH[1]}\"")
        ;;
      '') break ;;
      *) L_func_error "Invalid character in JSON path: $1"; return "$L_EX_DATAERR" ;;
    esac
    _L_input="${_L_input:${#BASH_REMATCH[0]}}"
    _L_dot="."
  done
}

# Parse a JSON-path expression (dot/bracket notation) into an L_obj key.
# @option -v <var>
# @arg <path>
# @example
#   L_json_path_to_obj_key -v key 'a.b["c.d"][0]'
#   # key now holds the packed L_obj key for:
#   # map "a" -> map "b" -> map "c.d" -> array index 0
L_json_path_to_obj_key() { L_handle_v_scalar "$@"; }
L_json_path_to_obj_key_vL_RET() {
  L_json_path_normalize_vL_RET
  local _L_tmp _L_i
  for _L_i in "${!L_RET[@]}"; do
    if [[ "${L_RET[_L_i]}" == '"'* ]]; then
      if (( _L_i != 0 )); then
        _L_tmp=${L_RET[0]}
      fi
      L_json_unquote_vL_RET "${L_RET[_L_i]}" || return
      if (( _L_i != 0 )); then
        L_RET[_L_i]=${L_RET[0]}
        L_RET[0]=$_L_tmp
      fi
    fi
  done
}

_L_float_re='^-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?'
_L_json_str_re=$'"([^"\x01-\x1f''\\]|\\["\\/bfnrt]|\\u[0-9a-fA-F]{4})*"'

# @description Print JSON parsing error.
_L_json_err() {
  local tmp
  printf -v tmp "%q" "${_L_json::64}"
  L_func_error "$1 pos=$(( _L_json_len - ${#_L_json} )) at: \`$tmp'" "$(( ${#FUNCNAME[*]} - _L_json_errdepth + 1 ))"
  return "$L_EX_DATAERR"
}
_L_json_lstrip() {
  _L_json=${_L_json#"${_L_json%%[!$' \t\r\n']*}"}
}
_L_json_parse_string() {
  if [[ "$_L_json" =~ ^[$' \t\r\n']*($_L_json_str_re) ]]; then
    if ! L_json_unquote_vL_RET "${BASH_REMATCH[1]}"; then
      _L_json_err "invalid json string: ${BASH_REMATCH[1]}" || return
    fi
    _L_string=("$L_RET" "${BASH_REMATCH[1]}")
    _L_json="${_L_json:${#BASH_REMATCH[0]}}"
  else
    _L_json_err "Expected string"
  fi
}
_L_json_parse_object_element() {
  _L_json_parse_string || return
  "$_L_json_cb" KEY "${_L_string[@]}" || return
  _L_json_lstrip
  if [[ "$_L_json" != :* ]]; then
    _L_json_err "Missing ':'"; return
  fi
  "$_L_json_cb" TOKEN ":" || return
  _L_json=${_L_json:1} _L_json_type="dict" _L_JSON_PATH+=("$_L_string")
  _L_json_parse_value || return
  unset "_L_JSON_PATH[${#_L_JSON_PATH[@]}-1]"
}
_L_json_parse_array_element() {
  _L_json_type="array" _L_JSON_PATH+=("$((_L_idx++))")
  _L_json_parse_value || return;
  unset "_L_JSON_PATH[${#_L_JSON_PATH[@]}-1]"
}
_L_json_parse_value() {
  local _L_tmp _L_string _L_idx=0
  case "$_L_json" in
    [$' \t\r\n']*) _L_json_lstrip; _L_json_parse_value; return ;;
    '"'*)
      _L_json_parse_string || return
      "$_L_json_cb" VALUE "${_L_string[0]}" STRING "${_L_string[1]}" || return
      ;;
    [-0-9]*)
      if [[ "$_L_json" =~ $_L_float_re ]]; then
        if [[ -n ${BASH_REMATCH[2]}${BASH_REMATCH[3]} ]]; then
          "$_L_json_cb" VALUE "${BASH_REMATCH[0]}" FLOAT || return
        else
          "$_L_json_cb" VALUE "${BASH_REMATCH[0]}" INTEGER || return
        fi
        _L_json=${_L_json:${#BASH_REMATCH[0]}}
      else
        _L_json_err "Invalid number"; return
      fi
      ;;
    '{'*)
      "$_L_json_cb" START "{" || return
      _L_json=${_L_json:1}
      while (( 1 )); do
        case "$_L_json" in
          [$' \t\r\n']*) _L_json_lstrip; continue ;;
          '"'*) _L_json_parse_object_element || return ;;
          '}'*) _L_json=${_L_json:1}; "$_L_json_cb" END "}" || return; return ;;
          '') _L_json_err "Unexpected EOF"; return ;;
          *) _L_json_err "Invalid object element"; return
        esac
        while
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1}; "$_L_json_cb" TOKEN "," || return ;;
            '}'*) _L_json=${_L_json:1}; "$_L_json_cb" END "}" || return; return ;;
            '') _L_json_err "Unexpected EOF"; return ;;
            *) _L_json_err "Invalid object element"; return
          esac
        do
          _L_json_parse_object_element || return
        done
        _L_json_err "Missing object end '}'"; return
      done
      ;;
    '['*)
      "$_L_json_cb" START "[" || return
      _L_json=${_L_json:1}
      while (( 1 )); do
        case "$_L_json" in
          [$' \t\r\n']*) _L_json_lstrip; continue ;;
          ']'*) _L_json=${_L_json:1}; "$_L_json_cb" END ']' || return; return ;;
          *) _L_json_parse_array_element || return ;;
        esac
        while
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1}; "$_L_json_cb" TOKEN "," || return ;;
            ']'*) _L_json=${_L_json:1}; "$_L_json_cb" END ']' || return; return ;;
            '') _L_json_err "Unexpected EOF"; return ;;
            *) _L_json_err "Invalid array element"; return ;;
          esac
        do
          _L_json_parse_array_element || return
        done
        _L_json_err "Missing array end ']'"; return
      done
      ;;
    null*) "$_L_json_cb" VALUE null NULL || return; _L_json=${_L_json:4} ;;
    true*) "$_L_json_cb" VALUE true BOOL || return; _L_json=${_L_json:4} ;;
    false*) "$_L_json_cb" VALUE false BOOL || return; _L_json=${_L_json:5} ;;
    '') _L_json_err "Unexpected EOF"; return ;;
    *) _L_json_err "Invalid value" || return ;;
  esac
}
# Call $1 with:
#   START [{
#   END ]}
#   VALUE parsed_value integer|float|bool|null
#   VALUE parsed_value string raw_value
#   KEY parsed_value raw_value
#   TOKEN ,:
_L_json_parse() {
  local _L_json_len=${#_L_json} _L_json_type _L_JSON_PATH=() _L_json_cb=$1 _L_json_errdepth=${#FUNCNAME[*]}
  _L_json_parse_value || return
  if [[ "$_L_json" == *[!$' \t\r\n']* ]]; then
    _L_json_err "Invalid tokens after value" || return
  fi
}

# Convert a json into an object.
# @arg <object>
# @stdin <json string>
L_json_read_into_obj() {
  local -n _L_json_obj=$1
  local _L_json=$(cat)
  _L_json_into_obj_cb() {
    case "$1" in
      VALUE) L_obj_set_type_value _L_json_obj "${_L_JSON_PATH[@]}" = "$3" "$2" ;;
      START)
        if [[ "$2" == "[" ]]; then
          local _L_type=ARRAY
        else
          local _L_type=MAP
        fi
        L_obj_set_type _L_json_obj "${_L_JSON_PATH[@]}" = "$_L_type"
    esac
  }
  _L_json_parse _L_json_into_obj_cb
}

L_obj_to_json() { L_handle_v_scalar "$@"; }
# callback for L_obj_walk, uses variables of L_obj_to_json
_L_obj_to_json_cb() {
	local ev=$1 type=$2 top val
	shift 2
	if [[ $ev == VALUE ]]; then
		val=$1
		shift
	fi
	top=$(( ${#_L_jt[@]} - 1 ))
	if [[ $ev == END ]]; then
		unset "_L_jt[$top]" "_L_jf[$top]"
		[[ $type == MAP ]] && _L_out+='}' || _L_out+=']'
		return 0
	fi
	if (( top >= 0 )); then
		if (( _L_jf[top] )); then _L_jf[top]=0; else _L_out+=,; fi
		if [[ ${_L_jt[top]} == MAP ]]; then
			L_json_quote_vL_RET "${!#}"
			_L_out+="$L_RET:"
		fi
	fi
	if [[ $ev == START ]]; then
		_L_jt+=("$type") _L_jf+=(1)
		[[ $type == MAP ]] && _L_out+='{' || _L_out+='['
		return 0
	fi
	case $type in
	  STRING) L_json_quote_vL_RET "$val"; _L_out+=$L_RET ;;
	  INTEGER|FLOAT) _L_out+=$val ;;
	  BOOL) case $val in true|1) _L_out+=true ;; *) _L_out+=false ;; esac ;;
	  NULL) _L_out+=null ;;
	esac
}
L_obj_to_json_vL_RET() {
  local _L_v="" _L_out="" _L_js _L_jt=() _L_jf=() _L_i
  L_obj_walk "$1" _L_obj_to_json_cb || return
  L_RET="$_L_out"
}

L_json_is_valid() {
  _L_json_cb() { :; }
  local _L_json="$1"
  _L_json_parse _L_json_cb
}

# Get a value from json including additional info.
# @return (<value> <type> <start_byte_count> <end_byte_count>)
L_json_get_all() { L_handle_v_array "$@"; }
L_json_get_all_vL_RET() {
  local _L_json="$1" _L_orig_json="$1" _L_initlen="${#1}" _L_key _L_start="" _L_end="" \
    _L_value_captured=0 _L_value="" _L_type=""
  L_json_path_to_obj_key -v _L_key "$2" || return
  _L_json_cb() {
    L_obj_key_join_vL_RET "${_L_JSON_PATH[@]}"
    case "$1 $L_RET" in
      "START $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" _L_type=$2 ;;
      "END $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))" _L_type=$2; return 124 ;;
      "VALUE $_L_key") _L_value=$2 _L_type=$3 _L_value_captured=1; return 124 ;;
    esac
  }
  _L_json_parse _L_json_cb || eval "(( $? == 124 )) || return $?"
  if [[ -n "$_L_start" && -n "$_L_end" ]]; then
    L_RET=(
      "${_L_value:-${_L_orig_json:_L_start:_L_end-_L_start}}"
      "$_L_type"
      "$_L_start"
      "$(( _L_end-_L_start ))"
    )
  elif [[ -z "${_L_value:-}" && $_L_value_captured -eq 0 ]]; then
    return 1
  fi
}

# Get a value from json.
L_json_get() { L_handle_v_scalar "$@"; }
L_json_get_vL_RET() { L_json_get_all_vL_RET "$@"; }

# Remove an element from json.
L_json_rm() { L_handle_v_scalar "$@"; }
L_json_rm_vL_RET() {
  L_json_get_all_vL_RET "$1" "$2" || return
  local _L_start=${L_RET[2]} _L_end=${L_RET[3]}
  L_RET="${_L_json::_L_start}"
  L_RET="${L_RET%,}${_L_json:_L_end}"
}

# @description Print nicely looking version of the json.
# @option -a Use only ascii characters escapes in strings.
# @option -c Compact output.
# @option -i <int> Indent count of spaces.
# @option -C <auto|1|0> Color output, auto - autodetect, 1 - force, 0 - don't.
# @option -v <var> Store the output in variable instead of printing it.
# @optino -h Print this help and return 0.
# @arg $1 JSON
L_json_print() {
  local OPTIND OPTARG OPTERR _L_out="" _L_lvl=0 _L_indent=2 _L_last="" _L_empty=() \
    _L_i _L_v="" _L_wide=1 _L_color=auto _L_ascii=0
  while getopts acC:i:v:h _L_i; do
    case "$_L_i" in
      c) _L_wide="" ;;
      i)
        if ! L_is_integer "$OPTARG"; then
          L_func_error "must be an integer: $OPTARG"
          return "$L_EX_USAGE"
        fi
        _L_indent=$OPTARG
        ;;
      a) _L_ascii=1 ;;
      C) _L_color=$OPTARG ;;
      v) _L_v=$OPTARG ;;
			h) L_func_help; return 0 ;;
			*) L_func_usage_error; return "$L_EX_USAGE" ;;
		esac
  done
  shift "$((OPTIND-1))"
  if (( $# != 1 )); then
    L_func_error "expected one positional arguments"
    return "$L_EX_USAGE"
  fi
  case "$_L_color" in
    auto) L_color_detect ;;
    1) local "${L_COLOR_VARIABLES[@]}"; L_color_enable ;;
    *) local "${L_COLOR_VARIABLES[@]}"; L_color_disable ;;
  esac
  local _L_json=$1
  _L_json_parse _L_json_print
  if [[ -n "$_L_v" ]]; then
    printf -v "$_L_v" "%s" "$_L_out"
  else
    printf "%s\n" "$_L_out"
  fi
}
_L_json_print() {
  local indent
  printf -v indent "%*s" "$(( _L_indent * _L_lvl ))" ""
  case "$1 $2" in
    "START "["[{"])
      if [[ -n "$_L_wide" ]]; then
        case "$_L_last" in
          ["{,"]) _L_out+=$'\n'$indent ;;
          ":") _L_out+=" " ;;
        esac
      fi
      (( ++_L_lvl ))
      _L_empty[_L_lvl]=1
      _L_out+="$L_BOLD$2$L_RESET"
      ;;
    "END "["]}"])
      (( _L_lvl-- ))
      printf -v indent "%*s" "$((_L_indent*_L_lvl))" ""
      if (( _L_empty[_L_lvl+1] )); then
        _L_out+=$L_BOLD$2$L_RESET
      else
        _L_out+=${_L_wide:+$'\n'$indent}$L_BOLD$2$L_RESET
      fi
      ;;
    "TOKEN "":")
      if [[ -n "$_L_wide" && "$_L_last" == ["{,"] ]]; then _L_out+=$'\n'; fi
      _L_out+="$L_BOLD$2$L_RESET"
      ;;
    "TOKEN "",") _L_out+="$L_BOLD,$L_RESET" ;;
    KEY*|VALUE*)
      _L_empty[_L_lvl]=0
      if [[ -n "$_L_wide" ]]; then
        case "$_L_last" in
          ["{[,"]) _L_out+=$'\n'$indent ;;
          ":") _L_out+=" " ;;
          *) _L_out+=$indent ;;
        esac
      fi
      if [[ "$1" == "KEY" || $3 == "STRING" ]]; then
        if (( _L_ascii )); then
          L_json_quote_ascii_vL_RET "$2"
        else
          L_json_quote_vL_RET "$2"
        fi
      else
        L_RET=$2
      fi
      if [[ "$1" == KEY ]]; then
        _L_out+=$L_LIGHT_BLUE$L_RET$L_RESET
      elif [[ "$3" == STRING ]]; then
        _L_out+=$L_GREEN$L_RET$L_RESET
      elif [[ "$3" == NULL ]]; then
        _L_out+=$L_DARK_GRAY$L_RET$L_RESET
      else
        _L_out+=$L_RET
      fi
      ;;
    *) _L_json_err "could not print. args: $*"; return "$L_EX_SOFTWARE" ;;
  esac
  _L_last=${2:${#2}-1}
}

###############################################################################

_L_json_test() {
  _L_json_cb() {
    local IFS=" " tmp
    printf -v tmp "%q " "${_L_JSON_PATH[@]}"
    printf "!! context: %-8s | args: %s\n" "$tmp" "$*"
  }
  local _L_json=$1
  echo "$1"
  _L_json_parse _L_json_cb
}
_L_json_test_quiet() {
  local _L_json=$1
  _L_json_parse :
}

declare _L_JSON_TEST1='{ "a" : "b" , "c" : [ "d" , 1 , true ], "e": { "f.": { "g": null } } } '
declare _L_JSON_TEST2='{"str":"a","empty_str":"","esc .\\":"q\"\\\/\b\f\n\r\t\u00e9 .","uni":"ąę😀","int":1,"neg":-1,"zero":0,"float":1.5,"exp":1e3,"negexp":-2.5E-2,"t":true,"f":false,"n":null,"arr":[],"obj":{},"mixed":["d",1,true,null,[],{}],"nest":{"f.":{"g":null}}}'

_L_test_json_1() {
  if L_hash jq; then
    jq . <<<"$_L_JSON_TEST1"
  fi
  _L_json_test "$_L_JSON_TEST1"
}
_L_test_json_2() {
  if L_hash jq; then
    jq . <<<"$_L_JSON_TEST2"
  fi
  _L_json_test "$_L_JSON_TEST2"
}

test_json_roundtrip() {
  local json=$1 compact=$2 compact_ascii=$3
  echo "     input: $json"
  {
    if L_hash jq; then
      echo "jq_compact: $(jq -C -c <<<"$json")"
    fi
    echo "my_compact: $(L_json_print -C 1 -c "$json")"
    echo " cexpected: $compact"
    L_unittest_cmd -o "$compact" L_json_print -c "$json"
    if L_hash jq; then
      L_log '--- jq ---'
      jq <<<"$json"
    fi
  }
  {
    if L_hash jq; then
      echo "jq_-ac: $(jq -C -ac <<<"$json")"
    fi
    echo "my_-ac: $(L_json_print -C 1 -ac "$json")"
    echo "exp-ac: $compact_ascii"
    L_unittest_cmd -o "$compact_ascii" L_json_print -ac "$json"
  }
  {
    if L_hash jq; then
      L_log '--- jq pretty ---'
      jq -ca <<<"$json"
    fi
    L_log '--- my pretty ---'
    L_json_print "$json"
  }
}

_L_test_json_change_1() {
  local j='{"a":"b","c":["d",1,true],"e":{"f.":{"g":null}}}'
  test_json_roundtrip "$_L_JSON_TEST1" "$j" "$j"
}

_L_test_json_change_2() {
  local compact='{"str":"a","empty_str":"","esc .\\":"q\"\\/\b\f\n\r\té .","uni":"ąę😀","int":1,"neg":-1,"zero":0,"float":1.5,"exp":1e3,"negexp":-2.5E-2,"t":true,"f":false,"n":null,"arr":[],"obj":{},"mixed":["d",1,true,null,[],{}],"nest":{"f.":{"g":null}}}'
  local compact_ascii='{"str":"a","empty_str":"","esc .\\":"q\"\\/\b\f\n\r\t\u00e9 .","uni":"\u0105\u0119\ud83d\ude00","int":1,"neg":-1,"zero":0,"float":1.5,"exp":1e3,"negexp":-2.5E-2,"t":true,"f":false,"n":null,"arr":[],"obj":{},"mixed":["d",1,true,null,[],{}],"nest":{"f.":{"g":null}}}'
  test_json_roundtrip "$_L_JSON_TEST2" "$compact" "$compact_ascii"
}

_L_test_json_unquote() {
  # Test basic unquoting
  L_unittest_cmd -o hello L_json_unquote '"hello"'
  L_unittest_cmd -o 'hello world' L_json_unquote '"hello world"'
  L_unittest_cmd -o 'hello"world' L_json_unquote '"hello\"world"'
  L_unittest_cmd -o $'hello\nworld' L_json_unquote '"hello\nworld"'
  L_unittest_cmd -o $'hello\tworld' L_json_unquote '"hello\tworld"'
  L_unittest_cmd -o 'hello\world' L_json_unquote '"hello\\world"'
  L_unittest_cmd -o 'hello/world' L_json_unquote '"hello\/world"'
  L_unittest_cmd -o $'hello\bworld' L_json_unquote '"hello\bworld"'
  L_unittest_cmd -o $'hello\fworld' L_json_unquote '"hello\fworld"'
  L_unittest_cmd -o $'hello\rworld' L_json_unquote '"hello\rworld"'
  L_unittest_cmd -o A L_json_unquote '"A"'
  L_unittest_cmd -o $'ሴ' L_json_unquote '"ሴ"'

  # Test empty string
  L_unittest_cmd -o '' L_json_unquote '""'

  # Test with -v
  local result
  L_json_unquote -v result '"test"'
  L_unittest_eq "$result" 'test'
}

_L_test_json_is_valid() {
  local json jsons

  L_log 'Valid JSON'
  jsons=(
    '{}' '[]' '{"a":1}' '[1,2,3]' '{"a":[1,2,{"b":3}]}'
    '{"a":1,"b":2}' '{"a":1,"b":2,"c":3}'
    'null' 'true' 'false' '"string"'
    '123' '-123.45' '1e10' '1E-5'
    '{"a":"b","c":"d"}'
    '{"a":"b","c":[1,2,3],"d":{"e":"f"}}'
    # Nested empty containers
    '[[]]' '[ [ ] ]' '[[[]]]' '[{}]' '{"a":{}}' '{"a":[]}'
  )
  for json in "${jsons[@]}"; do L_unittest_cmd L_json_is_valid "$json"; done

  L_log 'Valid complex float forms'
  jsons=(
    # Zeros, signs and decimals
    '0' '-0' '0.0' '-0.0' '1.0' '0.5' '-1.5'
    '0.000000000000001' '9999999999999999999'
    # Exponent variations (case, sign, leading zeros in exponent)
    '1E10' '1e+10' '1e-10' '1E+100' '0e0' '1e0' '1e007' '1E00' '100e-2'
    # Mantissa with fraction and exponent combined
    '1.5e3' '1.5e-3' '-1.5e-3' '1.0e0' '6.022e23' '123.456e-78' '1.7976931348623157E308'
    # Complex floats inside containers
    '[1.5,2.5,-3e-3]' '[1E+100 , 2E-100]' '[ -0 , 0 ]' '{"a":1e10,"b":-0.0}' '{"x":6.022e23}'
  )
  for json in "${jsons[@]}"; do L_unittest_cmd L_json_is_valid "$json"; done

  L_log 'Invalid float forms'
  jsons=(
    '1.' '.5' '-.5' '+1' '01' '00' '-'
    '1e' '1e+' '1e-' '1e1.5' '1e1e1' '1e10e5' '1e--1'
    '1..2' '1.2.3' '1.5.3' '1.0.'
    '0x1f' '0b1' '1_000' '1,000'
    'NaN' 'Infinity' 'nan' 'e1' '--1'
    '[1.]' '{"a":+1}' '{"a":.5}'
  )
  for json in "${jsons[@]}"; do L_unittest_cmd ! L_json_is_valid "$json"; done

  L_log 'Invalid JSON'
  jsons=(
    '{' '[' '{a:1}' '{"a":}' '{"a":1,}' '[1,2,]' '{"a":1 "b":2}'
  )
  for json in "${jsons[@]}"; do L_unittest_cmd ! L_json_is_valid "$json"; done

  L_log 'Invalid repeated/doubled structural characters, without whitespace'
  jsons=(
    '{,,}' '[,,]' '[[' ']]' '{{' '}}' '{{}}' ',,'
  )
  for json in "${jsons[@]}"; do L_unittest_cmd ! L_json_is_valid "$json"; done

  L_log 'Invalid repeated/doubled structural characters, with whitespace between them'
  jsons=(
    '{ , , }' '[ , , ]' '[ [' '] ]' '{ {' '} }' '{ { } }' ' , , '
  )
  for json in "${jsons[@]}"; do L_unittest_cmd ! L_json_is_valid "$json"; done
}

_L_test_json_path() {
  L_readarray -t cases <<'EOF'
a[""] 0 "a" ""
["a"] 0 "a"
[""] 0 ""
[0] 0 0
["0"] 0 "0"
["a"][""]["0"][0]["0"] 0 "a" "" "0" 0 "0"
a["\""] 0 "a" "\""
a["\\"] 0 "a" "\\"
a["\\\""] 0 "a" "\\\""
a["\\\\"] 0 "a" "\\\\"
a["\\\\\""] 0 "a" "\\\\\""
a["\\\\\\\""] 0 "a" "\\\\\\\""
["\""] 0 "\""
["\\"] 0 "\\"
["\\\""] 0 "\\\""
["\\\\"] 0 "\\\\"
["\\\\\""] 0 "\\\\\""
["\\\\\\\""] 0 "\\\\\\\""
["a.b[c]d"] 0 "a.b[c]d"
["["] 0 "["
["]"] 0 "]"
["."] 0 "."
[""] 0 ""
["0"] 0 "0"
[0] 0 0
["0"][0]["0"] 0 "0" 0 "0"
["a"]["b"]["c"] 0 "a" "b" "c"
a[0] 0 "a" 0
a["0"] 0 "a" "0"
a["a.b"] 0 "a" "a.b"
["a.b"][0]["c[d]"] 0 "a.b" 0 "c[d]"
["a\\b"] 0 "a\\b"
["a\"b"] 0 "a\"b"
["a\\\\b"] 0 "a\\\\b"
["a\\\\\\\"b"] 0 "a\\\\\\\"b"
["x"]tail 1
["x" 1
["x] 1
["\" 1
["x"y] 1
[x] 1
[] 1
[01] 1
[-1] 1
["a"]["b.c"]["d[e]"]["f\"g"]["h\\i"] 0 "a" "b.c" "d[e]" "f\"g" "h\\i"
[""][0][""][1][""] 0 "" 0 "" 1 ""
["0"][0]["00"][00] 1
["a"][0][1][2][3] 0 "a" 0 1 2 3
a.b.c[0][1].d 0 "a" "b" "c" 0 1 "d"
["a.b"][0]["c.d"][1] 0 "a.b" 0 "c.d" 1
["a[b]"]["c]d"]["[e"] 0 "a[b]" "c]d" "[e"
["\"\""] 0 "\"\""
["\\\\"] 0 "\\\\"
["\\\\\\\\"] 0 "\\\\\\\\"
["\\\\\\\"] 1
["a\\\\\""] 0 "a\\\\\""
["a\\\\\\\""] 0 "a\\\\\\\""
["a\\\\\\\\\""] 0 "a\\\\\\\\\""
["a.b[0].c"] 0 "a.b[0].c"
["\t"] 0 "\t"
["\n"] 0 "\n"
["\r"] 0 "\r"
["\u0000"] 0 "\u0000"
["\\u1234"] 0 "\\u1234"
["a\\u1234b"] 0 "a\\u1234b"
["a"]["b"][999999999999999999999] 0 "a" "b" 999999999999999999999
EOF
  for input in "${cases[@]}"; do
    if [[ -z "$input" ]]; then continue; fi
    IFS=' ' read -ra tmp <<<"$input"
    input=${tmp[0]}
    expectedfail=${tmp[1]}
    expectedoutput=("${tmp[@]:2}")
    if ! L_json_path_normalize -v output "$input"; then
      if (( expectedfail )); then
        continue
      else
        exit 1
      fi
    fi
    exit=$?
    L_pp input " -> " output " !! " expectedoutput " \$?=$exit"
    if (( expectedfail )); then
      L_unittest_ne "$exit" 0
    else
      L_unittest_eq "$exit" 0
    fi
    if (( exit == 0 )); then
      L_unittest_arreq output "${expectedoutput[@]}"
    fi
  done
}

_L_test_json_to_obj() {
  local json back jsons
  L_readarray -t jsons <<'EOF'
{"a":"b","c":"d"}
[1,2,3,4]
{"a":[{"b":"c"}]}
{"a":[{"b":"c"}],"d":[{"e":"f"}]}
123
-1.5
"str"
""
true
false
null
{}
[]
[[]]
[{}]
[[],{}]
{"a":{}}
{"a":[]}
{"a":{},"b":[],"c":null}
{"a":null,"b":false,"c":0,"d":""}
[null,null]
[0,1,2,3,4,5,6,7,8,9,10,11,12]
[[0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11]]
[[1,2],[3,[4,5]]]
[[[[]]]]
[{"a":1},{"a":2},{"a":3}]
{"a":[1,[2,{"b":[3]}]]}
{"a":[{"b":"c"},{"d":"e"}]}
{"a":{"b":{"c":{"d":{"e":"f"}}}}}
{"":"empty key"}
{"":{"":[]}}
{"a.b":1,"a":{"b":2}}
{"a":{"b.c":1},"a.b":{"c":2}}
{"1":"x","2":"y"}
{"0":[1],"1":{"2":3}}
{"k\"\\":"a\nb\tc\u0001","\n":1}
{"VALUE.a":1,"TYPE.b":2}
{"a b":1,"c\td":2}
EOF
  for json in "${jsons[@]}"; do
    echo
    echo "====== $json ======="
    declare obj=()
    L_json_read_into_obj obj <<<"$json"
    # L_pp -m obj
    L_obj_print_table obj
    L_obj_to_json -v back obj
    echo "$back"
    local a b
    a=$(jq -caS <<<"$json")
    b=$(jq -caS <<<"$back")
    L_unittest_eq "$a" "$b"
  done
}

###############################################################################

# Events (same protocol as L_obj_walk, parts are full paths from the root):
#   VALUE <type> <value> <parts...>   type: STRING|INTEGER|FLOAT|BOOL|DATETIME|DATE|TIME
#   START <MAP|ARRAY> <parts...>      inline table / array
#   END   <MAP|ARRAY> <parts...>
#   TABLE MAP <parts...>              [a.b] header, also emitted for each [[a.b]] element (last part is the index)
#   TABLE ARRAY <parts...>            emitted once, before the first [[a.b]] element
# A nonzero callback return aborts the parse and is returned.

_L_toml_bare_re='^[A-Za-z0-9_-]+'
_L_toml_bstr_re=$'^"(([^"\\\\\x01-\x08\x0a-\x1f\x7f]|\\\\[btnfre"\\\\]|\\\\u[0-9a-fA-F]{4}|\\\\U[0-9a-fA-F]{8})*)"'
_L_toml_lstr_re=$'^\'([^\'\x01-\x08\x0a-\x1f\x7f]*)\''
_L_toml_dt_re='^[0-9]{4}-[0-9]{2}-[0-9]{2}([Tt ][0-9]{2}:[0-9]{2}(:[0-9]{2}([.][0-9]+)?)?([Zz]|[+-][0-9]{2}:[0-9]{2})?)?'
_L_toml_time_re='^[0-9]{2}:[0-9]{2}(:[0-9]{2}([.][0-9]+)?)?'
_L_toml_radix_re='^0(x[0-9a-fA-F]+(_[0-9a-fA-F]+)*|o[0-7]+(_[0-7]+)*|b[01]+(_[01]+)*)'
_L_toml_num_re='^[+-]?(0|[1-9][0-9]*(_[0-9]+)*)([.][0-9]+(_[0-9]+)*)?([eE][+-]?[0-9]+(_[0-9]+)*)?'

_L_toml_err() {
	local tmp
	printf -v tmp "%q" "${_L_toml::64}"
	L_func_error "$1 pos=$(( _L_toml_len - ${#_L_toml} )) at: \`$tmp'" "$(( ${#FUNCNAME[*]} - _L_toml_errdepth + 1 ))"
	return "$L_EX_DATAERR"
}

# spaces and tabs
_L_toml_ws() {
	_L_toml=${_L_toml#"${_L_toml%%[!$' \t']*}"}
}

# whitespace, newlines and comments
_L_toml_skip() {
	while :; do
		_L_toml=${_L_toml#"${_L_toml%%[!$' \t\r\n']*}"}
		[[ $_L_toml == '#'* ]] || break
		if [[ $_L_toml == *$'\n'* ]]; then _L_toml=${_L_toml#*$'\n'}; else _L_toml=; fi
	done
}

# rest of the line: optional comment, then newline or EOF
_L_toml_eol() {
	_L_toml_ws
	if [[ $_L_toml == '#'* ]]; then
		if [[ $_L_toml == *$'\n'* ]]; then _L_toml=$'\n'${_L_toml#*$'\n'}; else _L_toml=; fi
	fi
	case $_L_toml in
	  '') ;;
	  $'\r\n'*) _L_toml=${_L_toml:2} ;;
	  $'\n'*) _L_toml=${_L_toml:1} ;;
	  *) _L_toml_err "Expected end of line"; return ;;
	esac
}

# $1 = raw content of a basic string -> L_RET
_L_toml_unescape_vL_RET() {
	local s=$1 out= c h n
	while [[ $s == *\\* ]]; do
		out+=${s%%\\*}
		s=${s#*\\}
		c=${s::1}
		case $c in
		b) out+=$'\b'; s=${s:1} ;;
		t) out+=$'\t'; s=${s:1} ;;
		n) out+=$'\n'; s=${s:1} ;;
		f) out+=$'\f'; s=${s:1} ;;
		r) out+=$'\r'; s=${s:1} ;;
		e) out+=$'\e'; s=${s:1} ;;
		'"') out+='"'; s=${s:1} ;;
		\\) out+='\'; s=${s:1} ;;
		u|U)
			if [[ $c == u ]]; then n=4; else n=8; fi
			h=${s:1:n}
			if [[ ${#h} -ne n || $h == *[!0-9a-fA-F]* ]] ||
				(( 16#$h >= 0xD800 && 16#$h <= 0xDFFF || 16#$h > 0x10FFFF )); then
				_L_toml_err "Invalid unicode escape"; return
			fi
			printf -v h '%08x' "$((16#$h))"
			printf -v c "\\U$h"
			out+=$c
			s=${s:1+n}
			;;
		' '|$'\t'|$'\r'|$'\n')   # line ending backslash: trim whitespace and newlines
			s=${s#"${s%%[!$' \t\r\n']*}"}
			;;
		*) _L_toml_err "Invalid escape"; return ;;
		esac
	done
	L_RET=$out$s
}

# single line "..." or '...' -> L_RET
_L_toml_parse_sstring() {
	local _L_m _L_raw
	case $_L_toml in
	'"'*)
		[[ $_L_toml =~ $_L_toml_bstr_re ]] || { _L_toml_err "Invalid string"; return; }
		_L_m=${BASH_REMATCH[0]} _L_raw=${BASH_REMATCH[1]}
		_L_toml=${_L_toml:${#_L_m}}
		_L_toml_unescape_vL_RET "$_L_raw"
		;;
	*)
		[[ $_L_toml =~ $_L_toml_lstr_re ]] || { _L_toml_err "Invalid string"; return; }
		L_RET=${BASH_REMATCH[1]}
		_L_toml=${_L_toml:${#BASH_REMATCH[0]}}
		;;
	esac
}

# any string -> L_RET
_L_toml_parse_string() {
	local _L_m _L_raw _L_rest
	case $_L_toml in
	'"""'*)
		_L_rest=${_L_toml:3}
		case $_L_rest in $'\r\n'*) _L_rest=${_L_rest:2} ;; $'\n'*) _L_rest=${_L_rest:1} ;; esac
		_L_raw=
		while :; do
			case $_L_rest in
			'"""'*)
				_L_rest=${_L_rest:3}
				if [[ $_L_rest == '"'* ]]; then
					_L_raw+='"'; _L_rest=${_L_rest:1}
					if [[ $_L_rest == '"'* ]]; then _L_raw+='"'; _L_rest=${_L_rest:1}; fi
				fi
				break ;;
			\\?*) _L_raw+=${_L_rest::2}; _L_rest=${_L_rest:2} ;;
			'') _L_toml_err "Unterminated multi-line string"; return ;;
			*)
				_L_m=${_L_rest%%[\"\\]*}
				if [[ -z $_L_m ]]; then _L_m=${_L_rest::1}; fi
				_L_raw+=$_L_m; _L_rest=${_L_rest:${#_L_m}}
				;;
			esac
		done
		_L_toml=$_L_rest
		_L_toml_unescape_vL_RET "$_L_raw"
		;;
	"'''"*)
		_L_rest=${_L_toml:3}
		case $_L_rest in $'\r\n'*) _L_rest=${_L_rest:2} ;; $'\n'*) _L_rest=${_L_rest:1} ;; esac
		if [[ $_L_rest != *"'''"* ]]; then _L_toml_err "Unterminated multi-line string"; return; fi
		L_RET=${_L_rest%%"'''"*}
		_L_rest=${_L_rest#*"'''"}
		if [[ $_L_rest == "'"* ]]; then
			L_RET+="'"; _L_rest=${_L_rest:1}
			if [[ $_L_rest == "'"* ]]; then L_RET+="'"; _L_rest=${_L_rest:1}; fi
		fi
		_L_toml=$_L_rest
		;;
	*) _L_toml_parse_sstring ;;
	esac
}

# a.b."c d".e -> _L_keys
_L_toml_parse_key() {
	_L_keys=()
	while :; do
		_L_toml_ws
		case $_L_toml in
		'"'*|"'"*) _L_toml_parse_sstring || return; _L_keys+=("$L_RET") ;;
		*)
			if [[ $_L_toml =~ $_L_toml_bare_re ]]; then
				_L_keys+=("${BASH_REMATCH[0]}")
				_L_toml=${_L_toml:${#BASH_REMATCH[0]}}
			else
				_L_toml_err "Expected key"; return
			fi
			;;
		esac
		_L_toml_ws
		[[ $_L_toml == .* ]] || break
		_L_toml=${_L_toml:1}
	done
}

# $@ = parts
_L_toml_parse_number() {
	local _L_m _L_v _L_t
	if [[ $_L_toml =~ $_L_toml_dt_re ]]; then
		_L_m=${BASH_REMATCH[0]}
		if [[ -n ${BASH_REMATCH[1]} ]]; then _L_t=DATETIME; else _L_t=DATE; fi
		_L_toml=${_L_toml:${#_L_m}}
		"$_L_toml_cb" VALUE "$_L_t" "$_L_m" "$@"
	elif [[ $_L_toml =~ $_L_toml_time_re ]]; then
		_L_m=${BASH_REMATCH[0]}
		_L_toml=${_L_toml:${#_L_m}}
		"$_L_toml_cb" VALUE TIME "$_L_m" "$@"
	elif [[ $_L_toml =~ $_L_toml_radix_re ]]; then
		_L_m=${BASH_REMATCH[0]}
		_L_toml=${_L_toml:${#_L_m}}
		_L_v=${_L_m//_/}
		case ${_L_v:1:1} in
		x) _L_v=$((16#${_L_v:2})) ;;
		o) _L_v=$((8#${_L_v:2})) ;;
		b) _L_v=$((2#${_L_v:2})) ;;
		esac
		"$_L_toml_cb" VALUE INTEGER "$_L_v" "$@"
	elif [[ $_L_toml =~ ^[+-]?(inf|nan) ]]; then
		_L_m=${BASH_REMATCH[0]}
		_L_toml=${_L_toml:${#_L_m}}
		"$_L_toml_cb" VALUE FLOAT "$_L_m" "$@"
	elif [[ $_L_toml =~ $_L_toml_num_re ]]; then
		_L_m=${BASH_REMATCH[0]}
		if [[ -n ${BASH_REMATCH[3]}${BASH_REMATCH[5]} ]]; then _L_t=FLOAT; else _L_t=INTEGER; fi
		_L_toml=${_L_toml:${#_L_m}}
		_L_v=${_L_m//_/}
		"$_L_toml_cb" VALUE "$_L_t" "${_L_v#+}" "$@"
	else
		_L_toml_err "Invalid number"
	fi
}

# $@ = parts
_L_toml_parse_value() {
	local _L_i=0
	case $_L_toml in
	'"'*|"'"*)
		_L_toml_parse_string || return
		"$_L_toml_cb" VALUE STRING "$L_RET" "$@"
		;;
	true*)  _L_toml=${_L_toml:4}; "$_L_toml_cb" VALUE BOOL true "$@" ;;
	false*) _L_toml=${_L_toml:5}; "$_L_toml_cb" VALUE BOOL false "$@" ;;
	'['*)
		"$_L_toml_cb" START ARRAY "$@" || return
		_L_toml=${_L_toml:1}
		while :; do
			_L_toml_skip
			case $_L_toml in
			']'*) break ;;
			'') _L_toml_err "Unexpected EOF"; return ;;
			esac
			_L_toml_parse_value "$@" "$((_L_i++))" || return
			_L_toml_skip
			case $_L_toml in
			,*) _L_toml=${_L_toml:1} ;;
			']'*) break ;;
			'') _L_toml_err "Unexpected EOF"; return ;;
			*) _L_toml_err "Expected ',' or ']'"; return ;;
			esac
		done
		_L_toml=${_L_toml:1}
		"$_L_toml_cb" END ARRAY "$@"
		;;
	'{'*)
		"$_L_toml_cb" START MAP "$@" || return
		_L_toml=${_L_toml:1}
		_L_toml_ws
		if [[ $_L_toml == '}'* ]]; then
			_L_toml=${_L_toml:1}
		else
			while :; do
				_L_toml_parse_key || return
				_L_toml_ws
				if [[ $_L_toml != =* ]]; then _L_toml_err "Missing '='"; return; fi
				_L_toml=${_L_toml:1}
				_L_toml_ws
				_L_toml_parse_value "$@" "${_L_keys[@]}" || return
				_L_toml_ws
				case $_L_toml in
				,*) _L_toml=${_L_toml:1}; _L_toml_ws ;;
				'}'*) _L_toml=${_L_toml:1}; break ;;
				'') _L_toml_err "Unexpected EOF"; return ;;
				*) _L_toml_err "Expected ',' or '}'"; return ;;
				esac
			done
		fi
		"$_L_toml_cb" END MAP "$@"
		;;
	[0-9+-]*|inf*|nan*) _L_toml_parse_number "$@" ;;
	'') _L_toml_err "Unexpected EOF" ;;
	*) _L_toml_err "Invalid value" ;;
	esac
}

_L_toml_parse_keyval() {
	_L_toml_parse_key || return
	_L_toml_ws
	if [[ $_L_toml != =* ]]; then _L_toml_err "Missing '='"; return; fi
	_L_toml=${_L_toml:1}
	_L_toml_ws
	_L_toml_parse_value "${_L_toml_table[@]}" "${_L_keys[@]}"
}

# [a.b] or [[a.b]] -> sets _L_toml_table
_L_toml_parse_header() {
	local _L_isarr=0 _L_i _L_n _L_k
	if [[ $_L_toml == '[['* ]]; then _L_isarr=1; _L_toml=${_L_toml:2}; else _L_toml=${_L_toml:1}; fi
	_L_toml_parse_key || return
	_L_toml_ws
	if (( _L_isarr )); then
		[[ $_L_toml == ']]'* ]] || { _L_toml_err "Expected ']]'"; return; }
		_L_toml=${_L_toml:2}
	else
		[[ $_L_toml == ']'* ]] || { _L_toml_err "Expected ']'"; return; }
		_L_toml=${_L_toml:1}
	fi
	# resolve: insert the current element index after every parent that is an array of tables
	_L_toml_table=()
	_L_n=${#_L_keys[@]}
	for (( _L_i = 0; _L_i < _L_n; _L_i++ )); do
		_L_toml_table+=("${_L_keys[_L_i]}")
		if (( _L_i < _L_n - 1 )); then
			printf -v _L_k '%s\x1f' "${_L_toml_table[@]}"
			if [[ -n ${_L_toml_aot[$_L_k]+y} ]]; then
				_L_toml_table+=("$(( ${_L_toml_aot[$_L_k]} - 1 ))")
			fi
		fi
	done
	printf -v _L_k '%s\x1f' "${_L_toml_table[@]}"
	if (( _L_isarr )); then
		_L_n=${_L_toml_aot[$_L_k]:-0}
		_L_toml_aot[$_L_k]=$(( _L_n + 1 ))
		(( _L_n )) || "$_L_toml_cb" TABLE ARRAY "${_L_toml_table[@]}" || return
		_L_toml_table+=("$_L_n")
	else
		if [[ -n ${_L_toml_def[$_L_k]+y} ]]; then _L_toml_err "Duplicate table"; return; fi
		_L_toml_def[$_L_k]=1
	fi
	"$_L_toml_cb" TABLE MAP "${_L_toml_table[@]}"
}

_L_toml_parse() {
	local _L_toml_len=${#_L_toml} _L_toml_cb=$1 _L_toml_errdepth=${#FUNCNAME[*]}
	local _L_toml_table=() _L_keys=()
	local -A _L_toml_aot=() _L_toml_def=()
	while :; do
		_L_toml_skip
		case $_L_toml in
		'') break ;;
		'['*) _L_toml_parse_header || return ;;
		*) _L_toml_parse_keyval || return ;;
		esac
		_L_toml_eol || return
	done
}

# @description Parse TOML, call callback for every event.
# @arg $1 callback
# @arg $2 toml string
L_toml_read() {
	local _L_toml=$(cat)
	_L_toml_parse "$1"
}

###############################################################################

_L_test_toml() {
	local out=""
	add_to_out() { out+="$*"$'\n'; }
	L_toml_read add_to_out <<<$'a = 1\n[t]\nb = "x"\n[[arr]]\nc = [1, 2]\n'
	L_unittest_vareq out "\
VALUE INTEGER 1 a
TABLE MAP t
VALUE STRING x t b
TABLE ARRAY arr
TABLE MAP arr 0
START ARRAY arr 0 c
VALUE INTEGER 1 arr 0 c 0
VALUE INTEGER 2 arr 0 c 1
END ARRAY arr 0 c
"
}

###############################################################################

if L_is_main; then
  if [[ "$1" == eval ]]; then
    "$@"
  else
    L_unittest_main -p _L_test_ "$@"
  fi
fi
