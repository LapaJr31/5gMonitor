#!/bin/bash
cp /mnt/udm/udm.yaml /etc/open5gs/
sed -i 's|UDM_IP|'$UDM_IP'|g' /etc/open5gs/udm.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/udm.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/udm.yaml
exec open5gs-udmd -c /etc/open5gs/udm.yaml
