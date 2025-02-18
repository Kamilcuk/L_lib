#!/bin/bash
set -euo pipefail

. $(dirname $0)/../bin/L_lib.sh
m_mapfile() {
	local _L_arr="$1[@]"
	mapfile -td '' "$1" < <( printf ''${!_L_arr:+'%s\0'} ${!_L_arr:+"${!_L_arr}"} | tac -s '' )
}
L_array_set() {
	local -n _L_arr=$1
	_L_arr=("${@:2}")
}
m_extdebug() {
	if shopt -q extdebug; then
		L_array_set "${BASH_ARGV[@]::$#}"
	else
		shopt -s extdebug
		local _L_arr="$1[@]"
		"${FUNCNAME[0]}" ${!_L_arr:+"${!_L_arr}"} "$1"
		shopt -u extdebug
	fi
}
m_eval() {
	L_assert '' L_is_valid_variable_name "$1"
	eval "local _L_len=\${#$1[@]}"
	if ((_L_len)); then
		eval eval "'$1=(' '\"\${$1['{$((_L_len-1))..0}']}\"' ')'"
	fi
}

tmpf=$(mktemp)
trap 'rm -vf $tmpf' EXIT
for ((i=1;i<${1:-1000};++i)); do
	if ((i == 0)); then
		array1=()
	else
		eval "array1=({1..$i})"
	fi
	array2=("${array1[@]}")
	array3=("${array1[@]}")
	TIMEFORMAT="mapfile,$i,%R,%U,%S"
	{ time m_mapfile array1 2>&1 ; } 2>>$tmpf
	TIMEFORMAT="extdebug,$i,%R,%U,%S"
	{ time m_extdebug array2 2>&1 ; } 2>>$tmpf
	TIMEFORMAT="eval,$i,%R,%U,%S"
	{ time m_eval array3 2>&1 ; } 2>>$tmpf
	L_assert '' test "${array1[*]}" == "${array2[*]}"
	L_assert '' test "${array1[*]}" == "${array3[*]}"
	echo "done $i"
done

cat "$tmpf"
gnuplot -p -e "
	set title 'Time vs array size between mapfile and extdebug methods';
	set xlabel 'array size';
	set ylabel 'time';
	set datafile separator ',';
	set grid;
	plot \
		'<grep mapfile $tmpf' using 2:3 with lines title 'mapfile real', \
		'<grep eval $tmpf' using 2:3 with lines title 'eval real', \
		'<grep extdebug $tmpf' using 2:3 with lines title 'extdebug real';
"


