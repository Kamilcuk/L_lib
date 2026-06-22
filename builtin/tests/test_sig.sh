_L_test_sig_blocking() {
    local CAUGHT=0
    trap 'CAUGHT=1' USR1
    
    # Block USR1
    L_builtin sigmask -s USR1
    L_unittest_contains "$(L_builtin sigmask)" "SIGUSR1"

    L_raise -USR1
    sleep 0.05
    L_unittest_eq "$CAUGHT" "0" "USR1 should have been blocked"
    
    # Clean up by unblocking
    L_builtin sigmask -u USR1
}

_L_test_sig_unblocking() {
    local CAUGHT=0
    trap 'CAUGHT=1' USR1
    
    # Block USR1, send it, then unblock it
    L_builtin sigmask -s USR1
    L_raise -USR1
    L_unittest_eq "$CAUGHT" "0"

    L_builtin sigmask -u USR1
    # Trigger bash to check traps
    : 
    L_unittest_eq "$CAUGHT" "1" "USR1 should be caught after unblock"
}

_L_test_sig_sigunmask_pending() {
    local CAUGHT=0
    trap 'CAUGHT=1' USR1
    
    L_builtin sigmask -s USR1
    L_raise -USR1
    
    local ret=0
    L_builtin sigunmask -s USR1 echo "SHOULD NOT RUN" || ret=$?
    L_unittest_eq "$CAUGHT" "1" "USR1 should have been caught"
    
    local usr1_val=$(kill -l USR1)
    L_unittest_eq "$ret" "$((128 + usr1_val))"
}

_L_test_sig_sigunmask_no_pending() {
    local CAUGHT=0
    trap 'CAUGHT=1' USR1
    
    L_builtin sigmask -s USR1
    local out
    out=$(L_builtin sigunmask -s USR1 echo "RUNS")
    L_unittest_eq "$out" "RUNS"
    L_unittest_eq "$CAUGHT" "0"
    
    L_builtin sigmask -u USR1
}

_L_test_sig_all_block_unblock() {
    # Block ALL signals
    L_builtin sigmask -s ALL
    local blocked_count=$(L_builtin sigmask | wc -w)
    # Check that a large number of signals are blocked
    (( blocked_count > 10 )) || L_unittest_eq "blocked signals count: $blocked_count" "greater than 10"

    # Unblock ALL
    L_builtin sigmask -u ALL
    local blocked_count_after=$(L_builtin sigmask | wc -w)
    L_unittest_eq "$blocked_count_after" "0"
}

_L_test_sig_sigunmask_all() {
    L_builtin sigmask -s ALL
    local out
    out=$(L_builtin sigunmask -s ALL echo "RUNNING")
    L_unittest_eq "$out" "RUNNING"
    L_builtin sigmask -u ALL
}
