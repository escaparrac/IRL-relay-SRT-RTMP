# This script will install an SRT relay with SRTLA and NOALBS.

#!/usr/bin/env bash

while true; do
    read -p "What's your username? " username
    read -p "Is '$username' your correct username? (yes/no) " confirmation
    if [ "$confirmation" = "yes" ]; then
        echo "Great! Let's continue with the script."
        break
    else
        echo "Oops! Let's try again."
    fi

echo "script continues"

done
