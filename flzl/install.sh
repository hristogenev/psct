
#!/bin/bash

# Hardcoded download URL
FILEZILLA_URL="https://url-to-filzilla"
FILEZILLA_APP="/Applications/FileZilla.app"

# Check if FileZilla is installed
if [ -d "$FILEZILLA_APP" ]; then
    echo "FileZilla is already installed at $FILEZILLA_APP."
else
    echo "FileZilla is not installed. Downloading from $FILEZILLA_URL..."
    
    # Create a temporary directory for download
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit

    # Download the FileZilla DMG
    curl -L -o FileZilla.dmg "$FILEZILLA_URL"

    # Mount the DMG
    hdiutil attach FileZilla.dmg -nobrowse -quiet
    MOUNT_POINT=$(hdiutil info | grep "/Volumes/FileZilla" | awk '{print $3}')

    # Copy the app to Applications
    cp -R "$MOUNT_POINT/FileZilla.app" /Applications/

    # Unmount the DMG
    hdiutil detach "$MOUNT_POINT" -quiet

    # Clean up
    rm -rf "$TMP_DIR"

    echo "FileZilla has been installed successfully."
fi
