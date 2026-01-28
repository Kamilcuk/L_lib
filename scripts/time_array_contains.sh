#!/bin/bash

. "$(dirname "$0")"/../bin/L_lib.sh -s
array=($(seq 10000))

naive() {
	local _L_arr="$1[@]" i
	for i in "${!_L_arr}"; do
		if [[ "$i" == "$2" ]]; then
			return 0
		fi
	done
	return 1
}

time L_array_contains array 50
time naive array 50
