Construct context aware function on top of L_finally.

```
do_stuff_in_temporary_directory() {
  L_with_cd_tmpdir
  echo 123 > tmpfile
  # cd to previous directory and remove tmpdir automatically both on exit and on function return
}

temporary_cd_to_tmp() {
  L_with_cd /tmp/
  echo now in tmp > tmpfile
}
```

# Generated documentation from source:

::: bin/L_lib.sh with
