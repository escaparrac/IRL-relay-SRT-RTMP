# IRL-relay-SRT-RTMP
Step by Step IRL relay setup for IRL in Debian/Ubuntu

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

## Streaming Servers

#### SRT Server
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
#### SLS
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
### Finish SLS configuration and first run
```
cd bin
sudo ldconfig
sudo ./sls -c ../sls.conf
```
Console will be stuck with the SLS INFO, don't worry about that, we will handle it later.

### Check SLS connection
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

You should see some text moving and something like this appearing:
```
2023-08-29 18:55:38:931 SLS INFO: [0x7f1d70493010]CSLSListener::handler, new client[::ffff:176.80.71.144:62348], fd=820412458.
```
You should see that Larix stays connected, no errors appear and the bitrate is stable. Check the image for reference:

![image](https://github.com/escaparrac/IRL-relay-SRT-RMPT/assets/65442318/f766e36b-0844-4811-a2c2-f2e48781da07)

If everything is working correctly, you can close the server doing CTRL + C in the console.

### RTMP with stats monitor (nginx)
```
tutorial rtmp
```

```
extra
noalbs
duckdns
enablessh
openvpn
