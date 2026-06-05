_L_test_fuzzy() {
    local L_RET=()
    L_fuzzy_vL_RET help help me please
    L_unittest_arreq L_RET "help"
    
    L_RET=()
    L_fuzzy_vL_RET help hlp helpp hello
    L_unittest_success L_array_contains L_RET hlp
    L_unittest_success L_array_contains L_RET helpp
    L_unittest_failure L_array_contains L_RET hello

    L_RET=()
    L_fuzzy_vL_RET vrbose verbose
    L_unittest_arreq L_RET "verbose"

    L_RET=()
    L_fuzzy_vL_RET a abc de
    L_unittest_arreq L_RET "abc"

    L_RET=()
    L_fuzzy_vL_RET test
    L_unittest_arreq L_RET

    L_RET=()
    L_fuzzy_vL_RET "" a "" b
    L_unittest_arreq L_RET ""

    L_RET=()
    L_fuzzy abc abd acc bbc
    L_unittest_arreq L_RET

    L_unittest_cmd -o "help" L_fuzzy help help me please
    }
