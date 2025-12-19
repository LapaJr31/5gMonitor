#!/bin/bash
cp /mnt/smf/smf.yaml /etc/open5gs/
sed -i 's|SMF_IP|'$SMF_IP'|g' /etc/open5gs/smf.yaml
sed -i 's|SCP_IP|'$SCP_IP'|g' /etc/open5gs/smf.yaml
sed -i 's|UPF_IP|'$UPF_IP'|g' /etc/open5gs/smf.yaml
sed -i 's|UE_IPV4_INTERNET|'$UE_IPV4_INTERNET'|g' /etc/open5gs/smf.yaml
sed -i 's|SMF_DNS1|'$SMF_DNS1'|g' /etc/open5gs/smf.yaml
sed -i 's|SMF_DNS2|'$SMF_DNS2'|g' /etc/open5gs/smf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/smf.yaml
exec open5gs-smfd -c /etc/open5gs/smf.yaml
