# Splunk Saved Searches (Detection Rules)

## Overview

This document provides SPL (Search Processing Language) detection rules for Splunk Enterprise.

---

## Brute Force Detection

### Rule: Multiple Failed Logins

```spl
[Brute_Force_Detection]
search = index=windows EventCode=4625 earliest=-5m 
| stats count by src_ip, TargetUserName 
| where count > 5 
| eval severity=case(count>20, "critical", count>10, "high", 1=1, "medium")

dispatch.earliest_time = -5m
dispatch.latest_time = now
cron_schedule = */5 * * * *
alert.track = 1
alert.severity = 4
action.notable = 1
action.notable.param.rule_description = Brute force attack from $src_ip$ against $TargetUserName$ with $count$ attempts
action.notable.param.rule_title = Brute Force Attack Detected
action.notable.param.security_domain = access
```

**MITRE**: T1110 - Brute Force

---

## Credential Dumping Detection

### Rule: LSASS Access

```spl
[Credential_Dumping_LSASS]
search = index=sysmon EventCode=10 TargetImage="*lsass.exe*" 
    (GrantedAccess="*0x1010*" OR GrantedAccess="*0x1038*" OR GrantedAccess="*0x1438*")
| stats count by Computer, SourceImage, GrantedAccess

dispatch.earliest_time = -5m
dispatch.latest_time = now
cron_schedule = */5 * * * *
alert.track = 1
alert.severity = 5
action.notable = 1
action.notable.param.rule_description = Possible credential dumping on $Computer$ from $SourceImage$
action.notable.param.rule_title = Credential Dumping Detected
action.notable.param.security_domain = endpoint
```

**MITRE**: T1003.001 - LSASS Memory

---

## PowerShell Suspicious Activity

### Rule: Encoded Command

```spl
[Suspicious_PowerShell_Encoded]
search = index=windows EventCode=4104 earliest=-5m
| where match(ScriptBlockText, "(?i)-enc|-encodedcommand|FromBase64String")
| stats count by Computer, UserID, ScriptBlockText

dispatch.earliest_time = -5m
dispatch.latest_time = now
cron_schedule = */5 * * * *
alert.track = 1
alert.severity = 4
action.notable = 1
```

**MITRE**: T1059.001 - PowerShell

---

## Lateral Movement Detection

### Rule: SMB Lateral Movement

```spl
[Lateral_Movement_SMB]
search = index=windows EventCode=4624 LogonType=3 earliest=-10m
| stats dc(Computer) as unique_targets, values(Computer) as targets by SourceIp
| where unique_targets > 5

dispatch.earliest_time = -10m
dispatch.latest_time = now
cron_schedule = */10 * * * *
alert.track = 1
alert.severity = 4
action.notable = 1
action.notable.param.rule_description = Potential lateral movement from $SourceIp$ to $unique_targets$ hosts
action.notable.param.rule_title = Lateral Movement Detected
```

**MITRE**: T1021.002 - SMB/Windows Admin Shares

---

## Persistence Detection

### Rule: New Scheduled Task

```spl
[Scheduled_Task_Created]
search = index=windows EventCode=4698 earliest=-15m
| xmlkv EventData
| stats count by ComputerName, SubjectUserName, TaskName

dispatch.earliest_time = -15m
dispatch.latest_time = now
cron_schedule = */15 * * * *
alert.track = 1
alert.severity = 3
action.notable = 1
```

**MITRE**: T1053.005 - Scheduled Task

---

## Network Anomaly Detection

### Rule: Suspicious DNS Queries

```spl
[Suspicious_DNS_Queries]
search = index=sysmon EventCode=22 earliest=-5m
| where match(QueryName, "(?i)\\.onion$|\\.top$|\\.xyz$")
| stats count by Computer, Image, QueryName

dispatch.earliest_time = -5m
dispatch.latest_time = now
cron_schedule = */5 * * * *
alert.track = 1
alert.severity = 3
```

**MITRE**: T1071.004 - DNS

---

## Creating Saved Searches

### Via Splunk Web

1. Go to **Settings** → **Searches, reports, and alerts**
2. Click **New**
3. Enter search name and SPL query
4. Set schedule and alerting options
5. Save

### Via savedsearches.conf

**Location:** `/opt/splunk/etc/apps/search/local/savedsearches.conf`

```ini
[My_Detection_Rule]
search = index=windows EventCode=4625 | stats count by src_ip
alert.track = 1
cron_schedule = */5 * * * *
dispatch.earliest_time = -5m
dispatch.latest_time = now
action.email = 1
action.email.to = soc@example.com
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
