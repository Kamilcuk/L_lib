#!/bin/bash
CMD_clone() {
  local repo
  L_argparse description="clone repository" -- repo ---- "$@"
  git clone "$repo"
}
CMD_pull() {
  git pull "$@"
}
CMD_fetch_help="fetch help"
CMD_fetch() {
  git fetch "$@"
}
. L_lib.sh
L_argparse -- call=function prefix=CMD_ subcall=detect ---- "$@"
