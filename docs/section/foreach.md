# L_foreach

`L_foreach` is a powerful and flexible Bash function for iterating over the elements of one or more arrays. It provides a clean, readable alternative to complex `for` loops, especially when you need to process items in groups or iterate over associative arrays in a controlled manner.

It is used within a `while` loop, and on each iteration, it assigns values from the source array(s) to one or more variables. The loop continues as long as `L_foreach` can assign at least one variable.

## Basic Usage: Iterating Over a Single Array

The simplest use case is iterating over a standard array and assigning each element to a single variable. The syntax requires you to specify the variable name(s), a colon separator `:`, and the array name(s).

```bash
#!/bin/bash
. L_lib.sh -s

# Define an array of strings
servers=("server-alpha" "server-beta" "server-gamma")

# Loop over each server
while L_foreach name : servers; do
  echo "Pinging server: $name"
  # ping -c 1 "$name"
done
```
**Output:**
```
Pinging server: server-alpha
Pinging server: server-beta
Pinging server: server-gamma
```

## Processing Items in Groups (Tuples)

`L_foreach` can assign multiple variables on each iteration, allowing you to process an array in fixed-size chunks or "tuples".

```bash
# An array containing filenames and their corresponding sizes
files_data=("report.txt" "1024" "image.jpg" "4096" "archive.zip" "16384")

# Process the array in pairs
while L_foreach filename size : files_data; do
  echo "File '$filename' is $size bytes."
done
```
**Output:**
```
File 'report.txt' is 1024 bytes.
File 'image.jpg' is 4096 bytes.
File 'archive.zip' is 16384 bytes.
```
If the number of elements is not a perfect multiple of the variables, the last iteration will assign the remaining elements, and the leftover variables will be unset.

## Iterating Over Associative Arrays

Handling associative arrays (or "dictionaries") is a key feature. By default, the iteration order is not guaranteed.

```bash
# Define an associative array mapping services to ports
declare -A services=([http]=80 [ssh]=22 [smtp]=25)

# -k saves the key, and 'port' gets the value
while L_foreach -k service_name port : services; do
  echo "Service '$service_name' runs on port $port."
done
```
**Example Output (order may vary):**
```
Service 'http' runs on port 80.
Service 'ssh' runs on port 22.
Service 'smtp' runs on port 25.
```

### Sorted Iteration

To iterate in a predictable order, use the `-s` flag to sort by the array keys.

```bash
declare -A services=([http]=80 [ssh]=22 [smtp]=25)

echo "--- Services sorted by name ---"
while L_foreach -s -k name port : services; do
  echo "Service: $name (Port: $port)"
done
```
**Output:**
```
--- Services sorted by name ---
Service: http (Port: 80)
Service: smtp (Port: 25)
Service: ssh (Port: 22)
```

## Combining Multiple Arrays

`L_foreach` can iterate over multiple arrays in parallel.

### Horizontal Iteration (Default)

This is useful for processing consecutive lists of data.

```bash
local users=("alice" "bob")
local roles=("admin" "editor")

# The loop processes 'users', then continues with 'roles'
while L_foreach identity : users roles; do
  echo "Processing identity: $identity"
done
```
**Output:**
```
Processing identity: alice
Processing identity: bob
Processing identity: admin
Processing identity: editor
```

### Vertical Iteration (with `-k`)

When used with `-k`, `L_foreach` pairs elements from multiple arrays that share the same key. This is extremely powerful for correlating data between associative arrays.

```bash
declare -A user_roles=([alice]=admin [bob]=editor)
declare -A user_ids=([alice]=101 [bob]=102)

# Iterate using the keys from both arrays
while L_foreach -s -k name role id : user_roles user_ids; do
  echo "User: $name, ID: $id, Role: $role"
done
```
**Output:**
```
User: alice, ID: 101, Role: admin
User: bob, ID: 102, Role: editor
```

## Tracking Loop State

You can track the loop's progress using special flags:
- `-i <var>`: Stores the current loop index (starting from 0) in `<var>`.
- `-f <var>`: Stores `1` in `<var>` during the first iteration, `0` otherwise.
- `-l <var>`: Stores `1` in `<var>` during the last iteration, `0` otherwise.

```bash
items=("A" "B" "C")
separator=", "

while L_foreach -i idx -l is_last value : items; do
  echo -n "[$idx] $value"
  if (( ! is_last )); then
    echo -n "$separator"
  fi
done
echo # for a final newline
```
**Output:**
```
[0] A, [1] B, [2] C
```

# Generated documentation from source:

::: bin/L_lib.sh foreach
