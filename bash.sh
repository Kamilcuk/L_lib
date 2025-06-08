#!/bin/bash
set -euo pipefail

if [[ "$1" == "all" ]]; then
  set -- '3.1 3.2 4.0 4.1 4.2 4.3 4.4 5.0 5.1 5.2 5.3-rc2' "${@:2}"
fi

input=""
if read -t 0; then
  input=$(cat)
  echo "input=$input"
fi

IFS=$', \t\n' read -r -a versions <<<"$1"
for version in "${versions[@]}"; do
  (
    (
      echo "$version / bash:$version"
      rc=0
      docker run -i --rm -v $PWD:$PWD:ro bash:"$version" bash "${@:2}" <<<"$input" 2>&1 || rc=$?
      echo "\ rc=$rc"
    ) | tr '\n' $'\035'
    echo
  ) &
done | sort -gk1 | cut -d' ' -f2- | tr $'\035' '\n'
