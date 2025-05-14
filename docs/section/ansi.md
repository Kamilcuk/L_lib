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

## Generated documentation from source:

::: bin/L_lib.sh ansi
