#!/bin/bash
cp /mnt/bsf/bsf.yaml /etc/open5gs/
sed -i 's|BSF_IP|'$BSF_IP'|g' /etc/open5gs/bsf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/bsf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/bsf.yaml
exec open5gs-bsfd -c /etc/open5gs/bsf.yaml
