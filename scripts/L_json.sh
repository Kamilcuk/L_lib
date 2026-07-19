#!/bin/bash
set -euo pipefail

# . ./bin/L_lib.sh -s -n

shopt -s extglob

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

_L_float_re='^-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?'
_L_str_re=$'"([^"\x01-\x1f''\\]|\\["\\/bfnrt]|\\u[0-9a-fA-F]{4})*"'

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
  if [[ "$_L_json" =~ ^[$' \t\r\n']*($_L_str_re) ]]; then
    _L_string="${BASH_REMATCH[1]}"
    _L_json="${_L_json:${#BASH_REMATCH[0]}}"
  else
    _L_json_err "Expected string"
  fi
}
_L_json_read_object_element() {
  _L_json_read_string || return
  "$_L_json_cb" key "$_L_string"
  if (( _L_json_break )); then return; fi
  _L_json_lstrip
  if [[ "$_L_json" != :* ]]; then
    _L_json_err "Missing ':'"; return
  fi
  "$_L_json_cb" token ":" || return
  if (( _L_json_break )); then return; fi
  _L_json=${_L_json:1} _L_json_context+=$'\t'"$_L_string"
  _L_json_read_value || return
  _L_json_context=${_L_json_context%$'\t'*}
}
_L_json_read_array_element() {
  _L_json_context+=$'\t'"$((_L_idx++))";
  _L_json_read_value || return;
  _L_json_context=${_L_json_context%$'\t'*}
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
        while (( !_L_json_break )); do
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1}; "$_L_json_cb" token "," || return ;;
            '}'*) _L_json=${_L_json:1}; "$_L_json_cb" end "}" || return; return ;;
            '') _L_json_err "Unexpected EOF"; return ;;
            *) _L_json_err "Invalid object element"; return
          esac
          if (( !_L_json_break )); then
            _L_json_read_object_element || return
          fi
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
        while (( !_L_json_break )); do
          case "$_L_json" in
            [$' \t\r\n']*) _L_json_lstrip; continue ;;
            ','*) _L_json=${_L_json:1}; "$_L_json_cb" token "," || return ;;
            ']'*) _L_json=${_L_json:1}; "$_L_json_cb" end ']' || return; return ;;
            '') _L_json_err "Unexpected EOF"; return ;;
            *) _L_json_err "Invalid array element"; return ;;
          esac
          if (( !_L_json_break )); then
            _L_json_read_array_element || return
          fi
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
  local _L_json_len=${#_L_json} _L_json_context="" _L_json_cb=$1 _L_json_break=0 _L_json_errdepth=${#FUNCNAME[*]}
  # L_shopt_extglob 
      _L_json_read_value || return
  if [[ "$_L_json" == *[!$' \t\r\n']* ]]; then
    _L_json_err "Invalid tokens after value" || return
  fi
}

if (( ${BENCH:-0} )); then
  run() {
    _L_json='{"a":[{"b":"c"}],"d":[{"e":"f"}]}'
    _L_json_read :
  }
  return
  exit
fi
. ./bin/L_lib.sh -s -n

###############################################################################

L_json_unquote() { L_handle_v_scalar "$@"; }
L_json_unquote_vL_RET() {
  case "$1" in
    '"'*'"') L_json_unquote_vL_RET "${1:1:${#1}-2}" ;;
    *[!\\]\\\'*|\\\'*) false ;;
    *) eval "L_RET=$'$1'" ;;
  esac
}

L_json_path_normalize() { L_handle_v_scalar "$@"; }
L_json_path_normalize_vL_RET() { L_shopt_extglob L_json_path_normalize_vL_RET_in "$@"; }
L_json_path_normalize_vL_RET_in() {
  local _L_input=$1 _L_dot='' _L_tmp
  L_RET=""
  while (( 1 )); do
    case "$_L_input" in
      '["'*)
        if [[ "$_L_input" =~ \
          ^\[\"((([^\"$'\x01-\x1f'\\]|\\[\"\\/bfnrt])*)|([^\"$'\x01-\x1f'\\]|\\[\"\\/bfnrt]|\\u[0-9a-fA-F]{4})*)\"\] \
        ]]; then
          if (( ${#BASH_REMATCH[2]} )); then
            L_RET+=$'\t'"\"${BASH_REMATCH[2]}\""
          elif ! L_hash jq; then
            L_func_error "To handle \\u sequences jq is required, but not installed"; return "$L_EX_SOFTWARE"
          elif _L_tmp=$(jq '.[]' <<<"${BASH_REMATCH[0]}"); then
            L_RET+=$'\t'"$_L_tmp"
          else
            L_func_error "Invalid input string: $_L_input"; return "$L_EX_DATAERR"
          fi
          _L_input="${_L_input:${#BASH_REMATCH[0]}}"
        else
          L_func_error "Unclosed double quote string in bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        ;;
      "['"*)
        if [[ "$_L_input" =~ \
          ^\[\'((([^\'$'\x01-\x1f'\\]|\\[\'\\/bfnrt])*)|([^\'$'\x01-\x1f'\\]|\\[\'\\/bfnrt]|\\u[0-9a-fA-F]{4})*)\'\] \
        ]]; then
          _L_tmp=${BASH_REMATCH[1]//\\\'/\'}
          _L_input='["'${_L_tmp//\"/\\\"}'"]'${_L_input:${#BASH_REMATCH[0]}}
        else
          L_func_error "Unclosed single quote string in bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        ;;
      '['[0-9]*)
        if [[ "$_L_input" =~ ^'['(0|[1-9][0-9]*)']' ]]; then
          L_RET+=$'\t'"${BASH_REMATCH[1]}"
          _L_input="${_L_input:${#BASH_REMATCH[0]}}"
        else
          L_func_error "Invalid bracket notation: $_L_input"; return "$L_EX_DATAERR"
        fi
        ;;
      $_L_dot[^$'\x01-\x1f'"\\.\[\]@#%^&*+=|/?!~\`'\";:,{}()<>-"]*)
        if [[ "$_L_input" =~ ^$_L_dot([^"]"$'\x01-\x1f'"\\.\[@#%^&*+=|/?!~\`'\";:,{}()<>-"]+) ]]; then
          L_RET+=$'\t'"\"${BASH_REMATCH[1]}\""
          _L_input="${_L_input:${#_L_dot}+${#BASH_REMATCH[1]}}"
        else
          L_func_error "Empty key in JSON path: $_L_input"; return "$L_EX_DATAERR"
        fi
        ;;
      '') break ;;
      *) L_func_error "Invalid character in JSON path: $_L_input"; return "$L_EX_DATAERR" ;;
    esac
    _L_dot="."
  done
}

L_json_is_valid() {
  _L_json_cb() { :; }
  local _L_json="$1"
  _L_json_read _L_json_cb
}

_L_json_test() {
  _L_json_cb() { local IFS=" "; printf "!! %q %s\n" "$_L_json_context" "$*"; }
  local _L_json=$1
  _L_json_read _L_json_cb
}
_L_json_test_quiet() {
  local _L_json=$1
  _L_json_read :
}


L_json_get() { L_handle_v_scalar "$@"; }
L_json_get_vL_RET() {
  local _L_json="$1" _L_orig_json="$1" _L_initlen="${#1}" _L_key _L_start="" _L_end="" _L_value_captured=0
  L_json_path_normalize -v _L_key "$2" || return
  _L_json_cb() {
    case "$1 $_L_json_context" in
      "start $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "end $_L_key") _L_end="$(( _L_initlen - ${#_L_json} ))" _L_json_break=1 ;;
      "value $_L_key") L_RET="$2" _L_value_captured=1 _L_json_break=1 ;;
    esac
  }
  _L_json_read _L_json_cb || return
  if [[ -n "$_L_start" && -n "$_L_end" ]]; then
    L_RET="${_L_orig_json:_L_start:_L_end-_L_start}"
  elif [[ -z "${L_RET:-}" && $_L_value_captured -eq 0 ]]; then
    return 1
  fi
}

L_json_rm() { L_handle_v_scalar "$@"; }
L_json_rm_vL_RET() {
  local _L_json="$1" _L_initlen="${#1}" _L_start _L_end _L_key
  L_json_path_normalize -v _L_key "$2" || return
  _L_json_cb() {
    case "$1 $_L_json_context" in
      "start $_L_key") _L_start="$(( _L_initlen - ${#_L_json} ))" ;;
      "end $_L_key") _L_json_break=1 _L_end="$(( _L_initlen - ${#_L_json} ))" ;;
    esac
  }
  _L_json_read _L_json_cb || return
  L_RET="${_L_json::_L_start}"
  L_RET="${L_RET%,}${_L_json:_L_end}"
}

# @description Print nicely looking version of the json.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
# @arg $2 Number if spaces.
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
_L_json_compact() { _L_out+="$2"; }
L_json_compact_vL_RET() {
  local _L_json=$1 _L_out=""
  _L_json_read _L_json_compact
  L_RET=$_L_out
}

###############################################################################

_L_json_to_obj_cb() {
  if [[ "$1" == "value" ]]; then
    _L_a["$_L_json_context"]="$2"
  elif [[ "$1" == "start" && -z "$_L_json_context" ]]; then
    # Root object/array - store type marker for empty containers
    _L_a[$'\t__root_type__']="$2"
  fi
}

L_json_to_obj() {
  local -n _L_a=$1
  local _L_json=$2
  _L_a=()
  _L_json_read _L_json_to_obj_cb
}

L_obj_to_json() { L_handle_v_scalar "$@"; }
L_obj_to_json_vL_RET() {
  L_RET=""
  local keys prev=() idx=0 prevlen=0 IFS=$'\t' cur
  L_asa_keys -v keys "$1"
  L_sort keys
  # Handle empty object/array
  if [[ ${#keys[@]} -eq 1 && "${keys[0]}" == $'\t__root_type__' ]]; then
    eval "case \"\${$1[\"\${keys[0]}\"]}\" in
      \"{\") L_RET=\"{}\" ;;
      \"[\") L_RET=\"[]\" ;;
      *) L_RET=\"{}\" ;;
    esac"
    return
  fi
  for key in "${keys[@]}"; do
    # Start
    read -ra cur <<<"$key"
    curlen=${#cur[@]}
    eval "value=\${$1[\"\$key\"]}"
    # Get the number of elements the same in both cur and prev.
    local samenum=0
    while (( samenum < curlen && samenum < prevlen )) && [[ "${cur[samenum]}" == "${prev[samenum]}" ]]; do
      (( ++samenum ))
    done
    # If same level as before except last element.
    if (( samenum == prevlen - 1 && samenum == curlen - 1 )); then
      L_RET+=","
      # If object, add key:, otherwise just comma is enough.
      if [[ "${cur[samenum]}" == '"'* ]]; then
        L_RET+="${cur[samenum]}:"
      fi
    else
      # Close objects that diff.
      for (( idx = prevlen - 1; idx > samenum; --idx )); do
        if [[ "${prev[idx]}" == '"'* ]]; then
          L_RET+="}"
        else
          L_RET+="]"
        fi
      done
      # Start objects or arrays.
      local first="${L_RET:+,}"
      for (( idx = samenum ; idx < curlen; ++idx )); do
        if [[ "${cur[idx]}" == '"'* ]]; then
          L_RET+=${first:-'{'}"${cur[idx]}:"
        else
          L_RET+=${first:-'['}
        fi
        first=""
      done
    fi
    L_RET+="$value"
    # Ending.
    prev=("${cur[@]}") prevlen=$curlen
  done
  for (( idx = curlen - 1; idx >= 0; --idx )); do
    if [[ "${prev[idx]}" == '"'* ]]; then
      L_RET+="}"
    else
      L_RET+="]"
    fi
  done
}

# @arg $1 obj
# @arg $2 key
# @arg $3 value
L_obj_set() {
  local -n _L_obj="$1" || return
  local L_RET
  L_json_path_normalize_vL_RET "$2" || return
  _L_obj["$L_RET"]="$3"
}

# @arg $1 obj
# @arg $2 key
# @arg $3 json
L_obj_set_json() {
  local -n _L_obj="$1" || return
  local _L_obj_pos
  L_json_path_normalize -v _L_obj_pos "$2" || return
  _L_json_cb() { if [[ "$1" == "value" ]]; then _L_obj["$_L_obj_pos$_L_json_context"]="$2"; fi; }
  local _L_json="$2"
  _L_json_read _L_json_cb
}

# @arg $1 obj
# @arg $2 key
# @arg $3 obj
L_obj_set_obj() {
  local -n _L_obj="$1" _L_other="$3" || return
  local L_RET _L_i
  L_json_path_normalize_vL_RET "$2" || return
  for _L_i in "${!_L_other[@]}"; do
    _L_obj["$L_RET$_L_i"]="${_L_other["$_L_i"]}"
  done
}

# @option -v <var>
# @arg $1 obj
# @arg [$2] key
L_obj_len() { L_handle_v_array "$@"; }
L_obj_len_vL_RET() {
  local -n _L_obj="$1" || return
  local _L_key
  L_json_path_normalize -v _L_key "$2" || return
  L_RET=0
  for _L_i in "${!_L_obj[@]}"; do
    case "$_L_i" in
      "$_L_key") L_RET=${#_L_obj["$_L_i"]}; return ;;
      "$_L_key"$'\t''"'*) (( ++L_RET )) ;;
      "$_L_key"$'\t'[0-9]*) (( ++L_RET )) ;;
    esac
  done
}

# @option -v <var>
# @arg $1 obj
# @arg $2 key
L_obj_get() { L_handle_v_scalar "$@"; }
L_obj_get_vL_RET() {
  local -n _L_obj=$1
  L_json_path_normalize_vL_RET "$2" || return
  L_json_unquote_vL_RET "${_L_obj["$L_RET"]}" || return
}

# @option -v <var>
# @arg $1 obj
# @arg $2 key
L_obj_get_subobj() { L_handle_v_asa "$@"; }
L_obj_get_subobj_vL_RET() {
  local -n _L_obj=$1 || return 2
  local _L_key _L_keys=() _L_prefix
  L_json_path_normalize -v _L_prefix "$2" || return
  #
  for _L_key in "${!_L_obj[@]}"; do
    case "$_L_key" in
      "$_L_prefix") L_RET="${_L_obj["$_L_key"]}"; return ;;
      "$_L_prefix"$'\t'*) L_RET["${_L_key#"$_L_prefix"}"]="${_L_obj["$_L_key"]}" ;;
    esac
  done
}

# @option -v <var>
# @arg $1 obj
# @arg $2 key
L_obj_get_json() { L_handle_v_scalar "$@"; }
L_obj_get_json_vL_RET() {
  local -A _L_tmp
  L_obj_get_subobj -v _L_tmp "$@"
  L_obj_to_json_vL_RET _L_tmp
}

###############################################################################

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

_L_json_fetch_64KB_vL_RET() {
  L_cache -O L_RET -- curl -sSL https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json
}

_L_test_json_64KB() {
  local L_RET
  _L_json_fetch_64KB_vL_RET
  _L_json_test_quiet "$L_RET" || exit
}

# Test using first 20 elements (~5KB) from cached 64KB JSON
_L_test_json_5KB() {
  local L_RET
  _L_json_fetch_64KB_vL_RET
  L_RET=$(jq '.[:20]' <<<"$L_RET")
  _L_json_test "$L_RET" || exit
}

_L_test_json_to_obj() {
  local json back jsons
  L_readarray -t jsons <<'EOF'
{"a":"b","c":"d"}
[1,2,3,4]
{"a":[{"b":"c"}]}
{"a":[{"b":"c"}],"d":[{"e":"f"}]}
EOF
  for json in "${jsons[@]}"; do
    declare -A dest
    L_json_to_obj dest "$json"
    L_obj_to_json -v back dest
    _L_json_test "$back"
  done
}

declare _L_JSON_TEST1='{ "a" : "b" , "c" : [ "d" , 1 , true ], "e": { "f.": { "g": "h" } } } '

_L_test_json_1() {
  _L_json_test "$_L_JSON_TEST1"
}

_L_test_json_change() {
  L_unittest_cmd -o '{"a":"b","c":["d",1,true],"e":{"f.":{"g":"h"}}}' L_json_compact "$_L_JSON_TEST1"
  L_json_pretty "$_L_JSON_TEST1"
}

_L_test_json_obj() {
  declare -A obj=()
  L_json_to_obj obj "$_L_JSON_TEST1"
  declare -p obj
  L_obj_to_json obj
  L_obj_get obj 'e."f.".g'
  declare -A subobj=()
  L_obj_get_subobj -v subobj obj 'e'
  L_obj_get_subobj obj 'e'
  declare -p subobj
  L_pp subobj
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

_L_test_json_get() {
  local json='{"a":"b","c":[1,2,3],"d":{"e":"f"}}'
  L_unittest_cmd -o '"b"' L_json_get "$json" 'a'
  L_unittest_cmd -o '1' L_json_get "$json" 'c[0]'
  L_unittest_cmd -o '2' L_json_get "$json" 'c[1]'
  L_unittest_cmd -o '3' L_json_get "$json" 'c[2]'
  L_unittest_cmd -o '"f"' L_json_get "$json" 'd.e'
  L_unittest_cmd -o '{"e":"f"}' L_json_get "$json" 'd'
  L_unittest_cmd -o '[1,2,3]' L_json_get "$json" 'c'
  # Test with special keys
  local json2='{"a.b":"c"}'
  L_unittest_cmd -o '"c"' L_json_get "$json2" '["a.b"]'
  # Test non-existent keys (should return empty)
  L_unittest_cmd ! L_json_get "$json" 'x'
  L_unittest_cmd ! L_json_get "$json" 'c[5]'
}

_L_test_json_rm() {
  local json='{"a":"b","c":[1,2,3],"d":{"e":"f"}}'
  local result
  L_json_rm -v result "$json" 'a'
  L_unittest_vareq result '{"c":[1,2,3],"d":{"e":"f"}}'
  L_json_rm -v result "$json" 'c[1]'
  L_unittest_vareq result '{"a":"b","c":[1,3],"d":{"e":"f"}}'
  L_json_rm -v result "$json" 'd.e'
  L_unittest_vareq result '{"a":"b","c":[1,2,3],"d":{}}'
  # Test removing non-existent key (should return original)
  L_json_rm -v result "$json" 'x'
  L_unittest_cmd -o "$json" echo "$result"
}

_L_test_json_pretty_compact() {
  local json='{"a":"b","c":[1,2,3],"d":{"e":"f"}}'

  local compact
  L_json_compact -v compact "$json"
  L_unittest_vareq compact '{"a":"b","c":[1,2,3],"d":{"e":"f"}}'

  local pretty
  L_json_pretty -v pretty "$json" 2
  L_unittest_vareq pretty $'{\n*'
  L_unittest_vareq pretty $'*\n}'

  # Test with custom indent
  L_json_pretty -v pretty "$json" 4
  L_unittest_vareq pretty $'    "a"'
}

_L_test_json_to_obj_roundtrip() {
  local jsons=(
    '{}'
    '[]'
    '{"a":1}'
    '[1,2,3]'
    '{"a":[1,2,3]}'
    '[{"a":1},{"b":2}]'
    '{"a":{"b":{"c":1}}}'
    '{"a":"b","c":["d",1,true],"e":{"f.":{"g":"h"}}}'
    '{"": "empty key"}'
    '{"a": null}'
  )
  for json in "${jsons[@]}"; do
    declare -A obj
    L_json_to_obj obj "$json"
    local back
    L_obj_to_json -v back obj
    # Verify roundtrip by parsing both
    L_unittest_cmd _L_json_test "$json"
    L_unittest_cmd _L_json_test "$back"
  done
}

_L_test_obj_set() {
  declare -A obj=()

  L_obj_set obj 'a' '"b"'
  L_unittest_vareq obj[$'\ta'] '"b"'

  L_obj_set obj 'c[0]' '1'
  L_unittest_vareq obj[$'\tc\t0'] '1'

  L_obj_set obj 'c[1]' '2'
  L_unittest_vareq obj[$'\tc\t1'] '2'

  L_obj_set obj 'd.e' '"f"'
  L_unittest_vareq obj[$'\td\te'] '"f"'

  # Test with special characters in keys
  L_obj_set obj '["a.b"]' '"c"'
  L_unittest_vareq obj[$'\t"a.b"'] '"c"'
}

_L_test_obj_set_json() {
  declare -A obj=()

  L_obj_set_json obj 'a' '{"b":1,"c":[2,3]}'
  L_unittest_vareq obj[$'\ta\tb'] '1'
  L_unittest_vareq obj[$'\ta\tc\t0'] '2'
  L_unittest_vareq obj[$'\ta\tc\t1'] '3'

  L_obj_set_json obj 'd[]' '[1,2,3]'
  L_unittest_vareq obj[$'\td\t0'] '1'
  L_unittest_vareq obj[$'\td\t1'] '2'
  L_unittest_vareq obj[$'\td\t2'] '3'
}

_L_test_obj_set_obj() {
  declare -A obj=()
  declare -A other=([$'\ta']='"1"' [$'\tb']='"2"')

  L_obj_set_obj obj 'x' other
  L_unittest_vareq obj[$'\tx\ta'] '"1"'
  L_unittest_vareq obj[$'\tx\tb'] '"2"'
}

_L_test_obj_len() {
  local json='{"a":"b","c":[1,2,3],"d":{"e":"f","g":"h"}}'
  declare -A obj
  L_json_to_obj obj "$json"

  local len
  L_obj_len -v len obj
  L_unittest_eq "$len" '3'

  L_obj_len -v len obj 'c'
  L_unittest_eq "$len" '3'

  L_obj_len -v len obj 'd'
  L_unittest_eq "$len" '2'

  L_obj_len -v len obj 'x'
  L_unittest_eq "$len" '0'
}

_L_test_obj_get() {
  local json='{"a":"b","c":[1,2,3],"d":{"e":"f"}}'
  declare -A obj
  L_json_to_obj obj "$json"

  local val
  L_obj_get -v val obj 'a'
  L_unittest_eq "$val" 'b'

  L_obj_get -v val obj 'c[0]'
  L_unittest_eq "$val" '1'

  L_obj_get -v val obj 'c[1]'
  L_unittest_eq "$val" '2'

  L_obj_get -v val obj 'd.e'
  L_unittest_eq "$val" 'f'

  # Test with special keys
  local json2='{"a.b":"c"}'
  declare -A obj2
  L_json_to_obj obj2 "$json2"
  L_obj_get -v val obj2 '["a.b"]'
  L_unittest_eq "$val" 'c'
}

_L_test_obj_get_subobj() {
  local json='{"a":{"b":1,"c":2},"d":[3,4]}'
  declare -A obj
  L_json_to_obj obj "$json"
  #
  declare -A subobj
  L_obj_get_subobj -v subobj obj 'a'
  L_unittest_eq "${subobj[\$'\\tb']}" '1'
  L_unittest_eq "${subobj[\$'\\tc']}" '2'
  #
  L_obj_get_subobj -v subobj obj 'd'
  L_unittest_eq "${subobj[\$'\\t0']}" '3'
  L_unittest_eq "${subobj[\$'\\t1']}" '4'
  #
  # Test non-existent
  L_obj_get_subobj -v subobj obj 'x'
  L_unittest_eq "${#subobj[@]}" '0'
}

_L_test_obj_get_json() {
  local json='{"a":{"b":1,"c":2},"d":[3,4]}'
  declare -A obj
  L_json_to_obj obj "$json"
  #
  local subjson
  L_obj_get_json -v subjson obj 'a'
  L_unittest_eq "$subjson" '{"b":1,"c":2}'
  #
  L_obj_get_json -v subjson obj 'd'
  L_unittest_eq "$subjson" '[3,4]'
  #
  L_obj_get_json -v subjson obj 'x'
  L_unittest_eq "$subjson" '{}'
}

_L_test_json_path_edge_cases() {
  # Test various edge cases for path normalization
  local -A cases=(
    ['a']=$'\t"a"'
    ['a.b']=$'\t"a"\t"b"'
    ['a[0]']=$'\t"a"\t0'
    ['a["b"]']=$'\t"a"\t"b"'
    ['a["b.c"]']=$'\t"a"\t"b.c"'
    ['a["b\"c"]']=$'\t"a"\t"b\\"c"'
    ['["a"]']=$'\t"a"'
    ['[0]']=$'\t0'
    ['a.b[0].c']=$'\t"a"\t"b"\t0\t"c"'
    ['a[0][1][2]']=$'\t"a"\t0\t1\t2'
  )
  for input in "${!cases[@]}"; do
    local expected="${cases[$input]}"
    local output
    if [[ -z "$input" ]]; then
      L_json_path_normalize -v output "$input"
      L_unittest_vareq output "$expected" "Empty path"
    else
      L_json_path_normalize -v output "$input"
      L_unittest_vareq output "$expected" "Path: $input"
    fi
  done
  # Test invalid paths
  local invalid_paths=(
    'a['
    'a["b'
    'a["b]'
    'a..b'
    'a.["b"]'  # This might be valid actually
    'a[0]b'    # Missing separator
  )
  for path in "${invalid_paths[@]}"; do
    L_unittest_cmd ! L_json_path_normalize -v output "$path"
  done
}

_L_test_json_malformed() {
  # Test various malformed JSON inputs
  local malformed=(
    '{'
    '['
    '{"a":}'
    '{"a":1,}'
    '[1,2,]'
    '{"a":1 "b":2}'
    '{"a":}'
    'truex'
    'falsex'
    'nullx'
    '123abc'
    '"unterminated'
    '{"a": "\u}"'  # Invalid unicode
    '{"a":}'       # Missing value
    '[,1]'         # Leading comma in array
    '{"":}'        # Empty key with missing value
  )
  for json in "${malformed[@]}"; do
    L_unittest_cmd L_json_is_valid "$json"
  done
}

###############################################################################

if L_is_main; then
  if [[ "${1:-}" == eval ]]; then
    "$@"
  else
    L_unittest_main -p _L_test_json "$@"
  fi
fi
