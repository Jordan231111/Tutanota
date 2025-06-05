#!/bin/bash

# Script to download and open Tuta Mail on Ubuntu

# --- FUSE Check & Auto-Install ---
# AppImages require FUSE (Filesystem in Userspace) to run.
# We check for libfuse2, which provides libfuse.so.2 on Debian/Ubuntu systems.
echo "Checking for FUSE (libfuse2)..."
if ! ( [[ "$(dpkg-query -W -f='${Status}' libfuse2 2>/dev/null)" == "install ok installed" ]] || \
       [[ "$(dpkg-query -W -f='${Status}' libfuse2t64 2>/dev/null)" == "install ok installed" ]] ); then
    echo "---------------------------------------------------------------------"
    echo "INFO: FUSE (libfuse2) is not installed, but it's required by AppImages."
    echo "The script will now attempt to install it using 'sudo apt update && sudo apt install -y libfuse2'."
    echo "You may be prompted for your password to authorize the installation."
    echo "---------------------------------------------------------------------"
    
    # Attempt to install libfuse2
    if sudo apt update && sudo apt install -y libfuse2; then
        echo "libfuse2 installation attempted successfully."
    else
        echo "---------------------------------------------------------------------"
        echo "ERROR: libfuse2 installation failed or was cancelled."
        echo "Please try installing it manually: sudo apt update && sudo apt install -y libfuse2"
        echo "Then re-run this script."
        echo "---------------------------------------------------------------------"
        exit 1
    fi

    # Re-check if libfuse2 is now installed
    echo "Re-checking for FUSE (libfuse2) after installation attempt..."
    if ! ( [[ "$(dpkg-query -W -f='${Status}' libfuse2 2>/dev/null)" == "install ok installed" ]] || \
           [[ "$(dpkg-query -W -f='${Status}' libfuse2t64 2>/dev/null)" == "install ok installed" ]] ); then
        echo "---------------------------------------------------------------------"
        echo "ERROR: libfuse2 is still not detected after installation attempt."
        echo "Please ensure it was installed correctly and then re-run this script."
        echo "---------------------------------------------------------------------"
        exit 1
    else
        echo "FUSE (libfuse2) is now installed."
    fi
else
    echo "FUSE (libfuse2) is already installed."
fi
# --- End FUSE Check & Auto-Install ---

# Create a directory to store the download if it doesn't exist
mkdir -p ~/Downloads/tuta-mail

# Download the latest Tuta Mail AppImage
echo "Downloading Tuta Mail..."
# Use -N for timestamping: only download if server file is newer or local is missing.
wget -N -O ~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage https://app.tuta.com/desktop/tutanota-desktop-linux.AppImage

# Make the AppImage executable
chmod +x ~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage

# Create desktop shortcut
echo "Creating desktop shortcut..."
cat > ~/.local/share/applications/tutanota-desktop.desktop << EOF
[Desktop Entry]
Name=Tuta Mail
Comment=Secure email client
Exec=~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage
Icon=tutanota-desktop
Terminal=false
Type=Application
Categories=Network;Email;
EOF

# Install gnome-keyring for safeStorage API
    echo "Attempting to install gnome-keyring for secure storage..."
    sudo apt update && sudo apt install -y gnome-keyring || echo "gnome-keyring installation failed or was skipped, secure storage might not work."

    # Terminate any existing Tuta Mail processes
pkill -f tutanota-desktop-linux.AppImage || true  # || true ensures the script doesn't exit if no process is found

# Launch Tuta Mail
echo "Launching Tuta Mail..."
~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage --disable-gpu --disable-software-rasterizer --disable-gpu-compositing &

echo "---------------------------------------------------------------------"
echo "Tuta Mail installation script finished."
echo "If Tuta Mail did not launch, or you saw FUSE errors earlier,"
echo "ensure libfuse2 is installed and try launching manually from:"
echo "  ~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage"
echo "---------------------------------------------------------------------"