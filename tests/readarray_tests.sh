_L_test_readarray_1() {
	local L_HAS_MAPFILE=0
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

_L_test_readarray_tail_0() {
	_L_printer() { printf "%s\n" {1..25}; }
	{
		# 1. without -t, without -n
		local arr=()
		L_readarray -s 21 arr < <(_L_printer)
		L_unittest_arreq arr $'22\n' $'23\n' $'24\n' $'25\n'
	}
	{
		# 2. with -t, without -n
		local arr=()
		L_readarray -t -s 21 arr < <(_L_printer)
		L_unittest_arreq arr 22 23 24 25
	}
	{
		# 3. without -t, with -n
		local arr=()
		L_readarray -s 21 -n 2 arr < <(_L_printer)
		L_unittest_arreq arr $'22\n' $'23\n'
	}
	{
		# 4. with -t, with -n
		local arr=()
		L_readarray -t -s 21 -n 2 arr < <(_L_printer)
		L_unittest_arreq arr 22 23
	}
}

_L_test_readarray_tail_1() {
	local L_HAS_MAPFILE=0
	_L_test_readarray_tail_0
}

_L_test_readarray_extra_0() {
	# Test custom FD -u
	{
		local arr=()
		L_readarray -t -u 3 arr 3< <(printf "fdline1\nfdline2\n")
		L_unittest_arreq arr fdline1 fdline2
	}
	# Test clearing of sparse arrays
	{
		local arr=()
		arr[10]=ten
		arr[20]=twenty
		L_readarray -t arr < <(printf "new")
		L_unittest_arreq arr "new"
		L_unittest_eq "${#arr[@]}" 1
	}
	# Test non-newline delimiter with -t
	{
		local arr=()
		L_readarray -t -d ":" arr < <(printf "x:y:z:")
		L_unittest_arreq arr x y z
	}
	# Test non-newline delimiter without -t
	{
		local arr=()
		L_readarray -d ":" arr < <(printf "x:y:z:")
		L_unittest_arreq arr "x:" "y:" "z:"
	}
	# Test non-newline delimiter with -s and -n
	{
		local arr=()
		L_readarray -t -d ":" -s 1 -n 2 arr < <(printf "a:b:c:d:e:")
		L_unittest_arreq arr b c
	}
}

_L_test_readarray_extra_1() {
	local L_HAS_MAPFILE=0
	_L_test_readarray_extra_0
}
