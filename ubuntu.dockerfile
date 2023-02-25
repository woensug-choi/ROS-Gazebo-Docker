# Starting from ubuntu 22.04
FROM ubuntu:22.04

# Change apt repo to ones in South Korea
# RUN sed -i 's/archive.ubuntu.com/ftp.kaist.ac.kr/g' /etc/apt/sources.list

# update and upgrade libs
RUN apt update \
    && apt-get -y upgrade \
    && rm -rf /tmp/*

# Install basics 
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN truncate -s0 /tmp/preseed.cfg && \
   (echo "tzdata tzdata/Areas select Asia" >> /tmp/preseed.cfg) && \
   (echo "tzdata tzdata/Zones/Asia select Seoul" >> /tmp/preseed.cfg) && \
   debconf-set-selections /tmp/preseed.cfg && \
   rm -f /etc/timezone && \
   apt-get install -y sudo tzdata build-essential gfortran automake \
   bison flex libtool git wget software-properties-common
## cleanup of files from setup
RUN rm -rf /tmp/*

# Install Utilities
RUN apt-get -y install x11-apps mesa-utils xauth \
    && rm -rf /tmp/*

# Install Graphics Driver for 3D rendering
RUN cd /tmp/ && \
    wget --progress=dot:giga http://us.download.nvidia.com/XFree86/Linux-x86_64/430.40/NVIDIA-Linux-x86_64-430.40.run && \
    /bin/sh NVIDIA-Linux-x86_64-430.40.run -a -s --no-kernel-module --install-libglvnd || \
    cat /var/log/nvidia-installer.log

# Make user (assume host user has 1000:1000 permission)
RUN adduser --shell /bin/bash --disabled-password --gecos "" user \
    && echo 'user:user' | chpasswd && adduser user sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# Set User as user
USER user

# Use software rendering for container
ENV LIBGL_ALWAYS_INDIRECT=1
