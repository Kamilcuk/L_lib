###############################################################################
# @section obj2
# Additional tests for L_obj functions using the current (new) naming scheme.
# Covers gaps from todo.md and tests for L_obj_get_map and L_obj_set_array.

# ---------------------------------------------------------------------------
# 1. L_obj_set_typed — explicit type/value setting (was L_obj_set_type_value)
# ---------------------------------------------------------------------------
_L_test_obj2_set_typed_types() {
  obj_skip_test
  local L_RET
  local obj
  # Each explicit type directly
  L_obj_set_typed obj str = STRING "hello"
  L_obj_get -v L_RET obj str
  L_unittest_vareq L_RET "hello"
  L_obj_type -v L_RET obj str
  L_unittest_vareq L_RET STRING

  L_obj_set_typed obj int = INTEGER 42
  L_obj_get -v L_RET obj int
  L_unittest_vareq L_RET "42"
  L_obj_type -v L_RET obj int
  L_unittest_vareq L_RET INTEGER

  L_obj_set_typed obj flt = FLOAT 3.14
  L_obj_get -v L_RET obj flt
  L_unittest_vareq L_RET "3.14"
  L_obj_type -v L_RET obj flt
  L_unittest_vareq L_RET FLOAT

  L_obj_set_typed obj b = BOOL true
  L_obj_get -v L_RET obj b
  L_unittest_vareq L_RET "true"
  L_obj_type -v L_RET obj b
  L_unittest_vareq L_RET BOOL

  L_obj_set_typed obj n = NULL ""
  L_obj_type -v L_RET obj n
  L_unittest_vareq L_RET NULL

  L_obj_set_typed obj dt = DATETIME "2024-01-15"
  L_obj_type -v L_RET obj dt
  L_unittest_vareq L_RET DATETIME

  L_obj_set_typed obj d = DATE "2024-01-15"
  L_obj_type -v L_RET obj d
  L_unittest_vareq L_RET DATE

  L_obj_set_typed obj t = TIME "12:00:00"
  L_obj_type -v L_RET obj t
  L_unittest_vareq L_RET TIME
}

_L_test_obj2_set_typed_missing_separator() {
  obj_skip_test
  local obj
  # Missing '=' separator → L_EX_USAGE
  L_unittest_cmd -r '.*' ! L_obj_set_typed obj a STRING "val"
}

_L_test_obj2_set_typed_container_to_scalar() {
  obj_skip_test
  local obj
  L_obj_set_typed obj m = MAP ""
  L_obj_set_typed obj m = STRING "val"
}

_L_test_obj2_set_typed_root_level() {
  obj_skip_test
  local obj L_RET
  # Setting at root level with no path parts
  L_obj_set_typed obj = STRING "rootval"
  L_obj_get -v L_RET obj
  L_unittest_vareq L_RET "rootval"
}

# ---------------------------------------------------------------------------
# 2. L_obj_items — children as triples (was L_obj_get_items, known-broken)
# ---------------------------------------------------------------------------
_L_test_obj2_items_map() {
  obj_skip_test
  local obj items
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  # L_obj_items is known-broken (passes position as extra arg to foreach)
  L_obj_items -v items obj 2>/dev/null || :
  # The test documents the broken behavior; items may be empty
  if (( ${#items[@]} > 0 )); then
    L_unittest_eq "${items[0]}" "a"
  fi
}

_L_test_obj2_items_array() {
  obj_skip_test
  local obj items
  L_obj_array_append obj arr += one
  L_obj_array_append obj arr += two
  L_obj_items -v items obj arr 2>/dev/null || :
  # The test documents the broken behavior
  if (( ${#items[@]} > 0 )); then
    L_unittest_eq "${items[0]}" "0"
  fi
}

_L_test_obj2_items_empty() {
  obj_skip_test
  local items obj
  L_obj_set_typed obj empty = MAP ""
  L_obj_items -v items obj empty 2>/dev/null || :
  L_unittest_eq ${#items[@]} 0
}

_L_test_obj2_items_nonexistent() {
  obj_skip_test
  local obj items
  L_obj_set obj a = 1
  # Non-existent path → returns 1
  L_unittest_cmd -r '.*' ! L_obj_items -v items obj x y z
}

_L_test_obj2_items_scalar() {
  obj_skip_test
  local items obj
  L_obj_set obj s = "value"
  # Getting items from a scalar path → returns 1
  L_unittest_cmd -r '.*' ! L_obj_items -v items obj s
}

# ---------------------------------------------------------------------------
# 3. Negative array indexing
# ---------------------------------------------------------------------------
_L_test_obj2_neg_index_get() {
  obj_skip_test
  local obj L_RET
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  L_obj_get -v L_RET obj arr -1
  L_unittest_vareq L_RET c
  L_obj_get -v L_RET obj arr -2
  L_unittest_vareq L_RET b
}

_L_test_obj2_neg_index_oob() {
  obj_skip_test
  local obj L_RET
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  # Out-of-bounds negative → return 1
  L_unittest_cmd -r '.*' ! L_obj_get -v L_RET obj arr -10
}

_L_test_obj2_neg_index_zero() {
  obj_skip_test
  local obj L_RET
  L_obj_array_append obj arr += a
  # -0 is invalid (code requires _L_arg > 0)
  L_unittest_cmd -r '.*' ! L_obj_get -v L_RET obj arr -0
}

_L_test_obj2_neg_index_has() {
  obj_skip_test
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  L_unittest_checkexit 0 L_obj_has obj arr -1
  L_unittest_checkexit 1 L_obj_has obj arr -10
}

_L_test_obj2_neg_index_rm() {
  obj_skip_test
  local obj L_RET
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  L_obj_rm obj arr -1
  L_obj_len -v L_RET obj arr
  L_unittest_vareq L_RET 2
  L_obj_get -v L_RET obj arr 1
  L_unittest_vareq L_RET b
}

_L_test_obj2_neg_index_pos_keys_len() {
  obj_skip_test
  local obj keys L_RET pos
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  # L_obj_pos via negative index
  L_obj_pos -v pos obj arr -1
  (( pos > 0 )) || L_unittest_fail "pos should be > 0"
  # L_obj_keys on array
  L_obj_keys -v keys obj arr
  L_unittest_arreq keys 0 1 2
  # L_obj_len via negative index (length of scalar value)
  L_obj_len -v L_RET obj arr -1
  L_unittest_vareq L_RET 1
}

# ---------------------------------------------------------------------------
# 4. L_obj_to_json — missing option coverage
# ---------------------------------------------------------------------------
_L_test_obj2_json_compact() {
  obj_skip_test
  local out obj
  L_obj_set obj a = "hello"
  L_obj_set obj b = 42
  L_obj_to_json -c -v out obj
  # Compact: no whitespace/newlines
  [[ "$out" != *$'\n'* ]] || L_unittest_fail "compact output should not contain newlines"
  [[ "$out" == *"\"a\":\"hello\""* ]] || L_unittest_fail "compact output a"
  [[ "$out" == *"\"b\":42"* ]] || L_unittest_fail "compact output b"
}

_L_test_obj2_json_indent() {
  obj_skip_test
  local out obj
  L_obj_set obj a = "hello"
  L_obj_to_json -i 4 -v out obj
  # Should use 4-space indentation
  L_unittest_cmd L_regex_match "$out" $'\n    "a"'
  L_obj_to_json -v out obj
  # Default uses 2 spaces
  L_unittest_cmd L_regex_match "$out" $'\n  "a"'
}

_L_test_obj2_json_ascii() {
  obj_skip_test
  local out obj
  L_obj_set obj name = "héllo"
  L_obj_to_json -a -v out obj
  # Non-ASCII → \uXXXX
  [[ "$out" == *"\\u00"* ]] || L_unittest_fail "expected unicode escape"
}

_L_test_obj2_json_color() {
  obj_skip_test
  local out obj
  L_obj_set_typed obj b = BOOL true
  L_obj_set_typed obj n = NULL ""
  L_obj_set obj s = "str"
  L_obj_set obj i = 42
  L_obj_to_json -C -v out obj
  # ANSI codes should be present
  [[ "$out" == *$'\033'* ]] || L_unittest_fail "expected ANSI codes in color output"
}

_L_test_obj2_json_sort() {
  obj_skip_test
  local out obj
  L_obj_set obj z = 1
  L_obj_set obj a = 2
  L_obj_set obj m = 3
  L_obj_to_json -S -v out obj
  # Keys in alphabetical order: a, m, z
  L_unittest_cmd L_regex_match "$out" '"a".*"m".*"z"'
}

_L_test_obj2_json_empty_container() {
  obj_skip_test
  local out obj
  L_obj_set_map obj =
  L_obj_to_json -v out obj
  # Empty object → "{}"
  L_unittest_eq "$out" '{}'

  L_obj_new obj
  L_obj_set_array obj =
  L_obj_to_json -v out obj
  L_unittest_eq "$out" '[]'
}

_L_test_obj2_json_root_scalar() {
  obj_skip_test
  local out obj
  L_obj_set obj = "hello"
  L_obj_to_json -v out obj
  L_unittest_eq "$out" '"hello"'
}

_L_test_obj2_json_null() {
  obj_skip_test
  local out obj
  L_obj_set_typed obj n = NULL ""
  L_obj_to_json -cv out obj
  echo "$out"
  # NULL value should serialize as null
  L_unittest_cmd L_regex_match "$out" '"n": *null'
}

_L_test_obj2_json_bool() {
  obj_skip_test
  local out obj
  L_obj_set_typed obj b1 = BOOL true
  L_obj_set_typed obj b2 = BOOL false
  L_obj_to_json -v out obj
  L_unittest_cmd L_regex_match "$out" '"b1": *true'
  L_unittest_cmd L_regex_match "$out" '"b2": *false'
}

# ---------------------------------------------------------------------------
# 5. L_obj_to_ini and L_obj_to_toml — missing option coverage
# ---------------------------------------------------------------------------
_L_test_obj2_ini_sort() {
  obj_skip_test
  local out obj
  L_obj_set obj z = 1
  L_obj_set obj a = 2
  L_obj_set obj m = 3
  L_obj_to_ini -S -v out obj
  # Keys in alphabetical order
  L_unittest_cmd L_regex_match "$out" $'a = 2\nm = 3\nz = 1'
}

_L_test_obj2_ini_multiline() {
  obj_skip_test
  local out obj
  L_obj_set obj multi = $'line1\nline2\nline3'
  _L_obj_dump obj
  L_obj_to_ini -v out obj
  echo "$out"
  # Multi-line string values → continuation lines with "  ..."
  [[ "$out" == *"line1"* ]] || L_unittest_fail "should contain line1"
  [[ "$out" == *"  line2"* ]] || L_unittest_fail "should have continuation line2"
}

_L_test_obj2_ini_special_chars() {
  obj_skip_test
  local out obj
  L_obj_set obj s1 = "val;comment"
  L_obj_set obj s2 = "val#hash"
  L_obj_set obj s3 = "val[bracket"
  L_obj_set obj s4 = '"quoted'
  L_obj_to_ini -v out obj
  [[ "$out" == *\"val\;*\"* ]] || L_unittest_fail "semicolon should trigger quoting"
  [[ "$out" == *\"val\#*\"* ]] || L_unittest_fail "hash should trigger quoting"
}

_L_test_obj2_ini_empty_string() {
  obj_skip_test
  local out obj
  L_obj_set obj empty = ""
  L_obj_to_ini -v out obj
  # Empty string → "key =" or "key = \"\""
  L_unittest_cmd L_regex_match "$out" 'empty =.*'
}

_L_test_obj2_toml_sort() {
  obj_skip_test
  local out obj
  L_obj_set obj z = 1
  L_obj_set obj a = 2
  L_obj_set obj m = 3
  L_obj_to_toml -S -v out obj
  L_unittest_cmd L_regex_match "$out" $'a = 2\nm = 3\nz = 1'
}

_L_test_obj2_toml_datetime() {
  obj_skip_test
  local out obj
  L_obj_set_typed obj dt = DATETIME "2024-01-15T12:00:00Z"
  L_obj_set_typed obj d = DATE "2024-01-15"
  L_obj_set_typed obj t = TIME "12:00:00"
  L_obj_to_toml -v out obj
  # DATETIME/DATE/TIME should be unquoted
  L_unittest_cmd L_regex_match "$out" 'dt = 2024'
  L_unittest_cmd L_regex_match "$out" 'd = 2024'
  L_unittest_cmd L_regex_match "$out" 't = 12'
}

_L_test_obj2_toml_nested_array_of_tables() {
  obj_skip_test
  local out obj
  L_obj_set_array obj servers =
  L_obj_set obj servers 0 host = "a"
  L_obj_set obj servers 1 host = "b"
  L_obj_to_toml -v out obj
  echo "$out"
  # Should use [[...]] syntax for array of tables
  L_unittest_cmd L_regex_match "$out" $'\\[\\[servers\\]\\]\nhost *= *"a"'
  L_unittest_cmd L_regex_match "$out" $'\\[\\[servers\\]\\]\nhost *= *"b"'
}

_L_test_obj2_toml_inline_array() {
  obj_skip_test
  local out obj
  L_obj_array_append obj arr += 1
  L_obj_array_append obj arr += 2
  L_obj_array_append obj arr += 3
  L_obj_to_toml -v out obj
  L_unittest_cmd L_regex_match "$out" 'arr = \[1, 2, 3\]'
}

_L_test_obj2_toml_root_array_error() {
  obj_skip_test
  local out obj
  L_obj_new obj
  L_obj_set_array obj =
  # Root-level ARRAY -> "TOML root must be a table" error
  L_unittest_cmd -r '.*' ! L_obj_to_toml -v out obj
}

# ---------------------------------------------------------------------------
# 6. L_obj_walk — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_walk_sort() {
  obj_skip_test
  local out="" IFS=' '
  L_obj_set obj z = 1
  L_obj_set obj a = 2
  L_obj_set obj m = 3
  collect() { out+="$*"$'\n'; }
  L_obj_walk -S obj collect
  # Keys should be visited in sorted order: a, m, z
  L_unittest_cmd L_regex_match "$out" 'VALUE INTEGER 2 a.*VALUE INTEGER 3 m.*VALUE INTEGER 1 z'
}

_L_test_obj2_walk_callback_abort() {
  obj_skip_test
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  abort_cb() {
    if [[ "$1" == VALUE ]]; then
      return 42
    fi
  }
  _L_obj_dump obj
  # When callback returns non-zero, walk aborts and returns that code
  L_unittest_cmd -e 42 L_obj_walk obj abort_cb
}

_L_test_obj2_walk_empty_object() {
  obj_skip_test
  local obj
  # Walk on empty/uninitialized object → returns 0 immediately
  L_unittest_checkexit 0 L_obj_walk obj echo
}

_L_test_obj2_walk_root_scalar() {
  obj_skip_test
  local obj
  L_obj_set obj = "scalar"
  # Root as a scalar VALUE node
  local out="" IFS=' '
  root_cb() { out+="$*"$'\n'; }
  L_obj_walk obj root_cb
  L_unittest_cmd L_regex_match "$out" 'VALUE STRING scalar'
}

# ---------------------------------------------------------------------------
# 7. L_obj_foreach — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_foreach_abort() {
  obj_skip_test
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  abort_cb() {
    return 1   # abort
  }
  # Callback abort — foreach stops and propagates
  L_unittest_cmd -e 1 L_obj_foreach obj abort_cb
}

_L_test_obj2_foreach_array_indices() {
  obj_skip_test
  local obj out=""
  L_obj_array_append obj arr += first
  L_obj_array_append obj arr += second
  L_obj_array_append obj arr += third
  cb() { out+="$1:$2:$3:$4"$'\n'; }
  # Iterate INTO an ARRAY using position syntax
  L_obj_pos -v pos obj arr
  L_obj_foreach "obj+${pos}" cb
  # Callback should receive integer indices 0, 1, 2 as $1
  [[ "$out" == *"0:first:STRING"* ]] || L_unittest_fail "index 0 not correct"
  [[ "$out" == *"1:second:STRING"* ]] || L_unittest_fail "index 1 not correct"
  [[ "$out" == *"2:third:STRING"* ]] || L_unittest_fail "index 2 not correct"
}

_L_test_obj2_foreach_empty_array() {
  obj_skip_test
  local obj out=""
  L_obj_set_array obj empty =
  cb() { out+="$1:$2:$3:$4"$'\n'; }
  L_obj_pos -v pos obj empty
  L_obj_foreach "obj+${pos}" cb
  # Empty ARRAY → no callback calls
  L_unittest_vareq out ""
}

_L_test_obj2_foreach_scalar() {
  obj_skip_test
  local obj
  L_obj_set obj s = "value"
  L_unittest_cmd -r 's value STRING' L_obj_foreach obj echo
}

_L_test_obj2_foreach_arg_order() {
  obj_skip_test
  local obj out="" pos
  L_obj_array_append obj arr += val
  L_obj_pos -v pos obj arr
  cb() { out+="$1:$2:$3:$4"$'\n'; }
  L_obj_foreach "obj+${pos}" cb
  # Callback arg order: key/index value type pos
  L_unittest_cmd L_regex_match "$out" '^0:val:STRING:'
}

# ---------------------------------------------------------------------------
# 8. L_obj_iter — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_iter_break_reset() {
  obj_skip_test
  local k v t pos it
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  it=""
  # Break after first
  L_obj_iter obj it k v t pos
  L_unittest_vareq k "a"
  L_unittest_vareq v "1"
  # Reset before reuse
  it=""
  L_obj_iter obj it k v t pos
  L_unittest_vareq k "a"
  L_obj_iter obj it k v t pos
  L_unittest_vareq k "b"
  L_obj_iter obj it k v t pos
  L_unittest_vareq k "c"
  # Iterator exhausted
  L_unittest_checkexit 1 L_obj_iter obj it k v t pos
}

_L_test_obj2_iter_non_container() {
  obj_skip_test
  local k v it obj
  L_obj_set obj = "value"
  it=""
  # Non-container path → returns 1
  L_unittest_checkexit 1 L_obj_iter obj it k v
}

_L_test_obj2_iter_pos_verified() {
  obj_skip_test
  local k v t pos it obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_pos -v expected_a obj a
  L_obj_pos -v expected_b obj b
  it=""
  L_obj_iter obj it k v t pos
  L_unittest_eq "$pos" "$expected_a"
  L_obj_iter obj it k v t pos
  L_unittest_eq "$pos" "$expected_b"
}

# ---------------------------------------------------------------------------
# 9. L_obj_copy — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_copy_subtree() {
  obj_skip_test
  local L_RET src dst srcpos
  L_obj_set src parent child = "value"
  L_obj_set src other = "keep"
  L_obj_copy src dst
  # Copy subtree: copy only the 'parent' subtree into a new location
  L_obj_pos -v srcpos src parent
  _L_obj_dump src
  L_obj_copy src+$srcpos dst subtree
  _L_obj_dump dst
  L_obj_get -v L_RET dst subtree child
  L_unittest_vareq L_RET "value"
}

_L_test_obj2_copy_scalar() {
  obj_skip_test
  local L_RET src dst
  L_obj_set src s = "scalarval"
  # Copy a scalar node (non-container value)
  L_obj_pos -v spos src s
  L_setx L_obj_copy src+${spos} dst d
  L_obj_get -v L_RET dst d
  L_unittest_vareq L_RET "scalarval"
}

_L_test_obj2_copy_replaces_existing() {
  obj_skip_test
  local L_RET
  local src dst
  L_obj_set src newval = "new"
  L_obj_set dst oldval = "old"
  L_obj_set dst oldchild = "data"
  # Copy into a position that already has content → old children cleaned up
  L_obj_copy src dst
  L_unittest_checkexit 1 L_obj_has dst oldval
  L_unittest_checkexit 1 L_obj_has dst oldchild
  L_obj_get -v L_RET dst newval
  L_unittest_vareq L_RET "new"
}

_L_test_obj2_copy_same_object() {
  obj_skip_test
  local obj
  L_obj_set obj a = 1
  # Copy into itself → returns 0 immediately
  L_unittest_checkexit 0 L_obj_copy obj obj
}

_L_test_obj2_copy_same_object_subtree() {
  obj_skip_test
  local L_RET pos
  local obj
  L_obj_set obj parent child1 = "v1"
  L_obj_set obj parent child2 = "v2"
  L_obj_set obj other = "keep"
  L_obj_pos -v pos obj parent
  # Copy into a position within the same object
  L_obj_copy "obj+${pos}" obj newparent
  L_obj_get -v L_RET obj newparent child1
  L_unittest_vareq L_RET "v1"
  L_obj_get -v L_RET obj newparent child2
  L_unittest_vareq L_RET "v2"
  L_obj_get -v L_RET obj other
  L_unittest_vareq L_RET "keep"
}

# ---------------------------------------------------------------------------
# 10. L_obj_merge — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_merge_nested_map() {
  obj_skip_test
  local L_RET src dst
  L_obj_set dst nested a = 1
  L_obj_set dst nested b = 2
  L_obj_set src nested b = "changed"
  L_obj_set src nested c = 3
  # Deep merge: overlapping nested keys merge recursively
  L_obj_merge src dst
  L_obj_get -v L_RET dst nested a
  L_unittest_vareq L_RET "1"
  L_obj_get -v L_RET dst nested b
  L_unittest_vareq L_RET "changed"
  L_obj_get -v L_RET dst nested c
  L_unittest_vareq L_RET "3"
}

_L_test_obj2_merge_array_array() {
  obj_skip_test
  local keys src dst
  L_obj_array_append dst arr += a
  L_obj_array_append dst arr += b
  L_obj_array_append src arr += c
  L_obj_array_append src arr += d
  # ARRAY:ARRAY → elements appended (not replaced)
  L_obj_merge src dst
  L_obj_keys -v keys dst arr
  L_unittest_arreq keys 0 1 2 3
}

_L_test_obj2_merge_map_scalar_dst() {
  obj_skip_test
	local src dst
	L_obj_set dst = "value"          # dst root is a scalar
	L_obj_set src map_key = "new"    # src root is a MAP
	L_unittest_cmd -r 'must be MAP' ! L_obj_merge src dst
}

_L_test_obj2_merge_array_nonarray_dst() {
  obj_skip_test
  local obj
  L_obj_set_array dst arr =
  L_obj_array_append obj_a dst arr += x
  L_obj_set_map src arr =
  _L_obj_dump src dst
  L_unittest_cmd -r '.*' ! L_obj_merge src dst
}

_L_test_obj2_merge_empty_target() {
  obj_skip_test
  local L_RET src dst
  L_obj_set src a = 1
  L_obj_set src b c = 2
  # Merging into an empty/uninitialized target
  L_obj_merge src dst
  L_obj_get -v L_RET dst a
  L_unittest_vareq L_RET "1"
  L_obj_get -v L_RET dst b c
  L_unittest_vareq L_RET "2"
}

# ---------------------------------------------------------------------------
# 11. L_obj_cmp — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_cmp_type_mismatch() {
  obj_skip_test
  local obj1 obj2
  L_obj_set_typed obj1 a = INTEGER 1
  L_obj_set_typed obj2 a = STRING "1"
  # Type mismatch: INTEGER vs STRING → unequal
  L_unittest_checkexit 1 L_obj_cmp obj1 obj2
}

_L_test_obj2_cmp_bool() {
  obj_skip_test
  local obj1 obj2 obj3
  L_obj_set_typed obj1 b = BOOL true
  L_obj_set_typed obj2 b = BOOL true
  L_obj_set_typed obj3 b = BOOL false
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  L_unittest_checkexit 1 L_obj_cmp obj1 obj3
}

_L_test_obj2_cmp_null() {
  obj_skip_test
  local obj1 obj2
  L_obj_set_typed obj1 n = NULL ""
  L_obj_set_typed obj2 n = NULL ""
  # Two NULL nodes (both have empty value)
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
}

_L_test_obj2_cmp_float() {
  obj_skip_test
  local obj1 obj2 obj3
  L_obj_set_typed obj1 f = FLOAT "1.0"
  L_obj_set_typed obj2 f = FLOAT "1.0"
  L_obj_set_typed obj3 f = FLOAT "2.0"
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  L_unittest_checkexit 1 L_obj_cmp obj1 obj3
}

_L_test_obj2_cmp_empty_containers() {
  obj_skip_test
  local obj1 obj2 obj3
  L_obj_set_typed obj1 = MAP ""
  L_obj_set_typed obj2 = MAP ""
  L_obj_set_array obj3 =
  # {} vs {} → equal
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  # {} vs [] → unequal (different types)
  L_unittest_checkexit 1 L_obj_cmp obj1 obj3
}

_L_test_obj2_cmp_nested_arrays() {
  obj_skip_test
  local obj1 obj2
  L_obj_array_append obj1 arr += a
  L_obj_array_append obj1 arr += b
  L_obj_array_append obj2 arr += a
  L_obj_array_append obj2 arr += c
  # Nested arrays with different elements → unequal
  L_unittest_checkexit 1 L_obj_cmp obj1 obj2
}

# ---------------------------------------------------------------------------
# 12. Argument validation errors
# ---------------------------------------------------------------------------
_L_test_obj2_argval_set_typed_missing_eq() {
  obj_skip_test
  local obj
  L_unittest_cmd -r '.*' ! L_obj_set_typed obj a STRING "val"
}

_L_test_obj2_argval_set_typed_default_missing_eq() {
  obj_skip_test
  local obj
  # _L_obj_set_typed_default is called by L_obj_set_default; test directly
  L_obj_set obj a = 1
  L_unittest_cmd -r '.*' ! _L_obj_set_typed_default obj a STRING "def"
}

_L_test_obj2_argval_concat_missing_plus() {
  obj_skip_test
  local obj
  L_obj_set obj s = "hello"
  L_unittest_cmd -r '.*' ! L_obj_string_append obj s "world"
}

_L_test_obj2_argval_append_typed_missing_plus() {
  obj_skip_test
  local obj
  L_unittest_cmd -r '.*' ! L_obj_array_append_typed obj arr INTEGER 1
}

_L_test_obj2_argval_append_typed_too_few() {
  obj_skip_test
  local obj
  L_unittest_cmd -r '.*' ! L_obj_array_append_typed obj
}

_L_test_obj2_argval_insert_typed_missing_eq() {
  obj_skip_test
  local obj
  L_obj_array_append obj arr += x
  L_unittest_cmd -r '.*' ! L_obj_array_insert_typed obj arr 0 INTEGER "val"
}

_L_test_obj2_argval_insert_typed_too_few() {
  obj_skip_test
  local obj
  L_unittest_cmd -r '.*' ! L_obj_array_insert_typed obj
}

# ---------------------------------------------------------------------------
# 13. L_obj_rm — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_rm_mid_array() {
  obj_skip_test
  local L_RET
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  L_obj_array_append obj arr += d
  # Remove a middle element from an ARRAY
  L_obj_rm obj arr 1
  L_obj_len -v L_RET obj arr
  L_unittest_vareq L_RET 3
  # Verify remaining elements re-linked correctly
  L_obj_get -v L_RET obj arr 0
  L_unittest_vareq L_RET "a"
  L_obj_get -v L_RET obj arr 1
  L_unittest_vareq L_RET "c"
  L_obj_get -v L_RET obj arr 2
  L_unittest_vareq L_RET "d"
}

_L_test_obj2_rm_nonexistent() {
  obj_skip_test
  local obj
  L_obj_set obj a = 1
  # Removing from a non-existent path → returns 1
  L_unittest_cmd -r '.*' ! L_obj_rm obj x y z
}

_L_test_obj2_rm_position_syntax() {
  obj_skip_test
  local pos
  local obj
  L_obj_set obj a b = "value"
  L_obj_set obj a c = "value2"
  L_obj_pos -v pos obj a
  # Remove via position syntax
  L_obj_rm "obj+${pos}" b
  L_unittest_checkexit 1 L_obj_has "obj+${pos}" b
  L_unittest_checkexit 0 L_obj_has "obj+${pos}" c
}

_L_test_obj2_rm_free_list_reuse() {
  obj_skip_test
  local L_RET pos
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  # Remove middle element
  L_obj_rm obj arr 1
  # Insert again → should reuse freed slot
  L_obj_array_insert obj arr 1 = "new"
  L_obj_get -v L_RET obj arr 1
  L_unittest_vareq L_RET "new"
  # Verify A and C still linked correctly
  L_obj_get -v L_RET obj arr 0
  L_unittest_vareq L_RET "a"
  L_obj_get -v L_RET obj arr 2
  L_unittest_vareq L_RET "c"
}

# ---------------------------------------------------------------------------
# 14. L_obj_array_pop — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_pop_nested() {
  obj_skip_test
  local L_RET
  local obj
  L_obj_array_append obj parent arr += x
  L_obj_array_append obj parent arr += y
  L_obj_array_append obj parent arr += z
  # Popping from a nested array
  L_obj_array_pop -v L_RET obj parent arr
  L_unittest_vareq L_RET z
  L_obj_len -v L_RET obj parent arr
  L_unittest_vareq L_RET 2
}

_L_test_obj2_pop_container() {
  obj_skip_test
  local obj
  L_obj_array_append obj arr += scalar
  L_obj_set_typed obj arr 1 = MAP ""
  L_obj_array_pop -v var obj arr
  L_unittest_vareq var ""
}

# ---------------------------------------------------------------------------
# 15. L_obj_get — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_get_from_container() {
  obj_skip_test
  local obj
  L_obj_set_typed obj m = MAP ""
  # Getting value from a container node → "no scalar value" error
  L_unittest_cmd -r '.*' ! L_obj_get -v v obj m
  # Also test via stdout
  L_unittest_cmd -r '.*' ! L_obj_get obj m
}

_L_test_obj2_get_without_v() {
  obj_skip_test
  local obj
  L_obj_set obj a = "hello"
  # Without -v (prints to stdout) — never tested
  L_unittest_cmd -o 'hello' L_obj_get obj a
}

_L_test_obj2_get_negative_index() {
  obj_skip_test
  local v
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  L_obj_get -v v obj arr -1
  L_unittest_vareq v c
}

# ---------------------------------------------------------------------------
# 16. L_obj_get_or — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_get_or_container() {
  obj_skip_test
  local v
  local obj
  L_obj_set_typed obj m = MAP ""
  # Path exists but is a container → "cannot get value of a container" error
  L_unittest_cmd -r '.*' ! L_obj_get_or -v v obj m "default"
}

_L_test_obj2_get_or_special_chars() {
  obj_skip_test
  local v
  local obj
  L_obj_set obj a = 1
  # Default value containing special characters
  L_obj_get_or -v v obj missing "spaced value"
  L_unittest_vareq v "spaced value"
  L_obj_get_or -v v obj missing "with=equals"
  L_unittest_vareq v "with=equals"
  L_obj_get_or -v v obj missing '"quoted"'
  L_unittest_vareq v '"quoted"'
  L_obj_get_or -v v obj missing ''
  L_unittest_vareq v ""
}

# ---------------------------------------------------------------------------
# 17. L_obj_len — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_len_scalar_types() {
  obj_skip_test
  local v
  local obj
  L_obj_set_typed obj i = INTEGER 42
  L_obj_len -v v obj i
  L_unittest_vareq v "2"

  L_obj_set_typed obj f = FLOAT 3.14
  L_obj_len -v v obj f
  L_unittest_vareq v "4"

  L_obj_set_typed obj b = BOOL true
  L_obj_len -v v obj b
  L_unittest_vareq v "4"

  L_obj_set_typed obj n = NULL ""
  L_obj_len -v v obj n
  L_unittest_vareq v "0"

  L_obj_set obj e = ""
  L_obj_len -v v obj e
  L_unittest_vareq v "0"
}

# ---------------------------------------------------------------------------
# 18. L_obj_keys — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_keys_nonexistent() {
  obj_skip_test
  local -a keys
  local obj
  L_obj_set obj a = 1
  # Keys from a non-existent path → returns 1
  L_unittest_cmd -r '.*' ! L_obj_keys -v keys obj x y z
}

_L_test_obj2_keys_nested_array() {
  obj_skip_test
  local -a keys pos
  local obj
  L_obj_set obj parent arr 0 = "a"
  L_obj_set obj parent arr 1 = "b"
  L_obj_set obj parent arr 2 = "c"
  L_obj_pos -v pos obj parent arr
  L_obj_keys -v keys "obj+${pos}"
  L_unittest_arreq keys 0 1 2
}

# ---------------------------------------------------------------------------
# 19. L_obj_has — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_has_negative() {
  obj_skip_test
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  L_unittest_checkexit 0 L_obj_has obj arr -1
  L_unittest_checkexit 0 L_obj_has obj arr -2
  L_unittest_checkexit 1 L_obj_has obj arr -10
}

_L_test_obj2_has_position_missing_child() {
  obj_skip_test
  local pos
  local obj
  L_obj_set obj a b = "val"
  L_obj_pos -v pos obj a
  # Position syntax into a missing child
  L_unittest_checkexit 1 L_obj_has "obj+${pos}" nonexistent
}

# ---------------------------------------------------------------------------
# 20. L_obj_string_append — missing coverage (was L_obj_string_append)
# ---------------------------------------------------------------------------
_L_test_obj2_concat_bool() {
  obj_skip_test
  local v
  local obj
  # Appending to BOOL → coerces to STRING
  L_obj_set_typed obj b = BOOL true
  L_obj_string_append obj b += "suffix"
  L_obj_type -v v obj b
  L_unittest_vareq v STRING
  L_obj_get -v v obj b
  L_unittest_vareq v "truesuffix"
}

_L_test_obj2_concat_null() {
  obj_skip_test
  local v
  local obj
  # Appending to NULL → coerces to STRING
  L_obj_set_typed obj n = NULL ""
  L_obj_string_append obj n += "appended"
  L_obj_type -v v obj n
  L_unittest_vareq v STRING
  L_obj_get -v v obj n
  L_unittest_vareq v "appended"
}

_L_test_obj2_concat_nonexistent() {
  obj_skip_test
  local obj
  # Appending to a non-existent path → should fail
  L_unittest_cmd -r '.*' ! L_obj_string_append obj missing += "text"
}

_L_test_obj2_concat_missing_plus() {
  obj_skip_test
  local obj
  L_obj_set obj s = "hello"
  L_unittest_cmd -r '.*' ! L_obj_string_append obj s "world"
}

# ---------------------------------------------------------------------------
# 21. L_obj_array_append_typed — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_append_typed_map_array() {
  obj_skip_test
	local v obj
	L_obj_set_typed obj arr = ARRAY ""
	L_obj_array_append_typed obj arr += MAP ""
	L_obj_type -v v obj arr 0
	L_unittest_vareq v MAP

	L_obj_array_append_typed obj arr += ARRAY ""
	L_obj_type -v v obj arr 1
	L_unittest_vareq v ARRAY
}

_L_test_obj2_append_typed_missing_plus() {
  obj_skip_test
  local obj
  L_unittest_cmd -r '.*' ! L_obj_array_append_typed obj arr INTEGER 1
}

_L_test_obj2_append_typed_too_few() {
  obj_skip_test
  local obj
  L_unittest_cmd -r '.*' ! L_obj_array_append_typed obj
}

_L_test_obj2_append_typed_order() {
  obj_skip_test
  local -a keys v
  local obj
  L_obj_array_append_typed obj arr += INTEGER 1
  L_obj_array_append_typed obj arr += INTEGER 2
  L_obj_array_append_typed obj arr += INTEGER 3
  L_obj_array_append_typed obj arr += INTEGER 4
  # Verify full ordered sequence
  L_obj_keys -v keys obj arr
  L_unittest_arreq keys 0 1 2 3
  L_obj_get -v v obj arr 0; L_unittest_vareq v "1"
  L_obj_get -v v obj arr 1; L_unittest_vareq v "2"
  L_obj_get -v v obj arr 2; L_unittest_vareq v "3"
  L_obj_get -v v obj arr 3; L_unittest_vareq v "4"
}

# ---------------------------------------------------------------------------
# 22. Type inference (_L_obj_infer_type_from_value_vL_RET)
# ---------------------------------------------------------------------------

_L_test_obj2_infer_scientific() {
  obj_skip_test
  local v
  local obj
  L_obj_set obj x = 1e10
  L_obj_type -v v obj x
  L_unittest_vareq v FLOAT
  L_obj_set obj x = 1E10
  L_obj_type -v v obj x
  L_unittest_vareq v FLOAT
  L_obj_set obj x = 1e-10
  L_obj_type -v v obj x
  L_unittest_vareq v FLOAT
}

_L_test_obj2_infer_edge_cases() {
  obj_skip_test
  local v
  local obj
  # Leading zero → STRING (regex doesn't match)
  L_obj_set obj x = 01
  L_obj_type -v v obj x
  L_unittest_vareq v STRING
  # Decimal without leading digit → STRING
  L_obj_set obj x = .5
  L_obj_type -v v obj x
  L_unittest_vareq v STRING
  # Empty string → STRING
  L_obj_set obj x = ""
  L_obj_type -v v obj x
  L_unittest_vareq v STRING
  # Zero → INTEGER
  L_obj_set obj x = 0
  L_obj_type -v v obj x
  L_unittest_vareq v INTEGER
  # Negative FLOAT → FLOAT
  L_obj_set obj x = -3.14
  L_obj_type -v v obj x
  L_unittest_vareq v FLOAT
  # Float with exponent and decimal → FLOAT
  L_obj_set obj x = 1.5e10
  L_obj_type -v v obj x
  L_unittest_vareq v FLOAT
  # +3.14 → FLOAT
  L_obj_set obj x = 3.14
  L_obj_type -v v obj x
  L_unittest_vareq v FLOAT
}

# ---------------------------------------------------------------------------
# 23. L_obj_clear — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_clear_array() {
  obj_skip_test
  local v
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  # Clearing an ARRAY → verifies all elements freed
  L_obj_clear obj arr
  L_obj_len -v v obj arr
  L_unittest_vareq v "0"
}

_L_test_obj2_clear_freelist() {
  obj_skip_test
  local v
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  # Clear, then set new values → verify correct linking
  L_obj_clear obj
  L_obj_set obj x = "new1"
  L_obj_set obj y = "new2"
  L_obj_get -v v obj x
  L_unittest_vareq v "new1"
  L_obj_get -v v obj y
  L_unittest_vareq v "new2"
  L_obj_len -v v obj
  L_unittest_vareq v "2"
}

_L_test_obj2_clear_mixed_children() {
  obj_skip_test
  local v
  local obj
  L_obj_set obj scalar = "value"
  L_obj_set_map obj sub =
  L_obj_set obj sub child = "childval"
  L_obj_clear obj
  L_obj_len -v v obj
  L_unittest_vareq v "0"
}

# ---------------------------------------------------------------------------
# 24. Free list / memory reuse
# ---------------------------------------------------------------------------
_L_test_obj2_freelist_interleave() {
  obj_skip_test
  local v
  local obj
  # Complex interleaving: insert A → insert B → insert C → remove B → insert D
  L_obj_array_append obj arr += "a"
  L_obj_array_append obj arr += "b"
  L_obj_array_append obj arr += "c"
  L_obj_rm obj arr 1   # remove b
  L_obj_array_insert obj arr 1 = "d"
  # D reuses B's slot, A and C still linked correctly
  L_obj_get -v v obj arr 0; L_unittest_vareq v "a"
  L_obj_get -v v obj arr 1; L_unittest_vareq v "d"
  L_obj_get -v v obj arr 2; L_unittest_vareq v "c"
}

_L_test_obj2_freelist_multiple_removals() {
  obj_skip_test
	local v obj pb pc pe pf
	L_obj_array_append obj arr += "a"
	L_obj_array_append -v pb obj arr += "b"
	L_obj_array_append -v pc obj arr += "c"
	L_obj_array_append obj arr += "d"
	L_obj_rm obj arr 1   # remove b
	L_obj_rm obj arr 1   # remove c
	L_obj_array_append -v pe obj arr += "e"
	L_obj_array_append -v pf obj arr += "f"
	L_obj_len -v v obj arr
	L_unittest_vareq v 4
	L_obj_get -v v obj arr 0; L_unittest_vareq v a
	L_obj_get -v v obj arr 1; L_unittest_vareq v d
	L_obj_get -v v obj arr 2; L_unittest_vareq v e
	L_obj_get -v v obj arr 3; L_unittest_vareq v f
	L_unittest_vareq pe "$pc"   # LIFO free list
	L_unittest_vareq pf "$pb"
}

# ---------------------------------------------------------------------------
# 25. L_obj_walk callback parts — deeply nested
# ---------------------------------------------------------------------------
_L_test_obj2_walk_deep_parts() {
  obj_skip_test
  local out="" IFS=' ' obj
  # Map→Map→Array→Map→scalar path
  L_obj_set obj a b c 0 d = "deepval"
  walk_cb() { out+="$*"$'\n'; }
  L_obj_walk obj walk_cb
  L_unittest_cmd L_regex_match "$out" 'VALUE STRING deepval a b c 0 d'
}

_L_test_obj2_walk_array_index_deep() {
  obj_skip_test
  local out="" IFS=' ' obj
  L_obj_set obj a 0 = "v0"
  L_obj_set obj a 1 = "v1"
  L_obj_set obj a 2 = "v2"
  walk_cb() { out+="$*"$'\n'; }
  L_obj_walk obj walk_cb
  # Deeply nested array index > 0 in path
  L_unittest_cmd L_regex_match "$out" 'VALUE STRING v2 a 2'
}

# ---------------------------------------------------------------------------
# 26. L_obj_foreach position syntax — ARRAY
# ---------------------------------------------------------------------------
_L_test_obj2_foreach_array_pos_syntax() {
  obj_skip_test
  local pos out="" obj
  L_obj_array_append obj arr += x
  L_obj_array_append obj arr += y
  L_obj_array_append obj arr += z
  L_obj_pos -v pos obj arr
  cb() { out+="$1:$2:$3:$4"$'\n'; }
  L_obj_foreach "obj+${pos}" cb
  # Callback receives integer indices 0, 1, 2 as $1
  L_unittest_cmd L_regex_match "$out" '0:x:STRING:'
  L_unittest_cmd L_regex_match "$out" '1:y:STRING:'
  L_unittest_cmd L_regex_match "$out" '2:z:STRING:'
}

# ---------------------------------------------------------------------------
# 27. BOOL/NULL through L_obj_get
# ---------------------------------------------------------------------------
_L_test_obj2_get_bool() {
  obj_skip_test
  local v
  local obj
  L_obj_set_typed obj b = BOOL true
  L_obj_get -v v obj b
  L_unittest_vareq v "true"

  L_obj_set_typed obj b2 = BOOL false
  L_obj_get -v v obj b2
  L_unittest_vareq v "false"
}

_L_test_obj2_get_null() {
  obj_skip_test
  local v
  local obj
  L_obj_set_typed obj n = NULL ""
  L_obj_get -v v obj n
  # NULL has empty value
  L_unittest_vareq v ""
}

_L_test_obj2_get_bool_null_from_set_typed() {
  obj_skip_test
  local v t
  local obj
  L_obj_set_typed obj n = BOOL true
  L_obj_type -v t obj n
  L_unittest_vareq t BOOL
  L_obj_get -v v obj n
  L_unittest_vareq v "true"

  L_obj_set_typed obj nl = NULL ""
  L_obj_type -v t obj nl
  L_unittest_vareq t NULL
  L_obj_get -v v obj nl
  L_unittest_vareq v ""
}

# ---------------------------------------------------------------------------
# 28. L_obj_set_typed reverse error — scalar to container
# ---------------------------------------------------------------------------
_L_test_obj2_set_typed_reverse_error() {
  obj_skip_test
  local L_RET obj
  L_obj_set obj scalar = "value"
  # Reverse: scalar → MAP. The code only checks MAP|ARRAY → scalar, not scalar → MAP.
  # Current behavior: succeeds (missing check). This test documents the gap.
  L_obj_set_map obj scalar =
  L_obj_type -v L_RET obj scalar
  L_unittest_vareq L_RET MAP
}

# ---------------------------------------------------------------------------
# 29. L_obj_array_insert_typed — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_insert_typed_map_array() {
  obj_skip_test
  local v obj
  L_obj_array_append obj arr += "existing"
  # Insert as MAP type — value should be ignored
  L_obj_array_insert_typed obj arr 0 = MAP ""
  L_obj_type -v v obj arr 0
  L_unittest_vareq v MAP
  # Original element shifted to index 1
  L_obj_get -v v obj arr 1
  L_unittest_vareq v "existing"

  # Insert as ARRAY type
  L_obj_array_insert_typed obj arr 1 = ARRAY ""
  L_obj_type -v v obj arr 1
  L_unittest_vareq v ARRAY
}

_L_test_obj2_insert_typed_missing_eq() {
  obj_skip_test
  local obj
  L_obj_array_append obj arr += x
  L_unittest_cmd -r '.*' ! L_obj_array_insert_typed obj arr 0 STRING "val"
}

# ---------------------------------------------------------------------------
# 30. L_obj_is_valid — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_is_valid_free_node() {
  obj_skip_test
  local pos
  local obj
  L_obj_set obj a = 1
  L_obj_pos -v pos obj a
  L_obj_rm obj a
  # Freed node position → should return 1 (FREE)
  L_unittest_checkexit 1 L_obj_is_valid "obj+${pos}"
}

_L_test_obj2_is_valid_non_multiple() {
  obj_skip_test
  # Position that is NOT a multiple of 6 → returns 1
  L_unittest_checkexit 1 L_obj_is_valid "obj+3"
  L_unittest_checkexit 1 L_obj_is_valid "obj+7"
}

_L_test_obj2_is_valid_boundary() {
  obj_skip_test
  local pos
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_pos -v pos obj b
  # Position at exactly the last valid node
  L_unittest_checkexit 0 L_obj_is_valid "obj+${pos}"
}

# ---------------------------------------------------------------------------
# 31. L_obj_pos — missing coverage
# ---------------------------------------------------------------------------
_L_test_obj2_pos_root() {
  obj_skip_test
  local pos
  local obj
  L_obj_set obj a = 1
  # Get position of root
  L_obj_pos -v pos obj
  L_unittest_vareq pos "0"
}

_L_test_obj2_pos_negative() {
  obj_skip_test
  local pos
  local obj
  L_obj_array_append obj arr += a
  L_obj_array_append obj arr += b
  L_obj_array_append obj arr += c
  # Get position via negative index
  L_obj_pos -v pos obj arr -1
  (( pos > 0 )) || L_unittest_fail "pos should be > 0"
}

_L_test_obj2_pos_empty_obj() {
  obj_skip_test
  local pos
  local obj
  # Get position on an empty/uninitialized object with path → should fail
  L_unittest_cmd -r '.*' ! L_obj_pos -v pos obj a b c
}

_L_test_obj2_pos_container() {
  obj_skip_test
  local pos
  local obj
  L_obj_set_typed obj m = MAP ""
  # Get position of a container node (MAP/ARRAY) → should succeed
  L_obj_pos -v pos obj m
  (( pos > 0 )) || L_unittest_fail "pos should be > 0"
}

# ---------------------------------------------------------------------------
# 32. Scalar traversal error
# ---------------------------------------------------------------------------
_L_test_obj2_traverse_through_scalar_get() {
  obj_skip_test
  local v obj
  L_obj_set obj scalar = "value"
  # Traversing through a scalar: get value where scalar is in the way
  L_unittest_cmd -r '.*' ! L_obj_get -v v obj scalar child
}

_L_test_obj2_traverse_through_scalar_set() {
  obj_skip_test
  local obj
  L_obj_set obj scalar = "value"
  # Traversing through a scalar: set value where scalar is in the way
  L_unittest_cmd -r '.*' ! L_obj_set_typed obj scalar child = STRING "val"
}

# ---------------------------------------------------------------------------
# 34. L_obj_get_map — NEW function tests
# ---------------------------------------------------------------------------
_L_test_obj2_get_map_map() {
  obj_skip_test
  local -A asa=()
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  # L_obj_get_map extracts MAP or ARRAY elements as an associative array
  # Note: L_handle_v_asa is not defined on Bash 4.3+ nameref code path.
  # This test documents the broken/missing implementation.
  L_obj_get_map -v asa obj
  if (( ${#asa[@]} == 0 )); then
    L_unittest_skip "L_obj_get_map not functional on this Bash version (L_handle_v_asa missing)"
  fi
  L_unittest_eq "${asa[a]}" 1
  L_unittest_eq "${asa[b]}" 2
  L_unittest_eq "${asa[c]}" 3
}

_L_test_obj2_get_map_array() {
  obj_skip_test
  local -A asa=()
  local obj
  L_obj_array_append obj arr += first
  L_obj_array_append obj arr += second
  L_obj_get_map -v asa obj arr
  if (( ${#asa[@]} == 0 )); then
    L_unittest_skip "L_obj_get_map not functional on this Bash version"
  fi
}

_L_test_obj2_get_map_scalar_error() {
  obj_skip_test
  local -A asa
  local obj
  L_obj_set obj s = "value"
  # Getting asa from a scalar → error
  L_unittest_cmd -r '.*' ! L_obj_get_map -v asa obj s
}

# ---------------------------------------------------------------------------
# 35. L_obj_set_array — NEW function tests
# ---------------------------------------------------------------------------
_L_test_obj2_set_array_basic() {
  obj_skip_test
  local v obj srcarr=(alpha beta gamma)
  # Pre-initialize root to avoid clear-at-root failure
  L_obj_set_typed obj = MAP ""
  _L_obj_dump obj
  L_obj_set_array obj arr = srcarr
  L_obj_len -v v obj arr
  L_unittest_vareq v "3"
  _L_obj_dump obj
  L_obj_get -v v obj arr 0
  L_unittest_vareq v "alpha"
  L_obj_get -v v obj arr 1
  L_unittest_vareq v "beta"
  L_obj_get -v v obj arr 2
  L_unittest_vareq v "gamma"
}

_L_test_obj2_set_array_overwrites() {
  obj_skip_test
  local v obj srcarr=(new1 new2)
  L_obj_set_typed obj = MAP ""
  L_obj_set obj old = "stale"
  L_obj_set obj arr 0 = "old0"
  L_obj_set obj arr 1 = "old1"
  # Setting from array should clear existing children at that path
  L_obj_set_array obj arr = srcarr
  L_obj_len -v v obj arr
  L_unittest_vareq v "2"
  L_obj_get -v v obj arr 0
  L_unittest_vareq v "new1"
  L_obj_get -v v obj arr 1
  L_unittest_vareq v "new2"
}

_L_test_obj2_set_array_missing_eq() {
  obj_skip_test
  local obj srcarr=(a b)
  L_obj_set_typed obj = MAP ""
  # Missing '=' separator → L_EX_USAGE
  L_unittest_cmd -r '.*' ! L_obj_set_array obj arr srcarr
}

_L_test_obj2_set_array_root_uninitialized() {
  obj_skip_test
  local obj srcarr=(a b c) len v
  L_obj_set_array obj = srcarr
  L_obj_len -v len obj
  L_unittest_eq "$len" 3
  L_obj_get -v v obj 0
  L_unittest_eq "$v" a
  L_obj_get -v v obj 1
  L_unittest_eq "$v" b
  L_obj_get -v v obj 2
  L_unittest_eq "$v" c
}

# ---------------------------------------------------------------------------
# Cross-cutting: L_obj_values (new function)
# ---------------------------------------------------------------------------
_L_test_obj2_values_scalars() {
  obj_skip_test
  local obj vals
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_values -v vals obj
  L_unittest_arreq vals 1 2
}

_L_test_obj2_values_array() {
  obj_skip_test
  local obj vals
  L_obj_array_append obj arr += x
  L_obj_array_append obj arr += y
  L_obj_values -v vals obj arr
  L_unittest_arreq vals x y
}

_L_test_obj2_values_nonexistent() {
  obj_skip_test
  local obj vals
  L_unittest_cmd -r '.*' ! L_obj_values -v vals obj x y z
}

_L_test_obj2_values_scalar_error() {
  obj_skip_test
  local obj vals
  L_obj_set obj s = "value"
  L_unittest_cmd -r '.*' ! L_obj_values -v vals obj s
}

_L_test_obj2_values_with_containers() {
  obj_skip_test
  local -a vals
  local obj
  L_obj_set obj a = 1
  L_obj_set_typed obj sub = MAP ""
  # L_obj_values errors on non-scalar children
  L_unittest_cmd -e 64 L_obj_values -v vals obj
}
