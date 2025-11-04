#!/usr/bin/env bash
. L_lib.sh -s
CMD_run() {
  L_argparse help="run an image" \
    -- image \
    ---- "$@"
  echo "Running $image"
}
CMD_ps() {
  L_argparse help="list images" \
    ---- "$@"
  echo "Listing images"
}
CMD_exec() {
  L_argparse help="Exec into a container" \
    -- container \
    -- command nargs=remainder required=1 \
    ---- "$@"
  echo "Executing command [$(L_quote_printf -- "${command[@]}")] inside $container"
}
L_argparse help="docker function example" \
  -- --config help="Location of client config files" \
  -- call=function prefix=CMD_ subcall=detect \
  ---- "$@"
