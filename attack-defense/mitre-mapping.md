# MITRE ATT&CK Framework Mapping

## Table of Contents

1. [Overview](#overview)
2. [Technique Coverage Matrix](#technique-coverage-matrix)
3. [Tactic Coverage](#tactic-coverage)
4. [Detection Rules](#detection-rules)
5. [Data Sources](#data-sources)
6. [Mitigation Strategies](#mitigation-strategies)

---

## Overview

### MITRE ATT&CK Framework

MITRE ATT&CK is a globally-accessible knowledge base of adversary tactics and techniques based on real-world observations. This document maps the lab's attack scenarios and detection capabilities to the MITRE ATT&CK framework.

### Framework Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MITRE ATT&CK FRAMEWORK STRUCTURE                        │
└─────────────────────────────────────────────────────────────────────────────┘

TACTICS (14 total)              TECHNIQUES (200+)              SUB-TECHNIQUES
    │                                   │                              │
    ├── Initial Access                  ├── T1566 Phishing             ├── T1566.001 Spearphishing Attachment
    ├── Execution                       ├── T1059 Command Execution    ├── T1059.001 PowerShell
    ├── Persistence                     ├── T1547 Boot Persistence     ├── T1547.001 Registry Run Keys
    ├── Privilege Escalation            ├── T1078 Valid Accounts       ├── T1078.001 Local Accounts
    ├── Defense Evasion                 └── ...                        └── ...
    ├── Credential Access
    ├── Discovery
    ├── Lateral Movement
    ├── Collection
    ├── Command and Control
    ├── Exfiltration
    └── Impact
```

---

## Technique Coverage Matrix

### Complete Lab Coverage

| Technique ID | Technique Name | Tactic | Attack Tool | Detection Method |
|--------------|----------------|--------|-------------|------------------|
| T1046 | Network Service Scanning | Discovery | Nmap | Suricata, ELK/Splunk |
| T1087.001 | Account Discovery: Local Account | Discovery | Enum4linux | Windows Event 4624, 5140 |
| T1087.002 | Account Discovery: Domain Account | Discovery | Enum4linux | Windows Event 4624, 5140 |
| T1135 | Network Share Discovery | Discovery | Enum4linux | Windows Event 5140 |
| T1110.001 | Brute Force: Password Guessing | Credential Access | Hydra | Windows Event 4625, 4740 |
| T1110.002 | Brute Force: Password Cracking | Credential Access | Hashcat | Windows Event 4624 |
| T1558.003 | Steal Kerberos Tickets: Kerberoasting | Credential Access | GetUserSPNs | Windows Event 4769 |
| T1003.001 | OS Credential Dumping: LSASS Memory | Credential Access | Mimikatz | Sysmon Event 10 |
| T1003.002 | OS Credential Dumping: SAM | Credential Access | CrackMapExec | Windows Event 4656, 4661 |
| T1021.002 | Remote Services: SMB/Windows Admin Shares | Lateral Movement | CrackMapExec | Windows Event 4624, 4672 |
| T1569.002 | System Services: Service Execution | Execution | PsExec | Windows Event 7045, 4688 |
| T1134.001 | Access Token Manipulation: Token Impersonation | Privilege Escalation | Incognito | Sysmon Event 10, 25 |
| T1558.001 | Steal Kerberos Tickets: Golden Ticket | Credential Access | Mimikatz | Windows Event 4624 (Type 9) |
| T1059.001 | Command and Scripting Interpreter: PowerShell | Execution | PowerShell | Windows Event 4103, 4104 |
| T1071.001 | Application Layer Protocol: Web Protocols | Command and Control | HTTP C2 | Suricata, Packetbeat |
| T1190 | Exploit Public-Facing Application | Initial Access | SQLMap | Suricata Web Rules |
| T1040 | Network Sniffing | Credential Access | Wireshark | Network Monitoring |
| T1070.004 | Indicator Removal: File Deletion | Defense Evasion | rm/del | Windows Event 4663 |
| T1078.002 | Valid Accounts: Domain Accounts | Defense Evasion | Pass-the-Hash | Windows Event 4624 |
| T1090 | Proxy | Command and Control | SSH Tunnel | Network Flow Analysis |

---

## Tactic Coverage

### Initial Access

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INITIAL ACCESS (TA0001)                              │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1190 - Exploit Public-Facing Application
├── Description: Exploit vulnerabilities in public-facing web applications
├── Tool: SQLMap, Burp Suite
├── Target: DVWA (192.168.4.10)
└── Detection:
    ├── Suricata: ET WEB_SERVER Possible SQL Injection Attempt
    ├── Web Server Logs: 192.168.2.50 - - [11/Feb/2026:11:15:33] "GET /vulnerabilities/sqli/?id=1' AND 1=1
    └── ELK Query: suricata.eve.alert.signature:*SQL* AND source.ip:192.168.2.50
```

### Execution

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EXECUTION (TA0002)                                   │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1059.001 - Command and Scripting Interpreter: PowerShell
├── Description: Use PowerShell for command execution
├── Tool: PowerShell, Empire
├── Target: Windows endpoints
└── Detection:
    ├── Windows Event 4103: Module Logging
    ├── Windows Event 4104: Script Block Logging
    ├── Sysmon Event 1: Process Creation
    └── ELK Query: event.code:4104 AND powershell.file.script_block_text:*

Technique: T1569.002 - System Services: Service Execution
├── Description: Create or modify system services to execute commands
├── Tool: PsExec, SC
├── Target: Windows services
└── Detection:
    ├── Windows Event 7045: Service Installation
    ├── Windows Event 4688: Process Creation (PSEXESVC.exe)
    ├── Sysmon Event 1: Process Creation
    └── ELK Query: event.code:7045 AND winlog.event_data.ServiceName:PSEXESVC
```

### Persistence

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PERSISTENCE (TA0003)                                 │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1547.001 - Boot or Logon Autostart Execution: Registry Run Keys
├── Description: Add entries to registry run keys for persistence
├── Tool: reg.exe, PowerShell
├── Target: Windows Registry
└── Detection:
    ├── Sysmon Event 12: Registry Object Added/Deleted
    ├── Sysmon Event 13: Registry Value Set
    ├── Windows Event 4663: Object Access
    └── ELK Query: event.code:13 AND registry.path:*\\Run\\*
```

### Privilege Escalation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PRIVILEGE ESCALATION (TA0004)                        │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1134.001 - Access Token Manipulation: Token Impersonation/Theft
├── Description: Steal and impersonate user access tokens
├── Tool: Incognito, Mimikatz token::elevate
├── Target: Windows processes
└── Detection:
    ├── Sysmon Event 10: Process Access (LSASS)
    ├── Sysmon Event 25: Process Tampering
    ├── Windows Event 4672: Special Privileges Assigned
    └── ELK Query: event.code:10 AND winlog.event_data.TargetImage:*lsass.exe

Technique: T1078.002 - Valid Accounts: Domain Accounts
├── Description: Use compromised domain accounts for privilege escalation
├── Tool: Pass-the-Hash, Pass-the-Ticket
├── Target: Domain authentication
└── Detection:
    ├── Windows Event 4624: Logon (Type 9 - NewCredentials)
    ├── Windows Event 4768: Kerberos TGT Request
    ├── Windows Event 4769: Kerberos Service Ticket
    └── ELK Query: event.code:4624 AND winlog.event_data.LogonType:9
```

### Defense Evasion

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DEFENSE EVASION (TA0005)                             │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1070.004 - Indicator Removal: File Deletion
├── Description: Delete files to remove indicators of activity
├── Tool: rm, del, sdelete
├── Target: Log files, artifacts
└── Detection:
    ├── Windows Event 4663: Object Access (Delete)
    ├── Sysmon Event 23: File Delete
    ├── Sysmon Event 26: File Delete Detected
    └── ELK Query: event.code:4663 AND winlog.event_data.AccessMask:0x10000
```

### Credential Access

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CREDENTIAL ACCESS (TA0006)                           │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1110.001 - Brute Force: Password Guessing
├── Description: Guess passwords through automated attempts
├── Tool: Hydra, CrackMapExec
├── Target: SMB, RDP, SSH
└── Detection:
    ├── Windows Event 4625: Failed Logon
    ├── Windows Event 4740: Account Lockout
    ├── Suricata: ET SCAN Multiple SMB Login Failures
    └── ELK Query: event.code:4625 AND winlog.event_data.LogonType:3

Technique: T1110.002 - Brute Force: Password Cracking
├── Description: Crack password hashes offline
├── Tool: Hashcat, John the Ripper
├── Target: NTLM hashes, Kerberos tickets
└── Detection:
    ├── Windows Event 4624: Successful Logon (after brute force)
    ├── Windows Event 4769: Kerberos Service Ticket (RC4)
    └── ELK Query: event.code:4769 AND winlog.event_data.TicketEncryptionType:0x17

Technique: T1558.003 - Steal or Forge Kerberos Tickets: Kerberoasting
├── Description: Request service tickets for offline cracking
├── Tool: GetUserSPNs.py, Rubeus
├── Target: Kerberos service accounts
└── Detection:
    ├── Windows Event 4769: Service Ticket Requested (RC4)
    ├── Multiple 4769 events from single source
    └── ELK Query: event.code:4769 AND winlog.event_data.TicketEncryptionType:0x17

Technique: T1003.001 - OS Credential Dumping: LSASS Memory
├── Description: Extract credentials from LSASS process memory
├── Tool: Mimikatz sekurlsa::logonpasswords, CrackMapExec --lsa
├── Target: LSASS process
└── Detection:
    ├── Sysmon Event 10: Process Access (LSASS)
    ├── Windows Event 4656: Object Access
    └── ELK Query: event.code:10 AND winlog.event_data.TargetImage:*lsass.exe AND winlog.event_data.GrantedAccess:0x1010

Technique: T1003.002 - OS Credential Dumping: Security Account Manager
├── Description: Extract credentials from SAM database
├── Tool: Mimikatz lsadump::sam, CrackMapExec --sam
├── Target: SAM database
└── Detection:
    ├── Windows Event 4656: Object Access (SAM)
    ├── Windows Event 4661: SAM Handle Request
    └── ELK Query: event.code:4661 AND winlog.event_data.ObjectType:SAM_USER

Technique: T1558.001 - Steal or Forge Kerberos Tickets: Golden Ticket
├── Description: Forge Kerberos TGT using krbtgt hash
├── Tool: Mimikatz kerberos::golden
├── Target: Kerberos authentication
└── Detection:
    ├── Windows Event 4624: Logon (Type 9)
    ├── Missing TGT request (4768) before TGS (4769)
    └── ELK Query: event.code:4624 AND winlog.event_data.LogonType:9 AND NOT _exists_:winlog.event_data.LmPackageName
```

### Discovery

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DISCOVERY (TA0007)                                   │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1046 - Network Service Scanning
├── Description: Scan network for open ports and services
├── Tool: Nmap, Masscan
├── Target: Network infrastructure
└── Detection:
    ├── Suricata: ET SCAN Potential Port Scan
    ├── Suricata: ET SCAN Multiple Ports Scan
    └── ELK Query: event.dataset:suricata.eve AND suricata.eve.alert.signature:*scan*

Technique: T1087.001 - Account Discovery: Local Account
├── Description: Enumerate local user accounts
├── Tool: Enum4linux, net user
├── Target: Windows systems
└── Detection:
    ├── Windows Event 4624: Logon (Anonymous)
    ├── Windows Event 5140: Network Share Access (IPC$)
    └── ELK Query: event.code:4624 AND winlog.event_data.AccountName:ANONYMOUS*

Technique: T1087.002 - Account Discovery: Domain Account
├── Description: Enumerate domain user accounts
├── Tool: Enum4linux, ldapsearch
├── Target: Active Directory
└── Detection:
    ├── Windows Event 4661: SAM Handle Request
    ├── LDAP queries to Domain Controller
    └── ELK Query: event.code:4661 AND winlog.event_data.ObjectType:SAM_DOMAIN

Technique: T1135 - Network Share Discovery
├── Description: Discover network shares
├── Tool: Enum4linux, net view
├── Target: SMB shares
└── Detection:
    ├── Windows Event 5140: Network Share Access
    └── ELK Query: event.code:5140
```

### Lateral Movement

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LATERAL MOVEMENT (TA0008)                            │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1021.002 - Remote Services: SMB/Windows Admin Shares
├── Description: Use SMB for lateral movement
├── Tool: CrackMapExec, PsExec, SMBexec
├── Target: SMB shares, ADMIN$
└── Detection:
    ├── Windows Event 4624: Logon (Type 3)
    ├── Windows Event 4672: Special Privileges Assigned
    ├── Windows Event 5140: Network Share Access (ADMIN$)
    └── ELK Query: event.code:4624 AND winlog.event_data.LogonType:3 AND winlog.event_data.IpAddress:192.168.2.50
```

### Command and Control

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COMMAND AND CONTROL (TA0011)                         │
└─────────────────────────────────────────────────────────────────────────────┘

Technique: T1071.001 - Application Layer Protocol: Web Protocols
├── Description: Use HTTP/HTTPS for C2 communication
├── Tool: Metasploit, Cobalt Strike
├── Target: Web traffic
└── Detection:
    ├── Suricata: ET MALWARE Possible C2 Communication
    ├── Packetbeat: Unusual HTTP traffic patterns
    └── ELK Query: event.dataset:packetbeat AND network.protocol:http AND destination.port:443

Technique: T1090 - Proxy
├── Description: Use proxy for C2 communication
├── Tool: SSH tunnel, SOCKS proxy
├── Target: Network traffic
└── Detection:
    ├── Suricata: ET POLICY SSH Tunnel Detected
    ├── Network flow analysis
    └── ELK Query: event.dataset:suricata.eve AND suricata.eve.alert.signature:*tunnel*
```

---

## Detection Rules

### Splunk Saved Searches

```spl
# Brute Force Detection
[Brute_Force_Detection]
search = index=windows EventCode=4625 earliest=-5m 
| stats count by src_ip, TargetUserName 
| where count > 5 
| eval alert_severity=case(count>20, "critical", count>10, "high", 1=1, "medium")
| eval alert_title="Brute Force Attack Detected"

dispatch.earliest_time = -5m
dispatch.latest_time = now
cron_schedule = */5 * * * *
alert.track = 1
action.notable = 1

# LSASS Access Detection
[Credential_Dumping_LSASS]
search = index=sysmon EventCode=10 TargetImage="*lsass.exe*" 
    (GrantedAccess="*0x1010*" OR GrantedAccess="*0x1038*" OR GrantedAccess="*0x1438*")
| stats count by Computer, SourceImage, GrantedAccess
| eval alert_title="Credential Dumping Detected"

dispatch.earliest_time = -5m
dispatch.latest_time = now
cron_schedule = */5 * * * *
alert.track = 1
alert.severity = 5
action.notable = 1

# Lateral Movement Detection
[Lateral_Movement_SMB]
search = index=windows EventCode=4624 LogonType=3 earliest=-10m
| stats dc(Computer) as unique_targets, values(Computer) as targets by SourceIp
| where unique_targets > 5
| eval alert_title="Potential Lateral Movement"

dispatch.earliest_time = -10m
dispatch.latest_time = now
cron_schedule = */10 * * * *
alert.track = 1
action.notable = 1
```

### ELK Detection Rules (KQL)

```kql
# Brute Force Detection
event.code:4625 AND winlog.event_data.LogonType:3
| STATS count BY source.ip, winlog.event_data.TargetUserName
| WHERE count > 5

# LSASS Access Detection
event.code:10 AND winlog.event_data.TargetImage:*lsass.exe*
  AND (winlog.event_data.GrantedAccess:0x1010 
       OR winlog.event_data.GrantedAccess:0x1038 
       OR winlog.event_data.GrantedAccess:0x1438)

# PowerShell Encoded Command
event.code:4104 AND powershell.file.script_block_text:(*-enc* OR *-encodedcommand* OR *FromBase64String*)

# Registry Persistence
event.code:13 AND registry.path:*\\Software\\Microsoft\\Windows\\CurrentVersion\\Run*
```

---

## Data Sources

### Data Source Mapping

| Data Source | Techniques Covered | Tools |
|-------------|-------------------|-------|
| Windows Event Log | 50+ | Winlogbeat, Splunk UF |
| Sysmon | 40+ | Winlogbeat, Splunk UF |
| Suricata EVE | 30+ | Filebeat, Logstash |
| Packetbeat | 20+ | Packetbeat |
| Auditd (Linux) | 15+ | Auditbeat |
| MISP Threat Intel | 10+ | Filebeat, Logstash |

### Data Quality Metrics

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATA SOURCE COVERAGE                                 │
└─────────────────────────────────────────────────────────────────────────────┘

Windows Event Log:    ████████████████████████████████████████  95%
Sysmon:               ████████████████████████████████████████  90%
Suricata:             ████████████████████████████████████      85%
Packetbeat:           ████████████████████████████████          75%
Auditd:               ██████████████████████████                65%
MISP:                 ████████████████████                      50%
```

---

## Mitigation Strategies

### Mitigation Mapping

| Technique | Mitigation ID | Mitigation Name | Implementation |
|-----------|---------------|-----------------|----------------|
| T1110.001 | M1036 | Account Use Policies | Account lockout, password complexity |
| T1003.001 | M1028 | Operating System Configuration | Credential Guard, LSA protection |
| T1003.002 | M1027 | Password Policies | SAM encryption, SYSKEY |
| T1021.002 | M1026 | Privileged Account Management | Restrict admin shares, SMB signing |
| T1569.002 | M1021 | Restrict Web-Based Content | Service control manager ACLs |
| T1046 | M1031 | Network Intrusion Prevention | Port scanning detection |
| T1190 | M1048 | Application Isolation and Sandboxing | WAF, input validation |
| T1059.001 | M1042 | Disable or Remove Feature or Program | Constrained Language Mode |
| T1558.003 | M1047 | Audit | Monitor 4769 events, RC4 detection |
| T1558.001 | M1027 | Password Policies | KRBTGT password rotation |

---

*Document Version: 2.0*  
*Last Updated: 2026-02-12*  
*Author: Enterprise Security Architecture Team*
