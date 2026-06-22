f_xargs_e() {
	if [[ "$1" -ge 5 ]]; then
		return 1
	fi
	printf "%s:" "$1"
}

_L_test_xargs_extra_e() {
	local i
	local -a a=()
	for ((i = 0; i < 10; ++i)); do
		a+=("$i")
	done

	L_unittest_cmd -e 123 -o "0:1:2:3:4:" L_xargs -A a -n 1 f_xargs_e

	local out
	L_unittest_cmd -e 123 -v out L_xargs -A a -P 5 -n 1 f_xargs_e
	local -a arr
	IFS=: read -r -a arr <<<"$out"
	L_sort_bash -n arr
	L_unittest_arreq arr 0 1 2 3 4
}
