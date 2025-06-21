Bugs or inconsistencies between Bash versions discovered along making this library.

You can test the examples with the script `bash.sh` in the repository that runs docker with a specific Bash version. You can pass the script to it by using here document with a quoted delimiter, so not to care about quotes.

```
$ bash -x ./bash.sh 4.2 -x <<'EOF'
The script to test.
EOF
```

## Bash <4.3 preserves quotes in `${var//repl/<here>}`

```
a='}}'; echo "${a//'}}'/'}'}"
```

| Bash | output |
| --- | --- |
| <=4.3 | `'}'` |
| >=4.4 | `}` |

## Bash <4.4 declare -p outputs quoted arrays and $'\001' in front of $'\001' and $'\177' bytes.

```
a=(); declare -p a
```


| Bash | output |
| --- | --- |
| <=4.3 | `declare -a a='()'` |
| >=4.4 | `declare -a a=()` |


```
a=$'\001\177'; printf "%q\n" "$(declare -p a)"
```

| Bash | output |
| --- | --- |
| <=4.3 | `$'declare -- a="\001\001\001\177"'` |
| >=4.4 | `$'declare -- a="\001\177"'` |                                                            

## Bash >=4.0 all hell breaks loose with IFS=$'\001'

Bash _greater or equal_ version 4.0. Tested up to version 5.3-rc2.

```
IFS=$'\001'; a=(one); printf "%q " "${a[@]}"
```

| Bash | output |
| --- | --- |
| >=4.0 | `'' '' o '' n '' e ` |
| 3.2 | `one` |

I recommend using ASCII group separator character `L_GS=$'\035'` for a custom separator.

## Bash 3.1 [[ =~ is incompatible with 3.2 because quoting change

The problem is that the argument to `=~` after Bash3.2 doesn't have to be quoted.

This makes porting scripts to Bash 3.1 painful.

```
[[ a =~ (a) ]]; echo $?
```

| Bash | result |
| --- | --- |
| >=3.2 | `0` |
| <=3.1 | `syntax error near (a` |

## Bash 4.2.53 segfaults when using array variable inside (( )) and using it again after comma operator.

``` 
a=(1); (( b = a[0], a = b ))
```

| Bash | result |
| --- | --- |
| ==4.2 | segmentation fault, exit code 139 |
| !=4.2 | |

## Bash <=4.2 wrongly evaluates arrays in (( )) when array is used twice

```
array=1; (( array[0]<0 ? tmp=array[0] : (tmp=2) )); echo "tmp=$tmp"
```

| Bash | output |
| --- | --- |
| <=3.1 | `tmp=2` |
| >=3.2,<=4.1 | `tmp=1` |
| >=4.2 | `tmp=2` |

## Calling a function with a lot of arguments is slow

When optimizing `L_argparse` I noticed a particular slowdown - the function was really short, but still profiling showed it is very slow. Turns out the act of _calling_ the function with a lot of arguments is very slow.

Refactoring to using an array brought significant speedup.
