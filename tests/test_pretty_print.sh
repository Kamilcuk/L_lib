#!/bin/bash

_L_test_pretty_print() {
    local name=1 tmp
    L_pretty_print -v tmp -C name
    L_unittest_eq "$tmp" 'name=1'
    local arr=(1 2)
    L_pretty_print -v tmp arr
    L_unittest_eq "$tmp" 'arr=(1 2)'
    local nodense=(1 [5]=$'\n')
    L_pretty_print -v tmp nodense
    L_unittest_eq "$tmp" "nodense=([0]=1 [5]=$'\n')"
}

_L_test_pretty_print_assoc_space() {
    skip_assoc
    local -A arr tmp
    arr[A]=b
    arr['c d']='f g'  # has to be assigned this way - bash4.0 bug
    L_pretty_print -v tmp arr
    L_unittest_eq "$tmp" "arr=([A]=b [c\ d]=f\ g)"
}

_L_test_pretty_print_new() {
    skip_assoc
    local tmp
    local -i values=1
    local -A dictionary=([a]=b [c]=d)
    local variable=42

    L_pretty_print -v tmp "Current values are:" values dictionary "also check this" variable
    echo "$tmp"
    L_unittest_match "$tmp" 'Current values are: -i values=1 dictionary=\(\[a\]=b \[c\]=d\).*also check this.*variable=42'

    if L_hash fmt; then
        # Test compact output with width
        L_pretty_print -v tmp -w 20 values dictionary
        L_unittest_match "$tmp" $'\n'
    fi
}
