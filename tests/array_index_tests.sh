_L_test_array_index() {
	# Test indexed array
	local -a arr=(1 2 3)
	local idx
	L_array_index -v idx arr 1
	L_unittest_eq "$idx" "0"

	L_array_index -v idx arr 2
	L_unittest_eq "$idx" "1"

	L_array_index -v idx arr 3
	L_unittest_eq "$idx" "2"

	# Test failure

arr=(1 2 3)
	if L_array_index arr 4; then
		echo "L_array_index should have failed"
		return 1
	fi

	# Test associative array
	if (( L_HAS_ASSOCIATIVE_ARRAY )); then
		local -A assoc=([one]=1 [two]=2 [three]=3)
		local key
		L_array_index -v key assoc 2
		L_unittest_eq "$key" "two"
	fi
}

_L_test_array_keys() {
	local keys

	# Empty array
	local -a empty_arr=() keys=()
	L_array_keys -v keys empty_arr
	L_unittest_eq "${#keys[@]}" "0"

	# Normal array
	local -a arr=(a b c)
	L_array_keys -v keys arr
	L_unittest_eq "${#keys[@]}" "3"
	# keys should be 0 1 2
	L_unittest_eq "${keys[*]}" "0 1 2"

	if (( L_HAS_ASSOCIATIVE_ARRAY )); then
		# Empty associative array
		local -A empty_assoc=()
		L_array_keys -v keys empty_assoc
		L_unittest_eq "${#keys[@]}" "0"

		# Associative array
		local -A assoc=([a]=1 [b]=2)
		L_array_keys -v keys assoc
		L_unittest_eq "${#keys[@]}" "2"
		
		# Sort keys for consistent comparison
		local sorted_keys
		# shellcheck disable=SC2207
		sorted_keys=($(printf "%s\n" "${keys[@]}" | sort))
		L_unittest_eq "${sorted_keys[*]}" "a b"
	fi
}

_L_test_args_index() {
	local idx
	L_args_index -v idx "World" "Hello" "World"
	L_unittest_eq "$idx" "1"

	L_args_index -v idx "Hello" "Hello" "World"
	L_unittest_eq "$idx" "0"

	if L_args_index -v idx "Missing" "Hello" "World"; then
		echo "L_args_index should have failed"
		return 1
	fi
}

_L_test_args() {
	# L_args_contain tests
	L_unittest_checkexit 0 L_args_contain 1 0 1 2
	L_unittest_checkexit 0 L_args_contain 1 2 1
	L_unittest_checkexit 0 L_args_contain 1 1 0
	L_unittest_checkexit 0 L_args_contain 1 1
	L_unittest_checkexit 1 L_args_contain 0 1
	L_unittest_checkexit 1 L_args_contain 0
}

_L_test_array_contains() {
	local arr
	
arr=(0 1 2)
	L_unittest_checkexit 0 L_array_contains arr 1
	
arr=(2 1)
	L_unittest_checkexit 0 L_array_contains arr 1
	
arr=(1 0)
	L_unittest_checkexit 0 L_array_contains arr 1
	
arr=(1)
	L_unittest_checkexit 0 L_array_contains arr 1
	
arr=(1)
	L_unittest_checkexit 1 L_array_contains arr 0
	
arr=()
	L_unittest_checkexit 1 L_array_contains arr 0
}
