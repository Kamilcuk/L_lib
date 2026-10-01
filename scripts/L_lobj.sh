#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh

# obj: flat bash array, 6 fields per node, node index 0 = free-list head, node index 1 = tree root
#
# fields (offset from node base):
# 0  kind      "M" map / "A" array / "S" scalar / "" free / "F" free-list head
# 1  key       string key, only set when parent is kind "M"
# 2  val/child scalar's value ("S"), or index of first child ("M"/"A"), or "" if empty
# 3  next      next sibling index, or (for node 0) head of free list; "" = none
# 4  prev      previous sibling index; "" = none
# 5  parent    owning container's index; "" = none (root, or free-list head)

L_obj_new() {
  local -n _L_obj=$1
  _L_obj=(
    "F" "" "" "" "" ""
    "" "" "" "" "" ""
  )
}

L_obj_alloc_vL_RET() {
  local -n _L_obj=$1
  local _L_idx=${_L_obj[3]}
  if [[ -z $_L_idx ]]; then
    _L_idx=${#_L_obj[@]}
  else
    _L_obj[3]=${_L_obj[_L_idx+3]}
  fi
  _L_obj[_L_idx+0]="" _L_obj[_L_idx+1]="" _L_obj[_L_idx+2]=""
  _L_obj[_L_idx+3]="" _L_obj[_L_idx+4]="" _L_obj[_L_idx+5]=""
  L_RET=$_L_idx
}

L_obj_free() {
  local -n _L_obj=$1
  local _L_idx=$2
  _L_obj[_L_idx]="" _L_obj[_L_idx+1]="" _L_obj[_L_idx+2]=""
  _L_obj[_L_idx+3]=${_L_obj[3]} _L_obj[_L_idx+4]="" _L_obj[_L_idx+5]=""
  _L_obj[3]=$_L_idx
}

_L_obj_find_child_vL_RET() {
  local -n _L_obj=$1 || return
  local _L_parent=$2 _L_kind=$3 _L_label=$4
  local _L_cur=${_L_obj[_L_parent+2]}
  if [[ $_L_kind == M ]]; then
    while [[ -n $_L_cur ]]; do
      if [[ ${_L_obj[_L_cur]} == "$_L_kind" && ${_L_obj[_L_cur+1]} == "$_L_label" ]]; then
        break
      fi
      _L_cur=${_L_obj[_L_cur+3]}
    done
  else
    local _L_n=$_L_label
    while (( _L_n > 0 )); do
      if [[ -z $_L_cur ]]; then
        break
      fi
      _L_cur=${_L_obj[_L_cur+3]}
      _L_n=$((_L_n-1))
    done
    if (( _L_n != 0 )); then
      _L_cur=""
    fi
  fi
  L_RET=$_L_cur
}

L_obj_len_vL_RET() {
  local -n _L_obj=$1
  local _L_cur=${_L_obj[$2+2]} _L_n=0
  while [[ -n $_L_cur ]]; do
    _L_n=$((_L_n+1))
    _L_cur=${_L_obj[_L_cur+3]}
  done
  L_RET=$_L_n
}

L_obj_get_vL_RET() {
  local -n _L_obj=$1
  local _L_cur=6 _L_a=("${@:1}") _L_idx _L_kind _L_label
  for ((_L_idx=0; _L_idx<${#_L_a[@]}; _L_idx+=2)); do
    _L_kind=${_L_a[_L_idx]} _L_label=${_L_a[_L_idx+1]}
    if [[ ${_L_obj[_L_cur]} != "$_L_kind" ]]; then
      return 1
    fi
    _L_obj_find_child_vL_RET "${!_L_obj}" "$_L_cur" "$_L_kind" "$_L_label"
    if [[ -z $L_RET ]]; then
      return 1
    fi
    _L_cur=$L_RET
  done
  if [[ ${_L_obj[_L_cur]} != S ]]; then
    return 1
  fi
  L_RET=${_L_obj[_L_cur+2]}
}

L_obj_set() {
  local -n _L_obj=$1
  local _L_value=${*: -1} _L_a=("${@:2:$#-3}") _L_idx
  local _L_cur=6 _L_kind _L_label _L_child _L_head
  for ((_L_idx=0; _L_idx<${#_L_a[@]}; _L_idx+=2)); do
    _L_kind=${_L_a[_L_idx]} _L_label=${_L_a[_L_idx+1]}
    if [[ ${_L_obj[_L_cur]:=$_L_kind} != "$_L_kind" ]]; then
      L_func_error "type mismatch at node $_L_cur: expected $_L_kind, got ${_L_obj[_L_cur]}"
      return "$L_EX_DATAERR"
    fi
    _L_obj_find_child_vL_RET "${!_L_obj}" "$_L_cur" "$_L_kind" "$_L_label"
    _L_child=$L_RET
    if [[ -z $_L_child ]]; then
      if [[ $_L_kind == A ]]; then
        L_obj_len_vL_RET "${!_L_obj}" "$_L_cur"
        if (( _L_label != L_RET && _L_label != L_RET + 1 )); then
          L_func_error "array index $_L_label out of bounds (len $L_RET)"
          return "$L_EX_DATAERR"
        fi
      fi
      L_obj_alloc_vL_RET "${!_L_obj}"
      _L_child=$L_RET
      _L_obj[_L_child+5]=$_L_cur
      if [[ $_L_kind == M ]]; then
        _L_obj[_L_child+1]=$_L_label
      fi
      _L_head=${_L_obj[_L_cur+2]}
      _L_obj[_L_child+3]=$_L_head
      if [[ -n $_L_head ]]; then
        _L_obj[_L_head+4]=$_L_child
      fi
      _L_obj[_L_cur+2]=$_L_child
    fi
    _L_cur=$_L_child
  done
  if [[ ${_L_obj[_L_cur]:=S} != S ]]; then
    L_func_error "cannot overwrite container at node $_L_cur with a scalar"
    return "$L_EX_DATAERR"
  fi
  _L_obj[_L_cur+2]=$_L_value
}

###############################################################################



_L_obj_print_vL_RET() {
  local -n _L_obj=$1
  local _L_n=$2 _L_output="" _L_cur _L_kind=${_L_obj[$2]} _L_comma=""
  case $_L_kind in
    S) printf -v _L_output 'S %q' "${_L_obj[_L_n+2]}" ;;
    A)
      _L_output+='['
      _L_cur=${_L_obj[_L_n+2]}
      while [[ -n $_L_cur ]]; do
        _L_obj_print_vL_RET "${!_L_obj}" "$_L_cur"
        _L_output+="$L_RET$_L_comma"
        _L_comma=,
        _L_cur=${_L_obj[_L_cur+3]}
      done
      _L_output+=']'
      ;;
    M)
      _L_output+='{'
      _L_cur=${_L_obj[_L_n+2]}
      while [[ -n $_L_cur ]]; do
        _L_obj_print_vL_RET "${!_L_obj}" "$_L_cur"
        printf -v _L_tmp "%q" "${_L_obj[_L_cur+1]}"
        _L_output+="$_L_tmp=$L_RET$_L_comma"
        _L_comma=,
        _L_cur=${_L_obj[_L_cur+3]}
      done
      _L_output+='}'
      ;;
    "") _L_output='<>' ;;
    *) _L_output="<$_L_kind>" ;;
  esac
  L_RET=$_L_output
}

L_obj_print() {
  local -n _L_obj=$1
  _L_obj_print_vL_RET "${!_L_obj}" "${2:-6}"
  printf '%s\n' "$L_RET"
}

L_obj_table_print() {
  local -n _L_obj=$1
  local _L_idx=0 _L_buf="[idx]|kind|key|val|next|prev|parent" _L_tmp
  for (( _L_idx=0; _L_idx < ${#_L_obj[@]}; _L_idx += 6 )); do
    printf -v _L_tmp "[%d]" "$_L_idx"
    _L_buf+=$'\n'$_L_tmp
    printf -v _L_tmp "|%q" "${_L_obj[@]:_L_idx:6}"
    _L_buf+=$_L_tmp
  done
  time L_table -s '|' "$_L_buf"
  time column -t -s '|' <<<"$_L_buf"
}

###############################################################################

L_obj_new obj
L_obj_set obj M a = $LINENO
L_obj_set obj M b A 0 = $LINENO
L_obj_set obj M b A 1 = $LINENO
# L_obj_append_vL_RET obj M b 2
L_obj_print obj
L_obj_table_print obj
