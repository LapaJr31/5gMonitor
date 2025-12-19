#!/bin/bash
cp /mnt/amf/amf.yaml /etc/open5gs/
sed -i 's|AMF_IP|'$AMF_IP'|g' /etc/open5gs/amf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/amf.yaml
sed -i 's|MCC|'$MCC'|g' /etc/open5gs/amf.yaml
sed -i 's|MNC|'$MNC'|g' /etc/open5gs/amf.yaml
sed -i 's|TAC|'$TAC'|g' /etc/open5gs/amf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/amf.yaml
exec open5gs-amfd -c /etc/open5gs/amf.yaml
