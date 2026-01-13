#!/bin/bash

set -euo pipefail

# Config
FILEZILLA_APP_NAME="FileZilla.app"
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
curl -fL -o "$ARCHIVE_PATH" "$DOWNLOAD_URL"

echo "Extracting archive..."
tar -xjf "$ARCHIVE_PATH" -C "$TMP_DIR"

# Install FileZilla.app to /Applications
echo "Installing ${FILEZILLA_APP_NAME} to /Applications..."
if command -v ditto >/dev/null 2>&1; then
    ditto "${TMP_DIR}/${FILEZILLA_APP_NAME}" "$TARGET_APP"
else
    cp -R "${TMP_DIR}/${FILEZILLA_APP_NAME}" "/Applications/"
fi

echo "${FILEZILLA_APP_NAME} has been installed successfully at: ${TARGET_APP}"