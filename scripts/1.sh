#!/usr/bin/env bash

CLI_sync() {
	L_argparse_group \
		:: \
		:::: "$@"
}

L_argparse \
	:: --debug DEBUG action=store_1 \
	:: action=group:CLI_ \
	:::: "$@"
