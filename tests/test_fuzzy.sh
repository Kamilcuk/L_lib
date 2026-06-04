_L_test_fuzzy() {
    local L_v=()
    L_fuzzy_v help help me please
    L_unittest_arreq L_v "help"
    
    L_v=()
    L_fuzzy_v help hlp helpp hello
    L_unittest_success L_array_contains L_v hlp
    L_unittest_success L_array_contains L_v helpp
    L_unittest_failure L_array_contains L_v hello

    L_v=()
    L_fuzzy_v vrbose verbose
    L_unittest_arreq L_v "verbose"

    L_v=()
    L_fuzzy_v a abc de
    L_unittest_arreq L_v "abc"

    L_v=()
    L_fuzzy_v test
    L_unittest_arreq L_v

    L_v=()
    L_fuzzy_v "" a "" b
    L_unittest_arreq L_v ""

    L_v=()
    L_fuzzy abc abd acc bbc
    L_unittest_arreq L_v

    L_unittest_cmd -o "help" L_fuzzy help help me please
    }
