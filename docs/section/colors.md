# L_color

Use the `L_*` variables for colored output.

Use `L_RESET` or `L_COLORRESET` to reset color to defaults.

Use `L_color_detect` to detect if the terminal is supposed to support colors.

The interface is not great. The ultimate goal was to not to use any subshells.

The `L_color_detect` function sets or clears the `L_*` variables related to colors.

The issue is that if you redirect the output, you have to call L_color_detect again for each file descriptor change.

Additionally, if you output to a different file descriptor, you have to call `L_color_detect` again each time changing the file descriptor.

Usually, colors are really used for logging output. Like the following:

The function L_color_detect is not even that costly. However, I do not enjoy the alternative of spawning a subshell.

```
exec {logfd}>&1
L_color_detect >&$logfd
echo "$L_GREEN""Hello world""$L_RESET" >&$logfd
```

## Color and Style Variables

All variables listed in `L_COLOR_VARIABLES` are set by `L_color_enable` and cleared by `L_color_disable`/`L_color_detect` (when color is not supported).

| Category | Variables | ANSI Code | Description |
|----------|-----------|-----------|-------------|
| **Reset** | `L_RESET`, `L_COLORRESET` | `\E[m` / `\E[0m` | Reset all attributes |
| **Text Styles** | | | |
| | `L_BOLD`, `L_BRIGHT` | `\E[1m` | Bold / increased intensity |
| | `L_DIM`, `L_FAINT` | `\E[2m` | Faint / decreased intensity |
| | `L_ITALIC`, `L_STANDOUT` | `\E[3m` | Italic |
| | `L_UNDERLINE` | `\E[4m` | Single underline |
| | `L_BLINK` | `\E[5m` | Slow blink |
| | `L_REVERSE` | `\E[7m` | Reverse video (swap fg/bg) |
| | `L_CONCEAL`, `L_HIDDEN` | `\E[8m` | Conceal / hidden |
| | `L_CROSSEDOUT` | `\E[9m` | Crossed out / strikethrough |
| **Fonts** | | | |
| | `L_FONT0`–`L_FONT9` | `\E[10m`–`\E[19m` | Font selection (0=default, 1-9=alternatives) |
| | `L_FRAKTUR` | `\E[20m` | Fraktur (Gothic) font |
| | `L_DOUBLE_UNDERLINE` | `\E[21m` | Double underline |
| **Style Resets** | | | |
| | `L_NODIM` | `\E[22m` | Reset dim/faint (turn off bold/dim) |
| | `L_NOSTANDOUT` | `\E[23m` | Reset italic/standout |
| | `L_NOUNDERLINE` | `\E[24m` | Reset underline |
| | `L_NOBLINK` | `\E[25m` | Reset blink |
| | `L_NOREVERSE` | `\E[27m` | Reset reverse |
| | `L_NOHIDDEN`, `L_REVEAL` | `\E[28m` | Reset conceal/hidden |
| | `L_NOCROSSEDOUT` | `\E[29m` | Reset crossed out |
| **Foreground Colors (Standard)** | | | |
| | `L_BLACK` | `\E[30m` | Black |
| | `L_RED` | `\E[31m` | Red |
| | `L_GREEN` | `\E[32m` | Green |
| | `L_YELLOW` | `\E[33m` | Yellow |
| | `L_BLUE` | `\E[34m` | Blue |
| | `L_MAGENTA` | `\E[35m` | Magenta |
| | `L_CYAN` | `\E[36m` | Cyan |
| | `L_LIGHT_GRAY` | `\E[37m` | Light gray / white |
| | `L_DEFAULT`, `L_FOREGROUND_DEFAULT` | `\E[39m` | Default foreground |
| **Foreground Colors (Bright/High-intensity)** | | | |
| | `L_DARK_GRAY` | `\E[90m` | Dark gray (bright black) |
| | `L_LIGHT_RED` | `\E[91m` | Light red |
| | `L_LIGHT_GREEN` | `\E[92m` | Light green |
| | `L_LIGHT_YELLOW` | `\E[93m` | Light yellow |
| | `L_LIGHT_BLUE` | `\E[94m` | Light blue |
| | `L_LIGHT_MAGENTA` | `\E[95m` | Light magenta |
| | `L_LIGHT_CYAN` | `\E[96m` | Light cyan |
| | `L_WHITE` | `\E[97m` | White (bright white) |
| **Background Colors (Standard)** | | | |
| | `L_BG_BLACK` | `\E[40m` | Black background |
| | `L_BG_RED` | `\E[41m` | Red background |
| | `L_BG_GREEN` | `\E[42m` | Green background |
| | `L_BG_YELLOW` | `\E[43m` | Yellow background |
| | `L_BG_BLUE` | `\E[44m` | Blue background |
| | `L_BG_MAGENTA` | `\E[45m` | Magenta background |
| | `L_BG_CYAN` | `\E[46m` | Cyan background |
| | `L_BG_LIGHT_GRAY` | `\E[47m` | Light gray background |
| | `L_BG_DEFAULT` | `\E[49m` | Default background |
| **Background Colors (Bright/High-intensity)** | | | |
| | `L_BG_DARK_GRAY` | `\E[100m` | Dark gray background |
| | `L_BG_LIGHT_RED` | `\E[101m` | Light red background |
| | `L_BG_LIGHT_GREEN` | `\E[102m` | Light green background |
| | `L_BG_LIGHT_YELLOW` | `\E[103m` | Light yellow background |
| | `L_BG_LIGHT_BLUE` | `\E[104m` | Light blue background |
| | `L_BG_LIGHT_MAGENTA` | `\E[105m` | Light magenta background |
| | `L_BG_LIGHT_CYAN` | `\E[106m` | Light cyan background |
| | `L_BG_WHITE` | `\E[107m` | White background |
| **Special Effects** | | | |
| | `L_FRAMED` | `\E[51m` | Framed |
| | `L_ENCIRCLED` | `\E[52m` | Encircled |
| | `L_OVERLINED` | `\E[53m` | Overlined |
| | `L_NOENCIRCLED`, `L_NOFRAMED` | `\E[54m` | Not encircled / not framed |
| | `L_NOOVERLINED` | `\E[55m` | Not overlined |

## Constant ANSI Variables (Always Available)

These `L_ANSI_*` variables are **always** set to their escape sequences, regardless of color detection:

| Variable | ANSI Code | Description |
|----------|-----------|-------------|
| `L_ANSI_BOLD`, `L_ANSI_BRIGHT` | `\E[1m` | Bold |
| `L_ANSI_DIM`, `L_ANSI_FAINT` | `\E[2m` | Dim/Faint |
| `L_ANSI_STANDOUT` | `\E[3m` | Italic/Standout |
| `L_ANSI_UNDERLINE` | `\E[4m` | Underline |
| `L_ANSI_BLINK` | `\E[5m` | Blink |
| `L_ANSI_REVERSE` | `\E[7m` | Reverse |
| `L_ANSI_CONCEAL`, `L_ANSI_HIDDEN` | `\E[8m` | Conceal/Hidden |
| `L_ANSI_CROSSEDOUT` | `\E[9m` | Crossed out |
| `L_ANSI_FONT0`–`L_ANSI_FONT9` | `\E[10m`–`\E[19m` | Font selection |
| `L_ANSI_FRAKTUR` | `\E[20m` | Fraktur font |
| `L_ANSI_DOUBLE_UNDERLINE` | `\E[21m` | Double underline |
| `L_ANSI_NODIM` | `\E[22m` | Reset dim |
| `L_ANSI_NOSTANDOUT` | `\E[23m` | Reset italic |
| `L_ANSI_NOUNDERLINE` | `\E[24m` | Reset underline |
| `L_ANSI_NOBLINK` | `\E[25m` | Reset blink |
| `L_ANSI_NOREVERSE` | `\E[27m` | Reset reverse |
| `L_ANSI_NOHIDDEN`, `L_ANSI_REVEAL` | `\E[28m` | Reset conceal |
| `L_ANSI_NOCROSSEDOUT` | `\E[29m` | Reset crossed out |
| **Background Colors (Standard)** | | |
| `L_ANSI_BG_BLACK` | `\E[40m` | Black background |
| `L_ANSI_BG_RED` | `\E[41m` | Red background |
| `L_ANSI_BG_GREEN` | `\E[42m` | Green background |
| `L_ANSI_BG_YELLOW` | `\E[43m` | Yellow background |
| `L_ANSI_BG_BLUE` | `\E[44m` | Blue background |
| `L_ANSI_BG_MAGENTA` | `\E[45m` | Magenta background |
| `L_ANSI_BG_CYAN` | `\E[46m` | Cyan background |
| `L_ANSI_BG_LIGHT_GRAY` | `\E[47m` | Light gray background |
| `L_ANSI_BG_DEFAULT` | `\E[49m` | Default background |
| **Background Colors (Bright/High-intensity)** | | |
| `L_ANSI_BG_DARK_GRAY` | `\E[100m` | Dark gray background |
| `L_ANSI_BG_LIGHT_RED` | `\E[101m` | Light red background |
| `L_ANSI_BG_LIGHT_GREEN` | `\E[102m` | Light green background |
| `L_ANSI_BG_LIGHT_YELLOW` | `\E[103m` | Light yellow background |
| `L_ANSI_BG_LIGHT_BLUE` | `\E[104m` | Light blue background |
| `L_ANSI_BG_LIGHT_MAGENTA` | `\E[105m` | Light magenta background |
| `L_ANSI_BG_LIGHT_CYAN` | `\E[106m` | Light cyan background |
| `L_ANSI_BG_WHITE` | `\E[107m` | White background |

## API Reference

::: bin/L_lib.sh colors