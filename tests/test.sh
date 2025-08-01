#!/usr/bin/env bash

_L_test_color() {
	{
		L_color_enable
		L_unittest_eq "$L_RED" "$L_ANSI_RED"
		L_color_disable
		L_unittest_eq "$L_RED" ""
		L_color_detect
	}
}

_L_test_a_regex_match() {
	L_unittest_cmd L_regex_match "(a)" "^[(].*[)]$"
}

_L_test_basic() {
	{
		L_unittest_checkexit 0 L_isdigit 5
		L_unittest_checkexit 0 L_isdigit 1235567890
		L_unittest_checkexit 1 L_isdigit 1235567890a
		L_unittest_checkexit 1 L_isdigit x
	}
	{
		L_unittest_checkexit 0 L_is_float -1
		L_unittest_checkexit 0 L_is_float -1.
		L_unittest_checkexit 0 L_is_float -1.2
		L_unittest_checkexit 0 L_is_float -.2
		L_unittest_checkexit 0 L_is_float +1
		L_unittest_checkexit 0 L_is_float +1.
		L_unittest_checkexit 0 L_is_float +1.2
		L_unittest_checkexit 0 L_is_float +.2
		L_unittest_checkexit 0 L_is_float 1
		L_unittest_checkexit 0 L_is_float 1.
		L_unittest_checkexit 0 L_is_float 1.2
		L_unittest_checkexit 0 L_is_float .2
		L_unittest_checkexit 1 L_is_float -.
		L_unittest_checkexit 1 L_is_float abc
	}
	{
		unset a
		local a="declare -r a"
		L_unittest_checkexit 1 L_var_is_readonly a
		local -r b="declare b"
		L_unittest_checkexit 0 L_var_is_readonly b
	}
	if ((L_HAS_ASSOCIATIVE_ARRAY)); then
		unset c
		L_unittest_checkexit 1 L_var_is_associative c
		local -A c=(["declare -r c"]="declare -r c")
		L_unittest_checkexit 0 L_var_is_associative c
	fi
	{
		unset d
		L_unittest_checkexit 1 L_var_is_array d
		L_unittest_checkexit 1 L_var_is_notarray d
		local -a d=("declare -r d")
		L_unittest_checkexit 0 L_var_is_array d
		L_unittest_checkexit 1 L_var_is_notarray d
	}
	{
		unset e
		L_unittest_checkexit 1 L_var_is_exported e
		local e="declare -r e"
		L_unittest_checkexit 1 L_var_is_exported e
		export e
		L_unittest_checkexit 0 L_var_is_exported e
		unset e
	}
	{
		L_unittest_checkexit 1 L_var_is_set _L_variable
		local _L_variable
		if ((L_HAS_BASH4_0)); then
			# In bash 3.2 local sets the variable to empty. On newers it doesn't set.
			L_unittest_checkexit 1 L_var_is_set _L_variable
		fi
		_L_variable=
		L_unittest_checkexit 0 L_var_is_set _L_variable
		_L_variable=""
		L_unittest_checkexit 0 L_var_is_set _L_variable
		_L_variable="a"
		L_unittest_checkexit 0 L_var_is_set _L_variable
	}
	{
		L_unittest_checkexit 0 L_is_integer 1
		L_unittest_checkexit 0 L_is_integer 0
		L_unittest_checkexit 0 L_is_integer -1
		L_unittest_checkexit 0 L_is_integer +1
		L_unittest_checkexit 1 L_is_integer 1-
		L_unittest_checkexit 1 L_is_integer 1+
		L_unittest_checkexit 1 L_is_integer 1-2
		L_unittest_checkexit 1 L_is_integer 1+2
		L_unittest_checkexit 1 L_is_integer a
	}
	{
		L_unittest_checkexit 0 L_is_valid_variable_name a
		L_unittest_checkexit 0 L_is_valid_variable_name ab
		L_unittest_checkexit 0 L_is_valid_variable_name _ac
		L_unittest_checkexit 0 L_is_valid_variable_name _a9
		L_unittest_checkexit 1 L_is_valid_variable_name 9
		L_unittest_checkexit 1 L_is_valid_variable_name 9a
		L_unittest_checkexit 1 L_is_valid_variable_name a-
		L_unittest_checkexit 1 L_is_valid_variable_name -a
		L_unittest_checkexit 1 L_is_valid_variable_name "a "
		L_unittest_checkexit 1 L_is_valid_variable_name " a"
		L_unittest_checkexit 1 L_is_valid_variable_name " a "
		L_unittest_checkexit 1 L_is_valid_variable_name $'\x01a'
		# shellcheck disable=SC2016
		L_unittest_checkexit 1 L_is_valid_variable_name '$((a))'
		L_unittest_checkexit 1 L_is_valid_variable_name 'rm -rf'
		L_unittest_checkexit 1 L_is_valid_variable_name ''
	}
	{
		L_unittest_checkexit 0 L_is_valid_variable_or_array_element aa
		L_unittest_checkexit 0 L_is_valid_variable_or_array_element 'arr[elem]'
		L_unittest_checkexit 1 L_is_valid_variable_or_array_element 'arr[elem'
		L_unittest_checkexit 0 L_is_valid_variable_or_array_element 'arr[@#!@#[][32]13]'
		L_unittest_checkexit 1 L_is_valid_variable_or_array_element '1'
		L_unittest_checkexit 1 L_is_valid_variable_or_array_element 'arr[]'
	}
}

_L_test_a_handle_v() {
	{
		local i
		for i in L_handle_v_scalar L_handle_v_array; do
			return_123() { "$i" "$@"; }
			return_123_v() { return 123; }
			L_unittest_cmd -ce 123 return_123
			L_unittest_cmd -ce 123 return_123 --
			L_unittest_cmd -ce 123 return_123 a
			L_unittest_cmd -ce 123 return_123 -- a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va --
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a --
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -va -- a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a a
			unset a
			local a
			L_unittest_cmd -ce 123 return_123 -v a -- a
			unset a
		done
	}
	{
		wrapper() { set_scalar "$@"; echo "END"; }
		set_scalar() { L_handle_v_scalar "$@"; }
		set_scalar_v() { L_v=123; }
		L_unittest_cmd -co $'123\nEND' wrapper
		L_unittest_cmd -co $'123\nEND' wrapper --
		L_unittest_cmd -co $'123\nEND' wrapper a
		L_unittest_cmd -co $'123\nEND' wrapper -- a
		local a=""
		L_unittest_cmd -c set_scalar -va
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_scalar -v a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_scalar -va a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_scalar -v a a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_scalar -va -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
		local a=""
		L_unittest_cmd -c set_scalar -v a -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_notarray a
	}
	{
		wrapper_set_one() { set_one "$@"; echo "END"; }
		set_one() { L_handle_v_array "$@"; }
		set_one_v() { L_v=(123); }
		L_unittest_cmd -co $'123\nEND' wrapper_set_one
		L_unittest_cmd -co $'123\nEND' wrapper_set_one --
		L_unittest_cmd -co $'123\nEND' wrapper_set_one a
		L_unittest_cmd -co $'123\nEND' wrapper_set_one -- a
		local a=""
		L_unittest_cmd -c set_one -va
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -v a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -va a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -v a a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -va -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
		local a=""
		L_unittest_cmd -c set_one -v a -- a
		L_unittest_eq "$a" 123
		L_unittest_cmd -c L_var_is_array a
	}
	{
		wrapper() { set_arr "$@"; echo "END"; }
		set_arr() { L_handle_v_array "$@"; }
		set_arr_v() { L_v=(456 789); }
		L_unittest_cmd -co $'456\n789\nEND' wrapper
		L_unittest_cmd -co $'456\n789\nEND' wrapper --
		L_unittest_cmd -co $'456\n789\nEND' wrapper a
		L_unittest_cmd -co $'456\n789\nEND' wrapper -- a
		local a=""
		L_unittest_cmd -c set_arr -va a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -v a a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -va -- a
		L_unittest_arreq a 456 789
		local a=""
		L_unittest_cmd -c set_arr -v a -- a
		L_unittest_arreq a 456 789
	}
	unset -f set_arr set_one set_arr_v set_one_v return_123 return_123_v set_scalar set_scalar_v wrapper wrapper_set_one
}

_L_test_string() {
	local tmp IFS="!@#"
	if ((!L_HAS_BASH4_0)); then
		# Bash3.2 is not able to split "${@:2}" correctly when IFS does not contain space.
		local IFS=" "
	fi
	{
		L_rstrip -v tmp " a b  "
		L_unittest_eq "$tmp" " a b"
		L_rstrip -v tmp " a b"
		L_unittest_eq "$tmp" " a b"
		L_lstrip -v tmp " a b  "
		L_unittest_eq "$tmp" "a b  "
		L_lstrip -v tmp "a b  "
		L_unittest_eq "$tmp" "a b  "
	}
	{
		L_strip -v tmp " a b  "
		L_unittest_eq "$tmp" "a b"
		L_strip -v tmp " a b"
		L_unittest_eq "$tmp" "a b"
		L_strip -v tmp "a b    "
		L_unittest_eq "$tmp" "a b"
		L_strip -v tmp "a b"
		L_unittest_eq "$tmp" "a b"
	}
	{
			L_strupper -v tmp " a b  "
			L_unittest_eq "$tmp" " A B  "
			L_strlower -v tmp " A B  "
			L_unittest_eq "$tmp" " a b  "
			L_unittest_cmd -c L_strstr " a b  " "a b"
			L_unittest_cmd -c ! L_strstr " a b  " "a X"
			L_unittest_cmd -c L_strhash -v tmp "  a b "
			L_unittest_cmd -c L_is_integer "$tmp"
			L_unittest_cmd -c L_strhash_bash -v tmp "  a b "
			L_unittest_cmd -c L_is_integer "$tmp"
			L_capitalize -v tmp "abc"
			L_unittest_eq "$tmp" "Abc"
			L_capitalize -v tmp "ABC"
			L_unittest_eq "$tmp" "ABC"
			L_capitalize -v tmp ""
			L_unittest_eq "$tmp" ""
			L_uncapitalize -v tmp "abc"
			L_unittest_eq "$tmp" "abc"
			L_uncapitalize -v tmp "ABC"
			L_unittest_eq "$tmp" "aBC"
			L_uncapitalize -v tmp ""
			L_unittest_eq "$tmp" ""
	}
	{
		local i
		L_str_count -v i abca a
		L_unittest_vareq i 2
		L_str_count -v i abca x
		L_unittest_vareq i 0
	}
}

_L_test_list_functions() {
	local arr
	aaa_func1() { :; }
	aaa_func2() { :; }
	L_list_functions_with_prefix_removed -v arr aaa_
	L_sort arr
	L_unittest_arreq arr func1 func2
	aaa_() { :; }
	L_list_functions_with_prefix_removed -v arr aaa_
	L_unittest_arreq arr '' func1 func2
	unset aaa_func1 aaa_func2 aaa_
}

_L_test_exit_to_1null() {
	{
		local var='blabla'
		L_unittest_success L_exit_to_1null var true
		L_unittest_eq "$var" 1
		L_unittest_eq "${var:+SUCCESS}" "SUCCESS"
		L_unittest_eq "${var:-0}" "1"
		L_unittest_eq "$((var))" "1"
		local var='blabla'
		L_unittest_success L_exit_to_1null var false
		L_unittest_eq "$var" ""
		L_unittest_eq "${var:+SUCCESS}" ""
		L_unittest_eq "${var:-0}" "0"
		L_unittest_eq "$((var))" "0"
	}
}

_L_test_format() {
	{
		local name=John
		local age=21
		L_unittest_cmd -o "Hello, John! You are         21 years old." \
			L_percent_format "Hello, %(name)s! You are %(age)10s years old.\n"
		L_unittest_cmd -o "Hello, %John! You are %%        21 years old." \
			L_percent_format "Hello, %%%(name)s! You are %%%%%(age)10s years old.\n"
		L_unittest_cmd -o "Hello, John! You are         21 years old." \
			L_fstring 'Hello, {name}! You are {age:10s} years old.\n'
		L_unittest_cmd -o "Hello, {John}! You are {{        21}} years old." \
			L_fstring 'Hello, {{{name}}}! You are {{{{{age:10s}}}}} years old.\n'
	}
	{
		L_unittest_cmd -o "21" \
			L_percent_format "%(age)s"
		L_unittest_cmd -o "21 " \
			L_percent_format "%(age)s "
		L_unittest_cmd -o " 21" \
			L_percent_format " %(age)s"
		L_unittest_cmd -o "21" \
			L_fstring "{age}"
		L_unittest_cmd -o "21" \
			L_fstring "{age:}"
		L_unittest_cmd -o "21" \
			L_fstring "{age:d}"
		L_unittest_cmd -o " 21" \
			L_fstring " {age:d}"
		L_unittest_cmd -o "21 " \
			L_fstring "{age:d} "
		L_unittest_cmd -o "{" \
			L_fstring "{{"
		L_unittest_cmd -o "}" \
			L_fstring "}}"
		L_unittest_cmd -o "%%%" \
			L_fstring "%%%"
	}
	{
		L_unittest_cmd -r 'invalid' ! L_percent_format "%(age)"
		L_unittest_cmd -r 'invalid' ! L_percent_format "%()"
		L_unittest_cmd -r 'invalid' ! L_percent_format "%("
		L_unittest_cmd -r 'invalid' ! L_percent_format "%)d"
		L_unittest_cmd -r 'invalid' ! L_percent_format "%"
		L_unittest_cmd -r 'invalid' ! L_fstring "{age"
		L_unittest_cmd -r 'invalid' ! L_fstring "age}"
		L_unittest_cmd -r 'invalid' ! L_fstring "{}"
		L_unittest_cmd -r 'invalid' ! L_fstring "{:}"
		L_unittest_cmd -r 'invalid' ! L_fstring "}"
		L_unittest_cmd -r 'invalid' ! L_fstring "{"
	}
}

_L_test_other() {
	{
		local max=-1
		L_max -v max 1 2 3 4
		L_unittest_eq "$max" 4
	}
	{
		local -a a
		L_abbreviation -va ev eval shooter
		L_unittest_arreq a eval
		L_abbreviation_v e eval eshooter
		L_unittest_arreq L_v eval eshooter
		L_abbreviation -v a none eval eshooter
		L_unittest_arreq a
	}
	{
		local -a a
		L_abbreviation -v a $'\x01' "$L_ALLCHARS" var
		L_unittest_arreq a "$L_ALLCHARS"
		L_abbreviation -v a $'nl\nno' $'nothing' $'nl\nnot here' $'nl\n ok' $'nl\nno'
		L_unittest_arreq a $'nl\nnot here' $'nl\nno'
	}
	{
		L_unittest_checkexit 0 L_is_true true
		L_unittest_checkexit 1 L_is_true false
		L_unittest_checkexit 0 L_is_true yes
		L_unittest_checkexit 0 L_is_true 1
		L_unittest_checkexit 0 L_is_true 123
		L_unittest_checkexit 1 L_is_true 0
		L_unittest_checkexit 1 L_is_true 00
		L_unittest_checkexit 1 L_is_true 010
		L_unittest_checkexit 1 L_is_true atruea
		#
		L_unittest_checkexit 1 L_is_false true
		L_unittest_checkexit 0 L_is_false false
		L_unittest_checkexit 0 L_is_false no
		L_unittest_checkexit 1 L_is_false 1
		L_unittest_checkexit 1 L_is_false 123
		L_unittest_checkexit 0 L_is_false 0
		L_unittest_checkexit 0 L_is_false 00
		L_unittest_checkexit 1 L_is_false 101
		L_unittest_checkexit 1 L_is_false afalsea
	}
	{
		local min=-1
		L_min -v min 1 2 3 4
		L_unittest_eq "$min" 1
	}
	{
		L_unittest_checkexit 0 L_args_contain 1 0 1 2
		L_unittest_checkexit 0 L_args_contain 1 2 1
		L_unittest_checkexit 0 L_args_contain 1 1 0
		L_unittest_checkexit 0 L_args_contain 1 1
		L_unittest_checkexit 1 L_args_contain 0 1
		L_unittest_checkexit 1 L_args_contain 0
	}
	{
		if L_hash jq; then
			local tmp
			t() {
				local tmp
				L_json_escape -v tmp "$1"
				# L_log "JSON ${tmp@Q}"
				out=$(echo "{\"v\":$tmp}" | jq -r .v)
				L_unittest_eq "$1" "$out"
			}
			t $'1 hello\n\t\bworld'
			t $'2 \x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f'
			t $'3 \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f'
			t $'4 \x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f'
			t $'5 \x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f'
			t "! ${L_ALLCHARS::127}"
		fi
	}
	{
		local name=1 tmp
		L_pretty_print -v tmp name 2
		L_unittest_eq "$tmp" $'declare -- name="1"\n2\n'
		local name=(1 2)
		L_pretty_print -v tmp name 2
		if ((L_HAS_DECLARE_WITH_NO_QUOTES)); then
			L_unittest_eq "$tmp" $'declare -a name=([0]="1" [1]="2")\n2\n'
		else
			L_unittest_eq "$tmp" $'declare -a name=\'([0]="1" [1]="2")\'\n2\n'
		fi
	}
	{
		L_unittest_cmd -e 0 L_float_cmp 1.1 -eq 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.1 -le 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.1 -ge 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.1 -gt 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.1 -lt 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.1 -ne 1.1
		L_unittest_cmd -e 10 L_float_cmp 1.1 '<=>' 1.1
		#
		L_unittest_cmd -e 0 L_float_cmp 1.02 -lt 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -le 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -eq 1.1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ne 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -gt 1.1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -ge 1.1
		L_unittest_cmd -e 9 L_float_cmp 1.02 '<=>' 1.1
		#
		L_unittest_cmd -e 1 L_float_cmp 1.02 -lt 1.0000
		L_unittest_cmd -e 1 L_float_cmp 1.02 -le 1.0000
		L_unittest_cmd -e 1 L_float_cmp 1.02 -eq 1.0000
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ne 1.0000
		L_unittest_cmd -e 0 L_float_cmp 1.02 -gt 1.0000
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ge 1.0000
		L_unittest_cmd -e 11 L_float_cmp 1.02 '<=>' 1.0000
		#
		L_unittest_cmd -e 1 L_float_cmp 1.02 -lt 1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -le 1
		L_unittest_cmd -e 1 L_float_cmp 1.02 -eq 1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ne 1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -gt 1
		L_unittest_cmd -e 0 L_float_cmp 1.02 -ge 1
		L_unittest_cmd -e 11 L_float_cmp 1.02 '<=>' 1
		#
		L_unittest_cmd -e 1 L_float_cmp 1 -lt 1
		L_unittest_cmd -e 0 L_float_cmp 1 -le 1
		L_unittest_cmd -e 0 L_float_cmp 1 -eq 1
		L_unittest_cmd -e 1 L_float_cmp 1 -ne 1
		L_unittest_cmd -e 1 L_float_cmp 1 -gt 1
		L_unittest_cmd -e 0 L_float_cmp 1 -ge 1
		L_unittest_cmd -e 10 L_float_cmp 1 '<=>' 1
	}
	{
		L_unittest_cmd -o 'echo echo' L_quote_setx 'echo' 'echo'
		if ((L_HAS_BASH5_3)); then
			# So happy for this change.
			L_unittest_cmd -o "one $'a\nb' two" L_quote_setx 'one' $'a\nb' 'two'
		else
			L_unittest_cmd -o $'one \'a\nb\' two' L_quote_setx 'one' $'a\nb' 'two'
		fi
	}
}

_L_test_array() {
	local arr=() len
	{
		arr=()
		L_array_pop_front arr
		L_array_reverse arr
		L_array_len -v len arr
		L_unittest_eq "$len" 0
		L_unittest_arreq arr
		L_array_prepend arr
		L_unittest_arreq arr
		L_array_append arr
		L_unittest_arreq arr
		L_array_insert arr 0
		L_unittest_arreq arr
		L_array_insert arr 0 1 2 3
		L_unittest_arreq arr 1 2 3
		L_array_clear arr
		L_unittest_arreq arr
		L_array_assign arr 1 2 3
		L_unittest_arreq arr 1 2 3
		L_array_set arr 1 5
		L_unittest_arreq arr 1 5 3
		L_array_clear arr
		L_array_set arr 0 5
		L_unittest_arreq arr 5
	}
	{
		arr=(1 2 3)
		L_array_pop_back arr
		L_unittest_arreq arr 1 2
		arr=(1 2 3)
		L_array_pop_front arr
		L_unittest_arreq arr 2 3
		arr=(1 2 3)
		L_array_reverse arr
		L_unittest_arreq arr 3 2 1
		L_array_assign arr 1 2 3
		L_unittest_arreq arr 1 2 3
		L_array_prepend arr
		L_unittest_arreq arr 1 2 3
	}
	{
		local arr=(1 2 3)
		L_array_pop_back arr
		L_unittest_arreq arr 1 2
	}
	{
		local arr=(1 2 3 4 5)
		L_array_filter_eval arr '[[ $1 -ge 3 ]]'
		L_unittest_arreq arr 3 4 5
	}
	{
		arr=(1 2 3)
		L_unittest_checkexit 0 L_array_is_dense arr
		arr[100]=100
		L_unittest_checkexit 1 L_array_is_dense arr
	}
	{
		arr=(1 2 3)
		local a b c
		L_array_extract arr a b c
		L_unittest_eq "$a" "1"
		L_unittest_eq "$b" "2"
		L_unittest_eq "$c" "3"
	}
}

_L_test_array_read() {
	local arr=(4 5 6)
	L_array_read arr <<<$'1\n2\n3'
	L_unittest_arreq arr 1 2 3
	local arr=(4 5 6)
	L_array_read -d '' arr < <(printf "1\x002\x003\x00")
	L_unittest_arreq arr 1 2 3
}

_L_test_array_reverse() {
	local array=(1 2 3 4 5)
	L_unittest_cmd -c L_array_reverse array
	L_unittest_arreq array 5 4 3 2 1
	local array=(1)
	L_unittest_cmd -c L_array_reverse array
	L_unittest_arreq array 1
	# local array=({1..200}) does not work in bash4.0
	local array=()
	array=({1..200})
	L_unittest_cmd -c L_array_reverse array
	L_unittest_arreq array {200..1}
	local array=()
	L_unittest_cmd -c L_array_reverse array
	L_unittest_arreq array
}

_L_test_array_string() {
	helper() {
		local src=("$@") dst str
		L_array_to_string -v str src
		L_array_from_string dst "$str"
		L_unittest_arreq dst ${src[@]:+"${src[@]}"}
	}
	helper
	helper ''
	helper 1
	helper 1 2 3
	helper $'\001'
	helper $'\177'
	helper "$L_ALLCHARS"
	helper "$L_ALLCHARS" "$L_ALLCHARS" "$L_ALLCHARS" "$L_ALLCHARS"
}

_L_test_regex_findall() {
	{
		local tmp
		L_regex_findall -v tmp 'ab ac ad' 'a.'
		L_unittest_arreq tmp ab ac ad
		L_regex_findall -v tmp '123ab123ac123ad123' 'a.'
		L_unittest_arreq tmp ab ac ad
	}
}

_L_test_regex_replace() {
	local out a
	L_regex_replace -v out 'world world' 'w[^ ]*' 'hello'
	L_unittest_eq "$out" "hello world"
	L_regex_replace -gv out "aa ab ac" "a." ''
	L_unittest_eq "$out" "  "
	L_regex_replace -gv a "aa ab ac" "a." 'A"\&"'
	L_unittest_eq "$a" 'A"aa" A"ab" A"ac"'
	L_regex_replace -gv a "aa ab ac" "a(.)" 'A"\1"'
	L_unittest_eq "$a" 'A"a" A"b" A"c"'
}

_L_test_table() {
	{
		local tmp out="\
name1 name2 name3
a     b     c
d     e     f"
		L_unittest_cmd -c -o "$out" -- L_table "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b c
    d     e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b
    d"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b" "d"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b" "d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1   name3
    a b
    d e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_table -v tmp -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
}

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
		L_unittest_cmd -r "parameter without a default follows parameter with a default" ! L_argskeywords b=2 c --
		L_unittest_cmd -r "separator argument is missing" ! L_argskeywords a b
		L_unittest_cmd -r "parameter without a default follows parameter with a default" ! L_argskeywords a=1 b --
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
			local -A kwargs=()
			L_unittest_cmd -c L_argskeywords @@kwargs -- a=Real b=Python c=Is d=Great e="!"
			L_unittest_eq "${kwargs[a]}" "Real"
			L_unittest_eq "${kwargs[b]}" "Python"
			L_unittest_eq "${kwargs[c]}" "Is"
			L_unittest_eq "${kwargs[d]}" "Great"
			L_unittest_eq "${kwargs[e]}" "!"
		}
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
}

_L_test_version() {
	L_unittest_checkexit 0 L_version_cmp "0" -eq "0"
	L_unittest_checkexit 0 L_version_cmp "0" '==' "0"
	L_unittest_checkexit 1 L_version_cmp "0" '!=' "0"
	L_unittest_checkexit 0 L_version_cmp "0" '<' "1"
	L_unittest_checkexit 0 L_version_cmp "0" '<=' "1"
	L_unittest_checkexit 0 L_version_cmp "0.1" '<' "0.2"
	L_unittest_checkexit 0 L_version_cmp "2.3.1" '<' "10.1.2"
	L_unittest_checkexit 0 L_version_cmp "1.3.a4" '<' "10.1.2"
	L_unittest_checkexit 0 L_version_cmp "0.0.1" '<' "0.0.2"
	L_unittest_checkexit 0 L_version_cmp "0.1.0" -gt "0.0.2"
	L_unittest_checkexit 0 L_version_cmp "$BASH_VERSION" -gt "0.1.0"
	L_unittest_checkexit 0 L_version_cmp "1.0.3" "<" "1.0.7"
	L_unittest_checkexit 1 L_version_cmp "1.0.3" ">" "1.0.7"
	L_unittest_checkexit 0 L_version_cmp "2.0.1" ">=" "2"
	L_unittest_checkexit 0 L_version_cmp "2.1" ">=" "2"
	L_unittest_checkexit 0 L_version_cmp "2.0.0" ">=" "2"
	L_unittest_checkexit 0 L_version_cmp "1.4.5" "~=" "1.4.5"
	L_unittest_checkexit 0 L_version_cmp "1.4.6" "~=" "1.4.5"
	L_unittest_checkexit 1 L_version_cmp "1.5.0" "~=" "1.4.5"
	L_unittest_checkexit 1 L_version_cmp "1.3.0" "~=" "1.4.5"
	#
	# L_unittest_checkexit 1 L_version_cmp "1.1.post1" "==" "1.1"
	# L_unittest_checkexit 0 L_version_cmp "1.1.post1" "==" "1.1.*"
	# L_unittest_checkexit 0 L_version_cmp "1.1.post1" "==" "1.1.post1"
	# L_unittest_checkexit 0 L_version_cmp "1.1" "==" "1.1"
	# L_unittest_checkexit 0 L_version_cmp "1.1" "==" "1.1.0"
	# L_unittest_checkexit 1 L_version_cmp "1.1" "==" "1.1.dev1"
	# L_unittest_checkexit 1 L_version_cmp "1.1" "==" "1.1a1"
	# L_unittest_checkexit 1 L_version_cmp "1.1" "==" "1.1.post1"
	# L_unittest_checkexit 0 L_version_cmp "1.1" "==" "1.1.*"
}

_L_test_table() {
	{
		local tmp out="\
name1 name2 name3
a     b     c
d     e     f"
		L_unittest_cmd -c -o "$out" -- L_table "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b c
    d     e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b c" "d e f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1 name2 name3
    a     b
    d"
		L_unittest_cmd -o "$out" -- L_table -R1-2 "name1 name2 name3" "a b" "d"
		L_table -v tmp -R1-2 "name1 name2 name3" "a b" "d"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
	{
		local tmp out="\
name1   name3
    a b
    d e f"
		L_unittest_cmd -o "$out" -- L_table -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_table -v tmp -R1-2 -s, "name1,,name3" "a,b" "d,e,f"
		L_unittest_eq "$tmp" "$out"$'\n'
	}
}


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
		L_unittest_cmd -r "parameter without a default follows parameter with a default" ! L_argskeywords b=2 c --
		L_unittest_cmd -r "separator argument is missing" ! L_argskeywords a b
		L_unittest_cmd -r "parameter without a default follows parameter with a default" ! L_argskeywords a=1 b --
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
			local -A kwargs=()
			L_unittest_cmd -c L_argskeywords @@kwargs -- a=Real b=Python c=Is d=Great e="!"
			L_unittest_eq "${kwargs[a]}" "Real"
			L_unittest_eq "${kwargs[b]}" "Python"
			L_unittest_eq "${kwargs[c]}" "Is"
			L_unittest_eq "${kwargs[d]}" "Great"
			L_unittest_eq "${kwargs[e]}" "!"
		}
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
}

_L_test_log() {
	{
		local i
		L_log_level_to_int i INFO
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
		L_log_level_to_int i L_LOGLEVEL_INFO
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
		L_log_level_to_int i info
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
		L_log_level_to_int i "$L_LOGLEVEL_INFO"
		L_unittest_eq "$i" "$L_LOGLEVEL_INFO"
	}
}

_L_test_setx() {
	aaa_1() { echo hi; return "$1"; }
	aaa_2() { aaa_1 "$@"; }
	L_unittest_cmd -jr '.*+ echo hi.*' L_setx aaa_2 0
	L_unittest_cmd -jr '.*+ echo hi.*' -e 123 L_setx aaa_2 123
	unset aaa_1 aaa_2
}

_L_test_sort() {
	export LC_ALL=C
	if ((L_HAS_BASH4_0)); then
		local IFS='1'
	fi
	{
		local var=(1 2 3)
		L_sort_bash -n var
		L_unittest_arreq var 1 2 3
	}
	{
		local data opt
		for opt in "-n" "" "-z" "-n -z"; do
			for data in "1 2 3" "3 2 1" "1 3 2" "2 3 1" "6 5 4 3 2 1" "6 1 5 2 4 3" "-1 -2 4 6 -4"; do
				local -a sort_bash="($data)" sort="($data)" optarr="($opt)"
				L_sort_cmd ${optarr[@]+"${optarr[@]}"} sort
				L_sort_bash ${optarr[@]+"${optarr[@]}"} sort_bash
				L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			done
		done
		for opt in "" "-z"; do
			for data in "a b" "b a" "a b c" "c b a" "a c b" "b c a" "f d s a we r t gf d fg vc s"; do
				local -a sort_bash="($data)" sort="($data)" optarr="($opt)"
				L_sort_cmd ${optarr[@]+"${optarr[@]}"} sort
				L_sort_bash ${optarr[@]+"${optarr[@]}"} sort_bash
				L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			done
		done
	}
	{
		L_log "test bash sorting of an array"
		local arr=(9 4 1 3 4 5)
		L_sort_bash -n arr
		L_unittest_arreq arr 1 3 4 4 5 9
		local arr=(g s b a c o)
		L_sort_bash arr
		L_unittest_arreq arr a b c g o s
	}
	{
		L_log "test sorting of an array"
		local arr=(9 4 1 3 4 5)
		L_sort_cmd -n arr
		L_unittest_arreq arr 1 3 4 4 5 9
		local arr=(g s b a c o)
		L_sort_cmd arr
		L_unittest_arreq arr a b c g o s
	}
	{
		L_log "test sorting of an array with zero separated stream"
		local arr=(9 4 1 3 4 5)
		L_sort_cmd -z -n arr
		L_unittest_arreq arr 1 3 4 4 5 9
		local arr=(g s b a c o)
		L_sort_cmd -z arr
		L_unittest_arreq arr a b c g o s
	}
	{
		local -a nums=(
			10 99 7 33 97 68 100 83 80 51 74 24 85 71 64 36 72 67 60 73 54 5 63
			50 40 27 30 44 1 37 86 14 52 15 81 78 46 90 39 79 65 47 28 77 62 22
			98 76 41 49 89 48 32 21 92 70 11 96 58 55 56 45 17 66 57 42 31 23 26
			35 3 6 13 25 8 82 84 61 75 12 2 9 53 94 69 93 38 87 59 16 20 95 43 34
			91 88 4 18 19 29 -52444  46793   63644   23950   -24008  -8219 -34362
			59930 -13817 -30880 59270 43982 -1901 53069 -24481 -21592 811 -4132
			65052 -5629 19149 17827 17051 -22462 8842 53592 -49750 -18064 -8324
			-23371 42055 -24291 -54302 3207 4580 -10132 -33922 -14613 41633 36787
		)
		for opt in "" "-n" "-z" "-n -z"; do
			local -a sort_bash=("${nums[@]}") sort=("${nums[@]}") optarr="($opt)"
			L_sort_bash ${optarr[@]+"${optarr[@]}"} sort_bash
			L_sort_cmd ${optarr[@]+"${optarr[@]}"} sort
			L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			(
				L_HAS_MAPFILE_D=0
				local -a sort_bash=("${nums[@]}") sort=("${nums[@]}")
				L_sort_bash ${optarr[@]+"${optarr[@]}"} sort_bash
				L_sort_cmd ${optarr[@]+"${optarr[@]}"} sort
				L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			)
			(
				L_HAS_MAPFILE_D=0
				L_HAS_MAPFILE=0
				local -a sort_bash=("${nums[@]}") sort=("${nums[@]}")
				L_sort_bash ${optarr[@]+"${optarr[@]}"} sort_bash
				L_sort_cmd ${optarr[@]+"${optarr[@]}"} sort
				L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
			)
		done
	}
	{
		local -a words=(
			"curl moor" "knowing glossy" $'lick\npen' "hammer languid"
			pigs available gainful black-and-white grateful
			fetch screw sail marked seed delicious tenuous bow
			plants loaf handsome page ice misty innate slip
		)
		local sort_bash=("${words[@]}") sort=("${words[@]}")
		L_sort_bash -z sort_bash
		L_sort_cmd -z sort
		L_unittest_eq "${sort[*]}" "${sort_bash[*]}"
	}
	{
		local -a words=()
		L_sort_bash words
		L_unittest_arreq words
		L_sort_cmd words
		L_unittest_arreq words
	}
}

_L_test_trapchain() {
	local IFS=' '
	{
		L_log "test converting int to signal name"
		local tmp
		L_trap_to_name -v tmp EXIT
		L_unittest_eq "$tmp" EXIT
		L_trap_to_name -v tmp 0
		L_unittest_eq "$tmp" EXIT
		L_trap_to_name -v tmp 1
		L_unittest_eq "$tmp" SIGHUP
		L_trap_to_name -v tmp DEBUG
		L_unittest_eq "$tmp" DEBUG
		L_trap_to_name -v tmp SIGRTMIN+5
		L_unittest_eq "$tmp" SIGRTMIN+5
		L_trap_to_number -v tmp SIGRTMAX-5
		L_unittest_eq "$tmp" 59
	}
	{
		L_log "test L_trapchain"
		local tmp
		local allchars
		tmp=$(
			L_trap_push 'echo -n hello' EXIT
			L_trap_push 'echo -n " "' EXIT
			L_trap_push 'echo -n world' EXIT
			L_trap_push 'echo -n "!"' EXIT
		)
		L_unittest_eq "$tmp" "hello world!"
	}
	if ((L_HAS_BASHPID)); then
		tmp=$(
			L_trap_push 'echo -n "4"' SIGUSR1
			L_trap_push 'echo -n " 3"' SIGUSR1
			L_trap_push 'echo -n " 2"' SIGUSR2
			L_trap_push 'echo -n " 1"' EXIT
			L_raise -s SIGUSR1
			L_raise -s SIGUSR2
		)
		L_unittest_eq "$tmp" "4 3 2 1"
	fi
}

_L_test_map() {
	local IFS=" "
	{
		local map map2 tmp
		{
			L_map_init map
			L_map_set map a 1
			L_map_has map a
			L_map_set map b 2
			L_map_has map b
			L_map_set map c 3
			L_map_has map c
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 1
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 2
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 3
			L_map_items -v tmp map
			L_unittest_eq "${tmp[*]}" "a 1 b 2 c 3"
			L_map_keys -v tmp map
			L_unittest_eq "${tmp[*]}" "a b c"
			L_map_values -v tmp map
			L_unittest_eq "${tmp[*]}" "1 2 3"
		}
		{
			L_map_set map a 4
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 2
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 3
		}
		{
			L_map_set map b 5
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 3
		}
		{
			L_map_set map c 6
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 6
		}
		{
			map2="$map"
			L_map_remove map a
			L_unittest_failure L_map_get map a
			L_unittest_failure L_map_has map a
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 6
			map="$map2"
		}
		{
			map2="$map"
			L_map_remove map b
			L_unittest_failure L_map_get map b
			L_unittest_failure L_map_has map b
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map c
			L_unittest_eq "$tmp" 6
			map="$map2"
		}
		{
			map2="$map"
			L_map_remove map c
			L_unittest_failure L_map_get map c
			L_unittest_failure L_map_has map c
			L_map_get -v tmp map a
			L_unittest_eq "$tmp" 4
			L_map_get -v tmp map b
			L_unittest_eq "$tmp" 5
			map="$map2"
		}
	}
	{
		if ((L_HAS_BASH4_0)); then local IFS=bc; fi
		local map tmp
		L_map_init map
		L_map_set map "/bin/ba*" "/dev/*"
		L_map_set map "b " "2 "
		L_map_set map " c" " 3"
		L_map_get -v tmp map "/bin/ba*"
		L_unittest_eq "$tmp" "/dev/*"
		L_map_get -v tmp map "b "
		L_unittest_eq "$tmp" "2 "
		L_map_get -v tmp map " c"
		L_unittest_eq "$tmp" " 3"
		tmp=()
		L_map_keys -v tmp map
		L_unittest_arreq tmp "/bin/ba*" "b " " c"
		L_map_items -v tmp map
		L_unittest_arreq tmp "/bin/ba*" "/dev/*" "b " "2 " " c" " 3"
		L_map_values -v tmp map
		L_unittest_arreq tmp "/dev/*" "2 " " 3"
	}
	{
		local map tmp
		L_unittest_success L_map_init map
		L_unittest_success L_map_set map '${var:?error}$(echo hello)' '${var:?error}$(echo hello)value'
		L_unittest_success L_map_has map '${var:?error}$(echo hello)'
		L_unittest_success L_map_get -v tmp map '${var:?error}$(echo hello)'
		L_unittest_eq "$tmp" '${var:?error}$(echo hello)value'
		L_unittest_success L_map_items -v tmp map
		L_unittest_arreq tmp '${var:?error}$(echo hello)' '${var:?error}$(echo hello)value'
	}
	{
		local PREFIX_a PREFIX_b var tmp
		L_map_init var
		PREFIX_a=1
		PREFIX_b=2
		L_map_save var PREFIX_
		L_map_items -v tmp var
		L_unittest_arreq tmp a 1 b 2
	}
	{
		local var tmp
		var=123
		tmp=123
		L_map_init var
		L_map_set var a 1
		# L_unittest_cmpfiles <(L_map_get var a) <(echo -n 1)
		L_unittest_eq "$(L_map_get var b "")" ""
		L_map_set var b 2
		L_unittest_eq "$(L_map_get var a)" "1"
		L_unittest_eq "$(L_map_get var b)" "2"
		L_map_set var a 3
		L_unittest_eq "$(L_map_get var a)" "3"
		L_unittest_eq "$(L_map_get var b)" "2"
		L_unittest_checkexit 1 L_map_get var c
		L_unittest_checkexit 1 L_map_has var c
		L_unittest_checkexit 0 L_map_has var a
		L_map_set var allchars "$L_ALLCHARS"
		L_unittest_eq "$(L_map_get var allchars)" "$(printf %s "$L_ALLCHARS")"
		L_map_remove var allchars
		L_unittest_checkexit 1 L_map_get var allchars
		L_map_set var allchars "$L_ALLCHARS"
		local s_a s_b s_allchars
		L_unittest_eq "$(L_map_keys var | sort)" "$(printf "%s\n" b a allchars | sort)"
		L_map_load var s_
		L_unittest_eq "$s_a" 3
		L_unittest_eq "$s_b" 2
		L_unittest_eq "$s_allchars" "$L_ALLCHARS"
		#
		local tmp=()
		L_map_keys -v tmp var
		L_unittest_arreq tmp b a allchars
		local tmp=()
		L_map_values -v tmp var
		L_unittest_eq "${#tmp[@]}" 3
		L_unittest_eq "${tmp[0]}" 2
		L_unittest_eq "${tmp[1]}" 3
		if (( BASH_VERSINFO[0] >= 4 )); then
			# There is a bug that declare prints erroneous 0x01 in bash 3.2
			L_unittest_eq "${tmp[2]}" "$L_ALLCHARS"
			local tmp=() IFS=' '
			L_map_items -vtmp var
			L_unittest_eq "${tmp[*]}" "b 2 a 3 allchars $L_ALLCHARS"
		fi
	}
}

if ((L_HAS_ASSOCIATIVE_ARRAY)); then

_L_test_asa() {
	declare -A map=()
	local v
	{
		L_info "_L_test_asa: check has"
		map[a]=1
		L_asa_has map a
		L_asa_has map b && exit 1
	}
	{
		L_info "_L_test_asa: check getting"
		L_asa_get -v v map a
		L_unittest_eq "$v" 1
		v=
		L_asa_get -v v map a 2
		L_unittest_eq "$v" 1
		v=
		L_asa_get -v v map b 2
		L_unittest_eq "$v" 2
	}
	{
		L_info "_L_test_asa: check length"
		L_unittest_eq "$(L_asa_len map)" 1
		L_asa_len -v v map
		L_unittest_eq "$v" 1
		map[c]=2
		L_asa_len -v v map
		L_unittest_eq "$v" 2
	}
	{
		L_info "_L_test_asa: copy"
		local -A map=([a]=1 [c]=$'\'"@ ') map2=()
		L_asa_assign map2 = map
		L_unittest_eq "${map[a]}" 1
		L_unittest_eq "${map[c]}" $'\'"@ '
		L_unittest_eq "${map2[a]}" 1
		L_unittest_eq "${map2[c]}" $'\'"@ '
	}
	{
		L_info "_L_test_asa: nested asa"
		local -A map2=([c]=d [e]=f)
		map[mapkey]=$(declare -p "map2")
		L_asa_has map mapkey
		L_asa_get map mapkey
		local -A map3=()
		L_asa_from_declare map3 = "${map[mapkey]}"
		L_asa_get -v v map3 c
		L_unittest_eq "$v" d
		L_asa_get -v v map3 e
		L_unittest_eq "$v" f
	}
	{
		L_asa_keys_sorted -v v map2
		L_unittest_eq "${v[*]}" "c e"
		L_unittest_eq "$(L_asa_keys_sorted map2)" "c"$'\n'"e"
	}
	{
		L_info "_L_test_asa: nested asa with quotes"
		local -A map3 map2=([a]="='='=")
		map[mapkey]=$(declare -p "map2")
		L_asa_from_declare map3 = "${map[mapkey]}"
		L_unittest_eq "${map2[a]}" "${map3[a]}"
	}
}

fi  # L_HAS_ASSOCIATIVE_ARRAY

_L_test_z_argparse1() {
	local ret tmp option storetrue storefalse store0 store1 storeconst append
	{
		L_log "check init"
		local -a parser=(
			prog=prog
			-- -t --storetrue action=store_true
			-- -f --storefalse action=store_false
			-- -0 --store0 action=store_0
			-- -1 --store1 action=store_1
			-- -c --storeconst action=store_const const=yes default=no
			-- -a --append action=append
			----
		)
		L_unittest_cmd -r 'argument' ! L_argparse "${parser[@]}" ----
		L_unittest_cmd -r 'error' ! L_argparse "${parser[@]}" --- -h
		L_unittest_cmd L_argparse "${parser[@]}" --
		L_unittest_cmd L_argparse "${parser[@]}"
		L_unittest_cmd L_argparse -- -o ----
		L_unittest_cmd L_argparse -- --option ---- --op 1
		L_unittest_cmd L_argparse -- --option ----
		L_unittest_cmd L_argparse -- --option ---- --option=1
		L_unittest_cmd L_argparse -- --option ---- -h
		L_unittest_cmd -r '----' ! L_argparse
		L_unittest_cmd -r '----' ! L_argparse --
		L_unittest_cmd -r '----' ! L_argparse help=123
	}
	{
		local append=()
		L_log "check defaults"
		L_unittest_cmd -c L_argparse "${parser[@]}"
		L_unittest_vareq storetrue false
		L_unittest_vareq storefalse true
		L_unittest_vareq store0 1
		L_unittest_vareq store1 0
		L_unittest_vareq storeconst no
		L_unittest_arreq append
	}
	{
		append=()
		L_log "check single"
		L_unittest_cmd -c L_argparse "${parser[@]}" -tf01ca1 -a2 -a 3
		L_unittest_vareq storetrue true
		L_unittest_vareq storefalse false
		L_unittest_vareq store0 0
		L_unittest_vareq store1 1
		L_unittest_vareq storeconst yes
		L_unittest_arreq append 1 2 3
	}
	{
		append=()
		L_log "check long"
		L_unittest_cmd -c L_argparse "${parser[@]}" --storetrue --storefalse --store0 --store1 --storeconst \
			--append=1 --append $'2\n3' --append $'4" \'5'
		L_unittest_vareq storetrue true
		L_unittest_vareq storefalse false
		L_unittest_vareq store0 0
		L_unittest_vareq store1 1
		L_unittest_vareq storeconst yes
		L_unittest_arreq append 1 $'2\n3' $'4" \'5'
	}
	{
		L_log "args"
		local arg=() ret=0
		L_unittest_failure_capture tmp -- L_argparse prog=prog -- arg nargs="+" ----
		L_unittest_contains "$tmp" "required"
		#
		local arg=()
		L_argparse prog=prog -- arg nargs="+" ---- 1
		L_unittest_arreq arg 1
		#
		local arg=()
		L_argparse prog=prog -- arg nargs="+" ---- 1 $'2\n3' $'4"\'5'
		L_unittest_arreq arg 1 $'2\n3' $'4"\'5'
	}
	{
		L_log "check help"
		L_unittest_failure_capture tmp -- L_argparse prog="ProgramName" -- arg nargs=2 ----
		L_unittest_contains "$tmp" "Usage: ProgramName"
		L_unittest_contains "$tmp" "arg arg"
	}
	{
		L_log "only short opt"
		local o=
		L_argparse prog="ProgramName" -- -o ---- -o val
		L_unittest_eq "$o" val
	}
	{
		L_log "abbrev"
		local option verbose
		L_argparse -- --option action=store_1 -- --verbose action=store_1 ---- --o --v --opt
		L_unittest_eq "$option" 1
		L_unittest_eq "$verbose" 1
		#
		L_unittest_cmd -r "ambiguous option: --op" -- ! \
			L_argparse -- --option action=store_1 -- --opverbose action=store_1 ---- --op
	}
	{
		L_log "count"
		local verbose=
		L_argparse -- -v --verbose action=count ---- -v -v -v -v
		L_unittest_eq "$verbose" 4
		local verbose=
		L_argparse -- -v --verbose action=count ---- -v -v
		L_unittest_eq "$verbose" 2
		local verbose=
		L_argparse -- -v --verbose action=count ----
		L_unittest_eq "$verbose" ""
		local verbose=
		L_argparse -- -v --verbose action=count default=0 ----
		L_unittest_eq "$verbose" "0"
	}
	{
		L_log "type"
		local tmp arg
		L_unittest_failure_capture tmp L_argparse -- arg type=int ---- a
		L_unittest_contains "$tmp" "not an integer"
	}
	{
		L_log "usage"
		L_unittest_cmd -N -- L_argparse prog=prog -- bar nargs=3 help="This is a bar argument" ---- --help
	}
	{
		L_log "required"
		L_unittest_failure_capture tmp L_argparse prog=prog -- --option required=true ----
		L_unittest_contains "$tmp" "the following arguments are required: --option"
		L_unittest_failure_capture tmp L_argparse prog=prog -- --option required=true -- --other required=true -- bar ----
		L_unittest_contains "$tmp" "the following arguments are required: --option, --other, bar"
	}
}

_L_test_z_argparse2() {
	{
		L_log "two args"
		local ret out arg1 arg2
		L_argparse -- arg1 -- arg2 ---- a1 b1
		L_unittest_eq "$arg1" a1
		L_unittest_eq "$arg2" b1
		L_argparse -- arg1 nargs=1 -- arg2 nargs='?' default=def ---- a2
		L_unittest_eq "$arg1" a2
		L_unittest_eq "$arg2" "def"
		L_argparse -- arg1 nargs=1 -- arg2 nargs='*' ---- a3
		L_unittest_eq "$arg1" a3
		L_unittest_eq "$arg2" "def"
		#
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 -- arg2 nargs='+' ---- a
		L_unittest_contains "$out" "are required: arg2"
		L_unittest_failure_capture out -- L_argparse -- arg1 nargs=1 -- arg2 nargs='*' ----
		L_unittest_contains "$out" "are required: arg1"
		L_unittest_failure_capture out -- L_argparse -- arg1 nargs=1 -- arg2 nargs='+' ----
		L_unittest_contains "$out" "are required: arg1, arg2"
	}
}

_L_test_z_argparse3() {
	local foo bar count verbose filename
	{
		local count verbose filename
		L_argparse \
  		prog=ProgramName \
  		description="What the program does" \
  		epilog="Text at the bottom of help" \
  		-- filename \
  		-- -c --count \
  		-- -v --verbose action=store_1 \
  		---- -c 5 -v ./file1
  		L_unittest_eq "$count" 5
  		L_unittest_eq "$verbose" 1
  		L_unittest_eq "$filename" ./file1
	}
	{
		local tmp
		L_unittest_cmd -o "\
Usage: myprogram [-h]

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog="myprogram" ---- -h
	}
	{
		tmp=$(L_argparse prog="myprogram" -- --foo help="foo of the myprogram program" ---- -h)
		L_unittest_eq "$tmp" "\
Usage: myprogram [-h] [--foo FOO]

Options:
  -h, --help  show this help message and exit
  --foo FOO   foo of the myprogram program"
	}
	{
		local foo bar
		L_unittest_cmd -o "\
Usage: PROG [options]

Arguments:
  bar  bar help

Options:
  -h, --help   show this help message and exit
  --foo [FOO]  foo help" \
			-- L_argparse prog=PROG usage="PROG [options]" \
			-- --foo nargs="?" help="foo help" \
			-- bar nargs="+" help="bar help" \
			---- -h
	}
	{
		L_unittest_cmd -o "\
Usage: argparse.py [-h]

A foo that bars

Options:
  -h, --help  show this help message and exit

And that's how you'd foo a bar" \
			-- L_argparse prog=argparse.py \
				description='A foo that bars' \
				epilog="And that's how you'd foo a bar" \
				---- -h
	}
	{
		local out foobar foonley
		L_unittest_failure_capture out \
			-- L_argparse prog=PROG allow_abbrev=False \
			-- --foobar action=store_true \
			-- --foonley action=store_false \
			---- --foon
		L_unittest_eq "$out" "\
Usage: PROG [-h] [--foobar] [--foonley]
PROG: error: unrecognized arguments: --foon"
	}
	{
		local foo='' bar=''
		L_argparse prog=PROG -- -f --foo -- bar ---- BAR
		L_unittest_eq "$bar" BAR
		L_unittest_eq "$foo" ""
		local foo='' bar=''
		L_argparse prog=PROG -- -f --foo -- bar ---- BAR --foo FOO
		L_unittest_eq "$bar" BAR
		L_unittest_eq "$foo" "FOO"
		local foo='' bar='' out=''
		L_unittest_failure_capture out -- L_argparse prog=PROG -- -f --foo -- bar ---- --foo FOO
		L_unittest_eq "$out" "\
Usage: PROG [-h] [-f FOO] bar
PROG: error: the following arguments are required: bar"
	}
	{
		local foo=''
		L_argparse -- --foo action=store_const const=42 ---- --foo
		L_unittest_eq "$foo" 42
		local foo='' bar='' baz=''
		L_argparse -- --foo action=store_true -- --bar action=store_false -- --baz action=store_false ---- --foo --bar
		L_unittest_eq "$foo" true
		L_unittest_eq "$bar" false
		L_unittest_eq "$baz" true
		local foo=()
		L_argparse -- --foo action=append ---- --foo 1 --foo 2
		L_unittest_arreq foo 1 2
		local foo=()
		L_argparse -- --foo action=append default='first_element "second element"' ----
		L_unittest_arreq foo "first_element" "second element"
		local types=()
		L_argparse -- --str dest=types action=append_const const=str -- --int dest=types action=append_const const=int ---- --str --int
		L_unittest_arreq types str int
		local foo=
		# bop
		local verbose=
		L_argparse -- --verbose -v action=count default=0 ---- -vvv
		L_unittest_eq "$verbose" 3
	}
	{
		local foo=() bar=''
		L_argparse -- --foo nargs=2 -- bar nargs=1 ---- c --foo a b
		L_unittest_eq "$bar" "c"
		L_unittest_arreq foo a b
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX --foo=YY
		L_unittest_eq "$foo" YY
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX --foo
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- --foo XX
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- --foo nargs="?" const=c default=d -- bar nargs="?" default=d ----
		L_unittest_eq "$foo" d
		L_unittest_eq "$bar" d
		local foo='' bar=''
		L_argparse -- -f --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- XX -fYY
		L_unittest_eq "$foo" YY
		L_unittest_eq "$bar" XX
		local foo='' bar=''
		L_argparse -- -f --foo nargs="?" const=c default=d -- bar nargs="?" default=d ---- -f YY
		L_unittest_eq "$foo" c
		L_unittest_eq "$bar" YY
		(
			tmpf1=$(mktemp)
			tmpf2=$(mktemp)
			trap 'rm "$tmpf1" "$tmpf2"' EXIT
			local outfile='' infile=''
			L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ---- "$tmpf1" "$tmpf2"
			L_unittest_eq "$infile" "$tmpf1"
			L_unittest_eq "$outfile" "$tmpf2"
			local outfile='' infile=''
			L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ---- "$tmpf1"
			L_unittest_eq "$infile" "$tmpf1"
			L_unittest_eq "$outfile" "/dev/stdout"
		)
		local outfile='' infile=''
		L_argparse -- infile nargs="?" type=file_r default=/dev/stdin -- outfile nargs="?" type=file_w default=/dev/stdout ----
		L_unittest_eq "$infile" "/dev/stdin"
		L_unittest_eq "$outfile" "/dev/stdout"
		# bop nargs="*"
		local foo=()
		L_argparse prog=PROG -- foo nargs="+" ---- a b
		L_unittest_arreq foo a b
		local out=''
		L_unittest_failure_capture out -- L_argparse prog=PROG -- foo nargs="+" ----
		L_unittest_eq "$out" "\
Usage: PROG [-h] foo [foo ...]
PROG: error: the following arguments are required: foo"
	}
	{
		local foo=''
		L_argparse -- --foo default=42 ---- --foo 2
		L_unittest_eq "$foo" 2
		L_argparse -- --foo default=42 ----
		L_unittest_eq "$foo" 42
		local length width
		L_unittest_cmd -c L_argparse -- --length default=10 type=int -- --width default=10.5 type=int ----
		L_unittest_eq "$length" 10
		L_unittest_eq "$width" 10.5
		local foo=''
		L_unittest_cmd -c L_argparse -- foo nargs="?" default=42 ---- a
		L_unittest_eq "$foo" a
		local foo=''
		L_unittest_cmd -c L_argparse -- foo nargs="?" default=42 ----
		L_unittest_eq "$foo" 42
		local foo=321
		L_unittest_cmd -c L_argparse -- foo nargs="?" default= ----
		L_unittest_eq "$foo" ""
	}
	{
		local move=''
		L_unittest_cmd -c L_argparse prog=game.py -- move choices="rock paper scissors" ---- rock
		L_unittest_vareq move rock
		L_unittest_cmd -o "\
Usage: game.py [-h] {rock,paper,scissors}
game.py: error: argument {rock,paper,scissors}: invalid choice: fire (choose from rock, paper, scissors)" \
			-- ! L_argparse prog=game.py -- move choices="rock paper scissors" ---- fire
	}
	{
		local foo=''
		L_unittest_cmd -c L_argparse prog=PROG -- --foo required=1 ---- --foo BAR
		L_unittest_vareq foo BAR
		L_unittest_cmd -o "\
Usage: PROG [-h] --foo FOO
PROG: error: the following arguments are required: --foo" \
			-- ! L_argparse prog=PROG -- --foo required=1 ----
	}
	{
		L_unittest_cmd -o "\
Usage: frobble [-h] [bar]

Arguments:
  bar  the bar to frobble (default: 42)

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog=frobble -- bar nargs="?" type=int default=42 \
				help="the bar to frobble (default: 42)" ---- -h
		L_unittest_cmd -o "\
Usage: frobble [-h]

Options:
  -h, --help  show this help message and exit" \
			-- L_argparse prog=frobble -- --foo help=SUPPRESS ---- -h
	}
	{
		L_unittest_cmd -c L_argparse -- --foo -- bar ---- X --foo Y
		L_unittest_vareq foo Y
		L_unittest_vareq bar X
		L_unittest_cmd -o "\
Usage: prog [-h] [--foo FOO] bar

Arguments:
  bar

Options:
  -h, --help  show this help message and exit
  --foo FOO" \
			-- L_argparse prog=prog -- --foo -- bar ---- -h
  	}
}

if ((L_HAS_ASSOCIATIVE_ARRAY)); then
_L_test_z_argparse_A() {
	{
		declare -A Adest=()
		L_unittest_cmd -c \
				L_argparse prog=python.py Adest=Adest \
				-- --asome \
				-- -a action=append \
				-- dest nargs=3 \
				---- 1 1 123 --asome 1123 -a 1 -a 2 -a 3
		local -a arr="(${Adest[dest]})"
		L_unittest_arreq arr 1 1 123
		local -a arr="(${Adest[a]})"
		L_unittest_arreq arr 1 2 3
		L_unittest_eq "${Adest[asome]}" 1123
	}
}
fi

_L_test_z_argparse4() {
	local foo arg
	{
		local a='' dest=()
		L_argparse prog=prog -- -a -- dest nargs="*" ---- -a 1 2 3 -a 2
		L_unittest_arreq dest 2 3
		L_unittest_eq "$a" 2
		local a='' dest=()
		L_argparse prog=prog -- -a -- dest action=remainder ---- -a 1 2 3 -a
		L_unittest_arreq dest 2 3 -a
		L_unittest_eq "$a" 1
	}
	{
		local tmp
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- -a action=append complete=filenames -- dest nargs=3 ---- --L_argparse_get_completion -a ''
		L_unittest_cmd -r dirnames -- L_argparse -- --asome -- -a action=append complete=dirnames -- dest nargs=3 ---- --L_argparse_get_completion -a ''
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs=3 ---- --L_argparse_get_completion -a b
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs=3 ---- --L_argparse_get_completion -a b c
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs="?" ---- --L_argparse_get_completion -a b
		L_unittest_cmd -r filenames -- L_argparse -- --asome -- dest complete=filenames nargs="?" ---- --L_argparse_get_completion --ignoreme b
		L_unittest_cmd -f L_argparse -- --asome nargs="**"
	}
	{
		L_argparse -- --foo action=store_true -- arg nargs="*" ---- a b c
		L_unittest_eq "$foo" false
		L_unittest_arreq arg a b c
		L_argparse -- --foo action=store_true -- arg nargs="*" ---- --foo a b c
		L_unittest_eq "$foo" true
		L_unittest_arreq arg a b c
	}
}

_L_test_z_argparse5() {
	{
		local foo bar baz cmd sub
		cmd=(
			L_argparse \
			-- --foo action=store_true help='foo help' \
			-- call=subparser dest=sub \
			'{' \
				name=aa description='a help' \
				-- bar type=int help='bar help' \
			'}' \
			'{' \
				bb description='b help' \
				-- --baz choices='X Y Z' help='baz help' \
			'}' \
			----
		)
		L_unittest_cmd -c "${cmd[@]}" --foo aa 1
		L_unittest_eq "$foo" true
		L_unittest_eq "$bar" 1
		L_unittest_arreq sub aa 1
		L_unittest_cmd -c "${cmd[@]}" bb --baz X
		L_unittest_arreq sub bb --baz X
		L_unittest_eq "$baz" X
		#
		L_unittest_cmd -r "plain${L_GS}aa${L_GS}a help" \
			"${cmd[@]}" --L_argparse_get_completion --foo a
		L_unittest_cmd -r \
			"plain${L_GS}X.*plain${L_GS}Y.*plain${L_GS}Z" \
			"${cmd[@]}" --L_argparse_get_completion bb --baz ''
	}
	{
		L_unittest_cmd -r 'missing.*\{' ! L_argparse -- dest=sub class=subparser ----
		L_unittest_cmd -r 'missing.*\}' ! L_argparse -- dest=sub class=subparser { ----
		L_unittest_cmd -r 'missing.*\}' ! L_argparse -- dest=sub class=subparser } ----
		L_unittest_cmd -r 'name' ! L_argparse -- dest=sub class=subparser { } ----
		L_unittest_cmd -r 'quoting' ! L_argparse -- dest=sub class=subparser { aliases="a'" } ----
		L_unittest_cmd -r 'name' ! L_argparse -- dest=sub class=subparser { a name=b } ----
	}
	{
		L_log "check argparse internal args"
		L_unittest_cmd -r '' L_argparse prog=progname ---- --L_argparse_bash_completion
	}
}

_L_test_z_argparse6_call_function() {
	local cmd
	# "'
	{
		L_log "check argparse call=function 1"
		CMD_1() { L_argparse -- --one default=default ---- "$@"; echo "1 one=$one three=$three"; return 100; }
		CMD_2() { L_argparse -- --two choices='AA AB CC' ---- "$@"; echo "2 two=$two three=$three"; }
		cmd=(L_argparse show_default=1 -- --three default= -- call=function prefix=CMD_ subcall=yes ----)
		local one two three
		L_unittest_cmd -e 100 -r "1 one=one three=" "${cmd[@]}" 1 --one one
		L_unittest_cmd -r "2 two=AA three=" "${cmd[@]}" 2 --two AA
		L_unittest_cmd -r "2 two=AB three=" "${cmd[@]}" 2 --two AB
		L_unittest_cmd -r "2 two=CC three=a" "${cmd[@]}" --three a 2 --two CC
		L_unittest_cmd -r "invalid" ! "${cmd[@]}" 2 --two DD
		L_unittest_cmd -r "plain${L_GS}AA.*plain${L_GS}AB" \
			-- "${cmd[@]}" --L_argparse_get_completion 2 --two A
		L_log "check that show_default is inherited by subparsers"
		L_unittest_cmd -r '--one.*(default: default)' "${cmd[@]}" 1 -h
		L_log "check that default works"
		L_unittest_cmd -r '1 one=default three=' -e 100 "${cmd[@]}" 1
		unset -f CMD_1 CMD_2
	}
	{
		L_log "check argparse call=function 2"
		CMD_1() { L_argparse -- --one ---- "$@"; echo "1 one=$one three=$three"; return 100; }
		CMD_2() { L_argparse -- --two choices='AA AB CC' ---- "$@"; echo "2 two=$two three=$three"; }
		cmd=(L_argparse -- --three default= -- call=function prefix=CMD_ subcall=detect ----)
		local one two three
		L_unittest_cmd -e 100 -r "1 one=one three=" "${cmd[@]}" 1 --one one
		L_unittest_cmd -r "2 two=AA three=" "${cmd[@]}" 2 --two AA
		L_unittest_cmd -r "2 two=AB three=" "${cmd[@]}" 2 --two AB
		L_unittest_cmd -r "2 two=CC three=a" "${cmd[@]}" --three a 2 --two CC
		L_unittest_cmd -r "invalid" ! "${cmd[@]}" 2 --two DD
		L_unittest_cmd -r "plain${L_GS}AA.*plain${L_GS}AB" \
			-- "${cmd[@]}" --L_argparse_get_completion 2 --two A
		unset -f CMD_1 CMD_2
	}
	if ((L_HAS_BASH4_0)); then
		local IFS=f
	fi
	{
		L_log "check argparse call=function 3 with IFS=$IFS"
		dump() {
			local OLDIFS=$IFS IFS=' '
			echo "[${FUNCNAME[*]}] option=${option:-} one=${one:-} two=${two:-} three=$three four=${four[*]:-} IFS=$(printf %q "$OLDIFS")"
			IFS=$OLDIFS
		}
		AAAaaa_bbb() { local option four; L_argparse -- --option default=default -- four ---- "$@"; dump; }
		AAAaaa_ccc() { local four;L_argparse -- four choices='eqq eww ddd' ---- "$@"; dump; }
		AAAaaa_bbb2() { echo hi; }
		AAAaaa_ccc2() { echo hi; }
		AAAbbb_ddd() { local four;L_argparse -- four type=file nargs="?" ---- "$@"; dump; }
		AAAbbb_eee() { local four;L_argparse -- four nargs="+" ---- "$@"; dump; }
		AAAbbb_ggg() { echo 'ggg do not call me'; }
		AAA_aaa() { local one; L_argparse -- -1 --one type=dir -- call=function prefix=AAAaaa_ ---- "$@"; }
		AAA_bbb() { local two; L_argparse -- -2 --two choices='AA AB CC' -- call=function prefix=AAAbbb_ ---- "$@"; }
		AAA_fff() { echo 'fff do not call me'; }
		AAA_hhh() { : <<EOF
			docs
EOF
			L_argparse ---- "$@"
			wrapper;
		}
		local three argparse=(L_argparse show_default=1 -- -3 --three default= -- call=function prefix=AAA_ ----)
		#
		L_log "argparse6 check is_ok_to_call detection"
		local _L_opt_prefix=("") _L_opti=0 _L_opt_subcall=("detect")
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAaaa_bbb
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAaaa_ccc
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAAaaa_bbb2
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAAaaa_ccc2
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAbbb_ddd
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAAbbb_eee
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAAbbb_ggg
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAA_aaa
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAA_bbb
		L_unittest_cmd ! _L_argparse_sub_function_is_ok_to_call AAA_fff
		L_unittest_cmd _L_argparse_sub_function_is_ok_to_call AAA_hhh
		unset _L_opt_prefix _L_opti _L_opt_subcall
		#
		L_log "argparse6 check calls"
		L_unittest_cmd -r "three= four=123" "${argparse[@]}" aaa bbb 123
		L_unittest_cmd -r "one=/tmp two= three=three four=ddd" "${argparse[@]}" -3 three aaa -1 /tmp ccc ddd
		L_unittest_cmd -r "does not exists" ! "${argparse[@]}" -3 three aaa -1 fdsa ccc ddd
		L_unittest_cmd -r "unrecognized option" ! "${argparse[@]}" aaa -2 ccc
		L_unittest_cmd -r "unrecognized option" ! "${argparse[@]}" bbb -1 ddd
		L_unittest_cmd -r "required" ! "${argparse[@]}" aaa bbb
		L_unittest_cmd -r "invalid choice" ! "${argparse[@]}" aaa ccc 123
		L_unittest_cmd -r "unrecognized command" ! "${argparse[@]}" aaa ddd
		L_unittest_cmd -r "one= two= three= four=" "${argparse[@]}" bbb ddd
		L_unittest_cmd -r "file" ! "${argparse[@]}" bbb ddd /tmp
		L_unittest_cmd -r "four=/dev/stdout" "${argparse[@]}" bbb ddd /dev/stdout
		L_unittest_cmd -r "four=a b c d" "${argparse[@]}" bbb eee a b c d
		#
		L_log "argparse6 check subparser completion is ok"
		L_unittest_cmd -r "plain${L_GS}aaa.*plain${L_GS}bbb" "${argparse[@]}" --L_argparse_get_completion ''
		L_unittest_cmd -r "directory" "${argparse[@]}" --L_argparse_get_completion aaa -1 ''
		L_unittest_cmd -r "plain${L_GS}bbb.*plain${L_GS}bbb2" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' b
		L_unittest_cmd -r "plain${L_GS}ccc.*plain${L_GS}ccc2" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' c
		L_unittest_cmd -r "plain${L_GS}eqq.*plain${L_GS}eww.*plain${L_GS}ddd" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc ''
		L_unittest_cmd -r "plain${L_GS}eqq.*plain${L_GS}eww" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc 'e'
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc 'ek'
		L_unittest_cmd -r "plain${L_GS}eqq" "${argparse[@]}" --L_argparse_get_completion aaa -1 'ff' ccc 'eq'
		L_unittest_cmd -r "filenames" "${argparse[@]}" --L_argparse_get_completion bbb -1 -invalid ddd ''
		L_unittest_cmd -r "plain${L_GS}ddd" "${argparse[@]}" --L_argparse_get_completion bbb ddd
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion bbb ddde
		L_unittest_cmd -r "filenames" "${argparse[@]}" --L_argparse_get_completion bbb -1 -invalid --option=bla ddd '/dev/fd/'
		#
		L_log "argparse6 check completion of subparsers is ok"
		L_unittest_cmd -r "fff do not call me" "${argparse[@]}" fff
		L_unittest_cmd -r "ggg do not call me" "${argparse[@]}" bbb ggg
		L_unittest_cmd -r "plain${L_GS}fff" "${argparse[@]}" --L_argparse_get_completion fff
		L_unittest_cmd -r "plain${L_GS}ggg" "${argparse[@]}" --L_argparse_get_completion bbb ggg
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion fff ''
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion bbb ggg ''
		L_unittest_cmd -r "^plain${L_GS}-h.*plain${L_GS}--help$" "${argparse[@]}" --L_argparse_get_completion hhh ''
		L_unittest_cmd -r "^$" "${argparse[@]}" --L_argparse_get_completion hh ''
		#
		L_log "argparse6 check default is inherited"
		L_unittest_cmd -jr "-3, --three THREE.*\(default: ''\)" "${argparse[@]}" -h
		L_unittest_cmd -jr "--option OPTION.*\(default: default\)" "${argparse[@]}" aaa bbb -h
		#
		unset -f dump AAAaaa_bbb AAAaaa_ccc AAAbbb_ddd AAAbbb_eee AAA_aaa AAA_bbb AAAaaa_bbb2 AAAaaa_ccc2
	}
}

_L_test_z_argparse7_custom_prefix() {
	{
		L_log "check argparse prefix_chars"
		local o
		local c=(prefix_chars='-+' -- +o flag=1 -- -o flag=0 ----)
		L_argparse "${c[@]}"
		L_unittest_vareq o 1
		L_argparse "${c[@]}" +o
		L_unittest_vareq o 1
		L_argparse "${c[@]}" +o -o
		L_unittest_vareq o 0
		#
		local o question option
		local c=(prefix_chars='/' -- /o flag=1 -- /? dest=question flag=1 -- /option ----)
		L_argparse "${c[@]}"
		L_unittest_vareq o 0
		L_unittest_vareq question 0
		L_argparse "${c[@]}" /o
		L_unittest_vareq o 1
		L_unittest_vareq question 0
		L_argparse "${c[@]}" /o /?
		L_unittest_vareq o 1
		L_unittest_vareq question 1
		L_argparse "${c[@]}" /o /? /option c
		L_unittest_vareq o 1
		L_unittest_vareq question 1
		L_unittest_vareq option c
	}
	{
		L_log "check argparse has errors on invalid"
		L_unittest_cmd -r 'error' ! L_argparse -- -"option with space" ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --"option with space" ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- arg twice ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --option$'\n'newline ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --option$'\t'tab ---- -h
		L_unittest_cmd -r 'error' ! L_argparse -- --option dest='in valid' ---- -h
	}
}

_L_test_z_argparse8_one_dash_long_option() {
	{
		local o option
		L_argparse -- -o -- -option ----
		L_unittest_vareq o ''
		L_unittest_vareq option ''
		L_argparse -- -o -- -option ---- -option arg
		L_unittest_vareq o ''
		L_unittest_vareq option arg
		L_argparse -- -o default= -- -option default= ---- -o arg
		L_unittest_vareq o arg
		L_unittest_vareq option ''
		L_argparse -- -o default= -- -option default= ---- -opt arg
		L_unittest_vareq o ''
		L_unittest_vareq option arg
		L_argparse -- -o default= -- -option default= ---- -o pt -option arg
		L_unittest_vareq o pt
		L_unittest_vareq option arg
		local p t o
		L_argparse -- -p flag=1 -- -t flag=1 -- -o flag=1 -- -option default= ---- -pto -option a
		L_unittest_vareq p 1
		L_unittest_vareq t 1
		L_unittest_vareq o 1
		L_unittest_vareq option a
	}
}

_L_test_z_argparse9_time_profile() {
	local time uv
	uv=$L_DIR/argparse_uv.sh
	check() {
		local time output
		output=$(
			TIMEFORMAT="%R"
			{ time "$uv" "$@" ;} 2>&1
		)
		L_unittest_cmd L_regex_match "$output" "Options:"
		time=${output//*$'\n'}
		echo "$time"
		L_unittest_cmd L_float_cmp "$time" -gt 0.1
		L_unittest_cmd L_float_cmp "$time" -lt 1.5
	}
	check -h
	check run -h
}

_L_test_path() {
	local v
	{
		tester() { local v; L_basename -v v "$1"; L_unittest_vareq v "$2"; }
		tester /foo/bar.txt bar.txt
		tester /foo/.bar .bar
		tester /foo/bar/ ''
		tester /foo/. .
		tester /foo/.. ..
		tester . .
		tester .. ..
		tester //host host
	}
	{
		tester() { local v; L_dirname -v v "$1"; L_unittest_vareq v "$2"; }
		tester '' .
		tester . .
		tester .. .
		tester / /
		tester /a /
		tester ../a ..
		tester /a/b /a
		tester a/b a
		tester /a/b/c /a/b
		tester a/b/c a/b
	}
	{
		tester() { local v; L_extension -v v "$1"; caller; L_unittest_vareq v "$2"; }
		tester /foo/bar.txt .txt
		tester /foo/bar. .
		tester /foo/bar ''
		tester /foo/bar.txt/bar.cc .cc
		tester /foo/bar.txt/bar. .
		tester /foo/bar.txt/bar ''
		tester /foo/. ''
		tester /foo/.. ''
		tester /foo/.hidden ''
		tester /foo/..bar '.bar'
	}
	{
		tester() { local v; L_stem -v v "$1"; caller; L_unittest_vareq v "$2"; }
		tester /foo/bar.txt bar
		tester /foo/.bar .bar
		tester foo.bar.baz.tar foo.bar.baz
		tester . .
		tester .. ..
		tester /foo/bar bar
	}
	{
		tester() { local v; L_extensions -v v "$1"; caller; L_unittest_arreq v "${@:2}"; }
		tester my/library.tar.gar .tar .gar
		tester my/library.tar.gz .tar .gz
		tester my/library
	}
	{
		tester() { local v; L_relative_to -v v "$1" "$2"; caller; L_unittest_arreq v "$3"; }
		tester /etc/passwd / etc/passwd
		tester /etc/passwd /etc passwd
		tester /etc/passwd /usr ../etc/passwd
		tester /a /a/b/c ../..
		tester /a/b /a/b/c ..
		tester /a/b/c /a/b/c .
		tester /a/b/c/d /a/b/c d
		tester /a/b/c/d/e /a/b/c d/e
		tester /a/b/d /a/b/c ../d
		tester /a/b/d/e /a/b/c ../d/e
		tester /a/d /a/b/c ../../d
		tester /a/d/e /a/b/c ../../d/e
		tester /d/e/f /a/b/c ../../../d/e/f
		tester /d/e/f /a/b/c ../../../d/e/f

		tester /\ \ \ \ a\ \ \ b/å/⮀\*/\! /\ \ \ \ a\ \ \ b/å/⮀/xäå/\? ../../../⮀\*/\!
		tester / /A ..
		tester /A / A
		tester /\ \ \&\ /\ \ \!/\*/\\\\/E / \ \ \&\ /\ \ \!/\*/\\\\/E
		tester / /\ \ \&\ /\ \ \!/\*/\\\\/E ../../../../..
		tester /\ \ \&\ /\ \ \!/\*/\\\\/E /\ \ \&\ /\ \ \!/\?/\\\\/E/F ../../../../\*/\\\\/E
		tester /X/Y /\ \ \&\ /\ \ \!/C/\\\\/E/F ../../../../../../X/Y
		tester /\ \ \&\ /\ \ \!/C /A ../\ \ \&\ /\ \ \!/C
		tester /A\ /\ \ \!/C /A\ /B ../\ \ \!/C
		tester /Â/\ \ \!/C /Â/\ \ \!/C .
		tester /\ \ \&\ /B\ /\ C /\ \ \&\ /B\ /\ C/D ..
		tester /\ \ \&\ /\ \ \!/C /\ \ \&\ /\ \ \!/C/\\\\/Ê ../..
		tester /Å/\ \ \!/C /Å/\ \ \!/D ../C
		tester /.A\ /\*B/C /.A\ /\*B/\\\\/E ../../C
		tester /\ \ \&\ /\ \ \!/C /\ \ \&\ /D ../\ \ \!/C
		tester /\ \ \&\ /\ \ \!/C /\ \ \&\ /\\\\/E ../../\ \ \!/C
		tester /\ \ \&\ /\ \ \!/C /\\\\/E/F ../../../\ \ \&\ /\ \ \!/C
		tester /home/part1/part2 /home/part1/part3 ../part2
		tester /home/part1/part2 /home/part4/part5 ../../part1/part2
		tester /home/part1/part2 /work/part6/part7 ../../../home/part1/part2
		tester /home/part1 /work/part1/part2/part3/part4 ../../../../../home/part1
		tester /home /work/part2/part3 ../../../home
		tester / /work/part2/part3/part4 ../../../..
		tester /home/part1/part2 /home/part1/part2/part3/part4 ../..
		tester /home/part1/part2 /home/part1/part2/part3 ..
		tester /home/part1/part2 /home/part1/part2 .
		tester /home/part1/part2 /home/part1 part2
		tester /home/part1/part2 /home part1/part2
		tester /home/part1/part2 / home/part1/part2
		tester /home/part1/part2 /work ../home/part1/part2
		tester /home/part1/part2 /work/part1 ../../home/part1/part2
		tester /home/part1/part2 /work/part1/part2 ../../../home/part1/part2
		tester /home/part1/part2 /work/part1/part2/part3 ../../../../home/part1/part2
		tester /home/part1/part2 /work/part1/part2/part3/part4 ../../../../../home/part1/part2
		tester home/part1/part2 home/part1/part3 ../part2
		tester home/part1/part2 home/part4/part5 ../../part1/part2
		tester home/part1/part2 work/part6/part7 ../../../home/part1/part2
		tester home/part1 work/part1/part2/part3/part4 ../../../../../home/part1
		tester home work/part2/part3 ../../../home
		tester . work/part2/part3 ../../..
		tester home/part1/part2 home/part1/part2/part3/part4 ../..
		tester home/part1/part2 home/part1/part2/part3 ..
		tester home/part1/part2 home/part1/part2 .
		tester home/part1/part2 home/part1 part2
		tester home/part1/part2 home part1/part2
		tester home/part1/part2 . home/part1/part2
		tester home/part1/part2 work ../home/part1/part2
		tester home/part1/part2 work/part1 ../../home/part1/part2
		tester home/part1/part2 work/part1/part2 ../../../home/part1/part2
		tester home/part1/part2 work/part1/part2/part3 ../../../../home/part1/part2
		tester home/part1/part2 work/part1/part2/part3/part4 ../../../../../home/part1/part2
	}
	{
		L_unittest_cmd ! L_dir_is_empty /
		L_unittest_cmd ! L_dir_is_empty /usr
		(
			f=$(mktemp -d)
			trap 'rm -rf "$f"' EXIT
			L_unittest_cmd L_dir_is_empty "$f"
		)
	}
}

_L_test_PATH() {
	local P="A:B:C"
	{
		L_path_append P A
		L_unittest_vareq P "A:B:C"
		L_path_append P B
		L_unittest_vareq P "A:B:C"
		L_path_append P C
		L_unittest_vareq P "A:B:C"
		L_path_append P D
		L_unittest_vareq P "A:B:C:D"
		L_path_append P B
		L_unittest_vareq P "A:B:C:D"
	}
	{
		L_path_prepend P X
		L_unittest_vareq P "X:A:B:C:D"
		L_path_prepend P X
		L_unittest_vareq P "X:A:B:C:D"
		L_path_prepend P B
		L_unittest_vareq P "X:A:B:C:D"
		L_path_prepend P Y
		L_unittest_vareq P "Y:X:A:B:C:D"
	}
	{
		L_path_remove P X
		L_unittest_vareq P "Y:A:B:C:D"
		L_path_remove P D
		L_unittest_vareq P "Y:A:B:C"
		L_path_remove P X
		L_unittest_vareq P "Y:A:B:C"
		L_path_remove P Y
		L_unittest_vareq P "A:B:C"
		P="A:A:A"
		L_path_remove P A
		L_unittest_vareq P ""
	}
}

_L_test_L_proc() {
	local proc exitcode line
	{
		L_proc_popen -Ipipe -Opipe proc cat
		L_proc_printf proc "%s\n" "Hello, world!"
		L_proc_close_stdin proc
		L_proc_read proc line
		L_proc_wait -c proc
		L_unittest_vareq line "Hello, world!"
	}
	{
		L_proc_popen -Ipipe -Opipe proc sed 's/w/W/g'
		L_proc_printf proc "%s\n" "Hello world"
		L_proc_close_stdin proc
		L_proc_read proc line
		L_proc_wait -c -v exitcode proc
		L_unittest_vareq line "Hello World"
		L_unittest_vareq exitcode 0
	}
	{
		declare a pid cmd exitcode
		L_proc_popen proc bash -c 'sleep 0.5; exit 123'
		while L_proc_poll proc; do
			sleep 0.1
		done
		L_proc_get_exitcode -v exitcode proc
		L_unittest_vareq exitcode 123
	}
	{
		declare proc tmp exitcode
		L_proc_popen proc bash -c 'sleep 2.5; exit 123'
		L_exit_to tmp L_proc_wait -t 2 -v exitcode proc
		L_unittest_vareq tmp 1
		L_exit_to tmp L_proc_wait -t 2 -v exitcode proc
		L_unittest_vareq tmp 0
		L_unittest_vareq exitcode 123
	}
	{
		declare a pid cmd exitcode
		L_proc_popen -Ipipe -Opipe proc sed 's/w/W/g'
		L_proc_get_stdin -v a proc
		L_proc_get_stdout -v a proc
		L_proc_get_stderr -v a proc
		L_proc_get_pid -v pid proc
		L_proc_get_cmd -v cmd proc
		L_proc_get_exitcode -v exitcode proc
		L_proc_printf proc "%s\n" "Hello world"
		L_proc_close_stdin proc
		L_proc_read proc line
		L_proc_wait -c -v exitcode proc
		L_unittest_vareq line "Hello World"
		L_unittest_vareq exitcode 0
	}
	{
		declare stdout proc
		L_proc_popen -Opipe proc bash -c 'echo stdout; sleep 0.01; echo stdout'
		L_proc_communicate -o stdout -t 2 -v exitcode proc
		L_unittest_vareq stdout $'stdout\nstdout\n'
		L_unittest_vareq exitcode 0
	}
	{
		declare stdout stderr proc
		L_proc_popen -Opipe -Epipe proc bash -c 'echo stdout; sleep 0.01; echo stderr >&2; echo stderr >&2; sleep 0.01; echo stdout'
		L_proc_communicate -o stdout -e stderr -t 2 -v exitcode proc
		L_unittest_vareq stdout $'stdout\nstdout\n'
		L_unittest_vareq stderr $'stderr\nstderr\n'
		L_unittest_vareq exitcode 0
	}
	{
		declare stdout stderr proc
		L_proc_popen -Ipipe -Opipe -Epipe proc bash -c 'echo stdout; echo stderr >&2; tr "[:lower:]" "[:upper:]"; exit 101'
		L_proc_read proc line
		L_unittest_vareq line stdout
		L_proc_communicate -i "input"$'\n' -o stdout -e stderr -v exitcode proc
		L_unittest_vareq stdout "INPUT"$'\n'
		L_unittest_vareq stderr "stderr"$'\n'
		L_unittest_vareq exitcode 101
	}
	{
		local leftovers=(/tmp/L_*)
		L_unittest_arreq leftovers "/tmp/L_*"
	}
}

_L_test_all_getopts_have_local_OPTIND_OPTARG_OPTERR() {
	declare funcs1 funcs2 func tmp
	L_list_functions_with_prefix -v funcs1 L_
	L_list_functions_with_prefix -v funcs2 _L_
	for func in "${funcs1[@]}" "${funcs2[@]}"; do
		tmp=$(declare -f "$func")
		if [[ "$tmp" == *"while getopts"* ]]; then
			L_unittest_cmd L_regex_match "$tmp" "local.*OPTIND OPTARG OPTERR"
		fi
	done
}

_L_test_check_v_comment() {
	awk '
  	/^#/{prev=prev $0 "\n";next}
  	/L_.*[(][)] [{] L_handle_v/{
    	if (!(prev ~ "@option -v")) {
      	gsub(/[(].*/, "")
      	print
      	fail++
    	}
  	}
  	{prev=""}
  	END{ exit(fail) }
	' "$L_LIB_SCRIPT" || exit 1
}

_L_test_no_duplicate_functions() {
	local dups funcs funcs_cnt vars vars_cnt
	funcs=$(grep -o $'^[^ \t]*()' "$L_LIB_SCRIPT" | sort)
	funcs_cnt=$(wc -l <<<"$funcs")
	L_unittest_cmd test "$funcs_cnt" -gt 200
	dups="$(uniq -d <<<"$funcs")"
	L_unittest_eq "$dups" ""
	#
	vars=$(grep -o $'^[^ \t]*=' "$L_LIB_SCRIPT" | sort)
	vars_cnt=$(wc -l <<<"$vars")
	L_unittest_cmd test "$vars_cnt" -gt 200
	dups="$(uniq -d <<<"$vars")"
	L_unittest_eq "$dups" ""
	L_unittest_cmd test "$funcs_cnt" -ne "$vars_cnt"
}

_L_test_source_test() {
	L_unittest_cmd bash "$L_DIR"/source_test.sh
	L_unittest_cmd bash "$L_DIR"/source_test.sh 1 2 3
}

_L_test_traceback_test() {
	L_unittest_cmd bash "$L_DIR"/traceback_test.sh
}

_L_test_quoted_maths() {
	L_unittest_cmd ! grep -n 'shift $((' $L_LIB_SCRIPT
	L_unittest_cmd ! grep -n 'return $((' $L_LIB_SCRIPT
	L_unittest_cmd ! grep -n 'return $?' $L_LIB_SCRIPT
	L_unittest_cmd ! grep -n 'test $? ' $L_LIB_SCRIPT
	L_unittest_cmd ! grep -n 'test $# ' $L_LIB_SCRIPT
	# L_unittest_cmd ! grep -n 'L_unittest_eq \"${.*[\*]}\"' $L_LIB_SCRIPT
}

_L_test_finally() {
	{
		func() {
			L_finally -r echo "$L_UUID"
		}
		L_unittest_cmd -o "$L_UUID" func
	}
	{
		func() {
			L_finally -r echo world
			L_finally -r echo -n 'Hello '
		}
		L_unittest_cmd -o "Hello world" func
	}
	{
		L_info "Test that L_finally_pop only affects current scope"
		func2() {
			L_finally_pop
			( L_finally_pop )
			L_finally -r printf 2
		}
		func() {
			L_finally -r printf 4
			printf 1
			func2
			( L_finally_pop )
			printf 3
		}
		L_unittest_cmd -o 1234 func
	}
	{
		L_info "Test L_finally_pop works"
		func() {
			L_finally echo -n 2
			echo -n 1
			L_finally_pop
			echo -n 3
			L_finally_pop
			echo -n 4
			L_finally_pop
		}
		L_unittest_cmd -o "1234" func
	}
	{
		L_info "Test exit is ok"
		func() (
			L_finally printf 2
			printf 1
			exit
		)
		L_unittest_cmd -o "12" func
		#
		func() (
			L_finally printf 2
			printf 1
		 	exit 234
		)
		L_unittest_cmd -e 234 -o "12" func
		#
		func() (
			L_finally -r exit 234
			exit 123
		)
		L_unittest_cmd -e 234 func
		#
		func() {
			L_finally -r printf 2
			printf 1
			return 234
		}
		L_unittest_cmd -e 234 -o 12 func
		#
		func() {
			L_finally -r eval 'printf 2'
			printf 1
			return 234
		}
		L_unittest_cmd -e 234 -o 12 func
	}
	{
		L_info "Test signal is ok"
		func() (
			L_finally printf 2
			printf 1
			L_raise
		)
		L_unittest_cmd -o "12" func
	}
}

###############################################################################

_L_get_all_variables() {
	unset SUPER _ FUNCNAME SUPER2 VARIABLES_BEFORE L_logrecord_loglevel SECONDS
	unset L_v IFS LC_ALL _L_TRAP_L
	declare -p | grep -Ev "^declare (-a|-r|-ar|--) (SHELLOPTS|BASH_LINENO|BASH_REMATCH|PIPESTATUS|COLUMNS|LINES|BASHOPTS)="
}

. "$(dirname "$0")"/../bin/L_lib.sh

VARIABLES_BEFORE=$(_L_get_all_variables)

. "$(dirname "$0")"/../bin/L_lib.sh test "$@"

# Check for any new variables.
diff -biw - <<<"$VARIABLES_BEFORE" <(_L_get_all_variables) | sed -n 's/^> /+ /p' || :
