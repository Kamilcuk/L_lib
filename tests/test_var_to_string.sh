# shellcheck disable=SC2178
_L_test_var_to_string_normal() {
	local tmp i
	#
	local a=1 b=123
	L_var_to_string -v tmp a
	eval "b=$tmp"
	L_unittest_vareq b "$a"
	#
	local a="" b=123
	L_var_to_string -v tmp a
	eval "b=$tmp"
	L_unittest_vareq b "$a"
	#
	local -a a=()
	local b=123
	L_var_to_string -v tmp a
	eval "b=$tmp"
	L_unittest_arreq a ${b[@]:+"${b[@]}"}
	#
	unset b
	local -a arr=("$L_SAFE_ALLCHARS")
	local brr=123
	L_var_to_string -v tmp arr
	eval "brr=$tmp"
	L_unittest_arreq arr ${brr[@]:+"${brr[@]}"}
	#
	unset b
	local -a arr=("$L_ALLCHARS")
	L_var_to_string -v tmp arr
	local -a brr="$tmp"
	L_unittest_arreq arr ${brr[@]:+"${brr[@]}"}
}

_L_test_var_to_string_assoc() {
	if (( !L_HAS_ASSOCIATIVE_ARRAY )); then
		L_unittest_skip "No associative array"
		return
	fi

	unset a b
	local -A a=() b=([1]=2 [3]=4)
	L_var_to_string -v tmp a
	eval "b=$tmp"
	L_unittest_cmd L_asa_cmp a b
	L_unittest_eq "A${a[*]+${!a[*]}}" "A${b[*]+${!b[*]}}"
	L_unittest_eq "A${a[*]+${a[*]}}" "A${b[*]+${b[*]}}"
	L_unittest_eq "$((${a[@]+${#a[@]}}+0))" 0

}

_L_test_var_to_string_assoc_space() {
	if (( !L_HAS_ASSOCIATIVE_ARRAY )); then
		L_unittest_skip "No associative array"
		return
	fi
	if (( !L_HAS_BASH4_1 )); then
		L_unittest_skip "requires Bash4.1"
		return
	fi

	local -A a=(["$L_SAFE_ALLCHARS"]="$L_SAFE_ALLCHARS") b=([1]=2 [3]=4)
	L_var_to_string -v tmp a
	eval "b=$tmp"
	L_unittest_cmd L_asa_cmp a b
	L_unittest_eq "${!a[*]}" "${!b[*]}"
	L_unittest_eq "${a[*]}" "${b[*]}"
	L_unittest_eq "${#a[@]}" 1
	L_unittest_eq "${#b[@]}" 1
	L_unittest_eq "${a["$L_SAFE_ALLCHARS"]}" "$L_SAFE_ALLCHARS"
	L_unittest_eq "${b["$L_SAFE_ALLCHARS"]}" "$L_SAFE_ALLCHARS"
	#
	local -A a=(["$L_ALLCHARS"]="$L_ALLCHARS") b=([1]=2 [3]=4)
	L_var_to_string -v tmp a
	local -A b="$tmp"
	L_unittest_cmd L_asa_cmp a b
	L_unittest_eq "${!a[*]}" "${!b[*]}"
	L_unittest_eq "${a[*]}" "${b[*]}"
	L_unittest_eq "${#a[@]}" 1
	L_unittest_eq "${#b[@]}" 1
	L_unittest_eq "${a["$L_ALLCHARS"]}" "$L_ALLCHARS"
	L_unittest_eq "${b["$L_ALLCHARS"]}" "$L_ALLCHARS"
}

_L_test_var_to_string_scalar_2() {
	local a="  leading trailing  " b="inside  space" c=$'with
newlines' d=$'	with	tabs	'
	local tmp
	local a2 b2 c2 d2

	L_var_to_string -v tmp a
	eval "a2=$tmp"
	L_unittest_vareq a2 "$a"

	L_var_to_string -v tmp b
	eval "b2=$tmp"
	L_unittest_vareq b2 "$b"

	L_var_to_string -v tmp c
	eval "c2=$tmp"
	L_unittest_vareq c2 "$c"

	L_var_to_string -v tmp d
	eval "d2=$tmp"
	L_unittest_vareq d2 "$d"
}

_L_test_var_to_string_array_2() {
	local -a a=("  first  " "second  element" $'third
with
newlines' $'	fourth	')
	local tmp
	local -a a2

	L_setx L_var_to_string -v tmp a
	printf "%q\n" "$tmp"
	eval "a2=$tmp"
	L_unittest_arreq a2 "${a[@]}"
}

_L_test_var_to_string_assoc_2() {
	if (( !L_HAS_ASSOCIATIVE_ARRAY )); then
		L_unittest_skip "no associative array"
		return
	fi
	if (( !L_HAS_BASH4_1 )); then
		L_unittest_skip "requires Bash4.1"
		return
	fi

	local -A a1=(
		["  key 1  "]="  value 1  "
		[$'key\n2']=$'value\n2'
		[$'\tkey\t3']=$'\tvalue\t3'
	)
	local tmp
	local -A a2
	L_var_to_string -v tmp a1
	eval "a2=$tmp"
	L_pretty_print -w100 a1
	L_pretty_print -w100 a2
	L_unittest_cmd L_asa_cmp a1 a2
}
