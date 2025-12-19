#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Realistic 5G Traffic Simulator           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"

NUM_UES=10
BASE_IMSI="286010000000"

# Register subscribers
echo -e "\n${YELLOW}[SETUP] Registering $NUM_UES subscribers...${NC}"
for i in $(seq 1 $NUM_UES); do
    IMSI="${BASE_IMSI}$(printf "%03d" $i)"
    sudo docker exec mongodb mongosh open5gs --quiet --eval "
    db.subscribers.deleteOne({imsi: '$IMSI'});
    db.subscribers.insertOne({
      imsi: '$IMSI',
      subscribed_rau_tau_timer: 12,
      network_access_mode: 0,
      subscriber_status: 0,
      access_restriction_data: 32,
      slice: [{
        sst: 1,
        default_indicator: true,
        session: [{
          name: 'internet',
          type: 3,
          pcc_rule: [],
          ambr: {downlink: {value: 1, unit: 3}, uplink: {value: 1, unit: 3}},
          qos: {index: 9, arp: {priority_level: 8, pre_emption_capability: 1, pre_emption_vulnerability: 1}}
        }]
      }],
      ambr: {downlink: {value: 1, unit: 3}, uplink: {value: 1, unit: 3}},
      security: {k: '465B5CE8B199B49FAA5F0A2EE238A6BC', amf: '8000', op: 'E8ED289DEBA952E4283B54E88E6183CA', opc: null}
    })
    " > /dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} UE-$i (IMSI: $IMSI)"
done

# Create UE template
sudo docker exec ueransim bash -c "cat > /tmp/ue-template.yaml << 'EOFU'
supi: 'imsi-IMSI_PLACEHOLDER'
mcc: '286'
mnc: '01'
key: '465B5CE8B199B49FAA5F0A2EE238A6BC'
op: 'E8ED289DEBA952E4283B54E88E6183CA'
opType: 'OP'
amf: '8000'
imei: 'IMEI_PLACEHOLDER'
gnbSearchList: ['10.10.0.23']
sessions: [{type: 'IPv4', apn: 'internet', slice: {sst: 1}}]
configured-nssai: [{sst: 1}]
default-nssai: [{sst: 1}]
EOFU
"

# Traffic behavior functions
start_ue() {
    local ue_num=$1
    local behavior=$2
    local IMSI="${BASE_IMSI}$(printf "%03d" $ue_num)"
    local IMEI="35693803564380$ue_num"

    sudo docker exec ueransim bash -c "
        sed 's/IMSI_PLACEHOLDER/$IMSI/g; s/IMEI_PLACEHOLDER/$IMEI/g' \
            /tmp/ue-template.yaml > /tmp/ue-$ue_num.yaml
    "

    # Start UE
    sudo docker exec -d ueransim bash -c "
        cd /root/ueransim/build
        ./nr-ue -c /tmp/ue-$ue_num.yaml > /tmp/ue-$ue_num.log 2>&1
    " > /dev/null 2>&1

    sleep 3

    # Apply behavior
    case $behavior in
        "browsing")
            # Light, intermittent traffic (web browsing)
            sudo docker exec -d ueransim bash -c "
                sleep 5
                while true; do
                    ping -I uesimtun$((ue_num-1)) -c 5 -i 0.5 8.8.8.8 >/dev/null 2>&1
                    sleep $(( RANDOM % 20 + 10 ))
                done
            " > /dev/null 2>&1
            ;;
        "streaming")
            # Continuous heavy traffic (video streaming)
            sudo docker exec -d ueransim bash -c "
                sleep 5
                ping -I uesimtun$((ue_num-1)) -i 0.2 8.8.8.8 >/dev/null 2>&1
            " > /dev/null 2>&1
            ;;
        "messaging")
            # Very light, periodic traffic (messaging app)
            sudo docker exec -d ueransim bash -c "
                sleep 5
                while true; do
                    ping -I uesimtun$((ue_num-1)) -c 2 -i 1 8.8.8.8 >/dev/null 2>&1
                    sleep $(( RANDOM % 60 + 30 ))
                done
            " > /dev/null 2>&1
            ;;
        "idle")
            # Minimal keepalive traffic
            sudo docker exec -d ueransim bash -c "
                sleep 5
                while true; do
                    ping -I uesimtun$((ue_num-1)) -c 1 8.8.8.8 >/dev/null 2>&1
                    sleep 60
                done
            " > /dev/null 2>&1
            ;;
        "downloading")
            # Heavy burst traffic (file download)
            sudo docker exec -d ueransim bash -c "
                sleep 5
                while true; do
                    ping -I uesimtun$((ue_num-1)) -c 100 -i 0.1 8.8.8.8 >/dev/null 2>&1
                    sleep $(( RANDOM % 30 + 10 ))
                done
            " > /dev/null 2>&1
            ;;
    esac
}

stop_ue() {
    local ue_num=$1
    sudo docker exec ueransim pkill -f "nr-ue.*ue-$ue_num" 2>/dev/null
}

# User behavior profiles
BEHAVIORS=("browsing" "streaming" "messaging" "idle" "downloading")

echo -e "\n${YELLOW}[START] Simulating realistic user behaviors...${NC}"
echo ""

# Start initial UEs with different behaviors
for i in $(seq 1 5); do
    behavior_idx=$(( (i-1) % 5 ))
    behavior=${BEHAVIORS[$behavior_idx]}
    echo -e "${GREEN}[UE-$i]${NC} Starting with ${YELLOW}$behavior${NC} behavior"
    start_ue $i $behavior
    sleep 2
done

echo -e "\n${BLUE}Active UEs: 5${NC}"
echo -e "${GREEN}✓ Traffic simulation running${NC}\n"

# Simulation loop
cycle=0
while true; do
    cycle=$((cycle + 1))
    sleep 30

    echo -e "\n${BLUE}═══ Cycle #$cycle ═══${NC}"

    # Randomly disconnect/reconnect UEs (simulating mobility)
    action=$(( RANDOM % 3 ))

    case $action in
        0)
            # Disconnect a random UE
            ue_to_stop=$(( RANDOM % 5 + 1 ))
            echo -e "${YELLOW}[Mobility]${NC} UE-$ue_to_stop handoff (disconnect)"
            stop_ue $ue_to_stop
            ;;
        1)
            # Connect a new UE
            ue_to_start=$(( RANDOM % 10 + 1 ))
            behavior=${BEHAVIORS[$(( RANDOM % 5 ))]}
            echo -e "${GREEN}[New Connection]${NC} UE-$ue_to_start with $behavior"
            start_ue $ue_to_start $behavior
            ;;
        2)
            # Switch behavior (simulating app change)
            ue_to_change=$(( RANDOM % 5 + 1 ))
            new_behavior=${BEHAVIORS[$(( RANDOM % 5 ))]}
            echo -e "${BLUE}[Behavior Change]${NC} UE-$ue_to_change switching to $new_behavior"
            stop_ue $ue_to_change
            sleep 2
            start_ue $ue_to_change $new_behavior
            ;;
    esac

    # Show current status
    active=$(sudo docker exec ueransim ps aux 2>/dev/null | grep "nr-ue" | grep -v grep | wc -l)
    echo -e "   Active UEs: ${GREEN}$active${NC}"
    sudo docker exec ueransim ps aux 2>/dev/null | grep "nr-ue" | grep -v grep || echo "   No UE processes found"
done
