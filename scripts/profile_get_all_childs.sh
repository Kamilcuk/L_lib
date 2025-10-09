#!/bin/bash

. $(dirname "$0")/../L_lib.sh

L_get_all_childs_1() {
	local toppid=${1:-} IFS=$' \t\n' ps_output ps_pid children_of pid ppid unproc_idx
	if [[ -z "$toppid" ]]; then
		L_bashpid_to toppid
	fi
	#
	L_hash ps && ps_output=$(
			L_bashpid_to pid
			echo "$pid"
			exec ps -e -o ppid= -o pid=
	) && {
		# Extract ps pid that we conveniently put as the first item.
		read -r ps_pid <<<"$ps_output"
		# Populate a sparse array mapping pids to (string) lists of child pids.
		children_of=()
		while read -r ppid pid; do
			if [[ -n "$pid" && -n "$ppid" && pid -ne ppid && pid -ne ps_pid && ppid -ne ps_pid ]]; then
				children_of[ppid]+=" $pid"
			fi
		done <<<"$ps_output"
		# Add children to the list of pids until all descendants are found
		L_v=("$toppid")
		unproc_idx=0    # Index of first process whose children have not been added
		while (( ${L_v[@]+${#L_v[@]}}+0 > unproc_idx )) ; do
			pid=${L_v[unproc_idx++]}     # Get first unprocessed, and advance
			# shellcheck disable=SC2206
 			L_v+=(${children_of[pid]-})  # Add child pids (ignore ShellCheck)
		done
		# ( echo "${L_v[@]}"; pstree -p "$toppid" ) | sed 's/^/init /' >&100
		# I do not want to return toppid of itself.
		unset -v 'L_v[0]'
	}
}

L_get_all_childs_2() {
	local toppid=${1:-} IFS=$' \t\n' ps_output ps_pid children_of pid ppid unproc_idx
	if [[ -z "$toppid" ]]; then
		L_bashpid_to toppid
	fi
	#
	L_hash ps && ps_output=$(
			L_bashpid_to pid
			echo "$pid"
			exec ps -e -o ppid= -o pid=
	) && {
		# Extract ps pid that we conveniently put as the first item.
		ps_pid=${ps_output%%$'\n'*}
		ps_output=$'\n'${ps_output#*$'\n'}$'\n'
		local todo=("$toppid") pid found=() tmp i=0
		L_v=("$toppid")
		while (( i < ${#L_v[*]} )); do
			ps=$ps_output
			while time [[ "$ps" =~ (.*)$'\n'\ *"${L_v[i]}"\ +([0-9]+) ]]; do
				ps=${BASH_REMATCH[1]}
				if [[ "${BASH_REMATCH[2]}" != "$ps_pid" ]]; then
					L_v+=("${BASH_REMATCH[2]}")
				fi
			done
			i=$(( i + 1 ))
		done
	}
}

finally() {
	L_get_all_childs_to pids
	echo "Killing ${pids[@]}"
	kill "${pids[@]}"
}
L_finally finally
sh -c '( sleep 2 & sleep 2 & wait ) & sleep 3 & wait' &
# L_setx L_get_all_childs_2
sleep 0.5
pstree -pa $BASHPID
# echo "AA" "${L_v[@]}"
# exit
for i in 1; do
	L_v=()
	f=L_get_all_childs_"$i"
	L_time "$f"
	echo "$f:" "${L_v[@]}"
	ps auxp "${L_v[*]}"
done
L_time L_get_all_childs_to L_v
echo L_get_all_childs_to "${L_v[@]}"
ps auxp "${L_v[*]}"

