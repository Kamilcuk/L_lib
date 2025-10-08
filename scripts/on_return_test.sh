#!/bin/bash

on_return() {
  local A
  echo "AAAAAAA $BASH_COMMAND"
  return
  echo "on_return: ${BASH_SOURCE[1]}:${BASH_LINENO[1]}:${FUNCNAME[1]}() returned" >&2
  is_source="$(declare -p BASH_COMMAND)"
  if [ "${is_source:25:2}" == '. ' ] || [ "${is_source:25:7}" == 'source ' ];then
    echo "source '${is_source:25:2}' return was trapped" >&2
  else
    echo "Command at trap: '${is_source:25}'" >&2
  fi
  echo
}
a=""
set -o functrace
trap '${a+on_return}' RETURN

f() {
  return 101
}

f

. <(echo '
  echo "FROM INSIDE SOURCE:"
  declare -p BASH_COMMAND
  echo
  f
  return 102
')
