_L_test_lseek_basic() {
    local tmpfile
    L_with_tmpfile_into tmpfile
    echo -n "abcdefghij" > "$tmpfile"

    {
        local pos char
        
        # SEEK_SET
        L_builtin lseek -v pos 3 2 SET
        L_unittest_eq "$pos" "2"
        read -n 1 -u 3 char
        L_unittest_eq "$char" "c"

        # SEEK_CUR
        L_builtin lseek -v pos 3 2 CUR
        L_unittest_eq "$pos" "5"
        read -n 1 -u 3 char
        L_unittest_eq "$char" "f"

        # SEEK_END
        L_builtin lseek -v pos 3 -1 END
        L_unittest_eq "$pos" "9"
        read -n 1 -u 3 char
        L_unittest_eq "$char" "j"
    } 3<"$tmpfile"
}

_L_test_lseek_numeric_whence() {
    local tmpfile
    L_with_tmpfile_into tmpfile
    echo -n "0123456789" > "$tmpfile"

    {
        local pos
        
        L_builtin lseek -v pos 3 5 0 # SET
        L_unittest_eq "$pos" "5"

        L_builtin lseek -v pos 3 2 1 # CUR
        L_unittest_eq "$pos" "7"

        L_builtin lseek -v pos 3 0 2 # END
        L_unittest_eq "$pos" "10"
    } 3<"$tmpfile"
}

_L_test_lseek_errors() {
    # Invalid FD
    L_unittest_checkexit 1 L_builtin lseek 999 0 SET
    # Invalid whence
    L_unittest_checkexit 2 L_builtin lseek 0 0 INVALID
}
