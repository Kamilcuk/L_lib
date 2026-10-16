
_L_test_json_quote() {
	if ! L_hash jq; then
		L_unittest_skip "jq not found"
		return
	fi
	t() {
		local tmp input="$1"
		L_json_quote -v tmp "$1"
		MSYS_NO_PATHCONV=1 L_unittest_cmd -o "$tmp" jq -n --arg input "$input" '$input'
	}
	t $'1 hello\n\t\bworld'
	t $'\1f'
	t $'\7f'
	t $'2 \x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f'
	t $'3 \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f'
	t $'4 \x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f'
	t $'5 \x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f'
	t "! ${L_ALLCHARS::127}"
	local i a LC_ALL=C
	for ((i=1;i<127;++i)); do
		printf -v a "%02x" "$i"
		printf -v a "%b" "\\x$a"
		t "${a}|"
	done
	unset -f t
}

_L_test_json() {
	true && return 0  # disabled
	{
		L_log "test L_json_get"
		local json='{"a":["b",{"c":[1,2],"i":2,"j":true,"k":false,"m":null}], "d":{ "e":"f","g":"h" }}'
		L_unittest_cmd eval 'jq -c <<<"$json"'
		L_unittest_cmd -o $'1\n2' L_json_get "$json" a 1 c
		L_unittest_cmd -o $'e\nf\ng\nh' L_json_get "$json" d
		L_unittest_cmd -o 2 L_json_get "$json" a 1 i
		L_unittest_cmd -o true L_json_get "$json" a 1 j
		L_unittest_cmd -o false L_json_get "$json" a 1 k
		L_unittest_cmd -o null L_json_get "$json" a 1 m
	}
	{
		local json_is json_shouldbe
		L_log "test L_json_edit"

		check() {
			local json1="$1" expr="$2" input="$3" json2
			#
			L_json_pretty -v json1 "$json1"
			json2=$(jq "$expr" <<<"$input")
			L_unittest_eq "$json1" "$json2"
			#
			L_json_compact -v json1 "$json1"
			json2=$(jq -c "$expr" <<<"$input")
			L_unittest_eq "$json1" "$json2"
		}

		{
			local json_no_d
			L_json_rm -v json_no_d "$json" d
			check "$json_no_d" 'del(.d)' "$json"
		}
	}
}


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

_L_json_fetch_64KB_vL_RET() {
  L_cache -O L_RET -f /tmp/json_64KB.json -- curl -sSL https://microsoftedge.github.io/Demos/json-dummy-data/64KB.json 2>/dev/null || true
}

_L_test_json_64KB() {
  local L_RET
  _L_json_fetch_64KB_vL_RET
  if [[ -z "$L_RET" ]]; then
    L_unittest_skip "64KB JSON fetch unavailable"
    return 0
  fi
  _L_json_test_quiet "$L_RET" || exit
}

# Test using first 20 elements (~5KB) from cached 64KB JSON
_L_test_json_5KB() {
  local L_RET
  _L_json_fetch_64KB_vL_RET
  if [[ -z "$L_RET" ]]; then
    L_unittest_skip "64KB JSON fetch unavailable"
    return 0
  fi
  L_RET=$(jq '.[:20]' <<<"$L_RET" 2>/dev/null || head -n 20 <<<"$L_RET")
  _L_json_test_parse "$L_RET" || exit
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
    L_unittest_cmd -c _L_obj_print_table obj
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


