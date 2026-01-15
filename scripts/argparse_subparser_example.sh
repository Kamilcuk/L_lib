#!/usr/bin/env bash
. L_lib.sh -s
L_argparse help="docker subparser example" \
  -- -f --flag flag=1 \
  -- -v --verbose nargs=0 eval='(( verbose=1 ))' \
  -- --config help="Location of client config files" \
  -- call=subparser dest=cmd \
  { \
    name=run help="run an image" \
    -- image \
  } \
  { \
    name=ps help="list images" \
  } \
  { \
    name=exec help="Exec into container" \
    -- container \
    -- command nargs=remainder required=1 \
  } \
  ---- "$@"
case "$cmd" in
  run) echo "Running image $image" ;;
  ps) echo "listing images" ;;
  exec) echo "Exeucuting [$(L_quote_printf "${command[@]}")] inside container $container" ;;
esac
