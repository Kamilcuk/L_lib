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

Result: The `[[ $- == *e* ]]` implementation is the fastest to parse. It is functionally smaller and bypasses the structure needed for `case`, taking ~0.0020 seconds compared to ~0.0025 seconds.

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

Result: In pure runtime execution, the `case` statement proves to be the most performant implementation. It executes approximately 60% faster than the original `shopt` method and holds a ~5% speed advantage over conditional checks (`[[ ]]`). This demonstrates that for high-iteration logic within the Bash evaluator, native POSIX keywords like `case` bypass the overhead of evaluating condition expressions.

## Bash Patterns (QEMU Exact Instruction Counts)

| Pattern | Instruction Cost (100x) | Per Iteration |
| :--- | :--- | :--- |
| `((1))` | 1,893,564 | 18,935 |
| `[[ 1 ]]` | 1,926,536 | 19,265 |
| `:` | 2,096,439 | 20,964 |
| `f() { :; }; f` | 3,440,324 | 34,403 |

Result: `((1))` is the fastest success state.

### Array Operations (100-element array)

| Operation | Total Instructions | Incremental Cost |
| :--- | :--- | :--- |
| `${#arr[@]}` | 2,839,169 | 3,515 |
| `${#arr[*]}` | 2,839,169 | 3,515 |
| `${arr[*]+${#arr[*]}}` | 2,941,785 | 106,131 |
| `${arr[*]}` | 3,256,346 | 420,692 |

Result: `${#arr[@]}` is the fastest length retrieval method.

### Parameter Expansion

| Expansion | Total Instructions | Instruction Delta |
| :--- | :--- | :--- |
| `${v+x}` | 688,595 | 0 |
| `${v:+x}` | 688,869 | +274 |

Result: `${v+x}` is faster than `${v:+x}`.

### Short-Circuiting

| Operation | Total Instructions | Instruction Delta |
| :--- | :--- | :--- |
| `(( A && B ))` | 711,790 | 0 |
| `(( A )) && (( B ))` | 710,934 | -856 |

Result: External short-circuiting with `&&` between `(( ))` blocks is the fastest way to skip logic.


### Callback Execution (eval)

| Pattern | Instructions (cb=':') |
| :--- | :--- |
| `eval "${cb:-}"` | 704,412 |
| `[[ -n "$cb" ]] && eval "$cb"` | 714,949 |
| `${cb:+eval} ${cb:+"$cb"}` | 716,212 |

Result: `eval "${cb:-}"` is the fastest when a callback is present.


### Variable Name Validation (L_is_valid_variable_name)

We compared six different implementations for validating variable names over a test suite of 16 representative valid and invalid names (including `a`, `ab`, `_ac`, `_a9`, `9`, `9a`, `a-`, `-a`, `a `, ` a`, ` a `, `a=b`, `a[0]`, ``, `$((a))`, `rm -rf`).

Measurements were taken using the QEMU deterministic instruction count method:

| Implementation | Instructions (16 inputs) | Relative Cost | Correctness | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Regex Match** (`[[ "$v" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]`) | 4,225,700 | 100.0% | **Correct** | Invokes heavy `regcomp`/`regexec` engine. |
| **Declare Check** (`declare -- "$v" 2>&1`) | 529,870 | 12.5% | **Incorrect** | Incorrectly marks `a=b` and `a[0]` as valid. |
| **Substring Slice** (`[[ ${v:0:1} == [a-zA-Z_] && ... ]]`) | 464,940 | 11.0% | **Correct** | Complex multi-conditional logic. |
| **Extglob Match** (`[[ $v == [a-zA-Z_]*([a-zA-Z0-9_]) ]]`) | 303,088 | 7.1% | **Correct** | Requires `extglob` to be enabled. |
| **3-Glob Check** (`-n $v && != *[^...] && != [0-9]*`) | 331,722 | 7.8% | **Correct** | Simple, portable pattern match. |
| **2-Glob Check** (`== [a-zA-Z_]* && != *[^...]`) | 306,723 | 7.2% | **Correct** | **Fastest & most robust correct portable method.** |

Result: The **2-glob check** method is the fastest correct way to validate a variable name, avoiding the massive dynamic memory and regex compilation overhead of `=~` (~13.7x faster) while remaining portable and independent of `extglob`.


### Numeric Validation (L_is_integer, L_is_float)

We compared the performance of pure glob-based validation vs. regex-based validation (`=~`) for integers and floats.

Measurements were taken using the QEMU deterministic instruction count method:

#### Integer Validation (L_is_integer)
Tested over 12 typical valid and invalid integer inputs (including signs and trailing characters):

| Implementation | Instructions (12 inputs) | Relative Cost | Correctness | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Regex Match** (`[[ "$1" =~ ^[-+]?[0-9]+$ ]]`) | 2,733,340 | 100.0% | **Correct** | Invokes regular expression engine. |
| **Pure Glob** (`[[ -n ${1#[+-]} && ${1#[+-]} != *[^0-9]* ]]`) | 616,425 | 22.6% | **Correct** | **Fastest (4.4x faster)**, entirely native. |

#### Float Validation (L_is_float)
Tested over 16 representative float patterns (e.g., `.2`, `1.2`, `1.`, `-.2`, `-.`, `abc`, `1.2.3`):

| Implementation | Instructions (16 inputs) | Relative Cost | Correctness | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Regex Match** (`[[ "$1" =~ ^[+-]?([0-9]*[.]?[0-9]+|[0-9]+[.])$ ]]`) | 9,744,211 | 100.0% | **Correct** | High regex engine overhead. |
| **Pure Glob** (conditional block with split) | 1,850,228 | 19.0% | **Correct** | **Fastest (5.2x faster)**, entirely native. |

Result: Switching from regular expressions (`=~`) to native Bash glob patterns/parameter expansions for numeric validation yields a **4x to 5x performance improvement** by entirely bypassing regex compilation and memory allocations.


### Real-time Throughput

| Instruction Count | Real Time (Estimated) | Throughput |
| :--- | :--- | :--- |
| 1,000,000 (1M) | 600µs – 800µs | ~1.6 GIPS |


### String Prefix Dispatch: `case` vs `if` with prefix-strip

Two idioms for dispatching on a string prefix and stripping it. Both use the
same strip mechanism (`${str#$pat}`) but differ in control-flow:

- **`case`**: `case "$str" in "$pat"*) tmp=${str#"$pat"} ;; "$pat2"*) tmp=${str#"$pat2"} ;; esac`
- **`if`**: `if tmp=${str#"$pat"}; [[ "$tmp" != "$str" ]]; then :; else tmp=${str#"$pat2"}; [[ "$tmp" != "$str" ]] && :; fi`

Profiled with `L_bash_profile compare -m qemu` (deterministic instruction
count). Both snippets produce identical `tmp` (verified: `[value][value]`).

**Scenario 1 — first pattern matches (common case):**

| Implementation | Instructions | Δ |
| :--- | :--- | :--- |
| `case "$str" in "$pat"*) tmp=${str#"$pat"} ;; "$pat2"*) ... ;; esac` | **65 644** | — |
| `if tmp=${str#"$pat"}; [[ "$tmp" != "$str" ]]; then ...` | 92 974 | +27 330 (+42%) |

**Scenario 2 — first pattern fails, second matches:**

| Implementation | Instructions | Δ |
| :--- | :--- | :--- |
| `case ...` | **67 620** | — |
| `if ...` | 123 204 | +55 584 (+82%) |

**Variant — `if` with the assignment moved inside the branch**
(`if [[ "${str#"$pat"}" != "$str" ]]; then tmp=${str#"$pat"}; else tmp=${str#"$pat2"}; fi`):

| Implementation | Instructions | Δ |
| :--- | :--- | :--- |
| `case ...` | **92 624** | — |
| `if` (assignment inside branch) | 111 290 | +18 666 (+20%) |

**Why `case` wins:**
1. The `if` idiom computes and assigns `${str#"$pat"}` *unconditionally* before the
   test, even when the pattern misses and the `else` branch runs instead. `case`
   only evaluates the matching branch body.
2. `[[ "$tmp" != "$str" ]]` is a separate command with its own parse/eval overhead;
   `case` folds the match-test and dispatch into one builtin operation.
3. Even the improved `if` variant computes `${str#"$pat"}` twice in the taken branch
   (once in the `[[ ]]` test, once in the assignment).

**Recommendation:** prefer `case` for multi-pattern prefix dispatch — it is ~40%
cheaper in the common case and ~80% cheaper when early patterns miss. If `if` is
required, keep the assignment inside the branch (the +20% variant) rather than the
pre-assignment form (+42% / +82%).

### Leading Whitespace Trim of a JSON string (`_L_json`)

**Task:** strip leading whitespace. Source under test: `temp/trim_functions.sh`.
Benchmarked with `L_bash_profile compare` (QEMU deterministic instruction counts
and wall-clock time). Input: 1KB JSON with 3 leading spaces (`_L_json_1k`).

**Why each approach was presented:**
- `trim_orig` / `trim_simple` — single expression `${_L_json#${_L_json%%[![:space:]]*}}`.
  `%%[![:space:]]*` finds the leading whitespace run (greedy scan to first
  non-space), then `#` strips it. `trim_orig` quotes the nested expansion;
  `trim_simple` does not. Edge case: when there is no leading whitespace,
  `%%[![:space:]]*` returns the whole string, so `#` strips the first char
  (off-by-one bug).
- `trim_fixed` / `trim_fixed_opt` / `trim_fixed_long` / `trim_orig_opt` — split
  into a local variable + conditional, so when the run is empty nothing is
  stripped. Compared `[[ -n "$x" ]]` vs `(( ${#x} ))`, and short (`x`) vs long
  (`leading_ws`) variable name.
- `trim_extglob` — `##+([[:space:]])` (requires `extglob`). Matches and removes
  the longest leading whitespace run.
- `trim_read` / `trim_shortest` / `trim_regex` / `trim_printf` — alternatives.
  `trim_read` (`read -r _L_json <<< "$_L_json"`) truncates at the first newline,
  so it is incorrect for multi-line JSON.

**Results (QEMU instruction counts, 1KB JSON):**

| Function | Instructions | Δ vs best | % |
| :--- | :--- | :--- | :--- |
| `trim_orig_opt` | 284,528 | — | baseline |
| `trim_fixed_opt` | 285,015 | +487 | +0.17% |
| `trim_fixed` (`[[ -n ]]`, short x) | 288,000 | +3,472 | +1.22% |
| `trim_fixed_long` (long var) | 290,593 | +6,065 | +2.13% |
| `trim_simple` | 402,930 | +118,402 | +41.6% |
| `trim_extglob` | 454,907 | +170,379 | +59.9% |

`trim_orig_opt` wins (short var `x` + `(( ${#x} ))`). `trim_fixed_opt` is
functionally identical (same body, 487-instruction gap is noise). Long variable
name adds ~2%. `[[ -n ]]` adds ~1% over `(( ${#x} ))`.

**Why `trim_extglob` is slow (O(n²)):**

`+([[:space:]])` is implemented in bash's `EXTMATCH` ('+') branch of `GMATCH`
(`patmatch.c`). The match clause is:

```
for (srest = s; srest <= se; srest++) {
    m1 = GMATCH(s, srest, psub, pnext - 1) == 0;        /* match subpattern once */
    if (m1) {
        m2 = (GMATCH(srest, se, prest, pe) == 0) ||
              (s != srest && GMATCH(srest, se, p - 1, pe) == 0);  /* re-match whole extglob */
    }
    if (m1 && m2) return 0;
}
```

The second `GMATCH` clause re-matches the entire `+([[:space:]])` pattern
against the remainder. To match `n` spaces, `EXTMATCH` recurses `n` times; each
level's inner `srest` loop scans positions from the current offset. Total work ≈
Σ(1..n) = **O(n²)**. At 1KB the gap is ~60%; it grows quadratically with the
length of the leading whitespace run.

By contrast `%%[![:space:]]*` is one greedy left-to-right scan for the first
non-space character: **O(n)**, no recursion. This is why every `trim_*` variant
using `%%[![:space:]]*` beats `trim_extglob`.

**Throughput reference:** ~1.6 GIPS (1M instructions ≈ 600–800µs) →
`trim_orig_opt` at 284,528 instructions ≈ 178µs per call.

**All `trim_*` source (from `temp/trim_functions.sh`):**

```bash
trim_orig() { _L_json="${_L_json#"${_L_json%%[![:space:]]*}"}"; }

trim_simple() { _L_json="${_L_json#${_L_json%%[![:space:]]*}}"; }

trim_fixed() { local leading_ws=${_L_json%%[![:space:]]*}; if [[ -n "$leading_ws" ]]; then _L_json=${_L_json#"$leading_ws"}; fi; }

trim_extglob() { _L_json=${_L_json##+([[:space:]])}; }

trim_fixed_opt() { local x=${_L_json%%[![:space:]]*}; if (( ${#x} )); then _L_json=${_L_json#"$x"}; fi; }

trim_fixed_long() { local leading_ws=${_L_json%%[![:space:]]*}; if (( ${#leading_ws} )); then _L_json=${_L_json#"$leading_ws"}; fi; }

trim_orig_opt() { local x=${_L_json%%[![:space:]]*}; if (( ${#x} )); then _L_json=${_L_json#"$x"}; fi; }

trim_read() { read -r _L_json <<< "$_L_json"; }

trim_shortest() { _L_json="${_L_json#*[![:space:]]}"; _L_json="${_L_json#"${_L_json%%[![:space:]]*}"}"; }

trim_regex() { [[ "$_L_json" =~ ^[[:space:]]*(.*) ]]; _L_json="${BASH_REMATCH[1]}"; }

trim_printf() { printf -v _L_json '%s' "$_L_json"; }
```
