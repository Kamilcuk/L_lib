# Bugs

List of inconsistencies between Bash versions discovered along making this library.

```
run() { docker run --rm bash:"$1" bash -s; }
```

## Bash 3.2 replacement expansion

```
$ run 3.2 <<EOF
a='}}'; echo ${a//'}}'/'}'}
EOF
'}'
```
