#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$DIR"/L_argparse \
	-- call=subparser \
	'{' file      -- file      type=file          help="type=file"          '}'    \
	'{' dir       -- dir       type=dir           help="type=dir"           '}'    \
	'{' function  -- function  complete=function  help="complete=function"  '}'    \
	'{' hostname  -- hostname  complete=hostname  help="complete=hostname"  '}'    \
	'{' service   -- service   complete=service   help="complete=service"   '}'    \
	'{' signal    -- signal    complete=signal    help="complete=signal"    '}'    \
	'{' user      -- user      complete=user      help="complete=user"      '}'    \
	'{' group     -- group     complete=group     help="complete=group"     '}'    \
	'{' export    -- export    complete=export    help="complete=export"    '}'    \
	'{' directory -- directory complete=directory help="complete=directory" '}'    \
	'{' command   -- command   complete=command   help="complete=command"   '}'    \
	'{' choices   -- choices   choices="car manual tiger" help="choices=car manual tiger" '}' \
	---- "$@"
