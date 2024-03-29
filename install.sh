# This script will install an SRT relay with SRTLA and NOALBS.

#!/bin/bash

echo "Executing Escaparrac's SRT/SRTLA relay server installer..."

localip=$(hostname -I | tr -d ' ') # If you have several network devices, IPv6 or probems with your router, you can write your local IP after the ""=" like: localip="0.0.0.0"
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com) # Same as before, you can specify your public IP here (or your hostname if there is one). This won't affect the script usage.
username=$USER # If you want to use a custom user instead of the default user, please fill the next variable with your preferred username.
customusername=""

echo "Checking what type of user you are:"

if [ -n "$customusername" ]; then
    username="$customusername"
    echo "Username changed to $customusername"
elif [ "$((EUID))" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    username="$SUDO_USER"
    echo "You are running the script as sudo. Username is now set to: $username"
elif [ "$((EUID))" -eq 0 ] ; then
    username="root"
    echo "You are root. Username is now set to: $username"
else
    username="$USER"
    echo "Username is now set to: $username"
fi


echo "Updating and upgrading the OS"

sudo apt-get update -y -q >/dev/null
sudo apt-get upgrade -y -q >/dev/null
sudo dpkg --configure -a >/dev/null

echo "System updated and upgraded"

echo "Installing all the required packages"

sudo apt-get install libinput-dev make cmake tcl openssl zlib1g-dev gcc perl net-tools nano ssh git zip unzip tclsh pkg-config libssl-dev build-essential iputils-ping -y -q >/dev/null

echo "All packages installed correctly"

echo "Preparing ports to be open. By default 8181 = SLS HTTP, 8282 = SLS Server, 8383 = SRTLA, 22 = SSH"

sudo ufw allow 8181/udp >/dev/null
sudo ufw allow 8181/tcp >/dev/null
sudo ufw allow 8282/udp >/dev/null
sudo ufw allow 8282/tcp >/dev/null
sudo ufw allow 8383/tcp >/dev/null
sudo ufw allow 8383/udp >/dev/null
sudo ufw allow 22/tcp >/dev/null
sudo ufw allow 22/udp >/dev/null

echo "Enabling the firewall service"

echo "y" | sudo ufw enable >/dev/null

echo "Firewall enabled"
echo "Downloading and installing SRT Server. This can take up to 5 minutes, wait until it finishes."

cd /home/$username
sudo git clone https://github.com/Haivision/srt.git -q 2>&1 >/dev/null
cd srt
sudo ./configure > /dev/null 2>&1
sudo make -s > /dev/null 2>&1
echo "SRT Downloaded and compiled"
sudo git checkout v1.5.3 > /dev/null 2>&1
sudo ./configure > /dev/null 2>&1
sudo make -j8 -s > /dev/null 2>&1
sudo make install -s > /dev/null 2>&1
if [ -e /usr/local/bin/srt-file-transmit ]; then
    echo "Success: SRT v1.5.3 installed."
else
    echo "Error: SRT v1.5.3 could not be installed. Stopping the script."
    exit 1  # Exit with an error status
fi
cd ../

echo "SRT Server correctly installed"

echo "Downloading and installing SLS"

sudo git clone https://github.com/escaparrac/srt-live-server.git -q > /dev/null 2>&1
cd srt-live-server
sudo make -j8 -s > /dev/null 2>&1
sudo mv sls.conf sls.bak

echo "Downloading the sample sls.conf file from the repository"
curl -s -H "Cache-Control: no-cache" -o "sls.conf" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/sls.conf"
echo "sls.conf Downloaded"

echo "Finishing SLS configuration"
cd bin
sudo ldconfig
echo "SLS correctly installed"

echo "Creating startup scripts and services"
echo "Downloading sls.sh file from repo"
cd /home/$username
curl -s -H "Cache-Control: no-cache" -o "sls.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/sls.sh"
sudo chmod +x sls.sh
sudo sed -i "2s|.*|cd /home/$username/srt-live-server/bin/|" sls.sh

echo "Creating the SLS service"
cd /etc/systemd/system
sudo curl -s -H "Cache-Control: no-cache" -o "sls.service" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/sls.service"
sudo sed -i "5s|.*|ExecStart=/bin/bash /home/$username/sls.sh|" sls.service

echo "Enabling SLS service to start on boot"
sudo systemctl daemon-reload
sudo systemctl start sls.service
sudo systemctl enable sls.service

echo "SLS service enabled"

echo "SRT+SLS relay server finished"

echo "Installing SRTLA Relay Server"
cd /home/$username
git clone https://github.com/Marlow925/srtla.git -q 2>&1 >/dev/null
cd srtla/
make -s > /dev/null 2>&1
echo "SRTLA Relay Server installed"

echo "Configuring SRTLA Relay Server service on startup"
echo "Downloading srtla.sh file from repo"
cd /home/$username
sudo curl -s -H "Cache-Control: no-cache" -o "srtla.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/srtla.sh"
sudo chmod +x srtla.sh
sudo sed -i "2s|.*|cd /home/$username/srtla|" srtla.sh
sudo sed -i "3s|.*|./srtla_rec 8383 $localip 8282|" srtla.sh
sudo chmod +x srtla.sh

echo "Creating the SRTLA service"
cd /etc/systemd/system
sudo curl -s -H "Cache-Control: no-cache" -o "srtla.service" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/srtla.service"
sudo sed -i "5s|.*|ExecStart=/bin/bash /home/$username/srtla.sh|" srtla.service

echo "Enabling SRTLA service to start on boot"

sudo systemctl daemon-reload
sudo systemctl start srtla.service
sudo systemctl enable srtla.service

echo "Your SRT and SRTLA relays are working now."
echo ""
echo "To send video to the SRT server use $localip:8282 with streamid live/stream/broadcast. $publicip:8282 if you are outside the network (remember to open ports on your router)"
echo "To get your SRT video source at OBS use srt://$localip:8282/play/stream/broadcast. It's best to use a "
echo "To connect to the SRTLA server from Belabox use $publicip:8383 with streamid live/stream/broadcast (remember to open ports on your router)"
echo "The stats server is at http://$localip:8181/stats"
echo ""
echo "If you find any problems during the installation, find me at https://github.com/escaparrac/ or X/Twitter: https://www.twitter.com/joaquinestevan"