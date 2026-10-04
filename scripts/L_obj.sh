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

_L_obj_is_valid_key() { [[ "${1//\\[.\\]/}" != *\\* ]]; }
# a.b.c -> a
_L_obj_key_get_first_vL_RET() { L_RET=${1//\\[.\\]/XX} L_RET=${L_RET%%.*} L_RET=${1::${#L_RET}}; }
_L_obj_set_raw() { local -n _L_obj=$1 && _L_obj_is_valid_key "$2" && _L_obj["$2"]=$3; }
_L_obj_get_raw_vL_RET() {
  local -n _L_obj=$1 && _L_obj_is_valid_key "$2" && [[ -v "$1[$2]" ]] && L_RET=${_L_obj["$2"]}
}
_L_obj_get_raw_setdefault_vL_RET() {
  local -n _L_obj=$1 && _L_obj_is_valid_key "$2" && L_RET=${_L_obj["$2"]=$3}
}
_L_obj_key_escape_vL_RET() { L_RET=("${@//\\/\\\\}") L_RET=("${L_RET[@]//./\\.}"); }
_L_obj_key_unescape_vL_RET() { L_RET=("${@/\\\\/\\}") L_RET=("${L_RET[@]//\\./.}"); }
_L_obj_is_array() { local -n _L_obj=$1 && [[ "${_L_obj["TYPE.$2"]:-}" == array ]]; }
_L_obj_is_object() { local -n _L_obj=$1 && [[ "${_L_obj["TYPE.$2"]:-}" == object ]]; }

L_obj_key_join() { L_handle_v_scalar "$@"; }
L_obj_key_join_vL_RET() { local IFS=.; L_RET=("${@//\\/\\\\}") L_RET="${L_RET[*]//./\\.}"; }

L_obj_key_split() { L_handle_v_scalar "$@"; }
L_obj_key_split_vL_RET() {
  if [[ $1 != *\\* ]]; then
    readarray -t -d . L_RET <<<"$1."
    unset 'L_RET[-1]'
  else
    L_RET=${1//$'\2'/$'\2\3'}
    L_RET=${L_RET//\\\\/$'\2\5'}
    L_RET=${L_RET//\\./$'\2\4'}
    readarray -t -d . L_RET <<<"$L_RET."
    unset 'L_RET[-1]'
    L_RET=("${L_RET[@]//$'\2\4'/.}")
    L_RET=("${L_RET[@]//$'\2\5'/\\}")
    L_RET=("${L_RET[@]//$'\2\3'/$'\2'}")
  fi
}

# L_obj_set_type obj word.word.3 = 3
L_obj_set_type() {
  case "${!#}" in
    none|bool|integer|float|string|array|object) ;;
    *) return $L_EX_USAGE
  esac
  _L_obj_set_raw "$1" "TYPE.$2" "${!#}" || return
  local -n _L_obj=$1 || return
  _L_obj["HASTYPE"]=1
}

L_obj_get_type() { L_handle_v_scalar "$@"; }
L_obj_get_type_vL_RET() { _L_obj_get_raw_vL_RET "$1" "TYPE.$2"; }

L_obj_get_type_default() { L_handle_v_scalar "$@"; }
L_obj_get_type_default_vL_RET() { _L_obj_get_raw_vL_RET "$1" "TYPE.$2" || L_RET=$3; }

L_obj_get_type_setdefault() { L_handle_v_scalar "$@"; }
L_obj_get_type_setdefault_vL_RET() { _L_obj_get_raw_setdefault_vL_RET "$1" "TYPE.$2" "$3"; }

_L_is_natural_integer() {
  case "$1" in
    ''|*[!0-9]*|0?*) return 1 ;;
  esac
}

L_obj_infer_type() { L_handle_v_scalar "$@"; }
L_obj_infer_type_vL_RET() {
  if ! L_obj_get_type_vL_RET "$@"; then
    local -n _L_obj=$1 || return
    if [[ -v "_L_obj[VALUE.$2]" ]]; then
      L_RET=string
    else
      local _L_key _L_prefix="VALUE.$2" _L_seen=() _L_max=0
      for _L_key in "${!_L_obj[@]}"; do
        if [[ "$_L_key" == "$_L_prefix".* ]]; then
          _L_obj_key_get_first_vL_RET "${_L_key:${#_L_prefix}+1}"
          if ! _L_is_natural_integer "$L_RET"; then
            L_RET=object
            return
          fi
          _L_seen[$L_RET]=""
          if (( _L_max < L_RET )); then
            _L_max=L_RET
          fi
        fi
      done
      if (( ${#_L_seen[@]} == 0 )); then
        if (( $# >= 3 )); then
          L_RET=$3
        else
          return 1
        fi
      elif (( _L_max >= 0 && ${#_L_seen[@]} == _L_max + 1 )); then
        L_RET=array
      else
        L_RET=object
      fi
    fi
    L_obj_set_type "$1" "$2" "$L_RET"
  fi
}

# L_obj_set obj word.word.3 = 3
L_obj_set() {
  local -n _L_obj=$1 || return
  if [[ -v "_L_obj[HASTYPE]" ]]; then
    : todo check types of indexes
  fi
  _L_obj_set_raw "$1" "VALUE.$2" "${!#}"
}

# L_obj_set_many obj prefix name value [name value]...
L_obj_set_many() {
  local _L_name=$1 _L_prefix=$2
  shift 2
  while (( $# >= 2 )); do
    L_obj_set "$_L_name" "$_L_prefix.$1" = "$2" || return
    shift 2
  done
}

L_obj_get() { L_handle_v_scalar "$@"; }
L_obj_get_vL_RET() { _L_obj_get_raw_vL_RET "$1" "VALUE.$2"; }

L_obj_get_default() { L_handle_v_scalar "$@"; }
L_obj_get_default_vL_RET() { _L_obj_get_raw_vL_RET "$1" "VALUE.$2" || L_RET=$3; }

L_obj_get_setdefault() { L_handle_v_scalar "$@"; }
L_obj_get_setdefault_vL_RET() { _L_obj_get_raw_setdefault_vL_RET "$1" "VALUE.$2" "$3"; }

L_obj_keys() { L_handle_v_array "$@"; }
L_obj_keys_vL_RET() {
  local -n _L_obj=$1 || return
  _L_obj_is_valid_key "${2:-}" || return
  if [[ -v "_L_obj[VALUE.${2:-}]" ]]; then
    L_RET=("${2:-}")
  else
    declare -A L_ARET=()
    for L_RET in "${!_L_obj[@]}"; do
      if [[ "$L_RET" == "VALUE.${2:-}."* ]]; then
        _L_obj_key_get_first_vL_RET "${L_RET##"VALUE.${2:-}."}"
        L_ARET["$L_RET"]=""
      fi
    done
    L_RET=("${!L_ARET[@]}")
  fi
}

L_obj_len() { L_handle_v_scalar "$@"; }
L_obj_len_vL_RET() {
  L_obj_infer_type_vL_RET "$1" "${2:-}" || return
  case "$L_RET" in
    array|object) L_obj_keys_vL_RET "$@" && (( L_RET=${#L_RET[@]} )) ;;
    *) L_obj_get_vL_RET "$1" "${2:-}" && L_RET=${#L_RET} ;;
  esac
}

L_obj_has() { [[ -v "$1[VALUE.$2]" ]]; }

L_obj_del() {
  local -n _L_obj=$1 || return
  _L_obj_is_valid_key "${2:-}" || return
  local _L_i
  for _L_i in "${!_L_obj[@]}"; do
    case "$_L_i" in
      "TYPE.${2:-}"|"VALUE.${2:-}"|"TYPE.${2:-}."*|"VALUE.${2:-}."*) unset -v "_L_obj[$_L_i]"
    esac
  done
}

L_obj_string_append() {
  local -n _L_obj=$1 || return
  local L_RET
  _L_obj_is_valid_key "${2:-}" || return
  L_obj_get_type_default_vL_RET "$1" "${2:-}" "string"
  if [[ "$L_RET" != string ]]; then
    L_func_error "cannot append to '$2' in '$1': it is type $L_RET, expected string"
    return "$L_EX_USAGE"
  fi
  _L_obj["VALUE.${2:-}"]+="${!#}"
}

# L_obj_array_push obj a.b += a
L_obj_array_append() {
  local -n _L_obj=$1 || return
  local _L_nextidx=0 L_RET
  L_obj_infer_type_vL_RET "$1" "$2" "array"
  if [[ "$L_RET" != "array" ]]; then
    L_func_error "cannot append to '$2' in '$1': it is type $L_RET, exepcted array"
    return "$L_EX_USAGE"
  fi
  for L_RET in "${!_L_obj[@]}"; do
    if [[ "$L_RET" == "VALUE.$2."* ]]; then
      _L_obj_key_get_first_vL_RET "${L_RET##"VALUE.$2."}"
      if (( _L_nextidx <= L_RET )); then
        _L_nextidx=$(( L_RET + 1 ))
      fi
    fi
  done
  _L_obj["VALUE.$2.$_L_nextidx"]="${!#}"
}

# L_obj_walk_values obj cb <args>...
# calls cb <args>... <section> <value>
L_obj_walk_values() {
  local -n _L_obj="$1" || return
  shift
  local _L_keys=("${!_L_obj[@]}") _L_i L_RET
  L_sort _L_keys
  for _L_i in "${_L_keys[@]}"; do
    if [[ "$_L_i" == VALUE.* ]]; then
      "$@" "${_L_i:6}" "${_L_obj["$_L_i"]}" || return
    fi
  done
}

# L_obj_walk_all obj cb <args>...
# Calls:
#   cb <args>... START <key> <parts...>
#   cb <args>... VALUE <key> <value> <parts...>
#   cb <args>... END <key> <parts...>
#   cb <args>... META <key> <value>
L_obj_walk_all() {
  local -n _L_obj="$1" || return
  shift
  local _L_keys=("${!_L_obj[@]}") _L_key _L_level _L_parts=() _L_prev_group=() \
    _L_group_depth _L_prev_depth _L_common_depth  _L_open_keys=() L_RET
  L_sort _L_keys
  for _L_key in "${_L_keys[@]}"; do
    case "$_L_key" in
      VALUE.*)
        _L_key="${_L_key:6}"
        L_obj_key_split -v _L_parts "$_L_key"
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
          "$@" END "${_L_open_keys[_L_level - 1]}" "${_L_prev_group[@]:0:_L_level}" || return
        done
        _L_open_keys=("${_L_open_keys[@]:0:_L_common_depth}")   # forget closed groups
        # open groups we entered (shallowest first)
        for (( _L_level = _L_common_depth + 1; _L_level <= _L_group_depth; _L_level++ )); do
          L_obj_key_join_vL_RET "${_L_parts[@]:0:_L_level}"
          _L_open_keys+=("$L_RET")
          "$@" START "$L_RET" "${_L_parts[@]:0:_L_level}" || return
        done
        "$@" VALUE "$_L_key" "${_L_obj["VALUE.$_L_key"]}" "${_L_parts[@]}" || return
        _L_prev_group=("${_L_parts[@]:0:_L_group_depth}")
        ;;
      TYPE.*) ;;
      *)
        # META: keys that are not packed section keys
        "$@" META "$_L_key" "${_L_obj["$_L_key"]}" || return
    esac
  done
  # close whatever is still open
  for (( _L_level = ${#_L_prev_group[@]}; _L_level > 0; _L_level-- )); do
    "$@" END "${_L_open_keys[_L_level - 1]}" "${_L_prev_group[@]:0:_L_level}" || return
  done
}

# _L_obj_pp_q_vL_RET VAR STR: leave simple tokens bare, %q-quote anything with
# spaces, ",{}=", quotes, newlines, etc. (empty becomes '')
_L_obj_pp_q_vL_RET() {
  if [[ -n "$1" && "$1" != *[!a-zA-Z0-9_.@/:+-]* ]]; then
    printf -v L_RET %s "$1"
  else
    printf -v L_RET %q "$1"
  fi
}
# args: <obj> START|VALUE|END|META <key> [VALUE] <sections...>
_L_obj_pp_cb() {
  case $2 in
  META)
    if [[ "$3" != TYPE.* ]]; then
      _L_obj_pp_q_vL_RET "$3"
      _L_obj_pp_meta+="$_L_obj_pp_meta_sep$L_RET="
      _L_obj_pp_q_vL_RET "$4"
      _L_obj_pp_meta+="$L_RET"
      _L_obj_pp_meta_sep=" "
    fi
    ;;
  START)
    _L_obj_pp_q_vL_RET "${!#}"  # group name = last part
    _L_cb_out+="$_L_cb_sep$L_RET="
    if _L_obj_is_array "$1" "$3"; then
      _L_cb_out+="["
    else
      _L_cb_out+="{"
    fi
    _L_cb_sep=""  # first child of a group gets no leading space
    ;;
  END)
    if _L_obj_is_array "$1" "$3"; then
      _L_cb_out+="]"
    else
      _L_cb_out+="}"
    fi
    _L_cb_sep=" "
    ;;
  VALUE)
    _L_cb_out+="$_L_cb_sep"
    _L_obj_pp_q_vL_RET "${!#}"  # key name
    _L_cb_out+="$L_RET"
    if L_obj_get_type_vL_RET "$1" "$3"; then
      _L_cb_out+=":$L_RET"
    fi
    _L_obj_pp_q_vL_RET "$4"  # value
    _L_cb_out+="=$L_RET"
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

_L_test_obj_1() {
  local L_RET
  {
    L_obj_key_join_vL_RET word word 3
    L_obj_key_split_vL_RET "$L_RET"
    L_unittest_arreq L_RET word word 3
  }
  {
    L_obj_key_join_vL_RET word word 3 $'\t' $'\2' $'\2D' $'\2E' $'\3'
    L_obj_key_split_vL_RET "$L_RET"
    L_unittest_arreq L_RET word word 3 $'\t' $'\2' $'\2D' $'\2E' $'\3'
  }
  local -A obj=()
  {
    # # {"a":{"b":[1,2,3]}}
    L_obj_set obj a.b.1 = 1
    L_obj_set obj a.b.2 = 2
    L_obj_set obj a.b.3 = 3
    L_obj_set obj a.c = dead1
    L_obj_set obj a.d = dead2
    L_obj_set obj a.f = dead3
    L_obj_get_vL_RET obj a.b.1
    L_unittest_vareq L_RET 1
    L_obj_get_vL_RET obj a.b.2
    L_unittest_vareq L_RET 2
    L_obj_get_vL_RET obj a.b.3
    L_unittest_vareq L_RET 3
    L_obj_get_vL_RET obj a.c
    L_unittest_vareq L_RET dead1
    L_obj_get_vL_RET obj a.d
    L_unittest_vareq L_RET dead2
    L_obj_get_vL_RET obj a.f
    L_unittest_vareq L_RET dead3
    L_obj_len_vL_RET obj a.b
    L_unittest_vareq L_RET 3
    L_obj_len_vL_RET obj a
    L_unittest_vareq L_RET 4
    L_obj_len_vL_RET obj a.b.1
    L_unittest_vareq L_RET 1
    L_obj_len_vL_RET obj a.c
    L_unittest_vareq L_RET 5
    #
    L_unittest_failure L_obj_len_vL_RET obj a.b.c
  }
  {
    L_obj_array_append obj a.b += 4
    L_obj_len_vL_RET obj a.b
    L_unittest_vareq L_RET 4
    L_obj_array_append obj a.b += 5
    L_obj_len_vL_RET obj a.b
    L_unittest_vareq L_RET 5
  }
  {
    L_obj_string_append obj a.f += dead
    L_obj_get_vL_RET obj a.f
    L_unittest_vareq L_RET dead3dead
  }
  L_obj_print obj
  L_pp -m obj
}

_L_test_obj_2() {
  local L_RET
  local -A obj=()
  local stations=(warsaw "krakow.south" gdansk)
  local sensors=(temperature humidity pressure)
  local units=(C % hPa)
  local station base i s tick n

  # build the skeleton: stations.<id>.sensors.<1..3>.{name,unit}
  for station in "${stations[@]}"; do
    L_obj_key_join -v base stations "$station"   # escapes the dot in "krakow.south"
    L_obj_set obj "$base.name" = "$station"
    L_obj_set_type obj "$base.sensors" = array
    for i in "${!sensors[@]}"; do
      L_obj_set obj "$base.sensors.$i.name" = "${sensors[i]}"
      L_obj_set obj "$base.sensors.$i.unit" = "${units[i]}"
    done
  done

  # simulate 5 sampling ticks; the first tick seeds readings.1, the rest append
  for tick in 1 2 3 4 5; do
    for station in "${stations[@]}"; do
      L_obj_key_join -v base stations "$station"
      for s in 0 1 2; do
        L_obj_array_append obj "$base.sensors.$s.readings" += "$(( RANDOM % 100 ))"
      done
    done
    L_obj_set obj last_update = "$EPOCHSECONDS"
  done

    # --- lookups and lengths
  L_obj_key_join_vL_RET stations krakow.south
  base=$L_RET
  L_obj_get_vL_RET obj "$base.name"
  L_unittest_vareq L_RET krakow.south
  L_obj_len_vL_RET obj "$base.sensors"
  L_unittest_vareq L_RET 3
  L_obj_len_vL_RET obj "$base.sensors.1.readings"
  L_unittest_vareq L_RET 5
  L_obj_get_vL_RET obj "$base.sensors.2.unit"
  L_unittest_vareq L_RET hPa

  # --- iteration 1: by index (arrays), average each sensor of one station
  L_obj_len_vL_RET obj "$base.sensors"; local nsensors=$L_RET
  for (( s = 0; s < nsensors; s++ )); do
    local sum=0 name unit
    L_obj_get_vL_RET obj "$base.sensors.$s.name"; name=$L_RET
    L_obj_get_vL_RET obj "$base.sensors.$s.unit"; unit=$L_RET
    L_obj_len_vL_RET obj "$base.sensors.$s.readings"; n=$L_RET
    for (( i = 0; i < n; i++ )); do
      L_obj_get_vL_RET obj "$base.sensors.$s.readings.$i"
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
  L_time L_obj_walk_all obj obj_walk_cb

  # --- iteration 3: flat dump of the raw keys, to see the escaping
  L_time L_obj_print obj
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
      KV)
        L_obj_key_join_vL_RET "$2" "$3"
        L_obj_set _L_dest "$L_RET" = "$4" ;;
      CONTINUATION)
        L_obj_key_join_vL_RET "$2" "$3"
        L_obj_string_append _L_dest "$L_RET" += $'\n'"$4"
        ;;
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
    local line quotedline first=1 L_RET
    L_obj_key_split_vL_RET "$1"
    local section=${L_RET[0]} key=${L_RET[1]:-} rest=$2
    if [[ $section != "$_L_last_section" ]]; then
      _L_last_section=$section
      _L_ini_ret+="[$section]"$'\n'
    fi
    while :; do
      line=${rest%%$'\n'*}
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
      [[ $rest == *$'\n'* ]] || break
      rest=${rest#*$'\n'}
    done
  }
  L_obj_walk_values "$1" _L_ini_cb || _L_ini_rc=1
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
  echo "$var"
  L_ini_read_into_obj out <<<"$var"
  L_pp -m out
  L_obj_print out
  L_ini_from_obj_vL_RET out
  if [[ "$L_RET" != "$expected" ]]; then
    diff <(<<<"$L_RET" cat) - <<<"$expected" || :
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
        L_RET+=("${BASH_REMATCH[1]}")
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
      "$_L_json_cb" VALUE "${_L_string[0]}" string "${_L_string[1]}" || return
      ;;
    [-0-9]*)
      if [[ "$_L_json" =~ $_L_float_re ]]; then
        "$_L_json_cb" VALUE "${BASH_REMATCH[0]}" int || return
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
    null*) "$_L_json_cb" VALUE null null || return; _L_json=${_L_json:4} ;;
    true*) "$_L_json_cb" VALUE true bool || return; _L_json=${_L_json:4} ;;
    false*) "$_L_json_cb" VALUE false bool || return; _L_json=${_L_json:5} ;;
    '') _L_json_err "Unexpected EOF"; return ;;
    *) _L_json_err "Invalid value" || return ;;
  esac
}
# Call $1 with:
#   START [{
#   END ]}
#   VALUE parsed_value int|float|bool|null
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
# @arg <json string>
L_json_to_obj() {
  local -n _L_a=$1
  local _L_json=$2
  _L_a=()
  _L_json_to_obj_cb() {
    case "$1" in
      VALUE)
        if [[ "$3" != "string" ]]; then
          L_obj_set_type _L_a "${_L_JSON_PATH[@]}" = "$3"
        fi
        L_obj_set _L_a "${_L_JSON_PATH[@]}" = "$2"
        ;;
      START)
        if [[ "$2" == "[" ]]; then
          L_obj_set_type _L_a "${_L_JSON_PATH[@]}" = "array"
        fi
    esac
  }
  _L_json_parse _L_json_to_obj_cb
}

L_obj_to_json() { L_handle_v_scalar "$@"; }
_L_obj_to_json_cb() {
  case $2 in
    START)
      L_json_quote_vL_RET "${!#}"  # group name = last part
      _L_cb_out+="$_L_cb_sep$L_RET="
      if _L_obj_is_array "$1" "$3"; then
        _L_cb_out+="["
        _L_stack+=("[")
      else
        _L_cb_out+="{"
        _L_stack+=("{")
      fi
      _L_cb_sep=""
      ;;
    END)
      if _L_obj_is_array "$1" "$3"; then
        _L_cb_out+="]"
      else
        _L_cb_out+="}"
      fi
      unset -v "_L_stack[${#_L_stack[@]}-1]"
      _L_cb_sep=" "
      ;;
    VALUE)
      _L_cb_out+="$_L_cb_sep"
      if [[ "${_L_stack[${#_L_stack[@]}-1]}" == "{" ]]; then
        _L_obj_pp_q_vL_RET "${@:$#-1:1}"  # key name
        _L_cb_out+="$L_RET="
      fi
      L_obj_get_type_default_vL_RET "$1" "$3" string
      case "$L_RET" in
        bool|null|float|int) L_RET=${!#} ;;
        *) L_json_quote_vL_RET "${!#}" ;;
      esac
      _L_cb_out+="$L_RET"
      _L_cb_sep=" "
      ;;
  esac
}
L_obj_to_json_vL_RET() {
  local _L_cb_out="" _L_cb_sep="" _L_stack=()
  L_obj_walk_all "$1" _L_obj_to_json_cb "$1" || return
  L_RET=$_L_cb_out
}

L_json_is_valid() {
  _L_json_cb() { :; }
  local _L_json="$1"
  _L_json_parse _L_json_cb
}

L_json_get() { L_handle_v_array "$@"; }
L_json_get_vL_RET() {
  local _L_json="$1" _L_orig_json="$1" _L_initlen="${#1}" _L_key _L_start="" _L_end="" _L_value_captured=0 _L_value=""
  L_json_path_normalize -v _L_key "$2" || return
  _L_json_cb() {
    L_obj_key_join_vL_RET "${_L_JSON_PATH[@]}"
    case "$1 $L_RET" in
      "START $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "END $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))"; return 124 ;;
      "VALUE $_L_key") _L_value=$2 _L_value_captured=1; return 124 ;;
    esac
  }
  _L_json_parse _L_json_cb || eval "(( $? == 124 )) || return $?"
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
    L_obj_key_join_vL_RET "${_L_JSON_PATH[@]}"
    case "$1 $L_RET" in
      "START $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "END $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))"; return 124 ;;
    esac
  }
  _L_json_parse _L_json_cb || eval "(( $? == 124 )) || return $?"
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
      if [[ "$1" == "KEY" || $3 == "string" ]]; then
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
      elif [[ "$3" == string ]]; then
        _L_out+=$L_GREEN$L_RET$L_RESET
      elif [[ "$3" == null ]]; then
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
    printf -v expectedoutput "\t%s" "${tmp[@]:2}"
    if ! L_json_path_normalize -v output "$input"; then
      if (( expectedfail )); then
        continue
      else
        exit 1
      fi
    fi
    exit=$?
    L_pretty_print input " -> " output " ?=$exit"
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



###############################################################################

if L_is_main; then
  L_unittest_main -p _L_test_ "$@"
fi
