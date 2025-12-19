#!/bin/bash
cp /mnt/nssf/nssf.yaml /etc/open5gs/
sed -i 's|NSSF_IP|'$NSSF_IP'|g' /etc/open5gs/nssf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/nssf.yaml
sed -i 's|NRF_IP|'$NRF_IP'|g' /etc/open5gs/nssf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/nssf.yaml
exec open5gs-nssfd -c /etc/open5gs/nssf.yaml
