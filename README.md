# 5G Network Testbed with Monitoring

Complete 5G Standalone Architecture testbed using Open5GS, UERANSIM, InfluxDB, and Grafana.

## Architecture

- **5G Core**: Open5GS v2.7.6 (AMF, SMF, UPF, NRF, SCP, AUSF, UDM, UDR, PCF, NSSF, BSF)
- **RAN Simulator**: UERANSIM v3.2.7 (gNB + UE)
- **Monitoring**: InfluxDB 2.7 + Grafana
- **Network**: Docker 10.10.0.0/16

## Quick Start
```bash
# 1. Build images
docker compose build

# 2. Start all services
docker compose up -d

# 3. Check status
docker compose ps
docker logs metrics-collector -f

# 4. Access Grafana
# http://localhost:3000 (admin/admin123)

# 5. Start gNB
docker exec -d ueransim bash -c "cd /root/ueransim/build && ./nr-gnb -c /root/ueransim-config/gnb.yaml"

# 6. Run traffic simulator
./realistic-5g-traffic.sh
```

## Components

### 5G Core Network Functions
- **AMF** (10.10.0.50): Access and Mobility Management
- **SMF** (10.10.0.7): Session Management
- **UPF** (10.10.0.8): User Plane Function
- **NRF** (10.10.0.12): NF Repository
- **SCP** (10.10.0.35): Service Communication Proxy
- **AUSF** (10.10.0.11): Authentication Server
- **UDM** (10.10.0.13): Unified Data Management
- **UDR** (10.10.0.14): Unified Data Repository
- **PCF** (10.10.0.27): Policy Control
- **NSSF** (10.10.0.28): Network Slice Selection
- **BSF** (10.10.0.29): Binding Support

### Monitoring Stack
- **InfluxDB** (10.10.0.3:8086): Time-series database
- **Grafana** (10.10.0.4:3000): Visualization dashboard
- **Metrics Collector** (10.10.0.5): Python collector for KPIs

### Subscribers
- **MongoDB** (10.10.0.2:27017): Subscriber database
- 10 pre-registered UEs (IMSI: 286010000000001-010)

## Monitoring Dashboard

Access Grafana at http://localhost:3000 to view:

- **Connected Devices**: Active UE count
- **Active Sessions**: AMF signaling sessions
- **PDU Sessions**: SMF data sessions
- **Data Sessions**: UPF user plane sessions
- **Network Uptime**: System runtime
- **Service Health**: Metrics collection rate per NF

## Traffic Simulation

The `realistic-5g-traffic.sh` script simulates 5 user behavior patterns:

- **Browsing**: Intermittent bursts (web surfing)
- **Streaming**: Continuous heavy traffic (video)
- **Messaging**: Sporadic short packets (chat apps)
- **Idle**: Minimal keepalive traffic
- **Downloading**: Pulsating high load periods

## Configuration

All network functions use template-based configuration with environment variable substitution via init scripts.

**Config structure:**
```
config-templates/
├── amf/
│   ├── amf_init.sh    # Substitutes env vars
│   └── amf.yaml       # Template with placeholders
└── ...
```

## Metrics Collection

Custom Python collector (`metrics-collector/collector.py`):
- Scrapes Prometheus endpoints every 30s
- Calculates KPIs (connected devices, sessions, uptime)
- Stores in InfluxDB with dual measurements:
  - `5g_metrics`: Raw metrics with service tags
  - `network_kpi`: Aggregated KPIs

## Requirements

- Docker & Docker Compose
- 4GB+ RAM
- Linux kernel with TUN/TAP support

## Troubleshooting

**Network conflicts:**
```bash
docker compose down -v
docker network prune -f
docker compose up -d
```

**View logs:**
```bash
docker logs <service-name> -f
```

**Clean restart:**
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker network prune -f
docker compose up -d
```

## Project Structure
```
├── config-templates/      # NF configuration templates
├── metrics-collector/     # Python KPI collector
├── ueransim/             # UERANSIM Dockerfile
├── ueransim-config/      # gNB & UE configs
├── open5gs-docker/       # Open5GS Dockerfile
├── latex/                # Technical report
├── docker-compose.yml    # Full stack definition
└── realistic-5g-traffic.sh  # Traffic generator
```

## License

Based on Open5GS (AGPL-3.0) and UERANSIM (GPL-3.0)
