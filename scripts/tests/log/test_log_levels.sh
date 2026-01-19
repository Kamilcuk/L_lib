#!/bin/bash
# Test log level configuration from log.md examples

. "$(dirname "$0")/../../../bin/L_lib.sh"

echo "=== Default level (info) - debug should not be visible ==="
L_debug "This should NOT be visible"
L_info "This SHOULD be visible"

echo ""
echo "=== After setting level to debug ==="
L_log_configure -l debug

L_debug "Now you can see this!"
L_info "Regular info message"

echo ""
echo "=== Setting level to warning - info should not be visible ==="
L_log_configure -l warning

L_info "This should NOT be visible"
L_warning "This SHOULD be visible"
L_error "Errors are still visible"

echo ""
echo "=== Setting level to trace - everything visible ==="
L_log_configure -l trace

L_trace "Trace is now visible"
L_debug "Debug is visible"
L_info "Info is visible"
