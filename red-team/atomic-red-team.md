# Atomic Red Team

## Overview

Atomic Red Team is a library of tests mapped to the MITRE ATT&CK framework for testing detection capabilities.

---

## Installation

### On Red Kali

```bash
# Clone repository
git clone https://github.com/redcanaryco/atomic-red-team.git
cd atomic-red-team

# Install PowerShell module (for Windows)
Install-Module -Name invoke-atomicredteam -Scope CurrentUser
```

---

## Running Tests

### List Available Tests

```powershell
# Windows
Invoke-AtomicTest -ShowDetailsBrief

# Filter by technique
Invoke-AtomicTest T1003 -ShowDetails
```

### Execute Test

```powershell
# Run specific atomic test
Invoke-AtomicTest T1003.001 -TestNumbers 1

# Run all tests for a technique
Invoke-AtomicTest T1003.001

# Run with cleanup
Invoke-AtomicTest T1003.001 -Cleanup
```

---

## Common Tests

### Credential Dumping (T1003.001)

```powershell
Invoke-AtomicTest T1003.001
```

**Detection**: Sysmon Event ID 10 (LSASS access)

### Brute Force (T1110.001)

```powershell
Invoke-AtomicTest T1110.001
```

**Detection**: Windows Event ID 4625 (Failed logon)

### PowerShell (T1059.001)

```powershell
Invoke-AtomicTest T1059.001
```

**Detection**: Windows Event ID 4104 (Script block logging)

---

## Validation

After running tests, verify detection in SIEM:

```spl
index=windows EventCode=4625 earliest=-15m
| stats count by src_ip, AccountName
```

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
