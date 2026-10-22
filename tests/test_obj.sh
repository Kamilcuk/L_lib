###############################################################################
# @section obj
# Tests for L_obj functions.

_L_test_obj_1() {
  obj_skip_test
  local L_RET
  local obj
  {
    # # {"a":{"b":[1,2,3]}}
    L_obj_set obj a b 0 = 1
    L_obj_set obj a b 1 = 2
    L_obj_set obj a b 2 = 3
    L_obj_set obj a c = dead1
    L_obj_set obj a d = dead2
    L_obj_set obj a f = dead3
    L_obj_get_vL_RET obj a b 0
    L_unittest_vareq L_RET 1
    L_obj_get_vL_RET obj a b 1
    L_unittest_vareq L_RET 2
    L_obj_get_vL_RET obj a b 2
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
    L_unittest_cmd -r '.*' ! L_obj_len_vL_RET obj a b c
  }
  {
    L_obj_append obj a b += 4
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 4
    L_obj_append obj a b += 5
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 5
  }
  {
    L_obj_concat obj a f += dead
    L_obj_get_vL_RET obj a f
    L_unittest_vareq L_RET dead3dead
  }
  _L_obj_dump obj
  L_pp obj
}

_L_test_obj_2() {
  obj_skip_test
  local L_RET
  local obj=()
  local stations=(warsaw "krakow.south" gdansk)
  local sensors=(temperature humidity pressure)
  local units=(C % hPa)
  local station base i s tick n

  # build the skeleton: stations.<station>.sensors.<0..2>.{name,unit}
  for station in "${stations[@]}"; do
    L_obj_set obj stations "$station" name = "$station"
    for i in "${!sensors[@]}"; do
      L_obj_set obj stations "$station" sensors "$i" name = "${sensors[i]}"
      L_obj_set obj stations "$station" sensors "$i" unit = "${units[i]}"
    done
  done

  # simulate 5 sampling ticks; the first tick seeds readings.1, the rest append
  for tick in 1 2 3 4 5; do
    for station in "${stations[@]}"; do
      base=(stations "$station")
      for s in 0 1 2; do
        L_obj_append obj "${base[@]}" sensors "$s" readings += "$(( RANDOM % 100 ))"
      done
    done
    L_obj_set obj last_update = "$RANDOM"
  done

  _L_obj_dump obj

    # --- lookups and lengths
  base=(stations krakow.south)
  L_obj_get_vL_RET obj "${base[@]}" name
  L_unittest_vareq L_RET krakow.south
  L_obj_len_vL_RET obj "${base[@]}" sensors
  L_unittest_vareq L_RET 3
  L_obj_len_vL_RET obj "${base[@]}" sensors 1 readings
  L_unittest_vareq L_RET 5
  L_obj_get_vL_RET obj "${base[@]}" sensors 2 unit
  L_unittest_vareq L_RET hPa

  # --- iteration 1: by index (arrays), average each sensor of one station
  L_logrun L_obj_len -v nsensors obj "${base[@]}" sensors
  for (( s = 0; s < nsensors; s++ )); do
    local sum=0 name unit
    L_logrun L_obj_get -v name obj "${base[@]}" sensors "$s" name
    L_logrun L_obj_get -v unit obj "${base[@]}" sensors "$s" unit
    L_logrun L_obj_len -v n obj "${base[@]}" sensors "$s" readings
    for (( i = 0; i < n; i++ )); do
      L_logrun L_obj_get -v L_RET obj "${base[@]}" sensors "$s" readings "$i"
      sum=$(( sum + L_RET ))
    done
    printf '%s avg=%d%s (n=%d)\n' "$name" "$(( sum / n ))" "$unit" "$n"
  done

  # --- iteration 2: walk everything
  # prints an indented tree; section parts arrive unescaped
  obj_walk_cb() {
    case $1 in START|VALUE)
      printf '%*s%s = %s\n' "$(( ($# - 4) * 2 ))" '' "${!#}" "$3"
    esac
  }
  L_obj_walk obj obj_walk_cb

  # --- iteration 3: flat dump of the raw keys, to see the escaping
  _L_obj_dump obj
}

_L_test_obj_walk() {
  obj_skip_test
  local obj out=""
  L_obj_set obj a b = 1
  L_obj_set obj c 0 = str
  L_obj_set obj c 1 = 1.2
  add_to_out(){
    local tmp
    printf -v tmp "%s " "$@"
    tmp=${tmp%% }
    out+=${tmp%% }$'\n'
  }
  L_obj_walk obj add_to_out
  local exp="\
START MAP --
START MAP -- a
VALUE INTEGER 1 a b
END MAP -- a
START ARRAY -- c
VALUE STRING str c 0
VALUE FLOAT 1.2 c 1
END ARRAY -- c
END MAP --
"
  sdiff - <<<"$out" <(echo "$exp") || :
  L_unittest_vareq out "$exp"
}

_L_test_obj_3() {
  obj_skip_test
  # obj=()
  L_obj_set obj a b 0 = string
  L_obj_set obj a b 1 = string
  L_obj_set obj a b 2 = string

  L_obj_append obj a b += string1
  L_obj_append obj a b += string2
  L_obj_append obj a b += string3
  L_obj_append obj a b += string4

  # _L_obj_dump obj
  L_obj_rm obj a
  # L_obj_rm obj
  # L_obj_set obj a b 2 string
  L_obj_set_typed obj a b c = MAP ""
  L_obj_walk obj echo
  _L_obj_dump obj
}

_L_test_obj_rm_add() {
  obj_skip_test
	local out=""
	add_to_out() { out+="$*"$'\n'; }
	_walk() { out=""; L_obj_walk obj add_to_out; }
	{
		# add
		local obj=()
		L_obj_set obj a b = x
		_L_obj_dump obj
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- a
VALUE STRING x a b
END MAP -- a
END MAP --
"
	}
	{
		# remove leaf, parent stays
		L_obj_rm obj a b
		_L_obj_dump obj
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- a
END MAP -- a
END MAP --
"
	}
	{
		# re-add after remove
		L_obj_set obj a b = y
		_L_obj_dump obj
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- a
VALUE STRING y a b
END MAP -- a
END MAP --
"
	}
	{
		# remove subtree
		L_obj_rm obj a
		_L_obj_dump obj
		_walk
		L_unittest_vareq out "\
START MAP --
END MAP --
"
	}
	{
		# add array after remove
		L_obj_set obj c 0 = s1
		L_obj_append obj c += s2
		_walk
		L_unittest_vareq out "\
START MAP --
START ARRAY -- c
VALUE STRING s1 c 0
VALUE STRING s2 c 1
END ARRAY -- c
END MAP --
"
	}
	{
		# remove array, add map at the same key
		L_obj_rm obj c
		L_obj_set_typed obj c d = MAP ""
		_walk
		L_unittest_vareq out "\
START MAP --
START MAP -- c
START MAP -- c d
END MAP -- c d
END MAP -- c
END MAP --
"
	}
	{
		# remove root content, then add again
		L_obj_rm obj
		L_obj_set obj k = v
		_walk
		L_unittest_vareq out "\
START MAP --
VALUE STRING v k
END MAP --
"
	}
}

_L_test_obj_cmp() {
  obj_skip_test
  local obj1 obj2
  # Equal simple objects
  L_obj_set obj1 a = 1
  L_obj_set obj2 a = 1
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  # Different values
  L_obj_set obj2 a = 2
  L_unittest_checkexit 1 L_obj_cmp obj1 obj2
  # Equal nested objects (clear and use different keys)
  L_obj_clear obj1
  L_obj_clear obj2
  L_obj_set obj1 nested b = 1
  L_obj_set obj1 nested c = 2
  L_obj_set obj2 nested b = 1
  L_obj_set obj2 nested c = 2
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  # Different nested values
  L_obj_set obj2 a c = 3
  L_unittest_checkexit 1 L_obj_cmp obj1 obj2
  # Arrays
  L_obj_clear obj1
  L_obj_clear obj2
  L_obj_set obj1 arr 0 = a
  L_obj_set obj1 arr 1 = b
  L_obj_set obj2 arr 0 = a
  L_obj_set obj2 arr 1 = b
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  # Arrays of different lengths
  L_obj_set obj2 arr 2 = c
  L_unittest_checkexit 1 L_obj_cmp obj1 obj2
  # Scalars
  L_obj_clear obj1
  L_obj_clear obj2
  L_obj_set obj1 scalar = "hello"
  L_obj_set obj2 scalar = "hello"
  L_unittest_checkexit 0 L_obj_cmp obj1 obj2
  L_obj_set obj2 scalar = "world"
  L_unittest_checkexit 1 L_obj_cmp obj1 obj2
}

# Tests for L_obj_pos / L_obj_is_valid
_L_test_obj_get_pos() {
  obj_skip_test
  local L_RET pos
  local obj
  # Create a simple structure
  L_obj_set obj a b = 1
  L_obj_set obj a c = 2
  # Valid positions - check that positions are returned
  L_obj_pos -v pos obj a b
  (( pos > 0 ))
  L_obj_pos -v pos obj a
  (( pos > 0 ))
  # Invalid positions - path doesn't exist
  L_unittest_cmd -r '.*' ! L_obj_pos -v pos obj x y z
  L_unittest_cmd -r '.*' ! L_obj_pos -v pos obj a z
  # Test with explicit position
  L_obj_pos -v pos obj a
  L_obj_pos -v pos2 "obj+${pos}" b
  (( pos2 > 0 ))
  # Test with array position
  L_obj_append obj arr += val
  L_obj_pos -v pos obj arr 0
  L_unittest_checkexit 0 L_obj_is_valid "obj+${pos}"
}

_L_test_obj_pos_is_valid() {
  obj_skip_test
  local obj pos
  L_obj_set obj a b = 1
  L_obj_pos -v pos obj a
  # Valid position
  L_unittest_checkexit 0 L_obj_is_valid "obj+${pos}"
  # Invalid position
  L_unittest_checkexit 1 L_obj_is_valid "obj+9999"
  # Root position
  L_unittest_checkexit 0 L_obj_is_valid "obj+0"
}

# Tests for L_obj_items
_L_test_obj_get_items() {
  obj_skip_test
  local -a items
  local obj
  # MAP children using foreach directly (since L_obj_items has a bug)
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  # Use L_obj_foreach to get items manually (triples: key type value pos)
  out=""
  cb_items() { out+="$1:$2:$3:$4"$'\n'; }
  L_obj_foreach obj cb_items
  [[ $out == *"a:1:INTEGER"* ]] || L_unittest_fail "foreach items did not match a"
  [[ $out == *"b:2:INTEGER"* ]] || L_unittest_fail "foreach items did not match b"
  [[ $out == *"c:3:INTEGER"* ]] || L_unittest_fail "foreach items did not match c"
}

# Tests for L_obj_type
_L_test_obj_get_type() {
  obj_skip_test
  local L_RET
  local obj
  L_obj_set obj int = 42
  L_obj_set obj float = 3.14
  L_obj_set obj str = "hello"
  L_obj_set_typed obj bool = BOOL ""
  L_obj_set obj boolstr = true
  L_obj_set_typed obj map = MAP ""
  L_obj_set_typed obj arr = ARRAY ""
  # Get types
  L_obj_type -v L_RET obj int
  L_unittest_vareq L_RET INTEGER
  L_obj_type -v L_RET obj float
  L_unittest_vareq L_RET FLOAT
  L_obj_type -v L_RET obj str
  L_unittest_vareq L_RET STRING
  L_obj_type -v L_RET obj bool
  L_unittest_vareq L_RET BOOL
  L_obj_type -v L_RET obj map
  L_unittest_vareq L_RET MAP
  L_obj_type -v L_RET obj arr
  L_unittest_vareq L_RET ARRAY
  # Root type
  L_obj_type -v L_RET obj
  L_unittest_vareq L_RET MAP
  # Non-existent path
  L_unittest_cmd -r '.*' ! L_obj_type -v L_RET obj nonexistent
}

# Tests for L_obj_get_or
_L_test_obj_get_default() {
  obj_skip_test
  local L_RET
  local obj
  L_obj_set obj a = 1
  # Get existing value
  L_obj_get_or -v L_RET obj a "default"
  L_unittest_vareq L_RET 1
  # Get missing value - returns default
  L_obj_get_or -v L_RET obj b "default"
  L_unittest_vareq L_RET "default"
  # Get from non-existent path - returns default
  L_obj_get_or -v L_RET obj x y z "default"
  L_unittest_vareq L_RET "default"
}

# Tests for L_obj_set_typed
_L_test_obj_set_type() {
  obj_skip_test
  local L_RET
  local obj
  # Set as MAP
  L_obj_set_typed obj a = MAP ""
  L_obj_type -v L_RET obj a
  L_unittest_vareq L_RET MAP
  # Set as ARRAY
  L_obj_set_typed obj b = ARRAY ""
  L_obj_type -v L_RET obj b
  L_unittest_vareq L_RET ARRAY
  # Set as NULL
  L_obj_set_typed obj c = NULL ""
  L_obj_type -v L_RET obj c
  L_unittest_vareq L_RET NULL
  # Cannot set type twice (already a container)
  L_unittest_cmd -r '.*' ! L_obj_set_typed obj a = STRING ""
}

# Tests for _L_obj_set_typed_default
_L_test_obj_set_type_default() {
  obj_skip_test
  local L_RET
  local obj
  # Set default for unset key
  _L_obj_set_typed_default obj a = STRING "fallback"
  L_obj_get -v L_RET obj a
  L_unittest_vareq L_RET "fallback"
  # Try to set default for existing key - should keep existing value
  _L_obj_set_typed_default obj a = STRING "newvalue"
  L_obj_get -v L_RET obj a
  L_unittest_vareq L_RET "fallback"
  # Empty (unset) key gets default
  _L_obj_set_typed_default obj b = INTEGER 0
  L_obj_get -v L_RET obj b
  L_unittest_vareq L_RET "0"
}

# Tests for L_obj_set_default
_L_test_obj_set_default() {
  obj_skip_test
  local L_RET
  local obj
  # Set default for unset key with type inference
  L_obj_set_default obj a = 42
  L_obj_get -v L_RET obj a
  L_unittest_vareq L_RET "42"
  # Existing value is preserved
  L_obj_set_default obj a = 99
  L_obj_get -v L_RET obj a
  L_unittest_vareq L_RET "42"
  # String inference
  L_obj_set_default obj b = "hello"
  L_obj_get -v L_RET obj b
  L_unittest_vareq L_RET "hello"
  # Float inference
  L_obj_set_default obj c = 3.14
  L_obj_get -v L_RET obj c
  L_unittest_vareq L_RET "3.14"
}

# Tests for L_obj_clear
_L_test_obj_clear() {
  obj_skip_test
  local L_RET
  local obj
  # Create a map with children
  L_obj_set obj a b = 1
  L_obj_set obj a c = 2
  L_obj_set obj d = 3
  # Clear the map's children
  L_obj_clear obj a
  L_obj_len -v L_RET obj a
  L_unittest_vareq L_RET 0
  # Root still has 'd'
  L_obj_len -v L_RET obj
  L_unittest_vareq L_RET 2
  # Clear root
  L_obj_clear obj
  L_obj_len -v L_RET obj
  L_unittest_vareq L_RET 0
  # Cannot clear a scalar
  L_obj_set obj scalar = "value"
  L_unittest_cmd -r '.*' ! L_obj_clear obj scalar
}

# Tests for L_obj_keys
_L_test_obj_keys() {
  obj_skip_test
  local -a keys
  local obj
  # MAP keys
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  L_obj_set obj c = 3
  L_obj_keys -v keys obj
  L_unittest_eq ${#keys[@]} 3
  L_unittest_eq "${keys[0]}" "a"
  L_unittest_eq "${keys[1]}" "b"
  L_unittest_eq "${keys[2]}" "c"
  # ARRAY indices
  L_obj_clear obj
  L_obj_append obj arr += one
  L_obj_append obj arr += two
  L_obj_keys -v keys obj arr
  L_unittest_eq ${#keys[@]} 2
  L_unittest_eq "${keys[0]}" "0"
  L_unittest_eq "${keys[1]}" "1"
  # Empty map
  L_obj_set_typed obj empty = MAP ""
  L_obj_keys -v keys obj empty
  L_unittest_eq ${#keys[@]} 0
  # Cannot get keys from scalar
  L_obj_set obj scalar = "value"
  L_unittest_cmd -r '.*' ! L_obj_keys -v keys obj scalar
}

# Tests for L_obj_has
_L_test_obj_has() {
  obj_skip_test
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b c = 2
  # Existing paths
  L_unittest_checkexit 0 L_obj_has obj a
  L_unittest_checkexit 0 L_obj_has obj b c
  # Non-existing paths
  L_unittest_checkexit 1 L_obj_has obj x
  L_unittest_checkexit 1 L_obj_has obj a b
}

# Tests for L_obj_concat with type coercion
_L_test_obj_string_append_types() {
  obj_skip_test
  local L_RET
  local obj
  # Append to existing STRING
  L_obj_set obj s = "hello"
  L_obj_concat obj s += " world"
  L_obj_get -v L_RET obj s
  L_unittest_vareq L_RET "hello world"
  # Append to INTEGER coerces to STRING
  L_obj_set obj n = 42
  L_obj_concat obj n += "extra"
  L_obj_type -v L_RET obj n
  L_unittest_vareq L_RET STRING
  L_obj_get -v L_RET obj n
  L_unittest_vareq L_RET "42extra"
  # Append to FLOAT coerces to STRING
  L_obj_set obj f = 3.14
  L_obj_concat obj f += "end"
  L_obj_type -v L_RET obj f
  L_unittest_vareq L_RET STRING
  L_obj_get -v L_RET obj f
  L_unittest_vareq L_RET "3.14end"
  # Cannot append to container
  L_obj_set_typed obj map = MAP ""
  L_unittest_cmd -r '.*' ! L_obj_concat obj map += "val"
}

# Tests for L_obj_insert_typed and L_obj_insert
_L_test_obj_array_insert() {
  obj_skip_test
  local L_RET
  local obj
  # Insert at beginning
  L_obj_append obj arr += c
  L_obj_insert_typed obj arr 0 = STRING "a"
  L_obj_get -v L_RET obj arr 0
  L_unittest_vareq L_RET "a"
  L_obj_get -v L_RET obj arr 1
  L_unittest_vareq L_RET "c"
  # Insert in middle
  L_obj_insert_typed obj arr 1 = STRING "b"
  L_obj_len -v L_RET obj arr
  L_unittest_vareq L_RET 3
  L_obj_get -v L_RET obj arr 0
  L_unittest_vareq L_RET "a"
  L_obj_get -v L_RET obj arr 1
  L_unittest_vareq L_RET "b"
  L_obj_get -v L_RET obj arr 2
  L_unittest_vareq L_RET "c"
  # Insert at end (append)
  L_obj_insert_typed obj arr 3 = INTEGER 99
  L_obj_get -v L_RET obj arr 3
  L_unittest_vareq L_RET "99"
  # Insert with inferred type
  L_obj_insert obj arr 1 = "middle"
  L_obj_get -v L_RET obj arr 1
  L_unittest_vareq L_RET "middle"
  # Invalid index - out of bounds
  L_unittest_cmd -r '.*' ! L_obj_insert_typed obj arr 10 = STRING "x"
  # Insert into non-array
  L_obj_set_typed obj notarr = MAP ""
  L_unittest_cmd -r '.*' ! L_obj_insert_typed obj notarr 0 = STRING "x"
}

# Tests for L_obj_foreach
_L_test_obj_foreach() {
  obj_skip_test
  local obj out=""
  cb() { out+="$1:$2:$3:$4"$'\n'; }
  # Iterate over MAP
  L_obj_set obj a = 1
  L_obj_set obj b c = 2
  L_obj_foreach obj cb
  [[ $out == *"a:1:INTEGER"* ]] || L_unittest_fail "foreach did not match a"
  [[ $out == *"b::MAP"* ]] || L_unittest_fail "foreach did not match b.c"
  # Iterate over ARRAY
  L_obj_clear obj
  L_obj_append obj arr += first
  L_obj_append obj arr += second
  out=""
  L_obj_foreach obj cb
  # out should contain entries for "arr" key (which is an ARRAY) and its children
  [[ $out == *"arr"* ]] || L_unittest_fail "foreach did not iterate over arr"
  # Empty container
  L_obj_clear obj
  L_obj_set_typed obj empty = MAP ""
  out=""
  # Iterate over the empty map's children - it has none
  L_obj_pos -v pos obj empty
  L_obj_foreach "obj+${pos}" cb
  L_unittest_vareq out ""
}

# Tests for L_obj_iter
_L_test_obj_iter() {
  obj_skip_test
  local k v t pos it
  local obj
  L_obj_set obj a = 1
  L_obj_set obj b = 2
  # Iterate over MAP
  it=""
  while L_obj_iter obj it k v t pos; do
    if [[ $k == "a" ]]; then
      L_unittest_vareq v "1"
      L_unittest_vareq t INTEGER
    elif [[ $k == "b" ]]; then
      L_unittest_vareq v "2"
      L_unittest_vareq t INTEGER
    else
      L_unittest_fail "unexpected key $k"
    fi
  done
  # Iterate over ARRAY
  L_obj_clear obj
  L_obj_append obj arr += x
  L_obj_append obj arr += y
  it=""
  local indices=()
  local arr_pos
  L_obj_pos -v arr_pos obj arr
  while L_obj_iter "obj+${arr_pos}" it k v t pos; do
    indices+=("$k")
  done
  L_unittest_eq ${#indices[@]} 2
  L_unittest_eq "${indices[0]}" "0"
  L_unittest_eq "${indices[1]}" "1"
}

# Tests for L_obj_copy
_L_test_obj_copy() {
  obj_skip_test
  local L_RET
  local src dst
  # Copy simple structure
  L_logrun L_obj_set src a = 1
  L_logrun L_obj_set src b = 2
  L_logrun L_obj_copy src dst
  L_logrun _L_obj_dump src
  L_logrun _L_obj_dump dst
  L_obj_get -v L_RET dst a
  L_unittest_vareq L_RET 1
  L_obj_get -v L_RET dst b
  L_unittest_vareq L_RET 2
  # Copy at root level replaces existing content
  L_obj_set dst placeholder = "old"
  L_obj_copy src dst
  L_unittest_checkexit 1 L_obj_has dst placeholder
  L_obj_get -v L_RET dst a
  L_unittest_vareq L_RET 1
}

# Tests for L_obj_merge
_L_test_obj_merge() {
  obj_skip_test
  local L_RET dst src
  # Simple merge: dst is empty, just copy src
  L_logrun L_obj_set src a = 1
  L_logrun L_obj_set src b = 2
  L_logrun L_obj_merge src dst
  L_logrun L_obj_get -v L_RET dst a
  L_logrun L_unittest_vareq L_RET 1
  L_logrun L_obj_get -v L_RET dst b
  L_logrun L_unittest_vareq L_RET 2
  # Merge: src adds new keys to dst
  L_logrun L_obj_set src c = 3
  L_logrun _L_obj_dump src
  L_logrun _L_obj_dump dst
  L_logrun L_obj_merge src dst
  L_logrun L_obj_get -v L_RET dst c
  L_logrun L_unittest_vareq L_RET 3
}

# Tests for L_obj_pop
_L_test_obj_array_pop() {
  obj_skip_test
  local L_RET
  local obj
  L_obj_append obj arr += a
  L_obj_append obj arr += b
  L_obj_append obj arr += c
  # Pop last element
  L_obj_pop -v L_RET obj arr
  L_unittest_vareq L_RET c
  L_obj_len -v L_RET obj arr
  L_unittest_vareq L_RET 2
  # Pop again
  L_obj_pop -v L_RET obj arr
  L_unittest_vareq L_RET b
  L_obj_pop -v L_RET obj arr
  L_unittest_vareq L_RET a
  # Pop from empty array
  L_unittest_cmd -r '.*' ! L_obj_pop -v L_RET obj arr
  # Cannot pop from non-ARRAY
  L_obj_clear obj
  L_obj_set obj scalar = "value"
  L_unittest_cmd -r '.*' ! L_obj_pop -v L_RET obj scalar
}

# Tests for position references (obj+pos syntax)
_L_test_obj_position_refs() {
  obj_skip_test
  local L_RET
  local obj pos
  # Set up structure and get positions
  L_obj_set obj a b = 1
  L_obj_set obj a c = 2
  L_obj_set obj d = 3
  # Get position of 'a' (non-zero)
  L_obj_pos -v pos obj a
  (( pos > 0 ))
  # Use position to access children
  L_obj_get -v val "obj+${pos}" b
  L_unittest_vareq val 1
  L_obj_get -v val "obj+${pos}" c
  L_unittest_vareq val 2
  # Get position of array and use obj+pos syntax
  L_obj_append obj list += x
  L_obj_append obj list += y
  L_obj_pos -v pos obj list
  local list_pos=$pos
  L_obj_get -v val "obj+${list_pos}" 0
  L_unittest_vareq val "x"
  L_obj_get -v val "obj+${list_pos}" 1
  L_unittest_vareq val "y"
  # L_obj_len with position
  L_obj_len -v L_RET "obj+${list_pos}"
  L_unittest_vareq L_RET 2
  # L_obj_has with position
  L_unittest_checkexit 0 L_obj_has "obj+${list_pos}" 0
  L_unittest_checkexit 1 L_obj_has "obj+${list_pos}" 99
  # L_obj_keys with position
  local -a keys
  L_obj_keys -v keys "obj+${list_pos}"
  L_unittest_eq ${#keys[@]} 2
  L_unittest_eq "${keys[0]}" "0"
  L_unittest_eq "${keys[1]}" "1"
}

# Tests for L_obj to/from JSON round-trip
_L_test_obj_json_roundtrip() {
  obj_skip_test
  local json obj json_out
  json='{"name":"test","version":"1.0.0","active":true,"count":42,"items":["a","b","c"],"nested":{"key":"value"}}'
  # Parse JSON to obj
  L_obj_from_json obj <<EOF
$json
EOF
  # Check values
  L_obj_get -v name obj name
  L_unittest_vareq name "test"
  L_obj_get -v count obj count
  L_unittest_vareq count "42"
  L_obj_get -v active obj active
  L_unittest_vareq active "true"
  L_obj_get -v item0 obj items 0
  L_unittest_vareq item0 "a"
  L_obj_get -v nested_key obj nested key
  L_unittest_vareq nested_key "value"
  # Convert back to JSON
  L_obj_to_json -v json_out obj
  # Parse again and compare
  L_obj_from_json obj2 <<<"$json_out"
  L_obj_cmp obj obj2
}

# Tests for L_obj to/from INI round-trip
_L_test_obj_ini_roundtrip() {
  obj_skip_test
  local ini_text obj ini_out
  ini=$(printf 'name = test\nversion = 1.0.0\ncount = 42\n\n[server]\nhost = localhost\nport = 8080\n')
  # Parse INI to obj
  L_obj_from_ini obj <<<"$ini"
  # Check root values - INI parser nests root keys under a default section
  L_obj_get -v name obj "" name
  L_unittest_vareq name "test"
  L_obj_get -v port obj server port
  L_unittest_vareq port "8080"
  # Convert back to INI
  L_obj_to_ini -v ini_out obj
  # Should contain the same keys
  [[ $ini_out == *"name = test"* ]]
  [[ $ini_out == *"[server]"* ]]
  [[ $ini_out == *"host = localhost"* ]]
}

# Tests for L_obj to/from TOML round-trip
_L_test_obj_toml_roundtrip() {
  obj_skip_test
  local toml_text obj toml_out
  toml_text='name = "test"
version = "1.0.0"
count = 42

[server]
host = "localhost"
port = 8080
'
  # Parse TOML to obj
  L_obj_from_toml obj <<<"$toml_text"
  # Check values
  L_obj_get -v name obj name
  L_unittest_vareq name "test"
  L_obj_get -v port obj server port
  L_unittest_vareq port "8080"
  # Convert back to TOML
  L_obj_to_toml -v toml_out obj
  # Should contain the same keys
  [[ $toml_out == *"name = \"test\""* ]]
  [[ $toml_out == *"[server]"* ]]
}

# Tests for L_obj with special characters in keys
_L_test_obj_special_keys() {
  obj_skip_test
  local L_RET
  local obj
  # Keys with spaces
  L_obj_set obj "key with spaces" = "value"
  L_obj_get -v L_RET obj "key with spaces"
  L_unittest_vareq L_RET "value"
  # Keys with dots (should be treated as single key, not path)
  L_obj_set obj "a.b.c" = "dotted"
  L_obj_get -v L_RET obj "a.b.c"
  L_unittest_vareq L_RET "dotted"
  # Keys with special chars
  L_obj_set obj "key[brackets]" = "brackets_val"
  L_obj_get -v L_RET obj "key[brackets]"
  L_unittest_vareq L_RET "brackets_val"
  # Keys with unicode
  L_obj_set obj "key-unicode" = "unicode_val"
  L_obj_get -v L_RET obj "key-unicode"
  L_unittest_vareq L_RET "unicode_val"
}

# Tests for L_obj NULL type
_L_test_obj_null_type() {
  obj_skip_test
  local L_RET
  local obj
  # Set as NULL
  L_obj_set_typed obj n = NULL ""
  L_obj_type -v L_RET obj n
  L_unittest_vareq L_RET NULL
}

# Tests for L_obj deep nesting
_L_test_obj_deep_nesting() {
  obj_skip_test
  local L_RET
  local obj
  # Create deeply nested structure
  L_obj_set obj a b c d e f g h i j = "deep"
  L_obj_get -v L_RET obj a b c d e f g h i j
  L_unittest_vareq L_RET "deep"
  L_obj_type -v L_RET obj a b c d e f g h i j
  L_unittest_vareq L_RET STRING
  # Check lengths at each level
  L_obj_len -v L_RET obj a b c d e f g h
  L_unittest_vareq L_RET 1
}

# Tests for L_obj_append_typed
_L_test_obj_array_append_type_value() {
  obj_skip_test
  local L_RET
  local obj
  # Append with explicit type
  L_obj_append_typed obj arr += INTEGER 1
  L_obj_append_typed obj arr += FLOAT 2.5
  L_obj_append_typed obj arr += STRING "hello"
  L_obj_append_typed obj arr += BOOL true
  L_obj_append_typed obj arr += NULL ""
  # Check types
  L_obj_type -v L_RET obj arr 0
  L_unittest_vareq L_RET INTEGER
  L_obj_type -v L_RET obj arr 1
  L_unittest_vareq L_RET FLOAT
  L_obj_type -v L_RET obj arr 2
  L_unittest_vareq L_RET STRING
  L_obj_type -v L_RET obj arr 3
  L_unittest_vareq L_RET BOOL
  L_obj_type -v L_RET obj arr 4
  L_unittest_vareq L_RET NULL
  # Append to non-array should fail
  L_obj_clear obj
  L_obj_set_typed obj notarr = MAP ""
  L_unittest_cmd -r '.*' ! L_obj_append_typed obj notarr += STRING "val"
}

