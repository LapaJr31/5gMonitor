#!/bin/bash
cp /mnt/pcf/pcf.yaml /etc/open5gs/
sed -i 's|PCF_IP|'$PCF_IP'|g' /etc/open5gs/pcf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/pcf.yaml
sed -i 's|MONGO_IP|'$MONGO_IP'|g' /etc/open5gs/pcf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/pcf.yaml
exec open5gs-pcfd -c /etc/open5gs/pcf.yaml
