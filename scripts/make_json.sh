#!/bin/bash
. bin/L_lib.sh -s || exit 2

if (($# == 0)); then
  a=$(
    L_json_make \
    { \
      "a" : "b" , \
      "d" : "e" , \
      "c" :[ \
        "a" , \
        "b" \
      ] \
    } | jq
  )

  L_json_get "$a" c
else
  "$@"
fi
