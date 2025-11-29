# L_with - Context Managers (Python's "with" statement)

Python-style context managers for Bash - automatically manage resources that need cleanup, built on top of [`L_finally`](https://kamilcuk.github.io/L_lib/section/finally/).

## Why L_with?

Common patterns like "change directory temporarily" or "create temp directory and clean it up" require repetitive boilerplate. Context managers handle the setup and cleanup automatically:

```bash
# Without L_with - manual cleanup, error-prone
func() {
	local old_pwd=$PWD
	cd /tmp
	# do work...
	cd "$old_pwd"  # What if previous command failed?
}

# With L_with - automatic cleanup
func() {
	L_with_cd /tmp
	# do work...
	# Automatically returns to previous directory
}
```

## Available Context Managers

### L_with_cd - Temporary Directory Change

Change directory and automatically return to previous location:

```bash
process_in_directory() {
	L_with_cd /var/log
	# Now in /var/log
	grep ERROR *.log
	# Automatically returns to previous directory when function returns
}

# Or at script level
main() {
	L_with_cd "$project_dir"
	# Work in project directory
	./build.sh
	# Returns to previous directory on exit
}
```

### L_with_cd_tmpdir - Temporary Directory with Auto-Cleanup

Create a temporary directory, cd into it, and automatically remove it on exit:

```bash
build_in_isolated_env() {
	L_with_cd_tmpdir
	# Now in a new temporary directory
	pwd  # Prints something like: /tmp/tmp.XYZ123

	# Do your work
	git clone https://github.com/user/repo
	cd repo && make

	# Temp directory automatically deleted when function returns
}

# Practical example: safe extraction
extract_and_process() {
	L_with_cd_tmpdir
	tar xzf "$1"
	# Process extracted files
	./configure && make
	# All cleaned up automatically
}
```

### L_with_tmpdir - Create Temp Directory (No cd)

Create a temporary directory and store its path, with automatic cleanup:

```bash
process_with_workspace() {
	local tmpdir
	L_with_tmpdir -v tmpdir

	# Use tmpdir without changing directory
	echo "Working in: $tmpdir"
	cp input.txt "$tmpdir/"
	process_file "$tmpdir/input.txt"

	# Tmpdir automatically removed on function return
}
```

### L_with_file - Temporary File with Auto-Cleanup

Create a temporary file with automatic cleanup:

```bash
process_data() {
	local tmpfile
	L_with_file -v tmpfile

	# Use temporary file
	curl -s https://api.example.com/data > "$tmpfile"
	jq '.results[]' "$tmpfile"

	# File automatically deleted
}
```

## Practical Examples

### Safe Build Script

```bash
#!/bin/bash
. L_lib.sh
set -e

build_project() {
	local repo=$1

	# Create isolated build environment
	L_with_cd_tmpdir

	# Clone and build
	git clone "$repo" project
	cd project

	./configure
	make
	make test

	# Copy artifacts out before cleanup
	cp build/*.tar.gz "$OLDPWD/"

	# Cleanup happens automatically
}

build_project "https://github.com/user/project"
echo "Build artifacts ready!"
```

### Process Multiple Archives Safely

```bash
#!/bin/bash
. L_lib.sh

process_archive() {
	local archive=$1

	# Each archive processed in its own temp directory
	L_with_cd_tmpdir

	L_info "Processing $archive"
	tar xzf "$archive"

	# Process files
	for file in *; do
		process_file "$file"
	done

	# Cleanup automatic - no leaked temp directories!
}

for archive in *.tar.gz; do
	process_archive "$archive"
done
```

### Testing with Temporary Environment

```bash
#!/bin/bash
. L_lib.sh

test_installation() {
	# Create fake HOME directory
	local fake_home
	L_with_tmpdir -v fake_home

	# Set up test environment
	export HOME="$fake_home"
	export XDG_CONFIG_HOME="$fake_home/.config"

	# Run installation
	./install.sh

	# Verify
	[[ -f "$fake_home/.config/myapp/config.ini" ]] || L_error "Config not created"

	# Cleanup automatic
}
```

### Download and Process with Cleanup

```bash
download_and_convert() {
	local url=$1
	local output=$2

	local tmpfile
	L_with_file -v tmpfile .mp4  # Temp file with .mp4 extension

	# Download
	L_info "Downloading $url"
	curl -sL "$url" -o "$tmpfile"

	# Process
	L_info "Converting to $output"
	ffmpeg -i "$tmpfile" "$output"

	# tmpfile deleted automatically
}
```

## How It Works

All `L_with_*` functions use [`L_finally -r`](https://kamilcuk.github.io/L_lib/section/finally/) to register cleanup actions:

```bash
L_with_cd() {
	local dir=$1
	local oldpwd=$PWD

	cd "$dir"

	# Register cleanup to run on function return/exit/signal
	L_finally -r cd "$oldpwd"
}
```

This means:
- ✅ Cleanup runs on normal return
- ✅ Cleanup runs on early return
- ✅ Cleanup runs on `exit` command
- ✅ Cleanup runs on signals (SIGTERM, SIGINT, etc.)
- ✅ Cleanup runs on errors with `set -e`

# Generated documentation from source:

::: bin/L_lib.sh with
