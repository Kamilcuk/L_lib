#!/bin/bash
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")"/../bin/L_lib.sh -s

###############################################################################

_L_printf_or_store() { printf ${1:+"-v$1"} "$2%${1:+.}0s" "${@:3}" $'\n'; }

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
L_dotkey_join_vL_RET() { L_RET=("${@//\\/\\\\}"); local IFS=.; L_RET="${L_RET[*]//./\\.}"; }

L_dotkey_split() { L_handle_v_scalar "$@"; }
L_dotkey_split_vL_RET() {
  _L_dotkey_is_valid "$1" || return
  case "$1" in
    *\\*)
      L_RET=${1#.}
      L_RET=${L_RET//$'\2'/$'\2\3'}
      L_RET=${L_RET//\\\\/$'\2\5'}
      L_RET=${L_RET//\\./$'\2\4'}
      L_readarray -t -d . L_RET <<<"$L_RET."
      unset 'L_RET[-1]'
      L_RET=("${L_RET[@]//$'\2\4'/.}")
      L_RET=("${L_RET[@]//$'\2\5'/\\}")
      L_RET=("${L_RET[@]//$'\2\3'/$'\2'}")
      ;;
    *$'\n'*)
      L_readarray -t -d . L_RET <<<"${1#.}."
      unset 'L_RET[-1]'
      ;;
    *)
      IFS=. read -ra L_RET <<<"${1#.}"
      ;;
  esac
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
  local -n _L_obj=$1 || return
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
  local -n _L_obj=$1 || return
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
      *) L_func_error "a scalar '${_L_obj[_L_cur+1]}' is in the way of descending into $_L_arg from $*"; return 1 ;;
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
  local -n _L_obj=$1 || return
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
  local -n _L_obj=$1 || return
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
  local -n _L_obj=$1 || return
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
  local -n _L_obj=$1 || return
  local _L_idx=0 _L_buf="[idx]|kind|key|val|next|prev" _L_tmp
  for (( _L_idx = 0; _L_idx < ${#_L_obj[@]}; _L_idx += 5 )); do
    printf -v _L_tmp "[%d]" "$_L_idx"
    _L_buf+=$'\n'$_L_tmp
    printf -v _L_tmp "|%q" "${_L_obj[@]:_L_idx:5}"
    _L_buf+=$_L_tmp
  done
  L_table -t -s '|' "$_L_buf"
}

# sorts the children of MAP node $1 in place (uses _L_obj from L_obj_walk)
_L_obj_walk_sort() {
	local children=() child i j tmp LC_COLLATE=C
	for (( child = _L_obj[$1+2]; ; child = _L_obj[child+3] )); do
		children+=("$child")
		[[ -n ${_L_obj[child+3]} ]] || break
	done
	(( ${#children[@]} > 1 )) || return 0
	for (( i = 1; i < ${#children[@]}; i++ )); do
		tmp=${children[i]}
		for (( j = i - 1; j >= 0; j-- )); do
			[[ ${_L_obj[children[j]+1]} > ${_L_obj[tmp+1]} ]] || break
			children[j+1]=${children[j]}
		done
		children[j+1]=$tmp
	done
	_L_obj[$1+2]=${children[0]}
	for (( i = 0; i < ${#children[@]}; i++ )); do
		_L_obj[children[i]+3]=${children[i+1]:-}   # next
		_L_obj[children[i]+4]=${children[i-1]:-}   # prev
	done
}

# L_obj_walk obj cb...
#   cb... START <type>      -- <parts...>          type: MAP|ARRAY
#   cb... VALUE <type> <value> <parts...>  type: STRING|INTEGER|FLOAT|BOOL|NULL
#   cb... END   <type>      -- <parts...>
# Parts exclude the root. A nonzero callback return aborts the walk and is returned.
# @option -S sort keys
# @option -h print this help and return 0
L_obj_walk() {
  local OPTIND OPTERR OPTARG _L_c _L_cur=0 _L_parts=() _L_stack=() _L_kind _L_next _L_par _L_sort=0
  while getopts Sh _L_c; do
    case "$_L_c" in
      S) _L_sort=1 ;;
			h) L_func_help; return 0 ;;
			*) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift "$((OPTIND-1))"
  local -n _L_obj=$1 || return
  shift
  (( ${#_L_obj[@]} )) || return 0
  while :; do
    _L_kind=${_L_obj[_L_cur]}
    case $_L_kind in
      MAP|ARRAY)
        "$@" START "$_L_kind" "--" ${_L_parts[@]+"${_L_parts[@]}"} || return
        _L_next=${_L_obj[_L_cur+2]}
        if [[ -n $_L_next ]]; then
          # descend into the first child
          _L_stack+=("$_L_cur")
          if [[ $_L_kind == MAP ]]; then
            if ((_L_sort)); then
              _L_obj_walk_sort "$_L_cur"
              _L_next=${_L_obj[_L_cur+2]}
            fi
            _L_parts+=("${_L_obj[_L_next+1]}")
          else
            _L_parts+=(0)
          fi
          _L_cur=$_L_next
          continue
        fi
        "$@" END "$_L_kind" "--" ${_L_parts[@]+"${_L_parts[@]}"} || return   # empty container
        ;;
      *) "$@" VALUE "$_L_kind" "${_L_obj[_L_cur+2]}" ${_L_parts[@]+"${_L_parts[@]}"} || return ;;
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
      "$@" END "${_L_obj[_L_par]}" "--" ${_L_parts[@]+"${_L_parts[@]}"} || return
      _L_cur=$_L_par
    done
  done
}

# L_obj_keys [-v var] obj [part...]
# Keys of the MAP at the path (insertion order), or indices 0..n-1 for an ARRAY.
# Returns 1 if the path is missing or the node is a scalar.
L_obj_keys() { L_handle_v_array "$@"; }
L_obj_keys_vL_RET() {
  local -n _L_obj=$1 || return
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
  local -n _L_obj=$1 || return
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

# @description Structural compare of two objects. MAP key order is ignored, ARRAY order matters.
# @return 0 if equal, 1 if different
# @arg $1 first object name
# @arg $2 second object name
L_obj_cmp_obj() {
	local -n _L_cmp_a=$1 _L_cmp_b=$2
	if (( ${#_L_cmp_a[@]} == 0 || ${#_L_cmp_b[@]} == 0 )); then
	  return "$(( ${#_L_cmp_a[@]} != ${#_L_cmp_b[@]} ))"
	fi
	_L_obj_cmp_node 0 0
}
# $1 node index in _L_cmp_a, $2 node index in _L_cmp_b
_L_obj_cmp_node() {
	local _L_kind=${_L_cmp_a[$1]} _L_child_a _L_child_b _L_count_a=0 _L_count_b=0
	[[ $_L_kind == "${_L_cmp_b[$2]}" ]] || return 1
	case $_L_kind in
	  MAP)
		  for (( _L_child_a = _L_cmp_a[$1+2]; _L_child_a; _L_child_a = _L_cmp_a[_L_child_a+3] )); do
			  (( ++_L_count_a ))
			  for (( _L_child_b = _L_cmp_b[$2+2]; _L_child_b; _L_child_b = _L_cmp_b[_L_child_b+3] )); do
				  [[ ${_L_cmp_a[_L_child_a+1]} == "${_L_cmp_b[_L_child_b+1]}" ]] && break
			  done
			  (( _L_child_b )) || return 1
			  _L_obj_cmp_node "$_L_child_a" "$_L_child_b" || return 1
		  done
		  for (( _L_child_b = _L_cmp_b[$2+2]; _L_child_b; _L_child_b = _L_cmp_b[_L_child_b+3] )); do
			  (( ++_L_count_b ))
		  done
		  (( _L_count_a == _L_count_b ))
		  ;;
	  ARRAY)
		  _L_child_a=${_L_cmp_a[$1+2]} _L_child_b=${_L_cmp_b[$2+2]}
		  while [[ -n $_L_child_a && -n $_L_child_b ]]; do
			  _L_obj_cmp_node "$_L_child_a" "$_L_child_b" || return 1
			  _L_child_a=${_L_cmp_a[_L_child_a+3]} _L_child_b=${_L_cmp_b[_L_child_b+3]}
		  done
		  [[ -z $_L_child_a && -z $_L_child_b ]]
		  ;;
	  *) [[ ${_L_cmp_a[$1+2]} == "${_L_cmp_b[$2+2]}" ]] ;;
	esac
}


###############################################################################

obj_skip_test() {
  if (( !L_HAS_BASH4_3 )); then
    L_unittest_skip "obj only available on bash 4.3+ becuase of namereference"
    exit 123
  fi
}

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
  obj_skip_test
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
  obj_skip_test
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
    L_obj_set_value obj last_update = "$RANDOM"
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
  L_logrun L_obj_len -v nsensors obj "${base[@]}" sensors
  for (( s = 0; s < nsensors; s++ )); do
    local sum=0 name unit
    L_logrun L_obj_get -v name obj "${base[@]}" sensors "$s" name
    L_logrun L_obj_get -v unit obj "${base[@]}" sensors "$s" unit
    L_logrun L_obj_len -v n obj "${base[@]}" sensors "$s" readings
    for (( i = 0; i < n; i++ )); do
      L_logrun L_obj_get -v L_RET obj "${base[@]}" sensors "$s" readings "$i"
      (( sum += L_RET ))
    done
    printf '%s avg=%d%s (n=%d)\n' "$name" "$(( sum / n ))" "$unit" "$n"
  done

  # --- iteration 2: walk everything
  # prints an indented tree; section parts arrive unescaped
  obj_walk_cb() {
    case $1 in START|VALUE)
      printf '%*s%s = %s\n' "$(( ($# - 4) * 2 ))" '' "${!#}" "$3"
    esac
  }
  L_obj_walk obj obj_walk_cb

  # --- iteration 3: flat dump of the raw keys, to see the escaping
  L_obj_print_table obj
}

_L_test_obj_walk() {
  obj_skip_test
  local obj out=""
  L_obj_set_value obj a b = 1
  L_obj_set_value obj c 0 = str
  L_obj_set_value obj c 1 = 1.2
  add_to_out(){
    local tmp
    printf -v tmp "%s " "$@"
    tmp=${tmp%% }
    out+=${tmp%% }$'\n'
  }
  L_obj_walk obj add_to_out
  local exp="\
START MAP --
START MAP -- a
VALUE INTEGER 1 a b
END MAP -- a
START ARRAY -- c
VALUE STRING str c 0
VALUE FLOAT 1.2 c 1
END ARRAY -- c
END MAP --
"
  sdiff - <<<"$out" <(echo "$exp") || :
  L_unittest_vareq out "$exp"
}

_L_test_obj_3() {
  obj_skip_test
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
  obj_skip_test
	local out=""
	add_to_out() { out+="$*"$'\n'; }
	_walk() { out=""; L_obj_walk obj add_to_out; }
	{
		# add
		local obj=()
		L_obj_set_value obj a b = x
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- a
VALUE STRING x a b
END MAP -- a
END MAP --
"
	}
	{
		# remove leaf, parent stays
		L_obj_rm obj a b
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- a
END MAP -- a
END MAP --
"
	}
	{
		# re-add after remove
		L_obj_set_value obj a b = y
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- a
VALUE STRING y a b
END MAP -- a
END MAP --
"
	}
	{
		# remove subtree
		L_obj_rm obj a
		_walk
		L_unittest_vareq out "\
START MAP --
END MAP --
"
	}
	{
		# add array after remove
		L_obj_set_value obj c 0 = s1
		L_obj_array_append_value obj c += s2
		_walk
		L_unittest_vareq out "\
START MAP --
START ARRAY -- c
VALUE STRING s1 c 0
VALUE STRING s2 c 1
END ARRAY -- c
END MAP --
"
	}
	{
		# remove array, add map at the same key
		L_obj_rm obj c
		L_obj_set_type obj c d = MAP
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- c
START MAP -- c d
END MAP -- c d
END MAP -- c
END MAP --
"
	}
	{
		# remove root content, then add again
		L_obj_rm obj
		L_obj_set_value obj k = v
		_walk
		L_unittest_vareq out "\
START MAP --
VALUE STRING v k
END MAP --
"
	}
}

_L_test_obj_cmp() {
  obj_skip_test
  : todo write test for L_obj_cmp_obj
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

_L_ini_to_obj_cb() {
  local L_RET
  case "$1" in
    KV) L_obj_set_value _L_dest "$2" "$3" = "$4" ;;
    CONTINUATION) L_obj_string_append _L_dest "$2" "$3" += $'\n'"$4" ;;
  esac
}
L_ini_to_obj() {
  local -n _L_dest=$1 || return
  L_ini_read _L_ini_to_obj_cb
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

# Serializes OBJ to INI text.
# @option -v <var> Store output in variable
L_obj_to_ini() {
  local OPTIND OPTERR OPTARG _L_c _L_v="" _L_ini_ret="" _L_last_section="" _L_ini_rc=0 _L_sort=""
  while getopts v: _L_c; do
    case "$_L_c" in
      S) _L_sort=-S ;;
      v) _L_v=$OPTARG ;;
      h) L_func_help; return 0 ;;
      *) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift "$((OPTIND-1))"
  L_obj_walk $_L_sort "$1" _L_obj_to_ini_cb || _L_ini_rc=1
	_L_printf_or_store "$_L_v" "%s" "$_L_ini_ret" || return
  return "$_L_ini_rc"
}
_L_obj_to_ini_cb() {
  #   cb... VALUE <type> <value> <parts...>  type: STRING|INTEGER|FLOAT|BOOL|NULL
  if [[ "$1" == VALUE ]]; then
    local line quotedline first=1 L_RET section=$4 key=$5 value=$3
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

###############################################################################

_L_test_ini() {
  obj_skip_test
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
  declare out=() tmp
  echo "$var"
  L_ini_to_obj out <<<"$var"
  L_obj_print_table out
  L_obj_to_ini -v tmp out
  if [[ "$tmp" != "$expected" ]]; then
    sdiff <(cat <<<"$tmp") - <<<"$expected" || :
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

_L_json_float_re='^-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?'
_L_json_str_re=$'"([^"\x02-\x1f''\\]|\\["\\/bfnrt]|\\u[0-9a-fA-F]{4})*"'

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
  if [[ "$_L_json" =~ ^[$' \t\r\n']*($_L_json_str_re)${1:-} ]]; then
    if ! L_json_unquote_vL_RET "${BASH_REMATCH[1]}"; then
      _L_json_err "Invalid json string: ${BASH_REMATCH[1]}" || return
    fi
    _L_string=("$L_RET" "${BASH_REMATCH[1]}")
    _L_json="${_L_json:${#BASH_REMATCH[0]}}"
  else
    _L_json_err "Expected string${1:+ followed by a ':'}"
  fi
}
_L_json_parse_object_element() {
  _L_json_parse_string $'[ \t\r\n]*:[ \t\r\n]*' || return
  "${_L_json_cb[@]}" KEY "${_L_string[@]}" || return
  _L_json_type="dict" _L_JSON_PATH+=("$_L_string")
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
      "${_L_json_cb[@]}" VALUE "${_L_string[0]}" STRING "${_L_string[1]}" || return
      ;;
    [-0-9]*)
      if [[ "$_L_json" =~ $_L_json_float_re ]]; then
        if [[ -n ${BASH_REMATCH[2]}${BASH_REMATCH[3]} ]]; then
          "${_L_json_cb[@]}" VALUE "${BASH_REMATCH[0]}" FLOAT || return
        else
          "${_L_json_cb[@]}" VALUE "${BASH_REMATCH[0]}" INTEGER || return
        fi
        _L_json=${_L_json:${#BASH_REMATCH[0]}}
      else
        _L_json_err "Invalid number"; return
      fi
      ;;
    '{'*)
      "${_L_json_cb[@]}" START "{" || return
      _L_json=${_L_json:1}
      while (( 1 )); do
        case "$_L_json" in
          [$' \t\r\n']*) _L_json_lstrip; continue ;;
          '"'*) _L_json_parse_object_element || return ;;
          '}'*) _L_json=${_L_json:1}; "${_L_json_cb[@]}" END "}" || return; return ;;
          '') _L_json_err "Unexpected EOF"; return ;;
          *) _L_json_err "Invalid object element"; return
        esac
        while
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1} ;;
            '}'*) _L_json=${_L_json:1}; "${_L_json_cb[@]}" END "}" || return; return ;;
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
      "${_L_json_cb[@]}" START "[" || return
      _L_json=${_L_json:1}
      while (( 1 )); do
        case "$_L_json" in
          [$' \t\r\n']*) _L_json_lstrip; continue ;;
          ']'*) _L_json=${_L_json:1}; "${_L_json_cb[@]}" END ']' || return; return ;;
          *) _L_json_parse_array_element || return ;;
        esac
        while
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1} ;;
            ']'*) _L_json=${_L_json:1}; "${_L_json_cb[@]}" END ']' || return; return ;;
            '') _L_json_err "Unexpected EOF"; return ;;
            *) _L_json_err "Invalid array element"; return ;;
          esac
        do
          _L_json_parse_array_element || return
        done
        _L_json_err "Missing array end ']'"; return
      done
      ;;
    null*) "${_L_json_cb[@]}" VALUE null NULL || return; _L_json=${_L_json:4} ;;
    true*) "${_L_json_cb[@]}" VALUE true BOOL || return; _L_json=${_L_json:4} ;;
    false*) "${_L_json_cb[@]}" VALUE false BOOL || return; _L_json=${_L_json:5} ;;
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
_L_json_parse() {
  local _L_json_len=${#_L_json} _L_json_type _L_JSON_PATH=() _L_json_cb=("$@") _L_json_errdepth=${#FUNCNAME[*]}
  _L_json_parse_value || return
  if [[ "$_L_json" == *[!$' \t\r\n']* ]]; then
    _L_json_err "Invalid tokens after value" || return
  fi
}

# Convert a json into an object.
# @arg <object>
# @arg <offset...>
# @stdin <json string>
L_json_to_obj() {
  local _L_json=$(cat) _L_obj_offset=("${@:2}")
  _L_json_parse _L_json_to_obj_cb "$1"
}
_L_json_to_obj_cb() {
  case "$2" in
    VALUE) L_obj_set_type_value "$1" ${_L_obj_offset[@]+"${_L_obj_offset[@]}"} ${_L_JSON_PATH[@]+"${_L_JSON_PATH[@]}"} = "$4" "$3" ;;
    START)
      if [[ "$3" == "[" ]]; then
        local _L_type=ARRAY
      else
        local _L_type=MAP
      fi
      L_obj_set_type "$1" ${_L_obj_offset[@]+"${_L_obj_offset[@]}"} ${_L_JSON_PATH[@]+"${_L_JSON_PATH[@]}"} = "$_L_type"
  esac
}

# @description Convert obj into json.
# @option -a Use only ascii characters escapes in strings.
# @option -c Compact output.
# @option -i <int> Indent count of spaces.
# @option -C Color output.
# @option -v <var> Store the output in variable instead of printing it.
# @opting -h Print this help and return 0.
# @arg $1 JSON
L_obj_to_json() {
	local OPTIND OPTERR OPTARG _L_o _L_sort="" _L_v="" _L_wide=1 _L_indent_step="  " \
	  _L_json_quote_vL_RET=L_json_quote_vL_RET _L_color=auto \
	  _L_json_out="" _L_jt=() _L_jf=() _L_last="" _L_empty=() _L_indent=""
	while getopts acCi:Shv: _L_o; do
		case "$_L_o" in
			c) _L_wide="" ;;
			i)
				if ! L_is_integer "$OPTARG"; then
					L_func_error "must be an integer: $OPTARG"
					return "$L_EX_USAGE"
				fi
				printf -v _L_indent_step "%*s" "$OPTARG" ""
				;;
			a) _L_json_quote_vL_RET=L_json_quote_ascii_vL_RET ;;
			C) _L_color=1 ;;
			S) _L_sort=-S ;;
			v) _L_v=$OPTARG ;;
			h) L_func_help; return 0 ;;
			*) L_func_usage_error; return "$L_EX_USAGE" ;;
		esac
	done
	shift "$((OPTIND-1))"
	case "$_L_color:$_L_v" in
		auto:) L_color_detect ;;
		1:*) local "${L_COLOR_VARIABLES[@]}"; L_color_enable ;;
		*) local "${L_COLOR_VARIABLES[@]}"; L_color_disable ;;
	esac
	L_obj_walk $_L_sort "$1" _L_obj_to_json_cb || return
	_L_printf_or_store "$_L_v" "%s" "$_L_json_out"
}
# callback for L_obj_walk, uses variables of L_obj_to_json
_L_obj_to_json_cb() {
	local event=$1 type=$2 top=$(( ${#_L_jt[@]} - 1 )) value
	if [[ $event == END ]]; then
		unset "_L_jt[top]" "_L_jf[top]"
		_L_indent=${_L_indent:${#_L_indent_step}}
    if (( !_L_empty[top] )) || [[ "$_L_last" == ["}]"] ]]; then _L_json_out+=${_L_wide:+$'\n'$_L_indent}; fi
		if [[ $type == MAP ]]; then _L_last='}'; else _L_last="]"; fi
		_L_json_out+="$L_BOLD$_L_last$L_RESET"
  else
	  if (( top >= 0 )); then
      if [[ "$_L_last" == ["[{,"] ]]; then _L_json_out+=${_L_wide:+$'\n'"$_L_indent"}; fi
		  if (( _L_jf[top] )); then _L_jf[top]=0; else _L_json_out+="$L_BOLD,$L_RESET"${_L_wide:+$'\n'"$_L_indent"}; fi
		  if [[ ${_L_jt[top]} == MAP ]]; then
			  L_json_quote_vL_RET "${!#}"
			  _L_json_out+="$L_BLUE$L_RET$L_RESET$L_BOLD:$L_RESET${_L_wide:+ }"
			  _L_last=":"
		  fi
	  fi
	  if [[ $event == START ]]; then
		  _L_indent+=$_L_indent_step _L_empty[top+1]=1 _L_jt+=("$type") _L_jf+=(1)
		  if [[ $type == MAP ]]; then _L_last="{"; else _L_last="["; fi
			_L_json_out+="$L_BOLD$_L_last$L_RESET"
	  elif [[ $event == VALUE ]]; then
	    # Top will be lower then 0 when root is a VALUE.
	    value=$3 _L_empty[top < 0 ? 0 : top]=0
	    case $type in
	      INTEGER|FLOAT) _L_json_out+="$value" ;;
	      BOOL) case $value in true|1) _L_json_out+="true" ;; *) _L_json_out+="false" ;; esac ;;
	      NULL) _L_json_out+="$L_DARK_GRAY$value$L_RESET" ;;
	      *) "$_L_json_quote_vL_RET" "$value"; _L_json_out+="$L_GREEN$L_RET$L_RESET" ;;
	    esac
		  _L_last="V"
	  fi
	fi
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
# @option -C Color output.
# @option -v <var> Store the output in variable instead of printing it.
# @opting -h Print this help and return 0.
# @arg $1 JSON
L_json_print() { local _L_json_print_obj; L_json_to_obj _L_json_print_obj && L_obj_to_json "$@" _L_json_print_obj; }

###############################################################################

_L_json_test_parse() {
  _L_json_cb() {
    local IFS=" " tmp
    printf -v tmp "%q " ${_L_JSON_PATH[@]+"${_L_JSON_PATH[@]}"}
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
  _L_json_test_parse "$_L_JSON_TEST1"
}
_L_test_json_2() {
  if L_hash jq; then
    jq . <<<"$_L_JSON_TEST2"
  fi
  _L_json_test_parse "$_L_JSON_TEST2"
}

test_json_roundtrip() {
  local json=$1 compact=$2 compact_ascii=$3
  echo "     input: $json"
  {
    if L_hash jq; then
      echo "jq_compact: $(jq -C -c <<<"$json")"
    fi
    echo "my_compact: $(L_json_print -C -c <<<"$json")"
    echo " cexpected: $compact"
    L_unittest_cmd -Io "$compact" L_json_print -c <<<"$json"
    if L_hash jq; then
      L_log '--- jq ---'
      jq <<<"$json"
    fi
  }
  {
    if L_hash jq; then
      echo "jq_-ac: $(jq -C -ac <<<"$json")"
    fi
    echo "my_-ac: $(L_json_print -C -ac <<<"$json")"
    echo "exp-ac: $compact_ascii"
    L_unittest_cmd -Io "$compact_ascii" L_json_print -ac <<<"$json"
  }
  {
    if L_hash jq; then
      L_log '--- jq pretty ---'
      jq -ca <<<"$json"
    fi
    L_log '--- my pretty ---'
    L_json_print <<<"$json"
  }
}

_L_test_json_change_1() {
  obj_skip_test
  local j='{"a":"b","c":["d",1,true],"e":{"f.":{"g":null}}}'
  test_json_roundtrip "$_L_JSON_TEST1" "$j" "$j"
}

_L_test_json_change_2() {
  obj_skip_test
  local compact='{"str":"a","empty_str":"","esc .\\":"q\"\\/\b\f\n\r\té .","uni":"ąę😀","int":1,"neg":-1,"zero":0,"float":1.5,"exp":1e3,"negexp":-2.5E-2,"t":true,"f":false,"n":null,"arr":[],"obj":{},"mixed":["d",1,true,null,[],{}],"nest":{"f.":{"g":null}}}'
  local compact_ascii='{"str":"a","empty_str":"","esc .\\":"q\"\\/\b\f\n\r\t\u00e9 .","uni":"\u0105\u0119\ud83d\ude00","int":1,"neg":-1,"zero":0,"float":1.5,"exp":1e3,"negexp":-2.5E-2,"t":true,"f":false,"n":null,"arr":[],"obj":{},"mixed":["d",1,true,null,[],{}],"nest":{"f.":{"g":null}}}'
  test_json_roundtrip "$_L_JSON_TEST2" "$compact" "$compact_ascii"
}

_L_test_json_unquote() {
  obj_skip_test
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
  obj_skip_test
  local json jsons

  L_json_is_valid() {
    local _L_json="$1"
    _L_json_parse :
  }

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
  obj_skip_test
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
  obj_skip_test
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
  _checkit() {
    local obj back opts=${1:-}
    echo "====== $opts $json ======="
    L_unittest_cmd -cI L_json_to_obj obj <<<"$json"
    # L_pp -m obj
    L_unittest_cmd -c L_obj_print_table obj
    L_unittest_cmd -c L_obj_to_json -v back $opts obj
    local expected=$(jq $opts <<<"$json")
    if [[ "$back" != "$expected" ]]; then
      sdiff <(cat -A <<<"$back") <(cat -A <<<"$expected") || :
      L_unittest_fail "Output mismatch for $opts $json"
    fi
  }
  for json in "${jsons[@]}"; do
    _checkit
    _checkit -S
    _checkit -c
    _checkit -cS
    _checkit -acS
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

_L_toml_bstr_re='^"(([^"\\[:cntrl:]]|\\[btnfre"\\]|\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8})*)"'
_L_toml_lstr_re="^'([^'[:cntrl:]]*)'"

_L_toml_err() {
	local tmp
	printf -v tmp "%q" "${_L_toml::64}"
	L_func_error "$1 at offset $(( _L_toml_len - ${#_L_toml} )): $tmp" "$(( ${#FUNCNAME[*]} - _L_toml_errdepth + 1 ))"
	return "$L_EX_DATAERR"
}

# spaces and tabs
_L_toml_ws() { _L_toml=${_L_toml#"${_L_toml%%[!$' \t']*}"}; }

# whitespace, newlines and comments
_L_toml_skip() {
	while
		_L_toml=${_L_toml#"${_L_toml%%[!$' \t\r\n']*}"}
		[[ $_L_toml == '#'* ]]
	do
		if [[ $_L_toml == *$'\n'* ]]; then
		  _L_toml=${_L_toml#*$'\n'}
		else
		  _L_toml=
		fi
	done
}

# rest of the line: optional comment, then newline or EOF
_L_toml_eol() {
	_L_toml_ws
	if [[ $_L_toml == '#'* ]]; then
		if [[ $_L_toml == *$'\n'* ]]; then
		  _L_toml=$'\n'${_L_toml#*$'\n'}
		else
		  _L_toml=
		fi
	fi
	case $_L_toml in
	  '') ;;
	  $'\r\n'*) _L_toml=${_L_toml:2} ;;
	  $'\n'*|$'\r') _L_toml=${_L_toml:1} ;;
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
_L_toml_parse_sstring_vL_RET() {
	case $_L_toml in
	'"'*)
		[[ $_L_toml =~ $_L_toml_bstr_re ]] || { _L_toml_err "Invalid \" string"; return; }
		_L_toml_unescape_vL_RET "${BASH_REMATCH[1]}"
		;;
	*)
		[[ $_L_toml =~ $_L_toml_lstr_re ]] || { _L_toml_err "Invalid ' string"; return; }
		L_RET=${BASH_REMATCH[1]}
		;;
	esac
	_L_toml=${_L_toml:${#BASH_REMATCH[0]}}
}

_L_toml_mlbasic_re=$'^"""(\r?\n)?((([^"\\\\]|\\\\.|"{1,2}([^"\\\\]|\\\\.))*)"?"?)"""'

# any string -> L_RET
_L_toml_parse_string() {
	local _L_rest=${_L_toml:3} _L_raw="" _L_m
	case $_L_toml in
	  '"""'*)
	    [[ $_L_toml =~ $_L_toml_mlbasic_re ]] || { _L_toml_err "Unterminated multi-line string"; return; }
	    _L_toml=${_L_toml:${#BASH_REMATCH[0]}}
	    _L_toml_unescape_vL_RET "${BASH_REMATCH[2]}"
	    ;;
	  "'''"*)
		  case $_L_rest in $'\r\n'*) _L_rest=${_L_rest:2} ;; $'\n'*) _L_rest=${_L_rest:1} ;; esac
		  if [[ $_L_rest != *"'''"* ]]; then _L_toml_err "Unterminated multi-line string"; return; fi
		  L_RET=${_L_rest%%"'''"*}
		  _L_rest=${_L_rest#*"'''"}
		  if [[ $_L_rest == "'"* ]]; then
			  L_RET+="'" _L_rest=${_L_rest:1}
			  if [[ $_L_rest == "'"* ]]; then L_RET+="'" _L_rest=${_L_rest:1}; fi
		  fi
		  _L_toml=$_L_rest
		  ;;
	  *) _L_toml_parse_sstring_vL_RET ;;
	esac
}

# a.b."c d".e -> _L_keys
_L_toml_parse_key_v_L_keys() {
	_L_keys=()
	while
		_L_toml_ws
		case $_L_toml in
		  '"'*|"'"*) _L_toml_parse_sstring_vL_RET || return; _L_keys+=("$L_RET") ;;
		  *)
			  if [[ $_L_toml =~ ^[A-Za-z0-9_-]+ ]]; then
				  _L_keys+=("${BASH_REMATCH[0]}")
				  _L_toml=${_L_toml:${#BASH_REMATCH[0]}}
			  else
				  _L_toml_err "Expected key"; return
			  fi
			  ;;
		esac
		_L_toml_ws
		[[ $_L_toml == .* ]]
	do
		_L_toml=${_L_toml:1}
	done
}

_L_toml_parse_number() {
	local _L_value _L_type \
	  _L_D='[0-9]{4}-((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01])|(0[469]|11)-(0[1-9]|[12][0-9]|30)|02-(0[1-9]|1[0-9]|2[0-9]))' \
	  _L_T='([01][0-9]|2[0-3]):[0-5][0-9](:([0-5][0-9]|60)([.][0-9]+)?)?' \
	  _L_O='([Zz]|[+-]([01][0-9]|2[0-3]):[0-5][0-9])' \
	  _L_N='[+-]?(0|[1-9][0-9]*(_[0-9]+)*)([.][0-9]+(_[0-9]+)*)?([eE][+-]?[0-9]+(_[0-9]+)*)?' \
	  _L_end=$'[],}# \t\r\n]|$'
	if [[ $_L_toml =~ ^($_L_D([Tt ]$_L_T$_L_O?)?|$_L_T|0[xob][0-9a-fA-F_]+|[+-]?(inf|nan)|$_L_N)($_L_end) ]]; then
		_L_value=${BASH_REMATCH[1]}
		_L_toml=${_L_toml:${#_L_value}}
		case $_L_value in
		  [0-9][0-9][0-9][0-9]-*) _L_type=DATE${BASH_REMATCH[9]:+TIME} ;;
		  [0-9][0-9]:*) _L_type=TIME ;;
		  0[xob]*)
			  _L_type=INTEGER
			  _L_value=${_L_value//_/}
			  case ${_L_value:1:1} in
			    x) _L_value=$((_L_value)) ;;
			    o) _L_value=$((8#${_L_value:2})) ;;
			    b) _L_value=$((2#${_L_value:2})) ;;
			  esac
			  ;;
		  [-+][inf|inf|[+-]nan|nan|*[.eE]*)
			  _L_type=FLOAT
			  _L_value=${_L_value//_/}
			  _L_value=${_L_value#+}
			  ;;
		  [0-9]*|[+-][0-9]*)
			  _L_type=INTEGER
			  _L_value=${_L_value//_/}
			  _L_value=${_L_value#+}
			  ;;
      *) _L_toml_err "Internal error when parsing number: $_L_value" || return ;;
		esac
		"${_L_toml_cb[@]}" VALUE "$_L_type" "$_L_value" "$@"
	else
		_L_toml_err "Invalid number"
	fi
}

# $@ = parts
_L_toml_parse_value() {
	local _L_i=0
	case $_L_toml in
	  ["\"'"]*)
		  _L_toml_parse_string || return
		  "${_L_toml_cb[@]}" VALUE STRING "$L_RET" "$@"
		  ;;
	  true*)  _L_toml=${_L_toml:4}; "${_L_toml_cb[@]}" VALUE BOOL true "$@" ;;
	  false*) _L_toml=${_L_toml:5}; "${_L_toml_cb[@]}" VALUE BOOL false "$@" ;;
	  '['*)
		  "${_L_toml_cb[@]}" START ARRAY "$@" || return
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
		  "${_L_toml_cb[@]}" END ARRAY "$@"
		  ;;
	  '{'*)
		  "${_L_toml_cb[@]}" START MAP "$@" || return
		  _L_toml=${_L_toml:1}
		  _L_toml_ws
		  if [[ $_L_toml == '}'* ]]; then
			  _L_toml=${_L_toml:1}
		  else
			  while :; do
				  _L_toml_parse_key_v_L_keys || return
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
		  "${_L_toml_cb[@]}" END MAP "$@"
		  ;;
	  [0-9+-]*|inf*|nan*) _L_toml_parse_number "$@" ;;
	  '') _L_toml_err "Unexpected EOF" ;;
	  *) _L_toml_err "Invalid value" ;;
	esac
}

_L_toml_parse_keyval() {
	_L_toml_parse_key_v_L_keys || return
	_L_toml_ws
	if [[ $_L_toml != =* ]]; then _L_toml_err "Missing '='"; return; fi
	_L_toml=${_L_toml:1}
	_L_toml_ws
	_L_toml_parse_value ${_L_toml_table[@]+"${_L_toml_table[@]}"} ${_L_keys[@]+"${_L_keys[@]}"}
}

# [a.b] or [[a.b]] -> sets _L_toml_table
_L_toml_parse_header() {
	local _L_isarr=0 _L_i _L_n _L_key
	if [[ $_L_toml == '[['* ]]; then _L_isarr=1; _L_toml=${_L_toml:2}; else _L_toml=${_L_toml:1}; fi
	_L_toml_parse_key_v_L_keys || return
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
			printf -v _L_key '%q ' "${_L_toml_table[@]}"
			if [[ -n ${_L_toml_array_idx["$_L_key"]+y} ]]; then
				_L_toml_table+=("$(( ${_L_toml_array_idx["$_L_key"]} - 1 ))")
			fi
		fi
	done
	printf -v _L_key '%q ' "${_L_toml_table[@]}"
	if (( _L_isarr )); then
		_L_n=${_L_toml_array_idx["$_L_key"]:-0}
		_L_toml_array_idx["$_L_key"]=$(( _L_n + 1 ))
		(( _L_n )) || "${_L_toml_cb[@]}" TABLE ARRAY "${_L_toml_table[@]}" || return
		_L_toml_table+=("$_L_n")
	else
		if [[ -n ${_L_toml_seen_section["$_L_key"]+y} ]]; then _L_toml_err "Duplicate table"; return; fi
		_L_toml_seen_section["$_L_key"]=1
	fi
	"${_L_toml_cb[@]}" TABLE MAP "${_L_toml_table[@]}"
}

_L_toml_parse() {
	local _L_toml_len=${#_L_toml} _L_toml_cb=("$@") _L_toml_errdepth=${#FUNCNAME[*]}
	local _L_toml_table=() _L_keys=()
	local -A _L_toml_array_idx=() _L_toml_seen_section=()
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
# @arg <callback...>
# @stdin <toml>
L_toml_read() {
	local _L_toml=$(cat)
	_L_toml_parse "$@"
}

# Parse TOML into an L_obj.
# @arg $1 obj variable name
# @stdin <toml>
L_toml_to_obj() {
	L_toml_read _L_toml_cb "$1"
}
_L_toml_cb() {
	case "$2" in
		VALUE) L_obj_set_type_value "$1" "${@:5}" = "$3" "$4" ;;
		START|TABLE) L_obj_set_type "$1" "${@:4}" = "$3" ;;
	esac
}

# Characters that must be escaped in a TOML basic string.
_L_toml_special='[\"\\'$'\x01'-$'\x1f\x7f]'

_L_toml_quote_vL_RET() {
	local rest=$1 out= char
	while [[ $rest == *$_L_toml_special* ]]; do
		out+=${rest%%$_L_toml_special*}
		rest=${rest#"${rest%%$_L_toml_special*}"}
		char=${rest::1}
		rest=${rest:1}
		case $char in
		\") out+='\"' ;;
		\\) out+='\\' ;;
		$'\b') out+='\b' ;;
		$'\t') out+='\t' ;;
		$'\n') out+='\n' ;;
		$'\f') out+='\f' ;;
		$'\r') out+='\r' ;;
		*) printf -v char '\\u%04x' "'$char"; out+=$char ;;
		esac
	done
	L_RET="\"$out$rest\""
}

_L_toml_quote_key_vL_RET() {
  if [[ $1 =~ ^[A-Za-z0-9_-]+$ ]]; then L_RET=$1; else _L_toml_quote_vL_RET "$1"; fi
}

# $1 type, $2 value
_L_toml_quote_type_value_vL_RET() {
  case $1 in
    INTEGER|FLOAT|DATETIME|DATE|TIME) L_RET=$2 ;;
    BOOL) case $2 in true|1) L_RET=true ;; *) L_RET=false ;; esac ;;
    NULL) L_RET="" ;;
    *) _L_toml_quote_vL_RET "$2" ;;
  esac
}

# walk 1: for every ARRAY path remember if it has MAP / non-MAP elements
_L_obj_to_toml_scan_cb() {
  local event=$1 type=$2 key
  if [[ $event == END ]]; then
    unset '_L_kinds[-1]'
  else
    if (( ${#_L_kinds[@]} )) && [[ ${_L_kinds[-1]} == ARRAY ]]; then
        printf -v key '%q ' "${@:4:$#-5}"
        if [[ $type == MAP ]]; then _L_hasmap["$key"]=1; else _L_nonmap["$key"]=1; fi
    fi
    if [[ $event == START ]]; then _L_kinds+=("$type"); fi
  fi
}

# walk 2: scalars and inline values go to the buffer of their table, headers are emitted at the end
_L_obj_to_toml_emit_cb() {
  echo "$@"
  local event=$1 type=$2 value=$3 parent=$(( ${#_L_kinds[@]} - 1 )) tmp
  case $event in
  END)
    if (( _L_inline[parent] )); then
      if [[ $type == MAP ]]; then _L_inline_buf+='}'; else _L_inline_buf+=']'; fi
      if (( _L_inline[parent] == 1 )); then _L_bufs[_L_table_ids[parent-1]]+="$_L_inline_key = $_L_inline_buf"$'\n'; fi
    fi
    unset '_L_kinds[-1]' '_L_table_paths[-1]' '_L_table_ids[-1]' '_L_inline[-1]' '_L_first[-1]'
    ;;
  START)
    if (( parent < 0 )); then
      if [[ $type != MAP ]]; then L_func_error "TOML root must be a table"; return 1; fi
      _L_bufs[0]="" _L_kinds+=(MAP) _L_table_paths+=("") _L_table_ids+=(0) _L_inline+=(0) _L_first+=(0)
    else
      if (( _L_inline[parent] )); then
        if (( _L_first[parent] )); then _L_first[parent]=0; else _L_inline_buf+=', '; fi
        if [[ ${_L_kinds[parent]} == MAP ]]; then
            _L_toml_quote_key_vL_RET "${!#}"; _L_inline_buf+="$L_RET = "
        fi
        if [[ $type == MAP ]]; then _L_inline_buf+='{'; else _L_inline_buf+='['; fi
        _L_kinds+=("$type") _L_table_paths+=("") _L_table_ids+=("${_L_table_ids[parent]}") _L_inline+=(2) _L_first+=(1)
      elif [[ ${_L_kinds[parent]} == ARRAY ]]; then
        _L_bufs[++_L_bufcnt]="[[${_L_table_paths[parent]}]]"$'\n'
        _L_kinds+=(MAP) _L_table_paths+=("${_L_table_paths[parent]}") _L_table_ids+=("$_L_bufcnt") _L_inline+=(0) _L_first+=(0)
      else
        _L_toml_quote_key_vL_RET "${!#}"
        local current_path=${_L_table_paths[parent]:+${_L_table_paths[parent]}.}$L_RET
        if [[ $type == MAP ]]; then
          _L_bufs[++_L_bufcnt]="[$current_path]"$'\n'
          _L_kinds+=(MAP) _L_table_paths+=("$current_path") _L_table_ids+=("$_L_bufcnt") _L_inline+=(0) _L_first+=(0)
        else
          printf -v key '%q ' "${@:4:$#-4}"
          if [[ -n ${_L_hasmap["$key"]:-} && -z ${_L_nonmap["$key"]:-} ]]; then
            _L_kinds+=(ARRAY) _L_table_paths+=("$current_path") _L_table_ids+=("") _L_inline+=(0) _L_first+=(0)
          else
            _L_inline_key=${!#} _L_inline_table_id=${_L_table_ids[parent]} _L_inline_buf='['
            _L_kinds+=(ARRAY) _L_table_paths+=("") _L_table_ids+=("") _L_inline+=(1) _L_first+=(1)
          fi
        fi
      fi
    fi
    ;;
  VALUE)
    if (( _L_inline[parent] )); then
      if (( _L_first[parent] )); then _L_first[parent]=0; else _L_inline_buf+=', '; fi
      if [[ ${_L_kinds[parent]} == MAP ]]; then
          _L_toml_quote_key_vL_RET "${!#}"
          _L_inline_buf+="$L_RET = "
      fi
      _L_toml_quote_type_value_vL_RET "$type" "$value" || return 1
      _L_inline_buf+=$L_RET
    else
      _L_toml_quote_key_vL_RET "${!#}" || return 1
      _L_bufs[_L_table_ids[parent]]+="$L_RET = "
      _L_toml_quote_type_value_vL_RET "$type" "$value" || return 1
      _L_bufs[_L_table_ids[parent]]+="$L_RET"$'\n'
    fi
    ;;
  esac
}

# Convert obj into toml.
# @option -S sort keys
# @option -v <var> Store output in variable.
# @arg obj
L_obj_to_toml() {
  local OPTIND OPTERR OPTARG _L_c _L_sort="" _L_kinds=() _L_table_paths=() _L_table_ids=() _L_inline=() _L_first=() \
    _L_bufs=() _L_bufcnt=0 _L_inline_key _L_inline_table_id _L_inline_buf _L_i LC_COLLATE=C \
    _L_v="" _L_out="" IFS=$'\n'
  local -A _L_hasmap=() _L_nonmap=()
  while getopts Sv:h _L_c; do
    case $_L_c in
      S) _L_sort=-S ;;
      v) _L_v=$OPTARG ;;
			h) L_func_help; return 0 ;;
			*) L_func_usage_error; return "$L_EX_USAGE" ;;
    esac
  done
  shift "$((OPTIND-1))"
  L_obj_walk "$1" _L_obj_to_toml_scan_cb || return
  _L_kinds=()
  L_obj_walk $_L_sort "$1" _L_obj_to_toml_emit_cb || return
  _L_out="${_L_bufs[@]+${_L_bufs[*]}}"
	_L_printf_or_store "$_L_v" "%s" "${_L_out%%$'\n'}"
}

###############################################################################

_L_test_toml() {
  if ((!L_HAS_BASH4_0)); then
    L_unittest_skip "needs bash4.0 for associtive array"
    exit 123
  fi
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

toml_to_json() {
  python -c 'import tomllib,sys,json;print(json.dumps(tomllib.load(sys.stdin.buffer),sort_keys=True,separators=(",", ":")))'
}

_L_test_toml_roundtrip_1() {
  obj_skip_test
	local toml='a = 1
b = "hello"
[t]
c = 2.5
d = true
e = 1979-05-27T07:32:00Z
f = 1979-05-27
g = 07:32:00
[f.g]
h = "i"
[[arr]]
j = [1, 2, 3]
k = "l"
[[arr]]
m = "n"
'
	declare obj
	L_toml_to_obj obj <<<"$toml"
	L_obj_to_toml -v out obj
	L_obj_print_table obj
	# Check that datetime/time/date types are stored correctly in obj
	L_obj_get_vL_RET obj t e
	L_unittest_eq "$L_RET" "1979-05-27T07:32:00Z"  # datetime
	L_obj_get_vL_RET obj t f
	L_unittest_eq "$L_RET" "1979-05-27"          # date
	L_obj_get_vL_RET obj t g
	L_unittest_eq "$L_RET" "07:32:00"            # time
	declare obj2
	L_toml_to_obj obj2 <<<"$out"
	L_obj_to_toml -v out2 obj2
	sdiff - <<<"$out" <(echo "$out2") || :
	L_unittest_eq "$out" "$out2"
}


TOMLS=(
	# scalars
	$'a = 1'
	$'s = "hello"\nb = true\nf = 1.5\ni = -42\n'
	# tables
	$'[t]\nx = 1\n[t.u]\ny = 2\n'
	$'[a.b.c.d]\nx = 1\n'
	$'top = 1\n[a]\nx = 1\n[b]\ny = 2\n[a.c]\nz = 3\n'
	# arrays of tables
	$'[[arr]]\nname = "a"\n[[arr]]\nname = "b"\n'
	$'[[a]]\nx = 1\n[a.sub]\ny = 2\n[[a.items]]\nz = 3\n[[a.items]]\nz = 4\n[[a]]\nx = 5\n'
	$'[[a]]\nl = [1, 2]\n[[a]]\nl = []\n'
	# inline arrays and tables
	$'list = [1, 2, 3]\nmixed = [1, "a", true, 1.5]\nnested = [[1, 2], [3, 4]]\n'
	$'all_maps = [{ a = 1 }, { b = 2 }]\nmixed = [1, { a = 1 }]\n'
	$'p = { x = 1, y = { z = [1, 2, { w = 3 }] } }\n'
	# empty containers
	$'empty_arr = []\nempty_tbl = {}\n[t]\n'
	# keys
	$'"quoted key" = 1\n"a.b" = 2\n[ "x y" ]\n"k" = 3\n'
	$'a.b.c = 1\na.b.d = 2\n'
	$'1234 = "n"\ntrue = false\n'
	# strings
	$'s1 = "tab\\there \\"quoted\\" back\\\\slash"\ns2 = \'literal \\n no escape\'\ns3 = "unicode \\u00e9 \\U0001F600"\n'
	$'ml = """\nline1\nline2 \\\n   continued"""\nlit = \'\'\'\nraw \\n text\n\'\'\'\n'
	# numbers
	$'dec = 1_000\nhex = 0xDEADBEEF\noct = 0o755\nbin = 0b1010\nexp = 1e10\nfl = -3.14e-2\ninf1 = inf\nnan1 = nan\npos = +7\n'
	# dates and times
	$'odt = 1979-05-27T07:32:00Z\nldt = 1979-05-27T07:32:00\nld = 1979-05-27\nlt = 07:32:00\n'
	# layout
	$'# comment\na = 1 # trailing\n\n\n[t] # c\nb = 2\n'
	$'a = 1\r\n[t]\r\nb = 2\r\n'
	''
  $'root = 1\n[[a.b]]\nc=1\n[[a.b]]\nd=1\n[c]\nd=[1,[2,3,4]]\nf=[[1,2,3],[4,5,6]]\n[[q.d.f]]\na=1\n[[q.d.f]]\ng=[1,2,3]'
)

_L_test_toml_trips() {
  obj_skip_test
  local toml a b out
  for toml in "${TOMLS[@]}"; do
    a=() b=()
	  L_toml_to_obj a <<<"$toml" || {
	    printf -v tomlquoted "%q" "$toml"
	    L_unittest_fail "could not read toml:$L_NL$toml----------$tomlquoted"
	  }
	  L_obj_to_toml -v out a || L_unittest_fail "reading back failed of: $(L_obj_print_table a)"
	  L_toml_to_obj b <<<"$out" || L_unittest_fail "failed reading into b from toml:$L_NL$out"
	  L_obj_cmp_obj a b || L_unittest_fail "roundtrip of obj not same same:${L_NL}%% toml=$L_NL$toml${L_NL}%% a=$L_NL$(L_obj_print_table a)${L_NL}%% out=${L_NL}$out${L_NL}%% b=$L_NL$(L_obj_print_table b)"
  done
}

_L_test_toml_complex() {
  obj_skip_test
	# Test inline tables
	local toml='a = { b = 1, c = 2 }'
	declare obj=()
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_vL_RET obj a b
	L_unittest_eq "$L_RET" "1"
	L_obj_get_vL_RET obj a c
	L_unittest_eq "$L_RET" "2"

	# Test inline arrays
	toml='arr = [1, 2, 3]'
	L_toml_to_obj obj <<<"$toml"
	L_obj_len_vL_RET obj arr
	L_unittest_eq "$L_RET" "3"
	L_obj_get_vL_RET obj arr 0
	L_unittest_eq "$L_RET" "1"
	L_obj_get_vL_RET obj arr 1
	L_unittest_eq "$L_RET" "2"
	L_obj_get_vL_RET obj arr 2
	L_unittest_eq "$L_RET" "3"

	# Test datetime
	toml='
dt = 1979-05-27T07:32:00Z
date = 1979-05-27
time = 07:32:00
'
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_vL_RET obj dt
	L_unittest_eq "$L_RET" "1979-05-27T07:32:00Z"
	L_obj_get_vL_RET obj date
	L_unittest_eq "$L_RET" "1979-05-27"
	L_obj_get_vL_RET obj time
	L_unittest_eq "$L_RET" "07:32:00"

	# Test nested inline tables and arrays
	toml='nested = { a = { b = { c = 1 } }, d = [ { e = 1 }, { f = 2 } ] }'
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_vL_RET obj nested a b c
	L_unittest_eq "$L_RET" "1"
	L_obj_len_vL_RET obj nested d
	L_unittest_eq "$L_RET" "2"
	L_obj_get_vL_RET obj nested d 0 e
	L_unittest_eq "$L_RET" "1"
	L_obj_get_vL_RET obj nested d 1 f
	L_unittest_eq "$L_RET" "2"
}

# Test that [section] (single table) and [[section]] (array of tables) are distinct
_L_test_toml_section_vs_array() {
  obj_skip_test
	# Test single table [section]
	local toml='
[database]
name = "mydb"
port = 5432
'
	declare obj
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_vL_RET obj database name
	L_unittest_eq "$L_RET" "mydb"
	L_obj_get_vL_RET obj database port
	L_unittest_eq "$L_RET" "5432"
	L_obj_to_toml -v out obj
	# Verify the output is valid TOML
	declare obj2=()
	L_toml_to_obj obj2 <<<"$out"
	L_obj_get_vL_RET obj2 database name
	L_unittest_eq "$L_RET" "mydb"
	L_obj_get_vL_RET obj2 database port
	L_unittest_eq "$L_RET" "5432"

	# Test array of tables [[section]]
	toml='
[[servers]]
name = "alpha"
port = 5432

[[servers]]
name = "beta"
port = 3306
'
	declare obj3=()
	L_toml_to_obj obj3 <<<"$toml"
	L_obj_len_vL_RET obj3 servers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_vL_RET obj3 servers 0 name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_vL_RET obj3 servers 0 port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_vL_RET obj3 servers 1 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_vL_RET obj3 servers 1 port
	L_unittest_eq "$L_RET" "3306"
}

_L_test_toml_obj_aliases() {
  obj_skip_test
	local toml='
a = 1
b = "test"
'
	declare obj=()
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_vL_RET obj a
	L_unittest_eq "$L_RET" "1"
	L_obj_get_vL_RET obj b
	L_unittest_eq "$L_RET" "test"

	L_obj_to_toml -v out obj
	expected='a = 1
b = "test"'
	L_unittest_eq "$out" "$expected"
}
_L_test_toml_dots_and_brackets() {
  obj_skip_test
	# Test keys with dots -> creates nested tables
	local toml='
a.b.c = 1
x.y = "hello"
'
	declare obj=()
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_vL_RET obj a b c
	L_unittest_eq "$L_RET" "1"
	L_obj_get_vL_RET obj x y
	L_unittest_eq "$L_RET" "hello"

	# Test single bracket table [section]
	toml='
[database]
host = "localhost"
port = 5432

[server]
name = "web"
'
	declare obj2=()
	L_toml_to_obj obj2 <<<"$toml"
	L_obj_get_vL_RET obj2 database host
	L_unittest_eq "$L_RET" "localhost"
	L_obj_get_vL_RET obj2 database port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_vL_RET obj2 server name
	L_unittest_eq "$L_RET" "web"

	# Test double bracket array of tables [[section]]
	toml='
[[servers]]
name = "alpha"
port = 5432

[[servers]]
name = "beta"
port = 3306
'
	declare obj3=()
	L_toml_to_obj obj3 <<<"$toml"
	L_obj_len_vL_RET obj3 servers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_vL_RET obj3 servers 0 name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_vL_RET obj3 servers 0 port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_vL_RET obj3 servers 1 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_vL_RET obj3 servers 1 port
	L_unittest_eq "$L_RET" "3306"

	# Test [[ with dot in key name -> creates nested tables
	toml='
[[app.servers]]
name = "alpha"
port = 5432

[[app.servers]]
name = "beta"
port = 3306
'
	declare obj3=()
	L_toml_to_obj obj3 <<<"$toml"
	# [[app.servers]] creates app -> servers -> array of tables
	L_obj_len_vL_RET obj3 app servers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_vL_RET obj3 app servers 0 name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_vL_RET obj3 app servers 0 port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_vL_RET obj3 app servers 1 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_vL_RET obj3 app servers 1 port
	L_unittest_eq "$L_RET" "3306"

	# Mixed: dots in keys inside tables
	toml='
[app.config]
debug = true
version = "1.0"

[[handlers]]
name = "main"
enabled = true

[[handlers]]
name = "backup"
enabled = false
'
	declare obj4=()
	L_toml_to_obj obj4 <<<"$toml"
	L_obj_get_vL_RET obj4 app config debug
	L_unittest_eq "$L_RET" "true"
	L_obj_get_vL_RET obj4 app config version
	L_unittest_eq "$L_RET" "1.0"
	L_obj_len_vL_RET obj4 handlers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_vL_RET obj4 handlers 0 name
	L_unittest_eq "$L_RET" "main"
	L_obj_get_vL_RET obj4 handlers 1 enabled
	L_unittest_eq "$L_RET" "false"

	# Test quoted keys - literal dots in key names
	toml='
["app.servers"]
name = "alpha"
port = 5432

[["app.backups"]]
name = "beta"
port = 3306
'
	declare obj5=()
	L_toml_to_obj obj5 <<<"$toml"
	# Quoted keys: literal dots in key names
	L_obj_get_vL_RET obj5 "app.servers" name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_vL_RET obj5 "app.servers" port
	L_unittest_eq "$L_RET" "5432"
	# Array of tables with quoted key needs index
	L_obj_get_vL_RET obj5 "app.backups" 0 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_vL_RET obj5 "app.backups" 0 port
	L_unittest_eq "$L_RET" "3306"
}

###############################################################################

if L_is_main; then
  if [[ "${1:-}" == eval ]]; then
    "$@"
  else
    L_unittest_main -p _L_test_ "$@"
  fi
fi
