# Caching Utilities

Functions for caching command execution, exit codes, and output.

## Usage Guide

### Caching Command Output and Return Code

Use `L_cache` to execute a command and cache its output and exit status. Subsequent calls with the same command will retrieve the cached state.

```
# Execute and cache command output to a variable
L_cache -O result_var curl -sS https://example.com

# Retrieve stdout from cache
L_cache -O result_var curl -sS https://example.com
echo "$result_var"
```

### File-Based Caching

By default, caching is stored in memory. Use `-f` to persist the cache to a file.

```
L_cache -f /tmp/my_cache.bin -O result_var curl -sS https://example.com
```

### Cache Expiry (TTL)

Set a time-to-live (TTL) on cached entries using duration strings.

```
# Cache is valid for 10 minutes
L_cache -T 10m -O result_var curl -sS https://example.com
```

### Managing Side-Effect Variables

Save and restore internal state or environment variables alongside the command's exit code.

```
count=42
L_cache -s count -k my_operation_key my_command_or_function
```

### Decorating Functions for Automatic Caching

The standard practice is to decorate functions with `L_cache`. This wraps function execution to retrieve from or write to the cache.

```
# Define a function with variables to cache
fetch_data() {
    api_result="data from server"
}

# Decorate the function to save the variable state on future calls
L_decorate L_cache -s api_result fetch_data

# First call executes the function
fetch_data

# Subsequent calls load the cached state and restore api_result
fetch_data
```

### Listing and Clearing Cache Entries

List all active cache entries in a formatted table, or clear specific keys or the entire cache.

```
# List all cache entries
L_cache -l

# Clear the entry for a specific command/key
L_cache -r -k my_operation_key

# Clear the entire memory cache
L_cache -r
```

## API Reference

## cache

### L_cache

Cache the execution of a command.

The command execution is cached in \_L_CACHE global variable or in file when -f option is present. The second execution of the command will result in a cached execution. On cached execution the exit status of the command will be extracted from the cache.

Example

```
L_cache -T 10m -O output -f /tmp/cache.L_cache curl -sS https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html

myfunc() { var=$(( 1 + 2 )); }
L_decorate L_cache -s var -k myfunc myfunc
myfunc
myfunc

mydata() { curl "$@" https://website.com; }
L_decorate L_cache -O website_data mydata
mydata -sS
echo "$website_data"
mydata
echo "$website_data"

L_data -k mydata -l
```

**Options:**

- **`-o`**

  Cache the stdout of the command and output it.

  It will run the command in a process substitution.

- **`-O <var>`**

  Cache the stdout of the command and store it in variable instead of printing.

  It will run the command in a process substitution.

- **`-s <var>`** Save this variable to the cache. All cache variables will be restored on cached execution.

- **`-f <file>`**

  Use the file as cache.

  The file has a header with version number. The file stores internal cache state from declare -p \_L_CACHE variable. The file content is eval-ed upon loading.

- **`-r`**

  Instead of executing, clear the cache.

  If used with -k or with command, clear only the specific key.

- **`-l`**

  Instead of executing, list the entires in the cache in a table. Use twice to not limit to 100 characters.

  If used with -k or with command, list only the specific key.

- **`-T <ttl>`**

  Set time to live in duration string. Default: infinity.

  The TTL is checked by the caller. The option should be specified every call.

- **`-L <01>`** If 1, use flock, if 0, do not use flock. Default: autodetect based on flock availability.

- **`-k <key>`** Use this key to index the cache. Default: space joined %q quoted command.

- **`-h`** Print this help and return 0.

**Argument:** **`$@`** Command to execute.

**Sets variable:** **`_L_CACHE`**

**Uses environment variable:** **`_L_CACHE`**

**Shellcheck disable=** [SC2094](https://www.shellcheck.net/wiki/SC2094)

**Return:**

64 ($L_EX_USAGE) or other error code on invalid usage or error

otherwise returns the exit status of the cached command.
