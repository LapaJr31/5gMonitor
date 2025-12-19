#!/bin/bash
cp /mnt/ausf/ausf.yaml /etc/open5gs/
sed -i 's|AUSF_IP|'$AUSF_IP'|g' /etc/open5gs/ausf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/ausf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/ausf.yaml
exec open5gs-ausfd -c /etc/open5gs/ausf.yaml
