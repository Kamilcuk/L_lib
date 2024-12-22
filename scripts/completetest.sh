#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$DIR"/L_argparse \
	-- -f --file type=file help="do type=file" \
	-- -d --dir type=dir help="do type=dir" \
	-- -F --function complete=function help="do complete=function" \
	-- -h --hostname complete=hostname help="do complete=hostname" \
	-- -s --service complete=service help="do complete=service" \
	-- -S --signal complete=signal help="do complete=signal" \
	-- -U --user complete=user help="do complete=user" \
	-- -g --group complete=group help="do complete=group" \
	-- -e --export complete=export help="do complete=export" \
	-- -D --directory complete=directory help="do complete=directory" \
	-- -c --command complete=command help="do complete=command" \
	-- -C --choices choices="car manual tiger" \
	-- -1 --one_store_true action="store_true" \
	-- -2 --two_store_false action="store_false" \
	-- -3 --three_store_const action="store_const" const=3 \
	-- -4 --four_store_1 action="store_1" \
	-- -5 --five_store_0 action="store_0" \
	---- "$@"
