# ELK Detection Rules (KQL)

## Overview

This document provides Kibana Query Language (KQL) detection rules for the Enterprise SOC Lab.

---

## Brute Force Detection

### Rule: Multiple Failed Logins

```kql
event.code:4625 AND winlog.event_data.LogonType:3
```

**Alert Threshold**: >5 events in 5 minutes from same source IP

**MITRE**: T1110 - Brute Force

### Rule: Account Lockout

```kql
event.code:4740
```

**Alert Threshold**: Any occurrence

**MITRE**: T1110 - Brute Force

---

## Credential Dumping Detection

### Rule: LSASS Access

```kql
event.code:10 AND winlog.event_data.TargetImage:*lsass.exe* AND 
(winlog.event_data.GrantedAccess:0x1010 OR 
 winlog.event_data.GrantedAccess:0x1038 OR 
 winlog.event_data.GrantedAccess:0x1438)
```

**Alert Threshold**: Any occurrence

**MITRE**: T1003.001 - LSASS Memory

### Rule: SAM Database Access

```kql
event.code:4661 AND winlog.event_data.ObjectType:SAM_DOMAIN
```

**Alert Threshold**: Any occurrence

**MITRE**: T1003.002 - SAM Database

---

## PowerShell Suspicious Activity

### Rule: Encoded Command

```kql
event.code:4104 AND 
(powershell.file.script_block_text:*-enc* OR 
 powershell.file.script_block_text:*-encodedcommand* OR 
 powershell.file.script_block_text:*FromBase64String*)
```

**Alert Threshold**: Any occurrence

**MITRE**: T1059.001 - PowerShell

### Rule: Suspicious PowerShell Downloads

```kql
event.code:4104 AND 
(powershell.file.script_block_text:*Net.WebClient* OR 
 powershell.file.script_block_text:*Invoke-WebRequest* OR 
 powershell.file.script_block_text:*wget* OR 
 powershell.file.script_block_text:*curl*) AND
(powershell.file.script_block_text:*http* OR 
 powershell.file.script_block_text:*https*)
```

**Alert Threshold**: Any occurrence

**MITRE**: T1059.001 - PowerShell

---

## Lateral Movement Detection

### Rule: SMB Connection to Multiple Hosts

```kql
event.code:4624 AND winlog.event_data.LogonType:3 AND 
winlog.event_data.AuthenticationPackageName:NTLM
```

**Alert Threshold**: Same source IP connecting to >5 unique destinations in 10 minutes

**MITRE**: T1021.002 - SMB/Windows Admin Shares

### Rule: PsExec Usage

```kql
event.code:7045 AND winlog.event_data.ServiceName:PSEXESVC
```

**Alert Threshold**: Any occurrence

**MITRE**: T1569.002 - Service Execution

---

## Persistence Detection

### Rule: Registry Run Key Modification

```kql
event.code:13 AND registry.path:*\\Software\\Microsoft\\Windows\\CurrentVersion\\Run*
```

**Alert Threshold**: Any occurrence

**MITRE**: T1547.001 - Registry Run Keys

### Rule: Scheduled Task Creation

```kql
event.code:4698
```

**Alert Threshold**: Any occurrence

**MITRE**: T1053.005 - Scheduled Task

---

## Network Anomaly Detection

### Rule: Suspicious DNS Query

```kql
event.code:22 AND 
(dns.question.name:*.onion OR 
 dns.question.name:*.top OR 
 dns.question.name:*.xyz OR 
 LENGTH(dns.question.name) > 50)
```

**Alert Threshold**: Any occurrence

**MITRE**: T1071.004 - DNS

### Rule: C2 Communication

```kql
suricata.eve.alert.signature:*C2* OR 
suricata.eve.alert.signature:*trojan* OR 
suricata.eve.alert.signature:*malware*
```

**Alert Threshold**: Any occurrence

**MITRE**: T1071 - Application Layer Protocol

---

## Privilege Escalation Detection

### Rule: Token Impersonation

```kql
event.code:4624 AND winlog.event_data.LogonType:9
```

**Alert Threshold**: Any occurrence

**MITRE**: T1134.001 - Token Impersonation

### Rule: UAC Bypass

```kql
event.code:1 AND 
(process.executable:*fodhelper.exe OR 
 process.executable:*computerdefaults.exe OR 
 process.executable:*sdclt.exe)
```

**Alert Threshold**: Any occurrence

**MITRE**: T1548.002 - Bypass User Account Control

---

## Creating Detection Rules in Kibana

### Step 1: Create Rule

1. Go to **Security** → **Rules**
2. Click **Create new rule**
3. Select **Custom query**

### Step 2: Define Query

```kql
event.code:4625 AND winlog.event_data.LogonType:3
```

### Step 3: Configure Schedule

- **Runs every**: 5 minutes
- **Additional look-back time**: 1 minute

### Step 4: Set Actions

- Send email to SOC team
- Create case in ticketing system
- Trigger webhook for SOAR

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
