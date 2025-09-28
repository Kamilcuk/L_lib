#!/usr/bin/env bash
cd "$(dirname "$0")/.."
. ./bin/L_lib.sh
ulimit -c 0
tmpf=/tmp/what_about_exit_trap.txt
: > "$tmpf"

_L_FINALLY_TERM_SIGNALS="SIGABRT SIGALRM SIGBUS SIGFPE SIGHUP SIGILL SIGINT SIGIO SIGPIPE SIGPROF SIGPWR SIGQUIT SIGSEGV SIGSTKFLT SIGSYS SIGTERM SIGTRAP SIGUSR1 SIGUSR2 SIGVTALRM SIGXCPU SIGXFSZ SIGRTMAX SIGRTMAX-1 SIGRTMAX-10 SIGRTMAX-11 SIGRTMAX-12 SIGRTMAX-13 SIGRTMAX-14 SIGRTMAX-2 SIGRTMAX-3 SIGRTMAX-4 SIGRTMAX-5 SIGRTMAX-6 SIGRTMAX-7 SIGRTMAX-8 SIGRTMAX-9 SIGRTMIN SIGRTMIN+1 SIGRTMIN+10 SIGRTMIN+11 SIGRTMIN+12 SIGRTMIN+13 SIGRTMIN+14 SIGRTMIN+2 SIGRTMIN+3 SIGRTMIN+4 SIGRTMIN+5 SIGRTMIN+6 SIGRTMIN+7 SIGRTMIN+8 SIGRTMIN+9"

get_test() {
  tester() {
    . ./bin/L_lib.sh
    ulimit -c 0
    echo $1:$2:test
    trap "echo $1:$2:exit" exit
    L_raise -$2
  }
  export -f tester
  (
  for i in $_L_FINALLY_TERM_SIGNALS; do
    bash -c "tester proc $i"
    echo proc:$i:$?
    #
    ( tester subshell $i )
    echo subshell:$i:$?
    echo "$a"
    #
    a=$( tester procsub $i )
    echo procsub:$i:$?
    echo "$a"
    #
  done >"$tmpf"
  )
  #
  for i in proc subshell procsub; do
    echo
    traps_with_exit=$(sed -n "s/^$i:\(.*\):exit$/\1/p" "$tmpf" | sort)
    traps_with_no_exit=$(comm -3 <(printf "%s\n" "$_L_FINALLY_TERM_SIGNALS" | sort) - <<<"$traps_with_exit")
    echo "$BASH_VERSION #$(wc -l <<<"$traps_with_exit") Traps with exit in $i:" $traps_with_exit
    echo "$BASH_VERSION #$(wc -l <<<"$traps_with_no_exit") Traps with no exit in $i:" $traps_with_no_exit
  done
}

get_inherit() {
  for i in $_L_FINALLY_TERM_SIGNALS; do
    trap "echo $i >&2" $i
  done
  #
  echo $BASH_VERSION
  a=$(
    set -x
    trap - SIGTERM
    trap -p $_L_FINALLY_TERM_SIGNALS
  )
  echo -n "Untrapped: "
  echo "$a" | awk '{print $NF}' | paste -sd' '
  echo
  trap - $_L_FINALLY_TERM_SIGNALS
}


case "$1" in
  '') get_test ;;
  i) get_inherit ;;
  iall)
    for i in 3.2 4.0 4.1 4.2 4.3 4.4 5.0 5.1 5.2 5.3; do
      docker run --rm -v $PWD:$PWD -w $PWD bash:$i ./scripts/what_about_exit_trap.sh i
    done
    ;;
  all)
    for i in 3.2 4.0 4.1 4.2 4.3 4.4 5.0 5.1 5.2 5.3; do
      docker run --rm -v $PWD:$PWD -w $PWD bash:$i ./scripts/what_about_exit_trap.sh
    done
    ;;
esac
