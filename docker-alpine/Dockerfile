# Use Alpine Linux as base image
FROM alpine:latest

# LABEL about the custom image
LABEL maintainer="hola@esca.cc"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for a SRT+SRTLA relay server."

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
        bash \
        sudo \
        curl \
        dpkg  \
        gcc \
        git \
        libc-dev \
        libgcc \
        libstdc++ \
        make \
        openssl-dev \
        perl \
        tcl \
        tcl-dev \
        zlib-dev \
        openssh \
        zip \
        unzip \
        iputils \
        nano \
        openssl \
        pkgconfig \
        build-base \
        linux-headers \
        coreutils \
        util-linux \
        binutils \
        findutils \
        grep \
        sed \
        diffutils \
        tar \
        curl \
        ca-certificates \
        procps \
        findutils \
        grep \
        sed \
        diffutils \
        tar \
        iputils \
        bind-tools

# Create a non-root user
RUN adduser -D -u 1000 ubuntu && echo "ubuntu:ubuntu" | chpasswd
# Grant sudo privileges (if sudo is installed)
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Switch to the ubuntu user
USER ubuntu

# Download latest version of Docker script
RUN cd /home/ubuntu/ \
&& sudo curl -s -H "Cache-Control: no-cache" -o "docker.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/docker.sh" && sudo chmod +x docker.sh && sudo ./docker.sh

# Download latest version of the services
RUN cd /home/ubuntu/ \
&& sudo curl -s -H "Cache-Control: no-cache" -o "servicesd.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/servicesd.sh" && sudo chmod +x servicesd.sh

# Script to execute on boot
CMD ./home/ubuntu/servicesd.sh