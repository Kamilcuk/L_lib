#!/usr/bin/env bash
set -euo pipefail

# Find script directory and source L_lib
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR"/../bin/L_lib.sh -s

L_argparse \
  prog="bash-manager" \
  description="Manage multi-version Bash compilation and testing using Git worktrees." \
  -- version help="Bash version (e.g., 3.2, 4.0, 5.2, 5.3)." required=true \
  -- action choices="clear compile test all" help="Action to perform." default="all" \
  ---- "$@"

# Setup paths
BUILD_DIR="$DIR/build"
mkdir -p "$BUILD_DIR"

base_repo="$BUILD_DIR/bash.git"
SRC_REPO="$DIR/../tmp/bash"

# 1. Initialize bare repository if not exists
if [[ ! -d "$base_repo" ]]; then
  L_log "Initializing bare Bash clone in $base_repo from $SRC_REPO"
  L_logrun git clone --bare "$SRC_REPO" "$base_repo"
fi

# 2. Resolve tag name
tag="bash-$version"
if [[ "$version" == "3.2" ]]; then
  tag="bash-3.2-beta"
fi

# 3. Add worktree if not exists
worktree_dir="$BUILD_DIR/bash-$version"
if [[ ! -d "$worktree_dir" ]]; then
  L_log "Creating git worktree for Bash $version in $worktree_dir"
  L_logrun git -C "$base_repo" worktree add -f "$worktree_dir" "$tag"
fi


if [[ "$action" == "clear" ]]; then
  L_logrun make -C $worktree_dir distclean
  exit
fi

# 4. Compile Action
if [[ "$action" == "compile" || "$action" == "all" ]]; then
  if [[ ! -x "$worktree_dir/bash" ]]; then
    L_log "Configuring and compiling Bash $version in $worktree_dir"
    pushd "$worktree_dir" >/dev/null
    # Legacy versions need older standards
    export CFLAGS="-Wno-old-style-definition -Wno-implicit-function-declaration -std=gnu99 -Wno-int-conversion -w -Wno-implicit-int -Wno-implicit-function-declaration -Wno-discarded-qualifiers -D_GNU_SOURCE -Wno-return-mismatch"
    L_logrun ./configure
    L_logrun make LOCAL_CFLAGS="$CFLAGS"
    popd >/dev/null
  else
    L_log "Bash $version is already compiled."
  fi
fi

# 5. Test Action
if [[ "$action" == "test" || "$action" == "all" ]]; then
  L_log "Building and testing builtin against Bash $version..."
  pushd "$DIR" >/dev/null
  L_logrun make build B="build/$version" BASH_INC="build/bash-$version" BASH="build/bash-$version/bash"
  L_logrun make test B="build/$version" BASH_INC="build/bash-$version" BASH="build/bash-$version/bash"
  popd >/dev/null
fi
