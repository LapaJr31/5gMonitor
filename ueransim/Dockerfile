FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    git \
    make \
    libboost-all-dev \
    libssl-dev \
    libsctp-dev \
    wget

WORKDIR /root

# Clone UERANSIM
RUN git clone https://github.com/aligungr/UERANSIM.git ueransim && \
    cd ueransim && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

WORKDIR /root/ueransim

CMD ["/bin/bash"]
