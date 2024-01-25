# Download base image ubuntu 22.04
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="hola@esca.cc"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for a SRT+SRTLA relay server."
ARG DEBIAN_FRONTEND=noninteractive

# Install: dependencies, clean: apt cache, remove dir: cache, man, doc, change mod time of cache dir.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       software-properties-common \
       rsyslog systemd systemd-cron sudo \
    && apt-get clean \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && rm -rf /var/lib/apt/lists/* \
    && touch -d "2 hours ago" /var/lib/apt/lists
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]

# Update Ubuntu Software repository
RUN apt update \
&& apt upgrade -y \
&& apt install sudo -y \
&& apt install curl -y \
&& apt install apt-utils -y \
&& apt install dialog -y \
&& apt install debconf-utils -y \
&& echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Create ubuntu user
RUN useradd -m ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers
USER ubuntu

# Downloaded latest release of the script and excecute it
RUN sudo curl -s -H "Cache-Control: no-cache" -o "install.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/install.sh" && sudo chmod +x install.sh && sudo ./install.sh

# Expose Ports
EXPOSE 8181
EXPOSE 8282
EXPOSE 8383
EXPOSE 22