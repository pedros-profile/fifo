#!/usr/bin/env bash
set -e  # exit on any error

# URL for the VS Code stable 64-bit Linux tar.gz (adjust if needed)
URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
FILE="VSCode-linux-x64.tar.gz"

echo "Downloading VS Code..."
curl -L "$URL" -o "$FILE"

# Optional: confirm total file size
SIZE=$(stat -c%s "$FILE")
echo "Downloaded file size: $SIZE bytes"

# Extract to /opt (requires sudo) or a local folder
INSTALL_DIR="$HOME/VSCode"
mkdir -p "$INSTALL_DIR"
echo "Extracting VS Code to $INSTALL_DIR..."
tar -xzf "$FILE" -C "$INSTALL_DIR" --strip-components=1

# Optional: create a symlink to make 'code' command available
ln -sf "$INSTALL_DIR/code" "$HOME/.local/bin/code"

# Confirm installation
if [ -f "$INSTALL_DIR/code" ]; then
    echo "VS Code installed successfully!"
    "$INSTALL_DIR/code" --version
else
    echo "VS Code installation failed."
fi
