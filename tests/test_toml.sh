###############################################################################
# @section toml

_L_test_toml() {
  if ((!L_HAS_BASH4_0)); then
    L_unittest_skip "needs bash4.0 for associative array"
    exit 123
  fi
	local out=""
	add_to_out() { out+="$*"$'\n'; }
	L_toml_read add_to_out <<<$'a = 1\n[t]\nb = "x"\n[[arr]]\nc = [1, 2]\n'
	L_unittest_vareq out "\
VALUE INTEGER 1 a
TABLE MAP t
VALUE STRING x t b
TABLE ARRAY arr
TABLE MAP arr 0
START ARRAY arr 0 c
VALUE INTEGER 1 arr 0 c 0
VALUE INTEGER 2 arr 0 c 1
END ARRAY arr 0 c
"
}

toml_to_json() {
  python -c 'import tomllib,sys,json;print(json.dumps(tomllib.load(sys.stdin.buffer),sort_keys=True,separators=(",", ":")))'
}

_L_test_toml_roundtrip_1() {
  obj_skip_test
	local toml='a = 1
b = "hello"
[t]
c = 2.5
d = true
e = 1979-05-27T07:32:00Z
f = 1979-05-27
g = 07:32:00
[f.g]
h = "i"
[[arr]]
j = [1, 2, 3]
k = "l"
[[arr]]
m = "n"
'
	declare obj
	L_toml_to_obj obj <<<"$toml"
	L_obj_to_toml -v out obj
	_L_obj_print_table obj
	# Check that datetime/time/date types are stored correctly in obj
	L_obj_get_value_vL_RET obj t e
	L_unittest_eq "$L_RET" "1979-05-27T07:32:00Z"  # datetime
	L_obj_get_value_vL_RET obj t f
	L_unittest_eq "$L_RET" "1979-05-27"          # date
	L_obj_get_value_vL_RET obj t g
	L_unittest_eq "$L_RET" "07:32:00"            # time
	declare obj2
	L_toml_to_obj obj2 <<<"$out"
	L_obj_to_toml -v out2 obj2
	sdiff - <<<"$out" <(echo "$out2") || :
	L_unittest_eq "$out" "$out2"
}


TOMLS=(
	# scalars
	$'a = 1'
	$'s = "hello"\nb = true\nf = 1.5\ni = -42\n'
	# tables
	$'[t]\nx = 1\n[t.u]\ny = 2\n'
	$'[a.b.c.d]\nx = 1\n'
	$'top = 1\n[a]\nx = 1\n[b]\ny = 2\n[a.c]\nz = 3\n'
	# arrays of tables
	$'[[arr]]\nname = "a"\n[[arr]]\nname = "b"\n'
	$'[[a]]\nx = 1\n[a.sub]\ny = 2\n[[a.items]]\nz = 3\n[[a.items]]\nz = 4\n[[a]]\nx = 5\n'
	$'[[a]]\nl = [1, 2]\n[[a]]\nl = []\n'
	# inline arrays and tables
	$'list = [1, 2, 3]\nmixed = [1, "a", true, 1.5]\nnested = [[1, 2], [3, 4]]\n'
	$'all_maps = [{ a = 1 }, { b = 2 }]\nmixed = [1, { a = 1 }]\n'
	$'p = { x = 1, y = { z = [1, 2, { w = 3 }] } }\n'
	# empty containers
	$'empty_arr = []\nempty_tbl = {}\n[t]\n'
	# keys
	$'"quoted key" = 1\n"a.b" = 2\n[ "x y" ]\n"k" = 3\n'
	$'a.b.c = 1\na.b.d = 2\n'
	$'1234 = "n"\ntrue = false\n'
	# strings
	$'s1 = "tab\\there \\"quoted\\" back\\\\slash"\ns2 = \'literal \\n no escape\'\ns3 = "unicode \\u00e9 \\U0001F600"\n'
	$'ml = """\nline1\nline2 \\\n   continued"""\nlit = \'\'\'\nraw \\n text\n\'\'\'\n'
	# numbers
	$'dec = 1_000\nhex = 0xDEADBEEF\noct = 0o755\nbin = 0b1010\nexp = 1e10\nfl = -3.14e-2\ninf1 = inf\nnan1 = nan\npos = +7\n'
	# dates and times
	$'odt = 1979-05-27T07:32:00Z\nldt = 1979-05-27T07:32:00\nld = 1979-05-27\nlt = 07:32:00\n'
	# layout
	$'# comment\na = 1 # trailing\n\n\n[t] # c\nb = 2\n'
	$'a = 1\r\n[t]\r\nb = 2\r\n'
	''
	$'root = 1\n[[a.b]]\nc=1\n[[a.b]]\nd=1\n[c]\nd=[1,[2,3,4]]\nf=[[1,2,3],[4,5,6]]\n[[q.d.f]]\na=1\n[[q.d.f]]\ng=[1,2,3]'
)

_L_test_toml_trips() {
  obj_skip_test
  local toml a b out
  for toml in "${TOMLS[@]}"; do
    a=() b=()
		L_toml_to_obj a <<<"$toml" || {
      printf -v tomlquoted "%q" "$toml"
      L_unittest_fail "could not read toml:$L_NL$toml----------$tomlquoted"
    }
		L_obj_to_toml -v out a || L_unittest_fail "reading back failed of: $(_L_obj_print_table a)"
		L_toml_to_obj b <<<"$out" || L_unittest_fail "failed reading into b from toml:$L_NL$out"
		L_obj_cmp_obj a b || L_unittest_fail "roundtrip of obj not same same:${L_NL}%% toml=$L_NL$toml${L_NL}%% a=$L_NL$(_L_obj_print_table a)${L_NL}%% out=${L_NL}$out${L_NL}%% b=$L_NL$(_L_obj_print_table b)"
  done
}


_L_test_toml_complex() {
  obj_skip_test
	# Test inline tables
	local toml='a = { b = 1, c = 2 }'
	declare obj=()
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_value_vL_RET obj a b
	L_unittest_eq "$L_RET" "1"
	L_obj_get_value_vL_RET obj a c
	L_unittest_eq "$L_RET" "2"

	# Test inline arrays
	toml='arr = [1, 2, 3]'
	L_toml_to_obj obj <<<"$toml"
	L_obj_len_vL_RET obj arr
	L_unittest_eq "$L_RET" "3"
	L_obj_get_value_vL_RET obj arr 0
	L_unittest_eq "$L_RET" "1"
	L_obj_get_value_vL_RET obj arr 1
	L_unittest_eq "$L_RET" "2"
	L_obj_get_value_vL_RET obj arr 2
	L_unittest_eq "$L_RET" "3"

	# Test datetime
	toml='
dt = 1979-05-27T07:32:00Z
date = 1979-05-27
time = 07:32:00
'
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_value_vL_RET obj dt
	L_unittest_eq "$L_RET" "1979-05-27T07:32:00Z"
	L_obj_get_value_vL_RET obj date
	L_unittest_eq "$L_RET" "1979-05-27"
	L_obj_get_value_vL_RET obj time
	L_unittest_eq "$L_RET" "07:32:00"

	# Test nested inline tables and arrays
	toml='nested = { a = { b = { c = 1 } }, d = [ { e = 1 }, { f = 2 } ] }'
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_value_vL_RET obj nested a b c
	L_unittest_eq "$L_RET" "1"
	L_obj_len_vL_RET obj nested d
	L_unittest_eq "$L_RET" "2"
	L_obj_get_value_vL_RET obj nested d 0 e
	L_unittest_eq "$L_RET" "1"
	L_obj_get_value_vL_RET obj nested d 1 f
	L_unittest_eq "$L_RET" "2"
}

# Test that [section] (single table) and [[section]] (array of tables) are distinct
_L_test_toml_section_vs_array() {
  obj_skip_test
	# Test single table [section]
	local toml='
[database]
name = "mydb"
port = 5432
'
	declare obj
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_value_vL_RET obj database name
	L_unittest_eq "$L_RET" "mydb"
	L_obj_get_value_vL_RET obj database port
	L_unittest_eq "$L_RET" "5432"
	L_obj_to_toml -v out obj
	# Verify the output is valid TOML
	declare obj2=()
	L_toml_to_obj obj2 <<<"$out"
	L_obj_get_value_vL_RET obj2 database name
	L_unittest_eq "$L_RET" "mydb"
	L_obj_get_value_vL_RET obj2 database port
	L_unittest_eq "$L_RET" "5432"

	# Test array of tables [[section]]
	toml='
[[servers]]
name = "alpha"
port = 5432

[[servers]]
name = "beta"
port = 3306
'
	declare obj3=()
	L_toml_to_obj obj3 <<<"$toml"
	L_obj_len_vL_RET obj3 servers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_value_vL_RET obj3 servers 0 name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_value_vL_RET obj3 servers 0 port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_value_vL_RET obj3 servers 1 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_value_vL_RET obj3 servers 1 port
	L_unittest_eq "$L_RET" "3306"
}

_L_test_toml_obj_aliases() {
  obj_skip_test
	local toml='
a = 1
b = "test"
'
	declare obj=()
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_value_vL_RET obj a
	L_unittest_eq "$L_RET" "1"
	L_obj_get_value_vL_RET obj b
	L_unittest_eq "$L_RET" "test"

	L_obj_to_toml -v out obj
	expected='a = 1
b = "test"'
	L_unittest_eq "$out" "$expected"
}
_L_test_toml_dots_and_brackets() {
  obj_skip_test
	# Test keys with dots -> creates nested tables
	local toml='
a.b.c = 1
x.y = "hello"
'
	declare obj=()
	L_toml_to_obj obj <<<"$toml"
	L_obj_get_value_vL_RET obj a b c
	L_unittest_eq "$L_RET" "1"
	L_obj_get_value_vL_RET obj x y
	L_unittest_eq "$L_RET" "hello"

	# Test single bracket table [section]
	toml='
[database]
host = "localhost"
port = 5432

[server]
name = "web"
'
	declare obj2=()
	L_toml_to_obj obj2 <<<"$toml"
	L_obj_get_value_vL_RET obj2 database host
	L_unittest_eq "$L_RET" "localhost"
	L_obj_get_value_vL_RET obj2 database port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_value_vL_RET obj2 server name
	L_unittest_eq "$L_RET" "web"

	# Test double bracket array of tables [[section]]
	toml='
[[servers]]
name = "alpha"
port = 5432

[[servers]]
name = "beta"
port = 3306
'
	declare obj3=()
	L_toml_to_obj obj3 <<<"$toml"
	L_obj_len_vL_RET obj3 servers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_value_vL_RET obj3 servers 0 name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_value_vL_RET obj3 servers 0 port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_value_vL_RET obj3 servers 1 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_value_vL_RET obj3 servers 1 port
	L_unittest_eq "$L_RET" "3306"

	# Test [[ with dot in key name -> creates nested tables
	toml='
[[app.servers]]
name = "alpha"
port = 5432

[[app.servers]]
name = "beta"
port = 3306
'
	declare obj3=()
	L_toml_to_obj obj3 <<<"$toml"
	# [[app.servers]] creates app -> servers -> array of tables
	L_obj_len_vL_RET obj3 app servers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_value_vL_RET obj3 app servers 0 name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_value_vL_RET obj3 app servers 0 port
	L_unittest_eq "$L_RET" "5432"
	L_obj_get_value_vL_RET obj3 app servers 1 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_value_vL_RET obj3 app servers 1 port
	L_unittest_eq "$L_RET" "3306"

	# Mixed: dots in keys inside tables
	toml='
[app.config]
debug = true
version = "1.0"

[[handlers]]
name = "main"
enabled = true

[[handlers]]
name = "backup"
enabled = false
'
	declare obj4=()
	L_toml_to_obj obj4 <<<"$toml"
	L_obj_get_value_vL_RET obj4 app config debug
	L_unittest_eq "$L_RET" "true"
	L_obj_get_value_vL_RET obj4 app config version
	L_unittest_eq "$L_RET" "1.0"
	L_obj_len_vL_RET obj4 handlers
	L_unittest_eq "$L_RET" "2"
	L_obj_get_value_vL_RET obj4 handlers 0 name
	L_unittest_eq "$L_RET" "main"
	L_obj_get_value_vL_RET obj4 handlers 1 enabled
	L_unittest_eq "$L_RET" "false"

	# Test quoted keys - literal dots in key names
	toml='
["app.servers"]
name = "alpha"
port = 5432

[["app.backups"]]
name = "beta"
port = 3306
'
	declare obj5=()
	L_toml_to_obj obj5 <<<"$toml"
	# Quoted keys: literal dots in key names
	L_obj_get_value_vL_RET obj5 "app.servers" name
	L_unittest_eq "$L_RET" "alpha"
	L_obj_get_value_vL_RET obj5 "app.servers" port
	L_unittest_eq "$L_RET" "5432"
	# Array of tables with quoted key needs index
	L_obj_get_value_vL_RET obj5 "app.backups" 0 name
	L_unittest_eq "$L_RET" "beta"
	L_obj_get_value_vL_RET obj5 "app.backups" 0 port
	L_unittest_eq "$L_RET" "3306"
}

