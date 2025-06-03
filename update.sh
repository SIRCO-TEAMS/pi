#!/bin/bash

echo "***************************************************************"
echo "* Made by Timmy307                                           *"
echo "* GitHub: Timco307                                           *"
echo "*                                                            *"
echo "* This script will safely update your Raspberry Pi.          *"
echo "* IMPORTANT: A system reboot is REQUIRED after the update.   *"
echo "* The system will reboot automatically once completed.       *"
echo "***************************************************************"
echo ""

# Default values
update_confirmed=false
firmware_update=false
skip_update=false

# Parse command-line arguments
while getopts "ynf" opt; do
    case "$opt" in
        y) update_confirmed=true ;;  # Automatically confirm update
        n) skip_update=true ;;       # Skip system update entirely
        f) firmware_update=true ;;   # Enable firmware update (hidden option)
        *) echo "Usage: $0 [-y] [-n] [-f]"
           echo "  -y  Automatically confirm system update"
           echo "  -n  Skip system update"
           echo "  -f  Force firmware update (Use ONLY as a last resort!)"
           exit 1 ;;
    esac
done

# Prevent users from doing both -y and -n simultaneously
if $update_confirmed && $skip_update; then
    echo "***************************************************************"
    echo "* ERROR: You cannot use both -y and -n at the same time!      *"
    echo "* Please choose either to confirm (-y) or skip (-n) update.  *"
    echo "***************************************************************"
    exit 1
fi

# Skip update if the user chose -n
if $skip_update; then
    echo "System update skipped. Please save your work and rerun this script when ready."
else
    if ! $update_confirmed; then
        read -p "Do you want to proceed with the update? (Y/N): " choice
        case "$choice" in
            [Nn])
                echo "Update canceled. Please save your work and rerun this script when ready."
                exit 0
                ;;
            *) update_confirmed=true ;;
        esac
    fi

    echo "Starting system update..."
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt full-upgrade -y
    sudo apt autoremove -y
fi

# Firmware update logic (only runs if -f was used)
if $firmware_update; then
    echo "***************************************************************"
    echo "* WARNING: Firmware updates should ONLY be done as a last     *"
    echo "* resort and with permission from the device owner.           *"
    echo "* This can affect system stability and should be used sparingly! *"
    echo "***************************************************************"
    read -p "Are you sure you want to update the firmware? (Y/N): " firmware_choice
    if [[ "$firmware_choice" =~ ^[Yy]$ ]]; then
        sudo rpi-update
        echo "Firmware update complete!"
    else
        echo "Skipping firmware update."
    fi
fi

echo "*********************************************************************************"
echo "* System update complete! Your Raspberry Pi will now run the rest of the files  *"
echo "*********************************************************************************"
