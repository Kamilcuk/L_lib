#!/bin/bash
. L_lib.sh -s

# Level 2: Sub-commands for 'remote'
CMDREMOTE_add() {
    L_argparse -- name -- url ---- "$@"
    echo "Adding remote '$name' with URL '$url'"
}

CMDREMOTE_remove() {
    L_argparse -- name ---- "$@"
    echo "Removing remote '$name'"
}

# Level 1: Main commands
CMD_clone() {
    L_argparse -- repo_url ---- "$@"
    echo "Cloning from $repo_url"
}

CMD_remote() {
    # This function acts as a sub-parser for remote commands
    L_argparse \
        description="Manage remote repositories" \
        -- call=function prefix=CMDREMOTE_ \
        ---- "$@"
}

# Main parser entry point
L_argparse \
    prog="git" \
    -- call=function prefix=CMD_ \
    ---- "$@"
