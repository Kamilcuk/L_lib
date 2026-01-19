#!/bin/bash
# Test basic logging functionality from log.md examples

. "$(dirname "$0")/../../../bin/L_lib.sh"

echo "=== Testing basic logging ==="
L_info "Application starting"
L_debug "Loading configuration"  # Not shown by default (level too low)
L_warning "Configuration file not found, using defaults"
L_error "Failed to connect to database"

echo ""
echo "=== Testing printf-style formatting ==="
count=5
directory="/var/data"
L_info "Processing %d files in %s" "$count" "$directory"

echo ""
echo "=== Testing single vs multiple args ==="
L_info "hello %s"            # Should output: hello %s
L_info "hello %s" "world"    # Should output: hello world

echo ""
echo "=== Testing all log levels ==="
L_trace "Tracing message"
L_debug "Debugging message"
L_info "Informational message"
L_notice "Notice message"
L_warning "Warning message"
L_error "Error message"
L_critical "Critical message"
