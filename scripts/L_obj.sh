#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh

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
L_obj_key_pack_vL_RET() {
  printf -v L_RET "\t%q" "$@"
  # local _L_i IFS=$'\3' _L_keys=("${@//$'\2'/$'\2E'}")   # ESC  -> ESC 'E'
  # _L_keys=("${_L_keys[@]//$'\3'/$'\2D'}")   # DELIM-> ESC 'D'  (no raw \3 introduced)
  # L_RET=$IFS${_L_keys[*]}
}
L_obj_key_unpack_vL_RET() {
  eval "L_RET=(" "$@" ")"
  # IFS=$'\3' read -ra L_RET <<<"$*"
  # L_RET=("${L_RET[@]:1}")
  # L_RET=("${L_RET[@]//$'\2D'/$'\3'}")
  # L_RET=("${L_RET[@]//$'\2E'/$'\2'}")
}
L_obj_set_meta() {
  local -n _L_obj=$1 || return
  local L_RET
  L_obj_key_pack_vL_RET "${@:3:$#-4}"
  _L_obj["$2$L_RET"]="${*:$#}"
}
L_obj_get_meta_vL_RET() {
  local -n _L_obj=$1 || return
  L_obj_key_pack_vL_RET "${@:3}"
  L_RET=${_L_obj["$2$L_RET"]}
}
# L_obj_set_type obj word word 3 = 3
L_obj_set_type() {
  local -n _L_obj=$1 || return
  _L_obj["hastypes"]=1
  L_obj_set_meta "$1" "type" "${@:2}"
}
L_obj_get_type_vL_RET() { L_obj_get_meta_vL_RET "$1" "type" "${@:2}"; }
# L_obj_set obj word word 3 = 3
L_obj_set() {
  local -n _L_obj=$1 || return
  if (( ${_L_obj["hastypes"]:+1}0 )); then
    : todo check types of indexes
  fi
  L_obj_set_meta "$1" "" "${@:2}"
}
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
    if [[ "$_L_i" == "$L_RET"$'\3'* ]]; then
      _L_obj2["${_L_i:${#L_RET}}"]="${_L_obj["$_L_i"]}"
    fi
  done
}
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
    elif [[ "$L_RET" == "$_L_prefix"$'\3'* ]]; then
      L_RET="${L_RET##"$_L_prefix"$'\3'}"
      L_RET=${L_RET%%$'\3'*}
      L_ARET["$L_RET"]=""
    fi
  done
  L_RET=("${!L_ARET[@]}")
}
L_obj_len_vL_RET() {
  local -n _L_obj=$1 || return
  L_obj_keys_vL_RET "$@"
  L_RET=${#L_RET[@]}
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
    if [[ "$_L_i" == "$L_RET"$'\3'* ]]; then
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
L_obj_push() {
  local -n _L_obj=$1 || return
  L_obj_set_type "${@:1:$#-2}" array
  local _L_nextidx=0 _L_key L_RET
  L_obj_key_pack_vL_RET "${@:2:$#-3}"
  _L_prefix=$L_RET
  for L_RET in "${!_L_obj[@]}"; do
    if [[ "$L_RET" == "$_L_prefix"* ]]; then
      L_RET="${L_RET##"$_L_prefix"$'\3'}"
      L_RET=${L_RET%%$'\3'*}
      if (( _L_nextidx <= L_RET )); then
        _L_nextidx=$(( L_RET + 1 ))
      fi
    fi
  done
  _L_obj["$_L_prefix"$'\3'"$_L_nextidx"]="${*:$#}"
}
# L_obj_walk obj cb <args>...
# calls cb <args>... <obj> <section>... <value>
L_obj_walk() {
  local -n _L_obj="$1" || return
  local _L_keys=("${!_L_obj[@]}") _L_objname=$1 _L_i
  L_sort _L_keys
  for _L_i in "${_L_keys[@]}"; do
    if [[ "$_L_i" == $'\3'* ]]; then
      L_obj_key_unpack_vL_RET "$_L_i"
      "${@:2}" "$_L_objname" "${L_RET[@]}" "${_L_obj["$_L_i"]}" || return
    fi
  done
}

# _L_obj_pp_add_L_RET_q VAR STR: leave simple tokens bare, %q-quote anything with
# spaces, ",{}=", quotes, newlines, etc. (empty becomes '')
_L_obj_pp_add_L_RET_q() {
  if [[ -n $1 && $1 != *[!a-zA-Z0-9_.@/:+-]* ]]; then
    printf -v _L_obj_pp_ret %s%s "$_L_obj_pp_ret" "$1"
  else
    printf -v _L_obj_pp_ret %s%q "$_L_obj_pp_ret" "$1"
  fi
}
# L_obj_walk callback: $1=obj, $2..$(#-1)=key parts, ${!#}=value
_L_obj_pp_cb() {
  local _L_n=$(( $# - 2 )) _L_parts=("${@:2:$#-2}") _L_val=${!#} _L_i _L_c=0
  if (( _L_n <= 0 )); then
    return 0
  fi
  local _L_nd=$(( _L_n - 1 )) _L_pd=${#_L_pp_prev[@]}
  # length of the common parent-path prefix
  while (( _L_c < _L_pd && _L_c < _L_nd )) && [[ ${_L_pp_prev[_L_c]} == "${_L_parts[_L_c]}" ]]; do
    (( ++_L_c ))
  done
  # close groups
  for (( _L_i = _L_c; _L_i < _L_pd; _L_i++ )); do _L_obj_pp_ret+="}"$'\n'; done
  if (( _L_pp_started )); then
    _L_obj_pp_ret+=" "
  fi
  # open groups
  for (( _L_i = _L_c; _L_i < _L_nd; _L_i++ )); do
    _L_obj_pp_add_L_RET_q "${_L_parts[_L_i]}"
    _L_obj_pp_ret+="{"
  done
  _L_obj_pp_add_L_RET_q "${_L_parts[_L_nd]}"
  _L_obj_pp_ret+="="
  _L_obj_pp_add_L_RET_q "$_L_val"
  _L_pp_started=1
  _L_pp_prev=("${_L_parts[@]:0:_L_nd}")
}
# L_obj_pretty_vL_RET OBJ  ->  _L_obj_pp_ret
L_obj_pretty_vL_RET() {
  local _L_pp_prev=() _L_pp_started=0 _L_i=0 _L_obj_pp_ret=""
  L_obj_walk "$1" _L_obj_pp_cb || return
  while (( _L_i++ < ${#_L_pp_prev[@]} )); do _L_obj_pp_ret+="}"; done
  L_RET="$1($_L_obj_pp_ret)"
}
L_obj_pretty_print() { local _L_obj_pp_ret; L_obj_pretty_vL_RET "$1" && printf '%s\n' "$L_RET"; }

###############################################################################

_L_test_obj() {
  L_obj_key_pack_vL_RET word word 3
  declare -p L_RET
  L_obj_key_unpack_vL_RET "$L_RET"
  declare -p L_RET
  L_obj_key_pack_vL_RET word word 3 $'\3' $'\2' $'\2D' $'\2E'
  declare -p L_RET
  L_obj_key_unpack_vL_RET "$L_RET"
  declare -p L_RET
  declare -A obj=()
  # # {"a":{"b":[1,2,3]}}
  L_obj_set obj a b 1 = 1
  L_obj_set obj a b 2 = 2
  L_obj_set obj a b 3 = 3
  L_obj_set obj a c = daed
  L_obj_set obj a d = daed
  L_obj_set obj a f = daed
  declare -p obj
  L_obj_len_vL_RET obj a b
  echo "$L_RET"
  L_obj_len_vL_RET obj a
  echo "$L_RET"
  L_obj_len_vL_RET obj a b 1
  echo "$L_RET"
  L_obj_push obj a b += 4
  L_pp -m obj
  L_obj_walk obj echo
  L_obj_append obj a f += dead
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

# L_ini_parse "string" callback [args...]
# Calls: callback... section SECTION
#        callback... kv SECTION KEY VALUE
#        callback... continuation SECTION KEY VALUE
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
        "${@:2}" section "$_L_section" || return
        continue
      fi
    fi
    if (( _L_indented )) && [[ -n $_L_key ]]; then
      _L_ini_value_into _L_val "$_L_line"
      "${@:2}" continuation "$_L_section" "$_L_key" "$_L_val" || return
    elif [[ $_L_line == [^=:]*[=:]* ]]; then
      _L_strip_into _L_key "${_L_line%%[=:]*}"
      _L_ini_value_into _L_val "${_L_line#*[=:]}"
      "${@:2}" kv "$_L_section" "$_L_key" "$_L_val" || return
    elif [[ -n $_L_key ]]; then
      _L_ini_value_into _L_val "$_L_line"
      "${@:2}" continuation "$_L_section" "$_L_key" "$_L_val" || return
    fi
  done <<<"$1"
}

L_ini_parse_into_obj() {
  local -n _L_dest=$1
  _L_ini_cb() {
    case "$1" in
      kv) L_obj_set _L_dest "$2" "$3" = "$4" ;;
      continuation) L_obj_append _L_dest "$2" "$3" += $'\n'"$4" ;;
    esac
  }
  L_ini_parse "$2" _L_ini_cb
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
      ;;
  esac
  printf -v "$1" %s "$_s"
}

# L_ini_from_obj_vL_RET OBJ
# Serializes OBJ (via L_obj_walk) to INI text in L_RET.
L_ini_from_obj_vL_RET() {
  local _L_ini_ret="" _L_last_section="" _L_ini_rc=0
  _L_ini_cb() {
    local rest=$4 line quotedline first=1
    if [[ $2 != "$_L_last_section" ]]; then
      _L_last_section=$2
      _L_ini_ret+="[$2]"$'\n'
    fi
    while :; do
      line=${rest%%$'\n'*}
      if ! _L_ini_quote quotedline "$line" "$(( !first ))"; then
        _L_ini_rc=1
        return 1
      fi
      if (( first )); then
        _L_ini_ret+="$3 =${quotedline:+ $quotedline}"$'\n'
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
  L_ini_parse_into_obj out "$var"
  L_ini_from_obj_vL_RET out
  if [[ "$L_RET" != "$expected" ]]; then
    diff <(<<<"$L_RET" cat) - <<<"$expected" || :
    L_unittest_fail "ini obj roundtrip failure"
    exit 1
  fi
  L_pp -m out
  L_obj_pretty_print out
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
	[[ $s == '"'*'"' ]] || return "$L_EX_DATAERR"
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
    if ! L_json_unquote_vL_RET "${BASH_REMATCH[1]}"; then
      _L_json_err "invalid json string: ${BASH_REMATCH[1]}" || return
    fi
    _L_string=$L_RET
    _L_json="${_L_json:${#BASH_REMATCH[0]}}"
  else
    _L_json_err "Expected string"
  fi
}
_L_json_read_object_element() {
  _L_json_read_string || return
  "$_L_json_cb" key "$_L_string" || return
  _L_json_lstrip
  if [[ "$_L_json" != :* ]]; then
    _L_json_err "Missing ':'"; return
  fi
  "$_L_json_cb" token ":" || return
  _L_json=${_L_json:1} _L_json_type="key" _L_json_context+=("$_L_string")
  _L_json_read_value || return
  unset "_L_json_context[${#_L_json_context[@]}-1]"
}
_L_json_read_array_element() {
  _L_json_type="array" _L_json_context+=("$((_L_idx++))")
  _L_json_read_value || return;
  unset "_L_json_context[${#_L_json_context[@]}-1]"
}
_L_json_read_value() {
  local _L_tmp _L_string _L_idx=0
  case "$_L_json" in
    [$' \t\r\n']*) _L_json_lstrip; _L_json_read_value; return ;;
    '"'*)
      _L_json_read_string || return
      "$_L_json_cb" value "$_L_string" string || return
      ;;
    [-0-9]*)
      if [[ "$_L_json" =~ $_L_float_re ]]; then
        "$_L_json_cb" value "${BASH_REMATCH[0]}" number || return
        _L_json=${_L_json:${#BASH_REMATCH[0]}}
      else
        _L_json_err "Invalid number"; return
      fi
      ;;
    '{'*)
      "$_L_json_cb" start "{" || return
      _L_json=${_L_json:1}
      while (( 1 )); do
        case "$_L_json" in
          [$' \t\r\n']*) _L_json_lstrip; continue ;;
          '"'*) _L_json_read_object_element || return ;;
          '}'*) _L_json=${_L_json:1}; "$_L_json_cb" end "}" || return; return ;;
          '') _L_json_err "Unexpected EOF"; return ;;
          *) _L_json_err "Invalid object element"; return
        esac
        while
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1}; "$_L_json_cb" token "," || return ;;
            '}'*) _L_json=${_L_json:1}; "$_L_json_cb" end "}" || return; return ;;
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
      "$_L_json_cb" start "[" || return
      _L_json=${_L_json:1}
      while (( 1 )); do
        case "$_L_json" in
          [$' \t\r\n']*) _L_json_lstrip; continue ;;
          ']'*) _L_json=${_L_json:1}; "$_L_json_cb" end ']' || return; return ;;
          *) _L_json_read_array_element || return ;;
        esac
        while
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1}; "$_L_json_cb" token "," || return ;;
            ']'*) _L_json=${_L_json:1}; "$_L_json_cb" end ']' || return; return ;;
            '') _L_json_err "Unexpected EOF"; return ;;
            *) _L_json_err "Invalid array element"; return ;;
          esac
        do
          _L_json_read_array_element || return
        done
        _L_json_err "Missing array end ']'"; return
      done
      ;;
    true*|null*) "$_L_json_cb" value "${_L_json::4}" "${_L_json::4}" || return; _L_json=${_L_json:4} ;;
    false*) "$_L_json_cb" value "${_L_json::5}" "${_L_json::5}" || return; _L_json=${_L_json:5} ;;
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
      value)
        L_obj_set_type _L_a "${_L_json_context[@]}" = "$_L_json_type"
        L_obj_set _L_a "${_L_json_context[@]}" = "$2"
        ;;
      start)
        if (( !${#_L_json_context[@]:+1}0 )); then
          # Root object/array - store type marker for empty containers
          _L_a["json_root"]="$2"
        fi
    esac
  }
  _L_json_read _L_json_to_obj_cb
}

L_obj_to_json() { L_handle_v_scalar "$@"; }
L_obj_to_json_vL_RET() {
  local -n _L_obj=$1 || return
  local _L_key _L_prev=() _L_idx=0 _L_prevlen=0 _L_cur _L_json="" _L_curlen
  # Handle empty object/array
  if [[ ${#_L_obj[@]} -eq 1 && "${!_L_obj[*]}" == 'json_root' ]]; then
    case "${_L_obj[*]}" in
      "{") L_RET='{}' ;;
      "[") L_RET='[]' ;;
      *) L_RET="" ;;
    esac
    return
  fi
  for _L_key in "${!_L_obj[@]}"; do
    L_obj_key_unpack_vL_RET "$_L_key"
    _L_cur=("${L_RET[@]}")
    _L_curlen=${#_L_cur[@]}
    value=${_L_obj["$key"]}
    # Get the number of elements the same in both _L_cur and _L_prev.
    local _L_samenum=0
    while (( _L_samenum < _L_curlen && _L_samenum < _L_prevlen )) && [[ "${_L_cur[_L_samenum]}" == "${_L_prev[_L_samenum]}" ]]; do
      (( ++_L_samenum ))
    done
    # If same level as before except last element.
    if (( _L_samenum == _L_prevlen - 1 && _L_samenum == _L_curlen - 1 )); then
      L_RET+=","
      # If object, add key:, otherwise just comma is enough.
      if [[ "${_L_cur[_L_samenum]}" == '"'* ]]; then
        L_RET+="${_L_cur[_L_samenum]}:"
      fi
    else
      # Close objects that diff.
      for (( _L_idx = _L_prevlen - 1; _L_idx > _L_samenum; --_L_idx )); do
        if [[ "${_L_prev[_L_idx]}" == '"'* ]]; then
          L_RET+="}"
        else
          L_RET+="]"
        fi
      done
      # Start objects or arrays.
      local _L_first="${L_RET:+,}"
      for (( _L_idx = _L_samenum ; _L_idx < _L_curlen; ++_L_idx )); do
        if [[ "${_L_cur[_L_idx]}" == '"'* ]]; then
          L_RET+=${_L_first:-'{'}"${_L_cur[_L_idx]}:"
        else
          L_RET+=${_L_first:-'['}
        fi
        _L_first=""
      done
    fi
    L_RET+="$value"
    # Ending.
    _L_prev=("${_L_cur[@]}") _L_prevlen=$_L_curlen
  done
  for (( _L_idx = _L_curlen - 1; _L_idx >= 0; --_L_idx )); do
    if [[ "${_L_prev[_L_idx]}" == '"'* ]]; then
      L_RET+="}"
    else
      L_RET+="]"
    fi
  done
}

L_json_get() { L_handle_v_array "$@"; }
L_json_get_vL_RET() {
  local _L_json="$1" _L_orig_json="$1" _L_initlen="${#1}" _L_key _L_start="" _L_end="" _L_value_captured=0 _L_value=""
  L_json_path_to_obj_key -v _L_key "$2" || return
  _L_json_cb() {
    L_obj_key_pack_vL_RET "${_L_json_context[@]}"
    case "$1 $L_RET" in
      "start $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "end $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))"; return 124 ;;
      "value $_L_key") _L_value=$2 _L_value_captured=1; return 124 ;;
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
      "start $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "end $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))"; return 124 ;;
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
    "start "["[{"])
      case "$_L_last" in
        ["{,"]) _L_out+=$'\n'$indent ;;
        ":") _L_out+=" " ;;
      esac
      (( ++_L_lvl ))
      _L_out+="$L_BOLD$2$L_RESET"
      ;;
    "end "["]}"])
      (( _L_lvl-- ))
      printf -v indent "%*s" "$((_L_indent*_L_lvl))" ""
      _L_out+=$'\n'"$indent$L_BOLD$2$L_RESET"
      ;;
    "token "":")
      if [[ "$_L_last" == ["{,"] ]]; then _L_out+=$'\n'; fi
      _L_out+="$L_BOLD$2$L_RESET"
      ;;
    "token "",") _L_out+="$L_BOLD,$L_RESET" ;;
    key*|value*)
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

_L_test_ini
