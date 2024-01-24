# Download base image ubuntu 22.04
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="hola@esca.cc"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for a SRT+SRTLA relay server."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update
RUN apt upgrade -y
RUN apt install sudo

# Downloaded latest release of the script and excecute it
RUN sudo curl -s -H "Cache-Control: no-cache" -o "install.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/install.sh" && sudo chmod +x install.sh && sudo ./install.sh

# Expose Ports
EXPOSE 8181
EXPOSE 8282
EXPOSE 8383
EXPOSE 22