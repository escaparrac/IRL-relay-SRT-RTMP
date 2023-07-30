# IRL-relay-SRT-RMPT
Step by Step IRL relay setup for IRL in Debian/Ubuntu

sudo apt update -y && sudo apt full-upgrade -y

apt install libinput-dev make cmake tcl openssl zlib1g-dev gcc perl net-tools nano ssh git zip unzip tclsh pkg-config cmake libssl-dev build-essential -y

firewall

8181 = SLS HTTP, 8282 = SLS Server, 22 = SSH (Allow to terminal/run commands)
ufw allow 8181/udp
ufw allow 8181/tcp
ufw allow 8282/udp
ufw allow 8282/tcp
ufw allow 22/tcp
ufw allow 22/udp

sls with stats
SRT
git clone https://github.com/Haivision/srt.git
cd srt
./configure
make
git checkout v1.4.3 && ./configure && make -j8 && make install
cd ../
SLS
git clone https://gitlab.com/mattwb65/srt-live-server.git
cd srt-live-server
git checkout v1.4.3 && ./configure && make -j8 && make install
make -j8
mv sls.conf sls.bak
nano sls.conf
cd bin
ldconfig
./sls -c ../sls.conf

rtmp with stats


extra
noalbs
duckdns
enablessh
openvpn
