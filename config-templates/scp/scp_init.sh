#!/bin/bash
cp /mnt/scp/scp.yaml /etc/open5gs/
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/scp.yaml
sed -i 's|NRF_IP|'$NRF_IP'|g' /etc/open5gs/scp.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/scp.yaml
exec open5gs-scpd -c /etc/open5gs/scp.yaml
