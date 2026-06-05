
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
