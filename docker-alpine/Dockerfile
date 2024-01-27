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

# Download latest version of Docker script
RUN cd /root \
&& sudo curl -s -H "Cache-Control: no-cache" -o "dockera.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/docker-alpine/dockera.sh" && sudo chmod +x dockera.sh && sudo ./dockera.sh

# Download latest version of the services
RUN cd /root \
&& sudo curl -s -H "Cache-Control: no-cache" -o "servicesd.sh" "https://raw.githubusercontent.com/escaparrac/IRL-relay-SRT-RTMP/main/servicesd.sh" && sudo chmod +x servicesd.sh

# Script to execute on boot
CMD ./root/servicesd.sh