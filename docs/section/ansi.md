# ANSI Section

The `ansi` section of `L_lib.sh` provides a minimal interface for using ANSI escape codes in your bash scripts. These codes allow you to control the terminal's cursor, change text colors, and modify text formatting.

## What are ANSI escape codes?

ANSI escape codes are special sequences of characters that, when printed to the terminal, are interpreted as commands rather than as literal text. They are used to produce colored text, to move the cursor around on the screen, and to clear parts of the screen.

The `ansi` section provides a set of functions that make it easier to use these codes without having to memorize the raw escape sequences.

## Functions

This section includes functions for:

-   **Cursor Movement**: `L_ansi_up`, `L_ansi_down`, `L_ansi_left`, `L_ansi_right`, `L_ansi_next_line`, `L_ansi_prev_line`, `L_ansi_set_column`, `L_ansi_set_position`.
-   **Screen Clearing**: `L_ANSI_CLEAR_SCREEN_UNTIL_END`, `L_ANSI_CLEAR_SCREEN_UNTIL_BEGINNING`, `L_ANSI_CLEAR_SCREEN`, `L_ANSI_CLEAR_LINE_UNTIL_END`, `L_ANSI_CLEAR_LINE_UNTIL_BEGINNING`, `L_ANSI_CLEAR_LINE`.
-   **Text Formatting**: Functions for setting 8-bit and 24-bit colors.
-   **Other**: `L_ansi_set_title`, `L_ansi_print_on_line_above`.

## Examples

Here are some examples of how to use the functions in this section. You can find more examples in the test script: `scripts/test/ansi/test.sh`.

### Cursor Movement

```bash
#!/usr/bin/env bash
source bin/L_lib.sh

echo -n "Hello"
L_ansi_left 2
echo -n "y"
L_ansi_right 1
echo "!"
# Expected output: Hellyo!
```

### Progress Bar

```bash
#!/usr/bin/env bash
source bin/L_lib.sh

echo
for i in $(seq 5); do
  L_ansi_print_on_line_above 1 "Progress: $i/5"
  sleep 0.5
done
echo "Done."
```

### 24-bit Colors

```bash
#!/usr/bin/env bash
source bin/L_lib.sh

L_ansi_24bit_fg 200 100 200
echo "Hello in pink"
echo -n "$L_RESET"
```

## Generated documentation from source:

::: bin/L_lib.sh ansi