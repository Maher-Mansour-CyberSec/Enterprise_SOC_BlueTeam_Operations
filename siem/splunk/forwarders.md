# Splunk Universal Forwarder Configuration

## Overview

This document provides detailed configuration for Splunk Universal Forwarders on Windows and Linux endpoints.

---

## Windows Forwarder Configuration

### Installation

```powershell
# Download
Invoke-WebRequest -Uri "https://download.splunk.com/products/universalforwarder/releases/9.1.2/windows/splunkforwarder-9.1.2-windows-x64.msi" -OutFile "C:\Temp\splunkforwarder.msi"

# Install
msiexec /i C:\Temp\splunkforwarder.msi AGREETOLICENSE=yes SPLUNKUSERNAME=admin SPLUNKPASSWORD=changeme DEPLOYMENT_SERVER="192.168.2.9:8089" /quiet /norestart

# Verify service
Get-Service SplunkForwarder
```

### inputs.conf

**Location:** `C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf`

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

[WinEventLog://Microsoft-Windows-Windows Defender/Operational]
disabled = 0
start_from = oldest
current_only = 0
checkpointInterval = 5
index = windows
```

### outputs.conf

**Location:** `C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf`

```ini
[tcpout]
defaultGroup = indexers

[tcpout:indexers]
server = 192.168.2.9:9997

[tcpout-server://192.168.2.9:9997]
sslCertPath = $SPLUNK_HOME\etc\certs\forwarder.pem
sslRootCAPath = $SPLUNK_HOME\etc\certs\ca.pem
sslPassword = password
sslVerifyServerCert = true
```

### deploymentclient.conf

**Location:** `C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf`

```ini
[target-broker:deploymentServer]
targetUri = 192.168.2.9:8089
```

---

## Linux Forwarder Configuration

### Installation

```bash
# Download
wget -O splunkforwarder.tgz "https://download.splunk.com/products/universalforwarder/releases/9.1.2/linux/splunkforwarder-9.1.2-linux-x86_64.tgz"

# Extract
sudo tar -xvzf splunkforwarder.tgz -C /opt

# Start
sudo /opt/splunkforwarder/bin/splunk start --accept-license
sudo /opt/splunkforwarder/bin/splunk enable boot-start
```

### inputs.conf

**Location:** `/opt/splunkforwarder/etc/system/local/inputs.conf`

```ini
[default]
host = $decideOnStartup

[monitor:///var/log]
disabled = 0
index = linux
sourcetype = syslog

[monitor:///var/log/auth.log]
disabled = 0
index = linux
sourcetype = linux_secure

[monitor:///var/log/syslog]
disabled = 0
index = linux
sourcetype = syslog
```

### outputs.conf

**Location:** `/opt/splunkforwarder/etc/system/local/outputs.conf`

```ini
[tcpout]
defaultGroup = indexers

[tcpout:indexers]
server = 192.168.2.9:9997
```

---

## Deployment Server Configuration

### Server Class Setup

1. Go to **Settings** → **Forwarder Management**
2. Click **New Server Class**
3. Name: `windows-endpoints`
4. Add clients by hostname or IP
5. Assign apps to deploy

### App Deployment

Create app structure:
```
$SPLUNK_HOME/etc/deployment-apps/windows_inputs/
├── default/
│   ├── inputs.conf
│   └── outputs.conf
└── local/
```

---

## Verification

### Check Forwarder Status

```powershell
# Windows
& "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe" status

# Linux
sudo /opt/splunkforwarder/bin/splunk status
```

### Test Connection

```powershell
# Windows
& "C:\Program Files\SplunkUniversalForwarder\bin\splunk.exe" list forward-server

# Linux
sudo /opt/splunkforwarder/bin/splunk list forward-server
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
