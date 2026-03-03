#!/usr/bin/env bash
set -euo pipefail

_L_test_L_duration_to_usec() {
    local value
    L_duration_to_usec -v value 1s
    L_unittest_vareq value "1000000"

    L_duration_to_usec -v value 1ms
    L_unittest_vareq value "1000"

    L_duration_to_usec -v value 1us
    L_unittest_vareq value "1"

    L_duration_to_usec -v value 1m
    L_unittest_vareq value "60000000"

    L_duration_to_usec -v value 1h
    L_unittest_vareq value "3600000000"

    L_duration_to_usec -v value 1d
    L_unittest_vareq value "86400000000"

    L_duration_to_usec -v value 1w
    L_unittest_vareq value "604800000000"

    L_duration_to_usec -v value 1y
    L_unittest_vareq value "31536000000000"

    L_duration_to_usec -v value 1s1ms1us
    L_unittest_vareq value "1001001"
    L_duration_to_usec -v value 1y1w1d1h1m1s1ms1us
    L_unittest_vareq value "$(( (365 * 24 * 60 * 60 + 7 * 24 * 60 * 60 + 24 * 60 * 60 + 60 * 60 + 60) * 1000000 + 1001001 ))"

    L_duration_to_usec -v value 1y1w1d1h1m1s1ms1us
    L_unittest_vareq value "32230861001001"

    L_duration_to_usec -v value 1.5s
    L_unittest_vareq value "1500000"

    L_duration_to_usec -v value 0.5s
    L_unittest_vareq value "500000"

    L_duration_to_usec -v value 1s500ms
    L_unittest_vareq value "1500000"

    L_unittest_cmd -e 1 L_duration_to_usec -v value 1foo

    L_duration_to_usec -v value 0.5000000000001
    L_unittest_vareq value "500000"

    L_duration_to_usec -v value 0.5000000000001s
    L_unittest_vareq value "500000"

    L_duration_to_usec -v value 0s5000ms
    L_unittest_vareq value "5000000"

    L_duration_to_usec -v value 0s5000000us
    L_unittest_vareq value "5000000"
}

_L_test_L_usec_to_duration() {
    local value
    L_usec_to_duration -v value 1000000
    L_unittest_vareq value "1s"

    L_usec_to_duration -v value 1000
    L_unittest_vareq value "1ms"

    L_usec_to_duration -v value 1
    L_unittest_vareq value "1us"

    L_usec_to_duration -v value 60000000
    L_unittest_vareq value "1m"

    L_usec_to_duration -v value 3600000000
    L_unittest_vareq value "1h"

    L_usec_to_duration -v value 86400000000
    L_unittest_vareq value "1d"

    L_usec_to_duration -v value 31536000000000
    L_unittest_vareq value "1y"

    L_usec_to_duration -v value 32230861001001
    L_unittest_vareq value "1y1w1d1h1m1s1ms1us"

    L_usec_to_duration -v value 1500000
    L_unittest_vareq value "1s500ms"

    L_usec_to_duration -v value 500000
    L_unittest_vareq value "500ms"
}
