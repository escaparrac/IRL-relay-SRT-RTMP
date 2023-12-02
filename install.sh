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
