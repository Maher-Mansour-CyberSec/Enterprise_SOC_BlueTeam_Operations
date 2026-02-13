# SOC L1 Analyst Procedures

## Overview

This document provides standard operating procedures for Tier 1 SOC analysts.

---

## Alert Triage Process

### Step 1: Acknowledge (0-2 minutes)

1. Claim alert in ticketing system
2. Set status to "Under Investigation"
3. Note start time

### Step 2: Initial Assessment (2-5 minutes)

1. Review alert title and description
2. Identify affected asset(s)
3. Check alert severity
4. Verify if part of incident

### Step 3: Quick Verification (5-10 minutes)

1. Is this a known test/scan?
2. Is asset in maintenance window?
3. Is this a known false positive?
4. Check asset criticality

### Step 4: Classification (10-15 minutes)

| Classification | Action |
|----------------|--------|
| Confirmed Malicious | Escalate to L2 immediately |
| Suspicious | Escalate to L2 with context |
| False Positive | Close with documentation |
| Unknown | Request additional info |

---

## Common Alert Types

### Brute Force Alert

**Investigation Steps**:
1. Check source IP reputation
2. Count failed attempts
3. Check for successful logons
4. Verify if service account

**Escalation Criteria**:
- >20 failed attempts
- Successful logon after brute force
- Source IP is external

### Malware Detection Alert

**Investigation Steps**:
1. Verify file hash
2. Check VirusTotal
3. Review process tree
4. Check for lateral movement

**Escalation Criteria**:
- Confirmed malware
- Multiple infected hosts
- Data exfiltration suspected

---

## Escalation Matrix

| Severity | Response Time | Escalate To |
|----------|---------------|-------------|
| Critical | Immediate | L2 + Manager |
| High | 15 minutes | L2 |
| Medium | 1 hour | L2 (end of shift) |
| Low | 4 hours | No escalation |

---

*Document Version: 1.0*  
*Last Updated: 2026-02-12*
