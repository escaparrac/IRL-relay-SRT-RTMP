# This script will install an SRT relay with SRTLA and NOALBS.

#!/bin/bash
user=$(whoami)

# Main script logic comes here
echo "Executing main script logic..."
# Add your main script logic below this line

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
sudo ufw allow 22/tcp >/dev/null
sudo ufw allow 22/udp >/dev/null

echo "Enabling the firewall service"

echo "y" | sudo ufw enable >/dev/null

echo "Firewall enabled"
echo "Downloading and installing SRT Server"

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
curl -s -H "Cache-Control: no-cache" -o "sls.conf" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RMTP/main/sls.conf" >/dev/null
echo "sls.conf Downloaded"
