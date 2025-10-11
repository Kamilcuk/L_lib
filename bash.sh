#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/bin/L_lib.sh L_argparse \
  description="Compare behavior of multiple bash versions" \
  -- -q --quiet flag=1 help="Silence output from dockers" \
  -- -i --input help="Stdin" default="" \
  -- -c --script flag=1 help="Instead of bash arguments take script to execute" \
  -- versions nargs="?" help="Bash version to test against, or all. Default: all" default="all" \
  -- args nargs="*" help="Bash arguments" \
  ---- "$@"

if [[ "$versions" == "all" ]]; then
  versions='3.1 3.2 4.0 4.1 4.2 4.3 4.4 5.0 5.1 5.2 5.3 latest'
fi

if [[ -z "$input" ]] && read -t 0; then
  input=$(cat)
  echo "input=$input"
fi

if ((script)); then
  args=(-c "${args[*]}")
fi

IFS=$', \t\n' read -r -a versions <<<"$versions"
for version in "${versions[@]}"; do
  (
    (
      echo "$version / bash:$version"
      rc=0
      (
        if ((quiet)); then
          exec 1>/dev/null
        else
          exec 2>&1
        fi
        docker run -q -i --rm -v $PWD:$PWD:ro -w "$PWD" bash:"$version" bash "${args[@]}" <<<"$input"
      ) || rc=$?
      echo "\ rc=$rc"
    ) | tr '\n' $'\035'
    echo
  ) &
done | sort -gk1 | cut -d' ' -f2- | tr $'\035' '\n'
