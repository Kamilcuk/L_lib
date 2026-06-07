_L_test_readarray_1() {
	local L_HAS_MAPFILE_D=0 L_HAS_MAPFILE=0
	_L_test_readarray_2
}

_L_test_readarray_2() {
	{
		local arr=(4 5 6)
		L_readarray -t arr < <(printf "1\n2\n3\n")
		L_unittest_arreq arr 1 2 3
	}
	{
		local arr=(4 5 6)
		L_readarray -t -d '' arr < <(printf "1\x002\x003\x00")
		L_unittest_arreq arr 1 2 3
	}
	{
		local arr=()
		L_readarray -t arr < <(printf "line1\n\nline3\n")
		L_unittest_arreq arr line1 "" line3
	}
	{
		local arr=()
		L_readarray -t -d ":" arr < <(printf "a:b::d:")
		L_unittest_arreq arr "a" "b" "" "d"
	}
	{
		local arr=()
		L_readarray -t -d ":" arr < <(printf "a:b:c:")
		L_unittest_arreq arr "a" "b" "c"
	}
	{
		local arr=()
		L_readarray arr < <(printf "a\nb\n")
		L_unittest_arreq arr $'a\n' $'b\n'
	}
	{
		# Partial line
		local arr=(a b c)
		L_readarray -t arr < <(printf "line1\npartial")
		L_unittest_arreq arr "line1" "partial"
	}
	{
		# Empty input
		local arr=(a b c)
		L_readarray arr < /dev/null
		L_unittest_eq "${#arr[@]}" 0
	}
	{
		# Overwriting existing array
		local arr=(old values)
		L_readarray -t arr < <(printf "new")
		L_unittest_arreq arr "new"
	}
	{
		# Limit count (-n)
		local arr=()
		L_readarray -t -n 2 arr < <(printf "1\n2\n3\n4\n")
		L_unittest_arreq arr 1 2
	}
	{
		# Limit count (-n) 0
		local arr=()
		L_readarray -t -n 0 arr < <(printf "1\n2\n3\n4\n")
		L_unittest_arreq arr 1 2 3 4
	}
	{
		# Skip lines (-s)
		local arr=()
		L_readarray -t -s 2 arr < <(printf "1\n2\n3\n4\n")
		L_unittest_arreq arr 3 4
	}
	{
		# Skip + Limit
		local arr=()
		L_readarray -t -s 1 -n 2 arr < <(printf "1\n2\n3\n4\n")
		L_unittest_arreq arr 2 3
	}
}

