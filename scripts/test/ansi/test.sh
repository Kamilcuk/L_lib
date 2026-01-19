#!/usr/bin/env bash

source bin/L_lib.sh

echo "Testing L_ansi_up, L_ansi_down, L_ansi_left, L_ansi_right"
echo -n "Hello"
L_ansi_left 2
echo -n "y"
L_ansi_right 1
echo "!"
# Expected output: Hellyo!

echo "Testing L_ansi_next_line, L_ansi_prev_line"
echo "Line 1"
echo "Line 2"
L_ansi_prev_line 1
echo -n "This is on line 1 now"
L_ansi_next_line 2
echo "This is on line 3"

echo "Testing L_ansi_set_column"
echo -n "123456789"
L_ansi_set_column 5
echo -n "ABCD"
# Expected output: 1234ABCD9

echo
echo "Testing L_ansi_set_position"
L_ansi_set_position 10 1
echo "This is at row 10, column 1"

echo "Testing L_ansi_set_title"
L_ansi_set_title "My new title"

echo "Testing L_ANSI_CLEAR_*"
echo "This will be cleared."
sleep 1
echo -n "$L_ANSI_CLEAR_LINE"
echo "Line cleared."
sleep 1
echo -e "This is some text.\nThis is some more text."
sleep 1
echo -n "$L_ANSI_CLEAR_SCREEN_UNTIL_END"
echo "Screen cleared until end."
sleep 1

echo "Testing L_ansi_print_on_line_above"
echo
for i in $(seq 3); do
  L_ansi_print_on_line_above 1 "Progress: $i/3"
  sleep 0.5
done
echo "Done."

echo "Testing 8bit colors"
L_ansi_8bit_fg_rgb 5 0 0
echo "This is red"
L_ansi_8bit_bg_rgb 0 5 0
echo "This has a green background"
echo -n "$L_RESET"

echo "Testing 24bit colors"
L_ansi_24bit_fg 200 100 200
echo "Hello in pink"
L_ansi_24bit_bg 100 200 100
echo "This has a light green background"
echo -n "$L_RESET"

echo "Test complete."
