# This script will install an SRT relay with SRTLA and NOALBS.

#!/bin/bash

while true; do
    read -p "What's your username? (ubuntu will match all the tutorial information) " username
    read -p "Is '$username' your correct username? (yes/no) " confirmation

    if [ "$confirmation" = "yes" ]; then
        echo "Great! Let's continue with the script."
        break  # Exit the loop since the username is confirmed
    elif [ "$confirmation" = "no" ]; then
        echo "Oops! Let's try again."
    else
        echo "Invalid input. Please enter 'yes' or 'no'. If you want to exit the script, press CTRL + C."
    fi
done
# Main script logic comes here
echo "Executing main script logic..."
# Add your main script logic below this line

echo "Updating and upgrading the OS"

sudo apt update -y -q >/dev/null
sudo apt upgrade -y -q >/dev/null

echo "Installing all the required packages"

sudo apt install libinput-dev make cmake tcl openssl zlib1g-dev gcc perl net-tools nano ssh git zip unzip tclsh pkg-config libssl-dev build-essential iputils-ping -y


