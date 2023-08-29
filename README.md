# IRL-relay-SRT-RTMP

This repo is a step by step guide to create a stream relay setup for IRL in Debian/Ubuntu. 

During IRL streamings, if you lose the connection while you you are boardcasting, your Twitch/YouTube page will show you as Offline and your stream will end. This can mess up the viewer experience and the metrics. With a relay, instead of streaming directly to the platform, you are first streaming to a server and then from OBS, you pick up that video source and add it to your scenes. Now, the PC that has the OBS can be at home with a stable connection, high quality graphics and all your scenes configured and if your broadcast fails, the only thing that will happen is that the source will go black. We are going to install an automatic scene switcher on our server so if the connection fails or it's not stable, your OBS will change the scenes automatically to something like "having difficulties", "connection not stable", "offline source".

I made this guide in hopes of people can experiment without having to pay money for servers, be able to selfhost their own and do more IRL streams or add remote cameras to their broadcast.

The Ubuntu version used in this guide is the [22.04](https://releases.ubuntu.com/jammy/). Version 20.04 should be fine and Debian 10, 11 and 12 should work too. The firsts tests were done on a [TurnKey Core Debian 10VM](https://www.turnkeylinux.org/core).

1 CPU, 1GB of RAM and 8GB of storage should be enough for hosting a couple of servers, but my suggestion would be to have 2GB of RAM at least.

You can use a virtualization app on Windows like VirtuaBox, get a cloud service like Linode or Amazon EC2, install it in your own baremetal server, Raspberry Pi or using virtualization environments like Proxmox. In the future I would like to create a dockerized version of this project so it's super easy to run and deploy.

This guide was inspired by this video from [Codexual](https://www.youtube.com/watch?v=YhvRXWzRPm4), but I tried to make this simpler, correct some commands and make it friendlier for non-linux users.


# Table of contents

1. [Create a SRT server with stats monitor](https://github.com/escaparrac/IRL-relay-SRT-RMTP/blob/main/README.md#srt-with-stats-monitor-sls)
2. [Create a RTMP server with stats monitor](https://github.com/escaparrac/IRL-relay-SRT-RMTP/blob/main/README.md#rtmp-with-stats-monitor-nginx)
3. Install NOALBS on our servers to handle scene-switching in OBS using the current bitrate
4. Useful

# SRT with stats monitor (SLS)
## Perform update and upgrade
```
sudo apt update -y && sudo apt full-upgrade -y
```

## Install the required packages
```
sudo apt install libinput-dev make cmake tcl openssl zlib1g-dev gcc perl net-tools nano ssh git zip unzip tclsh pkg-config libssl-dev build-essential -y
```

## Configure the firewall
8181 = SLS HTTP, 8282 = SLS Server, 22 = SSH (Allow to terminal/run commands)
```
sudo ufw allow 8181/udp
sudo ufw allow 8181/tcp
sudo ufw allow 8282/udp
sudo ufw allow 8282/tcp
sudo ufw allow 22/tcp
sudo ufw allow 22/udp
```

## SRT Server
```
sudo git clone https://github.com/Haivision/srt.git
cd srt
sudo ./configure
sudo make
sudo git checkout v1.5.3 &&
sudo ./configure
sudo make -j8
sudo make install
cd ../
```

## SLS
```
sudo git clone https://gitlab.com/mattwb65/srt-live-server.git
cd srt-live-server
sudo make -j8
sudo mv sls.conf sls.bak
sudo nano sls.conf

```
### Sample sls.conf file
```
srt {
    worker_threads 1;
    worker_connections 200;
    http_port 8181;
    cors_header *;
    log_file /dev/stdout;

    server {
        listen 8282;
        latency 2000;
        domain_player play;
        domain_publisher live;
        default_sid play/stream/broadcast;
        backlog 10;
        idle_streams_timeout 10;

        app {
            app_publisher stream;
            app_player stream;
        }
    }
}
```
## Finish SLS configuration and first run
```
cd bin
sudo ldconfig
sudo ./sls -c ../sls.conf
```
Console will be stuck with the SLS INFO, don't worry about that, we will handle it later.

## Check SLS connection
Now we are going to download Larix Broadcaster or IRL Pro to test our server (whatever app that can stream to SRT servers work).

***BEWARE*** If you are using a remote server like Linode or Amazon EC2, you will need to open the ports 8181 and 8282 TPC/UDP so you can connect to the server remotelly.

- Open Larix
- Settings
- Connections
-  New Connection
-  Write a name for your connection (it can be whatever, just write something that you know to which server you are connecting)
-  Write the url: 
```
srt://0.0.0.0:8282 - 0.0.0.0 is your local o public IP. 
```

*If you have dynamic IP, you should use a Dynamic DNS service. Click here for a tutorial.
- Mode: Audio + Video
- SRT Sender mode: Caller
- Latency: 2000
- streamid: live/stream/broadcast *if you changed this on sls.conf, make it match
- Tap the checkmark
- Go back to the camera interface on Larix
- Press the big white button

You should see some text moving and a line like this appearing:
```
2023-08-29 18:55:38:931 SLS INFO: [0x7f1d70493010]CSLSListener::handler, new client[::ffff:176.80.71.144:62348], fd=820412458.
```
If the configuration is done right, Larix should stay connected, no errors will appear and the bitrate will be stable. Check the image for reference:

![image](https://github.com/escaparrac/IRL-relay-SRT-RMPT/assets/65442318/f766e36b-0844-4811-a2c2-f2e48781da07)

Now you can close the server doing CTRL + C in the console.

## Launch the server at startup
```
cd ~
sudo nano sls.sh
```
### sls.sh file
```
#!/bin/bash
cd /home/ubuntu/srt-live-server/bin/
./sls -c ../sls.conf
```
- Press CTRL + X
- Y
- Enter
```
chmod +x sls.sh
cd /etc/systemd/system
sudo nano sls.service
```
### sls.service file
```
[Unit]
Description=sls
 
[Service]
ExecStart=/bin/bash /home/ubuntu/sls.sh

[Install]
WantedBy=multi-user.target
```
- Press CTRL + X
- Y
- Enter
```
sudo systemctl daemon-reload
sudo systemctl start sls.service
sudo systemctl status sls.service
*if everything is OK (active and running) let's enable the service as startup
sudo systemctl enable sls.service
```

# RTMP with stats monitor (nginx)
```
tutorial rtmp
```

```
extra
noalbs
duckdns
enablessh
openvpn
