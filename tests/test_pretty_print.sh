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

_L_test_pretty_print_array_of_structs_compact() {
    local tmp
    local n_names=(k a [5]=b)
    local n_height=(150 160 [5]=170)
    local n_feets=(3 4 [5]=5)
    L_pretty_print -v tmp -w 200 'n_**'
    L_unittest_eq "$tmp" 'n_**{[0]={feets=3 height=150 names=k} [1]={feets=4 height=160 names=a} [5]={feets=5 height=170 names=b}}'
}

_L_test_pretty_print_array_of_structs_multiline() {
    local tmp
    local n_names=(k a [5]=b)
    local n_height=(150 160 [5]=170)
    local n_feets=(3 4 [5]=5)
    L_pretty_print -v tmp -m 'n_**'
    local expected=$'n_**{\n  [0]={\n    feets=3\n    height=150\n    names=k\n  }\n  [1]={\n    feets=4\n    height=160\n    names=a\n  }\n  [5]={\n    feets=5\n    height=170\n    names=b\n  }\n}'
    L_unittest_eq "$tmp" "$expected"
}

_L_test_pretty_print_single_array() {
    local tmp
    local n_feets=(3 4 [5]=5)
    L_pretty_print -v tmp n_feets
    L_unittest_eq "$tmp" 'n_feets=([0]=3 [1]=4 [5]=5)'
}

_L_test_pretty_print_glob_pattern() {
    local tmp
    local n_names=(k a [5]=b)
    local n_height=(150 160 [5]=170)
    local n_feets=(3 4 [5]=5)
    L_pretty_print -v tmp -w 200 'n_*'
    local expected='n_*{n_feets=([0]=3 [1]=4 [5]=5) n_height=([0]=150 [1]=160 [5]=170) n_names=([0]=k [1]=a [5]=b)}'
    L_unittest_eq "$tmp" "$expected"
}
