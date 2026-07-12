#!/usr/bin/env bash

_L_test_argskeywords() {
	{
		local a b
		L_unittest_cmd -r "missing 2 required positional arguments: a b" ! L_argskeywords a b --
		L_unittest_cmd -r "missing 1 required positional arguments: b" ! L_argskeywords a b -- 1
		L_unittest_cmd -c L_argskeywords a=1 b=2 --
		L_unittest_eq "$a $b" "1 2"
		L_unittest_cmd -c L_argskeywords a b=4 -- 3
		L_unittest_eq "$a $b" "3 4"
		L_unittest_cmd -r "missing 1 required positional arguments: a" ! L_argskeywords a b=2 --
		L_unittest_cmd -r "missing 1 required positional arguments: c" ! L_argskeywords b=2 c --
		L_unittest_cmd -r "separator argument is missing" ! L_argskeywords a b
		L_unittest_cmd -r "missing 1 required positional arguments: b" ! L_argskeywords a=1 b --
	}
	{
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either @ keyword_only -- either=Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either @ keyword_only -- Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		#
		L_unittest_cmd -c ! L_argskeywords either @ keyword_only -- Frank Dean
		L_unittest_cmd -c ! L_argskeywords either @ keyword_only -- Frank
	}
	{
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- either=Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- Frank keyword_only=Dean
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "Dean"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- Frank
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "def2"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 --
		L_unittest_eq "$either" "def1"
		L_unittest_eq "$keyword_only" "def2"
		local either="" keyword_only=""
		L_unittest_cmd -c L_argskeywords either=def1 @ keyword_only=def2 -- either=Frank
		L_unittest_eq "$either" "Frank"
		L_unittest_eq "$keyword_only" "def2"
	}
	{
		local positional_only="" either=""
		L_unittest_cmd -c L_argskeywords positional_only / either -- Frank either=Dean
		L_unittest_eq "$positional_only" "Frank"
		L_unittest_eq "$either" "Dean"
		local positional_only="" either=""
		L_unittest_cmd -c L_argskeywords positional_only / either -- Frank Dean
		L_unittest_eq "$positional_only" "Frank"
		L_unittest_eq "$either" "Dean"
		#
		L_unittest_cmd -c ! L_argskeywords positional_only / either -- positional_only=Frank either=Dean
	}
	{
		local member1="" member2="" member3=""
		L_unittest_cmd -c L_argskeywords @ member1 member2 member3 -- member1=Frank member2=Dean member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		local member1="" member2="" member3=""
		L_unittest_cmd -c L_argskeywords @ member1 member2 member3 -- member1=Frank member3=Dean member2=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Sammy"
		L_unittest_eq "$member3" "Dean"
		#
		L_unittest_cmd -c ! L_argskeywords @ member1 member2 member3 -- Frank Dean Sammy
		L_unittest_cmd -c ! L_argskeywords @ member1 member2 member3 -- member1=Frank member2=Dean member3=Sammy member4=John
		L_unittest_cmd -c ! L_argskeywords @ member1 member2 member3 -- Frank member3=Dean member2=Sammy
	}
	{
		local member1="" member2="" member3=""
		L_unittest_cmd -c L_argskeywords member1 member2 member3 / -- Frank Dean Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		#
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- member1=Frank member2=Dean member3=Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- Frank Dean Sammy John
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- member1=Frank member2=Dean member3=Sammy member4=John
		L_unittest_cmd -c ! L_argskeywords member1 member2 member3 / -- Frank member3=Dean member2=Sammy
	}
	{
		local member1="" member2="" member3="" args=()
		L_unittest_cmd -c L_argskeywords member1 member2 @args member3 -- Frank member2=Dean member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		L_unittest_arreq args
		local member1="" member2="" member3="" args=()
		L_unittest_cmd -c L_argskeywords member1 member2 @args member3 -- member1=Frank member2=Dean member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		L_unittest_arreq args
		#
		L_unittest_cmd -c ! L_argskeywords member1 member2 @args member3 -- member1=Frank Dean member3=Sammy
		#
		local member1="" member2="" member3="" args=()
		L_unittest_cmd -c L_argskeywords member1 member2 @args member3 -- Frank Dean Peter Joey member3=Sammy
		L_unittest_eq "$member1" "Frank"
		L_unittest_eq "$member2" "Dean"
		L_unittest_eq "$member3" "Sammy"
		L_unittest_arreq args Peter Joey
	}
	L_unittest_cmd -c ! L_argskeywords @ --
	{
		local member1="" member2="" member3="" member4=""
		L_unittest_cmd -c L_argskeywords member1 member2 / member3 @ member4 -- Frank Dean member3=Sammy member4=Joey
		L_unittest_eq "$member1 $member2 $member3 $member4" "Frank Dean Sammy Joey"
		L_unittest_cmd -c ! L_argskeywords member1 member2 @ member3 / member4 -- Frank Dean member3=Sammy member4=Joey
	}
	{
		L_unittest_cmd -c ! L_argskeywords member1 member2 @ / member3 -- Frank Dean member3=Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 / @ member3 -- Frank Dean Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 / @ member3 -- Frank member2=Dean member3=Sammy
		L_unittest_cmd -c ! L_argskeywords member1 member2 / @ member3 --
	}
	L_unittest_cmd -c ! L_argskeywords member1 member2 @args @ --
	L_unittest_cmd -c ! L_argskeywords member1 member2 @ @args --
	{
		local fn ln
		L_unittest_cmd -c L_argskeywords fn ln / -- Frank Sinatra
		L_unittest_eq "$fn $ln" "Frank Sinatra"
		L_unittest_cmd -c ! L_argskeywords fn ln / -- fn=Frank ln=Sinatra
	}
	{
		local args
		L_unittest_cmd -c L_argskeywords @args -- 1 2 3
		L_unittest_arreq args 1 2 3
		local integers
		L_unittest_cmd -c L_argskeywords @integers -- 1  2 3
		L_unittest_arreq integers 1 2 3
	}
	if ((L_HAS_ASSOCIATIVE_ARRAY)); then
		{
			local a b args IFS=" "
			local -A kwargs=()
			L_unittest_cmd -c L_argskeywords a b @args @@kwargs -- 1 2 a b c c=3 d=4
			L_unittest_eq "$a $b" "1 2"
			L_unittest_arreq args a b c
			L_unittest_eq "${kwargs[c]}" "3"
			L_unittest_eq "${kwargs[d]}" "4"
			L_unittest_cmd -c ! L_argskeywords a b @@kwargs @args --
		}
	fi
	{
		local map tmp
		L_unittest_cmd -c L_argskeywords -M @@map -- a=Real b=Python c=Is d=Great e="!"
		L_map_get -v tmp map a
		L_unittest_eq "$tmp" "Real"
		L_map_get -v tmp map b
		L_unittest_eq "$tmp" "Python"
		L_map_get -v tmp map c
		L_unittest_eq "$tmp" "Is"
		L_map_get -v tmp map d
		L_unittest_eq "$tmp" "Great"
		L_map_get -v tmp map e
		L_unittest_eq "$tmp" "!"
	}
	{
		local a b args map tmp
		L_unittest_cmd -c L_argskeywords -M a b @args @@map -- 1 2 a b c c=3 d=4
		L_unittest_eq "$a $b" "1 2"
		L_unittest_arreq args a b c
		L_map_items -v tmp map
		L_unittest_arreq tmp c 3 d 4
		L_unittest_cmd -c ! L_argskeywords a b @@map @args --
	}
	{
		# Test -c option (subcall) with auto-localizing variables
		local res=""
		_L_helper_func() {
			L_argskeywords -c 'res="$start-$stop-$step"' start stop step=1 -- "$@"
		}
		L_unittest_cmd -c _L_helper_func 1 5 step=2
		L_unittest_eq "$res" "1-5-2"
		# Ensure variables start, stop, step did not leak to outer scope
		L_unittest_eq "${start:-}" ""
		L_unittest_eq "${stop:-}" ""
		L_unittest_eq "${step:-}" ""
	}
}

_L_test_argskeywords_kwargs_shadow() {
	if (( ! L_HAS_ASSOCIATIVE_ARRAY )); then
		L_unittest_skip "associative arrays not supported in this Bash version"
		return
	fi

	local start="parent_start" stop="parent_stop" step="parent_step"
	local -A kwargs=([parent_key]="parent_val")
	local callback_start="" callback_stop="" callback_step="" callback_kwargs_val="" callback_has_parent_key="no"

	_L_shadow_callback() {
		callback_start="$start"
		callback_stop="$stop"
		callback_step="$step"
		# Modify the localized variables inside callback
		start="modified_start"
		step="modified_step"
		callback_kwargs_val="${kwargs[extra_key]:-}"
		if [[ -n "${kwargs[parent_key]+x}" ]]; then
			callback_has_parent_key="yes"
		fi
		kwargs[extra_key]="modified_kwargs_val"
	}

	_L_helper_shadow() {
		L_argskeywords -c _L_shadow_callback start stop step=1 @@kwargs -- "$@"
	}

	L_unittest_cmd -c _L_helper_shadow 10 20 step=5 extra_key="arg_val"
	L_unittest_eq "$callback_start" "10"
	L_unittest_eq "$callback_stop" "20"
	L_unittest_eq "$callback_step" "5"
	L_unittest_eq "$callback_kwargs_val" "arg_val"
	L_unittest_eq "$callback_has_parent_key" "no"  # kwargs was fully localized, parent keys should not leak in

	# Verify parent scope remains completely unaffected
	L_unittest_eq "$start" "parent_start"
	L_unittest_eq "$stop" "parent_stop"
	L_unittest_eq "$step" "parent_step"
	L_unittest_eq "${kwargs[parent_key]}" "parent_val"
	L_unittest_eq "${kwargs[extra_key]:-}" ""      # Modified kwargs should not leak to parent
}
