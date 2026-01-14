# Generator Pipelines (Flow)

## Overview

The generator system provides a functional programming pattern for Bash that enables lazy evaluation, composition of data transformation stages, and memory-efficient processing of sequences. Generators yield values on-demand rather than producing entire collections upfront, similar to Python generators or Rust iterators.

## Core Concepts

### Generator Pipelines

A generator pipeline consists of three types of stages:

- **Source Generators**: Produce initial values (e.g., `L_flow_source_range`, `L_flow_source_array`)
- **Pipe Generators**: Transform or filter values in transit (e.g., `L_flow_pipe_head`, `L_flow_pipe_map`)
- **Sink Generators**: Consume all values and produce final results (e.g., `L_flow_sink_printf`, `L_flow_sink_assign`)

Pipelines are **lazy** - they only compute values when requested, enabling efficient processing of infinite sequences and reduced memory usage.

### Generator State

The internal `_L_FLOW` array maintains the complete state of a generator pipeline:

- Execution depth tracking
- Context preservation for each stage (allowing resumption)
- Yielded values and metadata
- Completion and pause status

This state management enables generators to suspend and resume execution at precisely-controlled points.

## Basic Usage

### Simple Iteration

```bash
#!/bin/bash
. L_lib.sh

local nums
_L_FLOW + L_flow_source_range 5 + L_flow_sink_assign nums
echo "Numbers: ${nums[@]}"  # Output: Numbers: 0 1 2 3 4
```

### Pipeline Composition

```bash
# Create and run a pipeline: range(0,10) | head(5) | print
_L_FLOW \
  + L_flow_source_range 10 \
  + L_flow_pipe_head 5 \
  + L_flow_sink_printf "%d "  # Output: 0 1 2 3 4
```

### Manual Iteration

```bash
local gen value
L_flow_make gen + L_flow_source_range 5 + L_flow_sink_printf
L_flow_run gen

while L_flow_next gen value; do
  echo "Value: $value"
done
```

## Advanced Patterns

### Filtering and Transformation

```bash
local numbers=(1 0 1 0 1)
_L_FLOW \
  + L_flow_source_array numbers \
  + L_flow_pipe_filter 'L_eval "(( $1 ))"' \
  + L_flow_sink_printf "%d "  # Output: 1 1 1
```

### Tuple Processing

Generators can yield tuples (multiple values per element), enabling complex transformations:

```bash
local keys=(a b c)
local values=(1 2 3)

_L_FLOW \
  + L_flow_source_array keys \
  + L_flow_pipe_enumerate \
  + L_flow_sink_printf "<%d: %s> "  # Output: <1: a> <2: b> <3: c>
```

### Chaining Multiple Generators

```bash
# Process data through multiple transformation stages
_L_FLOW \
  + L_flow_source_range 10 \
  + L_flow_pipe_filter 'L_eval "(( $1 % 2 == 0 ))"' \
  + L_flow_pipe_map 'L_eval "L_v=$(($1 * 2))"' \
  + L_flow_sink_printf "%d "  # Even numbers doubled
```

## Key Functions

### Pipeline Construction

**`L_flow_new var func1 func2 ...`**

Initialize a generator pipeline with the given functions. Functions are stored with their execution context for lazy evaluation.

```bash
local gen
L_flow_new gen L_flow_source_range 5 L_flow_pipe_head 3
```

**`L_flow_make var + func1 args... + func2 args... +`**

Build a pipeline using DSL syntax where `+` separates stages. Provides more readable syntax for complex pipelines.

```bash
local gen
L_flow_make gen + L_flow_source_range 5 + L_flow_pipe_head 3 + L_flow_sink_printf
```

### Pipeline Execution

**`L_flow_run var`**

Start execution of the pipeline. Must be called once before consuming values.

```bash
L_flow_make gen + L_flow_source_range 5 + L_flow_sink_printf
L_flow_run gen
```

**`L_flow_next context var...`**

Request the next value from the pipeline. The generator context (first argument) must be explicitly provided - use `-` to refer to the current `_L_FLOW` variable. Returns 0 on success, non-zero when exhausted. Designed for use in while loops.

```bash
# Using explicit generator variable
local gen
L_flow_make gen + L_flow_source_range 5 + L_flow_sink_printf
L_flow_run gen
while L_flow_next gen value; do
  echo "Got: $value"
done

# Using default _L_FLOW with - shorthand
while L_flow_next - value; do
  echo "Got: $value"
done
```

**`L_flow_next_ok status_var gen var`**

Request the next value while storing success status in a variable. Useful for complex control flow where direct return codes are inconvenient.

```bash
local ok value
L_flow_next_ok ok gen value
if (( ok )); then
  echo "Got: $value"
fi
```

## Generator Types

### Sources

| Function | Description |
|----------|-------------|
| `L_flow_source_range [start] stop [step]` | Generate integers in a range |
| `L_flow_source_array arrayname` | Iterate over array elements |
| `L_flow_source_args args...` | Iterate over positional arguments |
| `L_flow_source_repeat value [count]` | Repeat a value indefinitely or N times |
| `L_flow_source_count [start] [step]` | Infinite counter (start, start+step, ...) |
| `L_flow_source_string_chars string` | Iterate over individual characters |

### Pipes (Transformers)

| Function | Description |
|----------|-------------|
| `L_flow_pipe_head n` | Yield first N elements |
| `L_flow_pipe_tail n` | Yield last N elements |
| `L_flow_pipe_filter cmd` | Filter by predicate command |
| `L_flow_pipe_map cmd` | Transform each element |
| `L_flow_pipe_enumerate` | Prepend zero-based index |
| `L_flow_pipe_unique_everseen` | Yield unique elements (preserving order) |
| `L_flow_pipe_stride n` | Yield every Nth element |
| `L_flow_pipe_batch n` | Group elements into tuples of N |
| `L_flow_pipe_zip_arrays arrayname` | Pair with array elements |
| `L_flow_pipe_sort [-n] [-A] [-k field]` | Sort all elements |

### Sinks (Consumers)

| Function | Description |
|----------|-------------|
| `L_flow_sink_printf [fmt]` | Print elements to stdout |
| `L_flow_sink_assign arrayname` | Collect into array |
| `L_flow_sink_map cmd` | Execute command for each element |
| `L_flow_sink_quantify cmd` | Count elements matching predicate |
| `L_flow_sink_fold_left -i init cmd` | Reduce to single value |
| `L_flow_sink_all_equal cmd` | Check if all elements equal |
| `L_flow_sink_first_true [-d default] cmd` | Find first matching element |

## Performance Considerations

### Memory Efficiency

Generators process elements on-demand, avoiding the need to store entire intermediate collections:

```bash
# Efficient: only stores 3 elements at a time (one per pipeline stage)
_L_FLOW + L_flow_source_range 1000000 + L_flow_pipe_head 3 + L_flow_sink_printf

# vs. inefficient (without generators):
local arr=()
for (( i=0; i<1000000; i++ )); do arr+=($i); done
for (( i=0; i<3; i++ )); do echo "${arr[i]}"; done
```

### Lazy Evaluation

Generator pipelines only compute what is consumed. This enables processing of infinite sequences:

```bash
# This never loops infinitely - head(5) stops after 5 elements
_L_FLOW + L_flow_source_count + L_flow_pipe_head 5 + L_flow_sink_printf
```

## Stateful Generators

Generator functions can maintain local state across multiple yields using `L_flow_restore`:

```bash
my_generator() {
  local counter=0
  L_flow_restore counter

  # Yield values while incrementing counter
  while (( counter < 10 )); do
    L_flow_yield "value_$counter"
    (( ++counter ))
  done
}
```

The `L_flow_restore` function:
1. Registers a return trap to save local variables
2. Loads previously saved state (if any)
3. Enables resumable state across yields

## Error Handling

Generator pipelines use `L_panic` for fatal errors. The `L_flow_next` return code indicates pipeline status:

- Return 0: Successfully yielded a value
- Return 1: Pipeline exhausted (no more values)
- Return 2+: Fatal error (invalid state, wrong arguments, etc.)

```bash
while L_flow_next gen value; do
  # Process value
done
# After loop: generator is exhausted
```

::: bin/L_lib.sh generator

