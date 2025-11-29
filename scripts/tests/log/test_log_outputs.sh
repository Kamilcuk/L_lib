#!/bin/bash
# Test custom log outputs from log.md examples

. "$(dirname "$0")/../../../bin/L_lib.sh"

tmpdir=$(mktemp -d)
trap "rm -rf '$tmpdir'" EXIT

echo "=== Default output (stderr) ==="
L_info "This goes to stderr by default"

echo ""
echo "=== Output to file only ==="
logfile="$tmpdir/app.log"
my_file_outputter() {
	echo "$L_logline" >> "$logfile"
}

L_log_configure -r -o my_file_outputter
L_info "This message goes to file"
L_error "This error also goes to file"

echo "Content of $logfile:"
cat "$logfile"

echo ""
echo "=== Dual output: stderr and file ==="
logfile2="$tmpdir/app2.log"
my_dual_outputter() {
	echo "$L_logline" >&2
	echo "$L_logline" >> "$logfile2"
}

L_log_configure -r -o my_dual_outputter
L_info "This goes to both stderr and file"
L_warning "Warning message to both"

echo ""
echo "Content of $logfile2:"
cat "$logfile2"

echo ""
echo "=== Split output: errors to separate file ==="
logfile3="$tmpdir/app3.log"
errorfile="$tmpdir/errors.log"
my_split_outputter() {
	# L_LOGLEVEL_ERROR = 40, variable is L_logline_level
	if ((L_logline_level >= 40)); then
		echo "$L_logline" >> "$errorfile"
	fi
	echo "$L_logline" >> "$logfile3"
}

L_log_configure -r -o my_split_outputter
L_info "Info to main log only"
L_error "Error to both logs"
L_warning "Warning to main log only"
L_critical "Critical to both logs"

echo ""
echo "Content of main log ($logfile3):"
cat "$logfile3"

echo ""
echo "Content of error log ($errorfile):"
cat "$errorfile"
