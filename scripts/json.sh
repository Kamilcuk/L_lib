

# @description Print JSON parsing error.
_L_json_err() {
  L_func_error "$1" "$(( ${#FUNCNAME[@]} - j_stackpos ))"
  return 2
}

# @description Parse a string in a JSON.
_L_json_get_string() {
  _L_json_lstrip "$j_json"
  if [[ "${j_json::1}" != '"' ]]; then
    _L_json_err "internal error: missing \" at $j_json" || return 2
  fi
  j_json=${j_json:1}
  if ! [[ "$j_json" =~ ((^|[^\"\\]|\\\")(\\\\)*)\"(.*)$ ]]; then
    #                  12               3         4
    _L_json_err "not closed \": $j_json" || return 2
  fi
	printf -v "$1" "%s" "${j_json::${#j_json}-${#BASH_REMATCH[0]}+${#BASH_REMATCH[1]}}"
	j_json=${BASH_REMATCH[4]}
}

# @description Remove whitespaces from the left.
_L_json_lstrip() {
  local L_v
  L_lstrip_v "$1" $' \t\r\n'
  j_json=$L_v
}

# @description JSON parser
# @option -v <var> Assign to this variable.
# @env j_fullljson
# @env j_json
# @env _L_cb
_L_json_do() { L_handle_v_array "$@"; }
_L_json_do_v() {
  _L_json_lstrip "$j_json"
  local startposition="$((${#j_fulljson}-${#j_json}))" type="" value tmp key subvalue _
  L_v=()
  case "${j_json::1}" in
  "{")
    "$_L_cb" "{"
    _L_json_lstrip "${j_json:1}"
    j_json=,$j_json
    while [[ "${j_json::1}" == , ]]; do
      if [[ -n "$type" ]]; then
        "$_L_cb" ","
      fi
      type="object"
      j_json=${j_json:1}
      local valuebegin="$((${#j_fulljson}-${#j_json}))"
      _L_json_get_string key
      "$_L_cb" ":" "\"$key\""
      printf -v key "%b" "$key"
      L_v+=("$key")
      _L_json_lstrip "$j_json"
      if [[ "${j_json::1}" != : ]]; then
        _L_json_err "not found ':' in $j_json" || return 2
      fi
      _L_json_lstrip "${j_json:1}"
      if (($#)) && [[ "$key" == "$1" ]]; then
        _L_json_do_v "${@:2}" || return "$?"
        if (($# == 1)); then
          L_v[5]=$valuebegin
        fi
        return
      else
        _L_json_do -v value "${@:2}" || return "$?"
        L_v+=("${value[0]}" "${value[1]}")
      fi
      _L_json_lstrip "$j_json"
    done
    if [[ "${j_json::1}" != "}" ]]; then
      _L_json_err "Closing } not found: $j_json" || return 2
    fi
    "$_L_cb" "}"
    j_json=${j_json:1}
    if (($#)); then
      _L_json_err "key $1 not found in $j_json" || return 1
    fi
    ;;
  "[")
    "$_L_cb" "["
    if (($#)) && ! [[ "$1" =~ ^[0-9]+$ ]]; then
      _L_json_err "array index must be a number: $1" || return 2
    fi
    local idx=0
    _L_json_lstrip "${j_json:1}"
    j_json=,$j_json
    while [[ "${j_json::1}" == , ]]; do
      if [[ -n "$type" ]]; then
        "$_L_cb" ,
      fi
      type="array"
      _L_json_lstrip "${j_json:1}"
      if (($#)) && ((idx++ == $1)); then
        _L_json_do_v "${@:2}" || return 2
        return
      else
        _L_json_do -v value || return 2
        L_v+=("${value[0]}" "${value[1]}")
      fi
      _L_json_lstrip "$j_json"
    done
    if [[ "${j_json::1}" != "]" ]]; then
      _L_json_err "Closing ] not found: $j_json" || return 2
    fi
    "$_L_cb" "]"
    j_json=${j_json:1}
    if (($#)); then
      _L_json_err "index $1 not found" || return 1
    fi
    ;;
  '"')
    type="string"
    _L_json_get_string value || return 2
    L_v=("$value")
    "$_L_cb" "string" "\"$value\""
    printf -v subvalue "%b" "$value"
    ;;
  [-0-9])
    type="number"
    if ! [[ "$j_json" =~ ^(-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][-+]?[0-9]*)?)(.*)$ ]]; then
      #                   1  2              3           4                  5
      _L_json_err "invalid number: $j_json" || return 2
    fi
    L_v=("${BASH_REMATCH[1]}")
    subvalue=$L_v
    "$_L_cb" "$type" "$subvalue"
    j_json=${BASH_REMATCH[5]}
    ;;
  [a-z])
    type="literal"
    # true false null
    L_v=("${j_json%%[\]\{\,\ $'\r\t\n'\:\}\[]*}")
    subvalue=$L_v
    "$_L_cb" "$type" "$subvalue"
    j_json=${j_json:${#L_v[0]}}
    ;;
  '') ;;
  *) _L_json_err "invalid j_json: $(printf %q "$j_json")" || return 2
  esac
  local length="$((${#j_fulljson}-${#j_json}-startposition))"
  L_v=(
    "$type" # 0
    "${subvalue-${j_fulljson:startposition:length}}" # 1
    "${j_fulljson:startposition:length}" # 2
    "$startposition" # 3
    "$length" # 4
    "$startposition" # 5
    "" # 6
    "" # 7
    "" # 8
    "" # 9
    "${L_v[@]}" # 10...
  )
}

# @description Gets value from a JSON.
# This function assigns a varaible that:
#    - [0] - the type object, array, string, number or literal.
#    - [1] - the parsed value of the object. For string it is the unescaped string.
#    - [2] - The part of the JSON representing this value.
#    - [3] - The character index in the JSON where this value starts.
#    - [4] - The length in characters of the JSON value.
#    - [5] - The character index in the JSON where this value starts including the key in thecase of object.
#    - [6..9] - Reserved for later use.
# For an array:
#    - [10 + 2 * i + 0] - The type of the value in the array at position i
#    - [10 + 2 * i + 1] - The value in the array at position i
# For an object:
#    - [10 + 2 * i + 0] - The key.
#    - [10 + 2 * i + 1] - The type of the value of key.
#    - [10 + 2 * i + 2] - The value of key in the object.
# @option -v <var> Assign to this variable.
# @option -h Print this help and exit.
# @arg $1 JSON
# @arg $@ Keys or indexes to index the element by.
# @env _L_cb
L_json_extract() { L_handle_v_array "$@"; }
L_json_extract_v() {
  local j_json="$1" j_fulljson="$1" ws=$'[ \r\t\n]*' j_stackpos="${#FUNCNAME[@]}" _L_cb="${_L_cb:-:}"
  _L_json_do_v "${@:2}"
}

# @description Get a value from JSON.
# If the value is true, false, none, a string or a number, it is assigned to the variable.
# If the value is an array, each value of the array is assigned to separate array elements.
# If the value is an object, the array is assigned key and values in order.
# If you need the type of the object, use L_json_extract.
# @example
#    L_json_get -v a '{"a":"b","c":"d"}'   # -> a=(a b c d)
#    L_json_get -v a '[1, 2, 3, 4]'        # -> a=(1 2 3 4)
#    L_json_get -v a '{"key":true}' key    # -> a="true"
# @see L_json_extract
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
# @arg $@ Keys or indexes to index the element by.
L_json_get() { L_handle_v_array "$@"; }
L_json_get_v() {
  local tmp=()
  L_json_extract_v "$@" || return "$?"
  case "${L_v[0]}" in
    object)
      for ((i=10;i<${#L_v[@]};i+=3)); do
        tmp+=("${L_v[i]}" "${L_v[i+2]}")
      done
      ;;
    array)
      for ((i=10;i<${#L_v[@]};i+=2)); do
        tmp+=("${L_v[i+1]}")
      done
      ;;
    *) tmp=("${L_v[1]}") ;;
  esac
  L_v=("${tmp[@]}")
}

# @description Edit one JSON element.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
# @arg $@ Keys or indexes to index the element by.
# @arg $@-1 The new value to assign. The new value is taken _unescaped_. Escape it yourself.
L_json_edit() { L_handle_v_scalar "$@"; }
L_json_edit_v() {
  L_json_extract_v "${@:1:$#-1}" || return "$?"
  # shellcheck disable=SC2124
  L_v="${1::${#1}-${L_v[3]}-1}${@:$#}${1:${L_v[3]}+${L_v[4]}}"
}

# @description Remove an JSON value.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
# @arg $@ Keys and indexes of the value to remove.
# @example
#    L_json_rm -v var '{"a":"b","c":[1,2,3]}' c
#    echo "$var"   # outputs {"a":"c"}
L_json_rm() { L_handle_v_scalar "$@"; }
L_json_rm_v() {
  L_json_extract_v "$@" || return "$?"
  local pre=${1::${L_v[5]}} post=${1:${L_v[3]}+${L_v[4]}} ws=$'[ \r\t\n]*'
  if [[ "$pre" =~ ^(.*),$ws$ ]]; then
    pre=${BASH_REMATCH[1]}
  elif [[ "$post" =~ ^$ws,(.*)$ ]]; then
    post=${BASH_REMATCH[1]}
  fi
  L_v=$pre$post
}

_L_json_pretty() {
  local indent last="${_L_out:${#_L_out}-1}"
  printf -v indent "%*s" "$((_L_indent*_L_lvl))" ""
  case "$1" in
    ["[{"])
      case "$last" in
      ["{,"]) _L_out+=$'\n'$indent ;;
      ":") _L_out+=' ' ;;
      esac
      _L_lvl=$((_L_lvl+1))
      _L_out+=$1$'\n'
      ;;
    ["]}"])
      _L_lvl=$((_L_lvl-1))
      printf -v indent "%*s" "$((_L_indent*_L_lvl))" ""
      _L_out+=$'\n'$indent$1
      ;;
    ":")
      if [[ "$last" == ["{,"] ]]; then _L_out+=$'\n'; fi
      _L_out+=$indent$2":"
      ;;
    ",") _L_out+="," ;;
    string|number|literal)
      case "$last" in
      ["{[,"]) _L_out+=$'\n'$indent ;;
      ":") _L_out+=" " ;;
      *) _L_out+=$indent ;;
      esac
      _L_out+=$2
      ;;
    *) _L_json_err "could not print. args: $*"; return 2 ;;
  esac
}

# @description Print nicely looking version of the json.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
# @arg $2 Number if spaces.
L_json_pretty() { L_handle_v_scalar "$@"; }
L_json_pretty_v() {
  local _L_cb=_L_json_pretty _L_out="" _L_lvl=0 _L_indent=${2:-2}
  L_json_extract_v "$@"
  L_v=$_L_out
}

_L_json_compact() {
  case "$1" in
    ["[{:,}]"]) _L_out+=${2:-}$1 ;;
    string|number|literal) _L_out+=$2 ;;
    *) _L_json_err "could not print. args: $*"; return 2 ;;
  esac
}

# @description Print compact version of the json.
# @option -v <var> Store the output in variable instead of printing it.
# @arg $1 JSON
L_json_compact() { L_handle_v_scalar "$@"; }
L_json_compact_v() {
  local _L_cb=_L_json_compact _L_out="" _L_lvl=0
  L_json_extract_v "$@"
  L_v=$_L_out
}

