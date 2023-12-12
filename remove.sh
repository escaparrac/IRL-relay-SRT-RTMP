echo "Removing SRT + SRTLA Relay Server"

sudo rm -rf sls.sh && echo "sls.sh removed successfully" || echo "sls.sh not removed"
sudo rm -rf srt-live-server && echo "srt-live-server removed successfully" || echo "srt-live-server not removed"
sudo rm -rf srtla.sh && echo "srtla.sh removed successfully" || echo "srtla.sh not removed"
sudo rm -rf srt && echo "srt removed successfully" || echo "srt not removed"
sudo rm -rf srtla && echo "srtla removed successfully" || echo "srtla not removed"

read -p "Do you want to remove the install.sh file? (Type 'yes' and Enter to remove, or press Enter to exit): " answer

if [ "$answer" = "yes" ]; then
    cd 
    sudo rm -rf install.sh
    echo "install.sh file removed."
else
    echo "Exiting without removing the install.sh file."
fi

cd /etc/systemd/system
sudo systemctl stop sls.service
sudo systemctl disable sls.service
sudo systemctl daemon-reload
sudo rm -rf sls.service && echo "sls.service removed successfully" || echo "sls.service not removed"

sudo systemctl stop srtla.service
sudo systemctl disable srtla.service
sudo systemctl daemon-reload
sudo rm -rf srtla.service && echo "srtla.service removed successfully" || echo "srtla.service not removed"

echo "SRT + SRTLA Relay Server files removed succesfully"