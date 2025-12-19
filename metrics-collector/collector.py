#!/usr/bin/env python3
import time
import os
import sys
import re
import requests
from datetime import datetime
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

print("=" * 70)
print("5G Network Analytics Collector")
print("=" * 70)

# Configuration
INFLUXDB_URL = os.getenv('INFLUXDB_URL', 'http://influxdb:8086')
INFLUXDB_TOKEN = os.getenv('INFLUXDB_TOKEN', 'my-super-secret-token')
INFLUXDB_ORG = os.getenv('INFLUXDB_ORG', 'primary')
INFLUXDB_BUCKET = os.getenv('INFLUXDB_BUCKET', '5g_metrics')

METRICS_ENDPOINTS = {
    'amf': 'http://10.10.0.50:9090/metrics',
    'smf': 'http://10.10.0.7:9090/metrics',
    'upf': 'http://10.10.0.8:9090/metrics',
    'pcf': 'http://10.10.0.27:9090/metrics',
}

client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = client.write_api(write_options=SYNCHRONOUS)

# Track state for calculating derivatives
state = {
    'start_time': time.time(),
    'last_collection': {},
    'ue_history': [],
    'session_history': []
}

def parse_metric(line):
    """Parse Prometheus metric"""
    if not line or line.startswith('#'):
        return None
    
    match = re.match(r'^([a-zA-Z_:][a-zA-Z0-9_:]*)\{?([^}]*)\}?\s+([0-9.e+\-]+|NaN)$', line)
    if match:
        name, labels_str, value_str = match.groups()
        
        if value_str == 'NaN':
            return None
        
        labels = {}
        if labels_str:
            for label in labels_str.split(','):
                if '=' in label:
                    k, v = label.split('=', 1)
                    labels[k.strip()] = v.strip('"')
        
        return {
            'name': name,
            'value': float(value_str),
            'labels': labels
        }
    return None

def calculate_kpis(raw_metrics):
    """Calculate useful KPIs from raw metrics"""
    kpis = {
        'connected_devices': 0,
        'active_sessions': 0,
        'registration_attempts': 0,
        'registration_success': 0,
        'pdu_sessions': 0,
        'data_sessions': 0,
        'network_uptime_seconds': time.time() - state['start_time']
    }
    
    for service, metrics in raw_metrics.items():
        for metric in metrics:
            name = metric['name']
            value = metric['value']
            
            # Count connected UEs
            if 'amf' in service and any(x in name.lower() for x in ['ue', 'subscriber', 'registered']):
                if 'nbr' in name or 'number' in name or 'count' in name:
                    kpis['connected_devices'] += int(value)
            
            # Count sessions
            if 'session' in name.lower():
                if 'amf' in service:
                    kpis['active_sessions'] += int(value)
                elif 'smf' in service:
                    kpis['pdu_sessions'] += int(value)
                elif 'upf' in service:
                    kpis['data_sessions'] += int(value)
            
            # Registration tracking
            if 'registration' in name.lower() or 'attach' in name.lower():
                kpis['registration_attempts'] += int(value)
                if 'success' in name.lower() or 'accept' in name.lower():
                    kpis['registration_success'] += int(value)
    
    return kpis

def collect_metrics():
    """Collect and analyze metrics"""
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    print(f"\n[{timestamp}] Collecting...", flush=True)
    
    raw_metrics = {}
    
    # Collect raw metrics
    for service, endpoint in METRICS_ENDPOINTS.items():
        try:
            response = requests.get(endpoint, timeout=5)
            if response.status_code == 200:
                metrics = []
                for line in response.text.split('\n'):
                    parsed = parse_metric(line)
                    if parsed:
                        metrics.append(parsed)
                raw_metrics[service] = metrics
                print(f"  ✓ {service.upper():4s}: {len(metrics)} metrics", flush=True)
            else:
                raw_metrics[service] = []
                print(f"  ✗ {service.upper():4s}: HTTP {response.status_code}", flush=True)
        except Exception as e:
            raw_metrics[service] = []
            print(f"  ✗ {service.upper():4s}: {type(e).__name__}", flush=True)
    
    # Calculate KPIs
    kpis = calculate_kpis(raw_metrics)
    
    # Store KPIs
    print(f"\n  📊 Network KPIs:", flush=True)
    print(f"     • Connected Devices: {kpis['connected_devices']}", flush=True)
    print(f"     • Active Sessions: {kpis['active_sessions']}", flush=True)
    print(f"     • PDU Sessions: {kpis['pdu_sessions']}", flush=True)
    print(f"     • Data Sessions: {kpis['data_sessions']}", flush=True)
    print(f"     • Network Uptime: {kpis['network_uptime_seconds']:.0f}s", flush=True)
    
    # Write KPIs to InfluxDB
    for kpi_name, kpi_value in kpis.items():
        point = Point("network_kpi") \
            .tag("metric_type", kpi_name) \
            .field("value", float(kpi_value))
        write_api.write(bucket=INFLUXDB_BUCKET, record=point)
    
    # Write raw metrics with service tags
    for service, metrics in raw_metrics.items():
        for metric in metrics:
            point = Point("5g_metrics") \
                .tag("service", service) \
                .tag("metric_name", metric['name'])
            
            for label_key, label_value in metric['labels'].items():
                point = point.tag(label_key, label_value)
            
            point = point.field("value", metric['value'])
            write_api.write(bucket=INFLUXDB_BUCKET, record=point)
    
    # Track trends
    state['ue_history'].append({
        'time': time.time(),
        'count': kpis['connected_devices']
    })
    if len(state['ue_history']) > 60:  # Keep last hour
        state['ue_history'].pop(0)
    
    return kpis

def main():
    print(f"\nInfluxDB: {INFLUXDB_URL}")
    print(f"Bucket: {INFLUXDB_BUCKET}")
    print("-" * 70)
    print("\nWaiting 10s for services...", flush=True)
    time.sleep(10)
    
    collection_num = 0
    
    while True:
        try:
            collection_num += 1
            print(f"\n{'='*70}")
            print(f"Collection #{collection_num}")
            print(f"{'='*70}")
            
            kpis = collect_metrics()
            
            print(f"{'='*70}\n")
            
        except KeyboardInterrupt:
            print("\n\nShutting down...", flush=True)
            break
        except Exception as e:
            print(f"\n❌ Error: {e}", flush=True)
        
        time.sleep(30)

if __name__ == '__main__':
    main()
