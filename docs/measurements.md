# Is dir empty?

```
-r 100 -b find -b ls -C /dev -C /usr -C / -C empty -C big -- 'find "$1" -mindepth 1 -maxdepth 1 | read' 'test -z "$(find "$1" -maxdepth 0 -empty)"' '[ "$(ls -A "$1")" ]' '[[ "$(ls -A "$1")" ]]' 'if test -e "$1/"*; then true; else (($?!=1)); fi' 'files=("$1"/* "$1"/.[^.]*); ((${#files[@]} != 2))' 'test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"'
```

| command                                                              | arg   | exit | instructions | seconds time elapsed            |
| ---                                                                  | ---   | ---  |              |                                 |
| `test -z "$(find "$1" -maxdepth 0 -empty)"`                          | /dev  | 0    | 1981601      | 0.0009061 ± 0.0000387 (4.27%)   |
| `test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"` | /dev  | 1    | 2055759      | 0.0011436 ± 0.0000283 (2.48%)   |
| `if test -e "$1/"*; then true; else (($?!=1)); fi`                   | /dev  | 0    | 2233459      | 0.00072149 ± 0.00000642 (0.89%) |
| `find "$1" -mindepth 1 -maxdepth 1 | read`                           | /dev  | 0    | 2284273      | 0.0010268 ± 0.0000404 (3.94%)   |
| `[[ "$(ls -A "$1")" ]]`                                              | /dev  | 0    | 2430653      | 0.0009046 ± 0.0000391 (4.32%)   |
| `[ "$(ls -A "$1")" ]`                                                | /dev  | 0    | 2468331      | 0.0009171 ± 0.0000389 (4.24%)   |
| `files=("$1"/* "$1"/.[^.]*); ((${#files[@]} != 2))`                  | /dev  | 0    | 2490835      | 0.0006879 ± 0.0000148 (2.15%)   |
| `if test -e "$1/"*; then true; else (($?!=1)); fi`                   | /usr  | 0    | 1594127      | 0.0005913 ± 0.0000126 (2.13%)   |
| `files=("$1"/* "$1"/.[^.]*); ((${#files[@]} != 2))`                  | /usr  | 0    | 1606758      | 0.0005577 ± 0.0000199 (3.58%)   |
| `[[ "$(ls -A "$1")" ]]`                                              | /usr  | 0    | 1904873      | 0.0008632 ± 0.0000336 (3.90%)   |
| `[ "$(ls -A "$1")" ]`                                                | /usr  | 0    | 1914554      | 0.0008816 ± 0.0000316 (3.59%)   |
| `find "$1" -mindepth 1 -maxdepth 1 | read`                           | /usr  | 0    | 1931748      | 0.0010043 ± 0.0000366 (3.65%)   |
| `test -z "$(find "$1" -maxdepth 0 -empty)"`                          | /usr  | 0    | 1981546      | 0.0008748 ± 0.0000374 (4.28%)   |
| `test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"` | /usr  | 1    | 2055694      | 0.0011720 ± 0.0000223 (1.90%)   |
| `if test -e "$1/"*; then true; else (($?!=1)); fi`                   | /     | 0    | 1599489      | 0.0005817 ± 0.0000176 (3.02%)   |
| `files=("$1"/* "$1"/.[^.]*); ((${#files[@]} != 2))`                  | /     | 0    | 1614535      | 0.0005450 ± 0.0000192 (3.53%)   |
| `[[ "$(ls -A "$1")" ]]`                                              | /     | 0    | 1909617      | 0.0008516 ± 0.0000350 (4.11%)   |
| `[ "$(ls -A "$1")" ]`                                                | /     | 0    | 1919528      | 0.0008605 ± 0.0000343 (3.98%)   |
| `find "$1" -mindepth 1 -maxdepth 1 | read`                           | /     | 0    | 1936727      | 0.0010168 ± 0.0000343 (3.38%)   |
| `test -z "$(find "$1" -maxdepth 0 -empty)"`                          | /     | 0    | 1981238      | 0.0008708 ± 0.0000368 (4.22%)   |
| `test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"` | /     | 1    | 2055181      | 0.0011162 ± 0.0000272 (2.43%)   |
| `if test -e "$1/"*; then true; else (($?!=1)); fi`                   | empty | 1    | 1584803      | 0.00060368 ± 0.00000941 (1.56%) |
| `files=("$1"/* "$1"/.[^.]*); ((${#files[@]} != 2))`                  | empty | 1    | 1601101      | 0.0005958 ± 0.0000127 (2.12%)   |
| `[[ "$(ls -A "$1")" ]]`                                              | empty | 1    | 1897740      | 0.0008604 ± 0.0000337 (3.91%)   |
| `[ "$(ls -A "$1")" ]`                                                | empty | 1    | 1906997      | 0.0008962 ± 0.0000314 (3.50%)   |
| `find "$1" -mindepth 1 -maxdepth 1 | read`                           | empty | 1    | 1921719      | 0.0010397 ± 0.0000364 (3.50%)   |
| `test -z "$(find "$1" -maxdepth 0 -empty)"`                          | empty | 1    | 1984623      | 0.0008788 ± 0.0000365 (4.16%)   |
| `test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"` | empty | 0    | 2052891      | 0.0011422 ± 0.0000279 (2.44%)   |
| `test -z "$(find "$1" -maxdepth 0 -empty)"`                          | big   | 0    | 1981470      | 0.0009637 ± 0.0000388 (4.03%)   |
| `test -z "$(find "$@" -maxdepth 0 "!" "(" -empty -type d ")" 2>&1)"` | big   | 1    | 2055578      | 0.0011548 ± 0.0000324 (2.81%)   |
| `find "$1" -mindepth 1 -maxdepth 1 | read`                           | big   | 0    | 8455111      | 0.0025564 ± 0.0000294 (1.15%)   |
| `[[ "$(ls -A "$1")" ]]`                                              | big   | 0    | 23102512     | 0.0030810 ± 0.0000548 (1.78%)   |
| `[ "$(ls -A "$1")" ]`                                                | big   | 0    | 23992066     | 0.0031162 ± 0.0000508 (1.63%)   |
| `if test -e "$1/"*; then true; else (($?!=1)); fi`                   | big   | 0    | 32164808     | 0.0030001 ± 0.0000222 (0.74%)   |
| `files=("$1"/* "$1"/.[^.]*); ((${#files[@]} != 2))`                  | big   | 0    | 42237627     | 0.00403384 ± 0.00000903 (0.22%) |


## `L_sete` Implementation Profiling (Profiled on GNU bash, version 5.1.16(1)-release x86_64-pc-linux-gnu)


We profiled four different implementations of the `L_sete` function to measure both parsing/startup overhead and pure runtime execution overhead. The four implementations tested were:
1. `shopt -po errexit >/dev/null`
2. `[[ $- == *e* ]]`
3. `[[ -o errexit ]]`
4. `case $- in *e*)`

### Scenario 1: Single Execution (Parsing Overhead)
This scenario measures the time it takes for Bash to parse the function definition and execute it a single time.

```
-r 100 --no-bwrap -C 1 --prefix '. /tmp/l_sete_funcs.sh; ' 'L_sete_shopt :' 'L_sete_match :' 'L_sete_opt :' 'L_sete_case :'
```

| command          | arg | exit | instructions | seconds time elapsed          |
| ---              | --- | ---  |              |                               |
| `L_sete_case :`  | 1   | 0    |              | 0.0025979 ± 0.0000321 (1.24%) |
| `L_sete_match :` | 1   | 0    |              | 0.0020370 ± 0.0000296 (1.45%) |
| `L_sete_opt :`   | 1   | 0    |              | 0.0026350 ± 0.0000419 (1.59%) |
| `L_sete_shopt :` | 1   | 0    |              | 0.0022563 ± 0.0000392 (1.74%) |

**Result:** The `[[ $- == *e* ]]` implementation is the fastest to parse. It is functionally smaller and bypasses the structure needed for `case`, taking ~0.0020 seconds compared to ~0.0025 seconds.

### Scenario 2: Loop Execution (Runtime Overhead)
This scenario measures the pure runtime execution overhead by defining the function once and running it 10,000 times (5,000 times with `+e` and 5,000 times with `-e`).

```
-r 100 --no-bwrap -C 1 --prefix '. /tmp/l_sete_funcs.sh; ' loop_shopt loop_match loop_opt loop_case
```

| command      | arg | exit | instructions | seconds time elapsed      |
| ---          | --- | ---  |              |                           |
| `loop_case`  | 1   | 0    |              | 0.26593 ± 0.00178 (0.67%) |
| `loop_match` | 1   | 0    |              | 0.27963 ± 0.00247 (0.88%) |
| `loop_opt`   | 1   | 0    |              | 0.27852 ± 0.00260 (0.93%) |
| `loop_shopt` | 1   | 0    |              | 0.42494 ± 0.00561 (1.32%) |

**Result:** In pure runtime execution, the `case` statement proves to be the most performant implementation. It executes approximately 60% faster than the original `shopt` method and holds a ~5% speed advantage over conditional checks (`[[ ]]`). This demonstrates that for high-iteration logic within the Bash evaluator, native POSIX keywords like `case` bypass the overhead of evaluating condition expressions.
