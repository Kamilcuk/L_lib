#!/bin/bash

f() {
  eval "$2"
  local n=$2 e='${array[*]'$1'"word1" "word2"}'
  if ! ( eval "set -- $e" ) 2>/dev/null; then
    echo "| $e | $n | -- | echo word >&2;exit 1 |"
  else
    eval "set -- $e"
    echo "| $e | $n | $# | $( (($#)) && printf "%q " "$@" | sed 's/ $//') |"
  fi
}

for i in - :- + :+ ? :? ; do
  unset array
  ( f "$i" 'unset' )
  ( f "$i" 'array=()' )
  ( f "$i" "array=('')" )
  ( f "$i" "array=(val)" )
  ( f "$i" "array=('' '')" )
done
