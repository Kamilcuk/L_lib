#!/bin/bash
# Test custom log formatters from log.md examples

. "$(dirname "$0")/../../../bin/L_lib.sh"

echo "=== Default formatter ==="
L_info "Default format message"

echo ""
echo "=== JSON formatter ==="
L_log_configure -r -l info -F L_log_format_json
L_info "User logged in"
L_error "Connection failed"

echo ""
echo "=== Long formatter ==="
L_log_configure -r -F L_log_format_long
L_info "Processing data"
L_warning "Low memory"

echo ""
echo "=== Custom formatter ==="
my_formatter() {
	# Available: $L_logline_levelname, $L_logline_funcname, $L_logline_lineno, etc.
	printf -v L_logline "[%s] %s:%s - %s" \
		"$L_logline_levelname" \
		"$L_logline_funcname" \
		"$L_logline_lineno" \
		"$*"
}

L_log_configure -r -F my_formatter
L_info "Custom format message"
L_error "Custom error message"

echo ""
echo "=== Reset to default ==="
L_log_configure -r -F L_log_format_default
L_info "Back to default format"
