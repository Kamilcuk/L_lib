_L_test_poll_timeout() {
    local -a ret=()
    L_builtin poll -t 0.05 -v ret
    L_unittest_eq "${#ret[@]}" "0"
}

_L_test_poll_pipe() {
    local -a p=()
    L_builtin pipe p
    eval "echo 'hello' >&${p[1]}"
    
    local -a results=()
    L_builtin poll -t 0.1 -v results "${p[0]}:r"
    L_unittest_eq "${#results[@]}" "1"
    L_unittest_eq "${results[0]}" "${p[0]}:r"
    
    eval "exec ${p[0]}<&-"
    eval "exec ${p[1]}>&-"
}

_L_test_ppoll_atomic_signal() {
    local CAUGHT=0
    trap 'CAUGHT=1' USR1
    
    L_builtin sigmask -s USR1
    L_raise -USR1
    
    local -a results=()
    L_unittest_checkexit 1 L_builtin ppoll -u USR1 -t 0.1 -v results
    L_unittest_eq "$CAUGHT" "1"
    L_unittest_eq "${#results[@]}" "0"
    
    L_builtin sigmask -u USR1
}

_L_test_ppoll_all_signals() {
    local CAUGHT=0
    trap 'CAUGHT=1' USR1
    
    L_builtin sigmask -s ALL
    L_raise -USR1
    
    local -a results=()
    L_unittest_checkexit 1 L_builtin ppoll -u ALL -t 0.1 -v results
    L_unittest_eq "$CAUGHT" "1"
    L_unittest_eq "${#results[@]}" "0"
    
    L_builtin sigmask -u ALL
}
