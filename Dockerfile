# Download base image ubuntu 22.04
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="hola@esca.cc"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for a SRT+SRTLA relay server."
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update \
&& apt upgrade -y \
&& apt install sudo -y \
&& apt install curl -y \
&& apt install dnsutils -y \
&& apt install ufw -y \
&& apt install apt-utils -y \
&& apt install dialog -y \
&& apt install debconf-utils -y \
&& echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Create ubuntu user
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers
USER ubuntu

# Download the latest release of the script and execute it
RUN cd /home/ubuntu/ \
&& sudo curl -s -H "Cache-Control: no-cache" -o "install.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/install.sh" && sudo chmod +x install.sh && sudo ./install.sh

# Expose Ports
EXPOSE 8181
EXPOSE 8282
EXPOSE 8383
EXPOSE 22