When discovering Bash one of the missing features is _not_ try catch block, but try finally.

The issue with trap is that:
  - I add trap signals every time different `trap 'rm -rf "$tmpf"' 1 2 3 or EXIT or SIGINT?`
  - I cannot append to the trap, which makes conditional logic really hard.
    Usually I end up creating all temporary files on top of the script just to have one trap for them all.
  - I cannot stop traps. I would want to trap execute when I stop using the resource, but
      - trap EXIT executes on the end of the script
      - trap RETURN no one knows when will execute and might execute on every RETURN from every function everywhere forever.

I do not really need "try catch". I need "try finally". I need cleanup. Thus the `L_finally` library came alive.

The `L_finally <action>` call:
  - Registers the action to execute on `EXIT`, `SIGINT` and `SIGTERM`.
  - The action will execute only once and only in the current process id, not anywhere or anytime else.
  - The option `-r` will add the action to execute on RETURN and will also `set -o functrace`.
      - It will only execute on RETURN from the current function in the current file which called the `L_finally` function.
      - If the action has been executed on RETURN, then it will not execute on EXIT.
      - If you happen to EXIT before getting to RETURN, the action still will be executed on EXIT.
  - Multiple calls append the actions to execute in reverse order.

Additionally, the `L_finally_pop` will execute and remove the last registered action.

Example:

```
#!/bin/bash
. L_lib.sh L_argparse \
  -- --option \
  ---- "$@"

tmpf=$(mktemp)
L_finally rm -rf "$tmpf"
: do something to tmpf >"$tmpf"

if [[ -n "$option" ]]; then
  tmpf2=$(mktemp)
  L_finally rm -rf "$tmpf2"
  : we need another tmpf2 >"$tmpf2"
  : it is ok, we can remove it now
  L_finally_pop
if

# tmp will be removed on the end of the script.
```

Function auto cleanup:

```
some_function() {
  local tmpf=$(mktemp)
  L_finally -r rm -rf "$tmpf"
  echo Do something with temporary file >"$tmpf"

  # exit 1    # this would remove the tempfile
  # return 1  # this would also remove the tempfile
  # the tempfile is automatically removed on the end of function
}
```

The action will register itself to `EXIT` and signals. The idea is, that you should be able to still hook your own custom action.


::: bin/L_lib.sh finally
