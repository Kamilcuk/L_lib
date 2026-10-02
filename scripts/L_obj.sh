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

###############################################################################
# @section obj
# Implementation of a class that can hold arbitrary nested data of maps and arrays.

L_obj_new() { local -n _L_obj=$1 && _L_obj=(); }
L_obj_key_pack() { L_handle_v_scalar "$@"; }
L_obj_key_pack_vL_RET() {
  printf -v L_RET "\t%q" "$@"
  # local _L_i IFS=$'\t' _L_keys=("${@//$'\2'/$'\2E'}")   # ESC  -> ESC 'E'
  # _L_keys=("${_L_keys[@]//$'\t'/$'\2D'}")   # DELIM-> ESC 'D'  (no raw \t introduced)
  # L_RET=$IFS${_L_keys[*]}
}
L_obj_key_unpack() { L_handle_v_array "$@"; }
L_obj_key_unpack_vL_RET() {
  eval "L_RET=(" "$@" ")"
  # IFS=$'\t' read -ra L_RET <<<"$*"
  # L_RET=("${L_RET[@]:1}")
  # L_RET=("${L_RET[@]//$'\2D'/$'\t'}")
  # L_RET=("${L_RET[@]//$'\2E'/$'\2'}")
}
L_obj_set_meta() {
  local -n _L_obj=$1 || return
  local L_RET
  L_obj_key_pack_vL_RET "${@:3:$#-4}"
  _L_obj["$2$L_RET"]="${*:$#}"
}
L_obj_get_meta() { L_handle_v_scalar "$@"; }
L_obj_get_meta_vL_RET() {
  local -n _L_obj=$1 || return
  L_obj_key_pack_vL_RET "${@:3}"
  [[ -v "_L_obj[$2$L_RET]" ]] && L_RET=${_L_obj["$2$L_RET"]}
}
# L_obj_set_type obj word word 3 = 3
L_obj_set_type() {
  local -n _L_obj=$1 || return
  _L_obj["hastype"]=1
  L_obj_set_meta "$1" "type" "${@:2}"
}
L_obj_get_type() { L_handle_v_scalar "$@"; }
L_obj_get_type_vL_RET() { L_obj_get_meta_vL_RET "$1" "type" "${@:2}"; }
# L_obj_set obj word word 3 = 3
L_obj_set() {
  local -n _L_obj=$1 || return
  if (( ${_L_obj["hastype"]:+1}0 )); then
    : todo check types of indexes
  fi
  L_obj_set_meta "$1" "" "${@:2}"
}
L_obj_get() { L_handle_v_scalar "$@"; }
L_obj_get_vL_RET() { L_obj_get_meta_vL_RET "$1" "" "${@:2}"; }
L_obj_set_obj() {
  local -n _L_obj=$1 _L_obj2=$2 || return
  local L_RET
  L_obj_key_pack_vL_RET "${@:3:$#-4}"
  for _L_i in "${!_L_obj2[@]}"; do
    _L_obj["$L_RET$_L_i"]="${_L_obj2["$_L_i"]}"
  done
}
L_obj_get_obj() {
  local -n _L_obj=$1 _L_obj2=$2 || return
  _L_obj2=()
  local L_RET
  L_obj_key_pack_vL_RET "${@:3}"
  for _L_i in "${!_L_obj[@]}"; do
    if [[ "$_L_i" == "$L_RET"$'\t'* ]]; then
      _L_obj2["${_L_i:${#L_RET}}"]="${_L_obj["$_L_i"]}"
    fi
  done
  (( ${#_L_obj2[@]} != 0 ))
}
L_obj_keys() { L_handle_v_array "$@"; }
L_obj_keys_vL_RET() {
  if (( $# == 1 )); then
    local _L_prefix=""
  else
    L_obj_key_pack_vL_RET "${@:2}"
    local _L_prefix="$L_RET"
  fi
  declare -A L_ARET=()
  for L_RET in "${!_L_obj[@]}"; do
    if [[ "$L_RET" == "$_L_prefix" ]]; then
      L_ARET["$L_RET"]=""
    elif [[ "$L_RET" == "$_L_prefix"$'\t'* ]]; then
      L_RET="${L_RET##"$_L_prefix"$'\t'}"
      L_RET=${L_RET%%$'\t'*}
      L_ARET["$L_RET"]=""
    fi
  done
  L_RET=("${!L_ARET[@]}")
}
L_obj_len() { L_handle_v_scalar "$@"; }
L_obj_len_vL_RET() {
  local -n _L_obj=$1 || return
  if (( $# )); then
    L_obj_key_pack_vL_RET "${@:2}"
    if L_var_is_set "_L_obj[$L_RET]"; then
      L_RET=${#_L_obj["$L_RET"]}
      return
    fi
  fi
  L_obj_keys_vL_RET "$@"
  (( L_RET=${#L_RET[@]} ))
}
L_obj_has() {
  local -n _L_obj=$1 || return
  local L_RET
  L_obj_key_pack_vL_RET "${@:2}"
  L_var_is_set "_L_obj[$L_RET]"
}
L_obj_del() {
  local -n _L_obj=$1 || return
  local L_RET _L_keys=("${!_L_obj[@]}") _L_i
  L_obj_key_pack_vL_RET "${@:2}"
  unset -v "_L_obj[$L_RET]"
  for _L_i in "${_L_keys[@]}"; do
    if [[ "$_L_i" == "$L_RET"$'\t'* ]]; then
      unset -v "_L_obj[$_L_i]"
    fi
  done
}
L_obj_append() {
  local -n _L_obj=$1 || return
  local L_RET
  L_obj_key_pack_vL_RET "${@:2:$#-3}"
  _L_obj["$L_RET"]+="${*:$#}"
}
# L_obj_array_push obj a b += a
L_obj_array_append() {
  local -n _L_obj=$1 || return
  local _L_nextidx=0 _L_key L_RET _L_prefix
  if L_obj_get_type_vL_RET "$1" "${@:2:$#-3}" && [[ "$L_RET" != "array" ]]; then
    L_func_error "can't append to non $L_RET type at ${*:2:$#-3} in object $1"
    return "$L_EX_USAGE"
  fi
  L_obj_set_type "$1" "${@:2:$#-3}" = array
  L_obj_key_pack_vL_RET "${@:2:$#-3}"
  _L_prefix=$L_RET
  for L_RET in "${!_L_obj[@]}"; do
    if [[ "$L_RET" == "$_L_prefix"* ]]; then
      L_RET="${L_RET##"$_L_prefix"$'\t'}"
      L_RET=${L_RET%%$'\t'*}
      if (( _L_nextidx <= L_RET )); then
        _L_nextidx=$(( L_RET + 1 ))
      fi
    fi
  done
  _L_obj["$_L_prefix"$'\t'"$_L_nextidx"]="${*:$#}"
}
# L_obj_walk obj cb <args>...
# calls cb <args>... <section>... <value>
L_obj_walk() {
  local -n _L_obj="$1" || return
  shift
  local _L_keys=("${!_L_obj[@]}") _L_i L_RET
  L_sort _L_keys
  for _L_i in "${_L_keys[@]}"; do
    if [[ "$_L_i" == $'\t'* ]]; then
      L_obj_key_unpack_vL_RET "$_L_i"
      "$@" "${L_RET[@]}" "${_L_obj["$_L_i"]}" || return
    fi
  done
}

# L_obj_walk_all obj cb <args>...
# Calls:
#   cb <args>... START <section>...
#   cb <args>... VALUE <section>... <value>
#   cb <args>... END <section>...
#   cb <args>... META <key> <value>
L_obj_walk_all() {
  local -n _L_obj="$1" || return
  shift
  local _L_keys=("${!_L_obj[@]}") _L_key _L_level _L_parts=() _L_prev_group=() _L_group_depth _L_prev_depth _L_common_depth
  L_sort _L_keys
  for _L_key in "${_L_keys[@]}"; do
    if [[ "$_L_key" == $'\t'* ]]; then
      L_obj_key_unpack -v _L_parts "$_L_key"
      (( ${#_L_parts[@]} > 0 )) || continue
      _L_group_depth=$(( ${#_L_parts[@]} - 1 ))  # last part is the key name, the rest is the group path
      _L_prev_depth=${#_L_prev_group[@]}
      # how many leading group names the previous and current keys share
      _L_common_depth=0
      while (( _L_common_depth < _L_prev_depth && _L_common_depth < _L_group_depth )) &&
            [[ "${_L_prev_group[_L_common_depth]}" == "${_L_parts[_L_common_depth]}" ]]; do
        (( ++_L_common_depth ))
      done
      # close groups we left (deepest first)
      for (( _L_level = _L_prev_depth; _L_level > _L_common_depth; _L_level-- )); do
        "$@" END "${_L_prev_group[@]:0:_L_level}" || return
      done
      # open groups we entered (shallowest first)
      for (( _L_level = _L_common_depth + 1; _L_level <= _L_group_depth; _L_level++ )); do
        "$@" START "${_L_parts[@]:0:_L_level}" || return
      done
      "$@" VALUE "${_L_parts[@]}" "${_L_obj["$_L_key"]}" || return
      _L_prev_group=("${_L_parts[@]:0:_L_group_depth}")
    else
      # META: keys that are not packed section keys
      "$@" META "$_L_key" "${_L_obj["$_L_key"]}" || return
    fi
  done
  # close whatever is still open
  for (( _L_level = ${#_L_prev_group[@]}; _L_level > 0; _L_level-- )); do
    "$@" END "${_L_prev_group[@]:0:_L_level}" || return
  done
}

# _L_obj_pp_q_vL_RET VAR STR: leave simple tokens bare, %q-quote anything with
# spaces, ",{}=", quotes, newlines, etc. (empty becomes '')
_L_obj_pp_q_vL_RET() {
  if [[ -n $1 && $1 != *[!a-zA-Z0-9_.@/:+-]* ]]; then
    printf -v L_RET %s "$1"
  else
    printf -v L_RET %q "$1"
  fi
}
# args: <START|VALUE|END|META> <sections...> [VALUE]
_L_obj_pp_cb() {
  case $2 in
  META)
    _L_obj_pp_q_vL_RET "$3"
    _L_obj_pp_meta+="$_L_obj_pp_meta_sep$L_RET="
    _L_obj_pp_q_vL_RET "$4"
    _L_obj_pp_meta+="$L_RET"
    _L_obj_pp_meta_sep=" "
    ;;
  START)
    _L_obj_pp_q_vL_RET "${!#}"  # group name = last part
    _L_cb_out+="$_L_cb_sep$L_RET="
    if L_obj_get_type_vL_RET "$1" "${@:3}" && [[ "$L_RET" == array ]]; then
      _L_cb_out+="["
    else
      _L_cb_out+="{"
    fi
    _L_cb_sep=""  # first child of a group gets no leading space
    ;;
  END)
    if L_obj_get_type_vL_RET "$1" "${@:3}" && [[ "$L_RET" == array ]]; then
      _L_cb_out+="]"
    else
      _L_cb_out+="}"
    fi
    _L_cb_sep=" "
    ;;
  VALUE)
    _L_cb_out+="$_L_cb_sep"
    if L_obj_get_type_vL_RET "$1" "${@:3:$#-4}" && [[ "$L_RET" == array ]]; then
      :
    else
      _L_obj_pp_q_vL_RET "${@:$#-1:1}"  # key name
      _L_cb_out+="$L_RET="
    fi
    _L_obj_pp_q_vL_RET "${!#}"  # value
    _L_cb_out+="$L_RET"
    _L_cb_sep=" "
    ;;
  esac
}
# L_obj_print_vL_RET OBJ  ->  _L_cb_out
L_obj_print_vL_RET() {
  local _L_obj_pp_meta="" _L_obj_pp_meta_sep="" _L_cb_out="" _L_cb_sep=""
  L_obj_walk_all "$1" _L_obj_pp_cb "$1" || return
  L_RET="$1($_L_cb_out)${_L_obj_pp_meta:+!($_L_obj_pp_meta)}"
}
L_obj_print() { L_handle_v_scalar "$@"; }

###############################################################################

_L_test_obj() {
  local L_RET
  {
    L_obj_key_pack_vL_RET word word 3
    L_obj_key_unpack_vL_RET "$L_RET"
    L_unittest_arreq L_RET word word 3
  }
  {
    L_obj_key_pack_vL_RET word word 3 $'\t' $'\2' $'\2D' $'\2E' $'\3'
    L_obj_key_unpack_vL_RET "$L_RET"
    L_unittest_arreq L_RET word word 3 $'\t' $'\2' $'\2D' $'\2E' $'\3'
  }
  local -A obj=()
  {
    # # {"a":{"b":[1,2,3]}}
    L_obj_set obj a b 1 = 1
    L_obj_set obj a b 2 = 2
    L_obj_set obj a b 3 = 3
    L_obj_set obj a c = dead1
    L_obj_set obj a d = dead2
    L_obj_set obj a f = dead3
    L_obj_get_vL_RET obj a b 1
    L_unittest_vareq L_RET 1
    L_obj_get_vL_RET obj a b 2
    L_unittest_vareq L_RET 2
    L_obj_get_vL_RET obj a b 3
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
    L_unittest_failure L_obj_len_vL_RET obj a b c
  }
  {
    L_obj_array_append obj a b += 4
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 4
    L_obj_array_append obj a b += 5
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 5
  }
  {
    L_obj_append obj a f += dead
    L_obj_get_vL_RET obj a f
    L_unittest_vareq L_RET dead3dead
  }
  L_obj_print obj
  L_pp -m obj
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

# L_ini_parse callback [args...] <input>
# Calls: callback... SECTION section
#        callback... KV section key value
#        callback... CONTINUATION section key value
L_ini_parse() {
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

L_ini_parse_into_obj() {
  local -n _L_dest=$1
  _L_ini_cb() {
    case "$1" in
      KV) L_obj_set _L_dest "$2" "$3" = "$4" ;;
      CONTINUATION) L_obj_append _L_dest "$2" "$3" += $'\n'"$4" ;;
    esac
  }
  L_ini_parse _L_ini_cb
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
# Serializes OBJ (via L_obj_walk) to INI text in L_RET.
L_ini_from_obj_vL_RET() {
  local _L_ini_ret="" _L_last_section="" _L_ini_rc=0
  _L_ini_cb() {
    local rest=$3 line quotedline first=1
    if [[ $1 != "$_L_last_section" ]]; then
      _L_last_section=$1
      _L_ini_ret+="[$1]"$'\n'
    fi
    while :; do
      line=${rest%%$'\n'*}
      if ! _L_ini_quote quotedline "$line" "$(( !first ))"; then
        _L_ini_rc=1
        return 1
      fi
      if (( first )); then
        _L_ini_ret+="$2 =${quotedline:+ $quotedline}"$'\n'
        first=0
      else
        _L_ini_ret+="  $quotedline"$'\n'
      fi
      [[ $rest == *$'\n'* ]] || break
      rest=${rest#*$'\n'}
    done
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
[section]
key = first line
  second line
  third line
[server]
host = localhost
long = first line
  second line
  third line
port = 8080
[spaced section]
after = trailing
empty =
  bare_no_eq
key = value
quoted = "with ; semicolon"
single = "with # hash"
EOF
  declare -A out=()
  L_ini_parse_into_obj out <<<"$var"
  L_pp -m out
  L_obj_print out
  L_ini_from_obj_vL_RET out
  if [[ "$L_RET" != "$expected" ]]; then
    diff <(<<<"$L_RET" cat) - <<<"$expected" || :
    L_unittest_fail "ini obj roundtrip failure"
    exit 1
  fi
  L_pp -m out
  L_obj_print out
}

###############################################################################
# @section json

# Convert Bash string into Json string.
# @option -v <var>
# @arg <str>
L_json_quote() { L_handle_v_scalar "$@"; }
L_json_quote_vL_RET() {
	if [[ $1 == *[$'\"\x01-\x1f\\']* ]]; then
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

# Convert Json string into Bash string.
# @option -v <var>
# @arg <str>
L_json_unquote() { L_handle_v_scalar "$@"; }
_L_json_unquote_unicode_append_L_RET() {
	local _L_hex _L_cp _L_hi _L_lo
	_L_hex=${_L_s:1:4}
	_L_s=${_L_s:5}
	_L_cp=$((16#$_L_hex))
	# Low surrogate without a preceding high surrogate is invalid.
	if (( _L_cp >= 0xDC00 && _L_cp <= 0xDFFF )); then
		return "$L_EX_DATAERR"
	fi
	# High surrogate: must be followed immediately by \uXXXX low surrogate.
	if (( _L_cp >= 0xD800 && _L_cp <= 0xDBFF )); then
		case $s in
			\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]*)
				_L_lo=${s:2:4}
				_L_lo=$((16#$_L_lo))
				if (( _L_lo < 0xDC00 || _L_lo > 0xDFFF )); then
					return "$L_EX_DATAERR"
				fi
				s=${s:6}
				_L_cp=$((0x10000 + ((_L_cp - 0xD800) << 10) + (_L_lo - 0xDC00)))
				;;
			*) return "$L_EX_DATAERR" ;;
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
			"\"") L_RET+='"' _L_s=${_L_s:1} ;;
			'\\'*) L_RET+='\' _L_s=${_L_s:1} ;;
			'/'*) L_RET+='/' _L_s=${_L_s:1} ;;
			b*) L_RET+=$'\b' _L_s=${_L_s:1} ;;
			f*) L_RET+=$'\f' _L_s=${_L_s:1} ;;
			n*) L_RET+=$'\n' _L_s=${_L_s:1} ;;
			r*) L_RET+=$'\r' _L_s=${_L_s:1} ;;
			t*) L_RET+=$'\t' _L_s=${_L_s:1} ;;
			u*)	_L_json_unquote_unicode_append_L_RET || return ;;
			*) return "$L_EX_DATAERR" ;;
		esac
	done
	L_RET+=$_L_s
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
  local _L_input=$1 _L_dot='' _L_tmp _L_tok=() L_RET
  while (( 1 )); do
    case "$_L_input" in
      '["'*)
        if [[ "$_L_input" =~ ^\[(\"([^\"$'\x01-\x1f'\\]|\\[\"\\/bfnrt]|\\u[0-9a-fA-F]{4})*\")\] ]]; then
          if ! L_json_unquote_vL_RET "${#BASH_REMATCH[1]}"; then
            L_func_error "Invalid input string: $1"; return "$L_EX_DATAERR"
          fi
          _L_tok+=("$L_RET")
        else
          L_func_error "Unclosed double quote string in bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        ;;
      "['"*)
        if [[ "$_L_input" =~ ^\[\'(([^\'$'\x01-\x1f'\\]|\\[\'\\/bfnrt]|\\u[0-9a-fA-F]{4})*)\'\] ]]; then
          _L_tmp=${BASH_REMATCH[1]}
          _L_tmp=${_L_tmp//\\\'/\'}   # \'  -> '   (undo single-quote escaping)
          _L_tmp=${_L_tmp//\"/\\\"}   # "   -> \"  (escape bare " for double-quote context)
          if ! L_json_unquote_vL_RET "\"${#BASH_REMATCH[1]}\""; then
            L_func_error "Invalid input string: $1"; return "$L_EX_DATAERR"
          fi
          _L_tok+=("$L_RET")
        else
          L_func_error "Unclosed single quote string in bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        ;;
      '['[0-9]*)
        if [[ "$_L_input" =~ ^'['(0|[1-9][0-9]*)']' ]]; then
          L_RET+=("${BASH_REMATCH[1]}")
        else
          L_func_error "Invalid bracket notation: $1"; return "$L_EX_DATAERR"
        fi
        ;;
      $_L_dot[^$'\x01-\x1f'"\\.\[\]@#%^&*+=|/?!~\`'\";:,{}()<>-"]*)
        if [[ "$_L_input" =~ ^$_L_dot([^"]"$'\x01-\x1f'"\\.\[@#%^&*+=|/?!~\`'\";:,{}()<>-"]+) ]]; then
          L_RET+=("${BASH_REMATCH[1]}")
        else
          L_func_error "Empty key in JSON path: $1"; return "$L_EX_DATAERR"
        fi
        ;;
      '') break ;;
      *) L_func_error "Invalid character in JSON path: $1"; return "$L_EX_DATAERR" ;;
    esac
    _L_input="${_L_input:${#BASH_REMATCH[0]}}"
    _L_dot="."
  done
  L_obj_key_pack_vL_RET "${L_RET[@]}"
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
_L_json_read_string() {
  if [[ "$_L_json" =~ ^[$' \t\r\n']*($_L_json_str_re) ]]; then
    # if ! L_json_unquote_vL_RET "${BASH_REMATCH[1]}"; then
    #   _L_json_err "invalid json string: ${BASH_REMATCH[1]}" || return
    # fi
    # _L_string=$L_RET
    _L_string="${BASH_REMATCH[1]}";
    _L_json="${_L_json:${#BASH_REMATCH[0]}}"
  else
    _L_json_err "Expected string"
  fi
}
_L_json_read_object_element() {
  _L_json_read_string || return
  "$_L_json_cb" KEY "$_L_string" || return
  _L_json_lstrip
  if [[ "$_L_json" != :* ]]; then
    _L_json_err "Missing ':'"; return
  fi
  "$_L_json_cb" TOKEN ":" || return
  _L_json=${_L_json:1} _L_json_type="dict" _L_json_context+=("$_L_string")
  _L_json_read_value || return
  unset "_L_json_context[${#_L_json_context[@]}-1]"
}
_L_json_read_array_element() {
  _L_json_type="array" _L_json_context+=("$((_L_idx++))")
  _L_json_read_value || return;
  unset "_L_json_context[${#_L_json_context[@]}-1]"
}
# Call _L_json_cb with:
#   START [
#   START {
#   END }
#   END ]
#   VALUE value <number|string|float|bool|null>
_L_json_read_value() {
  local _L_tmp _L_string _L_idx=0
  case "$_L_json" in
    [$' \t\r\n']*) _L_json_lstrip; _L_json_read_value; return ;;
    '"'*)
      _L_json_read_string || return
      "$_L_json_cb" VALUE "$_L_string" string || return
      ;;
    [-0-9]*)
      if [[ "$_L_json" =~ $_L_float_re ]]; then
        "$_L_json_cb" VALUE "${BASH_REMATCH[0]}" number || return
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
          '"'*) _L_json_read_object_element || return ;;
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
          _L_json_read_object_element || return
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
          *) _L_json_read_array_element || return ;;
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
          _L_json_read_array_element || return
        done
        _L_json_err "Missing array end ']'"; return
      done
      ;;
    null*) "$_L_json_cb" VALUE null null || return; _L_json=${_L_json:4} ;;
    true*) "$_L_json_cb" VALUE true bool || return; _L_json=${_L_json:4} ;;
    false*) "$_L_json_cb" VALUE false bool || return; _L_json=${_L_json:5} ;;
    '') _L_json_err "Unexpected EOF"; return ;;
    *) _L_json_err "Invalid value" || return ;;
  esac
}
_L_json_read() {
  local _L_json_len=${#_L_json} _L_json_type _L_json_context=() _L_json_cb=$1 _L_json_errdepth=${#FUNCNAME[*]}
  _L_json_read_value || return
  if [[ "$_L_json" == *[!$' \t\r\n']* ]]; then
    _L_json_err "Invalid tokens after value" || return
  fi
}

# Convert a json into an object.
# @arg <object>
# @arg <json string>
L_json_to_obj() {
  local -n _L_a=$1
  local _L_json=$2
  _L_a=()
  _L_json_to_obj_cb() {
    case "$1" in
      VALUE)
        if [[ "$3" != "string" ]]; then
          L_obj_set_type _L_a "${_L_json_context[@]}" = "$3"
        fi
        L_obj_set _L_a "${_L_json_context[@]}" = "$2"
        ;;
      START)
        if [[ "$2" == "[" ]]; then
          L_obj_set_type _L_a "${_L_json_context[@]}" = "array"
        fi
    esac
  }
  _L_json_read _L_json_to_obj_cb
}

L_obj_to_json() { L_handle_v_scalar "$@"; }
_L_obj_to_json_cb() {
  case $2 in
    START)
      L_json_quote_vL_RET "${!#}"  # group name = last part
      _L_cb_out+="$_L_cb_sep$L_RET="
      if L_obj_get_type_vL_RET "$1" "${@:3}" && [[ "$L_RET" == array ]]; then
        _L_cb_out+="["
      else
        _L_cb_out+="{"
      fi
      _L_cb_sep=""
      ;;
    END)
      if L_obj_get_type_vL_RET "$1" "${@:3}" && [[ "$L_RET" == array ]]; then
        _L_cb_out+="]"
      else
        _L_cb_out+="}"
      fi
      _L_cb_sep=" "
      ;;
    VALUE)
      _L_cb_out+="$_L_cb_sep"
      if L_obj_get_type_vL_RET "$1" "${@:3:$#-4}" && [[ "$L_RET" == array ]]; then
        :
      else
        _L_obj_pp_q_vL_RET "${@:$#-1:1}"  # key name
        _L_cb_out+="$L_RET="
      fi
      L_obj_get_type_vL_RET "$1" "${@:3:$#-3}" || L_RET=string
      case "$L_RET" in
        bool|null|float|number) L_RET=${!#} ;;
        *) L_json_quote_vL_RET "${!#}" ;;
      esac
      _L_cb_out+="$L_RET"
      _L_cb_sep=" "
      ;;
  esac
}
L_obj_to_json_vL_RET() {
  local _L_cb_out="" _L_cb_sep=""
  L_obj_walk_all "$1" _L_obj_to_json_cb "$1" || return
  L_RET=$_L_cb_out
}

L_json_get() { L_handle_v_array "$@"; }
L_json_get_vL_RET() {
  local _L_json="$1" _L_orig_json="$1" _L_initlen="${#1}" _L_key _L_start="" _L_end="" _L_value_captured=0 _L_value=""
  L_json_path_to_obj_key -v _L_key "$2" || return
  _L_json_cb() {
    L_obj_key_pack_vL_RET "${_L_json_context[@]}"
    case "$1 $L_RET" in
      "START $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "END $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))"; return 124 ;;
      "VALUE $_L_key") _L_value=$2 _L_value_captured=1; return 124 ;;
    esac
  }
  _L_json_read _L_json_cb || eval "(( $? == 124 )) || return $?"
  if [[ -n "$_L_start" && -n "$_L_end" ]]; then
    L_RET=("${_L_orig_json:_L_start:_L_end-_L_start}" "$_L_start" "$(( _L_end-_L_start ))")
  elif [[ -z "${_L_value:-}" && $_L_value_captured -eq 0 ]]; then
    return 1
  fi
}

# Remove an element from json.
L_json_rm() { L_handle_v_scalar "$@"; }
L_json_rm_vL_RET() {
  local _L_json="$1" _L_initlen="${#1}" _L_start _L_end _L_key
  L_json_path_to_obj_key -v _L_key "$2" || return
  _L_json_cb() {
    L_obj_key_pack_vL_RET "${_L_json_context[@]}"
    case "$1 $L_RET" in
      "START $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "END $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))"; return 124 ;;
    esac
  }
  _L_json_read _L_json_cb || eval "(( $? == 124 )) || return $?"
  L_RET="${_L_json::_L_start}"
  L_RET="${L_RET%,}${_L_json:_L_end}"
}

# @description Print nicely looking version of the json.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
# @arg $2 Number of spaces.
L_json_pretty() { L_handle_v_scalar "$@"; }
_L_json_pretty() {
  local indent
  printf -v indent "%*s" "$(( _L_indent * _L_lvl ))" ""
  case "$1 $2" in
    "START "["[{"])
      case "$_L_last" in
        ["{,"]) _L_out+=$'\n'$indent ;;
        ":") _L_out+=" " ;;
      esac
      (( ++_L_lvl ))
      _L_out+="$L_BOLD$2$L_RESET"
      ;;
    "END "["]}"])
      (( _L_lvl-- ))
      printf -v indent "%*s" "$((_L_indent*_L_lvl))" ""
      _L_out+=$'\n'"$indent$L_BOLD$2$L_RESET"
      ;;
    "TOKEN "":")
      if [[ "$_L_last" == ["{,"] ]]; then _L_out+=$'\n'; fi
      _L_out+="$L_BOLD$2$L_RESET"
      ;;
    "TOKEN "",") _L_out+="$L_BOLD,$L_RESET" ;;
    KEY*|VALUE*)
      case "$_L_last" in
        ["{[,"]) _L_out+=$'\n'$indent ;;
        ":") _L_out+=" " ;;
        *) _L_out+=$indent ;;
      esac
      if [[ "$1" == key ]]; then
        _L_out+=$L_LIGHT_BLUE$2$L_RESET
      elif [[ "$2" == '"'* ]]; then
        _L_out+=$L_GREEN$2$L_RESET
      else
        _L_out+=$2
      fi
      ;;
    *) _L_json_err "could not print. args: $*"; return "$L_EX_SOFTWARE" ;;
  esac
  _L_last=${2:${#2}-1}
}
L_json_pretty_vL_RET() {
  local _L_out="" _L_lvl=0 _L_indent=${2:-2} _L_json=$1 _L_last=""
  L_color_detect
  _L_json_read _L_json_pretty
  L_RET=$_L_out
}

# @description Print compact version of the json.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
L_json_compact() { L_handle_v_scalar "$@"; }
_L_json_compact() {
  _L_out+="$2"
}
L_json_compact_vL_RET() {
  local _L_json=$1 _L_out=""
  _L_json_read _L_json_compact
  L_RET=$_L_out
}

###############################################################################

_L_json_test() {
  _L_json_cb() {
    local IFS=" " tmp
    printf -v tmp "%q " "${_L_json_context[@]}"
    printf "!! context: %-8s | args: %s\n" "$tmp" "$*"
  }
  local _L_json=$1
  echo "$1"
  _L_json_read _L_json_cb
}
_L_json_test_quiet() {
  local _L_json=$1
  _L_json_read :
}

declare _L_JSON_TEST1='{ "a" : "b" , "c" : [ "d" , 1 , true ], "e": { "f.": { "g": "h" } } } '

_L_test_json_1() {
  _L_json_test "$_L_JSON_TEST1"
}

_L_test_json_change() {
  L_json_compact "$_L_JSON_TEST1"
  L_unittest_cmd -o '{"a":"b","c":["d",1,true],"e":{"f.":{"g":"h"}}}' L_json_compact "$_L_JSON_TEST1"
  L_json_pretty "$_L_JSON_TEST1"
}

###############################################################################

if L_is_main; then
  L_unittest_main -p _L_test_ "$@"
fi
