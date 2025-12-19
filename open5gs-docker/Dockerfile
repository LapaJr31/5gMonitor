FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:open5gs/latest && \
    apt-get update && \
    apt-get install -y \
    open5gs \
    curl \
    iproute2 \
    iptables \
    iputils-ping && \
    apt-get clean

# Create log directory
RUN mkdir -p /var/log/open5gs

WORKDIR /root
