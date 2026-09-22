
_L_test_sort() {
	local IFS=' '
	local -x LC_ALL=C
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

_L_test_sort_robustness() {
	L_log "test sorting with equal elements and permutations (detect infinite loops)"
	local arr IFS=$' \t\n'
	# Duplicate elements
	arr=(0 0 0)
	L_sort_bash -n arr
	L_unittest_arreq arr 0 0 0
	
	# Permutations of 0 1 2
	local p
	for p in "0 1 2" "0 2 1" "1 0 2" "1 2 0" "2 0 1" "2 1 0"; do
		arr=( $p )
		L_sort_bash -n arr
		L_unittest_arreq arr 0 1 2
	done

	# Permutations of 0 1 0
	for p in "0 0 1" "0 1 0" "1 0 0"; do
		arr=( $p )
		L_sort_bash -n arr
		L_unittest_arreq arr 0 0 1
	done
}

_L_test_sort_unique() {
	L_log "test unique sorting with L_sort, L_sort_bash, and L_sort_cmd"
	local arr

	# Lexical sort with duplicates
	arr=(b a b c a c b)
	L_sort_bash -u arr
	L_unittest_arreq arr a b c

	arr=(b a b c a c b)
	L_sort_cmd -u arr
	L_unittest_arreq arr a b c

	arr=(b a b c a c b)
	L_sort -u arr
	L_unittest_arreq arr a b c

	# Numeric sort with duplicates
	arr=(3 1 2 2 3 1 2)
	L_sort_bash -u -n arr
	L_unittest_arreq arr 1 2 3

	arr=(3 1 2 2 3 1 2)
	L_sort_cmd -u -n arr
	L_unittest_arreq arr 1 2 3

	arr=(3 1 2 2 3 1 2)
	L_sort -u -n arr
	L_unittest_arreq arr 1 2 3

	# Reverse unique sort
	arr=(b a b c a c b)
	L_sort_bash -u -r arr
	L_unittest_arreq arr c b a

	arr=(b a b c a c b)
	L_sort_cmd -u -r arr
	L_unittest_arreq arr c b a

	arr=(b a b c a c b)
	L_sort -u -r arr
	L_unittest_arreq arr c b a

	# Single element or empty array
	arr=(a)
	L_sort_bash -u arr
	L_unittest_arreq arr a

	arr=()
	L_sort_bash -u arr
	L_unittest_arreq arr
}


_L_test_sort_compare_floats() {
	local tests=(
		"-0.1" "-0.01"
		"0" "0"
		"1" "2"
		"2" "1"
		"-1" "0"
		"0" "-1"
		"-2" "-1"
		"-1" "-2"
		"1.0" "1"
		"1.1" "1.01"
		"1.01" "1.1"
		"1.001" "1.01"
		"1.01" "1.001"
		"0.1" "0.01"
		"0.01" "0.1"
		"-0.01" "-0.1"
		"-1.1" "-1.01"
		"-1.01" "-1.1"
		"1.000" "1"
		"1" "1.000"
		"0.000" "0"
		"-0.000" "0"
		"0" "-0.000"
		"0001" "1"
		"001.20" "1.2"
		"-001.20" "-1.2"
		"10.99" "10.991"
		"10.991" "10.99"
		"123456789" "123456788"
		"-123456789" "-123456788"
		"999999999" "1000000000"
		"-1000000000" "-999999999"
		"10.91111" "10.9999"
		"1.8" "1.9123456789"
		"1.8" "1.8123456789"
		"1.8" "1.7123456789"
		"1.1" "1.2123456789"
		"1.1" "1.1123456789"
		"1.1" "1.0123456789"
		"1.2" "1.11"
		"1.2" "1.20"
		"1.12" "1.123"
		"1.0" "1."
		"       1" "     1"
		"       1DEF" "     1.0G"
		"       1DEF" "     1....G"
		"       1.123.234" "1.123 ABC"
		"  010.030 020.040 " " 020.050 060.070 "
	)
	_compare() {
		local awk my diff a=$1 b=$2
		awk=$(awk -v a="$a" -v b="$b" 'BEGIN { print (+a > +b) }')
		if "$1" "$a" "$b"; then
			my=1
		elif (( $? == 1 )); then
			my=0
		else
			exit 123
		fi
		diff=""
		if [[ $my != $awk ]]; then
			diff=DIFF
		fi
		if [[ -n "$diff" ]]; then
			printf '%-10s %i | %15q > %-15q | %6s | awk=%s | %s\n' "$1" "$i" "$a" "$b" "$my" "$awk" "$diff"
			exit 122
		fi
	}
	local my diff a b i
	for ((i=0;i<${#tests[@]};i+=2)); do
		local a=${tests[i]} b=${tests[i+1]}
		_compare _L_sort_compare_float_gt "$a" "$b"
		_compare _L_sort_compare_float_gt "$b" "$a"
	done
}

_L_test_sort_floats() {
	# General numeric float sort
	arr=(3.14 1.5 2.7 0.1 10.0 2.71)
	L_sort_bash -g arr
	L_unittest_arreq arr 0.1 1.5 2.7 2.71 3.14 10.0

	# Negative and positive floats
	arr=(1.5 -2.7 0 -0.1 2.0 -10.5)
	L_sort_bash -g arr
	L_unittest_arreq arr -10.5 -2.7 -0.1 0 1.5 2.0

	# Leading zeroes
	arr=(001.2 1.02 01.20 0.12 10.02)
	L_sort_bash -g arr
	L_unittest_arreq arr 0.12 1.02 001.2 01.20 10.02

	# Very different fractional lengths
	arr=(1.1 1.01 1.001 1.0001 1.00001)
	L_sort_bash -g arr
	L_unittest_arreq arr 1.00001 1.0001 1.001 1.01 1.1

	# Negative fractional ordering
	arr=(-1.1 -1.01 -1.001 -0.1 -0.01)
	L_sort_bash -g arr
	L_unittest_arreq arr -1.1 -1.01 -1.001 -0.1 -0.01

	# Numeric prefix parsing
	arr=(1DEF 1.0G 1.123.234 1.123foo 2abc)
	L_sort_bash -g arr
	L_unittest_arreq arr 1DEF 1.0G 1.123.234 1.123foo 2abc

	# Large integer parts
	arr=(999999999 1000000000 123456789 987654321)
	L_sort_bash -g arr
	L_unittest_arreq arr 123456789 987654321 999999999 1000000000

	# Duplicates
	arr=(3.1 1.2 3.10 1.20 2.5 3.1)
	L_sort_bash -u -g arr
	L_unittest_arreq arr 1.20 2.5 3.1

	# Reverse float sort
	arr=(3.14 1.5 2.7 0.1 10.0 2.71)
	L_sort_bash -g -r arr
	L_unittest_arreq arr 10.0 3.14 2.71 2.7 1.5 0.1
}
