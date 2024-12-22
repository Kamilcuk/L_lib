#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "$DIR"/L_argparse \
	-- file type=file \
	-- dir type=dir \
	-- function complete=function \
	-- hostname complete=hostname \
	-- service complete=service \
	-- signal complete=signal \
	-- user complete=user \
	-- group complete=group \
	-- export complete=export \
	-- directory complete=directory \
	-- command complete=command \
	-- choices choices="car manual tiger" \
	---- "$@"
