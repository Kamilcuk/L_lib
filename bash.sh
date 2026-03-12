#!/usr/bin/env bash
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
  -- --podman flag=1 eval=' opt_podman=1; docker() { podman "$@"; } ' help="use podman" \
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

if (( ! ${opt_podman:-0} )); then
  if ! tmp=$(docker info 2>&1); then
    if hash podman; then
      L_warning "docker info failed, but podman found. Using podman."
      docker() { podman "$@"; }
    else
      L_panic "docker info failed:$L_NL$tmp"
    fi
  fi
fi

docker_run() {
  local version=$1
  if (( opt_jq )); then
    echo "/-- dockerfile-tester:$version"
    local image=$(docker build --target tester -q .)
  else
    echo "/-- bash:$version"
    local image=bash:$version
  fi
  if (( opt_quiet )); then
    exec 1>/dev/null
  else
    exec 2>&1
  fi
  local args=(-q --rm ${TERM+-eTERM} -v $PWD:$PWD:ro -w "$PWD" "$image" bash "${args[@]}") rc=0
  if (( opt_tty )) && [[ -z "$input" && -t 0 ]]; then
    docker run -ti "${args[@]}"
  else
    docker run -i "${args[@]}" <<<"$input"
  fi || rc=$?
  echo "\-- rc=$rc"
}

IFS=$', \t\n' read -r -a versions <<<"$opt_versions"
if (( ${#versions[@]} == 1 )); then
  if (( ${#args[@]} == 0 )); then
    opt_tty=1
  fi
  docker_run "${versions[0]}"
else
  if (( ${#args[@]} == 0 )); then
    L_panic "Too many version or missing command. Either give one version to start an interactive bash session or give a command to test against multiple versions. No command was found, but requested running on versions: ${versions[*]}"
  fi
  if (( opt_sequential )); then
    for version in "${versions[@]}"; do
      rc=0
      docker_run "$version" || rc=$?
    done
  else
    if true; then
      L_xargs -OO -Pn -a versions docker_run
    else
      {
        for version in "${versions[@]}"; do
          {
            # output version to sort the output properly
            echo -n "$version "
            docker_run "$version"
          } | tr '\n' $'\002' &
        done
        wait
      } | sort -gk1 | cut -d' ' -f2- | tr $'\002' '\n' | sed '/^$/{$d}'
    fi
  fi
fi
