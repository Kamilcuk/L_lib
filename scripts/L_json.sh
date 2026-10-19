

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
	L_json_path_normalize_vL_RET "$@"
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

