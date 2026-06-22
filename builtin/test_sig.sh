#!/usr/bin/env bash

# test_sig.sh - Unit tests for sigmask and sigunmask subcommands

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
enable -f "$DIR/build/L_builtin.so" L_builtin || { echo "Failed to load L_builtin"; exit 1; }

echo "Builtin loaded."

# Helper to check if a signal is masked
check_masked() {
    local sig=$1
    # Handle both USR1 and SIGUSR1
    L_builtin sigmask | grep -q -E "\b(SIG)?$sig\b"
}

# Test 1: sigmask blocking
echo "Test 1: sigmask blocking"
trap 'CAUGHT=1' USR1
CAUGHT=0
L_builtin sigmask -s USR1
check_masked USR1 || echo "FAIL: USR1 should be masked"

kill -USR1 $$
sleep 0.1 # Give it a moment (though it's synchronous in same process, but kernel delivery...)
if [[ ${CAUGHT:-0} -eq 1 ]]; then
    echo "FAIL: USR1 should have been blocked"
else
    echo "PASS: USR1 blocked"
fi

# Test 2: sigmask unblocking
echo "Test 2: sigmask unblocking"
L_builtin sigmask -u USR1
# Once unmasked, the pending signal should be delivered immediately.
# But in Bash, we might need to trigger a check.
# sigmask -u calls sigprocmask, which delivers to handler.
# Handler sets pending_traps.
# But sigmask -u doesn't call run_pending_traps().
# Wait, let's see.
: # A command to trigger trap checks
if [[ ${CAUGHT:-0} -eq 1 ]]; then
    echo "PASS: USR1 delivered after unblock"
else
    echo "FAIL: USR1 not delivered (CAUGHT=$CAUGHT)"
    # Try triggering traps
    L_builtin lseek 0 0 CUR >/dev/null
    if [[ ${CAUGHT:-0} -eq 1 ]]; then
        echo "PASS: USR1 delivered after lseek trigger"
    else
        echo "FAIL: USR1 still not delivered"
    fi
fi

# Test 3: sigunmask with pending signal
echo "Test 3: sigunmask with pending signal"
CAUGHT=0
L_builtin sigmask -s USR1
kill -USR1 $$
echo "Running sigunmask..."
ret=0
L_builtin sigunmask -s USR1 echo "SHOULD NOT RUN" || ret=$?
if [[ ${CAUGHT:-0} -eq 1 ]]; then
    echo "PASS: USR1 caught during sigunmask"
else
    echo "FAIL: USR1 NOT caught during sigunmask"
fi

if [[ $ret -eq $((128 + 10)) ]]; then # USR1 is 10 on most Linux
    echo "PASS: sigunmask returned 138 (128 + USR1)"
else
    # Check what USR1 is on this system
    usr1_val=$(kill -l USR1)
    if [[ $ret -eq $((128 + usr1_val)) ]]; then
        echo "PASS: sigunmask returned expected exit code ($ret)"
    else
        echo "FAIL: sigunmask returned $ret, expected $((128 + usr1_val))"
    fi
fi

# Test 4: sigunmask without pending signal
echo "Test 4: sigunmask without pending signal"
CAUGHT=0
L_builtin sigmask -s USR1
ret=0
out=$(L_builtin sigunmask -s USR1 echo "RUNS") || ret=$?
if [[ "$out" == "RUNS" ]]; then
    echo "PASS: sigunmask ran the command"
else
    echo "FAIL: sigunmask did not run command (out='$out')"
fi
if [[ $ret -eq 0 ]]; then
    echo "PASS: sigunmask returned 0"
else
    echo "FAIL: sigunmask returned $ret"
fi

echo "Tests completed."
