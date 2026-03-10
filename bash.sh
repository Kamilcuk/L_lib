#!/bin/bash
set -euo pipefail
. "$(dirname "$0")"/bin/L_lib.sh L_argparse \
  description="Compare behavior of multiple bash versions" \
  dest_prefix=opt_ \
  -- -q --quiet flag=1 help="Silence output from dockers" \
  -- -i --input help="Stdin" default="" \
  -- -c --script flag=1 help="Instead of bash arguments take script to execute" \
  -- -t --tty flag=1 help="attach tty" \
  -- -j --jq flag=1 help="run in tester" \
  -- -s --sequential flag=1 help="run in sequence, not in parallel" \
  -- versions nargs="?" help="Bash version to test against, or all. Default: all" default="all" \
  -- args nargs=remainder help="Bash arguments" \
  ---- "$@"

if [[ "$opt_versions" == "all" ]]; then
  opt_versions='3.2 4.0 4.1 4.2 4.3 4.4 5.0 5.1 5.2 5.3 latest'
fi

if [[ -z "$opt_input" ]] && read -t 0; then
  input=$(cat)
  echo "input=$input"
else
  input=$opt_input
fi

args=("${opt_args[@]}")
if (( opt_script )); then
  args=(-c "${args[*]}")
fi

dockerargs=()
if (( opt_tty )); then
  dockerargs+=("-t")
fi

docker_run() {
  local version=$1
  if (( opt_jq )); then
    echo "/ dockerfile-tester:$version"
    local image=$(docker build --target tester -q .)
  else
    echo "/ bash:$version"
    local image=bash:$version
  fi
  if (( opt_quiet )); then
    exec 1>/dev/null
  else
    exec 2>&1
  fi
  local args=(-q --rm -v $PWD:$PWD:ro -w "$PWD" "$image" bash "${args[@]}")
  if [[ -z "$input" && -t 0 ]]; then
    docker run -ti "${args[@]}"
  else
    docker run -i "${args[@]}" <<<"$input"
  fi
}

IFS=$', \t\n' read -r -a versions <<<"$opt_versions"
if (( ${#versions[@]} == 1 )); then
  docker_run "${versions[0]}"
elif (( opt_sequential )); then
  idx=0
  for version in "${versions[@]}"; do
    if (( idx++ != 0 )); then
      echo
    fi
    rc=0
    docker_run "$version" || rc=$?
    echo "\ rc=$rc"
  done
else
  for version in "${versions[@]}"; do
    (
      (
        rc=0
        ( docker_run "$version" ) || rc=$?
        echo "\ rc=$rc"
      ) | tr '\n' $'\002'
      echo
    ) &
  done | sort -gk1 | cut -d' ' -f2- | tr $'\002' '\n' | sed '/^$/{$d}'
fi
