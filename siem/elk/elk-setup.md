# ELK Stack Setup Guide

## Overview

This guide provides step-by-step instructions for deploying the ELK Stack (Elasticsearch, Logstash, Kibana) as the SIEM platform for the Enterprise SOC Lab.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [System Requirements](#system-requirements)
3. [Elasticsearch Installation](#elasticsearch-installation)
4. [Logstash Installation](#logstash-installation)
5. [Kibana Installation](#kibana-installation)
6. [Fleet Server Setup](#fleet-server-setup)
7. [Security Configuration](#security-configuration)
8. [Verification](#verification)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Ubuntu Server 22.04 LTS (recommended)
- Root or sudo access
- Static IP address configured
- Minimum 8GB RAM, 4 CPU cores
- 100GB+ available storage

---

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 8GB | 16GB |
| CPU | 4 cores | 8 cores |
| Disk | 100GB SSD | 500GB SSD |
| Network | 1Gbps | 10Gbps |

---

## Elasticsearch Installation

### Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg
```

### Step 2: Add Elastic Repository

```bash
# Add GPG key
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt update
```

### Step 3: Install Elasticsearch

```bash
sudo apt install -y elasticsearch
```

### Step 4: Configure Elasticsearch

```bash
sudo nano /etc/elasticsearch/elasticsearch.yml
```

Add/modify the following:

```yaml
# Cluster Settings
cluster.name: enterprise-soc-elk
node.name: es-node-1
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

# Network Settings
network.host: 192.168.2.9
http.port: 9200
transport.port: 9300

# Discovery (for single node)
discovery.type: single-node

# Security Settings
xpack.security.enabled: true
xpack.security.enrollment.enabled: true
xpack.security.http.ssl:
  enabled: true
  keystore.path: /etc/elasticsearch/certs/http.p12
xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: /etc/elasticsearch/certs/transport.p12

# Performance
bootstrap.memory_lock: true
indices.memory.index_buffer_size: 30%
```

### Step 5: JVM Configuration

```bash
sudo nano /etc/elasticsearch/jvm.options
```

Set heap size (50% of available RAM):

```
-Xms4g
-Xmx4g
```

### Step 6: Start Elasticsearch

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
```

### Step 7: Set Passwords

```bash
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system
sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u logstash_system
```

Save these passwords securely!

---

## Logstash Installation

### Step 1: Install Logstash

```bash
sudo apt install -y logstash
```

### Step 2: Create Pipeline Configuration

```bash
sudo nano /etc/logstash/conf.d/siem-pipeline.conf
```

```ruby
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/logstash/certs/logstash.crt"
    ssl_key => "/etc/logstash/certs/logstash.key"
  }
  
  syslog {
    port => 514
    type => "firewall"
  }
  
  http {
    port => 8080
    type => "suricata"
  }
}

filter {
  if [type] == "sysmon" {
    json {
      source => "message"
    }
    mutate {
      add_field => { "[@metadata][index]" => "sysmon" }
    }
  }
  
  if [type] == "firewall" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:timestamp} %{HOSTNAME:host} %{DATA:process}: %{GREEDYDATA:msg}" }
    }
    mutate {
      add_field => { "[@metadata][index]" => "firewall" }
    }
  }
  
  if [type] == "suricata" {
    json {
      source => "message"
    }
    mutate {
      add_field => { "[@metadata][index]" => "suricata" }
    }
  }
  
  date {
    match => [ "timestamp", "ISO8601" ]
    target => "@timestamp"
  }
}

output {
  elasticsearch {
    hosts => ["https://192.168.2.9:9200"]
    index => "%{[@metadata][index]}-%{+YYYY.MM.dd}"
    ssl => true
    cacert => "/etc/logstash/certs/ca.crt"
    user => "logstash_system"
    password => "${LOGSTASH_PASSWORD}"
  }
}
```

### Step 3: Start Logstash

```bash
sudo systemctl enable logstash
sudo systemctl start logstash
```

---

## Kibana Installation

### Step 1: Install Kibana

```bash
sudo apt install -y kibana
```

### Step 2: Configure Kibana

```bash
sudo nano /etc/kibana/kibana.yml
```

```yaml
server.port: 5601
server.host: "192.168.2.9"
server.name: "enterprise-soc-kibana"

elasticsearch.hosts: ["https://192.168.2.9:9200"]
elasticsearch.username: "kibana_system"
elasticsearch.password: "${KIBANA_PASSWORD}"
elasticsearch.ssl.certificateAuthorities: ["/etc/kibana/certs/ca.crt"]

xpack.security.encryptionKey: "${ENCRYPTION_KEY}"
xpack.encryptedSavedObjects.encryptionKey: "${ENCRYPTION_KEY}"

logging.root.level: info
```

### Step 3: Start Kibana

```bash
sudo systemctl enable kibana
sudo systemctl start kibana
```

### Step 4: Access Kibana

Open browser: `https://192.168.2.9:5601`

Login with:
- Username: `elastic`
- Password: (from reset-password step)

---

## Fleet Server Setup

### Step 1: Generate Fleet Server Token

In Kibana:
1. Go to **Management** → **Fleet**
2. Click **Add Fleet Server**
3. Select **Quick Start**
4. Copy the installation command

### Step 2: Install Fleet Server

```bash
sudo /opt/Elastic/Agent/elastic-agent install \
  --fleet-server-es=https://192.168.2.9:9200 \
  --fleet-server-service-token=<TOKEN> \
  --fleet-server-policy=fleet-server-policy \
  --certificate-authorities=/etc/elastic/certs/ca.crt
```

### Step 3: Verify Fleet Server

In Kibana:
1. Go to **Management** → **Fleet** → **Agents**
2. Verify Fleet Server appears as "Healthy"

---

## Security Configuration

### TLS Certificate Generation

```bash
# Create certificate directory
sudo mkdir -p /etc/elasticsearch/certs
sudo mkdir -p /etc/logstash/certs
sudo mkdir -p /etc/kibana/certs

# Generate CA
sudo /usr/share/elasticsearch/bin/elasticsearch-certutil ca

# Generate node certificates
sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert \
  --ca elastic-stack-ca.p12 \
  --dns purplekali \
  --ip 192.168.2.9 \
  --name es-node-1

# Export certificates for Logstash and Kibana
sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert \
  --ca elastic-stack-ca.p12 \
  --name logstash

sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert \
  --ca elastic-stack-ca.p12 \
  --name kibana
```

### Firewall Rules

```bash
sudo ufw allow 9200/tcp  # Elasticsearch
sudo ufw allow 9300/tcp  # Elasticsearch transport
sudo ufw allow 5044/tcp  # Logstash Beats
sudo ufw allow 514/udp   # Syslog
sudo ufw allow 5601/tcp  # Kibana
sudo ufw allow 8220/tcp  # Fleet Server
sudo ufw enable
```

---

## Verification

### Check Elasticsearch Health

```bash
curl -k -u elastic:password https://192.168.2.9:9200/_cluster/health
```

Expected output:
```json
{
  "cluster_name": "enterprise-soc-elk",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 1,
  "number_of_data_nodes": 1,
  "active_primary_shards": 0,
  "active_shards": 0
}
```

### Check Logstash Pipeline

```bash
sudo systemctl status logstash
sudo tail -f /var/log/logstash/logstash-plain.log
```

### Check Kibana Status

```bash
sudo systemctl status kibana
curl -k https://192.168.2.9:5601/api/status
```

---

## Troubleshooting

### Elasticsearch Won't Start

```bash
# Check logs
sudo journalctl -u elasticsearch -f

# Verify permissions
sudo chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
sudo chown -R elasticsearch:elasticsearch /var/log/elasticsearch

# Check memory lock
sudo sysctl vm.max_map_count=262144
```

### Logstash Connection Issues

```bash
# Test Elasticsearch connectivity
sudo -u logstash /usr/share/logstash/bin/logstash -e 'input { stdin {} } output { elasticsearch { hosts => ["https://192.168.2.9:9200"] } }'

# Check certificate paths
sudo ls -la /etc/logstash/certs/
```

### Kibana Access Issues

```bash
# Check Elasticsearch connectivity
sudo -u kibana /usr/share/kibana/bin/kibana --config /etc/kibana/kibana.yml --verbose

# Verify firewall
sudo ufw status
```

---

## Next Steps

1. [Configure Logstash Pipelines](./logstash-pipelines.md)
2. [Import Kibana Dashboards](./dashboards.md)
3. [Create Detection Rules](./detection-rules.md)
4. [Deploy Elastic Agents](../forwarders.md)

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
