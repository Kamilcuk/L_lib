`L_HAS_` is a collection of functions to detect bash features.

```
if ((L_HAS_SRANDOM)); then
  echo "SRANDOM is supported $SRANDOM"
else
  echo "SRANDOM is not supported"
fi
```

::: bin/L_lib.sh has
