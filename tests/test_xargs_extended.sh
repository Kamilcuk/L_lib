#!/usr/bin/env bash
set -euo pipefail

_L_test_L_xargs_callback_option() {
    # Test for the -c (callback) option
    callback_func() {
        if (( i < 3 )); then
            L_RET="item$((++i))"
        else
            L_RET=()
        fi
    }
    local i=0
    local output
    output=$(
        # On bash version 4.0 the set -e is NOT disabled in a while loop condition, which makes
        # the callback returning 1 trigger trap ERR, which makes it exit because L_trap_err exits.
        if (( L_BASH_VERSION / 0x100 == 0x400 )); then
            trap - ERR
        fi
        L_xargs -C 'callback_func' echo
    )
    L_unittest_eq "$output" "item1 item2 item3"
}

_L_test_L_xargs_solid_mode_option() {
    # Test for the -Z (solid mode) option
    local output
    output=$(printf "a b
c
d e" | L_xargs -Z -n 1 echo)
    L_unittest_eq "$output" "a b
c
d e"
}

_L_test_L_xargs_file_descriptor_option() {
    # Test for the -u (file descriptor) option
    local output
    exec 3< <(printf "fd_test1
fd_test2")
    output=$(L_xargs -u 3 echo)
    exec 3<&-
    L_unittest_eq "$output" "fd_test1 fd_test2"
}

_L_test_L_xargs_i_shorthand_option() {
    # Test for the -i shorthand option
    local output
    output=$(printf "file1
file2" | L_xargs -i echo "Processing {}")
    L_unittest_match "$output" "Processing file1
Processing file2"
}

_L_test_L_xargs_max_records_option() {
    # Test for the -L (max-records) option
    local output
    output=$(printf "1
2
3
4
5" | L_xargs -L 2 echo)
    L_unittest_eq "$output" "1 2
3 4
5"
}

_L_test_L_xargs_no_run_if_empty_option() {
    # Test for the -r (no-run-if-empty) option
    local output
    output=$(printf "" | L_xargs -r echo "this should not be printed")
    L_unittest_eq "$output" ""
}

_L_test_L_xargs_P_nproc_option() {
    # Test for -P nproc
    local output
    output=$(L_xargs -P nproc -n 1 bash -c 'echo "proc:${BASHPID:-123} val:$1"' -- <<<"1
2
3" | sort)
    L_unittest_match "$output" "proc:[0-9]+ val:[123]
proc:[0-9]+ val:[123]
proc:[0-9]+ val:[123]" "L_xargs -P nproc should run in parallel"
}

_L_test_L_xargs_process_killing() {
    L_command_exists pgrep || L_unittest_skip "pgrep not found"
    # Test that child processes are killed when L_xargs is killed
    # and that it happens quickly.
    local pid start end duration dur=1023491 before after beforelines afterlines bashpid
    L_bashpid_into bashpid
    dur=$bashpid$dur
    L_epochrealtime_usec -v start
    L_setx L_xargs -P 4 -I {} L_eval "exec sleep $dur" <<<"1 2 3 4" &
    pid=$!
    sleep 0.2
    before=$(pgrep -u $UID -x -f "sleep $dur" || :)
    kill $pid
    wait $pid 2>/dev/null || :
    after=$(pgrep -u $UID -x -f "sleep $dur" || :)
    L_epochrealtime_usec -v end
    duration=$((end - start))
    L_unittest_cmd eval "(( duration < 1000000 ))"
    sleep 0.1
    L_unittest_cmd -e 1 -j -v _ kill -0 "$pid"
    L_string_count_lines -v beforelines "$before"
    L_string_count_lines -v afterlines "$after"
    #
    if [[ -n "$before" ]]; then
        echo "before --"
        ps $before || :
        echo --
    fi
    if [[ -n "$after" ]]; then
        echo "after --"
        ps $after || :
        echo --
    fi
    L_unittest_cmd eval "(( beforelines - afterlines == 4 ))"
}
