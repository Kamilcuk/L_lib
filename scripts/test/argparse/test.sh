#!/usr/bin/env bash

set -e

source bin/L_lib.sh

# Simple example with options and positional arguments
echo "--- Simple Example ---"
L_argparse \
	prog="myapp" \
	description="Process some files" \
	-- filename help="Input file to process" \
	-- -c --count type=int default=1 help="Number of times to process" \
	-- -v --verbose action=store_true help="Enable verbose output" \
	---- "input.txt" "-c" "3" "--verbose"

echo "filename=$filename count=$count verbose=$verbose"
echo

# Flags and Options
echo "--- Flags and Options ---"
L_argparse \
	-- -v --verbose action=store_true help="Verbose output" \
	-- -q --quiet action=store_true help="Quiet mode" \
	-- -o --output required=1 help="Output file" \
	-- -c --count type=int default=1 help="Count" \
	---- -v -o "output.txt"

echo "verbose=$verbose quiet=$quiet output=$output count=$count"
echo

# Multiple Values (Arrays)
echo "--- Multiple Values (Arrays) ---"
L_argparse \
	-- files nargs=+ help="Files to process" \
	---- "file1.txt" "file2.txt" "file3.txt"

for file in "${files[@]}"; do
	echo "Processing: $file"
done
echo

# Subcommands
echo "--- Subcommands ---"
cmd_init() {
	L_argparse \
		description="Initialize a new repository" \
		-- --bare action=store_true help="Create bare repository" \
		---- "$@"

	echo "Initializing repository (bare=$bare)"
}

cmd_clone() {
	L_argparse \
		description="Clone a repository" \
		-- url help="Repository URL" \
		-- directory nargs='?' help="Destination directory" \
		---- "$@"

	echo "Cloning $url to ${directory:-./}"
}

L_argparse \
	prog="mygit" \
	description="A git-like tool" \
	-- call=function prefix=cmd_ subcall=detect \
	---- "clone" "https://example.com/repo.git"
echo

# Podman example
echo "--- Podman Example ---"
L_argparse \
    description="Set default trust policy or a new trust policy for a registry" \
    epilog="god" \
    -- -f --pubkeysfile dest=stringArray action=append help="Path of installed public key(s) to trust for TARGET. Absolute path to keys is added to policy.json. May used multiple times to define multiple public keys. File(s) must exist before using this command" \
    -- -t --type dest=type metavar=string help="Trust type, accept values: signedBy(default), accept, reject" default="signedBy" show_default=1 choices='signedBy accept reject' \
    -- -o --option \
    -- REGISTRY dest=registry \
    ---- -f "key1.pub" -f "key2.pub" -t "accept" "my-registry"

echo "pubkeysfile=${stringArray[@]} type=$type registry=$registry"

echo "Test complete."
