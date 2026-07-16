#!/bin/bash

#
# Types:
#  v - value
#  a - array
#  m - map
#  n - null
#
# prefix = _L_obj
#
# name=(
#   V<value>
#   M<name>
#   A<name>
#   N
# )
#
# a={1,2,3,{1,2,3}}
#
# ab=(V1 V2 V3)
#
# var=

_L_OBJ_I=0

L_obj_clear() { L_map_clear "$1"; }
L_obj_new() { L_map_clear "$1"; }

_L_obj_set_M() { L_map_set "$@"; }
_L_obj_set_A() { L_array_set "$@"; }
_L_obj_set_V() { printf -v "$1" "%s" "$2"; }
_L_obj_get_M() { L_map_get_vL_RET "$1" "$2"; }
_L_obj_get_A() { L_RET="$1[$2]"; L_RET=("${!L_RET}"); }
_L_obj_get_V() { L_RET=${!1}; }
_L_obj_len_M() { L_map_len_vL_RET "$1"; }
_L_obj_len_A() { L_array_len_vL_RET "$1"; }
_L_obj_len_V() { L_RET=${!1}; L_RET=${#L_RET}; }

L_obj_set() {
  local L_RET="$1" _L_type=M
  shift
  while (($# > 3)); do
    _L_obj_get_$type "$_L_obj" "$2"
    _L_type=${L_RET::1} L_RET=${L_RET:1}
  done

  _L_obj_get_M "_L_obj_${!1}" "${@:2:$#-1}"
  while (($# > 3)); do
    L_map_get -v _L_obj "$_L_obj"
    shift
  done
  L_map_set "$_L_obj" "$1" "$2"
}

L_obj_get() { L_handle_v_scalar "$@"; }
L_obj_get_vL_RET() {
  L_RET=[b
}

if L_is_main; then
  L_obj_new obj '{"a":{"b":{"c":1}}}'
  L_obj_set_json obj a
  L_obj_get_json -v json obj a
L_obj_foreach k v : obj a

L_obj_set obj a.b.c = 
L_obj_set obj a.b[1].c = 1 2 3
L_obj_set obj a b c = a 1 b 2 c 3

L_obj_get_obj -v obj2 obj 

L_obj_get obj a b c
