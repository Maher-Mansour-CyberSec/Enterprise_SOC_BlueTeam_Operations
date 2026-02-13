# SOC L2 Analyst Procedures

## Overview

This document provides advanced procedures for Tier 2 SOC analysts.

---

## Escalation Review Process

### Step 1: Review L1 Findings (0-10 minutes)

1. Read case summary
2. Review collected evidence
3. Understand L1 assessment
4. Identify investigation gaps

### Step 2: Deep Investigation (10-60 minutes)

1. Replicate key searches
2. Validate IOC matches
3. Expand timeline analysis
4. Check for correlations

### Step 3: Threat Assessment

| Assessment | Criteria | Action |
|------------|----------|--------|
| Confirmed Compromise | Malware present, unauthorized access | Initiate Incident Response |
| Suspicious | Anomalous behavior, no clear compromise | Enhanced monitoring |
| False Positive | Legitimate activity confirmed | Close and tune |

---

## Forensic Collection

### Memory Dump

```bash
# On Windows host
winpmem.exe -o memory.raw
```

### Log Collection

```powershell
# Export Security log
wevtutil epl Security C:\temp\Security.evtx

# Export Sysmon log
copy "C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx" C:\temp\
```

---

## Incident Response

### Containment

1. Isolate affected host
2. Block malicious IPs
3. Disable compromised accounts
4. Preserve evidence

### Eradication

1. Remove malware
2. Patch vulnerabilities
3. Reset credentials
4. Verify system integrity

### Recovery

1. Restore from backup
2. Rebuild systems if needed
3. Verify functionality
4. Return to production

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
