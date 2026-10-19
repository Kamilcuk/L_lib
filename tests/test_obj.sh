###############################################################################
# @section obj
# Tests for L_obj functions.

_L_test_obj_1() {
  obj_skip_test
  local L_RET
  local obj
  {
    # # {"a":{"b":[1,2,3]}}
    L_obj_set_value obj a b 0 = 1
    L_obj_set_value obj a b 1 = 2
    L_obj_set_value obj a b 2 = 3
    L_obj_set_value obj a c = dead1
    L_obj_set_value obj a d = dead2
    L_obj_set_value obj a f = dead3
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
    L_obj_array_append_value obj a b += 4
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 4
    L_obj_array_append_value obj a b += 5
    L_obj_len_vL_RET obj a b
    L_unittest_vareq L_RET 5
  }
  {
    L_obj_string_append obj a f += dead
    L_obj_get_vL_RET obj a f
    L_unittest_vareq L_RET dead3dead
  }
  _L_obj_print_table obj
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
    L_obj_set_value obj stations "$station" name = "$station"
    for i in "${!sensors[@]}"; do
      L_obj_set_value obj stations "$station" sensors "$i" name = "${sensors[i]}"
      L_obj_set_value obj stations "$station" sensors "$i" unit = "${units[i]}"
    done
  done

  # simulate 5 sampling ticks; the first tick seeds readings.1, the rest append
  for tick in 1 2 3 4 5; do
    for station in "${stations[@]}"; do
      base=(stations "$station")
      for s in 0 1 2; do
        L_obj_array_append_value obj "${base[@]}" sensors "$s" readings += "$(( RANDOM % 100 ))"
      done
    done
    L_obj_set_value obj last_update = "$RANDOM"
  done

  _L_obj_print_table obj

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
  _L_obj_print_table obj
}

_L_test_obj_walk() {
  obj_skip_test
  local obj out=""
  L_obj_set_value obj a b = 1
  L_obj_set_value obj c 0 = str
  L_obj_set_value obj c 1 = 1.2
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
  L_obj_set_value obj a b 0 = string
  L_obj_set_value obj a b 1 = string
  L_obj_set_value obj a b 2 = string

  L_obj_array_append_value obj a b += string1
  L_obj_array_append_value obj a b += string2
  L_obj_array_append_value obj a b += string3
  L_obj_array_append_value obj a b += string4

  # _L_obj_print_table obj
  L_obj_rm obj a
  # L_obj_rm obj
  # L_obj_set_value obj a b 2 string
  L_obj_set_type obj a b c = MAP
  L_obj_walk obj echo
  _L_obj_print_table obj
}

_L_test_obj_rm_add() {
  obj_skip_test
	local out=""
	add_to_out() { out+="$*"$'\n'; }
	_walk() { out=""; L_obj_walk obj add_to_out; }
	{
		# add
		local obj=()
		L_obj_set_value obj a b = x
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
		L_obj_set_value obj a b = y
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
		_walk
		L_unittest_vareq out "\
START MAP --
END MAP --
"
	}
	{
		# add array after remove
		L_obj_set_value obj c 0 = s1
		L_obj_array_append_value obj c += s2
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
		L_obj_set_type obj c d = MAP
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
		L_obj_set_value obj k = v
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
  : todo write test for L_obj_cmp_obj
}

