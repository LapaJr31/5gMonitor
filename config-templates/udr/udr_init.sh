#!/bin/bash
cp /mnt/udr/udr.yaml /etc/open5gs/
sed -i 's|UDR_IP|'$UDR_IP'|g' /etc/open5gs/udr.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/udr.yaml
sed -i 's|MONGO_IP|'$MONGO_IP'|g' /etc/open5gs/udr.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/udr.yaml
exec open5gs-udrd -c /etc/open5gs/udr.yaml
