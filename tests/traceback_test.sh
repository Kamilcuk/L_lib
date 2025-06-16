#!/usr/bin/env bash
. "$(dirname "$0")"/../bin/L_lib.sh

if [[ "$1" == "show"*"nomapfile" ]]; then
  L_HAS_MAPFILE=0
fi
if [[ "$1" == "show"* ]]; then
  a() {
    b
  }
  b() {
    c
  }
  c() {
    L_print_traceback
  }
  a
  exit
fi

one=$("$0" show | sed 's/pid [0-9]\+//' | tee /dev/stderr)
two=$("$0" show_nomapfile | sed 's/pid [0-9]\+//' | tee /dev/stderr)
L_unittest_cmd L_glob_match "$one" "Traceback from*"
L_unittest_eq "$one" "$two"
