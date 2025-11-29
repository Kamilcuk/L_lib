#!/usr/bin/env bash

set -e

source bin/L_lib.sh

echo "--- L_args_join ---"
L_args_join -v res ", " "Hello" "World" "from" "L_lib"
echo "Result: $res"
# Expected: Hello, World, from, L_lib

echo "--- L_args_andjoin ---"
L_args_andjoin -v res "Apple" "Banana" "Orange"
echo "Result: $res"
# Expected: Apple, Banana and Orange
L_args_andjoin -v res "Apple" "Banana"
echo "Result: $res"
# Expected: Apple and Banana
L_args_andjoin -v res "Apple"
echo "Result: $res"
# Expected: Apple
L_args_andjoin -v res
echo "Result (empty): '$res'"
# Expected: ''

echo "--- L_args_contain ---"
ret=1
L_args_contain "World" "Hello" "World" "Again" && ret=0 || ret=$?
echo "Contains World: $ret" # Expected: 0

ret=0
L_args_contain "Missing" "Hello" "World" "Again" && ret=0 || ret=$?
echo "Contains Missing: $ret" # Expected: 1

echo "--- L_args_index ---"
L_args_index -v idx "World" "Hello" "World" "Again"
echo "Index of World: $idx" # Expected: 1
L_args_index -v idx "Again" "Hello" "World" "Again"
echo "Index of Again: $idx" # Expected: 2
L_args_index -v idx "Missing" "Hello" "World" "Again" || true
echo "Index of Missing: $idx (exit code: $?)" # Expected: '' (exit code: 1)

echo "--- L_max ---"
L_max -v max_val 10 5 20 3 15
echo "Max value: $max_val" # Expected: 20
L_max -v max_val -5 -1 -10
echo "Max value: $max_val" # Expected: -1

echo "Test complete."
