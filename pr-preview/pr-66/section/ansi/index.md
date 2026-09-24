# L_ansi

This section provides some minimal interface to the ANSI escape codes.

It is not full implementation, but enough to get you started.

Contributions are welcome. Consider a simple following usage example:

```
echo
for i in $(seq 5); do
  L_ansi_print_on_line_above 1 "Progress: $i/5"
  sleep 0.5
done
```

The functions here should be bare bones.

```
L_ansi_24bit_fg 200 100 200; echo Hello in pink $RESET
```

## API Reference

## ansi

Very basic functions for manipulating cursor position and color.

Note

unstable

### L_strip_ansi

Remove ANSI esacpe sequences like \\E\[..m from string.

Uses extglob

**Option:** **`-v <var>`** assign result to this variable instead of printing it.

**Argument:** **`$1`** string to clean up

### L_strip_ansi_vL_RET

### L_ansi_up

Move cursor $1 lines up (CUU - Cursor Up)

**Argument:** **`$1`** int number of lines (default: 1)

### L_ansi_down

Move cursor $1 lines down (CUD - Cursor Down)

**Argument:** **`$1`** int number of lines (default: 1)

### L_ansi_right

Move cursor $1 columns right (CUF - Cursor Forward)

**Argument:** **`$1`** int number of columns (default: 1)

### L_ansi_left

Move cursor $1 columns left (CUB - Cursor Backward)

**Argument:** **`$1`** int number of columns (default: 1)

### L_ansi_next_line

Move cursor to beginning of line $1 lines down (CNL - Cursor Next Line)

**Argument:** **`$1`** int number of lines (default: 1)

### L_ansi_prev_line

Move cursor to beginning of line $1 lines up (CPL - Cursor Previous Line)

**Argument:** **`$1`** int number of lines (default: 1)

### L_ansi_set_column

Move cursor to column $1 (CHA - Cursor Horizontal Absolute)

**Argument:** **`$1`** int column number (1-based)

### L_ansi_set_position

Move cursor to row $1, column $2 (CUP - Cursor Position)

**Arguments:**

- **`$1`** int row number (1-based)
- **`$2`** int column number (1-based)

### L_ansi_set_title

Set terminal window title

**Argument:** **`$*`** str title text

### $L_ANSI_CLEAR_SCREEN_UNTIL_END

Clear screen from cursor to end (ED 0)

### $L_ANSI_CLEAR_SCREEN_UNTIL_BEGINNING

Clear screen from cursor to beginning (ED 1)

### $L_ANSI_CLEAR_SCREEN

Clear entire screen (ED 2)

### $L_ANSI_CLEAR_LINE_UNTIL_END

Clear line from cursor to end (EL 0)

### $L_ANSI_CLEAR_LINE_UNTIL_BEGINNING

Clear line from cursor to beginning (EL 1)

### $L_ANSI_CLEAR_LINE

Clear entire line (EL 2)

### $L_ANSI_SAVE_POSITION

Save cursor position (DECSC)

### $L_ANSI_RESTORE_POSITION

Restore cursor position (DECRC)

### L_ansi_print_on_line_above

Move cursor $1 lines above, output remaining args, then move cursor $1 lines down.

**Arguments:**

- **`$1`** int lines above
- **`$2...`** str to print

### L_ansi_8bit_fg

Set 256-color foreground color

**Argument:** **`$1`** int color index (0-255)

### L_ansi_8bit_bg

Set 256-color background color

**Argument:** **`$1`** int color index (0-255)

### L_ansi_8bit_fg_rgb

Set foreground color to 256-color RGB cube value

**Arguments:**

- **`$1`** red (0-5)
- **`$2`** green (0-5)
- **`$3`** blue (0-5)

### L_ansi_8bit_bg_rgb

Set foreground color to 8bit RGB

**Arguments:**

- **`$1`** red
- **`$2`** green
- **`$3`** blue

### L_ansi_24bit_fg

Set foreground color to 24bit RGB

**Arguments:**

- **`$1`** red
- **`$2`** green
- **`$3`** blue

### L_ansi_24bit_bg

Set background color to 24bit RGB

**Arguments:**

- **`$1`** red
- **`$2`** green
- **`$3`** blue
