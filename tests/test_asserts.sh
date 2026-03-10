_L_asserts_runner() {
	( "$@" 2>/dev/null >/dev/null )
}

_L_test_asserts() {
	L_unittest_checkexit 28 _L_asserts_runner L_die "test"
	L_unittest_checkexit 42 _L_asserts_runner L_die -42 "test"
	L_unittest_checkexit 29 _L_asserts_runner L_panic "test"
	L_unittest_checkexit 43 _L_asserts_runner L_panic -43 "test"
	L_unittest_checkexit 29 _L_asserts_runner L_assert "myassert" false
	L_unittest_checkexit 44 _L_asserts_runner L_assert "-44 myassert" false
	L_unittest_checkexit 144 _L_asserts_runner L_assert "-144" false
}

_L_test_exit_check() {
	L_unittest_checkexit 0 _L_asserts_runner L_exit
	L_unittest_checkexit 1 _L_asserts_runner L_exit "test"
	L_unittest_checkexit 0 _L_asserts_runner L_check "mycheck" true
	L_unittest_checkexit 1 _L_asserts_runner L_check "mycheck" false
}
