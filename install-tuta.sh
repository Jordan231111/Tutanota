#!/bin/bash
#
# Script to download, install, and launch the Tuta Mail AppImage on Debian/Ubuntu-based systems.
# It ensures all dependencies are met and sets up a desktop shortcut.

# --- Configuration ---
set -e # Exit immediately if a command exits with a non-zero status.

# Paths and filenames
INSTALL_DIR=~/Downloads/tuta-mail
APP_IMAGE_NAME="tutanota-desktop-linux.AppImage"
APP_IMAGE_PATH="${INSTALL_DIR}/${APP_IMAGE_NAME}"
DESKTOP_ENTRY_NAME="tutanota-desktop.desktop"
DESKTOP_ENTRY_PATH="${HOME}/.local/share/applications/${DESKTOP_ENTRY_NAME}"
DOWNLOAD_URL="https://app.tuta.com/desktop/tutanota-desktop-linux.AppImage"
REQUIRED_PACKAGES=("gnome-keyring")

# --- Functions ---

# Function to check for FUSE and add it to dependencies if missing.
# AppImages require FUSE (Filesystem in Userspace) to run.
# We check for libfuse2, which provides libfuse.so.2 on Debian/Ubuntu systems.
check_and_add_fuse() {
    echo "Checking for FUSE (libfuse2)..."
    if dpkg-query -W -f='${Status}' libfuse2 2>/dev/null | grep -q "install ok installed"; then
        echo "FUSE (libfuse2) is already installed."
    else
        echo "INFO: FUSE (libfuse2) not found. It will be added to the list of dependencies to install."
        REQUIRED_PACKAGES+=("libfuse2")
    fi
}

# Function to install required packages if they are not already present.
install_dependencies() {
    local packages_to_install=()
    for pkg in "$@"; do
        # Check if the package is already installed.
        if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "install ok installed"; then
            packages_to_install+=("${pkg}")
        fi
    done

    if [ ${#packages_to_install[@]} -gt 0 ]; then
        echo "---------------------------------------------------------------------"
        echo "The following required packages are missing: ${packages_to_install[*]}"
        echo "The script will now attempt to install them using 'sudo apt-get'."
        echo "You may be prompted for your password."
        echo "---------------------------------------------------------------------"
        
        sudo apt-get update
        sudo apt-get install -y "${packages_to_install[@]}"
        
        echo "Dependency installation process finished."
    else
        echo "All required dependencies are already satisfied."
    fi
}

# Function to handle the download and setup of the Tuta Mail AppImage.
download_and_setup_app() {
    echo "Ensuring installation directory exists at ${INSTALL_DIR}..."
    mkdir -p "${INSTALL_DIR}"

    echo "Downloading the latest Tuta Mail AppImage..."
    # Use -N for timestamping: only download if server file is newer or local is missing.
    wget -N -O "${APP_IMAGE_PATH}" "${DOWNLOAD_URL}"

    echo "Making the AppImage executable..."
    chmod +x "${APP_IMAGE_PATH}"

    echo "Creating desktop shortcut at ${DESKTOP_ENTRY_PATH}..."
    # Create a desktop entry for application launchers.
    cat > "${DESKTOP_ENTRY_PATH}" << EOF
[Desktop Entry]
Name=Tuta Mail
Comment=Secure email client
Exec=${APP_IMAGE_PATH} --disable-gpu --disable-software-rasterizer --disable-gpu-compositing
Icon=tutanota-desktop
Terminal=false
Type=Application
Categories=Network;Email;
EOF
}

# --- Main Execution ---
main() {
    check_and_add_fuse
    install_dependencies "${REQUIRED_PACKAGES[@]}"
    download_and_setup_app

    echo "Terminating any existing Tuta Mail processes to ensure a clean start..."
    # || true prevents the script from exiting if no process is found.
    pkill -f "${APP_IMAGE_NAME}" || true

    echo "Launching Tuta Mail..."
    # Launch in the background to not block the terminal.
    nohup "${APP_IMAGE_PATH}" --disable-gpu --disable-software-rasterizer --disable-gpu-compositing >/dev/null 2>&1 &

    echo "---------------------------------------------------------------------"
    echo "Tuta Mail installation and launch script finished."
    echo "You can find the application launcher in your applications menu."
    echo "The AppImage is located at: ${APP_IMAGE_PATH}"
    echo "---------------------------------------------------------------------"
}

# Run the main function
main