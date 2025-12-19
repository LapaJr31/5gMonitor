#!/bin/bash
cp /mnt/upf/upf.yaml /etc/open5gs/
sed -i 's|UPF_IP|'$UPF_IP'|g' /etc/open5gs/upf.yaml
sed -i 's|SMF_IP|'$SMF_IP'|g' /etc/open5gs/upf.yaml
sed -i 's|UE_IPV4_INTERNET|'$UE_IPV4_INTERNET'|g' /etc/open5gs/upf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/upf.yaml

# Create TUN interface
ip tuntap add name ogstun mode tun || true
ip addr add 10.45.0.1/16 dev ogstun || true
ip link set ogstun up || true
sysctl -w net.ipv4.ip_forward=1

exec open5gs-upfd -c /etc/open5gs/upf.yaml
