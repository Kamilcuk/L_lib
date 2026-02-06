Construct context aware function on top of `L_finally`.

The `with` module implements the RAII (Resource Acquisition Is Initialization) pattern for Bash. It allows you to acquire resources (change directory, create temporary files) that are automatically cleaned up when the current function returns, regardless of how it exits (return or error).

## Usage Guide

### Changing Directory (`L_with_cd`)

Use `L_with_cd` to temporarily change the current working directory. The original directory is restored automatically when the function returns.

```bash
my_function() {
    # Change to /tmp
    L_with_cd /tmp
    
    # Do work in /tmp
    pwd 
    
    # When my_function returns, we automatically cd back to where we started.
}
```

### Temporary Files (`L_with_tmpfile_to`)

Create a temporary file that is automatically deleted when the function returns.

```bash
process_data() {
    local temp_file
    # Create temp file and store path in 'temp_file'
    L_with_tmpfile_to temp_file
    
    echo "some data" > "$temp_file"
    process "$temp_file"
    
    # temp_file is removed automatically here
}
```

### Temporary Directories (`L_with_tmpdir_to`, `L_with_cd_tmpdir`)

You can create a temporary directory or create it and immediately `cd` into it.

```bash
# Create a temp dir, use it, and have it removed automatically
use_temp_dir() {
    local dir
    L_with_tmpdir_to dir
    touch "$dir/file1"
}

# Create a temp dir, cd into it, and have it removed and cwd restored automatically
work_in_isolation() {
    L_with_cd_tmpdir
    # Now in a fresh empty directory in /tmp
    echo "stuff" > data.txt
    # On return: cd back to original dir, and remove the temp dir.
}
```

### Redirecting Stdout to Variable (`L_with_redirect_stdout_to`)

This function allows you to capture the standard output of the current function into a variable. It avoids the performance penalty and subshell isolation of `$(...)`.

**Important:** The capture happens when the function *returns*. Therefore, the target variable must be visible after the function returns (e.g., a global variable, or a local variable in the calling function, or a nameref).

```bash
# Capture stdout of this function into the variable named by $1
get_config_data() {
    # $1 is the name of the variable to store result in
    L_with_redirect_stdout_to "$1"
    
    echo "key=value"
    echo "status=ok"
}

main() {
    local result
    get_config_data result
    echo "Got: $result"
}
```

## API Reference

::: bin/L_lib.sh with
