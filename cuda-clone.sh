# Use this script to clone only the cuda folder of this repository
#!/bin/bash

REPO_URL="https://github.com/ratulb/mojo_programming"
FOLDER_PATH="cuda"
TARGET_DIR="${3:-$(basename "$REPO_URL" .git)}"

echo "Cloning $FOLDER_PATH from $REPO_URL into $TARGET_DIR..."

git clone --filter=blob:none --no-checkout "$REPO_URL" "$TARGET_DIR"
cd "$TARGET_DIR" || exit 1

git sparse-checkout init --cone
git sparse-checkout set "$FOLDER_PATH"
git checkout

echo "✅ Done. Folder '$FOLDER_PATH' is checked out in '$TARGET_DIR'."



