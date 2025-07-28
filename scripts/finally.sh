#!/bin/bash
. "$(dirname "$0")"/../bin/L_lib.sh

###############################################################################

test1() {
  L_finally 'echo finally from test1 pop $L_FINALLY_SIGNAL'
  true some command, does not matter
  L_finally_pop
}

test2() {
  (
    L_finally 'echo finally from test2 $L_FINALLY_SIGNAL'
    exit 1
  )
}

test3() {
  L_finally -r 'echo finally from test3 $L_FINALLY_SIGNAL'
  return 1
}

test4() {
  L_finally -r 'echo finally from test4 $L_FINALLY_SIGNAL'
  true something || return 1
  true something else || return 2
  false och no || return 3
}

test5() {
  L_finally 'echo finally from test5 $L_FINALLY_SIGNAL'
  true something || return 1
  true something else || return 2
  false och no || return 3
}

test1
test2
test3
test4
test5
L_finally 'echo finally from main pop $L_FINALLY_SIGNAL'
L_finally_pop
L_finally 'echo finally from main $L_FINALLY_SIGNAL'
