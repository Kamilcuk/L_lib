# Caching Utilities

Functions for caching command execution, exit codes, and output.

## Usage Guide

### Caching Command Output and Return Code

Use `L_cache` to execute a command and cache its output and exit status. Subsequent calls with the same command will retrieve the cached state.

```bash
# Execute and cache command output to a variable
L_cache -O result_var curl -sS https://example.com

# Retrieve stdout from cache
L_cache -O result_var curl -sS https://example.com
echo "$result_var"
```

### File-Based Caching

By default, caching is stored in memory. Use `-f` to persist the cache to a file.

```bash
L_cache -f /tmp/my_cache.bin -O result_var curl -sS https://example.com
```

### Cache Expiry (TTL)

Set a time-to-live (TTL) on cached entries using duration strings.

```bash
# Cache is valid for 10 minutes
L_cache -T 10m -O result_var curl -sS https://example.com
```

### Managing Side-Effect Variables

Save and restore internal state or environment variables alongside the command's exit code.

```bash
count=42
L_cache -s count -k my_operation_key my_command_or_function
```

### Decorating Functions for Automatic Caching

The standard practice is to decorate functions with `L_cache`. This wraps function execution to retrieve from or write to the cache.

```bash
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

```bash
# List all cache entries
L_cache -l

# Clear the entry for a specific command/key
L_cache -r -k my_operation_key

# Clear the entire memory cache
L_cache -r
```

## API Reference

::: bin/L_lib.sh cache
