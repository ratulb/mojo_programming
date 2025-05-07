#!/bin/bash

# Usage: ./sparse-clone.sh [<target-dir>]
REPO_URL="https://github.com/ratulb/mojo_programming"
FOLDER_PATH="cuda"
TARGET_DIR="${3:-$(basename "$REPO_URL" .git)}"

# Check arguments
if [ -z "$REPO_URL" ] || [ -z "$FOLDER_PATH" ]; then
  echo "Usage: $0 [<target-dir>]"
  exit 1
fi

echo "🔄 Cloning '$FOLDER_PATH' from '$REPO_URL' into '$TARGET_DIR'..."

# Clone with minimal data, no checkout yet
git clone --filter=blob:none --no-checkout "$REPO_URL" "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

# Enable sparse checkout (non-cone mode)
git sparse-checkout init --no-cone

# Set sparse folder only (no root-level files)
echo "$FOLDER_PATH" > .git/info/sparse-checkout

# Checkout just the folder
git checkout

echo "✅ Done. Only '$FOLDER_PATH' is checked out in '$TARGET_DIR'."

