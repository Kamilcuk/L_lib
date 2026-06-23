_L_net_client_listen_accept() {
    sleep 0.1
    if ! exec 3<>/dev/tcp/127.0.0.1/"$1"; then
        echo "TCP connection failed"
        exit 1
    fi
    echo "hello from client" >&3
    exec 3>&-
}

_L_test_net_listen_accept() {
    local sfd=""
    local port_val=""
    L_builtin listen -p port_val sfd 127.0.0.1 0
    L_unittest_ne "$sfd" ""
    L_unittest_ne "$port_val" ""

    local client_pid=""
    L_with_process_into client_pid _L_net_client_listen_accept "$port_val"

    local client_fd=""
    local client_addr=""
    L_builtin accept client_fd client_addr "$sfd"

    L_unittest_ne "$client_fd" ""
    L_unittest_regex "$client_addr" "127\.0\.0\.1:[0-9]+"

    local line=""
    read -r line <&"$client_fd"
    L_unittest_eq "$line" "hello from client"

    eval "exec $client_fd<&-"
    eval "exec $sfd<&-"
}

_L_test_net_sleep_precision() {
    local start=""
    local end=""
    L_epochrealtime_usec -v start
    L_builtin sleep 0.05
    L_epochrealtime_usec -v end
    
    local elapsed=$(( end - start ))
    # 0.05 seconds = 50,000 microseconds. Let's assert it took at least 45,000 usec.
    L_unittest_success [ "$elapsed" -ge 45000 ]
}

_L_net_client_send_recv_raw() {
    L_builtin sleep 0.05
    local client_fd=""
    L_builtin connect client_fd 127.0.0.1 "$1"
    L_builtin send "$client_fd" "request_payload"
    
    local reply=""
    L_builtin recv -v reply "$client_fd" 32
    L_unittest_eq "$reply" "response_payload"

    L_builtin shutdown "$client_fd" RDWR
    eval "exec $client_fd<&-"
}

_L_test_net_connect_send_recv_raw() {
    local sfd=""
    local port_val=""
    L_builtin listen -p port_val sfd 127.0.0.1 0

    local client_pid=""
    L_with_process_into client_pid _L_net_client_send_recv_raw "$port_val"

    local accepted_fd=""
    local client_addr=""
    L_builtin accept accepted_fd client_addr "$sfd"
    
    local payload=""
    L_builtin recv -v payload "$accepted_fd" 15
    L_unittest_eq "$payload" "request_payload"

    local sent_count=""
    L_builtin send -v sent_count "$accepted_fd" "response_payload"
    L_unittest_eq "$sent_count" "16"

    eval "exec $accepted_fd<&-"
    eval "exec $sfd<&-"
}

_L_net_client_send_recv_hex() {
    L_builtin sleep 0.05
    local client_fd=""
    L_builtin connect client_fd 127.0.0.1 "$1"
    # "001122330044" represents binary bytes with multiple null-bytes!
    L_builtin send -f hex "$client_fd" "001122330044"
    eval "exec $client_fd<&-"
}

_L_test_net_connect_send_recv_hex() {
    local sfd=""
    local port_val=""
    L_builtin listen -p port_val sfd 127.0.0.1 0

    local client_pid=""
    L_with_process_into client_pid _L_net_client_send_recv_hex "$port_val"

    local accepted_fd=""
    local client_addr=""
    L_builtin accept accepted_fd client_addr "$sfd"
    
    local binary_hex=""
    L_builtin recv -f hex -v binary_hex "$accepted_fd" 6
    L_unittest_eq "$binary_hex" "001122330044"

    eval "exec $accepted_fd<&-"
    eval "exec $sfd<&-"
}

_L_test_net_nonblocking_recv() {
    local sfd=""
    local port_val=""
    L_builtin listen -p port_val sfd 127.0.0.1 0

    local client_pid=""
    L_with_process_into client_pid _L_net_client_send_recv_hex "$port_val"

    local accepted_fd=""
    local client_addr=""
    L_builtin accept accepted_fd client_addr "$sfd"

    local binary_hex=""
    L_builtin recv -f hex -v binary_hex "$accepted_fd" 6
    L_unittest_eq "$binary_hex" "001122330044"

    local empty_val="not_empty"
    L_builtin recv -n -v empty_val "$accepted_fd" 10
    L_unittest_eq "$empty_val" ""

    eval "exec $accepted_fd<&-"
    eval "exec $sfd<&-"
}

_L_test_net_defaults() {
    local sfd=""
    local port_val=""
    L_builtin listen -p port_val sfd
    L_unittest_ne "$sfd" ""
    L_unittest_ne "$port_val" ""
    L_unittest_ne "$port_val" "0"

    eval "exec $sfd<&-"
}

_L_test_net_port0_requires_p() {
    local sfd=""
    # Port is 0, so -p option is required
    L_unittest_checkexit 2 L_builtin listen sfd
}
