# Splunk Enterprise Setup Guide

## Overview

This guide provides step-by-step instructions for deploying Splunk Enterprise as the SIEM platform for the Enterprise SOC Lab.

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

## Splunk Enterprise Installation

### Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Download Splunk

```bash
wget -O splunk-9.1.2.tgz "https://download.splunk.com/products/splunk/releases/9.1.2/linux/splunk-9.1.2-linux-x86_64.tgz"
```

### Step 3: Extract and Install

```bash
sudo tar -xvzf splunk-9.1.2.tgz -C /opt
sudo /opt/splunk/bin/splunk start --accept-license
sudo /opt/splunk/bin/splunk enable boot-start
```

### Step 4: Set Admin Password

```bash
sudo /opt/splunk/bin/splunk edit user admin -password 'YourSecurePassword123!' -auth admin:changeme
```

---

## Index Configuration

### Create Indexes

```bash
sudo /opt/splunk/bin/splunk add index windows -auth admin:password
sudo /opt/splunk/bin/splunk add index sysmon -auth admin:password
sudo /opt/splunk/bin/splunk add index network -auth admin:password
sudo /opt/splunk/bin/splunk add index threatintel -auth admin:password
sudo /opt/splunk/bin/splunk add index web -auth admin:password
```

### Index Settings

**File:** `/opt/splunk/etc/system/local/indexes.conf`

```ini
[windows]
homePath = $SPLUNK_DB/windows/db
coldPath = $SPLUNK_DB/windows/colddb
thawedPath = $SPLUNK_DB/windows/thaweddb
maxDataSize = auto_high_volume
maxTotalDataSizeMB = 500000
frozenTimePeriodInSecs = 2592000

[sysmon]
homePath = $SPLUNK_DB/sysmon/db
coldPath = $SPLUNK_DB/sysmon/colddb
thawedPath = $SPLUNK_DB/sysmon/thaweddb
maxDataSize = auto_high_volume
maxTotalDataSizeMB = 500000
frozenTimePeriodInSecs = 2592000

[network]
homePath = $SPLUNK_DB/network/db
coldPath = $SPLUNK_DB/network/colddb
thawedPath = $SPLUNK_DB/network/thaweddb
maxTotalDataSizeMB = 200000
frozenTimePeriodInSecs = 2592000

[threatintel]
homePath = $SPLUNK_DB/threatintel/db
coldPath = $SPLUNK_DB/threatintel/colddb
thawedPath = $SPLUNK_DB/threatintel/thaweddb
maxTotalDataSizeMB = 50000
frozenTimePeriodInSecs = 7776000
```

---

## Data Input Configuration

### Syslog Input (Suricata/pfSense)

**File:** `/opt/splunk/etc/system/local/inputs.conf`

```ini
[udp://514]
connection_host = ip
sourcetype = syslog
index = network

[tcp://514]
connection_host = ip
sourcetype = syslog
index = network
```

### HTTP Event Collector (HEC)

1. Go to **Settings** → **Data Inputs** → **HTTP Event Collector**
2. Click **New Token**
3. Name: `suricata-hec`
4. Source type: `suricata`
5. Index: `network`
6. Click **Next** → **Review** → **Submit**
7. Copy the token value

---

## Props and Transforms

### Windows Event Log Parsing

**File:** `/opt/splunk/etc/system/local/props.conf`

```ini
[source::WinEventLog:Security]
SHOULD_LINEMERGE = false
TIME_PREFIX = <TimeCreated SystemTime='
TIME_FORMAT = %Y-%m-%dT%H:%M:%S.%9N%Z
KV_MODE = xml
EVAL-event_id = EventID
EVAL-src_ip = if(EventID==4625 OR EventID==4624, IpAddress, null())
EVAL-user = if(EventID==4625, TargetUserName, if(EventID==4624, TargetUserName, null()))
EVAL-action = if(EventID==4625, "failure", if(EventID==4624, "success", null()))

[source::WinEventLog:Microsoft-Windows-Sysmon/Operational]
SHOULD_LINEMERGE = false
TIME_PREFIX = <TimeCreated SystemTime='
TIME_FORMAT = %Y-%m-%dT%H:%M:%S.%9N%Z
KV_MODE = xml
EVAL-sysmon_event_id = EventID
EVAL-process_name = Image
EVAL-parent_process = ParentImage
EVAL-command_line = CommandLine
EVAL-source_ip = SourceIp
EVAL-destination_ip = DestinationIp
EVAL-destination_port = DestinationPort
```

### Suricata Parsing

```ini
[suricata]
SHOULD_LINEMERGE = false
TIME_PREFIX = "timestamp":"
TIME_FORMAT = %Y-%m-%dT%H:%M:%S.%6N%z
KV_MODE = json
EVAL-src_ip = json_extract(_raw, "src_ip")
EVAL-dest_ip = json_extract(_raw, "dest_ip")
EVAL-alert_signature = json_extract(_raw, "alert.signature")
EVAL-alert_category = json_extract(_raw, "alert.category")
EVAL-alert_severity = json_extract(_raw, "alert.severity")
```

---

## Universal Forwarder Deployment

### Download and Install

On Windows endpoints:

```powershell
# Download Splunk Universal Forwarder
Invoke-WebRequest -Uri "https://download.splunk.com/products/universalforwarder/releases/9.1.2/windows/splunkforwarder-9.1.2-windows-x64.msi" -OutFile "splunkforwarder.msi"

# Install silently
msiexec /i splunkforwarder.msi AGREETOLICENSE=yes SPLUNKUSERNAME=admin SPLUNKPASSWORD=changeme DEPLOYMENT_SERVER="192.168.2.9:8089" /quiet
```

### Configure Forwarder

**File:** `C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf`

```ini
[default]
host = $decideOnStartup

[WinEventLog://Security]
disabled = 0
start_from = oldest
current_only = 0
evt_resolve_ad_obj = 1
checkpointInterval = 5
index = windows
renderXml = true

[WinEventLog://Microsoft-Windows-Sysmon/Operational]
disabled = 0
start_from = oldest
current_only = 0
checkpointInterval = 5
index = sysmon
renderXml = true

[WinEventLog://System]
disabled = 0
start_from = oldest
current_only = 0
checkpointInterval = 5
index = windows

[WinEventLog://Microsoft-Windows-PowerShell/Operational]
disabled = 0
start_from = oldest
current_only = 0
checkpointInterval = 5
index = windows
```

### Configure Outputs

**File:** `C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf`

```ini
[tcpout]
defaultGroup = indexers

[tcpout:indexers]
server = 192.168.2.9:9997
sslCertPath = $SPLUNK_HOME\etc\certs\forwarder.pem
sslRootCAPath = $SPLUNK_HOME\etc\certs\ca.pem
sslPassword = password
```

---

## Access Splunk Web

Open browser: `https://192.168.2.9:8000`

Login with:
- Username: `admin`
- Password: (set during installation)

---

## Verification

### Check Indexer Status

```bash
sudo /opt/splunk/bin/splunk status
```

### Check Forwarder Connections

```bash
sudo /opt/splunk/bin/splunk list forward-server
```

### Verify Data Ingestion

In Splunk Search:
```spl
index=_internal earliest=-1h
| stats count by source, sourcetype
```

---

## Troubleshooting

### Splunk Won't Start

```bash
# Check logs
sudo tail -f /opt/splunk/var/log/splunk/splunkd.log

# Verify permissions
sudo chown -R splunk:splunk /opt/splunk

# Check disk space
df -h
```

### Forwarder Connection Issues

```bash
# Test connectivity
telnet 192.168.2.9 9997

# Check forwarder logs
Get-Content "C:\Program Files\SplunkUniversalForwarder\var\log\splunk\splunkd.log" -Tail 50
```

---

## Next Steps

1. [Configure Universal Forwarders](./forwarders.md)
2. [Import Splunk Dashboards](./dashboards.md)
3. [Create Saved Searches](./saved-searches.md)

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
