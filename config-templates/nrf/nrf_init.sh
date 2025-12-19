#!/bin/bash
cp /mnt/nrf/nrf.yaml /etc/open5gs/
sed -i 's|NRF_IP|'$NRF_IP'|g' /etc/open5gs/nrf.yaml
sed -i 's|MCC|'$MCC'|g' /etc/open5gs/nrf.yaml
sed -i 's|MNC|'$MNC'|g' /etc/open5gs/nrf.yaml
sed -i 's|MAX_NUM_UE|'$MAX_NUM_UE'|g' /etc/open5gs/nrf.yaml
exec open5gs-nrfd -c /etc/open5gs/nrf.yaml
