#!/bin/bash

# Script to download and open Tuta Mail on Ubuntu
# Create a directory to store the download if it doesn't exist
mkdir -p ~/Downloads/tuta-mail

# Download the latest Tuta Mail AppImage
echo "Downloading Tuta Mail..."
wget -O ~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage https://app.tuta.com/desktop/tutanota-desktop-linux.AppImage

# Make the AppImage executable
chmod +x ~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage

# Create desktop shortcut
echo "Creating desktop shortcut..."
cat > ~/.local/share/applications/tutanota.desktop << EOF
[Desktop Entry]
Name=Tuta Mail
Comment=Secure email client
Exec=~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage
Icon=mail-client
Terminal=false
Type=Application
Categories=Network;Email;
EOF

# Launch Tuta Mail
echo "Launching Tuta Mail..."
~/Downloads/tuta-mail/tutanota-desktop-linux.AppImage & 