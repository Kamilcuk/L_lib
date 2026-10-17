#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")"/../bin/L_lib.sh
L_log_configure -L


exit 0

















L_ini_parse() {
  local -n _L_out=$1
  local _L_rest=$2 _L_section="" _L_key="" _L_val="" _L_line _L_k _L_v _L_cont
  _out=()

  # First pass: collect raw lines into an array, tracking sections/keys
  local -a _lines=()
  while [[ "$_rest" =~ ^[^\n]*(?:\n|$) ]]; do
    _line=${BASH_REMATCH[0]%$'\n'}
    _rest=${_rest:${#BASH_REMATCH[0]}}
    _lines+=("$_line")
    [[ -z "$_rest" ]] && break
  done

  # Second pass: process lines, folding continuations
  local i
  for (( i=0; i<${#_lines[@]}; i++ )); do
    _line=${_lines[i]%$'\r'}

    # Blank or comment
    [[ "$_line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$_line" =~ ^[[:space:]]*[;#] ]] && continue

    # Continuation line: leading whitespace, and we have a current key
    if [[ "$_line" =~ ^[[:space:]] ]] && [[ -n "$_key" ]]; then
      _cont=${_line##+([ $'\t'])}   # strip leading whitespace
      _val+=" $_cont"                # RFC 822: single space separator
      _out["$_sect"$'\t'"$_key"]=$_val
      continue
    fi

    # Section header
    if [[ "$_line" =~ ^[[:space:]]*\[([^]]*)\] ]]; then
      _sect=${BASH_REMATCH[1]}
      _sect=${_sect##+([ $'\t'])}; _sect=${_sect%%+([ $'\t'])}
      _key=""
      continue
    fi

    # Key = value
    if [[ "$_line" =~ ^[[:space:]]*([^=:]+)[[:space:]]*[=:][[:space:]]*(.*)$ ]]; then
      _k=${BASH_REMATCH[1]}; _v=${BASH_REMATCH[2]}
      _k=${_k##+([ $'\t'])}; _k=${_k%%+([ $'\t'])}
      _v=${_v##+([ $'\t'])}; _v=${_v%%+([ $'\t'])}
      _key=$_k
      _val=$_v
      _out["$_sect"$'\t'"$_key"]=$_val
    fi
  done
}


L_ini_set() {
  local _L_v
  _L_ini_args
}

# @description Print INI parsing error.
_L_ini_err() {
  local tmp
  printf -v tmp "%q" "${_L_ini::64}"
  L_func_error "$1 pos=$(( _L_ini_len - ${#_L_ini} )) at: \`$tmp'" \
    "$(( ${#FUNCNAME[*]} - _L_ini_errdepth + 1 ))"
  return "$L_EX_DATAERR"
}

_L_ini_lstrip() {
  _L_ini=${_L_ini#"${_L_ini%%[!$' \t\r\n']*}"}
}

# Strip trailing whitespace from a string variable name passed in $1
_L_ini_rstrip_var() {
  local -n _L_ini_rv=$1
  _L_ini_rv=${_L_ini_rv%%+([ $'\t\r'])}
}

# Strip unquoted trailing comment starting with ';' or '#'
# Sets $L_RET to the stripped value.
_L_ini_strip_comment() {
  local _L_in=$1 _L_i _L_c _L_quote=''
  local _L_out=''
  for (( _L_i=0; _L_i<${#_L_in}; _L_i++ )); do
    _L_c=${_L_in:_L_i:1}
    if [[ -n "$_L_quote" ]]; then
      _L_out+=$_L_c
      if [[ "$_L_c" == "$_L_quote" ]]; then
        # handle escaped quote (backslash before)
        if (( _L_i == 0 )) || [[ "${_L_in:_L_i-1:1}" != '\' ]]; then
          _L_quote=''
        fi
      fi
      continue
    fi
    case "$_L_c" in
      '"'|"'") _L_quote=$_L_c; _L_out+=$_L_c ;;
      ';'|'#')
        # Comment must be preceded by whitespace or start-of-line to be a comment
        if (( _L_i == 0 )) || [[ "${_L_in:_L_i-1:1}" == [' '$'\t'] ]]; then
          break
        fi
        _L_out+=$_L_c
        ;;
      *) _L_out+=$_L_c ;;
    esac
  done
  L_RET=$_L_out
}

_L_ini_read_section() {
  # _L_ini starts with '['
  _L_ini=${_L_ini:1}
  local _L_name
  if [[ "$_L_ini" =~ ^([^]$'\r\n']+)\] ]]; then
    _L_name=${BASH_REMATCH[1]}
  else
    _L_ini_err "Unterminated section header"; return
  fi
  _L_ini=${_L_ini:${#BASH_REMATCH[0]}}
  # Trim trailing whitespace in section name
  _L_name=${_L_name%%+([ $'\t'])}
  _L_name=${_L_name##+([ $'\t'])}
  if [[ -z "$_L_name" ]]; then
    _L_ini_err "Empty section name"; return
  fi
  "$_L_ini_cb" section "$_L_name" || return
  if (( _L_ini_break )); then return; fi
  _L_ini_context=$'\t'"$_L_name"
}

_L_ini_read_key_value() {
  local _L_raw _L_key _L_val _L_sep

  # Read up to newline
  if [[ "$_L_ini" == *$'\n'* ]]; then
    _L_raw=${_L_ini%%$'\n'*}
    _L_ini=${_L_ini#*$'\n'}
  else
    _L_raw=$_L_ini
    _L_ini=''
  fi

  # Strip trailing CR (CRLF files)
  _L_raw=${_L_raw%$'\r'}

  # Find the separator ('=' or ':')
  if [[ "$_L_raw" =~ ^([^=:]+)([=:])(.*)$ ]]; then
    _L_key=${BASH_REMATCH[1]}
    _L_sep=${BASH_REMATCH[2]}
    _L_val=${BASH_REMATCH[3]}
  else
    # Line with no separator: treat as key with empty value, or a bare flag.
    # Standard INI allows bare keys; we treat them as boolean true.
    _L_key=$_L_raw
    _L_sep=''
    _L_val=''
  fi

  # Trim key whitespace
  _L_key=${_L_key##+([ $'\t'])}
  _L_key=${_L_key%%+([ $'\t'])}
  if [[ -z "$_L_key" ]]; then
    _L_ini_err "Empty key"; return
  fi

  # Strip comments from value, then trim
  if [[ -n "$_L_sep" ]]; then
    _L_ini_strip_comment "$_L_val"
    _L_val=$L_RET
  fi
  _L_val=${_L_val##+([ $'\t'])}
  _L_val=${_L_val%%+([ $'\t'])}

  "$_L_ini_cb" key "$_L_key" || return
  if (( _L_ini_break )); then return; fi

  if [[ -n "$_L_sep" ]]; then
    "$_L_ini_cb" token "$_L_sep" || return
    if (( _L_ini_break )); then return; fi
  fi

  # Determine value type and normalize
  local _L_type _L_out
  if [[ -z "$_L_sep" && -z "$_L_val" ]]; then
    # Bare key -> boolean true
    _L_type=bool
    _L_out=true
  elif [[ "$_L_val" == '"'*'"' && ${#_L_val} -ge 2 ]]; then
    _L_type=string
    _L_out=$_L_val
  elif [[ "$_L_val" == "'"*"'" && ${#_L_val} -ge 2 ]]; then
    _L_type=string
    # Single quotes: shell-style literal, re-emit as double-quoted JSON string
    local _L_inner=${_L_val:1:${#_L_val}-2}
    _L_out='"'${_L_inner//\"/\\\"}'"'
  elif [[ "$_L_val" =~ ^(true|false)$ ]]; then
    _L_type=bool
    _L_out=$_L_val
  elif [[ "$_L_val" =~ ^(null|none|nil)$ ]]; then
    _L_type=null
    _L_out=null
  elif [[ "$_L_val" =~ $_L_float_re$ ]]; then
    _L_type=number
    _L_out=$_L_val
  elif [[ "$_L_val" == '' ]]; then
    _L_type=string
    _L_out='""'
  else
    # Unquoted string: emit as JSON string
    _L_type=string
    _L_out='"'${_L_val//\"/\\\"}'"'
  fi

  local _L_full=$_L_ini_context$'\t'${_L_key@Q}
  # Use a JSON-style key representation: tab-delimited, key either quoted
  # or numeric, matching L_obj_set / L_json conventions.
  _L_full=$_L_ini_context$'\t'"\"$_L_key\""
  _L_ini_context_save=$_L_ini_context
  _L_ini_context=$_L_full
  "$_L_ini_cb" value "$_L_out" "$_L_type" || return
  _L_ini_context=$_L_ini_context_save
}

_L_ini_read() {
  local _L_ini_len=${#_L_ini} _L_ini_context="" _L_ini_cb=$1 _L_ini_break=0 \
        _L_ini_errdepth=${#FUNCNAME[*]} _L_ini_context_save=""
  while [[ -n "$_L_ini" ]]; do
    # Strip leading whitespace and blank lines
    case "$_L_ini" in
      [$' \t\r\n']*) _L_ini_lstrip; continue ;;
      ';'*|'#'*)
        # Comment line - skip to end of line
        if [[ "$_L_ini" == *$'\n'* ]]; then
          _L_ini=${_L_ini#*$'\n'}
        else
          _L_ini=''
        fi
        continue
        ;;
      '['*)
        _L_ini_read_section || return
        ;;
      *)
        _L_ini_read_key_value || return
        ;;
    esac
    if (( _L_ini_break )); then break; fi
  done
}

###############################################################################
# Public API
###############################################################################

# @description Validate an INI string.
# @arg $1 INI text
L_ini_is_valid() {
  _L_ini_cb() { :; }
  local _L_ini="$1"
  _L_ini_read _L_ini_cb
}

_L_ini_test() {
  _L_ini_cb() { local IFS=" "; printf "!! %q %s\n" "$_L_ini_context" "$*"; }
  local _L_ini=$1
  _L_ini_read _L_ini_cb
}
_L_ini_test_quiet() {
  local _L_ini=$1
  _L_ini_read :
}

# @description Get a value from an INI string by path.
#              Paths use the same syntax as L_json paths: a.b[0] etc.
# @option -v <var> Store the result in variable.
# @arg $1 INI text
# @arg $2 path
L_ini_get() { L_handle_v_scalar "$@"; }
L_ini_get_vL_RET() {
  local _L_ini="$1" _L_orig_ini="$1" _L_initlen="${#1}" \
        _L_key _L_start="" _L_end="" _L_value_captured=0
  L_json_path_normalize -v _L_key "$2" || return
  _L_ini_cb() {
    case "$1 $_L_ini_context" in
      "value $_L_key") L_RET="$2" _L_value_captured=1 _L_ini_break=1 ;;
    esac
  }
  _L_ini_read _L_ini_cb || return
  if (( ! _L_value_captured )); then
    return 1
  fi
}

# @description Remove a key from an INI string.
# @option -v <var> Store the result in variable.
# @arg $1 INI text
# @arg $2 path
L_ini_rm() { L_handle_v_scalar "$@"; }
L_ini_rm_vL_RET() {
  # Removing from INI text is non-trivial because we need to preserve
  # formatting. We rebuild the file from the parsed object instead.
  local -A _L_obj
  L_ini_to_obj _L_obj "$1" || return
  L_obj_rm _L_obj "$2" || return
  L_obj_to_ini_vL_RET _L_obj
}

# @description Pretty-print an INI string (normalized formatting).
# @option -v <var> Store the output in variable.
# @arg $1 INI text
# @arg [$2] indent (unused, kept for API symmetry)
L_ini_pretty() { L_handle_v_scalar "$@"; }
L_ini_pretty_vL_RET() {
  local -A _L_obj
  L_ini_to_obj _L_obj "$1" || return
  L_obj_to_ini_vL_RET _L_obj
}

# @description Compact form (same as pretty for INI, since INI is line-based).
L_ini_compact() { L_handle_v_scalar "$@"; }
L_ini_compact_vL_RET() { L_ini_pretty_vL_RET "$@"; }

###############################################################################
# Object conversion
###############################################################################

_L_ini_to_obj_cb() {
  case "$1" in
    value) _L_a["$_L_ini_context"]="$2" ;;
    section) _L_a[$'\t__sections__\t'"$2"]=1 ;;
  esac
}

# @description Parse INI text into an associative array following the
#              L_json_to_obj key convention: tab-delimited path components,
#              keys quoted with double quotes, indices bare.
# @arg $1 name of associative array
# @arg $2 INI text
L_ini_to_obj() {
  local -n _L_a=$1
  local _L_ini=$2
  _L_a=()
  _L_ini_read _L_ini_to_obj_cb
}

# @description Render an object (in L_json_to_obj convention) as INI text.
# @option -v <var> Store the output in variable.
# @arg $1 object name
L_obj_to_ini() { L_handle_v_scalar "$@"; }
L_obj_to_ini_vL_RET() {
  local -n _L_obj=$1
  local _L_key _L_path _L_val _L_section _L_sub
  local -A _L_sections=()
  local -A _L_roots=()

  L_RET=""
  # First pass: discover sections and root-level keys
  for _L_key in "${!_L_obj[@]}"; do
    # Skip marker keys
    [[ "$_L_key" == $'\t__sections__'* ]] && continue
    IFS=$'\t' read -ra _L_path <<<"$_L_key"
    # Drop leading empty component
    if [[ "${_L_path[0]}" == "" ]]; then
      _L_path=("${_L_path[@]:1}")
    fi
    if (( ${#_L_path[@]} == 0 )); then
      continue
    fi
    # First component is either a section name (quoted) or a root key (quoted)
    local _L_first=${_L_path[0]}
    # Detect section: any key with depth > 1 whose first component is quoted
    if (( ${#_L_path[@]} > 1 )); then
      # section = first component, stripped of quotes
      _L_section=${_L_first#\"}; _L_section=${_L_section%\"}
      _L_sections["$_L_section"]=1
    else
      _L_roots["$_L_first"]="${_L_obj["$_L_key"]}"
    fi
  done

  # Root-level keys first
  local _L_k
  local _L_sorted_roots=()
  for _L_k in "${!_L_roots[@]}"; do
    _L_sorted_roots+=("$_L_k")
  done
  if (( ${#_L_sorted_roots[@]} > 0 )); then
    IFS=$'\n' _L_sorted_roots=($(sort <<<"${_L_sorted_roots[*]}")); unset IFS
    for _L_k in "${_L_sorted_roots[@]}"; do
      local _L_name=${_L_k#\"}; _L_name=${_L_name%\"}
      _L_val=${_L_roots["$_L_k"]}
      _L_ini_emit_value "$_L_name" "$_L_val"
    done
  fi

  # Sections in sorted order
  local _L_sorted_sections=()
  for _L_k in "${!_L_sections[@]}"; do
    _L_sorted_sections+=("$_L_k")
  done
  if (( ${#_L_sorted_sections[@]} > 0 )); then
    IFS=$'\n' _L_sorted_sections=($(sort <<<"${_L_sorted_sections[*]}")); unset IFS
    for _L_section in "${_L_sorted_sections[@]}"; do
      L_RET+="[$_L_section]"$'\n'
      # Collect keys under this section at depth 2 only
      local _L_prefix=$'\t'"\"$_L_section\""
      local _L_subkeys=()
      for _L_key in "${!_L_obj[@]}"; do
        [[ "$_L_key" == $'\t__sections__'* ]] && continue
        [[ "$_L_key" == "$_L_prefix"$'\t'* ]] || continue
        # Only depth-2 keys (section.key), skip nested
        local _L_rest=${_L_key#"$_L_prefix"$'\t'}
        [[ "$_L_rest" == *$'\t'* ]] && continue
        _L_subkeys+=("$_L_key")
      done
      if (( ${#_L_subkeys[@]} > 0 )); then
        IFS=$'\n' _L_subkeys=($(sort <<<"${_L_subkeys[*]}")); unset IFS
        for _L_key in "${_L_subkeys[@]}"; do
          local _L_rest=${_L_key#"$_L_prefix"$'\t'}
          local _L_name=${_L_rest#\"}; _L_name=${_L_name%\"}
          _L_ini_emit_value "$_L_name" "${_L_obj["$_L_key"]}"
        done
      fi
      L_RET+=$'\n'
    done
  fi
  # Trim trailing blank line
  L_RET=${L_RET%$'\n'}
}

# Emit "key = value" with INI-appropriate quoting.
# Appends to L_RET.
_L_ini_emit_value() {
  local _L_name=$1 _L_val=$2
  # Unquote JSON string values
  local _L_out
  if [[ "$_L_val" == '"'*'"' && ${#_L_val} -ge 2 ]]; then
    local _L_inner=${_L_val:1:${#_L_val}-2}
    # Unescape basic JSON escapes for INI output
    _L_inner=${_L_inner//\\\"/\"}
    _L_inner=${_L_inner//\\\\/\\}
    _L_inner=${_L_inner//\\n/$'\n'}
    _L_inner=${_L_inner//\\t/$'\t'}
    _L_inner=${_L_inner//\\r/$'\r'}
    # Quote if value contains leading/trailing whitespace or comment chars
    if [[ "$_L_inner" == *[' '#$'\t'';']* || "$_L_inner" == '' ]]; then
      _L_out='"'"${_L_inner//\"/\\\"}"'"'
    else
      _L_out=$_L_inner
    fi
  elif [[ "$_L_val" == "true" || "$_L_val" == "false" \
       || "$_L_val" == "null" || "$_L_val" =~ $_L_float_re$ ]]; then
    _L_out=$_L_val
  else
    _L_out=$_L_val
  fi
  L_RET+="$_L_name = $_L_out"$'\n'
}

###############################################################################
# Convenience: read a file
###############################################################################

# @description Parse an INI file into an object.
# @arg $1 object name
# @arg $2 path to file
L_ini_file_to_obj() {
  local -n _L_a=$1
  local _L_content
  _L_content=$(<"$2") || {
    L_func_error "Cannot read file: $2"; return "$L_EX_NOINPUT"
  }
  L_ini_to_obj _L_a "$_L_content"
}

# @description Get a value from an INI file.
# @option -v <var> Store the result in variable.
# @arg $1 path to file
# @arg $2 key path
L_ini_file_get() { L_handle_v_scalar "$@"; }
L_ini_file_get_vL_RET() {
  local -A _L_obj
  L_ini_file_to_obj _L_obj "$1" || return
  L_obj_get_vL_RET _L_obj "$2"
}

###############################################################################
# Tests
###############################################################################

_L_test_ini_basic() {
  local ini=$'[section]\nkey = value\nnum = 42\nflag = true\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"section"\t"key"'] '"value"'
  L_unittest_vareq obj[$'\t"section"\t"num"'] '42'
  L_unittest_vareq obj[$'\t"section"\t"flag"'] 'true'
  L_unittest_vareq obj[$'\t__sections__\tsection'] '1'
}

_L_test_ini_root_keys() {
  local ini=$'root = 1\nother = "two"\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"root"'] '1'
  L_unittest_vareq obj[$'\t"other"'] '"two"'
}

_L_test_ini_comments() {
  local ini=$'; full line comment\n# another\n[sec] ; trailing\nkey = value ; inline\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"sec"\t"key"'] '"value"'
}

_L_test_ini_quoted_values() {
  local ini=$'[s]\na = "hello world"\nb = "with ; semicolon"\nc = \'single ; too\'\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"s"\t"a"'] '"hello world"'
  L_unittest_vareq obj[$'\t"s"\t"b"'] '"with ; semicolon"'
  L_unittest_vareq obj[$'\t"s"\t"c"'] '"single ; too"'
}

_L_test_ini_colon_separator() {
  local ini=$'[s]\na : 1\nb : two\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"s"\t"a"'] '1'
  L_unittest_vareq obj[$'\t"s"\t"b"'] '"two"'
}

_L_test_ini_bare_key() {
  local ini=$'[s]\nflag\nother = 1\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"s"\t"flag"'] 'true'
  L_unittest_vareq obj[$'\t"s"\t"other"'] '1'
}

_L_test_ini_get() {
  local ini=$'[db]\nhost = localhost\nport = 5432\n'
  L_unittest_cmd -o 'localhost' L_ini_get "$ini" 'db.host'
  L_unittest_cmd -o '5432' L_ini_get "$ini" 'db.port'
  L_unittest_cmd ! L_ini_get "$ini" 'db.missing'
}

_L_test_ini_is_valid() {
  local good=(
    $'[a]\nk=v\n'
    $'k=v\n'
    $'; comment\n[a]\n\nk = 1\n'
    $'[a]\nempty =\n'
    $'[a]\nb\n'
  )
  local bad=(
    $'[unterminated\nk=v\n'
    $'[]\nk=v\n'
  )
  local s
  for s in "${good[@]}"; do L_unittest_cmd L_ini_is_valid "$s"; done
  for s in "${bad[@]}";  do L_unittest_cmd ! L_ini_is_valid "$s"; done
}

_L_test_ini_roundtrip() {
  local ini=$'root = 1\n\n[server]\nhost = localhost\nport = 8080\n\n[client]\ntimeout = 30\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  local back
  L_obj_to_ini -v back obj
  declare -A obj2
  L_ini_to_obj obj2 "$back"
  # Compare a few keys
  L_unittest_vareq obj2[$'\t"server"\t"host"'] '"localhost"'
  L_unittest_vareq obj2[$'\t"server"\t"port"'] '8080'
  L_unittest_vareq obj2[$'\t"client"\t"timeout"'] '30'
  L_unittest_vareq obj2[$'\t"root"'] '1'
}

_L_test_ini_types() {
  local ini=$'[t]\ns = "quoted"\nn = 3.14\nb = false\nnul = null\nbare\nunq = raw text\n'
  declare -A obj
  L_ini_to_obj obj "$ini"
  L_unittest_vareq obj[$'\t"t"\t"s"'] '"quoted"'
  L_unittest_vareq obj[$'\t"t"\t"n"'] '3.14'
  L_unittest_vareq obj[$'\t"t"\t"b"'] 'false'
  L_unittest_vareq obj[$'\t"t"\t"nul"'] 'null'
  L_unittest_vareq obj[$'\t"t"\t"bare"'] 'true'
  L_unittest_vareq obj[$'\t"t"\t"unq"'] '"raw text"'
}

###############################################################################

if L_is_main; then
  if [[ "${1:-}" == eval ]]; then
    "$@"
  else
    L_unittest_main -p _L_test_ini "$@"
  fi
fi
