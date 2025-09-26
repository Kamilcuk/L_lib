#!/usr/bin/env bash
set -euo pipefail
. bin/L_lib.sh -s

###############################################################################

export TIMEFORMAT="real=%6lR user=%6lU system=%6lS"
if (($#)); then
  time L_run L_cache -O output -f /tmp/cache.L_cache "$@"
  echo $?
  exit
fi

mycurl() { md5sum <<<"$@"; }
# mycurl() { echo "$@"; }
L_cache_decorate -T 10s -o -f /tmp/cache.L_cache mycurl
time var=$(mycurl https://github.com/Kamilcuk/L_lib)
time var2=$(mycurl https://github.com/Kamilcuk/L_lib)  # uses file cache with 10 seconds ttl
L_assert '' [ "$var" == "$var2" ]
echo "$var"



myfunc() {
  var=$(echo 123)
  array=(a b c d)
  assoc=(a b c d)
  echo RUN >&2
}
L_cache_decorate -T 5 -s var -s assoc -s array -f /tmp/cache.L_cache myfunc
declare -f myfunc
declare -i var
declare -A assoc
myfunc
L_pretty_print array var assoc
unset var array assoc
declare -i var
declare -A assoc
myfunc
L_pretty_print array var assoc
exit
#

curl_cached() {
  L_cache -O output -f /tmp/cache.L_cache -T 10s curl -sS "$@"
}

for i in https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html  https://www.gnu.org/software/bash/manual/html_node/Shell-Variables.html https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Variables.html; do
  echo "-- $i --"
  time curl_cached "$i"
  echo "$output" | wc -l
  time curl_cached "$i"
  echo "$output" | wc -l
  # time L_cache -O output curl -sS "$i"
  # echo "$output" | wc -l
  # declare -p L_CACHE_curl
  # time L_cache -O output curl -sS "$i"
  # echo "$output" | wc -l
done
exit

