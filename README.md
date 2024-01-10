# IRL Relay server SRT + SRTLA + RTMP + NOALBS and others.

If you wish to buy me a coffee, you can do it [here](https://paypal.me/joaquinestevan)

This repo is a step by step guide on how to create a stream relay setup for IRL in Debian/Ubuntu. 

During IRL streamings, if you lose the connection while you you are boardcasting, your Twitch/YouTube page will show you as offline and your stream will end. This can mess up the viewer experience and the metrics. With a relay, instead of streaming directly to the platform, you are first streaming to a server and then from OBS, you pick up that video source and add it to your scenes. Now, the PC that has the OBS can be at home with a stable connection, high quality graphics and all your scenes configured and if your broadcast fails, the only thing that will happen is that the source will go black. We are going to install an automatic scene switcher on our server so if the connection fails or it's not stable, your OBS will change the scenes automatically to something like "having difficulties", "connection not stable", "offline source".

I made this guide in hopes of people can experiment without having to pay money for servers, be able to selfhost their own and do more IRL streams or add remote cameras to their broadcast.

The Ubuntu version used in this guide is the [22.04](https://releases.ubuntu.com/jammy/). Version 20.04 should be fine and Debian 10, 11 and 12 should work too. The firsts tests were done on a [TurnKey Core Debian 10VM](https://www.turnkeylinux.org/core).

1 CPU, 1GB of RAM and 8GB of storage should be enough for hosting a couple of relay servers, but my suggestion would be to have 2GB of RAM at least.

You can use any virtualization app on Windows like VirtualBox, get a cloud service like Linode or Amazon EC2, install it in your own baremetal server, Raspberry Pi or using virtualization environments like Proxmox. In the future I would like to create a dockerized version of this project so it's super easy to run and deploy.

This guide was inspired by this video from [Codexual](https://www.youtube.com/watch?v=YhvRXWzRPm4), but I tried to make this simpler, corrected some commands and made it friendlier for non-Linux users.

Before starting, this guide assumes that you already have an Ubuntu/Debian system ready. If you don't have it, check this guide on how to create a VM in Windows. All the configurations will be done with the console, no graphic interface will be needed.
Also, the -sudo- user for this tutorial will be "ubuntu", so be wary to change it before executing the commands. Execute the commands line by line for better results.


# Table of contents

1. [Create a SRT server with stats monitor](https://github.com/escaparrac/IRL-relay-SRT-RTMP#srt-with-stats-monitor-sls)
2. WIP [Create a RTMP server with stats monitor](https://github.com/escaparrac/IRL-relay-SRT-RTMP/#rtmp-with-stats-monitor-nginx)
3. [Create a SRTLA server with stats monitor](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#launch-srtla-relay-server-based-on-dukins-guide)
4. [Install NOALBS on our servers to handle scene-switching in OBS using the current bitrate](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#install-noalbs-on-our-server)
5. Usefull resources
    1. [Install an Ubuntu VM on Windows to host our server](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#install-an-ubuntu-virtual-machine-in-windows)
    2. [Enable SSH to access our server console from Windows](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#enable-ssh-access-for-your-servervm)
    3. [Configure a Dynamic DNS service with Duckdns](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#configure-a-dynamic-dns-service-with-duckdnsorg)

# SRT with stats monitor (SLS)

> [!NOTE]
> You can install the SRT + SRTLA service with single command. You need to be logged in as a sudo user, not root:
> `sudo curl -s -H "Cache-Control: no-cache" -o "install.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/install.sh" && sudo chmod +x install.sh && sudo ./install.sh`
> You can still continue installing it command by command with the guide below if you want more flexibility.
> If you want to remove all the files installed by the script, you can use the next command:
> `sudo curl -s -H "Cache-Control: no-cache" -o "remove.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/remove.sh" && sudo chmod +x remove.sh && sudo ./remove.sh`

## Perform update and upgrade
```
sudo apt update -y && sudo apt full-upgrade -y
```

## Install the required packages
```
sudo apt install libinput-dev make cmake tcl openssl zlib1g-dev gcc perl net-tools nano ssh git zip unzip tclsh pkg-config libssl-dev build-essential iputils-ping -y
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
sudo git checkout v1.5.3
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
### Sample sls.conf file - Copy and paste
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
- Press CTRL + X
- Y
- Enter

## Finish SLS configuration and first run
```
cd bin
sudo ldconfig
sudo ./sls -c ../sls.conf
```
Console will be stuck with the SLS INFO, don't worry about that, we will handle it later.

## Check SLS connection
Now we are going to download Larix Broadcaster or IRL Pro to test our server or our smartphone (whatever app that can stream to SRT servers work). Be sure to be connected to the same network/vpn or have your ports open on your router/service provider.

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

To test it in OBS or similar apps, you can add a VLC or video source with the next IP: srt://0.0.0.0:8282/play/stream/broadcast (0.0.0.0 is your server ip)

![image](https://github.com/escaparrac/IRL-relay-SRT-RTMP/assets/65442318/0fd4a2e7-be76-4c5c-a06f-d9e0239b1b35)

If everything shows correctly, you can close the server doing CTRL + C in the open console.

## Launch the server at startup
```
cd ~
sudo nano sls.sh
```
### sls.sh file - Copy and paste
```
#!/bin/bash
cd /home/ubuntu/srt-live-server/bin/
./sls -c ../sls.conf
```
- Press CTRL + X
- Y
- Enter
```
sudo chmod +x sls.sh
cd /etc/systemd/system
sudo nano sls.service
```
### sls.service file - Copy and paste
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
*if everything is OK (active and running) let's enable the service as a startup service
sudo systemctl enable sls.service
```

We are done with the SRT server. Now, you can configure the [NOALBS Service](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#noalbs) to enable the automatic scene switching.

## Launch SRTLA Relay Server (based on [dukins guide](https://github.com/dukins/irl-streaming-gopro-belabox-complete-guide/blob/main/README.md))

For the SRT server to work with Belabox, we will need to create a SRTLA relay. This will use the current SRT server and open up a port for the Belabox to connect to.

We are going to download the SRTLA relay server from Marlow925's repo and open some ports for it to work. In this guide we used the port 8383. Remember to change the 0.0.0.0 IP to your local IP address.

```
cd ~
git clone https://github.com/Marlow925/srtla.git
cd srtla/
make

sudo ufw status
sudo ufw allow 8383/tcp
sudo ufw allow 8383/udp
```
To test if it works execute the following code:
```
cd /home/ubuntu/srtla && ./srtla_rec 8383 0.0.0.0 8282
```
You will see something like:
```
Trying to connect to SRT at 0.0.0.0:8282... success
srtla_rec is now running
```
You can now go to BELABOX web UI and configure it this way in SRTLA SETTING

```
SRTLA receiver address: 0.0.0.0
SRTLA receiver port: 8383
SRT streamid: live/stream/broadcast
SRT latency: 2000 ms
```
Once all the ionfo is filled, I suggest you to click on "Encoder Settings" and the choose h265_test_pattern. This will send the test_pattern to your srtla relay without needing to connect a camera.

Now, press START at the top and you should see this message in your current console:

```
0.0.0.0:35266: group 0x55a0953224e0 registered
0.0.0.0:35266 (group 0x55a0953224e0): connection registration
```
If everything is right, press CTRL+C to exit. Now we will create a service for this to start at startup

### Launch SRTLA at startup
```
cd ~
sudo nano srtla.sh
```
### srtla.sh file - Copy and paste
First port is the SRTLA desired port, second port is the current SRT server one. Remember to edit the 0.0.0.0 to your local ip address.
```
#!/bin/bash
cd /home/ubuntu/srtla && ./srtla_rec 8383 0.0.0.0 8282
```
- Press CTRL + X
- Y
- Enter
```
sudo chmod +x srtla.sh
cd /etc/systemd/system
sudo nano srtla.service
```
### srtla.service file - Copy and paste
```
[Unit]
Description=srtla
 
[Service]
ExecStart=/bin/bash /home/ubuntu/srtla.sh

[Install]
WantedBy=multi-user.target
```
- Press CTRL + X
- Y
- Enter
```
sudo systemctl daemon-reload
sudo systemctl start srtla.service
sudo systemctl status srtla.service
*if everything is OK (active and running) let's enable the service as a startup service
sudo systemctl enable srtla.service
```

With this, we are done with our SRTLA relay server.


# RTMP with stats monitor (nginx)
```
tutorial rtmp
```


# Install NOALBS on our server

NOALBS (nginx-obs-automatic-low-bitrate-switching) is an automatic scene switcher for OBS. It will take your bitrate stats from your SRT or RTMP servers and if it reaches a treshhold, chance the scenes acordingly. The regular usage is to have one LIVE scene, one LOW BITRATE scene and one OFFLINE scene. Also consider creating a PRIVACY scene in your OBS so you can change it when you need to go to the barthroom, pay, sing documents or hide whatever

First, we are going to download NOALBS from their repo, install it and configure it.
```
cd ~
wget https://github.com/NOALBS/nginx-obs-automatic-low-bitrate-switching/releases/download/v2.8.0/noalbs-v2.8.0-x86_64-unknown-linux-musl.tar.gz
tar -xf noalbs-v2.8.0-x86_64-unknown-linux-musl.tar.gz
rm -rf noalbs-v2.8.0-x86_64-unknown-linux-musl.tar.gz
mv noalbs-v2.8.0-x86_64-unknown-linux-musl noalbs
cd noalbs
sudo mv config.json config.json.bak
sudo nano config.json
```
Config file for a SLS SRT Stream. Copy, paste, and edit the fields that need to be edited:
```
{
  "user": {
    "id": null,
    "name": "YOURCHANNELID",
    "passwordHash": null
  },
  "switcher": {
    "bitrateSwitcherEnabled": true,
    "onlySwitchWhenStreaming": false,
    "instantlySwitchOnRecover": true,
    "autoSwitchNotification": true,
    "retryAttempts": 5,
    "triggers": {
      "low": 1000,
      "rtt": 2500,
      "offline": null,
      "rttOffline": null
    },
    "switchingScenes": {
      "normal": "LIVE",
      "low": "LOW BITRATE",
      "offline": "OFFLINE"
    },
    "streamServers": [
      {
        "streamServer": {
         "type": "SrtLiveServer",
         "statsUrl": "http://x.x.x.x:8181/stats",
         "publisher": "live/stream/broadcast"
        },
        "name": "SRT",
        "priority": 0,
        "overrideScenes": null,
        "dependsOn": null,
        "enabled": true
      }
    ]
  },
  "software": {
    "type": "Obs",
    "host": "OBSWEBSOCKETIP",
    "password": "OBSWEBSOCKETPASSWORD",
    "port": 4455
  },
  "chat": {
    "platform": "Twitch",
    "username": "YOURCHANNELID",
    "admins": [
      "YOURCHANNELID",
      "YOUTBOTID"
    ],
    "language": "ES",
    "prefix": "!",
    "enablePublicCommands": false,
    "enableModCommands": false,
    "enableAutoStopStreamOnHostOrRaid": true,
    "commands": {
      "Refresh": {
        "permission": "Mod",
        "alias": [
          "r"
        ]
      },
      "Sourceinfo": {
        "permission": "Mod",
        "alias": null
      },
      "Trigger": {
        "permission": "Mod",
        "alias": null
      },
      "Fix": {
        "permission": "Mod",
        "alias": [
          "f"
        ]
      },
      "Bitrate": {
        "permission": "Public",
        "alias": [
          "b"
        ]
      },
      "Switch": {
        "permission": "Mod",
        "alias": [
          "ss"
        ]
      }
    }
  },
  "optionalScenes": {
    "starting": null,
    "ending": null,
    "privacy": null,
    "refresh": null
  },
  "optionalOptions": {
    "twitchTranscodingCheck": false,
    "twitchTranscodingRetries": 5,
    "twitchTranscodingDelaySeconds": 15,
    "offlineTimeout": null,
    "recordWhileStreaming": false
  }
}
```
- CTRL + X
- Press Y
- Enter

Now we need to edit our .env file
```
sudo nano .env
```
Here, change your TWITCH_BOT_USERNAME for your username or your bot name
For the OUATH, enter here to generate the key for your bot: https://twitchapps.com/tmi
Once you are finished writing everything:
- CTRL + X
- Press Y
- Enter
  
We are going to create an executable file now:

```
cd ~
sudo nano noalbs.sh
```
Copy and paste:
```
#!/bin/bash
cd /home/ubuntu/noalbs
./noalbs
```
- Press CTRL + X
- Y
- Enter
```
sudo chmod +x noalbs.sh
cd /etc/systemd/system
sudo nano noalbs.service
```
noalbs.service file. Copy and paste:
```
[Unit]
Description=noalbs
 
[Service]
ExecStart=/bin/bash /home/ubuntu/noalbs.sh
 
[Install]
WantedBy=multi-user.target
```
- Press CTRL + X
- Y
- Enter
```
sudo systemctl daemon-reload
sudo systemctl start noalbs.service
sudo systemctl status noalbs.service
*if everything is OK (active and running) let's enable the service as a startup service
sudo systemctl enable noalbs.service
```
# Useful Resources
## Install an Ubuntu Virtual Machine in Windows

Not everyone has a server or a spare PC to install Ubuntu. Also, the resources needed to setup a relay or NOALBS are so little, that it might not be worth to power up one for it. Cloud services are a valid option, but since most of the ones reading this tutorial will be using OBS on their own PCs, it's really convenient that you run a Ubuntu VM in the same PC inside the same network.

What is a VM? VM stands for Virtual Machine. In other words: you will install a program that is able to host other Operating Systems inside yours. This virtual marchines are isolated from your machine, so they are ideal to run small services or to test things. You could install all the virus in the world and none of them will actually jump into your PC (please don't try that).

We are going to use VMware Workstation Player, the free version from VMware to host our VM in Windows. First, download and install the app from their [official site](https://www.vmware.com/products/workstation-player.html).

Beware: you might need to enable virtuaization in your motherboard bios. With a quick look at google searching for "gigabyte/asus/msi enable virtualization intel/amd", you can check how to enable it in your system.

After the installation (and maybe some reboots) you will be on a small windows with some buttons.

We are going to download the 22.04 Ubuntu Server ISO for this tutorial. [Download](https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso) You can use other Ubuntu or Debian ISOs if you wish.

- Open VWware Workstation Player
- Press: Create a New Virtual Machine
- Add installer disc image file. Press next.
- Write a Virtual Machine Name
- Chose a location (this is where the VM file will be stored). Press next.
- Write 8GB disk size, choose single file. Press next.
- Click Customize Hardware
- Go to Memory and lower it from 4GB to 2GB.
- Under network adapter, choose Bridged.
- Press Close.
- Press Finish.

Now the VM will power up, and you will be welcomed to the Ubuntu Server Installer. You can navigate with your keyboard arrow keys, tab, space and Enter Key.

- Choose your language and press Enter
- Choose update to the new installer and press Enter
- Choose your keyboard (default should be ok) and press Enter
- Press Enter on the next screen (type of isntallation)
- On network connection, you can press enter, but I suggest you to assign a static IP here. For that
  - Scroll up to eth -> Press enter, go down to Edit IPv4 -> press Enter -> press Enter again, choose manual and Enter again.
    - subnet: 192.168.1.0/24 (this is your local ip range)
    - address: 192.168.1.126 (this is the chosen ip address for this VM)
    - gatewat: 192.168.1.1 (this is the router's ip)
    - name servers 1.1.1.1,8.8.8.8 (you can use your own here if you know them)
  - Click Save
- Scroll down and press Done
- On configure proxy press Done
- Wait until the tests are ready and press Done
- On guided storage scroll down and press Done and Done again. Then select Continue and Enter
- On the profile setup:
    - name: whatever you want
    - your servers name: *write a name for your server to be seen in the network. example: srt-server-ubuntu
    - username: ubuntu (you can choose whatever you want, but the tutorial is made with ubuntu user)
    - fill the both password fields and select Done
- On upgrade to ubuntu pro press Continue
- Press space to install OpenSSH server and select Done (we will configure this later [here](https://github.com/escaparrac/IRL-relay-SRT-RTMP/tree/main#enable-ssh-access-for-your-servervm)
- Press Tab and Done
- Wait for the install to end
- Scroll to Reboot now and press Enter

You might end up in a loop now (failed unmounting /cdrom). There will be a button below the window with something like "I finished installing". Click it and press enter. Ubuntu should boot up.

When everything is booted up, you can press Enter and it will show something like:
`srt-server-ubuntu login:`
- write ubuntu and press Enter
- write your password (you can't see what it's written, but it's writing, trust me) and press Enter.

Boom, you are inside your own Ubuntu VM!

Let's perform something now:
- Write sudo apt update and press Enter
- Write your password and press Enter
- Write sudo apt upgrade and press Enter
- You might need to press Y and Enter
- If a pink screen comes, press Tab and Enter at the Ok button

Now your machine is updated!
  
## Enable SSH access for your server/VM

We will try to connect to our Ubuntu VM from another computer. This will help us to use more friendlier apps than the OS console o make us be able to copy and paste nicely. You can even access from your smartphone or tablet if you want.
If you are using a cloud service for hosting your VM, they should have clear instructions on how to SSH.

First, head into your VM/server and write:

Let's check if SSH server is installed:
`sudo systemctl status ssh`
Check if it's active (running)

If yes, you can skip this command and jump to the next one

```
sudo apt update
sudo apt upgrade
sudo apt install openssh-server
sudo systemctl status ssh
```
If it's active (running) now, keep on.

Let's enable ssh incoming connections now:

`sudo ufw allow ssh` and press enter
`sudo ufw enable`

This will open the port 22 and make us able to connect remotely to the machine.

Now, head to your Windows PC. We are going to use the latest Windows terminal that can be downloaded from [here](https://github.com/microsoft/terminal/releases) to connect to a Ubuntu VM on our same network.

Let's say our VM is at 192.168.1.126 and the user for that VM is ubuntu.

We will write on the terminal: 
`ssh ubuntu@192.168.1.126`
A message like this will appear:
```
The authenticity of host '192.168.1.126 (192.168.1.126)' can't be established.
ECDSA key fingerprint is SHA256:sKJ0sHf73WjW5IBibJkMWKmu3Cve+UOfoIpmMJm+QeA.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
Write yes and press enter.

You should now be inside the VM from Windows. Now you can follow the first part of the tutorial more easily than from the Ubuntu console directly.

![image](https://github.com/escaparrac/IRL-relay-SRT-RTMP/assets/65442318/95fe82ef-53c2-4d25-981a-8b71336d2ae2)

Note: this is not the safest way to do SSH to a machine, but since it's a VM inside your network, I won't make you generate certificates or edit linux files. If you want to read about that you can check [here](https://goteleport.com/blog/how-to-ssh-properly/)

## Configure a Dynamic DNS service with DuckDNS.org

If you have Dynamic IP at home, having a dynamic DNS service will help you to not need to change your IP every now and then. Also, if you want to have a friendly domain name instead of your public IP wandering around, a Dynamic DNS service would be a good idea.

DuckDNS is a free DynDNS service really easy to configure and use.

First, we are going to create an account and a domain.

- Head to: https://www.duckdns.org/
- Sign in with your preferred method.
- Add a domain (xxx.duckdns.org)
- Click install select Linux and your domain at the bottom. *if you followed this guide, you should have an Ubuntu/Debian machine ready.
- Follow the steps. if you don't have cron installed, execute:
```
sudo apt -y install cron
```
- and Done!
- 
Now your server IP can be reached by xxx.duckdns.org. That means all your relays can be accessed by something like xxx.duckdns.org:8282.

## openvpn

## tailscale
