# This script will install an SRT relay with SRTLA and NOALBS.

#!/bin/bash

localip=$(hostname -I | tr -d ' ')
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo "Executing Escaparrac's SRT/SRTLA relay server installer..."

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
echo "Downloading and installing SRT Server. This can take up to 5 minutes, don't touch your keyboard until it finishes."

cd /home/$SUDO_USER
sudo git clone https://github.com/Haivision/srt.git -q 2>&1 >/dev/null
cd srt
sudo ./configure > /dev/null 2>&1
sudo make -s > /dev/null 2>&1
sudo git checkout v1.5.3 > /dev/null 2>&1
sudo ./configure > /dev/null 2>&1
sudo make -j8 -s > /dev/null 2>&1
sudo make install -s > /dev/null 2>&1
cd ../

echo "SRT Server correctly installed"

echo "Downloading and installing SLS"

sudo git clone https://gitlab.com/mattwb65/srt-live-server.git -q > /dev/null 2>&1
cd srt-live-server
sudo make -j8 -s > /dev/null 2>&1
sudo mv sls.conf sls.bak

echo "Downloading the sample sls.conf file from the repository"
curl -s -H "Cache-Control: no-cache" -o "sls.conf" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RMTP/main/sls.conf"
echo "sls.conf Downloaded"

echo "Finishing SLS configuration"
cd bin
sudo ldconfig
echo "SLS correctly installed"

echo "Creating startup scripts and services"
echo "Downloading sls.sh file from repo"
cd /home/$SUDO_USER
curl -s -H "Cache-Control: no-cache" -o "sls.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RMTP/main/sls.sh"
sudo chmod +x sls.sh
sudo sed -i "2s|.*|cd /home/$SUDO_USER/srt-live-server/bin/|" sls.sh

echo "Creating the SLS service"
cd /etc/systemd/system
sudo curl -s -H "Cache-Control: no-cache" -o "sls.service" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RMTP/main/sls.service"
sudo sed -i "5s|.*|ExecStart=/bin/bash /home/$SUDO_USER/sls.sh|" sls.service

echo "Enabling SLS service to start on boot"
sudo systemctl daemon-reload
sudo systemctl start sls.service
sudo systemctl enable sls.service

echo "SLS service enabled"

echo "SRT+SLS relay server finished"

echo "Installing SRTLA Relay Server"
cd /home/$SUDO_USER
git clone https://github.com/Marlow925/srtla.git -q 2>&1 >/dev/null
cd srtla/
make -s > /dev/null 2>&1
echo "SRTLA Relay Server installed"

echo "Configuring SRTLA Relay Server service on startup"
echo "Downloading srtla.sh file from repo"
cd /home/$SUDO_USER
curl -s -H "Cache-Control: no-cache" -o "srtla.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RMTP/main/srtla.sh"
sudo chmod +x srtla.sh
sudo sed -i "2s|.*|cd /home/$SUDO_USER/srtla|" srtla.sh
sudo sed -i "3s|.*|./srtla_rec 8383 $localip 8282|" srtla.sh
sudo chmod +x srtla.sh

echo "Creating the SRTLA service"
cd /etc/systemd/system
sudo curl -s -H "Cache-Control: no-cache" -o "srtla.service" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RMTP/main/srtla.service"
sudo sed -i "5s|.*|ExecStart=/bin/bash /home/$SUDO_USER/srtla.sh|" srtla.service

echo "Enabling SRTLA service to start on boot"

sudo systemctl daemon-reload
sudo systemctl start srtla.service
sudo systemctl enable srtla.service

echo "Your SRT and SRTLA relays are working now."
echo ""
echo "To connect to the SRT server use $localip:8282 with streamid live/stream/broadcast"
echo "To get your SRT video source at OBS use srt://$localip:8282/play/stream/broadcast"
echo "To connect to the SRTLA server from Belabox use $localip:8383 with streamid live/stream/broadcast"
echo "The stats server is at http://$localip:8181/stats"
echo ""
echo "If you find any problem during the installation, find me at https://github.com/escaparrac/ or X/Twitter: https://www.twitter.com/joaquinestevan"