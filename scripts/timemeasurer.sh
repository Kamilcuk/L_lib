#!/bin/bash
usage() {
	cat <<EOF
Usage: $0 [times] [script]

Options:
	-h		Show this help
	-m		Measure multiple times
	-q		Be quiet
	-c		Count of times to measure
	-d		Debug mode
EOF
	exit 1
}
a_count=10
a_verbose=0
a_debug=0
while getopts hmc:vd opt; do
	case $opt in
	h) usage ;;
	v) a_verbose=1 ;;
	c) a_count=$OPTARG ;;
	d) a_debug=1 ;;
	*) usage ;;
	esac
done
shift $((OPTIND - 1))
TIMEFORMAT='TIME %R %U %S'
while (($#)); do
	script=$1
	time=""
	for ((i = 0; i < a_count; i++)); do
		new=$({ eval "time $script"; } 2>&1)
		if ((a_verbose)); then
			echo "$new"
		fi
		time+="$new"$'\n'
	done
	printf "Measured %s %d times resulted in:\n" "$script" "$a_count"
	awk '
		/^TIME /{r+=$2;u+=$3;s+=$4;c+=1}
		END {printf "real %0.4f user %0.4f sys  %0.4f\n", r/c, u/c, s/c}
		' <<<"$time"
	shift
done
