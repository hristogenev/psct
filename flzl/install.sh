
#!/bin/bash

set -euo pipefail

# Config
FILEZILLA_APP_NAME="FileZilla.app"   # Change if the extracted .app has a different name
DOWNLOAD_URL="https://github.com/hristogenev/psct/raw/refs/heads/main/flzl/flzl.app.tar.bz2"
TARGET_APP="/Applications/${FILEZILLA_APP_NAME}"

# Ensure we can write to /Applications
if [ ! -w "/Applications" ]; then
    echo "You don't have permission to write to /Applications."
    echo "Please re-run this script with sudo: sudo $0"
    exit 1
fi

# Check if FileZilla is already installed
echo "Checking for ${FILEZILLA_APP_NAME}..."
if [ -d "$TARGET_APP" ]; then
    echo "${FILEZILLA_APP_NAME} is already installed at ${TARGET_APP}."
    exit 0
fi

# Create temporary directory
TMP_DIR="$(mktemp -d)"
ARCHIVE_PATH="${TMP_DIR}/flzl.app.tar.bz2"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading archive from: ${DOWNLOAD_URL}"
if ! curl -fL -o "$ARCHIVE_PATH" "$DOWNLOAD_URL"; then
    echo "Download failed. Please check the URL or your network connection."
    exit 1
fi

if [ ! -s "$ARCHIVE_PATH" ]; then
    echo "Downloaded file is empty. Aborting."
    exit 1
fi

echo "Extracting tar.bz2..."
if ! tar -xjf "$ARCHIVE_PATH" -C "$TMP_DIR"; then
    echo "Extraction failed. The archive might be corrupted or not a tar.bz2."
    exit 1
fi

echo "Locating .app bundle..."
EXTRACTED_APP_PATH="$(find "$TMP_DIR" -maxdepth 3 -type d -name "*.app" | head -n 1 || true)"
if [ -z "$EXTRACTED_APP_PATH" ]; then
    echo "No .app bundle found in the archive. Please ensure the archive contains a .app directory."
    exit 1
fi

ACTUAL_APP_NAME="$(basename "$EXTRACTED_APP_PATH")"
if [ "$ACTUAL_APP_NAME" != "$FILEZILLA_APP_NAME" ]; then
    TARGET_APP="/Applications/${ACTUAL_APP_NAME}"
fi

echo "Installing ${ACTUAL_APP_NAME} to /Applications..."
if command -v ditto >/dev/null 2>&1; then
    ditto "$EXTRACTED_APP_PATH" "$TARGET_APP"
else
    cp -R "$EXTRACTED_APP_PATH" "/Applications/"
fi

echo "${ACTUAL_APP_NAME} has been installed successfully at: ${TARGET_APP}"
echo "You can open it from Launchpad or Applications."
