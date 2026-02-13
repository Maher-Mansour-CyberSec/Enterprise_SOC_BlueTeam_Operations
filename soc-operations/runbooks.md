# Operational Runbooks

## Overview

This document provides operational runbooks for common SOC tasks.

---

## Runbook 1: Environment Initialization

### Prerequisites
- All VMs provisioned
- Network connectivity verified
- Administrative access

### Procedure

```bash
# Test connectivity
ping -c 3 192.168.2.1    # pfSense
ping -c 3 192.168.2.2    # DC
ping -c 3 192.168.2.9    # PurpleKali

# Verify services
systemctl status elasticsearch  # ELK
systemctl status splunk         # Splunk
systemctl status apache2        # MISP
```

---

## Runbook 2: Telemetry Verification

### Windows Events

```powershell
# Generate test event
runas /user:cyberlab\fakeuser cmd.exe

# Verify in SIEM
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 5
```

### Sysmon

```powershell
# Generate process event
notepad.exe

# Verify
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} -MaxEvents 5
```

---

## Runbook 3: False Positive Handling

### Process

1. Verify alert legitimacy
2. Document false positive reason
3. Create tuning recommendation
4. Update detection rule
5. Document in knowledge base

---

## Runbook 4: SIEM Maintenance

### Daily Tasks

```bash
# Check cluster health
curl -k -u elastic:password https://192.168.2.9:9200/_cluster/health

# Check disk space
df -h

# Review alerts
```

### Weekly Tasks

```bash
# Update Suricata rules
suricata-update

# Update MISP feeds
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
