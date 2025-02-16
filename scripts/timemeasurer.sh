#!/bin/bash
set -euo pipefail

# @description Shuffle an array
# @arg $1 array nameref
L_shuf() {
	local -n _L_arr=$1
	local _L_i _L_j _L_tmp
	# RANDOM range is 0..32767
	for ((_L_i=${#_L_arr[@]}-1; _L_i; --_L_i)); do
		# _L_j=$(( ((_L_i < 32768 ? 0 : (_L_i < 1073741824 ? 0 : RANDOM << 30) | RANDOM << 15) | RANDOM) % _L_i ))
		_L_j=$(( RANDOM % _L_i ))
		_L_tmp=${_L_arr[_L_i]}
		_L_arr[_L_i]=${_L_arr[_L_j]}
		_L_arr[_L_j]=$_L_tmp
	done
}

usage() {
	cat <<EOF
Usage: $0 OPTIONS MODE

Options:
 -c count       Number of elements, default 1000
 -r repeat      Repeat, default 10
 -o outputfile  default: sortspeed_IDX.perf, where IDX is autoincremented

Modes:
  perf    default, measure
  show10  Show last 10 measurements
EOF
}

measure() {
	if [[ -z "${IN_PERF:-}" ]]; then
		for cmd in "$@"; do
			fd=$(mktemp -u)
			ack=$(mktemp -u)
			mkfifo "$fd" "$ack"
			exec 100<>$ack 101<>$fd
			rm "$fd" "$ack"
			sudo tee <<<0 /proc/sys/kernel/nmi_watchdog >/dev/null
			env IN_PERF=1 perf stat \
				-r "${repeat:-10}" --delay=-1 --control fd:100,101 ${outputfile:+-o "$outputfile"} \
				-- "$0" -c "${count:-100}" ${sort:+-s} perf "$cmd" \
				2> >(sed '/Events \(enabled\|disabled\)/d')
			sudo tee <<<1 /proc/sys/kernel/nmi_watchdog >/dev/null
			(
				if [[ -n "${outputfile:-}" ]]; then
					exec 1>"$outputfile"
				fi
				echo "Measured $cmd with count=${count:-100} repeat=${repeat:-10}"
				md5sum "$(dirname $0)"/../bin/L_lib.sh
			)
			if [[ -n "${outputfile:-}" ]]; then
				cat "$outputfile"
			fi
		done
		exit
	else
		startarray=($(seq ${count:-100}))
		array=("${startarray[@]}")
		. "$(dirname $0)"/../bin/L_lib.sh
		RANDOM=42
		L_shuf array
		# printf "%s\n" "${array[*]}"
		echo enable >&100
		eval "$@"
		echo disable >&100
		read -u 101 a
		read -u 101 b
		L_assert '' test "$a" = "ack"
		L_assert '' test "$b" = "ack"
		if [[ "$1" = "L_sort"* ]]; then
			L_assert '' test "${array[0]}" = "${startarray[0]}"
			L_assert '' test "${array[*]}" = "${startarray[*]}"
		fi
	fi
}

while getopts "c:r:o:Os" opt; do
	case $opt in
	c) count=$OPTARG ;;
	r) repeat=$OPTARG ;;
	o) outputfile=$OPTARG ;;
	O) nextoutputfile=1 ;;
	s) sort=1 ;;
	*) usage; exit 1 ;;
	esac
done
shift $((OPTIND-1))
if [[ -n "${nextoutputfile:-}" ]]; then
	outputfile=perf_sortspeed_$(ls perf_sortspeed_*.txt 2>/dev/null | wc -l || :).txt
fi
mode=${1:-perf}
shift
if (($# == 0)); then
	set -- 'L_sort_cmd -n array'
fi
case "$mode" in
	perf) measure "$@" ;;
	show10) ls perf_sortspeed_*.txt 2>/dev/null | tail -n 10 | xargs cat ;;
	rmlast) ls perf_sortspeed_*.txt 2>/dev/null | tail -n 1 | xargs rm -v ;;
	*) usage; exit 1 ;;
esac
