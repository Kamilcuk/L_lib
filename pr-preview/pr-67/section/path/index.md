## API Reference

## path

### L_basename

The filename

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

### L_basename_vL_RET

### L_dirname

parent of the path

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

### L_dirname_vL_RET

### L_path_extension

The last dot-separated portion of the final component, if any.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

**See:** <https://en.cppreference.com/w/cpp/filesystem/path/extension.html>

### L_path_extension_vL_RET

### L_path_extensions

A list of the path’s suffixes, often called file extensions.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

**See:** <https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.suffixes>

### L_path_extensions_vL_RET

### L_path_stem

The final path component, without its suffix:

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

**See:** <https://en.cppreference.com/w/cpp/filesystem/path/stem>

### L_path_stem_vL_RET

### L_path_with_name

Return a new path with the name changed.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** path
- **`$1`** new name

### L_path_with_name_vL_RET

### L_path_with_stem

Return a new path with the stem changed.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** path
- **`$2`** new stem

### L_path_with_stem_vL_RET

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

### L_path_with_suffix

Return a new path with the suffix changed.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** path
- **`$2`** new suffix

### L_path_with_suffix_vL_RET

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

### L_path_is_absolute

Return whether the path is absolute or not.

### L_path_normalize

Replace multiple slashes by one slash.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Argument:** **`$1`** path

### L_path_normalize_vL_RET

**Shellcheck disable=** [SC2064](https://www.shellcheck.net/wiki/SC2064)

### L_path_relative_to

Compute a version of the original path relative to the path represented by other path.

This method is string-based.

**Option:** **`-v <var>`** Store the output in variable instead of printing it.

**Arguments:**

- **`$1`** original path
- **`$2`** other path

**See:**

- <https://docs.python.org/3/library/pathlib.html#pathlib.PurePath.relative_to>
- <https://stackoverflow.com/a/12498485/9072753>

### L_path_relative_to_vL_RET

**Shellcheck disable=** [SC2179](https://www.shellcheck.net/wiki/SC2179)

### L_path_is_relative_to

Check if a path is relative to other path.

This method is string-based; it neither accesses the filesystem nor treats “..” segments specially. Consider as alternative: L_path_relative_to -v tmp "$1" "$2" && \[[ "$tmp" == ../\* ]\]

Example

```
L_path_is_relative_to /etc/passwd /etc  # return 0
L_path_is_relative_to /etc/passwd /usr  # return 1
```

**Arguments:**

- **`$1`** Path to check
- **`$2`** Path that $1 should be relative to.

### L_path_append

Append a path to path variable if not already there.

Example

```
L_path_append PATH ~/.local/bin
```

**Arguments:**

- **`$1`** Variable name. For example PATH
- **`$2`** Path to append. For example /usr/bin
- **`[$3]`** Optional path separator. Default: ':'

### L_path_prepend

Prepend a path to path variable if not already there.

Example

```
L_path_append PATH ~/.local/bin
```

**Arguments:**

- **`$1`** Variable name. For example PATH
- **`$2`** Path to prepend. For example /usr/bin
- **`[$3]`** Optional path separator. Default: ':'

### L_path_remove

Remove a path from a path variable.

Example

```
L_path_append PATH ~/.local/bin
```

**Arguments:**

- **`$1`** Variable name. For example PATH
- **`$2`** Path to prepend. For example /usr/bin
- **`[$3]`** Optional path separator. Default: ':'

### L_dir_is_empty

Return 0 if a directory is empty.

**Argument:** **`$1`** Directory.
